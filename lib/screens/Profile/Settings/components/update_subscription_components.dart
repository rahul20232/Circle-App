// lib/screens/Profile/Settings/update_subscription_components.dart
import 'package:carousel_slider/carousel_slider.dart';
import 'package:circle_app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:circle_app/screens/Profile/Settings/controllers/update_subscription_controller.dart';
import '../../../../components/Cards/PricingCard.dart';

class UpdateSubscriptionComponents {
  final UpdateSubscriptionController controller;

  UpdateSubscriptionComponents({required this.controller});

  Widget buildMainContent(BuildContext context) {
    return Column(
      children: [
        buildImageCarousel(context),
        buildPricingSection(context),
        buildUpdateButton(context),
        buildTermsText(context),
        SizedBox(height: 16),
      ],
    );
  }

  Widget buildImageCarousel(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.40,
      child: Container(
        color: AppColors.ink.withOpacity(0.7),
        child: CarouselSlider(
          options: CarouselOptions(
            height: double.infinity,
            viewportFraction: 1.0,
            autoPlayInterval: Duration(seconds: 5),
            enlargeCenterPage: false,
            enableInfiniteScroll: false,
            onPageChanged: (index, reason) {
              controller.setCurrentSlide(index);
            },
          ),
          items: controller.carouselImages.map((imageUrl) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      color: AppColors.ink.withOpacity(0.4),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget buildPricingSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 75.0, left: 16.0, right: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(controller.planData.length, (index) {
          final plan = controller.planData[index];
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index < controller.planData.length - 1 ? 16 : 0,
              ),
              child: Stack(
                children: [
                  PriceCard(
                    title: plan['title'],
                    duration: plan['duration'],
                    price: plan['monthlyPrice'],
                    isSelected: controller.isPlanSelected(index),
                    onTap: () => controller.selectPlan(index),
                  ),
                  // if (controller.isCurrentUserPlan(index))
                  //   buildCurrentPlanBadge(),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // Widget buildCurrentPlanBadge() {
  //   return Positioned(
  //     top: -5,
  //     right: 8,
  //     left: 8,
  //     child: Container(
  //       padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //       decoration: BoxDecoration(
  //         color: AppColors.success,
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //       child: Text(
  //         'CURRENT PLAN',
  //         style: TextStyle(
  //           color: AppColors.surface,
  //           fontSize: 10,
  //           fontWeight: FontWeight.w600,
  //         ),
  //         textAlign: TextAlign.center,
  //       ),
  //     ),
  //   );
  // }

  Widget buildUpdateButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0, left: 16.0, right: 16.0),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: controller.isButtonEnabled
              ? () => controller.showPaymentModal(context)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: controller.isButtonEnabled
                ? Color(0xFF2D3748)
                : AppColors.grey400,
            foregroundColor: AppColors.surface,
            elevation: controller.isButtonEnabled ? 2 : 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            controller.buttonText,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTermsText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0),
      child: Text(
        controller.termsText,
        style: TextStyle(
          fontSize: 12,
          color: Colors.black87,
          height: 1.4,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget buildDotsIndicator(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.37,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(controller.carouselImages.length, (index) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 4),
            width: controller.currentSlide == index ? 12 : 8,
            height: controller.currentSlide == index ? 12 : 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: controller.currentSlide == index
                  ? AppColors.surface
                  : AppColors.surface.withOpacity(0.5),
              border: controller.currentSlide == index
                  ? Border.all(color: AppColors.grey500, width: 1)
                  : null,
            ),
          );
        }),
      ),
    );
  }

  Widget buildTextOverlay(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.18,
      right: MediaQuery.of(context).size.width * 0.15,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'UNLIMITED ACCESS',
            style: TextStyle(
              fontFamily: 'DMSerifDisplay-Regular',
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.surface,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'All dinners, every Wednesday',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.surface,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCloseButton(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      right: 16,
      child: IconButton(
        icon: Icon(
          Icons.close,
          size: 30,
          color: AppColors.surface,
        ),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget buildCurrentSubscriptionInfo() {
    if (!controller.hasActiveSubscription) {
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.infoSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.infoSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Subscription',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.info,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '${controller.currentPlanTitle} - ${controller.currentPlanDuration}',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.info,
            ),
          ),
        ],
      ),
    );
  }

  // Widget buildSubscriptionActionInfo() {
  //   if (controller.isSamePlan) {
  //     return Container(
  //       padding: EdgeInsets.all(12),
  //       margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //       decoration: BoxDecoration(
  //         color: AppColors.grey100,
  //         borderRadius: BorderRadius.circular(8),
  //         border: Border.all(color: AppColors.grey300),
  //       ),
  //       child: Row(
  //         children: [
  //           Icon(Icons.info_outline, color: AppColors.grey600, size: 16),
  //           SizedBox(width: 8),
  //           Expanded(
  //             child: Text(
  //               'This is your current plan',
  //               style: TextStyle(
  //                 color: AppColors.grey700,
  //                 fontSize: 12,
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //   }

  //   String actionText = '';
  //   Color actionColor = AppColors.info;
  //   IconData actionIcon = Icons.update;

  //   switch (controller.subscriptionActionType) {
  //     case 'upgrade':
  //       actionText = 'Upgrade to a longer plan and save more!';
  //       actionColor = AppColors.success;
  //       actionIcon = Icons.trending_up;
  //       break;
  //     case 'downgrade':
  //       actionText = 'Switch to a shorter plan';
  //       actionColor = AppColors.warning;
  //       actionIcon = Icons.trending_down;
  //       break;
  //     case 'subscribe':
  //       actionText = 'Start your subscription journey';
  //       actionColor = AppColors.accent;
  //       actionIcon = Icons.star;
  //       break;
  //   }

  //   if (actionText.isNotEmpty) {
  //     return Container(
  //       padding: EdgeInsets.all(12),
  //       margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //       decoration: BoxDecoration(
  //         color: actionColor.withOpacity(0.1),
  //         borderRadius: BorderRadius.circular(8),
  //         border: Border.all(color: actionColor.withOpacity(0.3)),
  //       ),
  //       child: Row(
  //         children: [
  //           Icon(actionIcon, color: actionColor, size: 16),
  //           SizedBox(width: 8),
  //           Expanded(
  //             child: Text(
  //               actionText,
  //               style: TextStyle(
  //                 color: actionColor.shade700,
  //                 fontSize: 12,
  //                 fontWeight: FontWeight.w500,
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //   }

  //   return SizedBox.shrink();
  // }

  Widget buildSubscriptionBenefits() {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subscription Benefits',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          SizedBox(height: 12),
          ...[
            'Unlimited dinner access',
            'Priority booking',
            'Exclusive events',
            'Cancel anytime',
          ].map((benefit) => Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: AppColors.success, size: 16),
                    SizedBox(width: 8),
                    Text(
                      benefit,
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading your subscription...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }
}
