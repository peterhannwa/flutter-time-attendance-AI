import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/report_card.dart';
import '../models/attendance.dart';
import '../models/leave_request.dart';
import '../services/attendance_service.dart';
import '../services/leave_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  String _selectedDepartment = 'All';
  final List<String> _departments = ['All', 'Engineering', 'HR', 'Marketing', 'Sales'];
  List<Attendance> _attendanceData = [];
  List<LeaveRequest> _leaveData = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final attendanceService = context.read<AttendanceService>();
      final leaveService = context.read<LeaveService>();

      final attendanceData = await attendanceService.getAttendanceForDate(_selectedDate);
      final leaveData = await leaveService.getLeaveRequestsForDate(_selectedDate);

      setState(() {
        _attendanceData = attendanceData;
        _leaveData = leaveData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Attendance'),
            Tab(text: 'Leave'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedDepartment,
                    decoration: const InputDecoration(
                      labelText: 'Department',
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    items: _departments.map((String department) {
                      return DropdownMenuItem(
                        value: department,
                        child: Text(department),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() {
                          _selectedDepartment = value;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2025),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                      });
                      _loadData();
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildAttendanceTab(),
                _buildLeaveTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final presentCount = _attendanceData.where((a) => a.isPresent).length;
    final totalEmployees = _attendanceData.length;
    final onLeaveCount = _leaveData.where((l) => l.status == LeaveStatus.approved).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: ReportCard(
                title: 'Present Today',
                value: '$presentCount/$totalEmployees',
                icon: Icons.people,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ReportCard(
                title: 'On Leave',
                value: onLeaveCount.toString(),
                icon: Icons.event_busy,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Attendance Trend',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: true),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                DateFormat('dd/MM').format(
                                  DateTime.now().subtract(Duration(days: 6 - value.toInt())),
                                ),
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(7, (index) {
                            return FlSpot(index.toDouble(), 
                              _attendanceData
                                .where((a) => a.date.day == DateTime.now()
                                  .subtract(Duration(days: 6 - index)).day)
                                .where((a) => a.isPresent)
                                .length
                                .toDouble());
                          }),
                          isCurved: true,
                          color: Theme.of(context).primaryColor,
                          barWidth: 3,
                          dotData: const FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: _attendanceData.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final attendance = _attendanceData[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(attendance.employeeName),
            subtitle: Text(
              'Check-in: ${attendance.checkIn != null ? DateFormat('hh:mm a').format(attendance.checkIn!) : 'N/A'} | '
              'Check-out: ${attendance.checkOut != null ? DateFormat('hh:mm a').format(attendance.checkOut!) : 'N/A'}'
            ),
            trailing: Icon(
              attendance.isPresent ? Icons.check_circle : Icons.cancel,
              color: attendance.isPresent ? Colors.green[700] : Colors.red,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLeaveTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: _leaveData.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final leave = _leaveData[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(leave.employeeName),
            subtitle: Text('${leave.type} | ${leave.duration} days'),
            trailing: Chip(
              label: Text(
                leave.status.toString().split('.').last,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: leave.status == LeaveStatus.approved 
                ? Colors.green 
                : leave.status == LeaveStatus.pending 
                  ? Colors.orange 
                  : Colors.red,
            ),
          ),
        );
      },
    );
  }
}
