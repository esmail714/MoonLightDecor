import 'package:flutter/material.dart';

enum EmployeeRole {
  admin,
  manager,
  staff,
}

extension EmployeeRoleExtension on EmployeeRole {
  String get displayName {
    switch (this) {
      case EmployeeRole.admin:
        return 'مدير';
      case EmployeeRole.manager:
        return 'مشرف';
      case EmployeeRole.staff:
        return 'موظف';
    }
  }
}

class Employee {
  final int? id;
  final String name;
  final String phoneNumber;
  final String? email;
  final EmployeeRole role;
  final DateTime? hireDate;

  Employee({
    this.id,
    required this.name,
    required this.phoneNumber,
    this.email,
    required this.role,
    this.hireDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'role': role.name, // Store enum name as string
      'hireDate': hireDate?.toIso8601String(),
    };
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'] as int?,
      name: map['name'] as String,
      phoneNumber: map['phoneNumber'] as String,
      email: map['email'] as String?,
      role: EmployeeRole.values.firstWhere(
          (e) => e.name == map['role'] as String,
          orElse: () => EmployeeRole.staff), // Default to staff if not found
      hireDate: map['hireDate'] != null
          ? DateTime.parse(map['hireDate'] as String)
          : null,
    );
  }

  Employee copyWith({
    int? id,
    String? name,
    String? phoneNumber,
    String? email,
    EmployeeRole? role,
    DateTime? hireDate,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      role: role ?? this.role,
      hireDate: hireDate ?? this.hireDate,
    );
  }
}

