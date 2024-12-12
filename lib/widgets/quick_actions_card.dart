import 'package:flutter/material.dart';

class QuickActionsCard extends StatelessWidget {
  const QuickActionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickAction(
                  context,
                  'Apply Leave',
                  Icons.calendar_today,
                  Colors.blue,
                  () {
                    // TODO: Navigate to leave application
                  },
                ),
                _buildQuickAction(
                  context,
                  'Team Calendar',
                  Icons.people,
                  Colors.green,
                  () {
                    // TODO: Navigate to team calendar
                  },
                ),
                _buildQuickAction(
                  context,
                  'Reports',
                  Icons.bar_chart,
                  Colors.orange,
                  () {
                    // TODO: Navigate to reports
                  },
                ),
                _buildQuickAction(
                  context,
                  'Settings',
                  Icons.settings,
                  Colors.purple,
                  () {
                    // TODO: Navigate to settings
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
