import 'package:flutter/material.dart';

class AttendanceCard extends StatelessWidget {
  const AttendanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Attendance',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAttendanceInfo(
                  context,
                  'Check In',
                  '09:00 AM',
                  Icons.login,
                ),
                const SizedBox(
                  height: 40,
                  child: VerticalDivider(),
                ),
                _buildAttendanceInfo(
                  context,
                  'Check Out',
                  '--:--',
                  Icons.logout,
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: () {
                // TODO: Implement check out
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout),
                  SizedBox(width: 8),
                  Text('Check Out'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceInfo(
    BuildContext context,
    String label,
    String time,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}
