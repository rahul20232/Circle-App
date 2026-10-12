import 'package:flutter/material.dart';
import 'package:circle_app/theme/app_colors.dart';

/// Selectable dinner card on the home screen.
/// Editorial layout: a calendar block (weekday / day / month) on the left,
/// time + neighbourhood in the middle, a radio on the right.
class NewCard extends StatelessWidget {
  final String date; // e.g. "Wednesday, October 14"
  final String time; // e.g. "7:30 PM"
  final bool isSelected;
  final VoidCallback onTap;
  final int? availableSpots;
  final String? location;

  const NewCard({
    Key? key,
    required this.date,
    required this.time,
    required this.isSelected,
    required this.onTap,
    this.availableSpots,
    this.location,
  }) : super(key: key);

  /// Splits "Wednesday, October 14" into ("WED", "14", "Oct"); falls back gracefully.
  (String, String, String) get _parts {
    final comma = date.split(',');
    final weekday = comma.first.trim();
    final rest = comma.length > 1 ? comma[1].trim().split(' ') : <String>[];
    final month = rest.isNotEmpty ? rest.first : '';
    final day = rest.length > 1 ? rest[1] : '';
    String short(String s, int n) => s.length > n ? s.substring(0, n) : s;
    return (short(weekday, 3).toUpperCase(), day, short(month, 3));
  }

  @override
  Widget build(BuildContext context) {
    final (weekday, day, month) = _parts;
    final fewLeft = availableSpots != null && availableSpots! > 0 && availableSpots! <= 2;
    final neighbourhood = location?.split(',').first.trim();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.surface : AppColors.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.ink : AppColors.line,
          width: isSelected ? 1.6 : 1,
        ),
        // Solid offset "lip" under the selected card for the app's 3D look.
        boxShadow: isSelected
            ? const [BoxShadow(color: AppColors.ink, blurRadius: 0, offset: Offset(0, 6))]
            : const [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Calendar block
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 64,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accent : AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(weekday,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: isSelected ? AppColors.surface.withOpacity(0.85) : AppColors.accentDeep,
                          )),
                      const SizedBox(height: 2),
                      Text(day,
                          style: TextStyle(
                            fontFamily: AppFonts.serif,
                            fontSize: 30,
                            height: 1.05,
                            color: isSelected ? AppColors.surface : AppColors.ink,
                          )),
                      Text(month,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? AppColors.surface.withOpacity(0.85) : AppColors.inkMuted,
                          )),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(time,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.3, color: AppColors.ink)),
                      if (neighbourhood != null) ...[
                        const SizedBox(height: 6),
                        Row(children: [
                          const Icon(Icons.place_outlined, size: 15, color: AppColors.inkMuted),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(neighbourhood,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14, color: AppColors.inkMuted)),
                          ),
                        ]),
                      ],
                      if (availableSpots != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: fewLeft ? AppColors.accentSoft : AppColors.grey100,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            availableSpots == 1 ? '1 seat left' : '$availableSpots seats left',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: fewLeft ? AppColors.accentDeep : AppColors.inkMuted,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Radio
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.ink : Colors.transparent,
                    border: Border.all(color: isSelected ? AppColors.ink : AppColors.lineStrong, width: 1.6),
                  ),
                  child: isSelected ? const Icon(Icons.check_rounded, size: 15, color: AppColors.surface) : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
