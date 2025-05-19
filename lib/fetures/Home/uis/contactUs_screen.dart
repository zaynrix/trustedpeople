import 'dart:convert';
import 'dart:js' as js;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:trustedtallentsvalley/core/widgets/app_drawer.dart';
import 'package:trustedtallentsvalley/fetures/Home/uis/trusted_screen.dart';
import 'package:trustedtallentsvalley/services/auth_service.dart';

// BlockedUser model
class BlockedUser {
  final String id;
  final String ip;
  final String userAgent;
  final String reason;
  final DateTime blockedAt;
  final String blockedBy;
  final String userEmail; // Optional - if available

  BlockedUser({
    required this.id,
    required this.ip,
    required this.userAgent,
    required this.reason,
    required this.blockedAt,
    required this.blockedBy,
    this.userEmail = '',
  });

  factory BlockedUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BlockedUser(
      id: doc.id,
      ip: data['ip'] ?? '',
      userAgent: data['userAgent'] ?? '',
      reason: data['reason'] ?? '',
      blockedAt: (data['blockedAt'] as Timestamp).toDate(),
      blockedBy: data['blockedBy'] ?? '',
      userEmail: data['userEmail'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ip': ip,
      'userAgent': userAgent,
      'reason': reason,
      'blockedAt': Timestamp.fromDate(blockedAt),
      'blockedBy': blockedBy,
      'userEmail': userEmail,
    };
  }
}

// Enhanced ContactMessage model with metadata
class ContactMessage {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String subject;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic> metadata; // New field for security metadata

  ContactMessage({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.subject,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.metadata = const {},
  });

  factory ContactMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ContactMessage(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      subject: data['subject'] ?? '',
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
      metadata: data['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'subject': subject,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'metadata': metadata,
    };
  }
}

// In your ContactUsScreen class, add this method to collect metadata
Future<Map<String, dynamic>> _collectUserMetadata() async {
  Map<String, dynamic> metadata = {
    'timestamp': DateTime.now().toIso8601String(),
    'platform': kIsWeb ? 'web' : defaultTargetPlatform.toString(),
  };

  try {
    // Get IP and location information using a free API
    final ipResponse = await http.get(Uri.parse('https://ipapi.co/json/'));
    if (ipResponse.statusCode == 200) {
      final ipData = json.decode(ipResponse.body);
      metadata['ip'] = ipData['ip'];
      metadata['city'] = ipData['city'];
      metadata['region'] = ipData['region'];
      metadata['country'] = ipData['country_name'];
      metadata['isp'] = ipData['org'];
    }

    // Get browser and device information
    if (kIsWeb) {
      // Browser-specific information
      metadata['userAgent'] = js.context['navigator']['userAgent'];
      metadata['language'] = js.context['navigator']['language'];

      // Screen information
      metadata['screenWidth'] = js.context['screen']['width'];
      metadata['screenHeight'] = js.context['screen']['height'];

      // Browser name and version
      String userAgent =
          js.context['navigator']['userAgent'].toString().toLowerCase();
      if (userAgent.contains('firefox')) {
        metadata['browser'] = 'Firefox';
      } else if (userAgent.contains('chrome') && !userAgent.contains('edge')) {
        metadata['browser'] = 'Chrome';
      } else if (userAgent.contains('safari') &&
          !userAgent.contains('chrome')) {
        metadata['browser'] = 'Safari';
      } else if (userAgent.contains('edge')) {
        metadata['browser'] = 'Edge';
      } else {
        metadata['browser'] = 'Other';
      }
    } else {
      // Mobile device information
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

      if (defaultTargetPlatform == TargetPlatform.android) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        metadata['device'] = androidInfo.model;
        metadata['brand'] = androidInfo.brand;
        metadata['androidVersion'] = androidInfo.version.release;
        metadata['sdkVersion'] = androidInfo.version.sdkInt.toString();
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        metadata['device'] = iosInfo.model;
        metadata['systemName'] = iosInfo.systemName;
        metadata['systemVersion'] = iosInfo.systemVersion;
      }

      // Get app version
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      metadata['appVersion'] = packageInfo.version;
      metadata['buildNumber'] = packageInfo.buildNumber;
    }

    // Add request timestamp and unique ID
    metadata['requestId'] = DateTime.now().millisecondsSinceEpoch.toString();
  } catch (e) {
    // If there's an error, still include basic info
    metadata['metadataError'] = e.toString();
  }

  return metadata;
}

// Provider for admin to view contact messages
final contactMessagesProvider = StreamProvider<List<ContactMessage>>((ref) {
  return FirebaseFirestore.instance
      .collection('contactMessages')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => ContactMessage.fromFirestore(doc))
          .toList());
});

