import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/booking.dart';
import '../models/payment.dart';
import '../models/image_data.dart';
import '../models/enums.dart';
import '../providers/booking_provider.dart';
import '../widgets/enhanced_payment_dialog.dart';
import '../widgets/enhanced_image_picker_widget.dart';
import '../widgets/image_gallery_widget.dart';
import 'booking_form_screen.dart';

class BookingDetailsScreen extends StatefulWidget {
  final Booking booking;

  const BookingDetailsScreen({super.key, required this.booking});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  List<Payment> _payments = [];
  bool _isLoadingPayments = false;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() {
      _isLoadingPayments = true;
    });

    try {
      final payments = await context.read<BookingProvider>().getBookingPayments(widget.booking.id);
      if (!mounted) return;
      setState(() {
        _payments = payments;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPayments = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('حجز #${widget.booking.invoiceNumber}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookingFormScreen(booking: widget.booking),
                ),
              ).then((_) {
                if (!mounted) return;
                context.read<BookingProvider>().loadBookings();
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicInfoCard(),
            const SizedBox(height: 16),
            _buildPaymentsCard(),
            const SizedBox(height: 16),
            _buildImagesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'المعلومات الأساسية',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _buildStatusChip(widget.booking.status),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('اسم العميل', widget.booking.customerName, Icons.person),
            _buildInfoRow('رقم الجوال', widget.booking.phoneNumber, Icons.phone),
            _buildInfoRow('تاريخ الحفلة', _formatDate(widget.booking.eventDate), Icons.event),
            _buildInfoRow('نوع الحفلة', widget.booking.eventType.displayName, Icons.category),
            _buildInfoRow('العامل المسؤول', widget.booking.responsibleEmployee, Icons.work),
            if (widget.booking.generalNotes.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow('ملاحظات عامة', widget.booking.generalNotes, Icons.note),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'الحسابات والدفعات',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _showAddPaymentDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة دفعة'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('إجمالي المبلغ:', style: TextStyle(fontWeight: FontWeight.w500)),
                      Text('${widget.booking.totalAmount.toStringAsFixed(0)} ريال', 
                           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('المدفوع:', style: TextStyle(fontWeight: FontWeight.w500)),
                      Text('${widget.booking.paidAmount.toStringAsFixed(0)} ريال', 
                           style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('المتبقي:', style: TextStyle(fontWeight: FontWeight.w500)),
                      Text('${widget.booking.remainingAmount.toStringAsFixed(0)} ريال', 
                           style: TextStyle(color: widget.booking.remainingAmount > 0 ? Colors.red : Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoadingPayments)
              const Center(child: CircularProgressIndicator())
            else if (_payments.isEmpty)
              const Center(child: Text('لا توجد دفعات مسجلة حتى الآن.'))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _payments.length,
                itemBuilder: (context, index) {
                  final payment = _payments[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: Icon(_getPaymentMethodIcon(payment.paymentMethod)),
                      title: Text('${payment.amount.toStringAsFixed(0)} ريال'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${payment.paymentMethod.displayName} - ${_formatDate(payment.paymentDate)}'),
                          if (payment.checkNumber != null)
                            Text('رقم الشيك: ${payment.checkNumber}'),
                          if (payment.cardLastFour != null)
                            Text('البطاقة: ****${payment.cardLastFour}'),
                          if (payment.referenceNumber != null)
                            Text('رقم مرجعي: ${payment.referenceNumber}'),
                          if (payment.notes.isNotEmpty)
                            Text('ملاحظات: ${payment.notes}'),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) => _handlePaymentAction(value, payment),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 8),
                                Text('تعديل'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('حذف', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BookingStatus status) {
    Color color;
    String text;
    switch (status) {
      case BookingStatus.ready:
        color = Colors.blue;
        text = 'جاهز';
        break;
      case BookingStatus.inProgress: 
        color = Colors.orange;
        text = 'معلق';
        break;
      case BookingStatus.completed:
        color = Colors.green;
        text = 'مكتمل';
        break;
      case BookingStatus.postponed:
        color = Colors.purple;
        text = 'مؤجل';
        break;
      case BookingStatus.cancelled:
        color = Colors.red;
        text = 'ملغي';
        break;
    }
    return Chip(
      label: Text(text, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  IconData _getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.transfer:
        return Icons.account_balance;
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.check:
        return Icons.receipt;
    }
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddPaymentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EnhancedPaymentDialog(
          bookingId: widget.booking.id,
          onSave: (payment) async {
            final bookingProvider = context.read<BookingProvider>();
            final success = await bookingProvider.addPayment(widget.booking.id, payment);
            if (!mounted) return;
            if (success) {
              await _loadPayments();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("تمت إضافة الدفعة بنجاح")),
              );
            } else {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("خطأ في إضافة الدفعة")),
              );
            }
          },
        );
      },
    );
  }

  void _handlePaymentAction(String action, Payment payment) {
    switch (action) {
      case 'edit':
        _showEditPaymentDialog(payment);
        break;
      case 'delete':
        _showDeletePaymentConfirmation(payment);
        break;
    }
  }

  void _showEditPaymentDialog(Payment payment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EnhancedPaymentDialog(
          payment: payment,
          bookingId: widget.booking.id,
          onSave: (updatedPayment) async {
            final bookingProvider = context.read<BookingProvider>();
            final success = await bookingProvider.updatePayment(updatedPayment);
            if (!mounted) return;
            if (success) {
              await _loadPayments();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("تم تحديث الدفعة بنجاح")),
              );
            } else {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("خطأ في تحديث الدفعة")),
              );
            }
          },
        );
      },
    );
  }

  void _showDeletePaymentConfirmation(Payment payment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد من حذف دفعة بمبلغ ${payment.amount.toStringAsFixed(0)} ريال؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final bookingProvider = context.read<BookingProvider>();
                final success = await bookingProvider.deletePayment(payment.id, widget.booking.id);
                if (!mounted) return;
                if (success) {
                  await _loadPayments();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("تم حذف الدفعة بنجاح")),
                  );
                } else {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("خطأ في حذف الدفعة")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('حذف', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // بناء قسم الصور
  Widget _buildImagesSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'صور الحجز',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadImages,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // ويدجت إضافة الصور
            EnhancedImagePickerWidget(
              title: 'إضافة صور للحجز',
              allowMultiple: true,
              maxImages: 20,
              onImagesChanged: (imagePaths) async {
                if (imagePaths.isNotEmpty) {
                  final bookingProvider = context.read<BookingProvider>();
                  final success = await bookingProvider.addMultipleImagesToBooking(
                    widget.booking.id,
                    imagePaths,
                  );
                  if (success) {
                    await _loadImages();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم إضافة الصور بنجاح')),
                      );
                    }
                  }
                }
              },
            ),
            
            const SizedBox(height: 16),
            
            // عرض الصور الموجودة
            FutureBuilder<List<ImageData>>(
              future: context.read<BookingProvider>().getBookingImages(widget.booking.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Text('خطأ في تحميل الصور: ${snapshot.error}'),
                  );
                }
                
                final images = snapshot.data ?? [];
                
                if (images.isEmpty) {
                  return Container(
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('لا توجد صور مرفقة', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
                }
                
                return ImageGalleryWidget(
                  images: images,
                  showDeleteButton: true,
                  onImageDelete: (image) async {
                    final bookingProvider = context.read<BookingProvider>();
                    final success = await bookingProvider.deleteImage(image);
                    if (success) {
                      await _loadImages();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم حذف الصورة بنجاح')),
                        );
                      }
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // تحميل الصور
  Future<void> _loadImages() async {
    setState(() {});
  }
}

