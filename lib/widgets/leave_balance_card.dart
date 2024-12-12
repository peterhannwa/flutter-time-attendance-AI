import 'package:flutter/material.dart';

class LeaveBalanceCard extends StatelessWidget {
  const LeaveBalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Leave Balance',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildLeaveType(
                    context,
                    'Annual',
                    14,
                    20,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildLeaveType(
                    context,
                    'Sick',
                    5,
                    10,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildLeaveType(
                    context,
                    'Personal',
                    2,
                    5,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: () {
                // TODO: Navigate to leave request screen
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add),
                  SizedBox(width: 8),
                  Text('Apply for Leave'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveType(
    BuildContext context,
    String type,
    int used,
    int total,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          type,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 64,
              width: 64,
              child: CircularProgressIndicator(
                value: used / total,
                backgroundColor: color.withOpacity(0.2),
                color: color,
              ),
            ),
            Text(
              '$used/$total',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}
