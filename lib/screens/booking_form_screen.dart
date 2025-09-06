import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/booking.dart';
import '../models/enums.dart';
import '../providers/booking_provider.dart';
import '../widgets/image_picker_widget.dart';

class BookingFormScreen extends StatefulWidget {
  final Booking? booking;
  final DateTime? preselectedDate;

  const BookingFormScreen({super.key, this.booking, this.preselectedDate});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late Booking _booking;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _booking = widget.booking ?? context.read<BookingProvider>().createNewBooking();
    
    // إذا تم تمرير تاريخ مسبق، استخدمه كتاريخ الحفلة
    if (widget.preselectedDate != null && widget.booking == null) {
      _booking.eventDate = widget.preselectedDate!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.booking == null ? 'إضافة حجز جديد' : 'تعديل حجز'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextFormField(
                      label: 'اسم العميل',
                      initialValue: _booking.customerName,
                      onChanged: (value) => _booking.customerName = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال اسم العميل';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      label: 'رقم الجوال',
                      initialValue: _booking.phoneNumber,
                      onChanged: (value) => _booking.phoneNumber = value,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال رقم الجوال';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDatePicker(
                      'تاريخ الحفلة',
                      _booking.eventDate,
                      (date) => setState(() => _booking.eventDate = date),
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownFormField<EventType>(
                      label: 'نوع الحفلة',
                      value: _booking.eventType,
                      items: EventType.values
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type.displayName),
                              ))
                          .toList(),
                      onChanged: (type) {
                        setState(() {
                          _booking.eventType = type!;
                          // تهيئة تفاصيل الحفلة بناءً على النوع المختار
                          _booking.womenDetails = null;
                          _booking.menDetails = null;
                          _booking.graduationDetails = null;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      label: 'الموظف المسؤول',
                      initialValue: _booking.responsibleEmployee,
                      onChanged: (value) => _booking.responsibleEmployee = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال اسم الموظف المسؤول';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      label: 'ملاحظات عامة',
                      initialValue: _booking.generalNotes,
                      onChanged: (value) => _booking.generalNotes = value,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // تفاصيل الحفلة بناءً على النوع
                    if (_booking.eventType == EventType.women)
                      _buildWomenPartyDetails()
                    else if (_booking.eventType == EventType.men)
                      _buildMenPartyDetails()
                    else if (_booking.eventType == EventType.graduation)
                      _buildGraduationDetails(),

                    const SizedBox(height: 16),

                    // إضافات الأثاث والخدمات
                    _buildGoldStandSection(),
                    _buildTablesSection(),
                    _buildPrintingSection(),
                    _buildSpeakerSection(),

                    const SizedBox(height: 16),

                    // الأجهزة الخاصة
                    _buildSpecialDevicesSection(),

                    const SizedBox(height: 16),

                    // اختيار الطاولات والكراسي
                    _buildTableChairSelectionSection(),

                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: _saveBooking,
                        child: const Text('حفظ الحجز'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildWomenPartyDetails() {
    _booking.womenDetails ??= WomenPartyDetails(decorationType: DecorationType.house);
    final details = _booking.womenDetails!;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تفاصيل حفلة النساء',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDropdownFormField<DecorationType>(
              label: 'نوع الديكور',
              value: details.decorationType,
              items: DecorationType.values
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.displayName),
                              ))
                          .toList(),
                      onChanged: (type) {
                        setState(() {
                          details.decorationType = type!;
                          details.hallName = null;
                          details.hallDecorations = null;
                          details.address = null;
                          details.floor = null;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      label: 'لون الورد',
                      initialValue: details.flowerColor,
                      onChanged: (value) => details.flowerColor = value,
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      label: 'عدد الأيام',
                      initialValue: details.numberOfDays.toString(),
                      onChanged: (value) => details.numberOfDays = int.tryParse(value) ?? 1,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    _buildImagePickerSection(
                      label: "صورة الديكور",
                      imageUrl: details.decorImageUrl,
                      onImagePicked: (url) {
                        setState(() {
                          details.decorImageUrl = url;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    if (details.decorationType == DecorationType.hall) ...[
                      _buildTextFormField(
                        label: 'اسم الصالة',
                        initialValue: details.hallName ?? '',
                        onChanged: (value) => details.hallName = value,
                        validator: (value) {
                          if (details.decorationType == DecorationType.hall && (value == null || value.isEmpty)) {
                            return 'الرجاء إدخال اسم الصالة';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildHallDecorationsSection(details.hallDecorations ??= HallDecorations()),
                    ] else ...[
                      _buildTextFormField(
                        label: 'العنوان',
                        initialValue: details.address ?? '',
                        onChanged: (value) => details.address = value,
                      ),
                      const SizedBox(height: 16),
                      _buildTextFormField(
                        label: 'الدور',
                        initialValue: details.floor ?? '',
                        onChanged: (value) => details.floor = value,
                      ),
                    ],
                  ],
                ),
              ),
            );
  }

  Widget _buildMenPartyDetails() {
    _booking.menDetails ??= MenPartyDetails(hallName: '', numberOfDays: 1, amount: 0.0);
    final details = _booking.menDetails!;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تفاصيل حفلة الرجال',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              label: 'اسم القاعة',
              initialValue: details.hallName,
              onChanged: (value) => details.hallName = value,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال اسم القاعة';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              label: 'عدد الأيام',
              initialValue: details.numberOfDays.toString(),
              onChanged: (value) => details.numberOfDays = int.tryParse(value) ?? 1,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              label: 'المبلغ',
              initialValue: details.amount.toStringAsFixed(0),
              onChanged: (value) => details.amount = double.tryParse(value) ?? 0.0,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildImagePickerSection(
              label: "صورة الديكور",
              imageUrl: details.decorImageUrl,
              onImagePicked: (url) {
                setState(() {
                  details.decorImageUrl = url;
                });
              },
              notes: details.decorNotes,
              onNotesChanged: (value) {
                setState(() {
                  details.decorNotes = value;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              label: 'ملاحظات إضافية',
              initialValue: details.notes,
              onChanged: (value) => details.notes = value,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraduationDetails() {
    _booking.graduationDetails ??= GraduationDetails(hallName: '', femaleGraduates: 0, maleGraduates: 0, amount: 0.0);
    final details = _booking.graduationDetails!;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تفاصيل حفلة التخرج',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              label: 'اسم القاعة',
              initialValue: details.hallName,
              onChanged: (value) => details.hallName = value,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال اسم القاعة';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              label: 'عدد الخريجات',
              initialValue: details.femaleGraduates.toString(),
              onChanged: (value) => details.femaleGraduates = int.tryParse(value) ?? 0,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              label: 'عدد الخريجين',
              initialValue: details.maleGraduates.toString(),
              onChanged: (value) => details.maleGraduates = int.tryParse(value) ?? 0,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildImagePickerSection(
              label: "صورة زينة الممر",
              imageUrl: details.corridorImageUrl,
              onImagePicked: (url) {
                setState(() {
                  details.corridorImageUrl = url;
                });
              },
              notes: details.corridorDecorNotes,
              onNotesChanged: (value) {
                setState(() {
                  details.corridorDecorNotes = value;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildChairOptionSection(details.chairOption ??= ChairOption()),
            const SizedBox(height: 16),
            _buildTextFormField(
              label: 'ملاحظات',
              initialValue: details.notes,
              onChanged: (value) => details.notes = value,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              label: 'المبلغ',
              initialValue: details.amount.toStringAsFixed(0),
              onChanged: (value) => details.amount = double.tryParse(value) ?? 0.0,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoldStandSection() {
    _booking.goldStand ??= GoldStand();
    final goldStand = _booking.goldStand!;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSwitchListTile(
              title: 'استند ذهب',
              value: goldStand.isSelected,
              onChanged: (value) {
                setState(() {
                  goldStand.isSelected = value;
                });
              },
            ),
            if (goldStand.isSelected) ...[
              const SizedBox(height: 16),
              _buildTextFormField(
                label: 'المبلغ',
                initialValue: goldStand.amount.toStringAsFixed(0),
                onChanged: (value) => goldStand.amount = double.tryParse(value) ?? 0.0,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildImagePickerSection(
                label: "صورة استند ذهب",
                imageUrl: goldStand.imageUrl,
                onImagePicked: (url) {
                  setState(() {
                    goldStand.imageUrl = url;
                  });
                },
                notes: goldStand.notes,
                onNotesChanged: (value) {
                  setState(() {
                    goldStand.notes = value;
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTablesSection() {
    _booking.tables ??= Tables();
    final tables = _booking.tables!;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSwitchListTile(
              title: 'طاولات',
              value: tables.isSelected,
              onChanged: (value) {
                setState(() {
                  tables.isSelected = value;
                });
              },
            ),
            if (tables.isSelected) ...[
              const SizedBox(height: 16),
              _buildTextFormField(
                label: 'المبلغ',
                initialValue: tables.amount.toStringAsFixed(0),
                onChanged: (value) => tables.amount = double.tryParse(value) ?? 0.0,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildImagePickerSection(
                label: "صورة الطاولات",
                imageUrl: tables.imageUrl,
                onImagePicked: (url) {
                  setState(() {
                    tables.imageUrl = url;
                  });
                },
                notes: tables.notes,
                onNotesChanged: (value) {
                  setState(() {
                    tables.notes = value;
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPrintingSection() {
    _booking.printing ??= Printing();
    final printing = _booking.printing!;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSwitchListTile(
              title: 'طباعة',
              value: printing.isSelected,
              onChanged: (value) {
                setState(() {
                  printing.isSelected = value;
                });
              },
            ),
            if (printing.isSelected) ...[
              const SizedBox(height: 16),
              _buildTextFormField(
                label: 'المبلغ',
                initialValue: printing.amount.toStringAsFixed(0),
                onChanged: (value) => printing.amount = double.tryParse(value) ?? 0.0,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                label: 'ملاحظات إضافية للطباعة',
                initialValue: printing.additionalNotes,
                onChanged: (value) => printing.additionalNotes = value,
                maxLines: 3,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSpeakerSection() {
    _booking.speaker ??= Speaker();
    final speaker = _booking.speaker!;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSwitchListTile(
              title: 'سماعة',
              value: speaker.isSelected,
              onChanged: (value) {
                setState(() {
                  speaker.isSelected = value;
                });
              },
            ),
            if (speaker.isSelected) ...[
              const SizedBox(height: 16),
              _buildTextFormField(
                label: 'المبلغ',
                initialValue: speaker.amount.toStringAsFixed(0),
                onChanged: (value) => speaker.amount = double.tryParse(value) ?? 0.0,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                label: 'ملاحظات السماعة',
                initialValue: speaker.notes,
                onChanged: (value) => speaker.notes = value,
                maxLines: 3,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialDevicesSection() {
    _booking.specialDevices ??= SpecialDevices();
    final devices = _booking.specialDevices!;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الأجهزة الخاصة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDeviceOption(
              title: 'جهاز دخان',
              isSelected: devices.smokeDevice?.isSelected ?? false,
              amount: devices.smokeDevice?.amount ?? 0.0,
              notes: devices.smokeDevice?.notes ?? '',
              imageUrl: devices.smokeDevice?.imageUrl,
              onChanged: (value) {
                setState(() {
                  devices.smokeDevice ??= SmokeDevice();
                  devices.smokeDevice!.isSelected = value;
                });
              },
              onAmountChanged: (value) {
                setState(() {
                  devices.smokeDevice ??= SmokeDevice();
                  devices.smokeDevice!.amount = value;
                });
              },
              onNotesChanged: (value) {
                setState(() {
                  devices.smokeDevice ??= SmokeDevice();
                  devices.smokeDevice!.notes = value;
                });
              },
              onImagePicked: (url) {
                setState(() {
                  devices.smokeDevice ??= SmokeDevice();
                  devices.smokeDevice!.imageUrl = url;
                });
              },
            ),
            _buildDeviceOption(
              title: 'جهاز ليزر',
              isSelected: devices.laserDevice?.isSelected ?? false,
              amount: devices.laserDevice?.amount ?? 0.0,
              notes: devices.laserDevice?.notes ?? '',
              imageUrl: devices.laserDevice?.imageUrl,
              onChanged: (value) {
                setState(() {
                  devices.laserDevice ??= LaserDevice();
                  devices.laserDevice!.isSelected = value;
                });
              },
              onAmountChanged: (value) {
                setState(() {
                  devices.laserDevice ??= LaserDevice();
                  devices.laserDevice!.amount = value;
                });
              },
              onNotesChanged: (value) {
                setState(() {
                  devices.laserDevice ??= LaserDevice();
                  devices.laserDevice!.notes = value;
                });
              },
              onImagePicked: (url) {
                setState(() {
                  devices.laserDevice ??= LaserDevice();
                  devices.laserDevice!.imageUrl = url;
                });
              },
            ),
            _buildDeviceOption(
              title: 'جهاز فولو',
              isSelected: devices.followDevice?.isSelected ?? false,
              amount: devices.followDevice?.amount ?? 0.0,
              notes: devices.followDevice?.notes ?? '',
              imageUrl: devices.followDevice?.imageUrl,
              onChanged: (value) {
                setState(() {
                  devices.followDevice ??= FollowDevice();
                  devices.followDevice!.isSelected = value;
                });
              },
              onAmountChanged: (value) {
                setState(() {
                  devices.followDevice ??= FollowDevice();
                  devices.followDevice!.amount = value;
                });
              },
              onNotesChanged: (value) {
                setState(() {
                  devices.followDevice ??= FollowDevice();
                  devices.followDevice!.notes = value;
                });
              },
              onImagePicked: (url) {
                setState(() {
                  devices.followDevice ??= FollowDevice();
                  devices.followDevice!.imageUrl = url;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceOption({
    required String title,
    required bool isSelected,
    required double amount,
    required String notes,
    String? imageUrl,
    required ValueChanged<bool> onChanged,
    required ValueChanged<double> onAmountChanged,
    required ValueChanged<String> onNotesChanged,
    required ValueChanged<String?> onImagePicked,
  }) {
    return Column(
      children: [
        _buildSwitchListTile(
          title: title,
          value: isSelected,
          onChanged: onChanged,
        ),
        if (isSelected) ...[
          const SizedBox(height: 16),
          _buildTextFormField(
            label: 'المبلغ',
            initialValue: amount.toStringAsFixed(0),
            onChanged: (value) => onAmountChanged(double.tryParse(value) ?? 0.0),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildTextFormField(
            label: 'ملاحظات',
            initialValue: notes,
            onChanged: onNotesChanged,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          _buildImagePickerSection(
            label: "صورة $title",
            imageUrl: imageUrl,
            onImagePicked: onImagePicked,
          ),
        ],
      ],
    );
  }

  Widget _buildTableChairSelectionSection() {
    _booking.tableChairSelection ??= TableChairSelection();
    final selection = _booking.tableChairSelection!;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'اختيار الطاولات والكراسي',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              label: 'نوع الطاولة',
              initialValue: selection.tableType,
              onChanged: (value) => selection.tableType = value,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              label: 'عدد الطاولات',
              initialValue: selection.tableCount.toString(),
              onChanged: (value) => selection.tableCount = int.tryParse(value) ?? 0,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              label: 'ملاحظات الطاولات',
              initialValue: selection.tableNotes,
              onChanged: (value) => selection.tableNotes = value,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              label: 'نوع الكرسي',
              initialValue: selection.chairType,
              onChanged: (value) => selection.chairType = value,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              label: 'عدد الكراسي',
              initialValue: selection.chairCount.toString(),
              onChanged: (value) => selection.chairCount = int.tryParse(value) ?? 0,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              label: 'ملاحظات الكراسي',
              initialValue: selection.chairNotes,
              onChanged: (value) => selection.chairNotes = value,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _buildImagePickerSection(
              label: "صورة الطاولات والكراسي",
              imageUrl: selection.imageUrl,
              onImagePicked: (url) {
                setState(() {
                  selection.imageUrl = url;
                });
              },
              notes: selection.notes,
              onNotesChanged: (value) {
                setState(() {
                  selection.notes = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveBooking() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      final bookingProvider = context.read<BookingProvider>();
      if (widget.booking == null) {
        _booking = _booking.copyWith(id: const Uuid().v4());
        _booking = _booking.copyWith(createdAt: DateTime.now());
        _booking = _booking.copyWith(createdBy: 'Admin'); // Placeholder
        _booking = _booking.copyWith(updatedAt: DateTime.now());
        _booking.updatedBy = 'Admin';
        await bookingProvider.addBooking(_booking);
      } else {
        _booking = _booking.copyWith(updatedAt: DateTime.now());
        _booking.updatedBy = 'Admin'; // Placeholder
        await bookingProvider.updateBooking(_booking);
      }
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Widget _buildTextFormField({
    required String label,
    required String initialValue,
    required ValueChanged<String> onChanged,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
    );
  }

  Widget _buildDatePicker(
    String label,
    DateTime initialDate,
    ValueChanged<DateTime> onDateSelected,
  ) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (picked != null && picked != initialDate) {
          onDateSelected(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_formatDate(initialDate)),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildDropdownFormField<T>( {
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _buildSwitchListTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildImagePickerSection({
    required String label,
    String? imageUrl,
    required ValueChanged<String?> onImagePicked,
    String? notes,
    ValueChanged<String>? onNotesChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ImagePickerWidget(
          initialImageUrl: imageUrl,
          onImageSelected: onImagePicked,
        ),
        if (onNotesChanged != null) ...[
          const SizedBox(height: 8),
          _buildTextFormField(
            label: 'ملاحظات $label',
            initialValue: notes ?? '',
            onChanged: onNotesChanged,
            maxLines: 3,
          ),
        ],
      ],
    );
  }

  Widget _buildHallDecorationsSection(HallDecorations hallDecorations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'تفاصيل زينة الصالة',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildImagePickerSection(
          label: "صورة زينة الممر",
          imageUrl: hallDecorations.corridorImageUrl,
          onImagePicked: (url) {
            setState(() {
              hallDecorations.corridorImageUrl = url;
            });
          },
          notes: hallDecorations.corridorNotes,
          onNotesChanged: (value) {
            setState(() {
              hallDecorations.corridorNotes = value;
            });
          },
        ),
        const SizedBox(height: 16),
        _buildImagePickerSection(
          label: "صورة زينة الدرج",
          imageUrl: hallDecorations.stairImageUrl,
          onImagePicked: (url) {
            setState(() {
              hallDecorations.stairImageUrl = url;
            });
          },
          notes: hallDecorations.stairNotes,
          onNotesChanged: (value) {
            setState(() {
              hallDecorations.stairNotes = value;
            });
          },
        ),
        const SizedBox(height: 16),
        _buildImagePickerSection(
          label: "صورة زينة المدخل",
          imageUrl: hallDecorations.entranceImageUrl,
          onImagePicked: (url) {
            setState(() {
              hallDecorations.entranceImageUrl = url;
            });
          },
          notes: hallDecorations.entranceNotes,
          onNotesChanged: (value) {
            setState(() {
              hallDecorations.entranceNotes = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildChairOptionSection(ChairOption chairOption) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSwitchListTile(
          title: 'كراسي إضافية',
          value: chairOption.isSelected,
          onChanged: (value) {
            setState(() {
              chairOption.isSelected = value;
            });
          },
        ),
        if (chairOption.isSelected) ...[
          const SizedBox(height: 16),
          _buildTextFormField(
            label: 'عدد الكراسي',
            initialValue: chairOption.chairCount.toString(),
            onChanged: (value) {
              setState(() {
                chairOption.chairCount = int.tryParse(value) ?? 0;
              });
            },
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildTextFormField(
            label: 'ملاحظات الكراسي',
            initialValue: chairOption.notes,
            onChanged: (value) {
              setState(() {
                chairOption.notes = value;
              });
            },
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          // Assuming imageUrls is a List<String> for multiple images
          // You might need a custom widget to handle multiple image picking
          // For simplicity, let's just show one for now or iterate if ImagePickerWidget supports it
          // Or, if it's always one image, change ChairOption.imageUrls to String?
          // For now, let's assume it's a single image for simplicity based on ImagePickerWidget
          _buildImagePickerSection(
            label: "صورة الكراسي الإضافية",
            imageUrl: chairOption.imageUrls.isNotEmpty ? chairOption.imageUrls.first : null,
            onImagePicked: (url) {
              setState(() {
                if (url != null) {
                  chairOption.imageUrls = [url];
                } else {
                  chairOption.imageUrls = [];
                }
              });
            },
          ),
        ],
      ],
    );
  }
}


