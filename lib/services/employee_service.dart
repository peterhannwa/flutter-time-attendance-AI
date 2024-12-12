import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/employee.dart';

class EmployeeService {
  static final EmployeeService _instance = EmployeeService._internal();
  factory EmployeeService() => _instance;
  
  late SharedPreferences _prefs;
  static const String _employeesKey = 'employees';
  
  EmployeeService._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<List<Employee>> getAllEmployees() async {
    final String? employeesJson = _prefs.getString(_employeesKey);
    if (employeesJson == null) return [];

    final List<dynamic> decodedList = json.decode(employeesJson);
    return decodedList.map((json) => Employee.fromJson(json)).toList();
  }

  Future<List<Employee>> getEmployeesByDepartment(String department) async {
    final employees = await getAllEmployees();
    return employees.where((emp) => emp.department == department).toList();
  }

  Future<Employee?> getEmployeeById(String id) async {
    final employees = await getAllEmployees();
    try {
      return employees.firstWhere((emp) => emp.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addEmployee(Employee employee) async {
    final employees = await getAllEmployees();
    employees.add(employee);
    await _saveEmployees(employees);
  }

  Future<void> updateEmployee(Employee employee) async {
    final employees = await getAllEmployees();
    final index = employees.indexWhere((emp) => emp.id == employee.id);
    if (index != -1) {
      employees[index] = employee;
      await _saveEmployees(employees);
    }
  }

  Future<void> deleteEmployee(String id) async {
    final employees = await getAllEmployees();
    employees.removeWhere((emp) => emp.id == id);
    await _saveEmployees(employees);
  }

  Future<void> _saveEmployees(List<Employee> employees) async {
    final List<Map<String, dynamic>> jsonList = employees.map((emp) => emp.toJson()).toList();
    await _prefs.setString(_employeesKey, json.encode(jsonList));
  }

  Future<List<Employee>> searchEmployees(String query) async {
    final employees = await getAllEmployees();
    query = query.toLowerCase();
    
    return employees.where((emp) {
      return emp.name.toLowerCase().contains(query) ||
          emp.email.toLowerCase().contains(query) ||
          emp.department.toLowerCase().contains(query) ||
          emp.position.toLowerCase().contains(query);
    }).toList();
  }

  Future<Map<String, int>> getDepartmentStats() async {
    final employees = await getAllEmployees();
    final stats = <String, int>{};
    
    for (final employee in employees) {
      stats[employee.department] = (stats[employee.department] ?? 0) + 1;
    }
    
    return stats;
  }

  Future<void> assignManager(String employeeId, String managerId) async {
    final employees = await getAllEmployees();
    final index = employees.indexWhere((emp) => emp.id == employeeId);
    
    if (index != -1) {
      employees[index] = employees[index].copyWith(managerId: managerId);
      await _saveEmployees(employees);
    }
  }

  Future<List<Employee>> getTeamMembers(String managerId) async {
    final employees = await getAllEmployees();
    return employees.where((emp) => emp.managerId == managerId).toList();
  }

  Future<bool> validateEmployeeCredentials(String email, String password) async {
    final employees = await getAllEmployees();
    return employees.any((emp) => 
      emp.email == email && emp.password == password // In production, use proper password hashing
    );
  }
}
