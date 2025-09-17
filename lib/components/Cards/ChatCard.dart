import 'package:flutter/material.dart';
import '../../models/chat_model.dart';

class ChatCard extends StatelessWidget {
  final Chat chat;
  final VoidCallback onTap;

  const ChatCard({
    Key? key,
    required this.chat,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: double.infinity,
          height: 100,
          child: Stack(
            children: <Widget>[
              // Black border/background
              Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.black,
                ),
              ),
              // Inner white container
              Positioned(
                top: 2,
                left: 2,
                right: 2,
                child: Container(
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    color: Color.fromRGBO(250, 250, 250, 1),
                  ),
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Profile picture
                      _buildProfilePicture(),
                      SizedBox(width: 30),
                      // Chat content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Name and time row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    chat.otherUser.displayName,
                                    style: TextStyle(
                                      color: Color.fromRGBO(0, 0, 0, 1),
                                      fontFamily: 'Arial',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (chat.unreadCount > 0)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF6B46C1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      chat.unreadCount.toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            // "Fellow diner" subtitle
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return CircleAvatar(
      radius: 25,
      backgroundColor: Color(0xFF6B46C1),
      backgroundImage: chat.otherUser.profilePictureUrl != null &&
              chat.otherUser.profilePictureUrl!.isNotEmpty
          ? NetworkImage(chat.otherUser.profilePictureUrl!)
          : null,
      child: chat.otherUser.profilePictureUrl == null ||
              chat.otherUser.profilePictureUrl!.isEmpty
          ? Text(
              chat.otherUser.displayName.isNotEmpty
                  ? chat.otherUser.displayName[0].toUpperCase()
                  : 'U',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            )
          : null,
    );
  }
}
