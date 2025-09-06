import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../services/database_service.dart';

class EmployeeProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<Employee> _employees = [];

  List<Employee> get employees => _employees;

  Future<void> loadEmployees() async {
    _employees = await _databaseService.getEmployees();
    notifyListeners();
  }

  Future<void> addEmployee(Employee employee) async {
    await _databaseService.insertEmployee(employee);
    await loadEmployees();
  }

  Future<void> updateEmployee(Employee employee) async {
    await _databaseService.updateEmployee(employee);
    await loadEmployees();
  }

  Future<void> deleteEmployee(int id) async {
    await _databaseService.deleteEmployee(id);
    await loadEmployees();
  }

  Employee? getEmployeeById(int id) {
    try {
      return _employees.firstWhere((employee) => employee.id == id);
    } catch (e) {
      return null;
    }
  }
}

