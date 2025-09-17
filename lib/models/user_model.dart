class AppUser {
  final String id;
  final String email;
  final String displayName;
  final bool isGoogleUser;
  final bool isVerified;
  final String? phoneNumber;
  final String? profilePictureUrl;

  final String? relationshipStatus;
  final String? childrenStatus; // Fixed typo: was "chidrenStatus"
  final String? industry;
  final String? country;

  // Preferences
  final List<String>? dinnerLanguages;
  final String? dinnerBudget;
  final bool hasDietaryRestrictions;
  final List<String>? dietaryOptions;

  // Notification preferences
  final bool eventPushNotifications;
  final bool eventSms;
  final bool eventEmail;
  final bool lastminutePushNotifications;
  final bool lastminuteSms;
  final bool lastminuteEmail;
  final bool marketingEmail;

  final bool isSubscribed;
  final DateTime? subscriptionStart;
  final DateTime? subscriptionEnd;
  final String? subscriptionType;
  final String? subscriptionPlanId;
  final bool isSubscriptionActive;
  final int daysUntilSubscriptionExpires;

  AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.isGoogleUser,
    required this.isVerified,
    this.relationshipStatus,
    this.childrenStatus, // Fixed typo
    this.industry,
    this.country,
    this.phoneNumber,
    this.profilePictureUrl,
    this.dinnerLanguages,
    this.dinnerBudget,
    this.hasDietaryRestrictions = false,
    this.dietaryOptions,
    this.eventPushNotifications = true,
    this.eventSms = true,
    this.eventEmail = true,
    this.lastminutePushNotifications = true,
    this.lastminuteSms = true,
    this.lastminuteEmail = true,
    this.marketingEmail = true,
    this.isSubscribed = false,
    this.subscriptionStart,
    this.subscriptionEnd,
    this.subscriptionType,
    this.subscriptionPlanId,
    this.isSubscriptionActive = false,
    this.daysUntilSubscriptionExpires = -1,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    String? rawUrl = json['profilePictureUrl'] ?? json['profile_picture_url'];

    // Parse dinner languages
    List<String>? dinnerLanguages;
    if (json['dinner_languages'] != null) {
      if (json['dinner_languages'] is List) {
        dinnerLanguages = List<String>.from(json['dinner_languages']);
      }
    }

    // Parse dietary options
    List<String>? dietaryOptions;
    if (json['dietary_options'] != null) {
      if (json['dietary_options'] is List) {
        dietaryOptions = List<String>.from(json['dietary_options']);
      }
    }

    // Parse subscription dates
    DateTime? subscriptionStart;
    if (json['subscription_start'] != null) {
      subscriptionStart = DateTime.parse(json['subscription_start']);
    }

    DateTime? subscriptionEnd;
    if (json['subscription_end'] != null) {
      subscriptionEnd = DateTime.parse(json['subscription_end']);
    }

    return AppUser(
      id: json['id'].toString(),
      email: json['email'],
      displayName:
          json['displayName'] ?? json['display_name'] ?? json['name'] ?? "",
      isGoogleUser: json['isGoogleUser'] ?? json['is_google_user'] ?? false,
      isVerified: json['isVerified'] ?? json['is_verified'] ?? false,
      phoneNumber: json['phoneNumber'] ?? json['phone_number'],
      profilePictureUrl:
          (rawUrl != null && rawUrl.trim().isNotEmpty) ? rawUrl : null,

      relationshipStatus: json['relationship_status'],
      childrenStatus: json['children_status'], // Fixed typo
      industry: json['industry'],
      country: json['country'],

      // Preferences
      dinnerLanguages: dinnerLanguages,
      dinnerBudget: json['dinner_budget'],
      hasDietaryRestrictions: json['has_dietary_restrictions'] ?? false,
      dietaryOptions: dietaryOptions,

      // Notification preferences
      eventPushNotifications: json['event_push_notifications'] ?? true,
      eventSms: json['event_sms'] ?? true,
      eventEmail: json['event_email'] ?? true,
      lastminutePushNotifications:
          json['lastminute_push_notifications'] ?? true,

      lastminuteSms: json['lastminute_sms'] ?? true,
      lastminuteEmail: json['lastminute_email'] ?? true,
      marketingEmail: json['marketing_email'] ?? true,

      isSubscribed: json['is_subscribed'] ?? false,
      subscriptionStart: subscriptionStart,
      subscriptionEnd: subscriptionEnd,
      subscriptionType: json['subscription_type'],
      subscriptionPlanId: json['subscription_plan_id'],
      isSubscriptionActive: json['is_subscription_active'] ?? false,
      daysUntilSubscriptionExpires:
          json['days_until_subscription_expires'] ?? -1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'isGoogleUser': isGoogleUser,
      'isVerified': isVerified,
      'phoneNumber': phoneNumber,
      'profilePictureUrl': profilePictureUrl,
      'relationship_status': relationshipStatus,
      'children_status': childrenStatus, // Fixed typo
      'industry': industry,
      'country': country,
      'dinner_languages': dinnerLanguages,
      'dinner_budget': dinnerBudget,
      'has_dietary_restrictions': hasDietaryRestrictions,
      'dietary_options': dietaryOptions,
      'event_push_notifications': eventPushNotifications,
      'event_sms': eventSms,
      'event_email': eventEmail,
      'lastminute_push_notifications': lastminutePushNotifications,
      'lastminute_sms': lastminuteSms,
      'lastminute_email': lastminuteEmail,
      'marketing_email': marketingEmail,
      'subscription_start': subscriptionStart?.toIso8601String(),
      'subscription_end': subscriptionEnd?.toIso8601String(),
      'subscription_type': subscriptionType,
      'subscription_plan_id': subscriptionPlanId,
      'is_subscription_active': isSubscriptionActive,
      'days_until_subscription_expires': daysUntilSubscriptionExpires,
    };
  }

  bool get hasActiveSubscription => isSubscriptionActive;

  bool get isSubscriptionExpiringSoon =>
      isSubscriptionActive &&
      daysUntilSubscriptionExpires > 0 &&
      daysUntilSubscriptionExpires <= 7;

  String get subscriptionStatusText {
    if (!isSubscribed) return "Not subscribed";
    if (!isSubscriptionActive) return "Subscription expired";
    if (daysUntilSubscriptionExpires == -1) return "Active (no expiration)";
    if (daysUntilSubscriptionExpires <= 0) return "Expired";
    return "Active (${daysUntilSubscriptionExpires} days left)";
  }
}
