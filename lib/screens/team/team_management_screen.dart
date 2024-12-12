import 'package:flutter/material.dart';

class TeamManagementScreen extends StatefulWidget {
  const TeamManagementScreen({super.key});

  @override
  State<TeamManagementScreen> createState() => _TeamManagementScreenState();
}

class _TeamManagementScreenState extends State<TeamManagementScreen> {
  final List<String> _departments = [
    'All',
    'Engineering',
    'Design',
    'Marketing',
    'Sales'
  ];
  String _selectedDepartment = 'All';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Team Management'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Members'),
              Tab(text: 'Requests'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTeamMembersTab(),
            _buildRequestsTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // TODO: Add new team member
          },
          child: const Icon(Icons.person_add),
        ),
      ),
    );
  }

  Widget _buildTeamMembersTab() {
    return Column(
      children: [
        _buildDepartmentFilter(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: 10,
            itemBuilder: (context, index) {
              return _buildTeamMemberCard(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDepartmentFilter() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            const Icon(Icons.filter_list),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedDepartment,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                ),
                items: _departments.map((String department) {
                  return DropdownMenuItem<String>(
                    value: department,
                    child: Text(department),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedDepartment = newValue;
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

  Widget _buildTeamMemberCard(int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ExpansionTile(
        leading: const CircleAvatar(
          child: Icon(Icons.person),
        ),
        title: Text('Team Member ${index + 1}'),
        subtitle: Text('${_departments[index % _departments.length]} Department'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildInfoRow('Email', 'member$index@example.com'),
                _buildInfoRow('Phone', '+1234567890'),
                _buildInfoRow('Join Date', '01/01/2024'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FilledButton.tonal(
                      onPressed: () {
                        // TODO: Edit member
                      },
                      child: const Text('Edit'),
                    ),
                    FilledButton.tonal(
                      onPressed: () {
                        // TODO: View attendance
                      },
                      child: const Text('Attendance'),
                    ),
                    FilledButton.tonal(
                      onPressed: () {
                        // TODO: View leaves
                      },
                      child: const Text('Leaves'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person_outline),
            ),
            title: Text('Request ${index + 1}'),
            subtitle: Text('Department: ${_departments[index % _departments.length]}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () {
                    // TODO: Approve request
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    // TODO: Reject request
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}
