import 'package:flutter/material.dart';
import '../../models/employee.dart';
import '../../services/employee_service.dart';
import '../../widgets/employee_list_item.dart';
import 'add_employee_screen.dart';

class EmployeeManagementScreen extends StatefulWidget {
  const EmployeeManagementScreen({super.key});

  @override
  State<EmployeeManagementScreen> createState() => _EmployeeManagementScreenState();
}

class _EmployeeManagementScreenState extends State<EmployeeManagementScreen> {
  final EmployeeService _employeeService = EmployeeService();
  String _searchQuery = '';
  String _selectedDepartment = 'All';
  List<Employee> _employees = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() => _isLoading = true);
    try {
      if (_selectedDepartment == 'All') {
        _employees = await _employeeService.getAllEmployees();
      } else {
        _employees = await _employeeService.getEmployeesByDepartment(_selectedDepartment);
      }

      if (_searchQuery.isNotEmpty) {
        _employees = await _employeeService.searchEmployees(_searchQuery);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading employees: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEmployeeScreen(),
                ),
              );
              if (result == true) {
                _loadEmployees();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search employees...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                      _loadEmployees();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedDepartment,
                  items: ['All', 'Engineering', 'HR', 'Marketing', 'Sales']
                      .map((String department) {
                    return DropdownMenuItem(
                      value: department,
                      child: Text(department),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() => _selectedDepartment = value);
                      _loadEmployees();
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _employees.isEmpty
                    ? const Center(child: Text('No employees found'))
                    : ListView.builder(
                        itemCount: _employees.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final employee = _employees[index];
                          return EmployeeListItem(
                            employee: employee,
                            onEdit: () async {
                              // Navigate to edit screen
                            },
                            onDelete: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Confirm Delete'),
                                  content: Text(
                                    'Are you sure you want to delete ${employee.name}?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await _employeeService.deleteEmployee(employee.id);
                                _loadEmployees();
                              }
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
