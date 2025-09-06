import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/payment.dart';
import '../models/enums.dart';

class EnhancedPaymentDialog extends StatefulWidget {
  final Payment? payment; // null للإضافة، موجود للتعديل
  final String bookingId;
  final Function(Payment) onSave;

  const EnhancedPaymentDialog({
    super.key,
    this.payment,
    required this.bookingId,
    required this.onSave,
  });

  @override
  State<EnhancedPaymentDialog> createState() => _EnhancedPaymentDialogState();
}

class _EnhancedPaymentDialogState extends State<EnhancedPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _checkNumberController = TextEditingController();
  final _cardLastFourController = TextEditingController();
  final _referenceNumberController = TextEditingController();

  PaymentMethod _selectedMethod = PaymentMethod.cash;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    if (widget.payment != null) {
      _initializeWithExistingPayment();
    }
  }

  void _initializeWithExistingPayment() {
    final payment = widget.payment!;
    _amountController.text = payment.amount.toString();
    _notesController.text = payment.notes;
    _selectedMethod = payment.paymentMethod;
    _selectedDate = payment.paymentDate;
    _selectedTime = TimeOfDay.fromDateTime(payment.paymentDate);
    
    _checkNumberController.text = payment.checkNumber ?? '';
    _cardLastFourController.text = payment.cardLastFour ?? '';
    _referenceNumberController.text = payment.referenceNumber ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.payment == null ? 'إضافة دفعة جديدة' : 'تعديل الدفعة'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // المبلغ
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'المبلغ *',
                  prefixIcon: Icon(Icons.attach_money),
                  suffixText: 'ريال',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال المبلغ';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'الرجاء إدخال مبلغ صحيح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // طريقة الدفع
              DropdownButtonFormField<PaymentMethod>(
                value: _selectedMethod,
                decoration: const InputDecoration(
                  labelText: 'طريقة الدفع *',
                  prefixIcon: Icon(Icons.payment),
                ),
                items: PaymentMethod.values.map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Row(
                      children: [
                        Icon(_getPaymentMethodIcon(method)),
                        const SizedBox(width: 8),
                        Text(method.displayName),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMethod = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // حقول إضافية حسب طريقة الدفع
              ..._buildPaymentMethodSpecificFields(),

              // التاريخ والوقت
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('التاريخ'),
                      subtitle: Text(_formatDate(_selectedDate)),
                      leading: const Icon(Icons.calendar_today),
                      onTap: _selectDate,
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('الوقت'),
                      subtitle: Text(_selectedTime.format(context)),
                      leading: const Icon(Icons.access_time),
                      onTap: _selectTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // الملاحظات
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'ملاحظات (اختياري)',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _savePayment,
          child: Text(widget.payment == null ? 'إضافة' : 'حفظ'),
        ),
      ],
    );
  }

  List<Widget> _buildPaymentMethodSpecificFields() {
    switch (_selectedMethod) {
      case PaymentMethod.check:
        return [
          TextFormField(
            controller: _checkNumberController,
            decoration: const InputDecoration(
              labelText: 'رقم الشيك',
              prefixIcon: Icon(Icons.receipt),
            ),
            validator: (value) {
              if (_selectedMethod == PaymentMethod.check && 
                  (value == null || value.isEmpty)) {
                return 'الرجاء إدخال رقم الشيك';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
        ];

      case PaymentMethod.card:
        return [
          TextFormField(
            controller: _cardLastFourController,
            decoration: const InputDecoration(
              labelText: 'آخر 4 أرقام البطاقة',
              prefixIcon: Icon(Icons.credit_card),
            ),
            keyboardType: TextInputType.number,
            maxLength: 4,
            validator: (value) {
              if (_selectedMethod == PaymentMethod.card && 
                  (value == null || value.length != 4)) {
                return 'الرجاء إدخال آخر 4 أرقام البطاقة';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
        ];

      case PaymentMethod.transfer:
        return [
          TextFormField(
            controller: _referenceNumberController,
            decoration: const InputDecoration(
              labelText: 'رقم الحوالة المرجعي',
              prefixIcon: Icon(Icons.confirmation_number),
            ),
          ),
          const SizedBox(height: 16),
        ];

      case PaymentMethod.cash:
      default:
        return [];
    }
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _savePayment() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      final paymentDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final payment = Payment(
        id: widget.payment?.id ?? const Uuid().v4(),
        bookingId: widget.bookingId,
        amount: amount,
        paymentMethod: _selectedMethod,
        paymentDate: paymentDateTime,
        notes: _notesController.text,
        checkNumber: _selectedMethod == PaymentMethod.check 
            ? _checkNumberController.text 
            : null,
        cardLastFour: _selectedMethod == PaymentMethod.card 
            ? _cardLastFourController.text 
            : null,
        referenceNumber: _selectedMethod == PaymentMethod.transfer 
            ? _referenceNumberController.text 
            : null,
        createdAt: widget.payment?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: widget.payment?.createdBy ?? 'Admin',
        updatedBy: 'Admin',
      );

      widget.onSave(payment);
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _checkNumberController.dispose();
    _cardLastFourController.dispose();
    _referenceNumberController.dispose();
    super.dispose();
  }
}

