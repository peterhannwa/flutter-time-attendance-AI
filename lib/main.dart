import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'services/settings_service.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/leave_service.dart';
import 'services/calendar_service.dart';
import 'services/employee_service.dart';
import 'services/attendance_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await NotificationService().initialize();
  final prefs = await SharedPreferences.getInstance();
  final calendarService = CalendarService();
  await calendarService.initialize();
  final leaveService = LeaveService();
  await leaveService.initialize();
  final employeeService = EmployeeService();
  await employeeService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsService()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => AttendanceService()),
        ChangeNotifierProvider(create: (_) => LeaveService()),
        ChangeNotifierProvider.value(value: leaveService),
        ChangeNotifierProvider.value(value: calendarService),
        Provider.value(value: employeeService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsService = context.watch<SettingsService>();
    final authService = context.watch<AuthService>();
    
    return MaterialApp(
      title: 'Employee Management',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settingsService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: authService.currentUser != null ? const HomeScreen() : const LoginScreen(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
          child: child!,
        );
      },
      localizationsDelegates: const [
        // Add localization delegates here
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('es', ''),
        // Add more locales as needed
      ],
    );
  }
}
