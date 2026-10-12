import 'package:flutter/material.dart';
import 'package:circle_app/theme/app_colors.dart';
import 'package:circle_app/components/Cards/OnboardingCard.dart';

class MiddleScreen extends StatefulWidget {
  final VoidCallback? onNext;
  final VoidCallback? onBack;

  const MiddleScreen({
    Key? key,
    this.onNext,
    this.onBack,
  }) : super(key: key);

  @override
  _MiddleScreenState createState() => _MiddleScreenState();
}

class _MiddleScreenState extends State<MiddleScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<Offset>> _slideAnimations;
  late Animation<double> _cardFadeAnimation;
  late Animation<double> _imageOpacityAnimation;

  // Unsplash image URLs for random people/group photos
  final List<String> _imageUrls = [
    'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=400&h=600&fit=crop&crop=faces',
    'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400&h=550&fit=crop&crop=faces',
    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=380&h=520&fit=crop&crop=faces',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=360&h=480&fit=crop&crop=faces',
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(
          milliseconds: 1000), // Increased duration for smoother animation
      vsync: this,
    );

    // Card fade animation (starts after images are positioned)
    _cardFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.1, 0.3,
          curve: Curves.easeIn), // Starts after images begin moving
    ));

    // Image opacity animation (prevents flash during positioning)
    _imageOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 0.15, curve: Curves.easeIn), // Quick fade in
    ));

    // Define slide animations for each image with staggered timing
    _slideAnimations = [
      // Top left - slides from left
      Tween<Offset>(
        begin:
            Offset(-1.5, 0.0), // Reduced from -2.0 for less aggressive entrance
        end: Offset(0.0, 0.0),
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.1, 0.8, curve: Curves.easeOutCubic), // Smoother curve
      )),

      // Top right - slides from right
      Tween<Offset>(
        begin: Offset(1.5, 0.0), // Reduced from 2.0
        end: Offset(0.0, 0.0),
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.15, 0.85, curve: Curves.easeOutCubic),
      )),

      // Bottom left - slides from left
      Tween<Offset>(
        begin: Offset(-1.5, 0.0), // Reduced from -2.0
        end: Offset(0.0, 0.0),
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.2, 0.9, curve: Curves.easeOutCubic),
      )),

      // Bottom right - slides from right
      Tween<Offset>(
        begin: Offset(1.5, 0.0), // Reduced from 2.0
        end: Offset(0.0, 0.0),
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.25, 0.95, curve: Curves.easeOutCubic),
      )),
    ];

    // Start animation after page transition completes to prevent overlap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Add delay to wait for page transition to complete
      Future.delayed(Duration(milliseconds: 300), () {
        if (mounted) {
          _animationController.forward();
        }
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.ink, size: 28),
          onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Animated photo collage background
            _buildAnimatedPhotoCollage(),

            // Center card with fade animation
            Center(
              child: FadeTransition(
                opacity: _cardFadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: StatsOnboardingCard(),
                ),
              ),
            ),

            // Bottom Next button
            Positioned(
              left: 32,
              right: 32,
              bottom: 40,
              child: _buildNextButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedPhotoCollage() {
    return Stack(
      children: [
        // Top left photo
        _buildAnimatedPhoto(0, 20, 20, 180, 250, 15),

        // Top right photo
        _buildAnimatedPhoto(1, 60, null, 160, 220, -10, right: 20),

        // Bottom left photo
        _buildAnimatedPhoto(2, null, 30, 170, 240, 8, bottom: 100),

        // Bottom right photo
        _buildAnimatedPhoto(3, null, null, 150, 200, -12,
            bottom: 80, right: 30),
      ],
    );
  }

  Widget _buildAnimatedPhoto(
    int index,
    double? top,
    double? left,
    double width,
    double height,
    double rotation, {
    double? bottom,
    double? right,
  }) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Positioned(
          top: top,
          left: left,
          bottom: bottom,
          right: right,
          child: FadeTransition(
            opacity: _imageOpacityAnimation, // Add opacity animation
            child: SlideTransition(
              position: _slideAnimations[index],
              child: Transform.rotate(
                angle: rotation * 3.14159 / 180,
                child: Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.ink.withOpacity(0.15),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _imageUrls[index],
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: AppColors.grey200,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                              color: AppColors.grey400,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.grey200,
                          child: Center(
                            child: Icon(
                              Icons.people,
                              size: 40,
                              color: AppColors.grey400,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: widget.onNext,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        child: Text(
          'Next',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
