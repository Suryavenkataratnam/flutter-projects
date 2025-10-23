// FILE: lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../widgets/expense_card.dart';
import 'add_expense_screen.dart';
import 'stats_screen.dart';
import '../utils/formatters.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Expense Tracker'),
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart),
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => StatsScreen())),
          ),
        ],
      ),
      body: FutureBuilder(
        future: prov.loadExpenses(),
        builder: (context, snapshot) {
          final expenses = prov.expenses;
          if (snapshot.connectionState == ConnectionState.waiting &&
              expenses.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          if (expenses.isEmpty) {
            return Center(child: Text('No expenses yet. Tap + to add.'));
          }

          final total = expenses.fold(0.0, (p, e) => p + e.amount);

          return Column(
            children: [
              Card(
                margin: EdgeInsets.all(12),
                child: ListTile(
                  title: Text('Total'),
                  subtitle: Text('${expenses.length} entries'),
                  trailing: Text(
                    formatCurrency(total),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: prov.loadExpenses,
                  child: ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (context, idx) {
                      final e = expenses[idx];
                      return ExpenseCard(
                        expense: e,
                        onDelete: () => _confirmDelete(context, prov, e.id!),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => AddExpenseScreen())),
        child: Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ExpenseProvider prov, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete'),
        content: Text('Delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await prov.deleteExpense(id);
              Navigator.of(ctx).pop();
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
