import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:timeleft_clone/models/dinner_model.dart';
import 'package:timeleft_clone/screens/main_screen.dart';
import 'package:timeleft_clone/services/api_service.dart';
import 'package:timeleft_clone/services/dinner_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';

class BookingDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> booking;
  final Dinner? dinner;

  const BookingDetailsScreen({
    Key? key,
    required this.booking,
    this.dinner,
  }) : super(key: key);

  @override
  _BookingDetailsScreenState createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  GoogleMapController? _mapController;
  LatLng? _restaurantLocation;
  Set<Marker> _markers = {};

  NavigatorState? _cachedNavigator;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cache the navigator reference for safe disposal
    _cachedNavigator = Navigator.of(context);
  }

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  void _initializeLocation() {
    if (widget.dinner?.location != null) {
      // Use actual coordinates if available, otherwise default to Bengaluru
      if (widget.dinner!.latitude != null && widget.dinner!.longitude != null) {
        _restaurantLocation =
            LatLng(widget.dinner!.latitude!, widget.dinner!.longitude!);
      } else {
        // Fallback to default coordinates
        _restaurantLocation = LatLng(12.9716, 77.5946);
      }

      _markers.add(
        Marker(
          markerId: MarkerId('restaurant'),
          position: _restaurantLocation!,
          infoWindow: InfoWindow(
            title: widget.dinner?.title ?? 'Restaurant',
            snippet: widget.dinner?.location,
          ),
        ),
      );
    }
  }

  // Helper method to check if dinner is in the past
  bool get _isPastDinner {
    if (widget.dinner == null) return false;
    return widget.dinner!.date.isBefore(DateTime.now());
  }

  // Helper method to get display status
  String get _displayStatus {
    if (_isPastDinner) {
      return 'Past';
    }
    return widget.booking['status']?.toString() ?? 'Unknown';
  }

  // Helper method to format date
  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  // Helper method to format time
  String _formatTime(DateTime date) {
    final hour =
        date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  // Helper method to get status color
  Color _getStatusColor(String status) {
    if (_isPastDinner) {
      return Colors.orange.shade600; // Orange for past dinners
    }

    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFEF1DE),
      appBar: AppBar(
        backgroundColor: Color(0xFFFEF1DE),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Booking Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              widget.dinner?.title ?? 'Dinner Booking',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8),

            // Booking Status
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(_displayStatus).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getStatusColor(_displayStatus),
                  width: 1,
                ),
              ),
              child: Text(
                _displayStatus.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(_displayStatus),
                ),
              ),
            ),
            SizedBox(height: 24),

            // Date & Time Card
            if (widget.dinner != null) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            color: Colors.black87, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Date & Time',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      _formatDate(widget.dinner!.date),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _formatTime(widget.dinner!.date),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
            ],

            // Location Container with Google Map
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(Icons.location_on,
                            color: Colors.red.shade400, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Restaurant Location',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Address
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      widget.dinner?.location ?? 'Location not available',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Google Map
                  if (_restaurantLocation != null) ...[
                    Container(
                      height: 200,
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: GoogleMap(
                          onMapCreated: (GoogleMapController controller) {
                            _mapController = controller;
                          },
                          initialCameraPosition: CameraPosition(
                            target: _restaurantLocation!,
                            zoom: 15.0,
                          ),
                          markers: _markers,
                          zoomControlsEnabled: false,
                          mapToolbarEnabled: false,
                          myLocationButtonEnabled: false,
                          compassEnabled: false,
                          scrollGesturesEnabled: true,
                          zoomGesturesEnabled: true,
                          rotateGesturesEnabled: false,
                          tiltGesturesEnabled: false,
                        ),
                      ),
                    ),
                  ] else ...[
                    // Fallback if no location data
                    Container(
                      height: 200,
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_off,
                                color: Colors.grey, size: 32),
                            SizedBox(height: 8),
                            Text(
                              'Location not available',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Get Directions Button
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _restaurantLocation != null
                            ? () {
                                // TODO: Open in Google Maps or Apple Maps
                                _openInMaps();
                              }
                            : null,
                        icon: Icon(Icons.directions, size: 18),
                        label: Text('Get Directions'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: Colors.blue, width: 1.5),
                          foregroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Available Spots (only show for future dinners)
            if (widget.dinner != null && !_isPastDinner) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.people,
                            color: Colors.green.shade600, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Available Spots',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      '${widget.dinner!.availableSpots} spots remaining',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
            ],

            // Booking ID
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking ID',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.booking['id']?.toString() ?? 'N/A',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Action Buttons (only for future confirmed bookings)
            // Action Buttons
            if (_isPastDinner &&
                widget.booking['status']?.toString().toLowerCase() ==
                    'confirmed') ...[
              // Connect with Attendees button for past confirmed dinners
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _navigateToConnectScreen();
                  },
                  icon: Icon(Icons.people, size: 18),
                  label: Text('Connect with Attendees'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Color(0xFF6B46C1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ] else if (!_isPastDinner &&
                widget.booking['status']?.toString().toLowerCase() ==
                    'confirmed') ...[
              // Cancel Booking button for future confirmed dinners
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    _showCancelBookingDialog(context);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.red, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel Booking',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _navigateToConnectScreen() {
    final dinnerId = widget.dinner?.id;
    if (dinnerId == null) return;

    // Navigate to MainScreen with Connect tab and pass dinner ID
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(
          initialIndex: 2, // Connect tab
          dinnerIdForAttendees: dinnerId,
        ),
      ),
      (route) => false, // Clear all previous routes
    );
  }

  void _openInMaps() async {
    if (_restaurantLocation != null) {
      final lat = _restaurantLocation!.latitude;
      final lng = _restaurantLocation!.longitude;
      print('Opening maps for location: $lat, $lng');
      final url =
          'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    }
  }

  void _showCancelBookingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Color(0xFFFEF1DE),
          title: Text(
            'Cancel Booking',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to cancel this booking? This action cannot be undone.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                try {
                  Navigator.pop(dialogContext);
                } catch (e) {
                  print('Error closing dialog: $e');
                }
              },
              child: Text(
                'Keep Booking',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _handleBookingCancellation(dialogContext);
              },
              child: Text(
                'Cancel Booking',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleBookingCancellation(BuildContext dialogContext) async {
    // Close dialog immediately
    try {
      Navigator.pop(dialogContext);
    } catch (e) {
      print('Error closing dialog: $e');
    }

    // Early exit if widget is disposed
    if (!mounted) return;

    // Store references before async operation
    final navigator = _cachedNavigator;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (navigator == null) return;

    // Show loading
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (loadingContext) => Center(
          child: CircularProgressIndicator(),
        ),
      );
    } catch (e) {
      print('Error showing loading dialog: $e');
      return;
    }

    try {
      HapticFeedback.heavyImpact();

      await Future.delayed(Duration(seconds: 1));

      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 50); // Short 50ms buzz
      }

      final bookingId = widget.booking['id'] as int;
      final success = await DinnerService.cancelBooking(bookingId);

      // Check if still mounted after async operation
      if (!mounted) return;

      // Close loading dialog
      try {
        navigator.pop();
      } catch (e) {
        print('Error closing loading dialog: $e');
      }

      if (success) {
        // Return to bookings screen
        try {
          navigator.pop({'refreshNeeded': true});
        } catch (e) {
          print('Error navigating back: $e');
        }

        // Show success message
        if (mounted) {
          try {
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text('Booking cancelled successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } catch (e) {
            print('Error showing success message: $e');
          }
        }
      } else {
        // Show error message
        if (mounted) {
          try {
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text('Failed to cancel booking'),
                backgroundColor: Colors.red,
              ),
            );
          } catch (e) {
            print('Error showing error message: $e');
          }
        }
      }
    } catch (e) {
      // Handle API errors
      if (!mounted) return;

      try {
        navigator.pop(); // Close loading
      } catch (navError) {
        print('Error closing loading on error: $navError');
      }

      if (mounted) {
        try {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        } catch (snackError) {
          print('Error showing error snackbar: $snackError');
        }
      }
    }
  }
}
