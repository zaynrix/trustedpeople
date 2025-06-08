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
import 'package:trustedtallentsvalley/fetures/auth/admin/providers/auth_provider_admin.dart';
import 'package:trustedtallentsvalley/fetures/services/notification_service.dart';
import 'package:trustedtallentsvalley/fetures/services/providers/enhanced_analytics_provider.dart';

// BlockedUser model
class BlockedUser {
  final String id;
  final String ip;
  final String userAgent;
  final String reason;
  final DateTime blockedAt;
  final String blockedBy;
  final String userEmail;

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
  final Map<String, dynamic> metadata;

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

// Provider for unread message count
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
  void initState() {
    super.initState();

    // Track that someone visited the contact page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final visitorTracker = ref.read(visitorTrackerProvider.notifier);
        visitorTracker.trackPageVisit(
          pageName: 'تواصل معنا',
          userAgent: kIsWeb
              ? js.context['navigator']['userAgent'].toString()
              : 'Flutter Mobile App',
        );
      } catch (e) {
        print('Failed to track page visit: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(isAdminProvider);
    final size = MediaQuery.of(context).size;

    // Define breakpoints
    final isMobile = size.width < 768;
    final isTablet = size.width >= 768 && size.width < 1024;
    final isDesktop = size.width >= 1024;

    return Scaffold(
      appBar: _buildAppBar(context, ref, isMobile, isAdmin),
      drawer: isMobile ? const AppDrawer() : null,
      body: isAdmin
          ? (isMobile
              ? _buildMobileAdminView(context, ref)
              : _buildWebAdminView(context, ref, isDesktop))
          : (isMobile
              ? _buildMobileContactForm(context, ref)
              : _buildWebContactForm(context, ref, isDesktop)),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, WidgetRef ref, bool isMobile, bool isAdmin) {
    if (isMobile) {
      // Mobile: Traditional mobile app bar
      return AppBar(
        backgroundColor: isAdmin ? Colors.green.shade700 : Colors.teal,
        title: Text(
          isAdmin ? 'إدارة الرسائل' : 'تواصل معنا',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 2,
        actions: isAdmin
            ? [
                Consumer(
                  builder: (context, ref, child) {
                    final unreadCount =
                        ref.watch(unreadMessagesCountProvider).maybeWhen(
                              data: (count) => count,
                              orElse: () => 0,
                            );

                    return Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.mark_email_read),
                          onPressed: () => _markAllAsRead(),
                          tooltip: 'تحديد الكل كمقروء',
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ]
            : null,
      );
    } else {
      // Web: Enhanced app bar
      return AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: isAdmin ? Colors.green.shade700 : Colors.teal,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isAdmin ? Icons.admin_panel_settings : Icons.contact_support,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              isAdmin ? 'إدارة رسائل التواصل' : 'تواصل معنا',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: isAdmin
            ? [
                Consumer(
                  builder: (context, ref, child) {
                    final unreadCount =
                        ref.watch(unreadMessagesCountProvider).maybeWhen(
                              data: (count) => count,
                              orElse: () => 0,
                            );

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ElevatedButton.icon(
                        onPressed: () => _markAllAsRead(),
                        icon: const Icon(Icons.mark_email_read, size: 18),
                        label: Text('تحديد الكل كمقروء ($unreadCount)',
                            style: GoogleFonts.cairo()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.green.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
              ]
            : null,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      );
    }
  }

  // Mobile Contact Form
  Widget _buildMobileContactForm(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMobileHeader(),
            const SizedBox(height: 24),
            if (_showSuccessMessage) _buildSuccessMessage(true),
            _buildMobileForm(),
          ],
        ),
      ),
    );
  }

  // Web Contact Form
  Widget _buildWebContactForm(
      BuildContext context, WidgetRef ref, bool isDesktop) {
    final maxWidth = isDesktop ? 800.0 : 600.0;

    return SingleChildScrollView(
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: EdgeInsets.all(isDesktop ? 32.0 : 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWebHeader(isDesktop),
                const SizedBox(height: 48),
                if (_showSuccessMessage) _buildSuccessMessage(false),
                _buildWebForm(isDesktop),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Mobile Admin View
  Widget _buildMobileAdminView(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(contactMessagesProvider);

    return messagesAsync.when(
      data: (messages) => _buildMobileMessagesList(context, ref, messages),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(context, error),
    );
  }

  // Web Admin View
  Widget _buildWebAdminView(
      BuildContext context, WidgetRef ref, bool isDesktop) {
    final maxWidth = isDesktop ? 1400.0 : 1000.0;
    final messagesAsync = ref.watch(contactMessagesProvider);

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: messagesAsync.when(
          data: (messages) =>
              _buildWebMessagesList(context, ref, messages, isDesktop),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorState(context, error),
        ),
      ),
    );
  }

  // Mobile-specific widgets
  Widget _buildMobileHeader() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade50, Colors.teal.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.teal.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.contact_support,
                  color: Colors.teal.shade700,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'تواصل معنا',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'يمكنك التواصل معنا عبر تعبئة النموذج أدناه وسنقوم بالرد عليك في أقرب وقت ممكن',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.teal.shade800,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileForm() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'نموذج التواصل',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildFormFields(true),
              const SizedBox(height: 24),
              _buildSubmitButton(true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileMessagesList(
      BuildContext context, WidgetRef ref, List<ContactMessage> messages) {
    if (messages.isEmpty) {
      return _buildEmptyMessagesState();
    }

    return Column(
      children: [
        // Mobile admin header
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade50, Colors.green.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.admin_panel_settings,
                  color: Colors.green.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إدارة الرسائل',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                    Text(
                      '${messages.length} رسالة',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Colors.green.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Messages list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: messages.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final message = messages[index];
              return _buildMobileMessageCard(context, ref, message);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMobileMessageCard(
      BuildContext context, WidgetRef ref, ContactMessage message) {
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
            _markMessageAsRead(message.id);
          }
        },
        leading: CircleAvatar(
          backgroundColor:
              message.isRead ? Colors.grey.shade200 : Colors.blue.shade100,
          child: Icon(
            Icons.mail,
            color: message.isRead ? Colors.grey.shade700 : Colors.blue.shade700,
            size: 20,
          ),
        ),
        title: Text(
          message.subject,
          style: GoogleFonts.cairo(
            fontWeight: message.isRead ? FontWeight.normal : FontWeight.bold,
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'من: ${message.name}',
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
            Text(
              formattedDate,
              style: GoogleFonts.cairo(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!message.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              onPressed: () => _showDeleteConfirmation(context, message),
              color: Colors.red.shade400,
            ),
          ],
        ),
        children: [
          _buildMessageContent(context, ref, message, true),
        ],
      ),
    );
  }

  // Web-specific widgets
  Widget _buildWebHeader(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 40.0 : 32.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.teal.shade600,
            Colors.teal.shade500,
            Colors.blue.shade500,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.support_agent,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'دعم العملاء',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isDesktop ? 24 : 16),
                Text(
                  'تواصل معنا',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: isDesktop ? 32 : 26,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: isDesktop ? 16 : 12),
                Text(
                  'نحن هنا لمساعدتك! يمكنك التواصل معنا من خلال النموذج أدناه وسنقوم بالرد عليك في أقرب وقت ممكن.',
                  style: GoogleFonts.cairo(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: isDesktop ? 16 : 14,
                    height: 1.6,
                  ),
                ),
                SizedBox(height: isDesktop ? 32 : 24),
                Row(
                  children: [
                    _buildContactInfo(Icons.email, 'support@example.com'),
                    const SizedBox(width: 24),
                    _buildContactInfo(Icons.phone, '+970 59 123 4567'),
                  ],
                ),
              ],
            ),
          ),
          if (isDesktop) ...[
            const SizedBox(width: 48),
            Expanded(
              flex: 2,
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.contact_support,
                          color: Colors.white,
                          size: 80,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'نحن في خدمتك',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '24/7 دعم فني',
                        style: GoogleFonts.cairo(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildWebForm(bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 40.0 : 32.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'نموذج التواصل',
              style: GoogleFonts.cairo(
                fontSize: isDesktop ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'املأ النموذج أدناه وسنتواصل معك قريباً',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: isDesktop ? 32 : 24),
            _buildFormFields(false),
            SizedBox(height: isDesktop ? 32 : 24),
            _buildSubmitButton(false),
          ],
        ),
      ),
    );
  }

  Widget _buildWebMessagesList(BuildContext context, WidgetRef ref,
      List<ContactMessage> messages, bool isDesktop) {
    if (messages.isEmpty) {
      return _buildEmptyMessagesState();
    }

    return Padding(
      padding: EdgeInsets.all(isDesktop ? 32.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWebAdminHeader(messages.length, isDesktop),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.separated(
              itemCount: messages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final message = messages[index];
                return _buildWebMessageCard(context, ref, message, isDesktop);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebAdminHeader(int messageCount, bool isDesktop) {
    final unreadCount = ref.watch(unreadMessagesCountProvider).maybeWhen(
          data: (count) => count,
          orElse: () => 0,
        );

    return Container(
      padding: EdgeInsets.all(isDesktop ? 32.0 : 24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade600, Colors.green.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إدارة رسائل التواصل',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: isDesktop ? 28 : 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'يمكنك عرض وإدارة جميع الرسائل المستلمة من المستخدمين',
                  style: GoogleFonts.cairo(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              _buildStatCard(
                  'إجمالي الرسائل', messageCount.toString(), Icons.mail),
              const SizedBox(height: 12),
              _buildStatCard('غير مقروءة', unreadCount.toString(),
                  Icons.mark_email_unread),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.cairo(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebMessageCard(BuildContext context, WidgetRef ref,
      ContactMessage message, bool isDesktop) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd – HH:mm');
    final String formattedDate = formatter.format(message.timestamp);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: message.isRead ? Colors.grey.shade300 : Colors.blue.shade300,
          width: message.isRead ? 1 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        onExpansionChanged: (expanded) {
          if (expanded && !message.isRead) {
            _markMessageAsRead(message.id);
          }
        },
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: message.isRead ? Colors.grey.shade100 : Colors.blue.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.mail,
            color: message.isRead ? Colors.grey.shade600 : Colors.blue.shade600,
            size: 24,
          ),
        ),
        title: Text(
          message.subject,
          style: GoogleFonts.cairo(
            fontWeight: message.isRead ? FontWeight.w500 : FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                'من: ${message.name} • ${message.email}',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              formattedDate,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!message.isRead)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'جديد',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showDeleteConfirmation(context, message),
              color: Colors.red.shade400,
              tooltip: 'حذف الرسالة',
            ),
          ],
        ),
        children: [
          _buildMessageContent(context, ref, message, false),
        ],
      ),
    );
  }

// Shared widgets
  Widget _buildFormFields(bool isMobile) {
    return Column(
      children: [
        if (!isMobile)
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: nameController,
                  label: 'الاسم الكامل',
                  icon: Icons.person_outline,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'الرجاء إدخال الاسم' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: emailController,
                  label: 'البريد الإلكتروني',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.isEmpty ?? true)
                      return 'الرجاء إدخال البريد الإلكتروني';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value!)) {
                      return 'الرجاء إدخال بريد إلكتروني صحيح';
                    }
                    return null;
                  },
                ),
              ),
            ],
          )
        else ...[
          _buildTextField(
            controller: nameController,
            label: 'الاسم الكامل',
            icon: Icons.person_outline,
            validator: (value) =>
                value?.isEmpty ?? true ? 'الرجاء إدخال الاسم' : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: emailController,
            label: 'البريد الإلكتروني',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value?.isEmpty ?? true)
                return 'الرجاء إدخال البريد الإلكتروني';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value!)) {
                return 'الرجاء إدخال بريد إلكتروني صحيح';
              }
              return null;
            },
          ),
        ],
        const SizedBox(height: 16),
        if (!isMobile)
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: phoneController,
                  label: 'رقم الجوال (اختياري)',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: subjectController,
                  label: 'الموضوع',
                  icon: Icons.subject,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'الرجاء إدخال الموضوع' : null,
                ),
              ),
            ],
          )
        else ...[
          _buildTextField(
            controller: phoneController,
            label: 'رقم الجوال (اختياري)',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: subjectController,
            label: 'الموضوع',
            icon: Icons.subject,
            validator: (value) =>
                value?.isEmpty ?? true ? 'الرجاء إدخال الموضوع' : null,
          ),
        ],
        const SizedBox(height: 16),
        _buildTextField(
          controller: messageController,
          label: 'الرسالة',
          icon: Icons.message_outlined,
          maxLines: isMobile ? 4 : 6,
          validator: (value) =>
              value?.isEmpty ?? true ? 'الرجاء إدخال الرسالة' : null,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.cairo(),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: Icon(icon),
        alignLabelWithHint: maxLines > 1,
      ),
      style: GoogleFonts.cairo(),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _buildSubmitButton(bool isMobile) {
    return SizedBox(
      width: double.infinity,
      height: isMobile ? 50 : 56,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
        child: _isSubmitting
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'جارٍ الإرسال...',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.send, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'إرسال الرسالة',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSuccessMessage(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      margin: const EdgeInsets.only(bottom: 24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Colors.green.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.check_circle,
              color: Colors.green.shade700,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تم إرسال رسالتك بنجاح!',
                  style: GoogleFonts.cairo(
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'سنقوم بالرد عليك في أقرب وقت ممكن على البريد الإلكتروني المحدد.',
                  style: GoogleFonts.cairo(
                    color: Colors.green.shade700,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
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
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context, WidgetRef ref,
      ContactMessage message, bool isMobile) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Security metadata section
          if (message.metadata.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'معلومات الأمان',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Row(
                        children: [
                          if (message.metadata['ip'] != null) ...[
                            TextButton.icon(
                              onPressed: () =>
                                  _checkIfBlocked(message.metadata['ip'] ?? ''),
                              icon: const Icon(Icons.security, size: 16),
                              label: Text('فحص الحظر',
                                  style: GoogleFonts.cairo(fontSize: 12)),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => _showBlockDialog(
                                context,
                                ip: message.metadata['ip'] ?? '',
                                userAgent: message.metadata['userAgent'] ?? '',
                                email: message.email,
                              ),
                              icon: const Icon(Icons.block, size: 16),
                              label: Text('حظر',
                                  style: GoogleFonts.cairo(fontSize: 12)),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSecurityInfo(message.metadata, isMobile),
                ],
              ),
            ),

          // Message content
          Row(
            children: [
              Expanded(
                child: _buildInfoRow(
                  icon: Icons.email_outlined,
                  label: 'البريد الإلكتروني',
                  value: message.email,
                ),
              ),
              if (!isMobile) const SizedBox(width: 16),
              if (!isMobile)
                Expanded(
                  child: _buildInfoRow(
                    icon: Icons.phone_outlined,
                    label: 'رقم الجوال',
                    value: message.phone.isEmpty ? 'غير متوفر' : message.phone,
                  ),
                ),
            ],
          ),

          if (isMobile && message.phone.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.phone_outlined,
              label: 'رقم الجوال',
              value: message.phone,
            ),
          ],

          const SizedBox(height: 16),

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
          if (isMobile)
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _copyMessageContent(context, message),
                    icon: const Icon(Icons.copy),
                    label: Text('نسخ المحتوى', style: GoogleFonts.cairo()),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _sendEmail(message.email),
                    icon: const Icon(Icons.reply),
                    label: Text('الرد عبر البريد', style: GoogleFonts.cairo()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                    ),
                  ),
                ),
              ],
            )
          else
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
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _sendEmail(message.email),
                  icon: const Icon(Icons.reply),
                  label: Text('الرد عبر البريد', style: GoogleFonts.cairo()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSecurityInfo(Map<String, dynamic> metadata, bool isMobile) {
    return Column(
      children: [
        if (metadata['ip'] != null)
          _buildSecurityInfoRow(
            'عنوان IP',
            metadata['ip'],
            onCopy: () => _copyToClipboard(metadata['ip']),
          ),
        if (metadata['country'] != null && metadata['city'] != null)
          _buildSecurityInfoRow(
            'الموقع',
            '${metadata['city']}, ${metadata['region'] ?? ''}, ${metadata['country']}',
          ),
        if (metadata['browser'] != null)
          _buildSecurityInfoRow('المتصفح', metadata['browser']),
        if (metadata['device'] != null)
          _buildSecurityInfoRow('الجهاز', metadata['device']),
        if (metadata['userAgent'] != null)
          _buildSecurityInfoRow(
            'User Agent',
            metadata['userAgent'],
            onCopy: () => _copyToClipboard(metadata['userAgent']),
            isUserAgent: true,
          ),
      ],
    );
  }

  Widget _buildSecurityInfoRow(
    String label,
    String value, {
    VoidCallback? onCopy,
    bool isUserAgent = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              isUserAgent
                  ? (value.length > 50 ? '${value.substring(0, 50)}...' : value)
                  : value,
              style: GoogleFonts.cairo(fontSize: 12),
              overflow: TextOverflow.ellipsis,
              maxLines: isUserAgent ? 2 : 1,
            ),
          ),
          if (onCopy != null)
            IconButton(
              icon: const Icon(Icons.copy, size: 14),
              onPressed: onCopy,
              tooltip: 'نسخ',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          if (isUserAgent)
            TextButton(
              onPressed: () => _showFullUserAgentDialog(context, value),
              child: Text('عرض الكل', style: GoogleFonts.cairo(fontSize: 10)),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                minimumSize: const Size(0, 0),
              ),
            ),
        ],
      ),
    );
  }

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
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyMessagesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.mail_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد رسائل حالياً',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ستظهر الرسائل هنا عندما يتواصل المستخدمون معك',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            'حدث خطأ أثناء تحميل الرسائل',
            style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: GoogleFonts.cairo(color: Colors.grey.shade700, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

// Helper methods and functionality
  Future<Map<String, dynamic>> _collectUserMetadata() async {
    Map<String, dynamic> metadata = {
      'timestamp': DateTime.now().toIso8601String(),
      'platform': kIsWeb ? 'web' : defaultTargetPlatform.toString(),
    };

    try {
      // Get IP and location information
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
        metadata['userAgent'] = js.context['navigator']['userAgent'];
        metadata['language'] = js.context['navigator']['language'];
        metadata['screenWidth'] = js.context['screen']['width'];
        metadata['screenHeight'] = js.context['screen']['height'];

        String userAgent =
            js.context['navigator']['userAgent'].toString().toLowerCase();
        if (userAgent.contains('firefox')) {
          metadata['browser'] = 'Firefox';
        } else if (userAgent.contains('chrome') &&
            !userAgent.contains('edge')) {
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

        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        metadata['appVersion'] = packageInfo.version;
        metadata['buildNumber'] = packageInfo.buildNumber;
      }

      metadata['requestId'] = DateTime.now().millisecondsSinceEpoch.toString();
    } catch (e) {
      metadata['metadataError'] = e.toString();
    }

    return metadata;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final metadata = await _collectUserMetadata();

        final newMessage = ContactMessage(
          id: '',
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          phone: phoneController.text.trim(),
          subject: subjectController.text.trim(),
          message: messageController.text.trim(),
          timestamp: DateTime.now(),
          metadata: metadata,
        );

        // Save to Firestore
        await FirebaseFirestore.instance
            .collection('contactMessages')
            .add(newMessage.toMap());

        // Send Telegram notification immediately
        try {
          final notificationManager =
              ref.read(adminNotificationManagerProvider);
          await notificationManager.notifyNewContactForm(
            name: nameController.text.trim(),
            email: emailController.text.trim(),
            phone: phoneController.text.trim(),
            subject: subjectController.text.trim(),
            messagePreview: messageController.text.trim().length > 100
                ? '${messageController.text.trim().substring(0, 100)}...'
                : messageController.text.trim(),
          );
        } catch (notificationError) {
          // Log notification error but don't stop the form submission
          print('Failed to send notification: $notificationError');
        }

        // Clear form
        nameController.clear();
        emailController.clear();
        phoneController.clear();
        subjectController.clear();
        messageController.clear();

        setState(() {
          _showSuccessMessage = true;
          _isSubmitting = false;
        });

        if (mounted) {
          Scrollable.ensureVisible(
            _formKey.currentContext!,
            duration: const Duration(milliseconds: 300),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ: $e', style: GoogleFonts.cairo()),
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

  void _markMessageAsRead(String messageId) {
    FirebaseFirestore.instance
        .collection('contactMessages')
        .doc(messageId)
        .update({'isRead': true});
  }

  void _markAllAsRead() {
    FirebaseFirestore.instance
        .collection('contactMessages')
        .where('isRead', isEqualTo: false)
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.update({'isRead': true});
      }
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم النسخ', style: GoogleFonts.cairo()),
        backgroundColor: Colors.green,
      ),
    );
  }

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
              child: SelectableText(
                userAgent,
                style: GoogleFonts.robotoMono(fontSize: 14),
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

  Future<bool> _checkIfBlocked(String ip) async {
    if (ip.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('عنوان IP غير متوفر', style: GoogleFonts.cairo()),
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
          content: Text(
            isBlocked ? 'هذا المستخدم محظور بالفعل' : 'هذا المستخدم غير محظور',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: isBlocked ? Colors.red : Colors.green,
        ),
      );

      return isBlocked;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $e', style: GoogleFonts.cairo()),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  void _showBlockDialog(
    BuildContext context, {
    required String ip,
    required String userAgent,
    required String email,
  }) {
    final reasonController = TextEditingController();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'حظر المستخدم',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: isMobile ? double.maxFinite : 400,
            child: Column(
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
                    SnackBar(
                      content: Text('الرجاء إدخال سبب الحظر',
                          style: GoogleFonts.cairo()),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                try {
                  final isAlreadyBlocked = await _checkIfBlocked(ip);
                  if (isAlreadyBlocked) {
                    Navigator.pop(context);
                    return;
                  }

                  final blockedUser = BlockedUser(
                    id: '',
                    ip: ip,
                    userAgent: userAgent,
                    reason: reasonController.text.trim(),
                    blockedAt: DateTime.now(),
                    blockedBy: ref.read(authProvider).user?.email ?? 'Admin',
                    userEmail: email,
                  );

                  await FirebaseFirestore.instance
                      .collection('blockedUsers')
                      .add(blockedUser.toMap());

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم حظر المستخدم بنجاح',
                          style: GoogleFonts.cairo()),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('حدث خطأ: $e', style: GoogleFonts.cairo()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('حظر', style: GoogleFonts.cairo()),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, ContactMessage message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'تأكيد الحذف',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'هل أنت متأكد من أنك تريد حذف هذه الرسالة؟',
                style: GoogleFonts.cairo(),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.mail, color: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.subject,
                            style:
                                GoogleFonts.cairo(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'من: ${message.name}',
                            style: GoogleFonts.cairo(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم حذف الرسالة بنجاح',
                        style: GoogleFonts.cairo()),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('حذف', style: GoogleFonts.cairo()),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  void _copyMessageContent(BuildContext context, ContactMessage message) {
    final content = '''
من: ${message.name}
البريد الإلكتروني: ${message.email}
رقم الجوال: ${message.phone}
الموضوع: ${message.subject}
الرسالة:
${message.message}
''';

    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم نسخ محتوى الرسالة', style: GoogleFonts.cairo()),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _sendEmail(String email) {
    // Launch email client
    // Use url_launcher package: launch('mailto:$email');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('فتح تطبيق البريد الإلكتروني...', style: GoogleFonts.cairo()),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
