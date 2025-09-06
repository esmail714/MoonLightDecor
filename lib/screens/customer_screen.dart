import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/customer.dart';
import '../providers/customer_provider.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerProvider>().loadCustomers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة العملاء'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showCustomerForm(context);
            },
          ),
        ],
      ),
      body: Consumer<CustomerProvider>(
        builder: (context, customerProvider, child) {
          if (customerProvider.customers.isEmpty) {
            return const Center(
              child: Text('لا يوجد عملاء مسجلون بعد.'),
            );
          }
          return ListView.builder(
            itemCount: customerProvider.customers.length,
            itemBuilder: (context, index) {
              final customer = customerProvider.customers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(customer.name),
                  subtitle: Text(customer.phoneNumber),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _showCustomerForm(context, customer: customer);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _confirmDelete(context, customer);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showCustomerForm(BuildContext context, {Customer? customer}) {
    final nameController = TextEditingController(text: customer?.name);
    final phoneController = TextEditingController(text: customer?.phoneNumber);
    final emailController = TextEditingController(text: customer?.email);
    final addressController = TextEditingController(text: customer?.address);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(customer == null ? 'إضافة عميل جديد' : 'تعديل عميل'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'الاسم'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'رقم الجوال'),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'البريد الإلكتروني (اختياري)'),
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'العنوان (اختياري)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || phoneController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('الاسم ورقم الجوال مطلوبان.')),
                  );
                  return;
                }

                final newCustomer = Customer(
                  id: customer?.id,
                  name: nameController.text,
                  phoneNumber: phoneController.text,
                  email: emailController.text.isEmpty ? null : emailController.text,
                  address: addressController.text.isEmpty ? null : addressController.text,
                  registrationDate: customer?.registrationDate ?? DateTime.now(),
                );

                if (customer == null) {
                  await context.read<CustomerProvider>().addCustomer(newCustomer);
                } else {
                  await context.read<CustomerProvider>().updateCustomer(newCustomer);
                }
                if (mounted) Navigator.pop(context);
              },
              child: Text(customer == null ? 'إضافة' : 'حفظ'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد أنك تريد حذف العميل ${customer.name}؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                await context.read<CustomerProvider>().deleteCustomer(customer.id!);
                if (mounted) Navigator.pop(context);
              },
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );
  }
}

