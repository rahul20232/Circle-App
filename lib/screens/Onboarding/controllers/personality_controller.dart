// lib/screens/Onboarding/controllers/personality_controller.dart
import 'package:flutter/material.dart';
import 'package:circle_app/services/onboarding_state_service.dart';

class PersonalityController {
  final VoidCallback onStateChanged;

  // Store all personality responses
  final Map<String, String> _personalityResponses = {};

  // Current question index
  int _currentQuestionIndex = 0;

  // Animation state - separate for forward and backward navigation
  bool _isForwardAnimating = false;
  bool _isBackwardAnimating = false;

  // Mixed questions with different types
  final List<Map<String, dynamic>> _questions = [
    // Multiple choice questions
    {
      'type': 'multiple_choice',
      'question': 'Are your opinions usually guided by:',
      'options': ['Logic and facts', 'Emotions and feelings']
    },
    {
      'type': 'multiple_choice',
      'question': 'Do you consider yourself more of a...',
      'options': ['Smart person', 'Funny person']
    },
    // More multiple choice
    {
      'type': 'multiple_choice',
      'question': 'If your life were a fashion statement would it be:',
      'options': ['Classic and timeless', 'Trendy and expressive']
    },
    {
      'type': 'multiple_choice',
      'question': 'What best describes an ideal night',
      'options': ['Well-planned in advance', 'Spontaneous and improvised']
    },
    {
      'type': 'multiple_choice',
      'question': 'Would you rather listen to rock or rap',
      'options': ['Rap', 'Rock', 'Neither']
    },

    // Rating scale questions
    {
      'type': 'rating_scale',
      'question': 'I am an introvert person',
      'leftLabel': 'Strongly Disagree',
      'rightLabel': 'Strongly Agree'
    },
    {
      'type': 'rating_scale',
      'question': 'I am a self-motivated person',
      'leftLabel': 'Strongly Disagree',
      'rightLabel': 'Strongly Agree'
    },
    {
      'type': 'rating_scale',
      'question': 'I am a creative person',
      'leftLabel': 'Strongly Disagree',
      'rightLabel': 'Strongly Agree'
    },
    {
      'type': 'rating_scale',
      'question': 'I am a stressed person',
      'leftLabel': 'Strongly Disagree',
      'rightLabel': 'Strongly Agree'
    },
    {
      'type': 'rating_scale',
      'question': 'I have an amazing job',
      'leftLabel': 'Strongly Disagree',
      'rightLabel': 'Strongly Agree'
    },
    {
      'type': 'rating_scale',
      'question': 'How important is family to you?',
      'leftLabel': 'Not important',
      'rightLabel': 'Very important'
    },
    {
      'type': 'rating_scale',
      'question': 'How important is spirituality to you?',
      'leftLabel': 'Not important',
      'rightLabel': 'Very important'
    },
    {
      'type': 'rating_scale',
      'question': 'How important is humor to you?',
      'leftLabel': 'Not important',
      'rightLabel': 'Very important'
    },
    {
      'type': 'rating_scale',
      'question': 'How often to you feel lonely?',
      'leftLabel': 'Never',
      'rightLabel': 'Everyday'
    },
    {
      'type': 'rating_scale',
      'question': 'I enjoy going out with friends',
      'leftLabel': 'Never',
      'rightLabel': 'Always Alomst'
    },
    {
      'type': 'rating_scale',
      'question': 'I like to workout',
      'leftLabel': 'Rarely',
      'rightLabel': 'Regularly'
    },
    {
      'type': 'rating_scale',
      'question': 'Does academic success matter to you?',
      'leftLabel': 'I don\'t',
      'rightLabel': 'All I know is school'
    },
    {
      'type': 'rating_scale',
      'question': 'I enjoy spending time more...',
      'leftLabel': 'In nature',
      'rightLabel': 'In the city'
    },
    {
      'type': 'rating_scale',
      'question': 'I enjoy politically incorrect humor',
      'leftLabel': 'Strongly Disagree',
      'rightLabel': 'Strongly Agree'
    },
    {
      'type': 'rating_scale',
      'question': 'I enjoy discussing politics/news',
      'leftLabel': 'Strongly Disagree',
      'rightLabel': 'Strongly Agree'
    },
  ];

  PersonalityController({required this.onStateChanged});

  // Getters
  Map<String, String> get personalityResponses =>
      Map.unmodifiable(_personalityResponses);

  int get currentQuestionIndex => _currentQuestionIndex;
  int get totalQuestions => _questions.length;
  bool get isLastQuestion => _currentQuestionIndex >= _questions.length - 1;
  bool get isFirstQuestion => _currentQuestionIndex == 0;
  bool get isAnimating => _isForwardAnimating || _isBackwardAnimating;

  String get currentQuestion => _questions[_currentQuestionIndex]['question'];
  String get currentQuestionType => _questions[_currentQuestionIndex]['type'];

  // For multiple choice questions
  List<String> get currentOptions =>
      _questions[_currentQuestionIndex]['options'] ?? [];

  // For rating scale questions
  String get currentLeftLabel =>
      _questions[_currentQuestionIndex]['leftLabel'] ?? '';
  String get currentRightLabel =>
      _questions[_currentQuestionIndex]['rightLabel'] ?? '';

  String? get currentAnswer => _personalityResponses[currentQuestion];
  bool get hasAnsweredCurrent => currentAnswer != null;

  // Updated progress calculation based on answered questions up to current position
  double get progress {
    return (_currentQuestionIndex + 1) / _questions.length;
  }

