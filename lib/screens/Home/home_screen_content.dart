// lib/screens/Home/home_screen_content.dart
import 'package:flutter/material.dart';
import './controllers/home_screen_controller.dart';
import './components/home_screen_components.dart';

class HomeScreenContent extends StatefulWidget {
  final VoidCallback? onSwitchToConnect;

  const HomeScreenContent({Key? key, this.onSwitchToConnect}) : super(key: key);

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> with RouteAware {
  late HomeScreenController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        HomeScreenController(onSwitchToConnect: widget.onSwitchToConnect);
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleRatingSuccess() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for rating your dinner experience!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _handleRatingError(String error) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit rating: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleSubmitRating() async {
    try {
      await _controller.submitRating();
      _handleRatingSuccess();
    } catch (e) {
      _handleRatingError(e.toString());
    }
  }

  Future<void> _handleBookDinner() async {
    await _controller.bookSelectedDinner(context);
  }

  Widget _buildHeader() {
    if (_controller.hasRatableBooking &&
        _controller.firstRatableBooking != null) {
      return HomeScreenComponents.buildRatingHeader(
        ratableBooking: _controller.firstRatableBooking!,
        currentRating: _controller.currentRating,
        onRatingChanged: _controller.setRating,
        isSubmittingRating: _controller.isSubmittingRating,
        onSubmitRating: _handleSubmitRating,
        onStartConnecting: _controller.startConnecting,
      );
    } else {
      return HomeScreenComponents.buildLocationHeader();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return HomeScreenComponents.buildBackground(
          child: Column(
            children: [
              // Header - dynamic based on rating state
              _buildHeader(),

              // Content - only show if not in rating mode or if there are available dinners
              HomeScreenComponents.buildDraggableContent(
                hasRatableBooking: _controller.hasRatableBooking,
                hasAvailableDinners: _controller.availableDinners.isNotEmpty,
                child: DraggableScrollableSheet(
                  initialChildSize: _controller.hasRatableBooking ? 0.4 : 0.7,
                  snap: true,
                  snapSizes: const [0.3],
                  builder: (context, scrollController) {
                    return HomeScreenComponents.buildMainContent(
                      headerTitle: _controller.headerTitle,
                      headerSubtitle: _controller.availableDinnersText,
                      isLoading: _controller.isLoading,
                      errorMessage: _controller.errorMessage,
                      availableDinners: _controller.availableDinners,
                      selectedDinner: _controller.selectedDinner,
                      onDinnerSelected: _controller.selectDinner,
                      canBook: _controller.canBookDinner,
                      bookButtonText: _controller.bookButtonText,
                      onBookPressed:
                          _controller.canBookDinner ? _handleBookDinner : null,
                      onRetry: _controller.refresh,
                      scrollController: scrollController,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
