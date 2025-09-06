import 'package:flutter/material.dart';
import '../models/user_role.dart';
import '../models/employee.dart';

class AuthProvider extends ChangeNotifier {
  Employee? _currentUser;
  UserRole _currentRole = UserRole.employee;
  
  Employee? get currentUser => _currentUser;
  UserRole get currentRole => _currentRole;
  List<Permission> get currentPermissions => _currentRole.permissions;
  
  bool get isLoggedIn => _currentUser != null;
  
  void login(Employee user, UserRole role) {
    _currentUser = user;
    _currentRole = role;
    notifyListeners();
  }
  
  void logout() {
    _currentUser = null;
    _currentRole = UserRole.employee;
    notifyListeners();
  }
  
  bool hasPermission(Permission permission) {
    return currentPermissions.contains(permission);
  }
  
  bool canView(String resource) {
    switch (resource) {
      case 'bookings':
        return hasPermission(Permission.viewBookings);
      case 'customers':
        return hasPermission(Permission.viewCustomers);
      case 'employees':
        return hasPermission(Permission.viewEmployees);
      case 'payments':
        return hasPermission(Permission.viewPayments);
      case 'lost_items':
        return hasPermission(Permission.viewLostItems);
      case 'reports':
        return hasPermission(Permission.viewReports);
      case 'dashboard':
        return hasPermission(Permission.viewDashboard);
      case 'audit_log':
        return hasPermission(Permission.viewAuditLog);
      default:
        return false;
    }
  }
  
  bool canCreate(String resource) {
    switch (resource) {
      case 'bookings':
        return hasPermission(Permission.createBooking);
      case 'customers':
        return hasPermission(Permission.createCustomer);
      case 'employees':
        return hasPermission(Permission.createEmployee);
      case 'payments':
        return hasPermission(Permission.createPayment);
      case 'lost_items':
        return hasPermission(Permission.createLostItem);
      default:
        return false;
    }
  }
  
  bool canEdit(String resource) {
    switch (resource) {
      case 'bookings':
        return hasPermission(Permission.editBooking);
      case 'customers':
        return hasPermission(Permission.editCustomer);
      case 'employees':
        return hasPermission(Permission.editEmployee);
      case 'payments':
        return hasPermission(Permission.editPayment);
      case 'lost_items':
        return hasPermission(Permission.editLostItem);
      default:
        return false;
    }
  }
  
  bool canDelete(String resource) {
    switch (resource) {
      case 'bookings':
        return hasPermission(Permission.deleteBooking);
      case 'customers':
        return hasPermission(Permission.deleteCustomer);
      case 'employees':
        return hasPermission(Permission.deleteEmployee);
      case 'payments':
        return hasPermission(Permission.deletePayment);
      case 'lost_items':
        return hasPermission(Permission.deleteLostItem);
      default:
        return false;
    }
  }
  
  bool canExportData() {
    return hasPermission(Permission.exportData);
  }
  
  bool canManageUsers() {
    return hasPermission(Permission.manageUsers);
  }
  
  bool canAccessSystemSettings() {
    return hasPermission(Permission.systemSettings);
  }
  
  // محاكاة تسجيل الدخول للاختبار
  void simulateLogin({UserRole role = UserRole.admin}) {
    final mockUser = Employee(
      id: 1,
      name: 'مدير النظام',
      phone: '0501234567',
      role: role.displayName,
      permissions: role.permissions.map((p) => p.displayName).join(', '),
    );
    login(mockUser, role);
  }
}

