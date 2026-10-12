// lib/screens/Profile/Settings/marketing_alert_components.dart
import 'package:flutter/material.dart';
import 'package:circle_app/theme/app_colors.dart';
import 'package:circle_app/screens/Profile/Settings/controllers/marketing_alert_controller.dart';

class MarketingAlertComponents {
  final MarketingAlertController controller;

  MarketingAlertComponents({required this.controller});

  Widget buildDescriptionText() {
    return Text(
      'Receive exclusive news about Circle, including the opening of registrations, our promotions and much more.',
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
            'Email',
            controller.email,
            controller.setEmail,
            isFirst: true,
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

  Widget buildMarketingStatus() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: controller.isEmailEnabled
            ? AppColors.successSoft
            : AppColors.grey50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: controller.isEmailEnabled
              ? AppColors.successSoft
              : AppColors.grey300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            controller.isEmailEnabled
                ? Icons.check_circle_outline
                : Icons.info_outline,
            color: controller.isEmailEnabled
                ? AppColors.success
                : AppColors.grey600,
            size: 16,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              controller.getMarketingStatus(),
              style: TextStyle(
                color: controller.isEmailEnabled
                    ? AppColors.success
                    : AppColors.grey700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPrivacyInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.infoSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.infoSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.privacy_tip_outlined,
                color: AppColors.info,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Privacy Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            controller.getPrivacyStatus(),
            style: TextStyle(
              fontSize: 14,
              color: AppColors.info,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMarketingBenefits() {
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
                Icons.campaign_outlined,
                color: AppColors.warning,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'What You\'ll Receive',
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
            '• Early access to new city launches\n• Exclusive dining events and experiences\n• Special promotions and discounts\n• Product updates and feature announcements',
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

  Widget buildUnsubscribeInfo() {
    if (controller.isEmailEnabled) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey300),
      ),
      child: Row(
        children: [
          Icon(
            Icons.unsubscribe,
            color: AppColors.grey600,
            size: 16,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'You can resubscribe to marketing emails at any time by enabling this setting.',
              style: TextStyle(
                color: AppColors.grey700,
                fontSize: 12,
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
                  onPressed: controller.optIntoMarketing,
                  child: Text(
                    'Opt In',
                    style: TextStyle(fontSize: 14),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    foregroundColor: AppColors.success,
                    side: BorderSide(color: AppColors.success),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: controller.optOutOfMarketing,
                  child: Text(
                    'Opt Out',
                    style: TextStyle(fontSize: 14),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    foregroundColor: AppColors.danger,
                    side: BorderSide(color: AppColors.danger),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildConsentInfo() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outlined,
            color: Colors.amber.shade600,
            size: 16,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Marketing communications are optional. You can change this setting anytime.',
              style: TextStyle(
                color: Colors.amber.shade700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
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
