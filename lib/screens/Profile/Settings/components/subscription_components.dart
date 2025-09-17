// lib/screens/Profile/Settings/subscription_components.dart
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:timeleft_clone/screens/Profile/Settings/controllers/subscription_controller.dart';
import '../../../../components/Cards/PricingCard.dart';

class SubscriptionComponents {
  final SubscriptionController controller;

  SubscriptionComponents({required this.controller});

  Widget buildImageCarousel(
      BuildContext context, bool isSmallScreen, double screenHeight) {
    return SizedBox(
      height: isSmallScreen ? screenHeight * 0.35 : screenHeight * 0.40,
      child: Stack(
        children: [
          buildCarouselSlider(),
          buildTextOverlay(context, isSmallScreen, screenHeight),
          buildDotsIndicator(),
          buildCloseButton(context),
        ],
      ),
    );
  }

  Widget buildCarouselSlider() {
    return Container(
      color: Colors.black.withOpacity(0.7),
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
                color: Colors.black.withOpacity(0.4),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildTextOverlay(
      BuildContext context, bool isSmallScreen, double screenHeight) {
    return Positioned(
      top: isSmallScreen ? screenHeight * 0.12 : screenHeight * 0.15,
      left: 16,
      right: 16,
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'UNLIMITED ACCESS',
              style: TextStyle(
                fontFamily: 'DMSerifDisplay-Regular',
                fontSize: isSmallScreen ? 24 : 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),
          SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'All dinners, every Wednesday',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 18,
                color: Colors.white,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDotsIndicator() {
    return Positioned(
      bottom: 20,
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
                  ? Colors.white
                  : Colors.white.withOpacity(0.5),
              border: controller.currentSlide == index
                  ? Border.all(color: Colors.grey, width: 1)
                  : null,
            ),
          );
        }),
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
          color: Colors.white,
        ),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget buildContentSection(BuildContext context, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(height: isSmallScreen ? 40 : 75),
          buildPricingPlans(),
          SizedBox(height: isSmallScreen ? 40 : 80),
          buildTermsText(isSmallScreen),
          SizedBox(height: isSmallScreen ? 20 : 40),
          buildSubscribeButton(context, isSmallScreen),
          SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget buildPricingPlans() {
    return Row(
      children: List.generate(controller.planData.length, (index) {
        final plan = controller.planData[index];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index < controller.planData.length - 1 ? 16 : 0,
            ),
            child: PriceCard(
              title: plan['title'],
              duration: plan['duration'],
              price: plan['monthlyPrice'],
              isSelected: controller.isPlanSelected(index),
              onTap: () => controller.selectPlan(index),
            ),
          ),
        );
      }),
    );
  }

  Widget buildTermsText(bool isSmallScreen) {
    return Text(
      controller.termsText,
      style: TextStyle(
        fontSize: isSmallScreen ? 11 : 12,
        color: Colors.black87,
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget buildSubscribeButton(BuildContext context, bool isSmallScreen) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => controller.showPaymentModal(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            vertical: isSmallScreen ? 12 : 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 2,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            controller.selectedPlanButtonText,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPlanBenefits() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What\'s Included',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12),
          ...[
            'Unlimited dinner reservations',
            'Access to all Wednesday events',
            'Priority booking for special events',
            'Member-only community features',
            'Cancel anytime',
          ].map((benefit) => Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        benefit,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget buildPlanComparison() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          Text(
            'Plan Comparison',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade800,
            ),
          ),
          SizedBox(height: 12),
          Table(
            columnWidths: {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1),
            },
            children: [
              TableRow(
                children: [
                  Text(''),
                  Text('1 Month',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  Text('3 Months',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  Text('6 Months',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
              TableRow(
                children: [
                  Text('Monthly Cost', style: TextStyle(fontSize: 12)),
                  Text('₹1,099',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12)),
                  Text('₹866',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12)),
                  Text('₹583',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12)),
                ],
              ),
              TableRow(
                children: [
                  Text('Total Savings', style: TextStyle(fontSize: 12)),
                  Text('-',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12)),
                  Text('21%',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.green)),
                  Text('47%',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.green)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSelectedPlanSummary() {
    final plan = controller.selectedPlanData;
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected Plan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                plan['duration'],
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              Text(
                plan['totalPrice'],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          if (plan['savePercentage'] != null) ...[
            SizedBox(height: 4),
            Text(
              'Save ${plan['savePercentage']}%',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildRecommendationBadge(int planIndex) {
    if (planIndex != controller.recommendedPlanIndex) {
      return SizedBox.shrink();
    }

    return Positioned(
      top: -5,
      right: 8,
      left: 8,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'MOST POPULAR',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
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
            'Loading subscription options...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
