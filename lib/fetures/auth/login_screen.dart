// // lib/screens/login_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:trustedtallentsvalley/routs/route_generator.dart';
// import 'package:trustedtallentsvalley/fetures/services/auth_service.dart';
//
// class LoginScreen extends ConsumerStatefulWidget {
//   const LoginScreen({Key? key}) : super(key: key);
//
//   @override
//   ConsumerState<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends ConsumerState<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _obscurePassword = true;
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   void _handleLogin() async {
//     if (_formKey.currentState?.validate() ?? false) {
//       final authNotifier = ref.read(authProvider.notifier);
//       await authNotifier.signIn(
//         _emailController.text.trim(),
//         _passwordController.text,
//       );
//
//       // Check if login was successful
//       final authState = ref.read(authProvider);
//       if (authState.isAuthenticated &&
//           !authState.isLoading &&
//           authState.error == null) {
//         if (mounted) {
//           context.go(ScreensNames.homePath);
//         }
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final authState = ref.watch(authProvider);
//     final error = authState.error;
//
//     return Scaffold(
//       body: Center(
//         child: Container(
//           constraints: const BoxConstraints(maxWidth: 400),
//           padding: const EdgeInsets.all(24),
//           child: Card(
//             elevation: 4,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(24),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     Text(
//                       'تسجيل الدخول',
//                       style: GoogleFonts.cairo(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 24),
//                     TextFormField(
//                       controller: _emailController,
//                       decoration: InputDecoration(
//                         labelText: 'البريد الإلكتروني',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         prefixIcon: const Icon(Icons.email),
//                       ),
//                       keyboardType: TextInputType.emailAddress,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'الرجاء إدخال البريد الإلكتروني';
//                         }
//                         if (!value.contains('@')) {
//                           return 'الرجاء إدخال بريد إلكتروني صحيح';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 16),
//                     TextFormField(
//                       controller: _passwordController,
//                       obscureText: _obscurePassword,
//                       decoration: InputDecoration(
//                         labelText: 'كلمة المرور',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         prefixIcon: const Icon(Icons.lock),
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             _obscurePassword
//                                 ? Icons.visibility
//                                 : Icons.visibility_off,
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               _obscurePassword = !_obscurePassword;
//                             });
//                           },
//                         ),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'الرجاء إدخال كلمة المرور';
//                         }
//                         if (value.length < 6) {
//                           return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
//                         }
//                         return null;
//                       },
//                     ),
//                     if (error != null) ...[
//                       const SizedBox(height: 16),
//                       Text(
//                         error,
//                         style: GoogleFonts.cairo(
//                           color: Colors.red,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ],
//                     const SizedBox(height: 24),
//                     ElevatedButton(
//                       onPressed: authState.isLoading ? null : _handleLogin,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blue.shade600,
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       child: authState.isLoading
//                           ? const CircularProgressIndicator()
//                           : Text(
//                               'تسجيل الدخول',
//                               style: GoogleFonts.cairo(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                     ),
//                     const SizedBox(height: 16),
//                     TextButton(
//                       onPressed: () {
//                         context.go(ScreensNames.homePath);
//                       },
//                       child: Text(
//                         'العودة للصفحة الرئيسية',
//                         style: GoogleFonts.cairo(
//                           color: Colors.blue.shade600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
