// lib/fetures/fetures/services/screens/service_detail_screen.dart

// class ServiceDetailScreen extends ConsumerStatefulWidget {
//   final ServiceModel service;
//
//   const ServiceDetailScreen({
//     Key? key,
//     required this.service,
//   }) : super(key: key);
//
//   @override
//   ConsumerState<ServiceDetailScreen> createState() =>
//       _ServiceDetailScreenState();
// }
//
// class _ServiceDetailScreenState extends ConsumerState<ServiceDetailScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   bool _showRequestForm = false;
//   bool _isSubmitting = false;
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final service = widget.service;
//     final screenSize = MediaQuery.of(context).size;
//     final isSmallScreen = screenSize.width < 600;
//     final isMediumScreen = screenSize.width >= 600 && screenSize.width < 1100;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "تفاصيل الخدمة",
//           style: GoogleFonts.cairo(
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: Colors.teal,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.home),
//             onPressed: () => context.goNamed(ScreensNames.home),
//             tooltip: 'الرئيسية',
//           ),
//         ],
//       ),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           return Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Side drawer for larger screens
//               if (!isSmallScreen) const AppDrawer(isPermanent: true),
//
//               // Main content
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Container(
//                     padding: const EdgeInsets.all(24.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Top section with image and basic info
//                         isSmallScreen || isMediumScreen
//                             ? _buildMobileTopSection(service, isSmallScreen)
//                             : _buildDesktopTopSection(service),
//
//                         const SizedBox(height: 32),
//
//                         // Service description
//                         Text(
//                           'وصف الخدمة',
//                           style: GoogleFonts.cairo(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           service.description,
//                           style: GoogleFonts.cairo(
//                             fontSize: 16,
//                             height: 1.6,
//                           ),
//                         ),
//
//                         const SizedBox(height: 32),
//
//                         // Service details
//                         Text(
//                           'تفاصيل الخدمة',
//                           style: GoogleFonts.cairo(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         _buildServiceDetailsGrid(service),
//
//                         const SizedBox(height: 32),
//
//                         // Request service form
//                         if (!_showRequestForm)
//                           Center(
//                             child: ElevatedButton.icon(
//                               onPressed: () {
//                                 setState(() {
//                                   _showRequestForm = true;
//                                 });
//                               },
//                               icon: const Icon(Icons.shopping_cart),
//                               label: Text(
//                                 'طلب الخدمة الآن',
//                                 style: GoogleFonts.cairo(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.teal,
//                                 foregroundColor: Colors.white,
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 32,
//                                   vertical: 12,
//                                 ),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                               ),
//                             ),
//                           )
//                         else
//                           _buildRequestForm(service),
//
//                         const SizedBox(height: 40),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildMobileTopSection(ServiceModel service, bool isSmallScreen) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Image
//         ClipRRect(
//           borderRadius: BorderRadius.circular(16),
//           child: service.imageUrl.isNotEmpty
//               ? Image.network(
//                   service.imageUrl,
//                   height: 200,
//                   width: double.infinity,
//                   fit: BoxFit.cover,
//                 )
//               : Container(
//                   height: 200,
//                   width: double.infinity,
//                   color: Colors.teal.shade100,
//                   child: Center(
//                     child: Icon(
//                       _getCategoryIcon(service.category.name),
//                       size: 80,
//                       color: Colors.teal.shade700,
//                     ),
//                   ),
//                 ),
//         ),
//         const SizedBox(height: 24),
//         // Title and price
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     service.title,
//                     style: GoogleFonts.cairo(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     service.category.displayName,
//                     style: GoogleFonts.cairo(
//                       fontSize: 16,
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               decoration: BoxDecoration(
//                 color: Colors.teal.shade50,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.teal.shade200),
//               ),
//               child: Text(
//                 '\$${service.price.toStringAsFixed(2)}',
//                 style: GoogleFonts.cairo(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.teal.shade700,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         // Rating
//         Row(
//           children: [
//             const Icon(Icons.star, color: Colors.amber, size: 20),
//             const SizedBox(width: 4),
//             // Text(
//             //   service..toString(),
//             //   style: GoogleFonts.cairo(
//             //     fontWeight: FontWeight.bold,
//             //   ),
//             // ),
//             const SizedBox(width: 8),
//             // Text(
//             //   '(${service.reviewsCount} تقييم)',
//             //   style: GoogleFonts.cairo(
//             //     color: Colors.grey.shade600,
//             //   ),
//             // ),
//             const SizedBox(width: 16),
//             const Icon(Icons.timer, color: Colors.teal, size: 20),
//             const SizedBox(width: 4),
//             Text(
//               '${service.deliveryTimeInDays} دقيقة',
//               style: GoogleFonts.cairo(),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildDesktopTopSection(ServiceModel service) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Image
//         ClipRRect(
//           borderRadius: BorderRadius.circular(16),
//           child: service.imageUrl.isNotEmpty
//               ? Image.network(
//                   service.imageUrl,
//                   height: 300,
//                   width: 400,
//                   fit: BoxFit.cover,
//                 )
//               : Container(
//                   height: 300,
//                   width: 400,
//                   color: Colors.teal.shade100,
//                   child: Center(
//                     child: Icon(
//                       _getCategoryIcon(service.category.name),
//                       size: 120,
//                       color: Colors.teal.shade700,
//                     ),
//                   ),
//                 ),
//         ),
//         const SizedBox(width: 32),
//         // Info
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 service.title,
//                 style: GoogleFonts.cairo(
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 service.category.displayName,
//                 style: GoogleFonts.cairo(
//                   fontSize: 18,
//                   color: Colors.grey.shade600,
//                 ),
//               ),
//               const SizedBox(height: 24),
//               // Price
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                 decoration: BoxDecoration(
//                   color: Colors.teal.shade50,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.teal.shade200),
//                 ),
//                 child: Text(
//                   '\$${service.price.toStringAsFixed(2)}',
//                   style: GoogleFonts.cairo(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.teal.shade700,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               // Rating and time
//               Row(
//                 children: [
//                   const Icon(Icons.star, color: Colors.amber, size: 24),
//                   const SizedBox(width: 8),
//                   Text(
//                     "service.rating.toString()",
//                     style: GoogleFonts.cairo(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     '({service.reviewsCount} تقييم)',
//                     style: GoogleFonts.cairo(
//                       fontSize: 16,
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
//                   const SizedBox(width: 32),
//                   const Icon(Icons.timer, color: Colors.teal, size: 24),
//                   const SizedBox(width: 8),
//                   Text(
//                     '{service.estimatedTimeMinutes} دقيقة',
//                     style: GoogleFonts.cairo(
//                       fontSize: 16,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 24),
//               // Orders count
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: Colors.blue.shade50,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Icon(Icons.shopping_bag,
//                         color: Colors.blue, size: 20),
//                     const SizedBox(width: 8),
//                     Text(
//                       'تم طلبها {service.orderCount} مرة',
//                       style: GoogleFonts.cairo(
//                         color: Colors.blue.shade700,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildServiceDetailsGrid(ServiceModel service) {
//     return GridView.count(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       crossAxisCount: 2,
//       childAspectRatio: 3,
//       crossAxisSpacing: 16,
//       mainAxisSpacing: 16,
//       children: [
//         _buildDetailItem(
//           icon: Icons.timer,
//           title: 'وقت التنفيذ',
//           value: '{service.estimatedTimeMinutes} دقيقة',
//         ),
//         _buildDetailItem(
//           icon: Icons.shopping_bag,
//           title: 'عدد الطلبات',
//           value: "service.orderCount.toString()",
//         ),
//         _buildDetailItem(
//           icon: Icons.category,
//           title: 'التصنيف',
//           value: service.category.name,
//         ),
//         _buildDetailItem(
//           icon: Icons.star,
//           title: 'التقييم',
//           value: '{service.rating.toString()} ({service.reviewsCount} تقييم)',
//         ),
//       ],
//     );
//   }
//
//   Widget _buildDetailItem({
//     required IconData icon,
//     required String title,
//     required String value,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, color: Colors.teal, size: 24),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   title,
//                   style: GoogleFonts.cairo(
//                     fontSize: 14,
//                     color: Colors.grey.shade600,
//                   ),
//                 ),
//                 Text(
//                   value,
//                   style: GoogleFonts.cairo(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildRequestForm(ServiceModel service) {
//     final requestsNotifier = ref.read(serviceRequestsProvider.notifier);
//
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const Icon(Icons.edit_note, color: Colors.teal, size: 24),
//               const SizedBox(width: 12),
//               Text(
//                 'طلب الخدمة',
//                 style: GoogleFonts.cairo(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.teal.shade700,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 24),
//           Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 TextFormField(
//                   controller: _nameController,
//                   decoration: InputDecoration(
//                     labelText: 'الاسم الكامل',
//                     hintText: 'أدخل اسمك الكامل',
//                     prefixIcon: const Icon(Icons.person),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'الرجاء إدخال الاسم';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _emailController,
//                   decoration: InputDecoration(
//                     labelText: 'البريد الإلكتروني',
//                     hintText: 'أدخل بريدك الإلكتروني',
//                     prefixIcon: const Icon(Icons.email),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'الرجاء إدخال البريد الإلكتروني';
//                     }
//                     if (!value.contains('@') || !value.contains('.')) {
//                       return 'الرجاء إدخال بريد إلكتروني صحيح';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _phoneController,
//                   decoration: InputDecoration(
//                     labelText: 'رقم الهاتف',
//                     hintText: 'أدخل رقم هاتفك',
//                     prefixIcon: const Icon(Icons.phone),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'الرجاء إدخال رقم الهاتف';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _descriptionController,
//                   decoration: InputDecoration(
//                     labelText: 'تفاصيل الطلب',
//                     hintText: 'اكتب تفاصيل طلبك هنا',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     alignLabelWithHint: true,
//                   ),
//                   maxLines: 5,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'الرجاء إدخال تفاصيل الطلب';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 24),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: OutlinedButton(
//                         onPressed: _isSubmitting
//                             ? null
//                             : () {
//                                 setState(() {
//                                   _showRequestForm = false;
//                                 });
//                               },
//                         style: OutlinedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                           side: BorderSide(color: Colors.grey.shade400),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         child: Text(
//                           'إلغاء',
//                           style: GoogleFonts.cairo(),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: ElevatedButton(
//                         onPressed: _isSubmitting
//                             ? null
//                             : () async {
//                                 if (_formKey.currentState!.validate()) {
//                                   setState(() {
//                                     _isSubmitting = true;
//                                   });
//
//                                   // Create service request
//                                   final request = ServiceRequestModel(
//                                     status: ServiceRequestStatus.inProgress,
//
//                                     id: '', // Will be set by Firestore
//                                     serviceId: service.id,
//                                     serviceName: service.title,
//                                     clientName: _nameController.text,
//                                     clientEmail: _emailController.text,
//                                     clientPhone: _phoneController.text,
//                                     requirements: _descriptionController.text,
//                                     createdAt:
//                                         Timestamp.fromDate(DateTime.now()),
//                                   );
//
//                                   final success = await requestsNotifier
//                                       .createRequest(request);
//
//                                   if (success) {
//                                     if (!mounted) return;
//
//                                     showDialog(
//                                       context: context,
//                                       builder: (context) => AlertDialog(
//                                         title: Row(
//                                           children: [
//                                             const Icon(Icons.check_circle,
//                                                 color: Colors.green),
//                                             const SizedBox(width: 8),
//                                             Text(
//                                               'تم إرسال الطلب بنجاح',
//                                               style: GoogleFonts.cairo(
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         content: Column(
//                                           mainAxisSize: MainAxisSize.min,
//                                           children: [
//                                             Text(
//                                               'تم استلام طلبك وسيتم الرد عليك خلال 15 دقيقة',
//                                               style: GoogleFonts.cairo(),
//                                             ),
//                                             const SizedBox(height: 16),
//                                             Container(
//                                               padding: const EdgeInsets.all(16),
//                                               decoration: BoxDecoration(
//                                                 color: Colors.green.shade50,
//                                                 borderRadius:
//                                                     BorderRadius.circular(8),
//                                                 border: Border.all(
//                                                     color:
//                                                         Colors.green.shade200),
//                                               ),
//                                               child: Row(
//                                                 children: [
//                                                   const Icon(Icons.timer,
//                                                       color: Colors.green),
//                                                   const SizedBox(width: 8),
//                                                   Expanded(
//                                                     child: Text(
//                                                       'وقت الاستجابة: 15 دقيقة',
//                                                       style: GoogleFonts.cairo(
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                         color: Colors
//                                                             .green.shade700,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         actions: [
//                                           TextButton(
//                                             onPressed: () {
//                                               Navigator.pop(context);
//                                               context
//                                                   .goNamed(ScreensNames.home);
//                                             },
//                                             child: Text(
//                                               'العودة للرئيسية',
//                                               style: GoogleFonts.cairo(
//                                                   color: Colors.teal),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     );
//                                   } else {
//                                     // Show error
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       SnackBar(
//                                         content: Text(
//                                           'حدث خطأ أثناء إرسال الطلب، يرجى المحاولة مرة أخرى',
//                                           style: GoogleFonts.cairo(),
//                                         ),
//                                         backgroundColor: Colors.red,
//                                       ),
//                                     );
//                                   }
//
//                                   setState(() {
//                                     _isSubmitting = false;
//                                   });
//                                 }
//                               },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.teal,
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         child: _isSubmitting
//                             ? const SizedBox(
//                                 width: 20,
//                                 height: 20,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   color: Colors.white,
//                                 ),
//                               )
//                             : Text(
//                                 'إرسال الطلب',
//                                 style: GoogleFonts.cairo(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   IconData _getCategoryIcon(String category) {
//     switch (category.toLowerCase()) {
//       case 'برمجة':
//         return Icons.code;
//       case 'تصميم':
//         return Icons.design_services;
//       case 'تسويق':
//         return Icons.campaign;
//       case 'كتابة':
//         return Icons.edit_note;
//       case 'ترجمة':
//         return Icons.translate;
//       case 'استشارات':
//         return Icons.support_agent;
//       case 'فيديو':
//         return Icons.videocam;
//       case 'صوت':
//         return Icons.mic;
//       default:
//         return Icons.miscellaneous_services;
//     }
//   }
// }
