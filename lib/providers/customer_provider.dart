import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../services/database_service.dart';

class CustomerProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<Customer> _customers = [];

  List<Customer> get customers => _customers;

  Future<void> loadCustomers() async {
    _customers = await _databaseService.getCustomers();
    notifyListeners();
  }

  Future<void> addCustomer(Customer customer) async {
    await _databaseService.insertCustomer(customer);
    await loadCustomers();
  }

  Future<void> updateCustomer(Customer customer) async {
    await _databaseService.updateCustomer(customer);
    await loadCustomers();
  }

  Future<void> deleteCustomer(int id) async {
    await _databaseService.deleteCustomer(id);
    await loadCustomers();
  }

  Customer? getCustomerById(int id) {
    try {
      return _customers.firstWhere((customer) => customer.id == id);
    } catch (e) {
      return null;
    }
  }
}

