import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trustedtallentsvalley/config/error_handelr.dart';
import 'package:trustedtallentsvalley/config/error_msg_widget.dart';
import 'package:trustedtallentsvalley/fetures/auth/admin/providers/auth_provider_admin.dart';
import 'package:trustedtallentsvalley/fetures/auth/admin/states/auth_state_admin.dart';
import 'package:trustedtallentsvalley/fetures/auth/admin/widgets/action_button.dart';
import 'package:trustedtallentsvalley/fetures/auth/admin/widgets/app_bar_widget.dart';
import 'package:trustedtallentsvalley/fetures/auth/admin/widgets/email_field.dart';
import 'package:trustedtallentsvalley/fetures/auth/admin/widgets/initial_loading_screen.dart';
import 'package:trustedtallentsvalley/fetures/auth/admin/widgets/mobile_layout.dart';
import 'package:trustedtallentsvalley/fetures/auth/admin/widgets/password_field.dart';
import 'package:trustedtallentsvalley/fetures/auth/admin/widgets/security_notice.dart';
import 'package:trustedtallentsvalley/fetures/auth/admin/widgets/show_success_dialog.dart';
import 'package:trustedtallentsvalley/fetures/auth/admin/widgets/web_form.dart';
import 'package:trustedtallentsvalley/fetures/auth/admin/widgets/web_header.dart';
import 'package:trustedtallentsvalley/fetures/auth/admin/widgets/web_layout.dart';

class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isInitialLoading = true;

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
    // Give the auth provider time to initialize
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

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

  Future<void> _handleAdminLogin() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final authNotifier = ref.read(authProvider.notifier);

      // Use the signIn method for admin login
      await authNotifier.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // Check if we're still mounted and the login was successful
      if (mounted) {
        final authState = ref.read(authProvider);

        if (authState.isAuthenticated && authState.isAdmin) {
          SuccessDialog.show(
            context,
            title: 'تم تسجيل الدخول بنجاح',
            subtitle: 'جاري التوجيه إلى لوحة التحكم...',
          );

          // Navigate after showing success
          await Future.delayed(const Duration(milliseconds: 1500));
          if (mounted) {
            context.go('/');
          }
        }
      }
    } catch (e) {
      // Error handling is managed by AuthNotifier through error state
      // The error will be displayed through the authState.error
      print('Admin login error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the auth state for reactive updates
    final authState = ref.watch(authProvider);

    if (_isInitialLoading) {
      return const InitialLoadingScreen(
        loadingText: 'جاري التحقق من حالة تسجيل الدخول...',
        icon: Icons.admin_panel_settings,
      );
    }

    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;
    final isDesktop = size.width >= 1024;

    return Scaffold(
      appBar: CustomAppBar(
        isMobile: isMobile,
        title: 'تسجيل دخول المشرف',
      ),
      body: isMobile
          ? _buildMobileLayout(authState)
          : _buildWebLayout(isDesktop, authState),
    );
  }

  Widget _buildMobileLayout(AuthState authState) {
    return MobileLayout(
      authState: authState,
      formKey: _formKey,
      title: 'تسجيل دخول المشرف',
      subtitle: 'يرجى إدخال بيانات الاعتماد للوصول لوحة التحكم',
      headerIcon: Icons.admin_panel_settings,
      buildEmailField: (isMobile, isLoading) => EmailField(
        controller: _emailController,
        isMobile: isMobile,
        isLoading: isLoading,
        labelText: 'البريد الإلكتروني',
        hintText: 'admin@example.com',
      ),
      buildPasswordField: (isMobile, isLoading) => PasswordField(
        controller: _passwordController,
        isMobile: isMobile,
        isLoading: isLoading,
        labelText: 'كلمة المرور',
      ),
      buildErrorMessage: (isMobile, error) => ErrorMessageWidget(
        errorMessage: error,
        isMobile: isMobile,
        errorTranslator: ErrorMessageHandler.getDisplayError,
      ),
      buildLoginButton: (isMobile, isLoading) => ActionButton(
        isMobile: isMobile,
        isLoading: isLoading,
        onPressed: _handleAdminLogin,
        loginText: 'تسجيل الدخول',
        loadingText: 'جارٍ تسجيل الدخول...',
        loginIcon: Icons.login,
      ),
    );
  }

  Widget _buildWebLayout(bool isDesktop, AuthState authState) {
    return WebLayout.admin(
      isDesktop: isDesktop,
      authState: authState,
      header: WebHeader.arabic(
        isDesktop: isDesktop,
        title: 'دخول المشرف',
        subtitle: 'للمشرفين المعتمدين فقط',
      ),
      form: WebForm(
        isDesktop: isDesktop,
        authState: authState,
        formKey: _formKey,
        buildEmailField: (isMobile, isLoading) => EmailField(
          controller: _emailController,
          isMobile: isMobile,
          isLoading: isLoading,
          labelText: 'البريد الإلكتروني',
          hintText: 'admin@example.com',
        ),
        buildPasswordField: (isMobile, isLoading) => PasswordField(
          controller: _passwordController,
          isMobile: isMobile,
          isLoading: isLoading,
          labelText: 'كلمة المرور',
        ),
        buildErrorMessage: (isMobile, error) => ErrorMessageWidget(
          errorMessage: error,
          isMobile: isMobile,
          errorTranslator: ErrorMessageHandler.getDisplayError,
        ),
        buildLoginButton: (isMobile, isLoading) => ActionButton(
          isMobile: isMobile,
          isLoading: isLoading,
          onPressed: _handleAdminLogin,
          loginText: 'تسجيل الدخول',
          loadingText: 'جارٍ تسجيل الدخول...',
          loginIcon: Icons.admin_panel_settings,
        ),
        buildSecurityNotice: () => const SecurityNotice(
          message: 'الوصول مقيد للمشرفين المعتمدين فقط',
          icon: Icons.security,
        ),
      ),
    );
  }
}
