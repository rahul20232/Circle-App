// lib/screens/Profile/Settings/settings_components.dart
import 'package:flutter/material.dart';
import 'package:circle_app/theme/app_colors.dart';
import 'package:circle_app/screens/Profile/Settings/controllers/settings_controller.dart';

class SettingsComponents {
  final SettingsController controller;

  SettingsComponents({required this.controller});

  Widget buildNotificationsSection(BuildContext context) {
    return Column(
      children: [
        buildSectionTitle("Notifications"),
        buildSettingsCard([
          ...controller.notificationItems.map((item) => buildSettingsItem(
              context,
              item,
              () => controller.navigateToSettingsItem(context, item))),
        ]),
      ],
    );
  }

  Widget buildSubscriptionSection(BuildContext context) {
    return Column(
      children: [
        buildSectionTitle("Subscription"),
        buildSettingsCard([
          buildSubscriptionItem(context),
        ]),
      ],
    );
  }

  Widget buildLegalSection(BuildContext context) {
    return Column(
      children: [
        buildSectionTitle("Legal"),
        buildSettingsCard([
          ...controller.legalItems.map((item) => buildSettingsItem(context,
              item, () => controller.navigateToSettingsItem(context, item))),
        ]),
      ],
    );
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
      ),
    );
  }

  Widget buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey400, width: 1),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget buildSettingsItem(
      BuildContext context, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, color: AppColors.ink),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.ink),
          ],
        ),
      ),
    );
  }

  Widget buildSubscriptionItem(BuildContext context) {
    return InkWell(
      onTap: controller.isLoading
          ? null
          : () => controller.navigateToSubscription(context),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Subscribe to Circle",
              style: TextStyle(fontSize: 16, color: AppColors.ink),
            ),
            controller.isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.ink),
                    ),
                  )
                : Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.ink),
          ],
        ),
      ),
    );
  }

  Widget buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed:
            controller.isLoading ? null : () => controller.logout(context),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: AppColors.ink, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: controller.isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.ink),
                ),
              )
            : Text(
                "Log out",
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget buildDeleteAccountButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => controller.navigateToDeleteAccount(context),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 14),
          backgroundColor: AppColors.surface,
          side: BorderSide(color: AppColors.danger, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          "Delete my account",
          style: TextStyle(
            fontSize: 16,
            color: AppColors.danger,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget buildAppVersion() {
    return Center(
      child: Text(
        controller.getFormattedVersion(),
        style: TextStyle(
          fontSize: 14,
          color: AppColors.grey700,
        ),
      ),
    );
  }

  Widget buildUserInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey300),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.grey300,
            child: Icon(Icons.person, color: AppColors.grey600),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.currentUser,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  'View Profile',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.ink),
        ],
      ),
    );
  }

  Widget buildLoadingOverlay() {
    if (!controller.isLoading) return SizedBox.shrink();

    return Container(
      color: AppColors.ink.withOpacity(0.3),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.surface),
        ),
      ),
    );
  }

  Widget buildSettingsSectionWithDividers(List<Widget> items) {
    if (items.isEmpty) return SizedBox.shrink();

    final itemsWithDividers = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      itemsWithDividers.add(items[i]);
      if (i < items.length - 1) {
        itemsWithDividers.add(
          Divider(
            height: 1,
            color: AppColors.grey300,
            indent: 16,
            endIndent: 16,
          ),
        );
      }
    }

    return buildSettingsCard(itemsWithDividers);
  }

  Widget buildSettingsItemWithIcon(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor ?? AppColors.grey600,
              size: 20,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 16, color: AppColors.ink),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.ink),
          ],
        ),
      ),
    );
  }

  Widget buildToggleSettingsItem(
    String title,
    bool value,
    Function(bool) onChanged, {
    String? subtitle,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16, color: AppColors.ink),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.grey600,
                    ),
                  ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.surface,
            activeTrackColor: AppColors.success,
            inactiveThumbColor: AppColors.surface,
            inactiveTrackColor: AppColors.grey400,
          ),
        ],
      ),
    );
  }

  Widget buildBadgeSettingsItem(
    BuildContext context,
    String title,
    String badge,
    VoidCallback onTap, {
    Color badgeColor = AppColors.danger,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 16, color: AppColors.ink),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: AppColors.surface,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.ink),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
