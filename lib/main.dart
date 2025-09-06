import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/booking_provider.dart';
import 'screens/home_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/lost_items_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/customer_screen.dart';
import 'screens/employee_screen.dart';
import 'providers/dashboard_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/employee_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/audit_provider.dart';
import 'widgets/notification_widget.dart';
import 'widgets/animated_page_transition.dart';

void main() {
  runApp(const EventBookingApp());
}

class EventBookingApp extends StatelessWidget {
  const EventBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AuditProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'نظام إدارة حجوزات الفعاليات',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.currentTheme,
            home: const MainNavigationScreen(),
          );
        },
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const CalendarScreen(),
    const LostItemsScreen(),
    const DashboardScreen(),
    const ReportsScreen(),
    const CustomerScreen(),
    const EmployeeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, NotificationProvider>(
      builder: (context, themeProvider, notificationProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('نظام إدارة حجوزات الفعاليات'),
            actions: [
              const NotificationWidget(),
              IconButton(
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: themeProvider.toggleTheme,
              ),
            ],
          ),
          body: AnimatedPageTransition(
            child: IndexedStack(
              key: ValueKey(_currentIndex),
              index: _currentIndex,
              children: _screens,
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'الرئيسية',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month),
                label: 'التقويم',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'المفقودات',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'لوحة المعلومات',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.description),
                label: 'التقارير',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people),
                label: 'العملاء',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'الموظفين',
              ),
            ],
          ),
        );
      },
    );
  }
}

