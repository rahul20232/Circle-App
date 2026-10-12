// lib/screens/Onboarding/onboarding_account_screen.dart
import 'package:flutter/material.dart';
import 'package:circle_app/theme/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:circle_app/screens/Onboarding/components/unified_progress_component.dart';
import 'package:circle_app/services/auth_service.dart';
import 'package:circle_app/services/onboarding_state_service.dart';

class OnboardingAccountScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  final Function(Map<String, String>)? onCompleteWithData;
  final VoidCallback? onBack;
  final Map<String, String>? personalityData;
  final Map<String, String>? identityData;
  final Map<String, String>? initialAccountData;

  const OnboardingAccountScreen({
    Key? key,
    this.onComplete,
    this.onCompleteWithData,
    this.onBack,
    this.personalityData,
    this.identityData,
    this.initialAccountData,
  }) : super(key: key);

  @override
  OnboardingAccountScreenState createState() => OnboardingAccountScreenState();
}

class OnboardingAccountScreenState extends State<OnboardingAccountScreen> {
  PageController _pageController = PageController();
  int _currentStep = 0; // 0: Phone, 1: Email, 2: Password
  bool _isLoading = false; // Add loading state

  // Controllers
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Focus nodes
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  // Validation states
  bool _isValidPhoneNumber = false;
  bool _isValidEmail = false;
  bool _isValidPassword = false;
  bool _passwordsMatch = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Phone country code
  String _selectedCountryCode = '+91';

  // Password requirements
  Map<String, bool> _passwordRequirements = {
    'lowercase': false,
    'uppercase': false,
    'number': false,
    'special': false,
    'length': false,
  };

  // Country codes
  final List<Map<String, String>> _countryCodes = [
    {'code': '+91', 'country': 'IN'},
    {'code': '+1', 'country': 'US'},
    {'code': '+44', 'country': 'UK'},
    {'code': '+86', 'country': 'CN'},
    {'code': '+81', 'country': 'JP'},
    {'code': '+49', 'country': 'DE'},
    {'code': '+33', 'country': 'FR'},
    {'code': '+39', 'country': 'IT'},
    {'code': '+61', 'country': 'AU'},
    {'code': '+7', 'country': 'RU'},
  ];

  @override
  void initState() {
    super.initState();

    // Initialize with saved data if available
    if (widget.initialAccountData != null) {
      final data = widget.initialAccountData!;
      if (data['phone_number'] != null) {
        _phoneController.text =
            data['phone_number']!.replaceAll(_selectedCountryCode + ' ', '');
        _validatePhoneNumber(_phoneController.text);
      }
      if (data['email'] != null) {
        _emailController.text = data['email']!;
        _validateEmail(data['email']!);
      }
    }

    // Add listeners
    _phoneController.addListener(() {
      _validatePhoneNumber(_phoneController.text);
      _saveProgress();
    });

    _emailController.addListener(() {
      _validateEmail(_emailController.text);
      _saveProgress();
    });

    _passwordController.addListener(() {
      _validatePassword(_passwordController.text);
      _checkPasswordsMatch();
      _saveProgress();
    });

    _confirmPasswordController.addListener(() {
      _checkPasswordsMatch();
    });

    // Auto-focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _phoneFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _validatePhoneNumber(String phoneNumber) {
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    setState(() {
      _isValidPhoneNumber = digitsOnly.length >= 10;
    });
  }

  void _validateEmail(String email) {
    setState(() {
      _isValidEmail =
          RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
    });
  }

  void _validatePassword(String password) {
    setState(() {
      _passwordRequirements['lowercase'] = RegExp(r'[a-z]').hasMatch(password);
      _passwordRequirements['uppercase'] = RegExp(r'[A-Z]').hasMatch(password);
      _passwordRequirements['number'] = RegExp(r'[0-9]').hasMatch(password);
      _passwordRequirements['special'] =
          RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
      _passwordRequirements['length'] = password.length >= 8;

      _isValidPassword = _passwordRequirements.values.every((req) => req);
    });
  }

  void _checkPasswordsMatch() {
    setState(() {
      _passwordsMatch =
          _passwordController.text == _confirmPasswordController.text &&
              _confirmPasswordController.text.isNotEmpty;
    });
  }

