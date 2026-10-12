// lib/components/home_screen_components.dart
import 'package:flutter/material.dart';
import 'package:circle_app/theme/app_colors.dart';
import '../../../models/dinner_model.dart';
import '../../../models/rating_model.dart';
import '../../../components/star_rating.dart';
import '../../../components/Cards/NewCard.dart';

class HomeScreenComponents {
  // Background Container
  static Widget buildBackground({required Widget child}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.accent, // Purple
            AppColors.accentDeep, // Lighter purple
          ],
        ),
      ),
      child: SafeArea(child: child),
    );
  }

  // Rating Header
  static Widget buildRatingHeader({
    required Booking ratableBooking,
    required int currentRating,
    required Function(int) onRatingChanged,
    required bool isSubmittingRating,
    required VoidCallback onSubmitRating,
    required VoidCallback onStartConnecting,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 4),
          // Rate your dinner title
          const Text(
            'Rate your dinner',
            style: TextStyle(
              color: AppColors.surface,
              fontSize: 24,
              fontFamily: AppFonts.serif, fontWeight: FontWeight.w400,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),
          // Dinner details
          Text(
            ratableBooking.dinnerTitle,
            style: TextStyle(
              color: AppColors.surface.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),

          // Interactive Star Rating
          InteractiveStarRating(
            initialRating: currentRating,
            size: 35,
            activeColor: AppColors.surface,
            inactiveColor: AppColors.surface.withOpacity(0.3),
            onRatingChanged: onRatingChanged,
          ),

          if (currentRating > 0) ...[
            const SizedBox(height: 16),
            // Submit Rating Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSubmittingRating ? null : onSubmitRating,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 2,
                ),
                child: isSubmittingRating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.accent,
                          ),
                        ),
                      )
                    : const Text(
                        'Submit Rating',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],

          const SizedBox(height: 16),
          // Start Connecting Button (secondary)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onStartConnecting,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.surface, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Connect with Other Diners',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.surface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Location Header
  static Widget buildLocationHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Location Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.surface.withOpacity(0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on, color: AppColors.surface, size: 16),
                SizedBox(width: 8),
                Text(
                  'Bangalore',
                  style: TextStyle(
                    color: AppColors.surface,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Location Title
          const Text(
            'CENTRAL BANGALORE',
            style: TextStyle(
              color: AppColors.surface,
              fontSize: 24,
              fontFamily: AppFonts.serif, fontWeight: FontWeight.w400,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),
          // Change Location
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Change location',
                style: TextStyle(
                  color: AppColors.surface.withOpacity(0.8),
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.refresh,
                color: AppColors.surface.withOpacity(0.8),
                size: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Loading State
  static Widget buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(50),
        child: CircularProgressIndicator(
          color: AppColors.accent,
        ),
      ),
    );
  }

  // Error State
  static Widget buildErrorState({
    required String errorMessage,
    required VoidCallback onRetry,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.dangerSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dangerSoft),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: AppColors.danger, size: 40),
          const SizedBox(height: 10),
          Text(
            errorMessage,
            style: TextStyle(
              color: AppColors.danger,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: AppColors.surface,
            ),
          ),
        ],
      ),
    );
  }

  // Empty State
  static Widget buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.restaurant_menu_outlined,
            size: 80,
            color: AppColors.grey400,
          ),
          const SizedBox(height: 20),
          Text(
            'No dinners available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Check back soon for new dining opportunities!',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.grey500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Dinner List
  static Widget buildDinnerList({
    required List<Dinner> dinners,
    required Dinner? selectedDinner,
    required Function(Dinner) onDinnerSelected,
  }) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dinners.length,
      itemBuilder: (context, index) {
        final dinner = dinners[index];
        final isSelected = selectedDinner?.id == dinner.id;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: NewCard(
            date: dinner.formattedDate,
            time: dinner.formattedTime,
            isSelected: isSelected,
            availableSpots: dinner.availableSpots,
            location: dinner.location,
            onTap: () => onDinnerSelected(dinner),
          ),
        );
      },
    );
  }

  // Book Button
  static Widget buildBookButton({
    required bool canBook,
    required String buttonText,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 0, bottom: 20),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          // The screen's one key action gets the accent.
          backgroundColor: canBook ? AppColors.accent : AppColors.grey300,
          foregroundColor: AppColors.surface,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: Text(
          buttonText,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }

  // Content Section Header
  static Widget buildContentHeader({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 28,
            fontFamily: AppFonts.serif, fontWeight: FontWeight.w400,
            color: AppColors.grey800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.grey600,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // Content Container
  static Widget buildContentContainer({
    required Widget child,
    required ScrollController scrollController,
    Widget? stickyFooter,
  }) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
              child: SingleChildScrollView(
                controller: scrollController,
                child: child,
              ),
            ),
          ),
          if (stickyFooter != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 8, 30, 20),
              child: stickyFooter,
            ),
        ],
      ),
    );
  }

  // Main Content Layout
  static Widget buildMainContent({
    required String headerTitle,
    required String headerSubtitle,
    required bool isLoading,
    required String? errorMessage,
    required List<Dinner> availableDinners,
    required Dinner? selectedDinner,
    required Function(Dinner) onDinnerSelected,
    required bool canBook,
    required String bookButtonText,
    required VoidCallback? onBookPressed,
    required VoidCallback onRetry,
    required ScrollController scrollController,
  }) {
    return buildContentContainer(
      scrollController: scrollController,
      stickyFooter: (!isLoading && errorMessage == null && availableDinners.isNotEmpty)
          ? buildBookButton(
              canBook: canBook,
              buttonText: bookButtonText,
              onPressed: onBookPressed,
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildContentHeader(
            title: headerTitle,
            subtitle: headerSubtitle,
          ),

          // Content based on state
          if (isLoading)
            buildLoadingState()
          else if (errorMessage != null)
            buildErrorState(
              errorMessage: errorMessage,
              onRetry: onRetry,
            )
          else if (availableDinners.isNotEmpty)
            buildDinnerList(
              dinners: availableDinners,
              selectedDinner: selectedDinner,
              onDinnerSelected: onDinnerSelected,
            )
          else
            buildEmptyState(),
        ],
      ),
    );
  }

  // Draggable Content Sheet
  static Widget buildDraggableContent({
    required bool hasRatableBooking,
    required bool hasAvailableDinners,
    required Widget child,
  }) {
    if (!hasRatableBooking || hasAvailableDinners) {
      return Expanded(
        child: DraggableScrollableSheet(
          initialChildSize: hasRatableBooking ? 0.5 : 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          snap: true,
          snapSizes: const [0.85, 0.95],
          builder: (context, scrollController) {
            return child;
          },
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
