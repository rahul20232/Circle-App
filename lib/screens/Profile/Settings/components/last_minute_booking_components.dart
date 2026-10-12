// lib/screens/Profile/Settings/last_minute_booking_components.dart
import 'package:flutter/material.dart';
import 'package:circle_app/theme/app_colors.dart';
import 'package:circle_app/screens/Profile/Settings/controllers/last_minute_booking_controller.dart';

class LastMinuteBookingComponents {
  final LastMinuteBookingController controller;

  LastMinuteBookingComponents({required this.controller});

  Widget buildDescriptionText() {
    return Text(
      'You must activate at least one type of notification to receive information about last-minute openings.',
      style: TextStyle(
        fontSize: 16,
        color: Colors.black87,
        height: 1.5,
      ),
    );
  }

  Widget buildNotificationOptions() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey300, width: 1),
      ),
      child: Column(
        children: [
          buildNotificationTile(
            'Push notifications',
            controller.pushNotifications,
            controller.setPushNotifications,
            isFirst: true,
          ),
          buildDivider(),
          buildNotificationTile(
            'SMS',
            controller.sms,
            controller.setSms,
          ),
          buildDivider(),
          buildNotificationTile(
            'Email',
            controller.email,
            controller.setEmail,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget buildNotificationTile(
    String title,
    bool value,
    Function(bool) onChanged, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.ink,
              fontWeight: FontWeight.w400,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.surface,
            activeTrackColor: AppColors.success,
            inactiveThumbColor: AppColors.surface,
            inactiveTrackColor: AppColors.grey400,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget buildDivider() {
    return Divider(
      height: 1,
      color: AppColors.grey300,
      indent: 16,
      endIndent: 16,
    );
  }

  Widget buildSaveButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => controller.saveAndNavigateBack(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.ink,
            foregroundColor: AppColors.surface,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 2,
          ),
          child: Text(
            'Save',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildRequirementWarning() {
    if (controller.hasAnyNotificationEnabled) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.dangerSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.dangerSoft),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_outlined,
            color: AppColors.danger,
            size: 16,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'At least one notification type must be enabled to receive last-minute booking alerts.',
              style: TextStyle(
                color: AppColors.danger,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNotificationSummary() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.infoSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.infoSoft),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.info,
            size: 16,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              controller.getNotificationSummary(),
              style: TextStyle(
                color: AppColors.info,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildQuickActions() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: controller.enableAllNotifications,
                  child: Text(
                    'Enable All',
                    style: TextStyle(fontSize: 14),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: controller.disableAllNotifications,
                  child: Text(
                    'Disable All',
                    style: TextStyle(fontSize: 14),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildLastMinuteInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warningSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warningSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule,
                color: AppColors.warning,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Last-Minute Bookings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Get notified when spots become available within 2 hours of dinner time. These notifications are time-sensitive and require quick action.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.warning,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNotificationTypeDescription(String type, String description) {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            type,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHelpSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notification Types',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12),
        buildNotificationTypeDescription(
          'Push Notifications',
          'Instant alerts for urgent last-minute openings.',
        ),
        buildNotificationTypeDescription(
          'SMS',
          'Text messages for immediate notification even when app is closed.',
        ),
        buildNotificationTypeDescription(
          'Email',
          'Email alerts with booking details and quick action links.',
        ),
      ],
    );
  }

  Widget buildValidationStatus() {
    final validationError = controller.validateNotificationSettings();

    if (validationError == null) {
      return Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.successSoft,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.successSoft),
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: AppColors.success,
              size: 16,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Settings meet minimum requirements for last-minute bookings.',
                style: TextStyle(
                  color: AppColors.success,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.dangerSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.dangerSoft),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.danger,
            size: 16,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              validationError,
              style: TextStyle(
                color: AppColors.danger,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
