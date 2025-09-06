import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/employee.dart';
import '../providers/employee_provider.dart';

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeProvider>().loadEmployees();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الموظفين'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showEmployeeForm(context);
            },
          ),
        ],
      ),
      body: Consumer<EmployeeProvider>(
        builder: (context, employeeProvider, child) {
          if (employeeProvider.employees.isEmpty) {
            return const Center(
              child: Text('لا يوجد موظفون مسجلون بعد.'),
            );
          }
          return ListView.builder(
            itemCount: employeeProvider.employees.length,
            itemBuilder: (context, index) {
              final employee = employeeProvider.employees[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(employee.name),
                  subtitle: Text('${employee.phoneNumber} - ${employee.role.displayName}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _showEmployeeForm(context, employee: employee);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _confirmDelete(context, employee);
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

  void _showEmployeeForm(BuildContext context, {Employee? employee}) {
    final nameController = TextEditingController(text: employee?.name);
    final phoneController = TextEditingController(text: employee?.phoneNumber);
    final emailController = TextEditingController(text: employee?.email);
    EmployeeRole selectedRole = employee?.role ?? EmployeeRole.staff;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(employee == null ? 'إضافة موظف جديد' : 'تعديل موظف'),
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
                DropdownButtonFormField<EmployeeRole>(
                  value: selectedRole,
                  decoration: const InputDecoration(labelText: 'الدور'),
                  items: EmployeeRole.values.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      selectedRole = value;
                    }
                  },
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

                final newEmployee = Employee(
                  id: employee?.id,
                  name: nameController.text,
                  phoneNumber: phoneController.text,
                  email: emailController.text.isEmpty ? null : emailController.text,
                  role: selectedRole,
                  hireDate: employee?.hireDate ?? DateTime.now(),
                );

                if (employee == null) {
                  await context.read<EmployeeProvider>().addEmployee(newEmployee);
                } else {
                  await context.read<EmployeeProvider>().updateEmployee(newEmployee);
                }
                if (mounted) Navigator.pop(context);
              },
              child: Text(employee == null ? 'إضافة' : 'حفظ'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, Employee employee) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد أنك تريد حذف الموظف ${employee.name}؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                await context.read<EmployeeProvider>().deleteEmployee(employee.id!);
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

