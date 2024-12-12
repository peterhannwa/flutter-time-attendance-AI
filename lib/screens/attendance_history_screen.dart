import 'package:flutter/material.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  final List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  String _selectedMonth = 'December';
  int _selectedYear = 2024;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () {
              // TODO: Implement export functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildMonthYearPicker(),
          _buildStatisticsCards(),
          const Divider(),
          Expanded(
            child: _buildAttendanceList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthYearPicker() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedMonth,
                decoration: const InputDecoration(
                  labelText: 'Month',
                  border: OutlineInputBorder(),
                ),
                items: _months.map((String month) {
                  return DropdownMenuItem<String>(
                    value: month,
                    child: Text(month),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedMonth = newValue;
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<int>(
                value: _selectedYear,
                decoration: const InputDecoration(
                  labelText: 'Year',
                  border: OutlineInputBorder(),
                ),
                items: List<int>.generate(5, (i) => 2024 - i).map((int year) {
                  return DropdownMenuItem<int>(
                    value: year,
                    child: Text(year.toString()),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedYear = newValue;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Present Days',
              '22',
              Colors.green,
              Icons.check_circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Late Days',
              '3',
              Colors.orange,
              Icons.access_time,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Absent Days',
              '1',
              Colors.red,
              Icons.cancel,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 30,
      itemBuilder: (context, index) {
        final date = DateTime.now().subtract(Duration(days: index));
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: index % 3 == 0
                  ? Colors.green.withOpacity(0.1)
                  : index % 3 == 1
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
              child: Icon(
                index % 3 == 0
                    ? Icons.check
                    : index % 3 == 1
                        ? Icons.access_time
                        : Icons.close,
                color: index % 3 == 0
                    ? Colors.green
                    : index % 3 == 1
                        ? Colors.orange
                        : Colors.red,
              ),
            ),
            title: Text(
              '${date.day}/${date.month}/${date.year}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: Text(
              index % 3 == 0
                  ? 'Check-in: 9:00 AM - Check-out: 6:00 PM'
                  : index % 3 == 1
                      ? 'Late Check-in: 9:30 AM - Check-out: 6:30 PM'
                      : 'Absent',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                // TODO: Show attendance details
              },
            ),
          ),
        );
      },
    );
  }
}
