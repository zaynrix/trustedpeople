import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/services/auth_service.dart';

// Fixed AuthNavigationListener - Replace in your login screen
class AuthNavigationListener extends ConsumerWidget {
  final Widget child;

  const AuthNavigationListener({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to auth state changes
    ref.listen<AuthState>(authProvider, (previous, current) {
      print('🎯 Auth state changed:');
      print(
          '  Previous: isAuth=${previous?.isAuthenticated}, isTrusted=${previous?.isTrustedUser}');
      print(
          '  Current: isAuth=${current.isAuthenticated}, isTrusted=${current.isTrustedUser}');

      // Only navigate if user just became authenticated as trusted user
      if (previous != null &&
          !previous.isAuthenticated &&
          current.isAuthenticated &&
          current.isTrustedUser &&
          !current.isLoading) {
        print(
            '🎯 User just authenticated as trusted user - scheduling navigation');

        // Use addPostFrameCallback to ensure navigation happens after build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            if (context.mounted) {
              final currentRoute = GoRouterState.of(context).uri.toString();
              print('🎯 Current route before navigation: $currentRoute');

              // Only navigate if we're on the login page
              if (currentRoute == '/secure-trusted-895623/login') {
                print('🎯 🚀 Navigating to dashboard...');

                // Use pushReplacement to prevent back navigation to login
                context.pushReplacement(
                    '/secure-trusted-895623/trusted-dashboard');

                print('🎯 ✅ Navigation to dashboard completed');
              } else {
                print('🎯 ⚠️ Not on login page, skipping navigation');
              }
            } else {
              print('🎯 ❌ Context not mounted, skipping navigation');
            }
          } catch (e) {
            print('🎯 ❌ Navigation error: $e');
            // Fallback: try using go instead of pushReplacement
            try {
              if (context.mounted) {
                context.go('/secure-trusted-895623/trusted-dashboard');
                print('🎯 ✅ Fallback navigation successful');
              }
            } catch (fallbackError) {
              print('🎯 ❌ Fallback navigation also failed: $fallbackError');
            }
          }
        });
      } else if (previous != null &&
          previous.isAuthenticated &&
          !current.isAuthenticated) {
        // User logged out
        print('🎯 User logged out');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            context.go('/secure-trusted-895623/login');
          }
        });
      } else {
        print('🎯 No navigation needed:');
        print('  - Previous null: ${previous == null}');
        print('  - Was authenticated: ${previous?.isAuthenticated ?? false}');
        print('  - Is authenticated: ${current.isAuthenticated}');
        print('  - Is trusted: ${current.isTrustedUser}');
        print('  - Is loading: ${current.isLoading}');
      }
    });

    return child;
  }
}

class TrustedUserLoginScreen extends ConsumerStatefulWidget {
  const TrustedUserLoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TrustedUserLoginScreen> createState() =>
      _TrustedUserLoginScreenState();
}

class _TrustedUserLoginScreenState
    extends ConsumerState<TrustedUserLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

