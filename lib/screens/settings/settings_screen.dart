import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/settings_service.dart';
import '../../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SettingsService _settingsService;
  bool _isDarkMode = false;
  bool _isBiometricsEnabled = false;
  bool _areNotificationsEnabled = true;
  String _selectedLanguage = 'English';

  final List<String> _availableLanguages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Chinese',
    'Japanese'
  ];

  @override
  void initState() {
    super.initState();
    _settingsService = context.read<SettingsService>();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _isDarkMode = _settingsService.isDarkMode;
      _isBiometricsEnabled = _settingsService.useBiometrics;
      _areNotificationsEnabled = _settingsService.notificationsEnabled;
    });
  }

  Future<void> _requestNotificationPermission() async {
    final notificationService = NotificationService();
    await notificationService.requestPermissions();
    await _settingsService.setNotificationsEnabled(true);
    setState(() {
      _areNotificationsEnabled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildAppearanceSection(),
            _buildSecuritySection(),
            _buildNotificationsSection(),
            _buildLanguageSection(),
            _buildDataSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSection() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const ListTile(
            title: Text('Appearance'),
            leading: Icon(Icons.palette),
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Enable dark theme'),
            value: _isDarkMode,
            onChanged: (bool value) async {
              await _settingsService.setDarkMode(value);
              setState(() {
                _isDarkMode = value;
              });
            },
          ),
          ListTile(
            title: const Text('Text Size'),
            subtitle: const Text('Adjust text size'),
            leading: const Icon(Icons.text_fields),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Implement text size adjustment
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          const ListTile(
            title: Text('Security'),
            leading: Icon(Icons.security),
          ),
          SwitchListTile(
            title: const Text('Biometric Authentication'),
            subtitle: const Text('Use fingerprint or face ID'),
            value: _isBiometricsEnabled,
            onChanged: (bool value) async {
              await _settingsService.setUseBiometrics(value);
              setState(() {
                _isBiometricsEnabled = value;
              });
            },
          ),
          ListTile(
            title: const Text('Change Password'),
            leading: const Icon(Icons.lock),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to change password screen
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const ListTile(
            title: Text('Notifications'),
            leading: Icon(Icons.notifications),
          ),
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Enable push notifications'),
            value: _areNotificationsEnabled,
            onChanged: (bool value) async {
              if (value) {
                await _requestNotificationPermission();
              } else {
                await _settingsService.setNotificationsEnabled(value);
              }
              setState(() {
                _areNotificationsEnabled = value;
              });
            },
          ),
          ListTile(
            title: const Text('Notification Preferences'),
            subtitle: const Text('Configure notification types'),
            leading: const Icon(Icons.tune),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to notification preferences
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          const ListTile(
            title: Text('Language'),
            leading: Icon(Icons.language),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: _selectedLanguage,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Select Language',
              ),
              items: _availableLanguages.map((String language) {
                return DropdownMenuItem<String>(
                  value: language,
                  child: Text(language),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedLanguage = newValue;
                  });
                  // TODO: Implement language change
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSection() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const ListTile(
            title: Text('Data & Storage'),
            leading: Icon(Icons.storage),
          ),
          ListTile(
            title: const Text('Clear Cache'),
            subtitle: const Text('Free up space'),
            leading: const Icon(Icons.cleaning_services),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Implement cache clearing
            },
          ),
          ListTile(
            title: const Text('Export Data'),
            subtitle: const Text('Download your data'),
            leading: const Icon(Icons.download),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Implement data export
            },
          ),
        ],
      ),
    );
  }
}
