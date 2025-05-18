import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/features/auth/presentation/providers/auth_provider.dart';
import 'package:trustedtallentsvalley/features/auth/presentation/widgets/login_form.dart';
import 'package:trustedtallentsvalley/routs/route_generator.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Redirect to admin dashboard if already authenticated and is admin
    if (authState.isAuthenticated && authState.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/secure-admin-784512/dashboard');
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تسجيل الدخول',
          style: GoogleFonts.cairo(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.grey.shade800,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LoginForm(
                    isLoading: authState.isLoading,
                    error: authState.error,
                    onLogin: (email, password) {
                      ref.read(authProvider.notifier).signIn(email, password);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      context.go(ScreensNames.homePath);
                    },
                    child: Text(
                      'العودة للصفحة الرئيسية',
                      style: GoogleFonts.cairo(
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