  // Check if an option is selected for current question (multiple choice)
  bool isSelected(String option) {
    return _personalityResponses[currentQuestion] == option;
  }

  // Check if a rating is selected for current question (rating scale)
  bool isRatingSelected(int rating) {
    final currentRating = _personalityResponses[currentQuestion];
    return currentRating != null && int.tryParse(currentRating) == rating;
  }

  // Handle option selection for multiple choice questions
  void selectOption(String option) {
    if (_isForwardAnimating) return;

    _personalityResponses[currentQuestion] = option;

    // Save progress immediately
    OnboardingStateService.savePersonalityData(_personalityResponses);

    onStateChanged();

    // Auto-advance to next question after a delay for animation
    if (!isLastQuestion) {
      _isForwardAnimating = true;
      Future.delayed(Duration(milliseconds: 500), () {
        _advanceToNextQuestion();
        _isForwardAnimating = false;
      });
    }
  }

  // Handle rating selection for rating scale questions
  void selectRating(int rating) {
    if (_isForwardAnimating) return;

    _personalityResponses[currentQuestion] = rating.toString();

    // Save progress immediately
    OnboardingStateService.savePersonalityData(_personalityResponses);

    onStateChanged();

    // Auto-advance to next question after a delay for animation
    if (!isLastQuestion) {
      _isForwardAnimating = true;
      Future.delayed(Duration(milliseconds: 800), () {
        _advanceToNextQuestion();
        _isForwardAnimating = false;
      });
    }
  }

  // Navigation methods
  bool canGoNext() {
    return hasAnsweredCurrent && !_isForwardAnimating;
  }

  // Internal method for advancing without animation checks
  void _advanceToNextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      onStateChanged();
    }
  }

  // Public method for manual navigation (respects animation state)
  void goToNextQuestion() {
    if (canGoNext() && !isLastQuestion) {
      _currentQuestionIndex++;
      onStateChanged();
    }
  }

  // FIXED: Remove responses for future questions when going back
  void goToPreviousQuestion() {
    print('goToPreviousQuestion called - isFirstQuestion: $isFirstQuestion');
    print('Current index before: $_currentQuestionIndex');
    print('Current responses count before: ${_personalityResponses.length}');

    if (!isFirstQuestion) {
      _isForwardAnimating = false;
      _currentQuestionIndex--;
      print('Current index after decrement: $_currentQuestionIndex');

      // Remove responses for questions after the current position
      _removeResponsesAfterCurrent();
      print(
          'Current responses count after cleanup: ${_personalityResponses.length}');

      // Save the updated state
      OnboardingStateService.savePersonalityData(_personalityResponses);

      onStateChanged();
      print('onStateChanged called');
    } else {
      print('Cannot go back - on first question');
    }
  }

  // Helper method to remove responses for questions after current position
  void _removeResponsesAfterCurrent() {
    final keysToRemove = <String>[];

    print('Removing responses after index: $_currentQuestionIndex');

    // Find all questions after current position and mark their responses for removal
    for (int i = _currentQuestionIndex + 1; i < _questions.length; i++) {
      final questionText = _questions[i]['question'];
      if (_personalityResponses.containsKey(questionText)) {
        keysToRemove.add(questionText);
        print('Marking for removal: $questionText (index $i)');
      }
    }

    // Remove the marked responses
    for (final key in keysToRemove) {
      _personalityResponses.remove(key);
      print('Removed response for: $key');
    }

    print('Total responses now: ${_personalityResponses.length}');
  }

  void goToQuestion(int index) {
    if (index >= 0 && index < _questions.length && !isAnimating) {
      _isForwardAnimating = true;
      _currentQuestionIndex = index;

      // Remove responses for questions after the target position
      _removeResponsesAfterCurrent();

      onStateChanged();

      // Reset animation state after a short delay
      Future.delayed(Duration(milliseconds: 400), () {
        _isForwardAnimating = false;
      });
    }
  }

  // Check if all questions are answered
  bool get isComplete => _personalityResponses.length == _questions.length;

  // Get completion percentage
  double get completionPercentage =>
      (_personalityResponses.length / _questions.length) * 100;

  // Clear all responses
  void clearAll() {
    _personalityResponses.clear();
    _currentQuestionIndex = 0;
    _isForwardAnimating = false;
    _isBackwardAnimating = false;
    onStateChanged();
  }

  // Get response for a specific question
  String? getResponseForQuestion(String question) {
    return _personalityResponses[question];
  }

  // Check if a specific question is answered
  bool isQuestionAnswered(int index) {
    if (index >= 0 && index < _questions.length) {
      final question = _questions[index]['question'];
      return _personalityResponses.containsKey(question);
    }
    return false;
  }

  // Get summary of all responses
  Map<String, String> getSummary() {
    return Map.from(_personalityResponses);
  }

  void restoreState(Map<String, String> previousData) {
    _personalityResponses.clear();
    _personalityResponses.addAll(previousData);

    // Find the last answered question to set current index
    for (int i = _questions.length - 1; i >= 0; i--) {
      final questionText = _questions[i]['question'];
      if (_personalityResponses.containsKey(questionText)) {
        _currentQuestionIndex = i;
        break;
      }
    }

    // If all questions are answered, go to last question
    if (_personalityResponses.length == _questions.length) {
      _currentQuestionIndex = _questions.length - 1;
    }

    onStateChanged();
  }

  void dispose() {
    // Clean up if needed
    _isForwardAnimating = false;
    _isBackwardAnimating = false;
  }
}
