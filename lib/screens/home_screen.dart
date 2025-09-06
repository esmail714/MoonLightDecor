import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';
import '../models/booking.dart';
import '../models/enums.dart';
import 'booking_form_screen.dart';
import 'booking_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // تحميل الحجوزات عند بدء التطبيق
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().loadBookings();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نظام إدارة حجوزات الفعاليات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<BookingProvider>().loadBookings();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط البحث
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'البحث في الحجوزات',
                hintText: 'اسم العميل، رقم الجوال، أو رقم الفاتورة',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                context.read<BookingProvider>().searchBookings(value);
              },
            ),
          ),
          
          // الإحصائيات السريعة
          _buildQuickStats(),
          
          // قائمة الحجوزات
          Expanded(
            child: Consumer<BookingProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (provider.bookings.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_note,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          provider.searchQuery.isEmpty 
                            ? 'لا توجد حجوزات بعد'
                            : 'لا توجد نتائج للبحث',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (provider.searchQuery.isEmpty)
                          ElevatedButton.icon(
                            onPressed: _addNewBooking,
                            icon: const Icon(Icons.add),
                            label: const Text('إضافة حجز جديد'),
                          ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.bookings.length,
                  itemBuilder: (context, index) {
                    final booking = provider.bookings[index];
                    return _buildBookingCard(booking);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewBooking,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Consumer<BookingProvider>(
      builder: (context, provider, child) {
        final stats = provider.getQuickStats();
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    'إجمالي الحجوزات',
                    '${stats['totalBookings']}',
                    Icons.event,
                    Colors.blue,
                  ),
                  _buildStatItem(
                    'جاهز',
                    '${stats['readyBookings']}',
                    Icons.check_circle,
                    Colors.green,
                  ),
                  _buildStatItem(
                    'جاري',
                    '${stats['inProgressBookings']}',
                    Icons.hourglass_empty,
                    Colors.orange,
                  ),
                  _buildStatItem(
                    'مكتمل',
                    '${stats['completedBookings']}',
                    Icons.done_all,
                    Colors.purple,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBookingCard(Booking booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _viewBookingDetails(booking),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الصف الأول: رقم الفاتورة والحالة
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'فاتورة #${booking.invoiceNumber}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildStatusChip(booking.status),
                ],
              ),
              const SizedBox(height: 8),
              
              // الصف الثاني: اسم العميل ونوع الحفلة
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      booking.customerName,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getEventTypeColor(booking.eventType).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      booking.eventType.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getEventTypeColor(booking.eventType),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // الصف الثالث: تاريخ الحفلة ورقم الجوال
              Row(
                children: [
                  Icon(Icons.event, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(booking.eventDate),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const Spacer(),
                  Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    booking.phoneNumber,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // الصف الرابع: المبالغ وشريط التقدم
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'المبلغ: ${booking.totalAmount.toStringAsFixed(0)} ريال',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: booking.paymentPercentage,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            booking.paymentPercentage >= 1.0 
                              ? Colors.green 
                              : Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'مدفوع: ${booking.paidAmount.toStringAsFixed(0)} - متبقي: ${booking.remainingAmount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleMenuAction(value, booking),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility),
                            SizedBox(width: 8),
                            Text('عرض التفاصيل'),
                          ],
                        ),
                      ),
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BookingStatus status) {
    Color color;
    switch (status) {
      case BookingStatus.ready:
        color = Colors.green;
        break;
      case BookingStatus.inProgress:
        color = Colors.orange;
        break;
      case BookingStatus.postponed:
        color = Colors.red;
        break;
      case BookingStatus.completed:
        color = Colors.purple;
        break;
      case BookingStatus.cancelled:
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getEventTypeColor(EventType eventType) {
    switch (eventType) {
      case EventType.women:
        return Colors.pink;
      case EventType.men:
        return Colors.blue;
      case EventType.graduation:
        return Colors.green;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _addNewBooking() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BookingFormScreen(),
      ),
    );
  }

  void _viewBookingDetails(Booking booking) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingDetailsScreen(booking: booking),
      ),
    );
  }

  void _handleMenuAction(String action, Booking booking) {
    switch (action) {
      case 'view':
        _viewBookingDetails(booking);
        break;
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingFormScreen(booking: booking),
          ),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(booking);
        break;
    }
  }

  void _showDeleteConfirmation(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف حجز ${booking.customerName}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<BookingProvider>().deleteBooking(booking.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حذف الحجز بنجاح')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

