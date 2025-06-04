import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/services/auth_service.dart';

class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isInitialLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkInitialAuthState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkInitialAuthState() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final authState = ref.read(authProvider);

    // If user is authenticated but not admin, sign them out immediately
    if (authState.isAuthenticated && !authState.isAdmin) {
      await ref.read(authProvider.notifier).signOut();
    }

    // Only redirect if user is authenticated AND admin
    if (authState.isAuthenticated && authState.isAdmin) {
      if (mounted) {
        context.go('/');
        return;
      }
    }

    if (mounted) {
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authNotifier = ref.read(authProvider.notifier);

      // Attempt to sign in with Firebase
      await authNotifier.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // Add a small delay to ensure state is updated
      await Future.delayed(const Duration(milliseconds: 300));

      // Check authentication result
      final authState = ref.read(authProvider);

      // Debug: Print the current auth state
      print(
          'DEBUG: Auth State - isAuthenticated: ${authState.isAuthenticated}, isAdmin: ${authState.isAdmin}');

      if (authState.isAuthenticated) {
        // User is authenticated, now check if they're admin
        if (authState.isAdmin) {
          // Success: User is authenticated AND admin
          print(
              'DEBUG: User is authenticated and admin - proceeding to dashboard');
          if (mounted) {
            setState(() {
              _isLoading = false;
            });

            _showSuccessDialog();

            await Future.delayed(const Duration(milliseconds: 1500));
            if (mounted) {
              context.go('/');
            }
          }
        } else {
          // User is authenticated but NOT admin - sign them out
          print('DEBUG: User is authenticated but not admin - signing out');
          await authNotifier.signOut();
          if (mounted) {
            setState(() {
              _errorMessage = 'لا تملك صلاحيات المشرف المطلوبة';
              _isLoading = false;
            });
          }
        }
      } else {
        // Authentication failed but no exception was thrown
        print('DEBUG: Authentication failed - user not authenticated');
        if (mounted) {
          setState(() {
            _errorMessage = 'فشل تسجيل الدخول، يرجى التحقق من بياناتك';
            _isLoading = false;
          });
        }
      }
    } on Exception catch (e) {
      // Handle Firebase authentication exceptions
      if (mounted) {
        setState(() {
          String errorMessage = 'حدث خطأ أثناء تسجيل الدخول';

          String errorString = e.toString().toLowerCase();

          if (errorString.contains('user-not-found') ||
              errorString.contains('user not found')) {
            errorMessage = 'المستخدم غير موجود';
          } else if (errorString.contains('wrong-password') ||
              errorString.contains('invalid-credential') ||
              errorString.contains('invalid-login-credentials')) {
            errorMessage = 'كلمة المرور غير صحيحة';
          } else if (errorString.contains('invalid-email')) {
            errorMessage = 'البريد الإلكتروني غير صحيح';
          } else if (errorString.contains('user-disabled')) {
            errorMessage = 'تم تعطيل هذا الحساب';
          } else if (errorString.contains('too-many-requests')) {
            errorMessage = 'محاولات كثيرة، يرجى المحاولة لاحقاً';
          } else if (errorString.contains('network-request-failed')) {
            errorMessage = 'خطأ في الاتصال، تحقق من الإنترنت';
          } else if (errorString.contains('email-already-in-use')) {
            errorMessage = 'البريد الإلكتروني مستخدم بالفعل';
          } else if (errorString.contains('weak-password')) {
            errorMessage = 'كلمة المرور ضعيفة جداً';
          }

          _errorMessage = errorMessage;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Handle any other errors
      if (mounted) {
        setState(() {
          _errorMessage = 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى';
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 40,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'تم تسجيل الدخول بنجاح',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'جاري التوجيه إلى لوحة التحكم...',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInitialLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade700,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.admin_panel_settings,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            const SizedBox(height: 20),
            Text(
              'جاري التحقق من حالة تسجيل الدخول...',
              style: GoogleFonts.cairo(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return _buildInitialLoadingScreen();
    }

    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;
    final isDesktop = size.width >= 1024;

    return Scaffold(
      appBar: _buildAppBar(context, isMobile),
      body: isMobile
          ? _buildMobileLayout(context)
          : _buildWebLayout(context, isDesktop),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isMobile) {
    if (isMobile) {
      return AppBar(
        title: Text(
          'تسجيل الدخول',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.grey.shade800,
        elevation: 0,
        centerTitle: true,
      );
    } else {
      return AppBar(
        backgroundColor: Colors.grey.shade900,
        elevation: 0,
        toolbarHeight: 40,
        automaticallyImplyLeading: false,
      );
    }
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              _buildMobileHeader(),
              const SizedBox(height: 40),
              _buildMobileForm(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebLayout(BuildContext context, bool isDesktop) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade900,
            Colors.grey.shade800,
            Colors.grey.shade700,
          ],
        ),
      ),
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 450 : 400,
            maxHeight: isDesktop ? 700 : 600,
          ),
          child: Card(
            elevation: isDesktop ? 20 : 15,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
            ),
            child: Container(
              padding: EdgeInsets.all(isDesktop ? 48 : 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildWebHeader(isDesktop),
                  SizedBox(height: isDesktop ? 40 : 32),
                  _buildWebForm(isDesktop),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Icon(
            Icons.admin_panel_settings,
            size: 48,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'تسجيل دخول المشرف',
          style: GoogleFonts.cairo(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'يرجى إدخال بيانات الاعتماد للوصول لوحة التحكم',
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMobileForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildEmailField(true),
            const SizedBox(height: 20),
            _buildPasswordField(true),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              _buildErrorMessage(true),
            ],
            const SizedBox(height: 24),
            _buildLoginButton(true),
          ],
        ),
      ),
    );
  }

  Widget _buildWebHeader(bool isDesktop) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(isDesktop ? 16 : 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.security,
            size: isDesktop ? 40 : 32,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: isDesktop ? 24 : 20),
        Text(
          'Admin Access',
          style: GoogleFonts.cairo(
            fontSize: isDesktop ? 28 : 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Authorized Personnel Only',
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: Colors.grey.shade600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildWebForm(bool isDesktop) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildEmailField(false),
          const SizedBox(height: 20),
          _buildPasswordField(false),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            _buildErrorMessage(false),
          ],
          const SizedBox(height: 28),
          _buildLoginButton(false),
          const SizedBox(height: 16),
          _buildSecurityNotice(),
        ],
      ),
    );
  }

  Widget _buildEmailField(bool isMobile) {
    return TextFormField(
      controller: _emailController,
      enabled: !_isLoading,
      decoration: InputDecoration(
        labelText: 'البريد الإلكتروني',
        labelStyle: GoogleFonts.cairo(),
        hintText: 'admin@example.com',
        prefixIcon: Icon(
          Icons.email_outlined,
          color: _isLoading ? Colors.grey.shade400 : Colors.grey.shade600,
          size: isMobile ? 20 : 22,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade700, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: isMobile ? 16 : 18,
        ),
        filled: true,
        fillColor: _isLoading ? Colors.grey.shade100 : Colors.grey.shade50,
      ),
      style: GoogleFonts.cairo(
        color: _isLoading ? Colors.grey.shade500 : Colors.black,
      ),
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء إدخال البريد الإلكتروني';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'البريد الإلكتروني غير صحيح';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(bool isMobile) {
    return TextFormField(
      controller: _passwordController,
      enabled: !_isLoading,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'كلمة المرور',
        labelStyle: GoogleFonts.cairo(),
        hintText: '••••••••',
        prefixIcon: Icon(
          Icons.lock_outlined,
          color: _isLoading ? Colors.grey.shade400 : Colors.grey.shade600,
          size: isMobile ? 20 : 22,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: _isLoading ? Colors.grey.shade400 : Colors.grey.shade600,
            size: isMobile ? 20 : 22,
          ),
          onPressed: _isLoading
              ? null
              : () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade700, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: isMobile ? 16 : 18,
        ),
        filled: true,
        fillColor: _isLoading ? Colors.grey.shade100 : Colors.grey.shade50,
      ),
      style: GoogleFonts.cairo(
        color: _isLoading ? Colors.grey.shade500 : Colors.black,
      ),
      autocorrect: false,
      enableSuggestions: false,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء إدخال كلمة المرور';
        }
        if (value.length < 6) {
          return 'كلمة المرور قصيرة جداً';
        }
        return null;
      },
    );
  }

  Widget _buildErrorMessage(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: GoogleFonts.cairo(
                color: Colors.red.shade800,
                fontSize: isMobile ? 14 : 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(bool isMobile) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _login,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            _isLoading ? Colors.grey.shade400 : Colors.grey.shade800,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey.shade400,
        padding: EdgeInsets.symmetric(
          vertical: isMobile ? 16 : 18,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: _isLoading ? 0 : 2,
      ),
      child: _isLoading
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'جارٍ تسجيل الدخول...',
                  style: GoogleFonts.cairo(
                    fontSize: isMobile ? 16 : 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.login,
                  size: isMobile ? 20 : 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'تسجيل الدخول',
                  style: GoogleFonts.cairo(
                    fontSize: isMobile ? 16 : 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSecurityNotice() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.security,
            color: Colors.amber.shade700,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'الوصول مقيد للمشرفين المعتمدين فقط',
              style: GoogleFonts.cairo(
                color: Colors.amber.shade800,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