// Provider for unread message count (for notifications)
final unreadMessagesCountProvider = StreamProvider<int>((ref) {
  return FirebaseFirestore.instance
      .collection('contactMessages')
      .where('isRead', isEqualTo: false)
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
});

class ContactUsScreen extends ConsumerStatefulWidget {
  const ContactUsScreen({Key? key}) : super(key: key);

  @override
  _ContactUsScreenState createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends ConsumerState<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final subjectController = TextEditingController();
  final messageController = TextEditingController();
  bool _isSubmitting = false;
  bool _showSuccessMessage = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    subjectController.dispose();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(isAdminProvider);
    final size = MediaQuery.of(context).size;
    final isMobile = size.width <= 768;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: isMobile,
        backgroundColor: isAdmin ? Colors.green.shade700 : Colors.teal,
        title: Text(
          'تواصل معنا',
          style: GoogleFonts.cairo(
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      drawer: isMobile ? const AppDrawer() : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show permanent drawer on larger screens
              if (constraints.maxWidth > 768)
                const AppDrawer(isPermanent: true),

              // Main content area
              Expanded(
                child: isAdmin ? _buildAdminView() : _buildContactForm(context),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContactForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Colors.teal.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.contact_support,
                  size: 40,
                  color: Colors.teal.shade700,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تواصل معنا',
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade700,
                        ),
                      ),
                      Text(
                        'يمكنك التواصل معنا عبر تعبئة النموذج أدناه وسنقوم بالرد عليك في أقرب وقت ممكن',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: Colors.teal.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Success message
          if (_showSuccessMessage)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.only(bottom: 24.0),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'تم إرسال رسالتك بنجاح! سنقوم بالرد عليك في أقرب وقت ممكن.',
                      style: GoogleFonts.cairo(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _showSuccessMessage = false;
                      });
                    },
                    color: Colors.green.shade700,
                  )
                ],
              ),
            ),

          // Contact form
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'نموذج التواصل',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Name field
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'الاسم',
                        labelStyle: GoogleFonts.cairo(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      style: GoogleFonts.cairo(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال الاسم';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email field
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'البريد الإلكتروني',
                        labelStyle: GoogleFonts.cairo(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      style: GoogleFonts.cairo(),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال البريد الإلكتروني';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'الرجاء إدخال بريد إلكتروني صحيح';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Phone field
                    TextFormField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: 'رقم الجوال',
                        labelStyle: GoogleFonts.cairo(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.phone_outlined),
                      ),
                      style: GoogleFonts.cairo(),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    // Subject field
                    TextFormField(
                      controller: subjectController,
                      decoration: InputDecoration(
                        labelText: 'الموضوع',
                        labelStyle: GoogleFonts.cairo(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.subject),
                      ),
                      style: GoogleFonts.cairo(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال الموضوع';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Message field
                    TextFormField(
                      controller: messageController,
                      decoration: InputDecoration(
                        labelText: 'الرسالة',
                        labelStyle: GoogleFonts.cairo(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignLabelWithHint: true,
                      ),
                      style: GoogleFonts.cairo(),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال الرسالة';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isSubmitting
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : Text(
                                'إرسال',
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminView() {
    final messagesAsync = ref.watch(contactMessagesProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Admin header
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  size: 32,
                  color: Colors.green.shade700,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إدارة رسائل التواصل',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      Text(
                        'يمكنك عرض وإدارة الرسائل المستلمة من المستخدمين',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Messages list
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'لا توجد رسائل حالياً',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: messages.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return _buildMessageCard(context, message);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text(
                  'حدث خطأ: $error',
                  style: GoogleFonts.cairo(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

// Enhanced security info row with copy and block options
  Widget _buildSecurityInfoRow(
    String label,
    String value, {
    VoidCallback? onCopy,
    VoidCallback? onBlock,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.cairo(),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onCopy != null)
            IconButton(
              icon: const Icon(Icons.copy, size: 16),
              onPressed: onCopy,
              tooltip: 'نسخ',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          if (onBlock != null)
            IconButton(
              icon: const Icon(Icons.block, size: 16, color: Colors.red),
              onPressed: onBlock,
              tooltip: 'حظر',
              padding: const EdgeInsets.only(right: 8),
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

// Copy to clipboard helper
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم النسخ'),
        backgroundColor: Colors.green,
      ),
    );
  }

// Show full user agent in a dialog
  void _showFullUserAgentDialog(BuildContext context, String userAgent) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'تفاصيل User Agent',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          content: Container(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    userAgent,
                    style: GoogleFonts.robotoMono(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => _copyToClipboard(userAgent),
              child: Text('نسخ', style: GoogleFonts.cairo()),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إغلاق', style: GoogleFonts.cairo()),
            ),
          ],
        );
      },
    );
  }

// Check if an IP is already blocked
  Future<bool> _checkIfBlocked(String ip) async {
    if (ip.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('عنوان IP غير متوفر'),
          backgroundColor: Colors.orange,
        ),
      );
      return false;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('blockedUsers')
          .where('ip', isEqualTo: ip)
          .get();

      final isBlocked = snapshot.docs.isNotEmpty;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isBlocked
              ? 'هذا المستخدم محظور بالفعل'
              : 'هذا المستخدم غير محظور'),
          backgroundColor: isBlocked ? Colors.red : Colors.green,
        ),
      );

      return isBlocked;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

// Show block dialog and add to blocked users
  void _showBlockDialog(
    BuildContext context, {
    required String ip,
    required String userAgent,
    required String email,
  }) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'حظر المستخدم',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (ip.isNotEmpty) ...[
                Text('عنوان IP:',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                Text(ip, style: GoogleFonts.cairo()),
                const SizedBox(height: 8),
              ],
              if (email.isNotEmpty) ...[
                Text('البريد الإلكتروني:',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                Text(email, style: GoogleFonts.cairo()),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  labelText: 'سبب الحظر',
                  labelStyle: GoogleFonts.cairo(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'اكتب سبب الحظر هنا...',
                ),
                style: GoogleFonts.cairo(),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء', style: GoogleFonts.cairo()),
            ),
            ElevatedButton(
              onPressed: () async {
                if (reasonController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('الرجاء إدخال سبب الحظر'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                try {
                  // Check if already blocked
                  final isAlreadyBlocked = await _checkIfBlocked(ip);
                  if (isAlreadyBlocked) {
                    Navigator.pop(context);
                    return;
                  }

                  // Create blocked user
                  final blockedUser = BlockedUser(
                    id: '',
                    ip: ip,
                    userAgent: userAgent,
                    reason: reasonController.text.trim(),
                    blockedAt: DateTime.now(),
                    blockedBy: ref.read(authProvider).user?.email ?? 'Admin',
                    userEmail: email,
                  );

                  // Save to Firestore
                  await FirebaseFirestore.instance
                      .collection('blockedUsers')
                      .add(blockedUser.toMap());

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم حظر المستخدم بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('حدث خطأ: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('حظر', style: GoogleFonts.cairo()),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMessageCard(BuildContext context, ContactMessage message) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd – HH:mm');
    final String formattedDate = formatter.format(message.timestamp);

    return Card(
      elevation: message.isRead ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: message.isRead ? Colors.grey.shade300 : Colors.blue.shade300,
          width: message.isRead ? 1 : 2,
        ),
      ),
      color: message.isRead ? Colors.white : Colors.blue.shade50,
      child: ExpansionTile(
        onExpansionChanged: (expanded) {
          if (expanded && !message.isRead) {
            // Mark as read when expanded
            FirebaseFirestore.instance
                .collection('contactMessages')
                .doc(message.id)
                .update({'isRead': true});
          }
        },
        leading: CircleAvatar(
          backgroundColor:
              message.isRead ? Colors.grey.shade200 : Colors.blue.shade100,
          child: Icon(
            Icons.mail,
            color: message.isRead ? Colors.grey.shade700 : Colors.blue.shade700,
          ),
        ),
        title: Text(
          message.subject,
          style: GoogleFonts.cairo(
            fontWeight: message.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'من: ${message.name} • $formattedDate',
          style: GoogleFonts.cairo(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!message.isRead)
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showDeleteConfirmation(context, message),
              color: Colors.red.shade400,
            ),
          ],
        ),
        children: [
          // In your _buildMessageCard method, update the security info section:
          if (message.metadata.isNotEmpty)
            ExpansionTile(
              title: Text(
                'معلومات الأمان',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
              initiallyExpanded:
                  !message.isRead, // Auto-expand for new messages
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.metadata['ip'] != null)
                        _buildSecurityInfoRow(
                          'عنوان IP',
                          message.metadata['ip'],
                          onCopy: () =>
                              _copyToClipboard(message.metadata['ip']),
                          onBlock: () => _showBlockDialog(context,
                              ip: message.metadata['ip'],
                              userAgent: message.metadata['userAgent'] ?? '',
                              email: message.email),
                        ),

                      if (message.metadata['country'] != null &&
                          message.metadata['city'] != null)
                        _buildSecurityInfoRow(
                          'الموقع',
                          '${message.metadata['city']}, ${message.metadata['region'] ?? ''}, ${message.metadata['country']}',
                        ),

                      if (message.metadata['browser'] != null)
                        _buildSecurityInfoRow(
                            'المتصفح', message.metadata['browser']),

                      if (message.metadata['device'] != null)
                        _buildSecurityInfoRow(
                            'الجهاز', message.metadata['device']),

                      if (message.metadata['userAgent'] != null) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Text(
                                'User Agent: ',
                                style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy, size: 16),
                                onPressed: () => _copyToClipboard(
                                    message.metadata['userAgent']),
                                tooltip: 'نسخ',
                              ),
                              IconButton(
                                icon: const Icon(Icons.block,
                                    size: 16, color: Colors.red),
                                onPressed: () => _showBlockDialog(context,
                                    ip: message.metadata['ip'] ?? '',
                                    userAgent: message.metadata['userAgent'],
                                    email: message.email),
                                tooltip: 'حظر هذا المستخدم',
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            message.metadata['userAgent'] ?? '',
                            style: GoogleFonts.robotoMono(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 5,
                          ),
                        ),
                        TextButton(
                          onPressed: () => _showFullUserAgentDialog(
                              context, message.metadata['userAgent'] ?? ''),
                          child: Text('عرض التفاصيل الكاملة',
                              style: GoogleFonts.cairo()),
                        ),
                      ],

                      if (message.metadata['timestamp'] != null)
                        _buildSecurityInfoRow(
                            'وقت الإرسال', message.metadata['timestamp']),

                      // Action buttons for security
                      const SizedBox(height: 16),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () =>
                                _checkIfBlocked(message.metadata['ip'] ?? ''),
                            icon: const Icon(Icons.security),
                            label:
                                Text('فحص الحظر', style: GoogleFonts.cairo()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () => _showBlockDialog(context,
                                ip: message.metadata['ip'] ?? '',
                                userAgent: message.metadata['userAgent'] ?? '',
                                email: message.email),
                            icon: const Icon(Icons.block),
                            label: Text('حظر المستخدم',
                                style: GoogleFonts.cairo()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 8),

                // Contact information
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        icon: Icons.email_outlined,
                        label: 'البريد الإلكتروني',
                        value: message.email,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoRow(
                        icon: Icons.phone_outlined,
                        label: 'رقم الجوال',
                        value:
                            message.phone.isEmpty ? 'غير متوفر' : message.phone,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Message content
                Text(
                  'الرسالة:',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    message.message,
                    style: GoogleFonts.cairo(height: 1.5),
                  ),
                ),

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _copyMessageContent(context, message),
                      icon: const Icon(Icons.copy),
                      label: Text('نسخ المحتوى', style: GoogleFonts.cairo()),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _sendEmail(message.email),
                      icon: const Icon(Icons.reply),
                      label:
                          Text('الرد عبر البريد', style: GoogleFonts.cairo()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Helper method for security info
//   Widget _buildSecurityInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             '$label: ',
//             style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: GoogleFonts.cairo(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey.shade700,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Submit contact form
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final metadata = await _collectUserMetadata();

        // Create new message
        final newMessage = ContactMessage(
          id: '',
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          phone: phoneController.text.trim(),
          subject: subjectController.text.trim(),
          message: messageController.text.trim(),
          timestamp: DateTime.now(),
          metadata: metadata, // Include collected metadata
        );

        // Save to Firestore
        await FirebaseFirestore.instance
            .collection('contactMessages')
            .add(newMessage.toMap());

        // Clear form
        nameController.clear();
        emailController.clear();
        phoneController.clear();
        subjectController.clear();
        messageController.clear();

        // Show success message
        setState(() {
          _showSuccessMessage = true;
          _isSubmitting = false;
        });

        // Focus on the success message
        if (mounted) {
          Scrollable.ensureVisible(
            _formKey.currentContext!,
            duration: const Duration(milliseconds: 300),
          );
        }
      } catch (e) {
        // Show error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ: $e'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  // Delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context, ContactMessage message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'تأكيد الحذف',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'هل أنت متأكد من أنك تريد حذف هذه الرسالة؟',
            style: GoogleFonts.cairo(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء', style: GoogleFonts.cairo()),
            ),
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('contactMessages')
                    .doc(message.id)
                    .delete();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('حذف', style: GoogleFonts.cairo()),
            ),
          ],
        );
      },
    );
  }

  // Copy message content to clipboard
  void _copyMessageContent(BuildContext context, ContactMessage message) {
    final content = '''
من: ${message.name}
البريد الإلكتروني: ${message.email}
رقم الجوال: ${message.phone}
الموضوع: ${message.subject}
الرسالة:
${message.message}
''';

    // Copy to clipboard
    // Use appropriate platform-specific clipboard function here
    // For example:
    // Clipboard.setData(ClipboardData(text: content));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ محتوى الرسالة'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Send email (launch mail client)
  void _sendEmail(String email) {
    // Launch email client
    // Use url_launcher package
    // For example:
    // launch('mailto:$email');
  }
}
