// lib/components/booking_success_components.dart
import 'package:flutter/material.dart';
import 'package:circle_app/theme/app_colors.dart';
import '../../../models/dinner_model.dart';

/// "Booking confirmed" screen, styled as a dinner ticket.
class BookingSuccessComponents {
  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  static const _weekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  // Small confirmation badge + label
  static Widget buildSuccessIcon() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(color: AppColors.successSoft, shape: BoxShape.circle),
          child: const Icon(Icons.check_rounded, size: 18, color: AppColors.success),
        ),
        const SizedBox(width: 10),
        const Text(
          'BOOKING CONFIRMED',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.6, color: AppColors.success),
        ),
      ],
    );
  }

  static Widget buildSuccessTitle() {
    return RichText(
      textAlign: TextAlign.center,
      text: const TextSpan(
        style: TextStyle(fontFamily: AppFonts.serif, fontSize: 40, height: 1.05, color: AppColors.ink, letterSpacing: -0.5),
        children: [
          TextSpan(text: "You're at\nthe table"),
          TextSpan(text: '.', style: TextStyle(color: AppColors.accent)),
        ],
      ),
    );
  }

  static Widget buildSuccessMessage(String message) {
    return Text(
      message,
      style: const TextStyle(fontSize: 16, color: AppColors.inkMuted, height: 1.5),
      textAlign: TextAlign.center,
    );
  }

  /// Ticket: calendar block + details, a perforated divider, and a footer strip.
  /// Sits on the app's solid ink "lip" for the 3D card look.
  static Widget buildDinnerDetailsCard(Dinner dinner) {
    final d = dinner.date.toLocal();
    final neighbourhood = dinner.location.split(',').first.trim();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.ink, width: 1.6),
        boxShadow: const [BoxShadow(color: AppColors.ink, blurRadius: 0, offset: Offset(0, 6))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: Row(
              children: [
                Container(
                  width: 68,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(14)),
                  child: Column(children: [
                    Text(_weekdays[d.weekday - 1],
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: AppColors.surface.withOpacity(0.85))),
                    const SizedBox(height: 2),
                    Text('${d.day}', style: const TextStyle(fontFamily: AppFonts.serif, fontSize: 32, height: 1.05, color: AppColors.surface)),
                    Text(_months[d.month - 1], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.surface.withOpacity(0.85))),
                  ]),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dinner.title,
                          style: const TextStyle(fontFamily: AppFonts.serif, fontSize: 22, height: 1.15, color: AppColors.ink)),
                      const SizedBox(height: 6),
                      Text(dinner.formattedTime,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.inkSoft)),
                      const SizedBox(height: 4),
                      Row(children: [
                        const Icon(Icons.place_outlined, size: 15, color: AppColors.inkMuted),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(neighbourhood,
                              overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, color: AppColors.inkMuted)),
                        ),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _perforation(),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
            child: Row(
              children: [
                _ticketFact('Table', 'Up to ${dinner.maxAttendees}'),
                _ticketFact('Venue', 'Revealed on the day'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _ticketFact(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: AppColors.inkFaint)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink)),
        ],
      ),
    );
  }

  /// Dashed line with semicircle notches at each edge, like a torn ticket.
  static Widget _perforation() {
    return SizedBox(
      height: 20,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: LayoutBuilder(builder: (context, c) {
              const dash = 6.0, gap = 5.0;
              final n = (c.maxWidth / (dash + gap)).floor();
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(n, (_) => Container(width: dash, height: 1.4, color: AppColors.lineStrong)),
              );
            }),
          ),
          for (final left in [true, false])
            Positioned(
              left: left ? -11 : null,
              right: left ? null : -11,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.ink, width: 1.6),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Kept for API compatibility with other callers.
  static Widget buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Icon(icon, size: 18, color: AppColors.inkMuted),
        const SizedBox(width: 10),
        Text('$label  ', style: const TextStyle(fontSize: 14, color: AppColors.inkMuted)),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink))),
      ]),
    );
  }

  static Widget buildPrimaryButton({required String text, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(onPressed: onPressed, child: Text(text)),
    );
  }

  static Widget buildSecondaryButton({required String text, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(foregroundColor: AppColors.inkSoft, minimumSize: const Size(64, 48)),
        child: Text(text),
      ),
    );
  }

  static Widget buildActionButtons({required VoidCallback onViewBookings, required VoidCallback onBackToHome}) {
    return Column(
      children: [
        buildPrimaryButton(text: 'View my bookings', onPressed: onViewBookings),
        const SizedBox(height: 6),
        buildSecondaryButton(text: 'Back to home', onPressed: onBackToHome),
      ],
    );
  }

  /// Gentle entrance: each block fades and rises in turn.
  static Widget _reveal(int index, Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + index * 120),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, (1 - t) * 18), child: child),
      ),
      child: child,
    );
  }

  static Widget buildMainContent({
    required Dinner dinner,
    required String successMessage,
    required VoidCallback onViewBookings,
    required VoidCallback onBackToHome,
  }) {
    return Column(
      children: [
        const SizedBox(height: 28),
        _reveal(0, buildSuccessIcon()),
        const SizedBox(height: 20),
        _reveal(1, buildSuccessTitle()),
        const SizedBox(height: 14),
        _reveal(2, buildSuccessMessage(successMessage)),
        const SizedBox(height: 32),
        _reveal(3, buildDinnerDetailsCard(dinner)),
        const Spacer(),
        const SizedBox(height: 32),
        _reveal(4, buildActionButtons(onViewBookings: onViewBookings, onBackToHome: onBackToHome)),
        const SizedBox(height: 8),
      ],
    );
  }

  static Widget buildScrollableContainer({required BuildContext context, required Widget child}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.vertical - 28,
        ),
        child: IntrinsicHeight(child: child),
      ),
    );
  }
}
