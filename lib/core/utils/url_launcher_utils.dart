import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Utility class for launching URLs and other external applications
class UrlLauncherUtils {
  /// Launch the phone dialer with the specified phone number
  static Future<bool> launchPhoneCall(String phoneNumber) async {
    // Clean the phone number (remove spaces, dashes, etc.)
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[\s-()]'), '');

    final Uri phoneUri = Uri.parse('tel:$cleanNumber');

    try {
      return await launchUrl(phoneUri);
    } catch (e) {
      debugPrint('Error launching phone call: $e');
      return false;
    }
  }

  /// Launch Telegram with the specified username
  static Future<bool> launchTelegram(String username) async {
    // Remove any @ symbol if present
    final cleanUsername = username.startsWith('@') ? username.substring(1) : username;

    final Uri telegramUri = Uri.parse('https://t.me/$cleanUsername');

    try {
      return await launchUrl(
        telegramUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint('Error launching Telegram: $e');
      return false;
    }
  }

  /// Launch WhatsApp with the specified phone number
  static Future<bool> launchWhatsApp(String phoneNumber) async {
    // Clean the phone number (remove spaces, dashes, etc.)
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[\s-+()]'), '');

    final Uri whatsappUri = Uri.parse('https://wa.me/$cleanNumber');

    try {
      return await launchUrl(
        whatsappUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint('Error launching WhatsApp: $e');
      return false;
    }
  }

  /// Launch any URL in the browser
  static Future<bool> launchWebUrl(String url) async {
    // Ensure URL has a scheme (http or https)
    String validUrl = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      validUrl = 'https://$url';
    }

    final Uri webUri = Uri.parse(validUrl);

    try {
      return await launchUrl(
        webUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint('Error launching URL: $e');
      return false;
    }
  }

  /// Handle possible error when launching URLs
  static void handleLaunchError(BuildContext context, String errorType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('لا يمكن فتح $errorType'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}