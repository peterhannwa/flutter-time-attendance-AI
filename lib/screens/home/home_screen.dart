import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../calendar/calendar_screen.dart';
import '../profile/profile_screen.dart';
import '../leave/leave_request_screen.dart';
import '../../services/auth_service.dart';
import '../../services/settings_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  Widget _buildScreen(BuildContext context) {
    final authService = context.watch<AuthService>();
    final user = authService.currentUser;
    
    if (user == null) {
      return const Center(child: Text('Please log in'));
    }

    switch (_selectedIndex) {
      case 0:
        return const CalendarScreen();
      case 1:
        return LeaveRequestScreen(employeeId: user.id);
      case 2:
        return const ProfileScreen();
      default:
        return const CalendarScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final settingsService = context.watch<SettingsService>();
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Management'),
        actions: [
          IconButton(
            icon: Icon(
              settingsService.isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () => settingsService.toggleTheme(),
          ),
        ],
      ),
      drawer: NavigationDrawer(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
          Navigator.pop(context);
        },
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  child: Text(
                    user?.name.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'User',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        user?.email ?? 'email@example.com',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(indent: 16, endIndent: 16),
          const NavigationDrawerDestination(
            icon: Icon(Icons.calendar_today),
            label: Text('Calendar'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.event_busy),
            label: Text('Leave Requests'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.person),
            label: Text('Profile'),
          ),
          const Divider(indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.settings),
                const SizedBox(width: 12),
                Text(
                  'Settings',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const Spacer(),
                Switch(
                  value: settingsService.isDarkMode,
                  onChanged: (value) => settingsService.toggleTheme(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: () => authService.signOut(),
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
            ),
          ),
        ],
      ),
      body: _buildScreen(context),
    );
  }
}
