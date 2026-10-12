// lib/screens/Profile/Settings/event_alert_components.dart
import 'package:flutter/material.dart';
import 'package:circle_app/theme/app_colors.dart';
import 'package:circle_app/screens/Profile/Settings/controllers/event_alert_controller.dart';

class EventAlertComponents {
  final EventAlertController controller;

  EventAlertComponents({required this.controller});

  Widget buildDescriptionText() {
    return Text(
      'Get notified about upcoming events, new dinner opportunities, and important updates.',
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

  Widget buildNotificationWarning() {
    if (controller.hasAnyNotificationEnabled) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warningSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.warningSoft),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_outlined,
            color: AppColors.warning,
            size: 16,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'You won\'t receive any event notifications with all options disabled.',
              style: TextStyle(
                color: AppColors.warning,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNotificationTypeInfo(String type, String description) {
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
        buildNotificationTypeInfo(
          'Push Notifications',
          'Instant alerts on your device when new events are available.',
        ),
        buildNotificationTypeInfo(
          'SMS',
          'Text messages for important updates and reminders.',
        ),
        buildNotificationTypeInfo(
          'Email',
          'Detailed information about events and opportunities.',
        ),
      ],
    );
  }

  Widget buildSettingsCard({
    required String title,
    required Widget child,
    EdgeInsets? padding,
  }) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