  void _saveProgress() {
    final accountData = {
      'phone_number': '$_selectedCountryCode ${_phoneController.text}',
      'country_code': _selectedCountryCode,
      'email': _emailController.text,
      'current_account_step': _currentStep.toString(),
    };
    OnboardingStateService.saveAccountData(accountData);
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _saveProgress();

      // Focus appropriate field
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_currentStep == 1) {
          _emailFocusNode.requestFocus();
        } else if (_currentStep == 2) {
          _passwordFocusNode.requestFocus();
        }
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _saveProgress();
    } else {
      widget.onBack?.call();
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _registerUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final identityData = widget.identityData ?? {};
      final personalityData = widget.personalityData ?? {};

      // Extract name from identity data or use email prefix as fallback
      String userName = _emailController.text.split('@')[0]; // Default fallback

      // You could enhance this to extract actual name from identity data if collected

      final result = await AuthService.registerWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
        userName,
        phoneNumber: '$_selectedCountryCode ${_phoneController.text}',
        personalityData: personalityData,
        identityData: identityData,
      );

      setState(() {
        _isLoading = false;
      });

      if (result != null) {
        // Registration successful
        final accountData = {
          'phone_number': '$_selectedCountryCode ${_phoneController.text}',
          'country_code': _selectedCountryCode,
          'email': _emailController.text,
          'registration_status': 'pending_verification',
        };

        OnboardingStateService.saveAccountData(accountData);

        if (widget.onCompleteWithData != null) {
          widget.onCompleteWithData!(accountData);
        } else if (widget.onComplete != null) {
          widget.onComplete!();
        }
      } else {
        _showSnackBar('Registration failed. Please try again.', isError: true);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      String errorMessage = 'Registration failed. Please try again.';
      if (e.toString().contains('already registered')) {
        errorMessage = 'An account with this email already exists.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your connection.';
      }

      _showSnackBar(errorMessage, isError: true);
      print('Registration error: $e');
    }
  }

  void _handleComplete() {
    _registerUser();
  }

  void _showCountryCodePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.grey200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancel',
                        style: TextStyle(
                            color: AppColors.grey600, fontSize: 16)),
                  ),
                  Text('Select Country',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  SizedBox(width: 60),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _countryCodes.length,
                itemBuilder: (context, index) {
                  final country = _countryCodes[index];
                  final isSelected = country['code'] == _selectedCountryCode;

                  return ListTile(
                    title: Text(
                      '${country['country']} ${country['code']}',
                      style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check, color: AppColors.ink)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedCountryCode = country['code']!;
                      });
                      Navigator.of(context).pop();
                      _saveProgress();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _isValidPhoneNumber;
      case 1:
        return _isValidEmail;
      case 2:
        return _isValidPassword && _passwordsMatch;
      default:
        return false;
    }
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'What\'s your phone number?';
      case 1:
        return 'What\'s your email address?';
      case 2:
        return 'Choose a password';
      default:
        return '';
    }
  }

  String _getButtonText() {
    if (_currentStep == 2) {
      return _isLoading ? 'Creating Account...' : 'Create Account';
    }
    return 'Next';
  }

  @override
  @override
  Widget build(BuildContext context) {
    final personalityData = widget.personalityData ?? {};
    final identityData = widget.identityData ?? {};

    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceMuted,
        elevation: 0,
        title: Text('Account',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.ink)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.ink),
          onPressed: _isLoading
              ? null
              : _previousStep, // Disable back button during loading
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress bar
                  UnifiedProgressComponent(
                    totalPersonalityQuestions: 21,
                    answeredPersonalityQuestions: personalityData.length,
                    totalIdentityQuestions: 5,
                    answeredIdentityQuestions: identityData.length,
                    showGradient: false,
                  ),

                  const SizedBox(height: 60),

                  // Step title
                  Text(
                    _getStepTitle(),
                    style: TextStyle(
                        fontSize: 28,
                        fontFamily: AppFonts.serif, fontWeight: FontWeight.w400,
                        color: AppColors.ink),
                  ),

                  const SizedBox(height: 60),
                ],
              ),
            ),

            // PageView content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildPhoneStep(),
                  _buildEmailStep(),
                  _buildPasswordStep(),
                ],
              ),
            ),

            // Next/Create Account button
            Padding(
              padding: const EdgeInsets.all(30),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (_canProceed() && !_isLoading)
                      ? (_currentStep == 2 ? _handleComplete : _nextStep)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (_canProceed() && !_isLoading)
                        ? AppColors.ink
                        : AppColors.grey300,
                    foregroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(AppColors.surface),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(_getButtonText(),
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600)),
                          ],
                        )
                      : Text(_getButtonText(),
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _showCountryCodePicker,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.grey300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_selectedCountryCode,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down,
                      color: AppColors.grey600, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _phoneController,
              focusNode: _phoneFocusNode,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10)
              ],
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'Phone number',
                hintStyle: TextStyle(color: AppColors.grey500, fontSize: 16),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.grey300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.ink, width: 2),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: TextField(
        controller: _emailController,
        focusNode: _emailFocusNode,
        keyboardType: TextInputType.emailAddress,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: 'Email',
          hintStyle: TextStyle(color: AppColors.grey500, fontSize: 16),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.grey300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.ink, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPasswordStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Password field
          TextField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            obscureText: _obscurePassword,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: 'Your password',
              hintStyle: TextStyle(color: AppColors.grey500, fontSize: 16),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.grey300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.ink, width: 2),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              suffixIcon: IconButton(
                icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.grey600),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Password requirements
          ..._passwordRequirements.entries.map((entry) {
            String label;
            switch (entry.key) {
              case 'lowercase':
                label = 'Lowercase and uppercase';
                break;
              case 'uppercase':
                label = 'Uppercase';
                break;
              case 'number':
                label = 'At least 1 number';
                break;
              case 'special':
                label = 'At least 1 special character';
                break;
              case 'length':
                label = 'At least 8 characters';
                break;
              default:
                label = '';
            }

            return Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    entry.value ? Icons.check : Icons.close,
                    color: entry.value ? AppColors.success : AppColors.grey600,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Text(label,
                      style:
                          TextStyle(color: AppColors.grey700, fontSize: 16)),
                ],
              ),
            );
          }).toList(),

          const SizedBox(height: 20),

          // Confirm password field
          TextField(
            controller: _confirmPasswordController,
            focusNode: _confirmPasswordFocusNode,
            obscureText: _obscureConfirmPassword,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: 'Confirm password',
              hintStyle: TextStyle(color: AppColors.grey500, fontSize: 16),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.grey300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.ink, width: 2),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              suffixIcon: IconButton(
                icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: AppColors.grey600),
                onPressed: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
