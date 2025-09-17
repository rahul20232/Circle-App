// SOLUTION 1: Update ProfileScreenContent to refresh when returning from EditProfileScreen

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:timeleft_clone/models/user_model.dart';
import 'package:timeleft_clone/screens/Profile/EditProfile/edit_profile_screen.dart';
import 'package:timeleft_clone/screens/Profile/webview_screen.dart';
import '../../services/auth_service.dart';
import '../bookings_screen.dart';
import 'settings/settings_screen.dart';

class ProfileScreenContent extends StatefulWidget {
  @override
  _ProfileScreenContentState createState() => _ProfileScreenContentState();
}

class _ProfileScreenContentState extends State<ProfileScreenContent> {
  final String _webViewKey = DateTime.now().millisecondsSinceEpoch.toString();

  // Add this method to refresh user data
  void _refreshProfile() async {
    await AuthService.loadUserSession(); // reload from SharedPreferences
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFEF1DE),
        elevation: 0,
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 15.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
              child: Center(
                child: SvgPicture.asset(
                  'assets/settings.svg',
                  width: 25, // optional
                  height: 25, // optional // optional: change SVG color
                ),
              ),
            ),
          )
          // IconButton(
          //   icon: Icon(
          //     Icons.settings,
          //     size: 28,
          //     color: Colors.grey.shade700,
          //   ),
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => SettingsScreen()),
          //     );
          //   },
          // ),
        ],
      ),
      backgroundColor: Color(0xFFFEF1DE),
      body: Container(
        color: Color(0xFFFEF1DE),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: ValueListenableBuilder<AppUser?>(
                      valueListenable: AuthService.currentUserNotifier,
                      builder: (context, user, _) {
                        return Column(
                          children: [
                            SizedBox(height: 40),

                            // In your profile_screen_content.dart, replace the profile picture Container with:

                            Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.shade300,
                                border: Border.all(
                                  color: Colors.grey.shade800,
                                  width: 2,
                                ),
                              ),
                              child: (user?.profilePictureUrl != null &&
                                      user!.profilePictureUrl!.isNotEmpty &&
                                      user!.profilePictureUrl!
                                          .startsWith('http'))
                                  ? ClipOval(
                                      child: Image.network(
                                        user!.profilePictureUrl!,
                                        width: 110,
                                        height: 110,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Icon(
                                            Icons.person,
                                            size: 40,
                                            color: Colors.grey.shade800,
                                          );
                                        },
                                      ),
                                    )
                                  : Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.grey.shade800,
                                    ),
                            ),

                            SizedBox(height: 20),

                            // User Name - This will now update automatically
                            Text(
                              user?.displayName ?? 'User',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey.shade800,
                              ),
                            ),

                            SizedBox(height: 10),

                            // Edit Profile Button - UPDATED to wait for result and refresh
                            Container(
                              width: 140,
                              margin: EdgeInsets.symmetric(horizontal: 40),
                              child: OutlinedButton(
                                onPressed: () async {
                                  // Wait for the EditProfileScreen to return
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditProfileScreen(),
                                    ),
                                  );

                                  if (result == true) {
                                    await AuthService.loadUserSession();
                                    // ✅ will auto-notify ValueListenableBuilder
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  side: BorderSide(
                                      color: Colors.grey.shade800, width: 1.5),
                                ),
                                child: Text(
                                  'Edit profile',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 40),

                            // Your Bookings Card
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BookingsScreen()),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: Colors.grey.shade800, width: 1.5),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_outlined,
                                      size: 24,
                                      color: Colors.grey.shade800,
                                    ),
                                    SizedBox(width: 16),
                                    Text(
                                      'Your Bookings',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                    Spacer(),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Colors.grey.shade800,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 16),

                            // Help Center Card
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: Colors.grey.shade400, width: 1),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.help_outline,
                                    size: 24,
                                    color: Colors.grey.shade800,
                                  ),
                                  SizedBox(width: 16),
                                  Text(
                                    'Help Center',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 16),

                            // Guide Card
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: Colors.grey.shade400, width: 1),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Guide',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Discover our 6 steps to talking to strangers and having unforgettable dinners.',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey.shade700,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      OutlinedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  GuideWebViewScreen(
                                                key: ValueKey(
                                                    'webview_$_webViewKey'),
                                                url: 'https://rahulsehgal.xyz/',
                                                title: 'Dinner Guide',
                                              ),
                                            ),
                                          );
                                        },
                                        style: OutlinedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 8,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          side: BorderSide(
                                              color: Colors.grey.shade800,
                                              width: 1.5),
                                        ),
                                        child: Text(
                                          'Check it out',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 40),
                          ],
                        );
                      }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
