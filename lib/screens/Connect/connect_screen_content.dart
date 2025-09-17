import 'package:flutter/material.dart';
import 'package:timeleft_clone/components/Cards/ChatCard.dart';
import 'package:timeleft_clone/components/Cards/SwipableChatCard.dart';
import 'package:timeleft_clone/components/Modals/connection_modal.dart';
import 'package:timeleft_clone/screens/main_screen.dart';
import 'package:timeleft_clone/screens/Connect/chat_detail_screen.dart';
import 'package:timeleft_clone/services/api_service.dart';
import 'package:timeleft_clone/services/chat_service.dart';
import 'package:timeleft_clone/models/chat_model.dart';
import 'package:timeleft_clone/services/connection_service.dart';
import 'package:timeleft_clone/services/dinner_service.dart';
import 'package:timeleft_clone/services/notification_service.dart';

class ConnectScreenContent extends StatefulWidget {
  final int? dinnerIdForAttendees; // Add this parameter

  const ConnectScreenContent({
    Key? key,
    this.dinnerIdForAttendees, // Add this parameter
  }) : super(key: key);

  @override
  ConnectScreenContentState createState() => ConnectScreenContentState();
}

class ConnectScreenContentState extends State<ConnectScreenContent>
    with AutomaticKeepAliveClientMixin {
  List<Chat> _chats = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _hasChats = false;
  bool _modalCurrentlyShowing = false;
  bool _hasShownModalThisSession = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadChats();

    // Check for modal on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.dinnerIdForAttendees != null) {
        // If we have a specific dinner ID, show attendees for that dinner
        _checkForDinnerIdAttendees(widget.dinnerIdForAttendees!);
      } else {
        // Otherwise, check for recent dinner attendees
        _checkForRecentDinnerAttendees();
      }
    });
  }

  // This method will be called from MainScreen when user switches to Connect tab
  void onTabSelected() {
    if (!_modalCurrentlyShowing) {
      if (widget.dinnerIdForAttendees != null) {
        _checkForDinnerIdAttendees(widget.dinnerIdForAttendees!);
      } else {
        _checkForRecentDinnerAttendees();
      }
    }
  }

  void _refreshNotificationsGlobally() {
    NotificationEventService().refreshNotifications();
  }

  Future<void> _checkForDinnerIdAttendees(int dinnerId) async {
    if (_modalCurrentlyShowing || _hasShownModalThisSession) return;

    try {
      // Get attendees for specific dinner ID
      final response = await DinnerService.getDinnerIdAttendees(dinnerId);

      if (response != null && response.isNotEmpty && mounted) {
        // Enrich attendees with connection status
        final enrichedAttendees =
            await _enrichAttendeesWithConnectionStatus(response);

        if (enrichedAttendees.isNotEmpty &&
            mounted &&
            !_modalCurrentlyShowing &&
            !_hasShownModalThisSession) {
          setState(() {
            _modalCurrentlyShowing = true;
            _hasShownModalThisSession = true;
          });

          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (BuildContext context) {
              return ConnectionModal(
                attendees: enrichedAttendees,
                dinnerTitle: 'Past Dinner Attendees',
                onConnectionsUpdated: () {
                  _loadChats();
                  _refreshNotificationsGlobally();
                },
                onNotificationUpdate: () {
                  // Trigger notification refresh in the main screen
                  // You can use a callback or state management for this
                  _refreshNotificationsGlobally();
                },
              );
            },
          ).whenComplete(() {
            if (mounted) {
              setState(() {
                _modalCurrentlyShowing = false;
              });
            }
          });
        }
      }
    } catch (e) {
      print('Error checking for dinner ID attendees: $e');
      if (mounted) {
        setState(() {
          _modalCurrentlyShowing = false;
        });

        // Show error message if access is forbidden (dinner too old)
        if (e.toString().contains('older than 1 day')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Cannot connect with attendees from dinners older than 1 day'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }
  }

  Future<void> _checkForRecentDinnerAttendees() async {
    if (_modalCurrentlyShowing || _hasShownModalThisSession) return;

    try {
      // First, get the basic attendee list
      final response = await DinnerService.getRecentDinnerAttendees();

      if (response != null && response.isNotEmpty && mounted) {
        // Now enrich each attendee with connection status
        final enrichedAttendees =
            await _enrichAttendeesWithConnectionStatus(response);

        if (enrichedAttendees.isNotEmpty &&
            mounted &&
            !_modalCurrentlyShowing &&
            !_hasShownModalThisSession) {
          setState(() {
            _modalCurrentlyShowing = true;
            _hasShownModalThisSession = true;
          });

          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (BuildContext context) {
              return ConnectionModal(
                attendees: enrichedAttendees,
                dinnerTitle: 'Recent Dinner',
                onConnectionsUpdated: () {
                  _loadChats();
                },
              );
            },
          ).whenComplete(() {
            if (mounted) {
              setState(() {
                _modalCurrentlyShowing = false;
              });
            }
          });
        }
      }
    } catch (e) {
      print('Error checking for recent dinner attendees: $e');
      if (mounted) {
        setState(() {
          _modalCurrentlyShowing = false;
        });
      }
    }
  }

  Future<List<Map<String, dynamic>>> _enrichAttendeesWithConnectionStatus(
      List<dynamic> attendees) async {
    final enrichedAttendees = <Map<String, dynamic>>[];

    try {
      // Get pending requests to see who wants to connect with current user
      final pendingRequests = await ConnectionService.getPendingRequests();
      final pendingRequestsMap = <int, Map<String, dynamic>>{};

      if (pendingRequests != null && pendingRequests['requests'] != null) {
        for (var request in pendingRequests['requests']) {
          final senderId = request['sender']['id'];
          pendingRequestsMap[senderId] = {
            'connection_id': request['connection_id'],
            'pending_request_received': true,
          };
        }
      }

      // Process each attendee
      for (var attendee in attendees) {
        final userId = attendee['id'];
        final enrichedAttendee = Map<String, dynamic>.from(attendee);

        // Check if this user has sent a request to current user
        if (pendingRequestsMap.containsKey(userId)) {
          enrichedAttendee.addAll(pendingRequestsMap[userId]!);
        } else {
          // Check connection status with this user
          try {
            final statusResponse =
                await ConnectionService.getConnectionStatusWithUser(userId);
            if (statusResponse != null) {
              enrichedAttendee['already_connected'] =
                  statusResponse['already_connected'] ?? false;
              enrichedAttendee['connection_request_sent'] =
                  statusResponse['connection_request_sent'] ?? false;
              enrichedAttendee['pending_request_received'] =
                  statusResponse['pending_request_received'] ?? false;
              enrichedAttendee['connection_id'] =
                  statusResponse['connection_id'];
            } else {
              // Default values if status check fails
              enrichedAttendee['already_connected'] = false;
              enrichedAttendee['connection_request_sent'] = false;
              enrichedAttendee['pending_request_received'] = false;
              enrichedAttendee['connection_id'] = null;
            }
          } catch (e) {
            print('Error getting connection status for user $userId: $e');
            // Default values on error
            enrichedAttendee['already_connected'] = false;
            enrichedAttendee['connection_request_sent'] = false;
            enrichedAttendee['pending_request_received'] = false;
            enrichedAttendee['connection_id'] = null;
          }
        }

        enrichedAttendees.add(enrichedAttendee);
      }
    } catch (e) {
      print('Error enriching attendees with connection status: $e');
      // Return attendees with default connection status if enrichment fails
      for (var attendee in attendees) {
        final enrichedAttendee = Map<String, dynamic>.from(attendee);
        enrichedAttendee['already_connected'] = false;
        enrichedAttendee['connection_request_sent'] = false;
        enrichedAttendee['pending_request_received'] = false;
        enrichedAttendee['connection_id'] = null;
        enrichedAttendees.add(enrichedAttendee);
      }
    }

    return enrichedAttendees;
  }

  // Method to reset the modal state (call this when user gets new dinner attendees)
  void resetModalState() {
    // This method can be removed since we want modal to show every time
    // when there are recent dinner attendees available
  }

  Future<void> _loadChats() async {
    if (!mounted) return;

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final chats = await ChatService.getUserChats();

      if (!mounted) return;

      setState(() {
        _chats = chats;
        _hasChats = chats.isNotEmpty;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _hasChats = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    await _loadChats();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFEF1DE),
        elevation: 0,
        title: Text(
          'Connect',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.black,
              size: 24,
            ),
            onPressed: _isLoading
                ? null
                : () async {
                    await _loadChats();
                    // Also refresh modal state for new dinner attendees
                    _hasShownModalThisSession = false;
                    // Check for new attendees after refresh
                    if (widget.dinnerIdForAttendees != null) {
                      _checkForDinnerIdAttendees(widget.dinnerIdForAttendees!);
                    } else {
                      _checkForRecentDinnerAttendees();
                    }
                  },
            tooltip: 'Refresh',
          ),
        ],
      ),
      backgroundColor: Color(0xFFFEF1DE),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_hasChats) {
      return _buildChatList();
    }

    return _buildOnboardingState();
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            'Failed to load chats',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Unknown error occurred',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadChats,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF6B46C1),
              foregroundColor: Colors.white,
            ),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _chats.length,
        itemBuilder: (context, index) {
          final chat = _chats[index];
          return SwipeableChatCard(
            chat: chat,
            onTap: () => _openChat(chat),
            onDelete: () => _deleteChat(chat),
          );
        },
      ),
    );
  }

  Future<void> _deleteChat(Chat chat) async {
    try {
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Deleting conversation...'),
              ],
            ),
          ),
        ),
      );

      await ChatService.deleteChat(chat.id);

      await ConnectionService.removeConnection(chat.otherUser.id);

      if (mounted) Navigator.pop(context);

      if (!mounted) return;

      setState(() {
        _chats.removeWhere((c) => c.id == chat.id);
        _hasChats = _chats.isNotEmpty;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Conversation deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete conversation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildOnboardingState() {
    return Container(
      color: Color(0xFFFEF1DE),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                top: 0,
                                left: 20,
                                child: Icon(
                                  Icons.auto_awesome,
                                  size: 16,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              Positioned(
                                bottom: 10,
                                right: 15,
                                child: Icon(
                                  Icons.auto_awesome,
                                  size: 12,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(20),
                                child: Icon(
                                  Icons.chat_bubble_outline,
                                  size: 80,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 30),
                          Text(
                            'Start connecting!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Join dinners and give feedback to discover compatible connections. Book a new seat to start!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 40),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      MainScreen(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                const begin = Offset(-1.0, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.ease;
                                var tween = Tween(begin: begin, end: end).chain(
                                  CurveTween(curve: curve),
                                );
                                return SlideTransition(
                                  position: animation.drive(tween),
                                  child: child,
                                );
                              },
                            ),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          'Book my seat',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openChat(Chat chat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(chat: chat),
      ),
    ).then((_) {
      _loadChats();
    });
  }
}
