// ============================================================================
// 1. FORGOT PASSWORD PAGE
// ============================================================================

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Modern color scheme
  static const Color primaryColor = Color(0xFF2563EB);
  static const Color surfaceColor = Color(0xFFFAFAFA);
  static const Color cardColor = Colors.white;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Scaffold(
      backgroundColor: surfaceColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 32),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 24 : 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildForm(),
                      const SizedBox(height: 24),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, primaryColor.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.lock_reset_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'نسيت كلمة المرور؟',
          style: GoogleFonts.cairo(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'أدخل بريدك الإلكتروني وسنرسل لك رمز التحقق',
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.cairo(),
            decoration: InputDecoration(
              labelText: 'البريد الإلكتروني',
              labelStyle: GoogleFonts.cairo(color: Colors.grey.shade600),
              hintText: 'example@email.com',
              hintStyle: GoogleFonts.cairo(color: Colors.grey.shade400),
              prefixIcon: Icon(Icons.email_outlined, color: primaryColor),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red.shade400),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال البريد الإلكتروني';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'يرجى إدخال بريد إلكتروني صحيح';
              }
              return null;
            },
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline,
                      color: Colors.red.shade600, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.cairo(
                        color: Colors.red.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_successMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      color: Colors.green.shade600, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _successMessage!,
                      style: GoogleFonts.cairo(
                        color: Colors.green.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendResetCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'إرسال رمز التحقق',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        TextButton(
          onPressed: () => context.go('/secure-trusted-895623/login'),
          child: Text(
            'العودة لتسجيل الدخول',
            style: GoogleFonts.cairo(
              color: primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _sendResetCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final email = _emailController.text.trim().toLowerCase();

      // Check if user exists in our database
      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userQuery.docs.isEmpty) {
        throw Exception('لا يوجد حساب مسجل بهذا البريد الإلكتروني');
      }

      final userDoc = userQuery.docs.first;
      final userData = userDoc.data();

      // Check if user is approved trusted user
      if (userData['status'] != 'approved') {
        throw Exception('هذا الحساب غير مفعل. يرجى التواصل مع الإدارة');
      }

      // Generate 6-digit verification code
      final verificationCode = _generateVerificationCode();

      // Store verification code in Firestore with expiration
      await FirebaseFirestore.instance
          .collection('password_reset_codes')
          .doc(email)
          .set({
        'code': verificationCode,
        'email': email,
        'userId': userDoc.id,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': DateTime.now()
            .add(const Duration(minutes: 15))
            .millisecondsSinceEpoch,
        'used': false,
      });

      // Send verification code via email (you can integrate with your email service)
      await _sendVerificationEmail(email, verificationCode,
          userData['profile']['fullName'] ?? 'المستخدم');

      setState(() {
        _successMessage = 'تم إرسال رمز التحقق إلى بريدك الإلكتروني';
        _isLoading = false;
      });

      // Navigate to verification screen after delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          context.go(
              '/secure-trusted-895623/verify-reset-code?email=${Uri.encodeComponent(email)}');
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  String _generateVerificationCode() {
    final random = Random();
    return (random.nextInt(900000) + 100000).toString();
  }

  Future<void> _sendVerificationEmail(
      String email, String code, String userName) async {
    // Here you would integrate with your email service (SendGrid, AWS SES, etc.)
    // For now, we'll just print it (in production, remove this)
    print('📧 Sending verification code to $email: $code');

    // Example integration with a hypothetical email service:
    /*
    await EmailService.send({
      'to': email,
      'subject': 'رمز إعادة تعيين كلمة المرور - وادي المواهب الموثوق',
      'template': 'password_reset',
      'data': {
        'userName': userName,
        'verificationCode': code,
        'expiryMinutes': 15,
      }
    });
    */
  }
}

// ============================================================================
// 2. VERIFICATION CODE PAGE
// ============================================================================

class VerifyResetCodeScreen extends ConsumerStatefulWidget {
  final String email;

  const VerifyResetCodeScreen({Key? key, required this.email})
      : super(key: key);

  @override
  ConsumerState<VerifyResetCodeScreen> createState() =>
      _VerifyResetCodeScreenState();
}

class _VerifyResetCodeScreenState extends ConsumerState<VerifyResetCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _codeControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  String? _errorMessage;
  int _remainingTime = 900; // 15 minutes
  late DateTime _expiryTime;

  static const Color primaryColor = Color(0xFF2563EB);
  static const Color surfaceColor = Color(0xFFFAFAFA);

  @override
  void initState() {
    super.initState();
    _expiryTime = DateTime.now().add(const Duration(minutes: 15));
    _startCountdown();
  }

  @override
  void dispose() {
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
        _startCountdown();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Scaffold(
      backgroundColor: surfaceColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 32),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 24 : 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildCodeInput(),
                      const SizedBox(height: 24),
                      _buildActions(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade600, Colors.orange.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.verified_user_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'تحقق من رمز التأكيد',
          style: GoogleFonts.cairo(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'أدخل الرمز المرسل إلى',
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.email,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _remainingTime > 300
                ? Colors.green.shade50
                : Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _remainingTime > 300
                  ? Colors.green.shade200
                  : Colors.orange.shade200,
            ),
          ),
          child: Text(
            'ينتهي خلال: ${_formatTime(_remainingTime)}',
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _remainingTime > 300
                  ? Colors.green.shade700
                  : Colors.orange.shade700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCodeInput() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (index) => _buildCodeField(index)),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline,
                      color: Colors.red.shade600, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.cairo(
                        color: Colors.red.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCodeField(int index) {
    return Container(
      width: 45,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              _focusNodes[index].hasFocus ? primaryColor : Colors.grey.shade300,
          width: _focusNodes[index].hasFocus ? 2 : 1,
        ),
      ),
      child: TextFormField(
        controller: _codeControllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        maxLength: 1,
        keyboardType: TextInputType.number,
        style: GoogleFonts.cairo(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade800,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }

          // Auto-verify when all fields are filled
          if (index == 5 && value.isNotEmpty) {
            _verifyCode();
          }
        },
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading || _remainingTime <= 0 ? null : _verifyCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'تحقق من الرمز',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _remainingTime > 0 ? null : _resendCode,
          child: Text(
            _remainingTime > 0
                ? 'إعادة الإرسال متاحة خلال ${_formatTime(_remainingTime)}'
                : 'إعادة إرسال الرمز',
            style: GoogleFonts.cairo(
              color: _remainingTime > 0 ? Colors.grey.shade500 : primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextButton(
          onPressed: () => context.go('/secure-trusted-895623/forgot-password'),
          child: Text(
            'تغيير البريد الإلكتروني',
            style: GoogleFonts.cairo(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _verifyCode() async {
    final code = _codeControllers.map((c) => c.text).join();

    if (code.length != 6) {
      setState(() {
        _errorMessage = 'يرجى إدخال الرمز كاملاً';
      });
      return;
    }

    if (_remainingTime <= 0) {
      setState(() {
        _errorMessage = 'انتهت صلاحية الرمز، يرجى طلب رمز جديد';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Verify code from Firestore
      final codeDoc = await FirebaseFirestore.instance
          .collection('password_reset_codes')
          .doc(widget.email)
          .get();

      if (!codeDoc.exists) {
        throw Exception('رمز التحقق غير صحيح');
      }

      final codeData = codeDoc.data()!;

      if (codeData['used'] == true) {
        throw Exception('تم استخدام هذا الرمز مسبقاً');
      }

      if (codeData['code'] != code) {
        throw Exception('رمز التحقق غير صحيح');
      }

      final expiresAt = codeData['expiresAt'] as int;
      if (DateTime.now().millisecondsSinceEpoch > expiresAt) {
        throw Exception('انتهت صلاحية رمز التحقق');
      }

      // Mark code as used
      await FirebaseFirestore.instance
          .collection('password_reset_codes')
          .doc(widget.email)
          .update({'used': true});

      // Navigate to reset password screen
      if (mounted) {
        context.go(
            '/secure-trusted-895623/reset-password?email=${Uri.encodeComponent(widget.email)}&code=${Uri.encodeComponent(code)}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _resendCode() async {
    context.go('/secure-trusted-895623/forgot-password');
  }
}

// ============================================================================
// 3. RESET PASSWORD PAGE
// ============================================================================

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String email;
  final String code;

  const ResetPasswordScreen({Key? key, required this.email, required this.code})
      : super(key: key);

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  String? _errorMessage;

  static const Color primaryColor = Color(0xFF2563EB);
  static const Color surfaceColor = Color(0xFFFAFAFA);

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Scaffold(
      backgroundColor: surfaceColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 32),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 24 : 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildForm(),
                      const SizedBox(height: 24),
                      _buildActions(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade600, Colors.green.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.lock_open_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'إعادة تعيين كلمة المرور',
          style: GoogleFonts.cairo(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'أدخل كلمة المرور الجديدة لحسابك',
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _passwordController,
            obscureText: !_passwordVisible,
            style: GoogleFonts.cairo(),
            decoration: InputDecoration(
              labelText: 'كلمة المرور الجديدة',
              labelStyle: GoogleFonts.cairo(color: Colors.grey.shade600),
              hintText: 'أدخل كلمة مرور قوية',
              hintStyle: GoogleFonts.cairo(color: Colors.grey.shade400),
              prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
              suffixIcon: IconButton(
                onPressed: () =>
                    setState(() => _passwordVisible = !_passwordVisible),
                icon: Icon(
                  _passwordVisible ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey.shade500,
                ),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red.shade400),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال كلمة المرور';
              }
              if (value.length < 6) {
                return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: !_confirmPasswordVisible,
            style: GoogleFonts.cairo(),
            decoration: InputDecoration(
              labelText: 'تأكيد كلمة المرور',
              labelStyle: GoogleFonts.cairo(color: Colors.grey.shade600),
              hintText: 'أعد إدخال كلمة المرور',
              hintStyle: GoogleFonts.cairo(color: Colors.grey.shade400),
              prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
              suffixIcon: IconButton(
                onPressed: () => setState(
                    () => _confirmPasswordVisible = !_confirmPasswordVisible),
                icon: Icon(
                  _confirmPasswordVisible
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.grey.shade500,
                ),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red.shade400),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى تأكيد كلمة المرور';
              }
              if (value != _passwordController.text) {
                return 'كلمة المرور غير متطابقة';
              }
              return null;
            },
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline,
                      color: Colors.red.shade600, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.cairo(
                        color: Colors.red.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _resetPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'إعادة تعيين كلمة المرور',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => context.go('/secure-trusted-895623/login'),
          child: Text(
            'العودة لتسجيل الدخول',
            style: GoogleFonts.cairo(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Verify the code is still valid
      final codeDoc = await FirebaseFirestore.instance
          .collection('password_reset_codes')
          .doc(widget.email)
          .get();

      if (!codeDoc.exists || codeDoc.data()!['code'] != widget.code) {
        throw Exception('رمز التحقق غير صحيح أو منتهي الصلاحية');
      }

      final codeData = codeDoc.data()!;

      // Check if code is expired
      final expiresAt = codeData['expiresAt'] as int;
      if (DateTime.now().millisecondsSinceEpoch > expiresAt) {
        throw Exception('انتهت صلاحية رمز التحقق');
      }

      // Get user data
      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: widget.email)
          .get();

      if (userQuery.docs.isEmpty) {
        throw Exception('لا يمكن العثور على الحساب');
      }

      final userId = userQuery.docs.first.id;
      final newPassword = _passwordController.text;

      // METHOD 1: Use temporary sign-in approach (Recommended)
      try {
        // First, send a password reset email to get a reset link
        await FirebaseAuth.instance.sendPasswordResetEmail(email: widget.email);

        // Store the new password temporarily for the user to use
        await FirebaseFirestore.instance
            .collection('temp_password_reset')
            .doc(widget.email)
            .set({
          'newPassword':
              newPassword, // In production, you might want to hash this
          'userId': userId,
          'verified': true,
          'createdAt': FieldValue.serverTimestamp(),
          'expiresAt': DateTime.now()
              .add(const Duration(hours: 1))
              .millisecondsSinceEpoch,
        });

        // Update user's last password reset time
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'lastPasswordReset': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'passwordResetPending': true,
        });

        // Delete the used reset code
        await FirebaseFirestore.instance
            .collection('password_reset_codes')
            .doc(widget.email)
            .delete();

        // Show success dialog with instructions
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Icon(Icons.check_circle,
                      color: Colors.green.shade600, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'تم التحقق بنجاح!',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تم التحقق من هويتك بنجاح. لإكمال إعادة تعيين كلمة المرور:',
                    style: GoogleFonts.cairo(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '1. افتح بريدك الإلكتروني',
                          style: GoogleFonts.cairo(
                              fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '2. اضغط على رابط إعادة تعيين كلمة المرور',
                          style: GoogleFonts.cairo(
                              fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '3. استخدم كلمة المرور الجديدة التي اخترتها',
                          style: GoogleFonts.cairo(
                              fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'كلمة المرور الجديدة: ${newPassword}',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'احفظ كلمة المرور هذه واستخدمها عند إعادة التعيين.',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('/secure-trusted-895623/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('فهمت، انتقل لتسجيل الدخول',
                      style: GoogleFonts.cairo()),
                ),
              ],
            ),
          );
        }
      } catch (authError) {
        print('Auth error: $authError');
        // If Firebase Auth fails, try alternative method
        await _resetPasswordAlternative(userId, newPassword);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  // Alternative method: Store reset info and guide user to use Firebase reset
  Future<void> _resetPasswordAlternative(
      String userId, String newPassword) async {
    // Update user record with password reset information
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'passwordResetRequest': {
        'requestedAt': FieldValue.serverTimestamp(),
        'newPasswordLength': newPassword.length, // Don't store actual password
        'status': 'verified',
      },
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Delete the used reset code
    await FirebaseFirestore.instance
        .collection('password_reset_codes')
        .doc(widget.email)
        .delete();

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.info, color: Colors.blue.shade600, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'تم التحقق من الرمز',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تم التحقق من رمز إعادة التعيين بنجاح. لإكمال العملية:',
                style: GoogleFonts.cairo(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'يرجى التواصل مع الإدارة لإكمال إعادة تعيين كلمة المرور',
                      style: GoogleFonts.cairo(
                          fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'أو استخدم خيار "نسيت كلمة المرور" في صفحة تسجيل الدخول',
                      style: GoogleFonts.cairo(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Send Firebase password reset email as backup
                try {
                  await FirebaseAuth.instance
                      .sendPasswordResetEmail(email: widget.email);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'تم إرسال رابط إعادة التعيين إلى بريدك الإلكتروني',
                            style: GoogleFonts.cairo()),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  print('Error sending reset email: $e');
                }
              },
              child:
                  Text('إرسال رابط إعادة التعيين', style: GoogleFonts.cairo()),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/secure-trusted-895623/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('العودة لتسجيل الدخول', style: GoogleFonts.cairo()),
            ),
          ],
        ),
      );
    }
  }
}

// ============================================================================
// 4. ROUTER CONFIGURATION UPDATE
// ============================================================================

// Add these routes to your GoRouter configuration:

/*
GoRoute(
  path: '/secure-trusted-895623/forgot-password',
  builder: (context, state) => const ForgotPasswordScreen(),
),
GoRoute(
  path: '/secure-trusted-895623/verify-reset-code',
  builder: (context, state) {
    final email = state.uri.queryParameters['email'] ?? '';
    return VerifyResetCodeScreen(email: email);
  },
),
GoRoute(
  path: '/secure-trusted-895623/reset-password',
  builder: (context, state) {
    final email = state.uri.queryParameters['email'] ?? '';
    final code = state.uri.queryParameters['code'] ?? '';
    return ResetPasswordScreen(email: email, code: code);
  },
),
*/

// ============================================================================
// 5. UPDATE LOGIN SCREEN TO ADD FORGOT PASSWORD LINK
// ============================================================================

// Add this widget to your login screen form:

class LoginScreenForgotPasswordLink extends StatelessWidget {
  const LoginScreenForgotPasswordLink({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: () => context.go('/secure-trusted-895623/forgot-password'),
        child: Text(
          'نسيت كلمة المرور؟',
          style: GoogleFonts.cairo(
            color: const Color(0xFF2563EB),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 6. EMAIL SERVICE INTEGRATION (OPTIONAL)
// ============================================================================

// Example email service class for sending verification codes
class EmailService {
  static Future<void> sendPasswordResetCode({
    required String email,
    required String code,
    required String userName,
  }) async {
    // Integration with your email service provider
    // Example using HTTP request to your backend:

    /*
    final response = await http.post(
      Uri.parse('https://your-backend.com/api/send-email'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'to': email,
        'template': 'password_reset',
        'subject': 'رمز إعادة تعيين كلمة المرور - وادي المواهب الموثوق',
        'data': {
          'userName': userName,
          'verificationCode': code,
          'expiryMinutes': 15,
        }
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('فشل في إرسال البريد الإلكتروني');
    }
    */

    // For development, just print the code
    print('📧 Password Reset Code for $email: $code');
  }
}

// ============================================================================
// 7. FIRESTORE SECURITY RULES UPDATE
// ============================================================================

// Add these rules to your Firestore security rules:

/*
// Password reset codes collection
match /password_reset_codes/{email} {
  allow read, write: if request.auth != null;
  allow create: if true; // Allow anonymous creation for forgot password
}
*/

// ============================================================================
// 8. CLEAN UP EXPIRED CODES (CLOUD FUNCTION)
// ============================================================================

// Example Cloud Function to clean up expired reset codes:

/*
const functions = require('firebase-functions');
const admin = require('firebase-admin');

exports.cleanupExpiredResetCodes = functions.pubsub
  .schedule('every 1 hours')
  .onRun(async (context) => {
    const now = Date.now();
    const expiredCodes = await admin.firestore()
      .collection('password_reset_codes')
      .where('expiresAt', '<', now)
      .get();

    const batch = admin.firestore().batch();
    expiredCodes.docs.forEach(doc => batch.delete(doc.ref));

    await batch.commit();
    console.log(`Cleaned up ${expiredCodes.size} expired reset codes`);
  });
*/
