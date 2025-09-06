import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../providers/booking_provider.dart';
import '../models/booking.dart';
import '../models/payment.dart';
import '../models/enums.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReportCard(
              title: 'تقرير الحجوزات اليومية',
              description: 'إنشاء تقرير بجميع الحجوزات ليوم محدد.',
              icon: Icons.calendar_today,
              onGenerate: _generateDailyBookingsReport,
            ),
            const SizedBox(height: 16),
            _buildReportCard(
              title: 'تقرير الحجوزات الشهرية',
              description: 'إنشاء تقرير بجميع الحجوزات لشهر محدد.',
              icon: Icons.calendar_month,
              onGenerate: _generateMonthlyBookingsReport,
            ),
            const SizedBox(height: 16),
            _buildReportCard(
              title: 'تقرير الدفعات',
              description: 'إنشاء تقرير بجميع الدفعات المسجلة.',
              icon: Icons.payments,
              onGenerate: _generatePaymentsReport,
            ),
            const SizedBox(height: 16),
            _buildReportCard(
              title: 'طباعة تفاصيل حجز فردي',
              description: 'طباعة تفاصيل حجز محدد.',
              icon: Icons.print,
              onGenerate: _printSingleBookingDetails,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard({
    required String title,
    required String description,
    required IconData icon,
    required Function() onGenerate,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 30, color: Colors.blue),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton.icon(
                onPressed: onGenerate,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('إنشاء التقرير'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateDailyBookingsReport() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selectedDate == null) return;

    setState(() {
      _selectedDate = selectedDate;
    });

    final bookings = await context.read<BookingProvider>().getBookingsByDate(selectedDate);

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('تقرير الحجوزات اليومية - ${_formatDate(selectedDate)}',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              if (bookings.isEmpty)
                pw.Text('لا توجد حجوزات لهذا اليوم.')
              else
                pw.Table.fromTextArray(
                  headers: ['رقم الفاتورة', 'اسم العميل', 'نوع الحفلة', 'المبلغ الإجمالي', 'الحالة'],
                  data: bookings.map((booking) => [
                    booking.invoiceNumber.toString(),
                    booking.customerName,
                    booking.eventType.displayName,
                    '${booking.totalAmount.toStringAsFixed(0)} ريال',
                    booking.status.displayName,
                  ]).toList(),
                  border: pw.TableBorder.all(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  cellAlignment: pw.Alignment.centerRight,
                  cellPadding: const pw.EdgeInsets.all(5),
                ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  Future<void> _generateMonthlyBookingsReport() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.blue, onPrimary: Colors.white, surface: Colors.white, onSurface: Colors.black),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (selectedDate == null) return;

    setState(() {
      _selectedDate = selectedDate;
    });

    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final lastDayOfMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0);

    final bookings = await context.read<BookingProvider>().getBookingsByMonth(firstDayOfMonth, lastDayOfMonth);

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('تقرير الحجوزات الشهرية - ${_getMonthName(selectedDate.month)} ${selectedDate.year}',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              if (bookings.isEmpty)
                pw.Text('لا توجد حجوزات لهذا الشهر.')
              else
                pw.Table.fromTextArray(
                  headers: ['رقم الفاتورة', 'اسم العميل', 'نوع الحفلة', 'تاريخ الحفلة', 'المبلغ الإجمالي', 'الحالة'],
                  data: bookings.map((booking) => [
                    booking.invoiceNumber.toString(),
                    booking.customerName,
                    booking.eventType.displayName,
                    _formatDate(booking.eventDate),
                    '${booking.totalAmount.toStringAsFixed(0)} ريال',
                    booking.status.displayName,
                  ]).toList(),
                  border: pw.TableBorder.all(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  cellAlignment: pw.Alignment.centerRight,
                  cellPadding: const pw.EdgeInsets.all(5),
                ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  Future<void> _generatePaymentsReport() async {
    final payments = await context.read<BookingProvider>().getAllPayments();

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('تقرير الدفعات',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              if (payments.isEmpty)
                pw.Text('لا توجد دفعات مسجلة.')
              else
                pw.Table.fromTextArray(
                  headers: ['رقم الدفعة', 'المبلغ', 'طريقة الدفع', 'تاريخ الدفع', 'ملاحظات'],
                  data: payments.map((payment) => [
                    payment.id,
                    '${payment.amount.toStringAsFixed(0)} ريال',
                    payment.paymentMethod.displayName,
                    _formatDate(payment.paymentDate),
                    payment.notes.isNotEmpty ? payment.notes : '-',
                  ]).toList(),
                  border: pw.TableBorder.all(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  cellAlignment: pw.Alignment.centerRight,
                  cellPadding: const pw.EdgeInsets.all(5),
                ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  Future<void> _printSingleBookingDetails() async {
    final bookingProvider = context.read<BookingProvider>();
    final allBookings = await bookingProvider.loadBookings(); // Assuming this loads all bookings

    if (allBookings.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا توجد حجوزات لطباعتها.')),
        );
      }
      return;
    }

    // Show a dialog to select a booking
    Booking? selectedBooking = await showDialog<Booking>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('اختر الحجز للطباعة'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: allBookings.length,
              itemBuilder: (BuildContext context, int index) {
                final booking = allBookings[index];
                return ListTile(
                  title: Text('حجز #${booking.invoiceNumber} - ${booking.customerName}'),
                  subtitle: Text('${booking.eventType.displayName} - ${_formatDate(booking.eventDate)}'),
                  onTap: () {
                    Navigator.pop(context, booking);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
          ],
        );
      },
    );

    if (selectedBooking == null) return;

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('تفاصيل الحجز - #${selectedBooking.invoiceNumber}',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              _buildPdfInfoRow('اسم العميل', selectedBooking.customerName),
              _buildPdfInfoRow('رقم الجوال', selectedBooking.phoneNumber),
              _buildPdfInfoRow('تاريخ الحفلة', _formatDate(selectedBooking.eventDate)),
              _buildPdfInfoRow('نوع الحفلة', selectedBooking.eventType.displayName),
              _buildPdfInfoRow('العامل المسؤول', selectedBooking.responsibleEmployee),
              if (selectedBooking.generalNotes.isNotEmpty)
                _buildPdfInfoRow('ملاحظات عامة', selectedBooking.generalNotes),
              pw.SizedBox(height: 20),
              pw.Text('تفاصيل الدفعات:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              FutureBuilder<List<Payment>>(
                future: context.read<BookingProvider>().getBookingPayments(selectedBooking.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return pw.Text('جاري تحميل الدفعات...');
                  }
                  if (snapshot.hasError) {
                    return pw.Text('خطأ في تحميل الدفعات: ${snapshot.error}');
                  }
                  final payments = snapshot.data ?? [];
                  if (payments.isEmpty) {
                    return pw.Text('لا توجد دفعات مسجلة لهذا الحجز.');
                  }
                  return pw.Table.fromTextArray(
                    headers: ['المبلغ', 'طريقة الدفع', 'تاريخ الدفع'],
                    data: payments.map((payment) => [
                      '${payment.amount.toStringAsFixed(0)} ريال',
                      payment.paymentMethod.displayName,
                      _formatDate(payment.paymentDate),
                    ]).toList(),
                    border: pw.TableBorder.all(),
                    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    cellAlignment: pw.Alignment.centerRight,
                    cellPadding: const pw.EdgeInsets.all(5),
                  );
                },
              ).build(context), // Important to call build on FutureBuilder result
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  pw.Widget _buildPdfInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('$label: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Expanded(
            child: pw.Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getMonthName(int month) {
    const monthNames = [
      '', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return monthNames[month];
  }
}


