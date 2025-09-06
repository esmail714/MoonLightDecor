import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/booking_provider.dart';
import '../models/booking.dart';
import '../models/enums.dart';
import 'booking_details_screen.dart';
import 'booking_form_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final ValueNotifier<List<Booking>> _selectedBookings;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _selectedBookings = ValueNotifier(_getBookingsForDay(_selectedDay!));
    
    // تحميل الحجوزات عند بدء الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().loadBookings();
    });
  }

  @override
  void dispose() {
    _selectedBookings.dispose();
    super.dispose();
  }

  List<Booking> _getBookingsForDay(DateTime day) {
    final provider = context.read<BookingProvider>();
    return provider.bookings.where((booking) {
      return isSameDay(booking.eventDate, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقويم الحجوزات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
                _selectedBookings.value = _getBookingsForDay(_selectedDay!);
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<BookingProvider>().loadBookings();
              _selectedBookings.value = _getBookingsForDay(_selectedDay!);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // إحصائيات سريعة للشهر
          _buildMonthStats(),
          
          // التقويم
          Consumer<BookingProvider>(
            builder: (context, provider, child) {
              return TableCalendar<Booking>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                eventLoader: _getBookingsForDay,
                startingDayOfWeek: StartingDayOfWeek.saturday,
                
                // تخصيص المظهر
                calendarStyle: const CalendarStyle(
                  outsideDaysVisible: false,
                  weekendTextStyle: TextStyle(color: Colors.red),
                  holidayTextStyle: TextStyle(color: Colors.red),
                  selectedDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 3,
                ),
                
                // تخصيص رأس التقويم
                headerStyle: const HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                  formatButtonShowsNext: false,
                  formatButtonDecoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  ),
                  formatButtonTextStyle: TextStyle(
                    color: Colors.white,
                  ),
                ),
                
                // الأحداث
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    _selectedBookings.value = _getBookingsForDay(selectedDay);
                  }
                },
                
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                
                // تخصيص بناء المؤشرات
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, bookings) {
                    if (bookings.isNotEmpty) {
                      return _buildEventMarkers(bookings.cast<Booking>());
                    }
                    return null;
                  },
                ),
              );
            },
          ),
          
          const SizedBox(height: 8.0),
          
          // قائمة الحجوزات لليوم المحدد
          Expanded(
            child: ValueListenableBuilder<List<Booking>>(
              valueListenable: _selectedBookings,
              builder: (context, bookings, _) {
                return Column(
                  children: [
                    // عنوان القسم
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        border: Border(
                          bottom: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedDay != null
                                ? 'حجوزات يوم ${_formatDate(_selectedDay!)}'
                                : 'اختر يوماً لعرض الحجوزات',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (bookings.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${bookings.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    // قائمة الحجوزات
                    Expanded(
                      child: bookings.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.event_busy,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _selectedDay != null
                                        ? 'لا توجد حجوزات في هذا اليوم'
                                        : 'اختر يوماً لعرض الحجوزات',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  if (_selectedDay != null) ...[
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: () => _addBookingForDate(_selectedDay!),
                                      icon: const Icon(Icons.add),
                                      label: const Text('إضافة حجز لهذا اليوم'),
                                    ),
                                  ],
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: bookings.length,
                              itemBuilder: (context, index) {
                                final booking = bookings[index];
                                return _buildBookingCard(booking);
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedDay != null
          ? FloatingActionButton(
              onPressed: () => _addBookingForDate(_selectedDay!),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildMonthStats() {
    return Consumer<BookingProvider>(
      builder: (context, provider, child) {
        final monthBookings = provider.bookings.where((booking) {
          return booking.eventDate.year == _focusedDay.year &&
                 booking.eventDate.month == _focusedDay.month;
        }).toList();

        final stats = _calculateMonthStats(monthBookings);

        return Container(
          margin: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'إحصائيات ${_getMonthName(_focusedDay.month)} ${_focusedDay.year}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        'إجمالي',
                        '${stats['total']}',
                        Icons.event,
                        Colors.blue,
                      ),
                      _buildStatItem(
                        'جاهز',
                        '${stats['ready']}',
                        Icons.check_circle,
                        Colors.green,
                      ),
                      _buildStatItem(
                        'جاري',
                        '${stats['inProgress']}',
                        Icons.hourglass_empty,
                        Colors.orange,
                      ),
                      _buildStatItem(
                        'مكتمل',
                        '${stats['completed']}',
                        Icons.done_all,
                        Colors.purple,
                      ),
                    ],
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
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildEventMarkers(List<Booking> bookings) {
    return Positioned(
      right: 1,
      bottom: 1,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // مؤشر عدد الحجوزات
          if (bookings.length > 3)
            Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${bookings.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          else
            ...bookings.take(3).map((booking) => Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(left: 1),
              decoration: BoxDecoration(
                color: _getStatusColor(booking.status),
                shape: BoxShape.circle,
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _viewBookingDetails(booking),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // أيقونة نوع الحفلة
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getEventTypeColor(booking.eventType).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getEventTypeIcon(booking.eventType),
                  color: _getEventTypeColor(booking.eventType),
                ),
              ),
              const SizedBox(width: 12),
              
              // معلومات الحجز
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          booking.customerName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _buildStatusChip(booking.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'فاتورة #${booking.invoiceNumber}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      booking.eventType.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // سهم للتفاصيل
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BookingStatus status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.ready:
        return Colors.green;
      case BookingStatus.inProgress:
        return Colors.orange;
      case BookingStatus.postponed:
        return Colors.red;
      case BookingStatus.completed:
        return Colors.purple;
      case BookingStatus.cancelled:
        return Colors.grey;
    }
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

  IconData _getEventTypeIcon(EventType eventType) {
    switch (eventType) {
      case EventType.women:
        return Icons.woman;
      case EventType.men:
        return Icons.man;
      case EventType.graduation:
        return Icons.school;
    }
  }

  Map<String, int> _calculateMonthStats(List<Booking> bookings) {
    return {
      'total': bookings.length,
      'ready': bookings.where((b) => b.status == BookingStatus.ready).length,
      'inProgress': bookings.where((b) => b.status == BookingStatus.inProgress).length,
      'completed': bookings.where((b) => b.status == BookingStatus.completed).length,
    };
  }

  String _getMonthName(int month) {
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return months[month - 1];
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _viewBookingDetails(Booking booking) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingDetailsScreen(booking: booking),
      ),
    );
  }

  void _addBookingForDate(DateTime date) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingFormScreen(preselectedDate: date),
      ),
    ).then((_) {
      // تحديث قائمة الحجوزات بعد العودة
      if (mounted) {
        context.read<BookingProvider>().loadBookings();
        _selectedBookings.value = _getBookingsForDay(_selectedDay!);
      }
    });
  }
}

