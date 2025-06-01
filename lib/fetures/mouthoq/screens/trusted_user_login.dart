import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/services/auth_service.dart';

// Enhanced AuthNavigationListener with proper error handling
class AuthNavigationListener extends ConsumerWidget {
  final Widget child;

  const AuthNavigationListener({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to auth state changes
    ref.listen<AuthState>(authProvider, (previous, current) {
      print('🎯 Auth state changed:');
      print(
          '  Previous: isAuth=${previous?.isAuthenticated}, isTrusted=${previous?.isTrustedUser}, error=${previous?.error}');
      print(
          '  Current: isAuth=${current.isAuthenticated}, isTrusted=${current.isTrustedUser}, error=${current.error}');

      // CRITICAL: Do not navigate if there's an error in the current state
      if (current.error != null) {
        print('🎯 ❌ Navigation blocked - error present: ${current.error}');
        return; // Stay on current page when there's an error
      }

      // Only navigate if user successfully became authenticated as trusted user
      if (previous != null &&
          !previous.isAuthenticated &&
          current.isAuthenticated &&
          current.isTrustedUser &&
          !current.isLoading &&
          current.error == null) {
        // Ensure no error exists
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
          !current.isAuthenticated &&
          current.error == null) {
        // Only navigate on logout if no error
        // User logged out successfully
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
        print('  - Has error: ${current.error != null}');

        if (current.error != null) {
          print('🎯 ⚠️ Error present - staying on current page');
        }
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

  // New validation state variables
  String? _emailError;
  String? _passwordError;
  bool _emailTouched = false;
  bool _passwordTouched = false;

  @override
  void initState() {
    super.initState();
    // Add listeners for real-time validation
    _emailController.addListener(_validateEmailRealTime);
    _passwordController.addListener(_validatePasswordRealTime);
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateEmailRealTime);
    _passwordController.removeListener(_validatePasswordRealTime);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Real-time email validation
  void _validateEmailRealTime() {
    if (!_emailTouched) return;

    final email = _emailController.text.trim();
    setState(() {
      if (email.isEmpty) {
        _emailError = 'الرجاء إدخال البريد الإلكتروني';
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        _emailError = 'تنسيق البريد الإلكتروني غير صحيح';
      } else {
        _emailError = null;
      }
    });
  }

  // Real-time password validation
  void _validatePasswordRealTime() {
    if (!_passwordTouched) return;

    final password = _passwordController.text;
    setState(() {
      if (password.isEmpty) {
        _passwordError = 'الرجاء إدخال كلمة المرور';
      } else if (password.length < 6) {
        _passwordError = 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
      } else {
        _passwordError = null;
      }
    });
  }

  // Enhanced form validation
  bool _validateForm() {
    setState(() {
      _emailTouched = true;
      _passwordTouched = true;
    });

    _validateEmailRealTime();
    _validatePasswordRealTime();

    return _formKey.currentState?.validate() ??
        false && _emailError == null && _passwordError == null;
  }

  // Enhanced login method with proper error handling and loading states
  Future<void> _login() async {
    // First validate the form
    if (!_validateForm()) {
      print('🔐 ❌ Form validation failed');
      return;
    }

    // Set loading state immediately and clear any previous errors
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

      // Perform the authentication and wait for completion
      await authNotifier.signInTrustedUser(
          _emailController.text.trim(), _passwordController.text);

      print('🔐 signInTrustedUser method completed');

      // Check if widget is still mounted before proceeding
      if (!mounted) {
        print('🔐 Widget disposed after login attempt');
        return;
      }

      // Get the current auth state after the operation
      final authState = ref.read(authProvider);
      print('🔐 Post-login auth state analysis:');
      print('  - isAuthenticated: ${authState.isAuthenticated}');
      print('  - isTrustedUser: ${authState.isTrustedUser}');
      print('  - isLoading: ${authState.isLoading}');
      print('  - error: ${authState.error}');

      // Handle different scenarios based on auth state
      if (authState.error != null) {
        // There's an authentication error - STAY ON LOGIN PAGE
        print('🔐 ❌ Authentication error detected: ${authState.error}');
        print('🔐 🔒 STAYING ON LOGIN PAGE due to error');
        setState(() {
          _errorMessage = authState.error!;
          _isLoading = false;
        });
        return; // Critical: Exit here to prevent any navigation
      }

      if (!authState.isAuthenticated) {
        // User is not authenticated at all - STAY ON LOGIN PAGE
        print('🔐 ❌ User not authenticated');
        print('🔐 🔒 STAYING ON LOGIN PAGE due to failed authentication');
        setState(() {
          _errorMessage = 'فشل في تسجيل الدخول. تحقق من بيانات الاعتماد.';
          _isLoading = false;
        });
        return; // Critical: Exit here to prevent any navigation
      }

      if (authState.isAuthenticated && !authState.isTrustedUser) {
        // User is authenticated but not a trusted user - STAY ON LOGIN PAGE
        print('🔐 ❌ User authenticated but not trusted');
        print('🔐 🔒 STAYING ON LOGIN PAGE - signing out non-trusted user');
        setState(() {
          _errorMessage =
              'هذا الحساب غير مخول للدخول إلى هذا القسم. يجب أن تكون مستخدماً موثوقاً.';
          _isLoading = false;
        });

        // Sign out the non-trusted user to prevent access
        try {
          await authNotifier.signOut();
          print('🔐 Non-trusted user signed out successfully');
        } catch (signOutError) {
          print('🔐 Error signing out non-trusted user: $signOutError');
        }
        return; // Critical: Exit here to prevent any navigation
      }

      if (authState.isAuthenticated && authState.isTrustedUser) {
        // Perfect! User is both authenticated and trusted
        print('🔐 ✅ Login successful - user is authenticated and trusted');
        print('🔐 🎯 NAVIGATION ALLOWED - proceeding to dashboard');

        setState(() {
          _isLoading = false;
        });

        // Navigate to dashboard only for successful trusted user login
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              print('🔐 🚀 Navigating to trusted dashboard');
              context
                  .pushReplacement('/secure-trusted-895623/trusted-dashboard');
              print('🔐 ✅ Navigation completed successfully');
            }
          });
        }
        return;
      }

      // Fallback case - something unexpected happened - STAY ON LOGIN PAGE
      print('🔐 ⚠️ Unexpected auth state after login');
      print('🔐 🔒 STAYING ON LOGIN PAGE due to unexpected state');
      setState(() {
        _errorMessage = 'حدث خطأ غير متوقع. حاول مرة أخرى.';
        _isLoading = false;
      });
    } catch (e) {
      print('🔐 ❌ CRITICAL LOGIN ERROR: $e');
      print('🔐 Error type: ${e.runtimeType}');
      print('🔐 🔒 STAYING ON LOGIN PAGE due to exception');

      // Only handle errors if widget is still mounted
      if (mounted) {
        String errorMessage;

        // Parse different types of errors for better user experience
        if (e.toString().contains('لم يتم العثور على طلب تسجيل')) {
          errorMessage =
              'لم يتم العثور على طلب تسجيل بهذا البريد الإلكتروني. تأكد من تسجيلك أولاً.';
        } else if (e.toString().contains('wrong-password') ||
            e.toString().contains('user-not-found')) {
          errorMessage = 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
        } else if (e.toString().contains('too-many-requests')) {
          errorMessage =
              'تم تجاوز عدد المحاولات المسموح. حاول مرة أخرى لاحقاً.';
        } else if (e.toString().contains('network-request-failed')) {
          errorMessage =
              'خطأ في الاتصال بالإنترنت. تحقق من اتصالك وحاول مرة أخرى.';
        } else {
          errorMessage = 'حدث خطأ أثناء تسجيل الدخول. حاول مرة أخرى.';
        }

        setState(() {
          _errorMessage = errorMessage;
          _isLoading = false;
        });

        // Ensure user is signed out on error to prevent any auth confusion
        try {
          final authNotifier = ref.read(authProvider.notifier);
          await authNotifier.signOut();
          print('🔐 User signed out after error to ensure clean state');
        } catch (signOutError) {
          print('🔐 Error during cleanup signout: $signOutError');
        }
      } else {
        print('🔐 Widget disposed during error handling');
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
      body: Stack(
        children: [
          // Main content
          isMobile
              ? _buildMobileLayout(context)
              : _buildWebLayout(context, isDesktop),

          // Full-screen loading overlay
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  // Full-screen loading overlay
  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                strokeWidth: 3,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              Text(
                'جارٍ التحقق من بيانات المستخدم...',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'يرجى الانتظار',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
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
            maxHeight:
                isDesktop ? 800 : 750, // Increased height for enhanced form
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
                    _buildWebHeader(isDesktop),
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

  // Enhanced email field with error hints
  Widget _buildEmailField(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _emailController,
          onTap: () {
            setState(() {
              _emailTouched = true;
            });
          },
          onChanged: (value) {
            if (!_emailTouched) {
              setState(() {
                _emailTouched = true;
              });
            }
          },
          decoration: InputDecoration(
            labelText: 'البريد الإلكتروني',
            labelStyle: GoogleFonts.cairo(),
            hintText: 'trusted@example.com',
            prefixIcon: Icon(
              Icons.email_outlined,
              color: _emailError != null
                  ? Colors.red.shade600
                  : Colors.blue.shade600,
              size: isMobile ? 20 : 22,
            ),
            suffixIcon: _emailTouched
                ? Icon(
                    _emailError == null ? Icons.check_circle : Icons.error,
                    color: _emailError == null ? Colors.green : Colors.red,
                    size: 20,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _emailError != null
                    ? Colors.red.shade300
                    : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _emailError != null
                    ? Colors.red.shade700
                    : Colors.blue.shade700,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red.shade700, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red.shade700, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: isMobile ? 16 : 18,
            ),
            filled: true,
            fillColor:
                _emailError != null ? Colors.red.shade50 : Colors.grey.shade50,
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
        ),
        // Email error hint
        if (_emailError != null && _emailTouched) ...[
          const SizedBox(height: 6),
          _buildFieldErrorHint(_emailError!, isMobile),
        ],
        // Email success hint
        if (_emailError == null &&
            _emailTouched &&
            _emailController.text.isNotEmpty) ...[
          const SizedBox(height: 6),
          _buildFieldSuccessHint('البريد الإلكتروني صحيح', isMobile),
        ],
      ],
    );
  }

  // Enhanced password field with error hints
  Widget _buildPasswordField(bool isMobile) {
    final password = _passwordController.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          onTap: () {
            setState(() {
              _passwordTouched = true;
            });
          },
          onChanged: (value) {
            if (!_passwordTouched) {
              setState(() {
                _passwordTouched = true;
              });
            }
          },
          decoration: InputDecoration(
            labelText: 'كلمة المرور',
            labelStyle: GoogleFonts.cairo(),
            hintText: '••••••••',
            prefixIcon: Icon(
              Icons.lock_outlined,
              color: _passwordError != null
                  ? Colors.red.shade600
                  : Colors.blue.shade600,
              size: isMobile ? 20 : 22,
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_passwordTouched)
                  Icon(
                    _passwordError == null ? Icons.check_circle : Icons.error,
                    color: _passwordError == null ? Colors.green : Colors.red,
                    size: 20,
                  ),
                const SizedBox(width: 8),
                IconButton(
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
              ],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _passwordError != null
                    ? Colors.red.shade300
                    : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _passwordError != null
                    ? Colors.red.shade700
                    : Colors.blue.shade700,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red.shade700, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red.shade700, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: isMobile ? 16 : 18,
            ),
            filled: true,
            fillColor: _passwordError != null
                ? Colors.red.shade50
                : Colors.grey.shade50,
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
        ),
        // Password error hint
        if (_passwordError != null && _passwordTouched) ...[
          const SizedBox(height: 6),
          _buildFieldErrorHint(_passwordError!, isMobile),
        ],
        // Password success hint
        if (_passwordError == null &&
            _passwordTouched &&
            password.isNotEmpty) ...[
          const SizedBox(height: 6),
          _buildFieldSuccessHint('كلمة المرور صحيحة', isMobile),
        ],
        // Password strength indicators (when user is typing)
        if (_passwordTouched && password.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildPasswordStrengthIndicator(password, isMobile),
        ],
      ],
    );
  }

  // Field error hint widget
  Widget _buildFieldErrorHint(String message, bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.red.shade200, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade700,
            size: 16,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.cairo(
                color: Colors.red.shade800,
                fontSize: isMobile ? 12 : 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Field success hint widget
  Widget _buildFieldSuccessHint(String message, bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.green.shade200, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Colors.green.shade700,
            size: 16,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.cairo(
                color: Colors.green.shade800,
                fontSize: isMobile ? 12 : 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Password strength indicator
  Widget _buildPasswordStrengthIndicator(String password, bool isMobile) {
    final hasMinLength = password.length >= 6;
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasNumbers = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChars =
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    final strength = [
      hasMinLength,
      hasUppercase,
      hasLowercase,
      hasNumbers,
      hasSpecialChars
    ].where((criteria) => criteria).length;

    Color strengthColor;
    String strengthText;
    if (strength <= 2) {
      strengthColor = Colors.red;
      strengthText = 'ضعيفة';
    } else if (strength <= 3) {
      strengthColor = Colors.orange;
      strengthText = 'متوسطة';
    } else {
      strengthColor = Colors.green;
      strengthText = 'قوية';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'قوة كلمة المرور: ',
              style: GoogleFonts.cairo(
                fontSize: isMobile ? 12 : 11,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              strengthText,
              style: GoogleFonts.cairo(
                fontSize: isMobile ? 12 : 11,
                color: strengthColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: strength / 5,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            _buildStrengthCriteria('6+ أحرف', hasMinLength, isMobile),
            _buildStrengthCriteria('حروف كبيرة', hasUppercase, isMobile),
            _buildStrengthCriteria('حروف صغيرة', hasLowercase, isMobile),
            _buildStrengthCriteria('أرقام', hasNumbers, isMobile),
            _buildStrengthCriteria('رموز خاصة', hasSpecialChars, isMobile),
          ],
        ),
      ],
    );
  }

  // Individual strength criteria widget
  Widget _buildStrengthCriteria(String text, bool met, bool isMobile) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          met ? Icons.check_circle : Icons.circle_outlined,
          size: 12,
          color: met ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.cairo(
            fontSize: isMobile ? 10 : 9,
            color: met ? Colors.green : Colors.grey,
            fontWeight: met ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // Enhanced error message for login failures
  Widget _buildErrorMessage(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'تأكد من صحة البريد الإلكتروني وكلمة المرور المدخلة',
            style: GoogleFonts.cairo(
              color: Colors.red.shade700,
              fontSize: isMobile ? 12 : 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(bool isMobile) {
    return ElevatedButton(
      onPressed:
          (_isLoading) ? null : _login, // Disable completely when loading
      style: ElevatedButton.styleFrom(
        backgroundColor:
            _isLoading ? Colors.grey.shade400 : Colors.blue.shade800,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey.shade400,
        disabledForegroundColor: Colors.grey.shade600,
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
                  'جارٍ التحقق من البيانات...',
                  style: GoogleFonts.cairo(
                    fontSize: isMobile ? 16 : 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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

  // Debug helper methods
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
