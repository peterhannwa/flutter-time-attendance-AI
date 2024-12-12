import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/leave_request.dart';
import '../models/leave_balance.dart';
import '../services/notification_service.dart';

class LeaveService extends ChangeNotifier {
  static final LeaveService _instance = LeaveService._internal();
  factory LeaveService() => _instance;
  LeaveService._internal();

  static const String _leaveRequestsKey = 'leave_requests';
  static const String _leaveBalancesKey = 'leave_balances';
  SharedPreferences? _prefs;
  final NotificationService _notificationService = NotificationService();

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Leave Request Methods
  Future<List<LeaveRequest>> getAllLeaveRequests() async {
    if (_prefs == null) await initialize();
    final String? data = _prefs?.getString(_leaveRequestsKey);
    if (data == null) return [];

    final List<dynamic> jsonList = json.decode(data);
    return jsonList.map((json) => LeaveRequest.fromJson(json)).toList();
  }

  Future<List<LeaveRequest>> getEmployeeLeaveRequests(String employeeId) async {
    final requests = await getAllLeaveRequests();
    return requests.where((request) => request.employeeId == employeeId).toList();
  }

  Future<List<LeaveRequest>> getPendingApprovals(String managerId) async {
    final requests = await getAllLeaveRequests();
    return requests.where((request) => 
      request.status == LeaveStatus.pending &&
      request.approverId == managerId
    ).toList();
  }

  Future<List<LeaveRequest>> getLeaveRequestsForDate(DateTime date) async {
    final requests = await getAllLeaveRequests();
    return requests.where((request) => 
      request.startDate.isBefore(date.add(const Duration(days: 1))) &&
      request.endDate.isAfter(date.subtract(const Duration(days: 1)))
    ).toList();
  }

  Future<void> submitLeaveRequest(LeaveRequest request) async {
    final requests = await getAllLeaveRequests();
    requests.add(request);
    await _saveLeaveRequests(requests);

    // Update leave balance
    await _updateLeaveBalance(
      request.employeeId,
      request.type,
      request.durationInDays.toDouble(),
      isPending: true,
    );

    // Notify manager
    if (request.approverId != null) {
      _notificationService.showNotification(
        title: 'New Leave Request',
        body: '${request.employeeId} has requested leave from '
            '${request.startDate.toString().split(' ')[0]} to '
            '${request.endDate.toString().split(' ')[0]}',
      );
    }
    notifyListeners();
  }

  Future<void> updateLeaveRequest(LeaveRequest request) async {
    final requests = await getAllLeaveRequests();
    final index = requests.indexWhere((r) => r.id == request.id);
    if (index != -1) {
      final oldRequest = requests[index];
      requests[index] = request;
      await _saveLeaveRequests(requests);

      // Update leave balances based on status change
      if (oldRequest.status != request.status) {
        if (request.status == LeaveStatus.approved) {
          await _updateLeaveBalance(
            request.employeeId,
            request.type,
            request.durationInDays.toDouble(),
            isPending: false,
            isApproved: true,
          );
        } else if (request.status == LeaveStatus.rejected ||
                   request.status == LeaveStatus.cancelled) {
          await _updateLeaveBalance(
            request.employeeId,
            request.type,
            request.durationInDays.toDouble(),
            isPending: false,
            isApproved: false,
          );
        }

        // Notify employee
        _notificationService.showNotification(
          title: 'Leave Request ${request.status.toString().split('.').last}',
          body: 'Your leave request from '
              '${request.startDate.toString().split(' ')[0]} to '
              '${request.endDate.toString().split(' ')[0]} has been '
              '${request.status.toString().split('.').last}',
        );
      }
      notifyListeners();
    }
  }

  Future<void> deleteLeaveRequest(String requestId) async {
    final requests = await getAllLeaveRequests();
    requests.removeWhere((r) => r.id == requestId);
    await _saveLeaveRequests(requests);
    notifyListeners();
  }

  Future<void> _saveLeaveRequests(List<LeaveRequest> requests) async {
    if (_prefs == null) await initialize();
    final String data = json.encode(requests.map((r) => r.toJson()).toList());
    await _prefs?.setString(_leaveRequestsKey, data);
  }

  // Leave Balance Methods
  Future<LeaveBalance?> getEmployeeLeaveBalance(
    String employeeId, 
    int year,
  ) async {
    if (_prefs == null) await initialize();
    final String? data = _prefs?.getString(_leaveBalancesKey);
    if (data == null) return null;

    final List<dynamic> jsonList = json.decode(data);
    final balances = jsonList
        .map((json) => LeaveBalance.fromJson(json))
        .where((balance) => 
          balance.employeeId == employeeId && 
          balance.year == year
        );
    
    return balances.isEmpty ? null : balances.first;
  }

  Future<void> _updateLeaveBalance(
    String employeeId,
    LeaveType leaveType,
    double days, {
    bool isPending = false,
    bool? isApproved,
  }) async {
    final year = DateTime.now().year;
    var balance = await getEmployeeLeaveBalance(employeeId, year);
    
    if (balance == null) {
      // Create new balance if doesn't exist
      balance = LeaveBalance(
        employeeId: employeeId,
        year: year,
        quotas: {
          leaveType.toString(): LeaveQuota(
            total: 0,
            used: 0,
            pending: 0,
            lastUpdated: DateTime.now(),
          ),
        },
      );
    }

    final quota = balance.quotas[leaveType.toString()] ?? LeaveQuota(
      total: 0,
      used: 0,
      pending: 0,
      lastUpdated: DateTime.now(),
    );

    if (isPending) {
      balance.quotas[leaveType.toString()] = quota.copyWith(
        pending: quota.pending + days,
        lastUpdated: DateTime.now(),
      );
    } else if (isApproved != null) {
      if (isApproved) {
        balance.quotas[leaveType.toString()] = quota.copyWith(
          used: quota.used + days,
          pending: quota.pending - days,
          lastUpdated: DateTime.now(),
        );
      } else {
        balance.quotas[leaveType.toString()] = quota.copyWith(
          pending: quota.pending - days,
          lastUpdated: DateTime.now(),
        );
      }
    }

    await _saveLeaveBalance(balance);
    notifyListeners();
  }

  Future<void> _saveLeaveBalance(LeaveBalance balance) async {
    if (_prefs == null) await initialize();
    final String? data = _prefs?.getString(_leaveBalancesKey);
    final List<LeaveBalance> balances = [];
    
    if (data != null) {
      final List<dynamic> jsonList = json.decode(data);
      balances.addAll(
        jsonList
            .map((json) => LeaveBalance.fromJson(json))
            .where((b) => 
              b.employeeId != balance.employeeId || 
              b.year != balance.year
            ),
      );
    }
    
    balances.add(balance);
    
    final String encodedData = json.encode(
      balances.map((b) => b.toJson()).toList(),
    );
    await _prefs?.setString(_leaveBalancesKey, encodedData);
  }

  Future<Map<String, int>> getLeaveStatistics(String employeeId) async {
    final requests = await getEmployeeLeaveRequests(employeeId);
    final stats = <String, int>{};
    
    for (final request in requests) {
      final type = request.type.toString().split('.').last;
      stats[type] = (stats[type] ?? 0) + request.durationInDays;
    }
    
    return stats;
  }
}
