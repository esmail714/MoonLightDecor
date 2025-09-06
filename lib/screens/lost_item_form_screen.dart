import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lost_item.dart';
import '../models/booking.dart';
import '../providers/booking_provider.dart';

class LostItemFormScreen extends StatefulWidget {
  final LostItem? lostItem;

  const LostItemFormScreen({super.key, this.lostItem});

  @override
  State<LostItemFormScreen> createState() => _LostItemFormScreenState();
}

class _LostItemFormScreenState extends State<LostItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late LostItem _lostItem;
  late TextEditingController _dateController;
  Booking? _selectedBooking;

  @override
  void initState() {
    super.initState();
    _lostItem = widget.lostItem ??
        LostItem(
          description: '',
          dateFound: DateTime.now(),
          locationFound: '',
          status: LostItemStatus.pending,
        );
    _dateController = TextEditingController(
        text: _formatDate(_lostItem.dateFound));

    if (_lostItem.bookingId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<BookingProvider>().getBookingById(_lostItem.bookingId!).then((booking) {
          setState(() {
            _selectedBooking = booking;
          });
        });
      });
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _lostItem.dateFound,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _lostItem.dateFound) {
      setState(() {
        _lostItem.dateFound = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _saveLostItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final provider = context.read<BookingProvider>();
      if (widget.lostItem == null) {
        await provider.addLostItem(_lostItem);
      } else {
        await provider.updateLostItem(_lostItem);
      }
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lostItem == null ? 'إضافة مفقود جديد' : 'تعديل مفقود'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: _lostItem.description,
                decoration: const InputDecoration(
                  labelText: 'الوصف',
                  hintText: 'وصف المفقود (مثال: محفظة جلدية سوداء)',
                ),
                maxLines: 3,
                onSaved: (value) => _lostItem.description = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال وصف للمفقود';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'تاريخ العثور',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء اختيار تاريخ العثور';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                initialValue: _lostItem.locationFound,
                decoration: const InputDecoration(
                  labelText: 'مكان العثور',
                  hintText: 'مثال: قاعة الأفراح، بهو الفندق',
                ),
                onSaved: (value) => _lostItem.locationFound = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال مكان العثور';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<LostItemStatus>(
                value: _lostItem.status,
                decoration: const InputDecoration(
                  labelText: 'الحالة',
                ),
                items: LostItemStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.displayName),
                  );
                }).toList(),
                onChanged: (status) {
                  setState(() {
                    _lostItem.status = status!;
                  });
                },
                onSaved: (status) => _lostItem.status = status!,
              ),
              const SizedBox(height: 16.0),
              // حقل لربط المفقود بحجز (اختياري)
              Consumer<BookingProvider>(
                builder: (context, provider, child) {
                  return DropdownButtonFormField<Booking?>(
                    decoration: const InputDecoration(
                      labelText: 'ربط بحجز (اختياري)',
                    ),
                    value: _selectedBooking,
                    hint: const Text('اختر حجزًا'),
                    items: [null, ...provider.bookings].map((booking) {
                      return DropdownMenuItem<Booking?>(
                        value: booking,
                        child: Text(booking == null
                            ? 'لا يوجد حجز مرتبط'
                            : 'فاتورة #${booking.invoiceNumber} - ${booking.customerName}'),
                      );
                    }).toList(),
                    onChanged: (booking) {
                      setState(() {
                        _selectedBooking = booking;
                        _lostItem.bookingId = booking?.id;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 24.0),
              Center(
                child: ElevatedButton(
                  onPressed: _saveLostItem,
                  child: Text(widget.lostItem == null ? 'إضافة مفقود' : 'تعديل مفقود'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