// Replace your _login method in TrustedUserLoginScreen with this:
  Future<void> _login() async {
    // context.pushReplacement('/secure-trusted-895623/trusted-dashboard');

    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        print('🔐 ========================================');
        print('🔐 LOGIN SCREEN: Starting login process');
        print('🔐 ========================================');
        print('🔐 Email: ${_emailController.text.trim()}');

        final authNotifier = ref.read(authProvider.notifier);

        // Perform the authentication
        await authNotifier.signInTrustedUser(
            _emailController.text.trim(), _passwordController.text);

        print('🔐 signInTrustedUser completed');

        // Check if widget is still mounted before proceeding
        if (!mounted) {
          print('🔐 Widget disposed after login attempt');
          return;
        }

        // Check the auth state after login
        final authState = ref.read(authProvider);
        print('🔐 Post-login auth state:');
        print('  - isAuthenticated: ${authState.isAuthenticated}');
        print('  - isTrustedUser: ${authState.isTrustedUser}');
        print('  - isLoading: ${authState.isLoading}');
        print('  - error: ${authState.error}');

        // Check for auth errors
        if (authState.error != null) {
          throw Exception(authState.error);
        }

        // If authentication was successful, navigate immediately
        if (authState.isAuthenticated) {
          print('🔐 ✅ Login successful - navigating to dashboard');

          // Update UI state
          setState(() {
            _isLoading = false;
          });

          // Navigate to dashboard immediately (don't rely only on listener)
          if (mounted) {
            // Use a small delay to ensure the state is fully updated
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                print('🔐 🚀 Direct navigation to dashboard');
                context.pushReplacement(
                    '/secure-trusted-895623/trusted-dashboard');
                print('🔐 ✅ Direct navigation completed');
              }
            });
          }
        } else {
          // Authentication failed
          setState(() {
            _errorMessage = 'فشل في تسجيل الدخول. تحقق من بيانات الاعتماد.';
            _isLoading = false;
          });
        }
      } catch (e) {
        print('🔐 ❌ LOGIN ERROR: $e');

        // Only handle errors if widget is still mounted
        if (mounted) {
          setState(() {
            _errorMessage = 'حدث خطأ أثناء تسجيل الدخول: ${e.toString()}';
            _isLoading = false;
          });
        } else {
          print('🔐 Widget disposed during error handling');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;
    final isTablet = size.width >= 768 && size.width < 1024;
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
          'تسجيل دخول الموثوق',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
        centerTitle: true,
      );
    } else {
      return AppBar(
        backgroundColor: Colors.blue.shade900,
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
              _buildNavigationLinks(),
              if (kDebugMode) ...[
                const SizedBox(height: 20),
                _buildDebugSection(),
              ],
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
            Colors.blue.shade900,
            Colors.blue.shade800,
            Colors.blue.shade700,
          ],
        ),
      ),
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 450 : 400,
            maxHeight: isDesktop ? 650 : 600,
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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // _buildWebHeader(isDesktop),
                    SizedBox(height: isDesktop ? 40 : 32),
                    _buildWebForm(isDesktop),
                    const SizedBox(height: 20),
                    _buildNavigationLinks(),
                    if (kDebugMode) ...[
                      const SizedBox(height: 20),
                      _buildDebugSection(),
                    ],
                  ],
                ),
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
            color: Colors.blue.shade100,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.blue.shade300,
              width: 2,
            ),
          ),
          child: Icon(
            Icons.verified_user,
            size: 48,
            color: Colors.blue.shade700,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'تسجيل دخول الموثوق',
          style: GoogleFonts.cairo(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'أدخل بيانات اعتمادك للوصول إلى حسابك',
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildWebHeader(bool isDesktop) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(isDesktop ? 16 : 12),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.verified_user,
            size: isDesktop ? 40 : 32,
            color: Colors.blue.shade700,
          ),
        ),
        SizedBox(height: isDesktop ? 24 : 20),
        Text(
          'Trusted User Login',
          style: GoogleFonts.cairo(
            fontSize: isDesktop ? 28 : 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'المستخدمين الموثوقين فقط',
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: Colors.grey.shade600,
            letterSpacing: 0.5,
          ),
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
      child: _buildFormContent(true),
    );
  }

  Widget _buildWebForm(bool isDesktop) {
    return _buildFormContent(false);
  }

  Widget _buildFormContent(bool isMobile) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildEmailField(isMobile),
          const SizedBox(height: 20),
          _buildPasswordField(isMobile),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            _buildErrorMessage(isMobile),
          ],
          const SizedBox(height: 24),
          _buildLoginButton(isMobile),
          const SizedBox(height: 16),
          _buildSecurityNotice(),
        ],
      ),
    );
  }

  Widget _buildEmailField(bool isMobile) {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: 'البريد الإلكتروني',
        labelStyle: GoogleFonts.cairo(),
        hintText: 'trusted@example.com',
        prefixIcon: Icon(
          Icons.email_outlined,
          color: Colors.blue.shade600,
          size: isMobile ? 20 : 22,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: isMobile ? 16 : 18,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      style: GoogleFonts.cairo(),
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
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'كلمة المرور',
        labelStyle: GoogleFonts.cairo(),
        hintText: '••••••••',
        prefixIcon: Icon(
          Icons.lock_outlined,
          color: Colors.blue.shade600,
          size: isMobile ? 20 : 22,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.blue.shade600,
            size: isMobile ? 20 : 22,
          ),
          onPressed: () {
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
          borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: isMobile ? 16 : 18,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      style: GoogleFonts.cairo(),
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
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey.shade400,
        padding: EdgeInsets.symmetric(
          vertical: isMobile ? 16 : 18,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
      ),
      child: _isLoading
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
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
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.verified_user,
            color: Colors.blue.shade700,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'الوصول للمستخدمين الموثوقين فقط',
              style: GoogleFonts.cairo(
                color: Colors.blue.shade800,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

// Enhanced debug section for your trusted user login screen
// Update your debug section to include the fix methods
  Widget _buildDebugSection() {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 10),
        Text(
          'Debug Section - Trusted User Login Testing',
          style: GoogleFonts.cairo(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),

        // PROBLEM IDENTIFIED SECTION
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '⚠️ مشكلة محددة: المستخدم موجود في Firestore لكن غير موجود في Firebase Auth',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _fixExistingUser(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        'إصلاح المستخدم الحالي',
                        style: GoogleFonts.cairo(fontSize: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _createFreshUser(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        'إنشاء مستخدم جديد',
                        style: GoogleFonts.cairo(fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Step 1: Check what exists
        Container(
          width: double.infinity,
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
                'الخطوة 1: فحص النظام',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _listAllUsers(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        'عرض جميع المستخدمين',
                        style: GoogleFonts.cairo(fontSize: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _checkCurrentEmail(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        'فحص البريد المدخل',
                        style: GoogleFonts.cairo(fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Step 2: Test login
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الخطوة 2: اختبار تسجيل الدخول',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _testFixedUserLogin(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        'تسجيل دخول (المستخدم المُصلح)',
                        style: GoogleFonts.cairo(fontSize: 9),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _testFreshUserLogin(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        'تسجيل دخول (المستخدم الجديد)',
                        style: GoogleFonts.cairo(fontSize: 9),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

// Add these methods to your login screen class
  Future<void> _fixExistingUser() async {
    try {
      final authNotifier = ref.read(authProvider.notifier);
      await authNotifier.fixAndCreateTrustedUser();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم إصلاح المستخدم!\nالبريد: trusteduser@example.com\nكلمة المرور: 123456',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      print('Error fixing user: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('خطأ في إصلاح المستخدم: $e', style: GoogleFonts.cairo()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createFreshUser() async {
    try {
      final authNotifier = ref.read(authProvider.notifier);
      await authNotifier.createFreshTrustedUser();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم إنشاء مستخدم جديد!\nالبريد: newtrusteduser@example.com\nكلمة المرور: 123456',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      print('Error creating fresh user: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في إنشاء المستخدم الجديد: $e',
                style: GoogleFonts.cairo()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _testFixedUserLogin() async {
    _emailController.text = 'trusteduser@example.com';
    _passwordController.text = '123456';
    await _login();
  }

  Future<void> _testFreshUserLogin() async {
    _emailController.text = 'newtrusteduser@example.com';
    _passwordController.text = '123456';
    await _login();
  }

// Keep your existing debug methods
  Future<void> _listAllUsers() async {
    try {
      final authNotifier = ref.read(authProvider.notifier);
      await authNotifier.debugListAllUsers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم عرض جميع المستخدمين - راجع وحدة التحكم',
                style: GoogleFonts.cairo()),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      print('Error listing users: $e');
    }
  }

  Future<void> _checkCurrentEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('أدخل بريد إلكتروني أولاً', style: GoogleFonts.cairo()),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final authNotifier = ref.read(authProvider.notifier);
      final results = await authNotifier.checkEmailEverywhere(email);

      String message = 'فحص $email:\n';
      message +=
          'Firebase Auth: ${results['firebase_auth'] == true ? '✅' : '❌'}\n';
      message +=
          'مجموعة الإدارة: ${results['admins_collection'] == true ? '✅' : '❌'}\n';
      message +=
          'مجموعة المستخدمين: ${results['users_collection'] == true ? '✅' : '❌'}\n';
      message +=
          'طلبات التسجيل: ${results['user_applications'] == true ? '✅' : '❌'}';

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('نتائج الفحص', style: GoogleFonts.cairo()),
            content: Text(message, style: GoogleFonts.cairo()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('حسناً', style: GoogleFonts.cairo()),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Error checking email: $e');
    }
  }

  Widget _buildNavigationLinks() {
    return Column(
      children: [
        // Register link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'لا تملك حساب؟ ',
              style: GoogleFonts.cairo(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/secure-trusted-895623/register'),
              child: Text(
                'سجل الآن',
                style: GoogleFonts.cairo(
                  color: Colors.blue.shade700,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        // Status check link
        TextButton(
          onPressed: () => context.go('/application-status'),
          child: Text(
            'تحقق من حالة طلبك',
            style: GoogleFonts.cairo(
              color: Colors.blue.shade600,
              fontSize: 14,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
