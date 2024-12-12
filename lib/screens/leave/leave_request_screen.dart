import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/leave_request.dart';
import '../../models/leave_balance.dart';
import '../../services/leave_service.dart';
import '../../services/employee_service.dart';
import '../../widgets/custom_date_picker.dart';

class LeaveRequestScreen extends StatefulWidget {
  final String employeeId;

  const LeaveRequestScreen({
    super.key,
    required this.employeeId,
  });

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final LeaveService _leaveService = LeaveService();
  final EmployeeService _employeeService = EmployeeService();

  LeaveType _selectedType = LeaveType.annual;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  final TextEditingController _reasonController = TextEditingController();
  List<String> _attachments = [];
  bool _isLoading = false;
  LeaveBalance? _leaveBalance;

  @override
  void initState() {
    super.initState();
    _loadLeaveBalance();
  }

  Future<void> _loadLeaveBalance() async {
    setState(() => _isLoading = true);
    try {
      _leaveBalance = await _leaveService.getEmployeeLeaveBalance(
        widget.employeeId,
        DateTime.now().year,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading leave balance: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        setState(() {
          _attachments.addAll(result.files.map((file) => file.path!));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking files: $e')),
      );
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final manager = await _employeeService.getEmployeeById(widget.employeeId);
      
      final request = LeaveRequest(
        employeeId: widget.employeeId,
        type: _selectedType,
        startDate: _startDate,
        endDate: _endDate,
        reason: _reasonController.text,
        approverId: manager?.managerId,
        attachments: _attachments,
      );

      await _leaveService.submitLeaveRequest(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Leave request submitted successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting request: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Leave'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_leaveBalance != null) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Leave Balance',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ..._leaveBalance!.quotas.entries.map(
                                (entry) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(entry.key.split('.').last),
                                      Text(
                                        '${entry.value.remaining} days remaining',
                                        style: TextStyle(
                                          color: entry.value.hasBalance
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    DropdownButtonFormField<LeaveType>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Leave Type',
                      ),
                      items: LeaveType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.toString().split('.').last),
                        );
                      }).toList(),
                      onChanged: (LeaveType? value) {
                        if (value != null) {
                          setState(() => _selectedType = value);
                        }
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a leave type';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomDatePicker(
                            label: 'Start Date',
                            selectedDate: _startDate,
                            onDateSelected: (date) {
                              setState(() => _startDate = date);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomDatePicker(
                            label: 'End Date',
                            selectedDate: _endDate,
                            onDateSelected: (date) {
                              setState(() => _endDate = date);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _reasonController,
                      decoration: const InputDecoration(
                        labelText: 'Reason',
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a reason';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickFiles,
                          icon: const Icon(Icons.attach_file),
                          label: const Text('Add Attachments'),
                        ),
                      ],
                    ),
                    if (_attachments.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Card(
                        child: Column(
                          children: _attachments.map((path) {
                            return ListTile(
                              title: Text(path.split('/').last),
                              trailing: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  setState(() {
                                    _attachments.remove(path);
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitRequest,
                        child: const Text('Submit Request'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }
}
