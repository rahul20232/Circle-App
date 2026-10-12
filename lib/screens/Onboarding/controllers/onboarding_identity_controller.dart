// lib/screens/Onboarding/controllers/onboarding_identity_controller.dart
import 'package:flutter/material.dart';

class OnboardingIdentityController {
  final Map<String, String> initialData;
  final VoidCallback onStateChanged;
  final int personalityQuestionsCount;
  final int personalityAnsweredCount;

  // Store all identity responses
  final Map<String, String> _identityResponses = {};

  // Current question index
  int _currentQuestionIndex = 0;

  // Animation state
  bool _isAnimating = false;

  // Identity questions and their options/types
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What is your relationship status?',
      'type': 'multiple_choice',
      'options': [
        'Single',
        'Married',
        "It's Complicated",
        'In a relationship',
        "I'd prefer not to say"
      ],
      'category': 'relationship'
    },
    {
      'question': 'Do you have children?',
      'type': 'multiple_choice',
      'options': [
        'No',
        'Yes',
        "I'd prefer not to say",
      ],
      'category': 'family'
    },
    {
      'question': 'If you\'re working, what industry do you work in?',
      'type': 'multiple_choice',
      'options': [
        'Not working',
        'Healthcare',
        'Technology',
        'Manual Labor',
        'Retail',
        'Food',
        'Services',
        'Arts',
        'Politics'
      ],
      'category': 'career'
    },
    {
      'question': 'What country are you from?',
      'type': 'multiple_choice',
      'options': [
        'India 🇮🇳',
        'USA 🇺🇸',
        'Australia 🇦🇺',
        'Canada 🇨🇦',
        'UK 🇬🇧',
        'Germany 🇩🇪',
        'France 🇫🇷',
        'Italy 🇮🇹',
        'Spain 🇪🇸',
        'Japan 🇯🇵',
        'China 🇨🇳',
      ],
      'category': 'location'
    },
    {
      'question': 'When is your birthday?',
      'type': 'date_picker',
      'options': [], // No predefined options for date picker
      'category': 'personal'
    },
  ];

  OnboardingIdentityController({
    required this.initialData,
    required this.onStateChanged,
    this.personalityQuestionsCount = 0,
    this.personalityAnsweredCount = 0,
  }) {
    // Initialize with existing data if provided
    if (initialData.isNotEmpty) {
      _identityResponses.addAll(initialData);
    }
  }

  // Getters
  Map<String, String> get identityResponses =>
      Map.unmodifiable(_identityResponses);

  int get currentQuestionIndex => _currentQuestionIndex;
  int get totalQuestions => _questions.length;
  bool get isLastQuestion => _currentQuestionIndex >= _questions.length - 1;
  bool get isFirstQuestion => _currentQuestionIndex == 0;
  bool get isAnimating => _isAnimating;

  String get currentQuestion => _questions[_currentQuestionIndex]['question'];
  String get currentQuestionType => _questions[_currentQuestionIndex]['type'];
  List<String> get currentOptions =>
      List<String>.from(_questions[_currentQuestionIndex]['options']);
  String get currentCategory => _questions[_currentQuestionIndex]['category'];

  String? get currentAnswer => _identityResponses[currentQuestion];
  bool get hasAnsweredCurrent => currentAnswer != null;

  // Check if current question is date picker type
  bool get isCurrentQuestionDatePicker => currentQuestionType == 'date_picker';

  // Updated progress calculation that considers both personality and identity questions
  double get progress {
    final totalQuestionsOverall = personalityQuestionsCount + _questions.length;
    final totalAnsweredOverall =
        personalityAnsweredCount + _identityResponses.length;
    return totalAnsweredOverall / totalQuestionsOverall;
  }

  // Progress specific to just identity questions (for internal use)
  double get identityProgress => _identityResponses.length / _questions.length;

  // Check if an option is selected for current question
  bool isSelected(String option) {
    return _identityResponses[currentQuestion] == option;
  }

  // Handle option selection with auto-advance
  void selectOption(String option) {
    if (_isAnimating) return;

    _identityResponses[currentQuestion] = option;
    onStateChanged();

    // Auto-advance to next question after a delay for animation
    if (!isLastQuestion) {
      _isAnimating = true;
      Future.delayed(Duration(milliseconds: 300), () {
        _advanceToNextQuestion();
        _isAnimating = false;
      });
    }
  }

  // Handle date selection for birthday question
  void selectDate(DateTime date) {
    if (_isAnimating) return;

    // Format date as MM/DD/YYYY
    final formattedDate =
        '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';

    _identityResponses[currentQuestion] = formattedDate;
    onStateChanged();

    // Auto-advance to next question after a delay for animation
    if (!isLastQuestion) {
      _isAnimating = true;
      Future.delayed(Duration(milliseconds: 300), () {
        _advanceToNextQuestion();
        _isAnimating = false;
      });
    }
  }

  // Get formatted date for display
  String? get formattedBirthday {
    final dateString = _identityResponses[currentQuestion];
    if (dateString == null) return null;

    try {
      final parts = dateString.split('/');
      if (parts.length == 3) {
        final month = int.parse(parts[0]);
        final day = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        final date = DateTime(year, month, day);

        const months = [
          '',
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December'
        ];

        return '${months[month]} $day, $year';
      }
    } catch (e) {
      // If parsing fails, return original string
      return dateString;
    }

    return dateString;
  }

  // Navigation methods
  bool canGoNext() {
    return hasAnsweredCurrent && !_isAnimating;
  }

  // Internal method for advancing without animation checks
  void _advanceToNextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      onStateChanged();
    }
  }

  // Public method for manual navigation
  void goToNextQuestion() {
    if (canGoNext() && !isLastQuestion) {
      _currentQuestionIndex++;
      onStateChanged();
    }
  }

  // FIXED: Remove responses for future questions when going back
  void goToPreviousQuestion() {
    if (!isFirstQuestion && !_isAnimating) {
      // Add !_isAnimating check
      _currentQuestionIndex--;

      // Remove responses for questions after the current position
      _removeResponsesAfterCurrent();

      onStateChanged();
    }
  }

  // Helper method to remove responses for questions after current position
  void _removeResponsesAfterCurrent() {
    final keysToRemove = <String>[];

    // Find all questions after current position and mark their responses for removal
    for (int i = _currentQuestionIndex + 1; i < _questions.length; i++) {
      final questionText = _questions[i]['question'];
      if (_identityResponses.containsKey(questionText)) {
        keysToRemove.add(questionText);
      }
    }

    // Remove the marked responses
    for (final key in keysToRemove) {
      _identityResponses.remove(key);
    }
  }

  void goToQuestion(int index) {
    if (index >= 0 && index < _questions.length && !_isAnimating) {
      _isAnimating = true;
      _currentQuestionIndex = index;

      // Remove responses for questions after the target position
      _removeResponsesAfterCurrent();

      onStateChanged();

      Future.delayed(Duration(milliseconds: 400), () {
        _isAnimating = false;
      });
    }
  }

  // Check if all questions are answered
  bool get isComplete => _identityResponses.length == _questions.length;

  // Get completion percentage
  double get completionPercentage =>
      (_identityResponses.length / _questions.length) * 100;

  // Clear all responses
  void clearAll() {
    _identityResponses.clear();
    _currentQuestionIndex = 0;
    _isAnimating = false;
    onStateChanged();
  }

  // Get response for a specific question
  String? getResponseForQuestion(String question) {
    return _identityResponses[question];
  }

  // Check if a specific question is answered
  bool isQuestionAnswered(int index) {
    if (index >= 0 && index < _questions.length) {
      final question = _questions[index]['question'];
      return _identityResponses.containsKey(question);
    }
    return false;
  }

  // Get all responses
  Map<String, String> getAllResponses() {
    return Map.from(_identityResponses);
  }

  // Restore state from previous session
  void restoreState(Map<String, String> previousData) {
    _identityResponses.clear();
    _identityResponses.addAll(previousData);

    // Find the last answered question to set current index
    for (int i = _questions.length - 1; i >= 0; i--) {
      final questionText = _questions[i]['question'];
      if (_identityResponses.containsKey(questionText)) {
        _currentQuestionIndex = i;
        break;
      }
    }

    // If all questions are answered, go to last question
    if (_identityResponses.length == _questions.length) {
      _currentQuestionIndex = _questions.length - 1;
    }

    onStateChanged();
  }

  // Helper methods from original controller
  List<String> getOptionsForQuestion(String question) {
    for (var q in _questions) {
      if (q['question'] == question) {
        return List<String>.from(q['options']);
      }
    }
    return [];
  }

  String getQuestionCategory(String question) {
    for (var q in _questions) {
      if (q['question'] == question) {
        return q['category'];
      }
    }
    return 'unknown';
  }

  String getQuestionType(String question) {
    for (var q in _questions) {
      if (q['question'] == question) {
        return q['type'];
      }
    }
    return 'multiple_choice';
  }

  bool hasOptionsForQuestion(String question) {
    return getOptionsForQuestion(question).isNotEmpty;
  }

  bool isValidSelection(String value) {
    return value.isNotEmpty;
  }

  void dispose() {
    _isAnimating = false;
  }
}
