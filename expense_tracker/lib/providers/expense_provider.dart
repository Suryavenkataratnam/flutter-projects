import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../db/expense_database.dart';

class ExpenseProvider extends ChangeNotifier {
  List<Expense> _expenses = [];

  List<Expense> get expenses => _expenses;

  Future<void> loadExpenses() async {
    _expenses = await ExpenseDatabase.instance.readAllExpenses();
    notifyListeners();
  }

  Future<void> addExpense(Expense expense) async {
    await ExpenseDatabase.instance.create(expense);
    await loadExpenses();
  }

  Future<void> deleteExpense(int id) async {
    await ExpenseDatabase.instance.delete(id);
    await loadExpenses();
  }

  // Returns expenses filtered by period: 'daily','weekly','monthly','yearly'
  List<Expense> getExpensesByPeriod(String period) {
    final now = DateTime.now();

    switch (period) {
      case 'daily':
        return _expenses.where((e) {
          final d = DateTime.parse(e.date);
          return d.year == now.year && d.month == now.month && d.day == now.day;
        }).toList();

      case 'weekly':
        final weekAgo = now.subtract(
          Duration(days: 6),
        ); // include today (7 days)
        return _expenses.where((e) {
          final d = DateTime.parse(e.date);
          return !d.isBefore(
            DateTime(weekAgo.year, weekAgo.month, weekAgo.day),
          );
        }).toList();

      case 'monthly':
        return _expenses.where((e) {
          final d = DateTime.parse(e.date);
          return d.year == now.year && d.month == now.month;
        }).toList();

      case 'yearly':
        return _expenses.where((e) {
          final d = DateTime.parse(e.date);
          return d.year == now.year;
        }).toList();

      default:
        return _expenses;
    }
  }

  double totalForPeriod(String period) {
    final list = getExpensesByPeriod(period);
    return list.fold(0.0, (p, e) => p + e.amount);
  }

  // Aggregation helpers for charts
  // Weekly aggregation: returns map of weekday (Mon..Sun index 1-7) -> total
  Map<int, double> aggregateWeekly() {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: 6));
    Map<int, double> map = {
      for (var i = 0; i < 7; i++) ((start.add(Duration(days: i))).weekday): 0.0,
    };

    for (final e in _expenses) {
      final d = DateTime.parse(e.date);
      if (!d.isBefore(DateTime(start.year, start.month, start.day))) {
        map[d.weekday] = (map[d.weekday] ?? 0) + e.amount;
      }
    }
    return map; // keys are 1(Mon)..7(Sun)
  }

  // Monthly aggregation: day-of-month -> total for current month
  Map<int, double> aggregateMonthly() {
    final now = DateTime.now();
    Map<int, double> map = {};
    for (final e in _expenses) {
      final d = DateTime.parse(e.date);
      if (d.year == now.year && d.month == now.month) {
        map[d.day] = (map[d.day] ?? 0) + e.amount;
      }
    }
    return map; // keys: 1..31
  }

  // Yearly aggregation: month (1..12) -> total
  Map<int, double> aggregateYearly() {
    final now = DateTime.now();
    Map<int, double> map = {for (var m = 1; m <= 12; m++) m: 0.0};
    for (final e in _expenses) {
      final d = DateTime.parse(e.date);
      if (d.year == now.year) {
        map[d.month] = (map[d.month] ?? 0) + e.amount;
      }
    }
    return map;
  }
}
