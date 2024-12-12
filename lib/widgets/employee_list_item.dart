import 'package:flutter/material.dart';
import '../models/employee.dart';

class EmployeeListItem extends StatelessWidget {
  final Employee employee;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EmployeeListItem({
    super.key,
    required this.employee,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          child: Text(
            employee.name.substring(0, 1).toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          employee.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(employee.position),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Email', employee.email),
                const SizedBox(height: 8),
                _buildInfoRow('Department', employee.department),
                const SizedBox(height: 8),
                if (employee.phoneNumber != null)
                  _buildInfoRow('Phone', employee.phoneNumber!),
                const SizedBox(height: 8),
                if (employee.address != null)
                  _buildInfoRow('Address', employee.address!),
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Joining Date',
                  employee.joiningDate.toString().split(' ')[0],
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Status',
                  employee.isActive ? 'Active' : 'Inactive',
                  isStatus: true,
                  isActive: employee.isActive,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {bool isStatus = false, bool isActive = true}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: isStatus
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    value,
                    style: const TextStyle(color: Colors.white),
                  ),
                )
              : Text(value),
        ),
      ],
    );
  }
}
