import 'package:flutter/material.dart';

class Customer {
  final int? id;
  final String name;
  final String phoneNumber;
  final String? email;
  final String? address;
  final DateTime? registrationDate;

  Customer({
    this.id,
    required this.name,
    required this.phoneNumber,
    this.email,
    this.address,
    this.registrationDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'address': address,
      'registrationDate': registrationDate?.toIso8601String(),
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as int?,
      name: map['name'] as String,
      phoneNumber: map['phoneNumber'] as String,
      email: map['email'] as String?,
      address: map['address'] as String?,
      registrationDate: map['registrationDate'] != null
          ? DateTime.parse(map['registrationDate'] as String)
          : null,
    );
  }

  Customer copyWith({
    int? id,
    String? name,
    String? phoneNumber,
    String? email,
    String? address,
    DateTime? registrationDate,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      registrationDate: registrationDate ?? this.registrationDate,
    );
  }
}

