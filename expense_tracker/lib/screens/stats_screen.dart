import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/expense_provider.dart';
import '../utils/formatters.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Day'),
            Tab(text: 'Week'),
            Tab(text: 'Month'),
            Tab(text: 'Year'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDayTab(prov),
          _buildWeekTab(prov),
          _buildMonthTab(prov),
          _buildYearTab(prov),
        ],
      ),
    );
  }

  Widget _buildDayTab(ExpenseProvider prov) {
    final list = prov.getExpensesByPeriod('daily');
    final total = prov.totalForPeriod('daily');
    return _buildListWithHeader(total, list);
  }

  Widget _buildWeekTab(ExpenseProvider prov) {
    final totalsMap = prov.aggregateWeekly();
    final total = totalsMap.values.fold(0.0, (p, e) => p + e);

    // Prepare bar groups for Mon..Sun (1..7)
    final items = List.generate(7, (i) {
      final weekday = ((DateTime.now().subtract(
        Duration(days: 6),
      )).add(Duration(days: i))).weekday; // order aligned to last 7 days
      final value = totalsMap[weekday] ?? 0.0;
      return BarChartGroupData(
        x: i,
        barRods: [BarChartRodData(toY: value)],
      );
    });

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Text(
            'Total: ${formatCurrency(total)}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (totalsMap.values.isEmpty)
                    ? 10
                    : (totalsMap.values.reduce((a, b) => a > b ? a : b) * 1.2),
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        final date = DateTime.now().subtract(
                          Duration(days: 6 - idx),
                        );
                        final label = [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun',
                        ][date.weekday - 1];
                        return SideTitleWidget(
                          child: Text(label),
                          axisSide: meta.axisSide,
                        );
                      },
                    ),
                  ),
                ),
                barGroups: items,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthTab(ExpenseProvider prov) {
    final map = prov.aggregateMonthly();
    final total = map.values.fold(0.0, (p, e) => p + e);

    // sort days
    final days = map.keys.toList()..sort();
    final items = days.map((d) {
      final value = map[d] ?? 0.0;
      return BarChartGroupData(
        x: d,
        barRods: [BarChartRodData(toY: value)],
      );
    }).toList();

    double maxY = items.isEmpty
        ? 10
        : items.map((g) => g.barRods[0].toY).reduce((a, b) => a > b ? a : b) *
              1.2;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Text(
            'Total: ${formatCurrency(total)}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceBetween,
                maxY: maxY,
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final day = value.toInt();
                        return SideTitleWidget(
                          child: Text('$day'),
                          axisSide: meta.axisSide,
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                ),
                barGroups: items,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearTab(ExpenseProvider prov) {
    final map = prov.aggregateYearly();
    final total = map.values.fold(0.0, (p, e) => p + e);

    final items = List.generate(12, (i) {
      final month = i + 1;
      final value = map[month] ?? 0.0;
      return BarChartGroupData(
        x: i,
        barRods: [BarChartRodData(toY: value)],
      );
    });

    double maxY = items.isEmpty
        ? 10
        : items.map((g) => g.barRods[0].toY).reduce((a, b) => a > b ? a : b) *
              1.2;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Text(
            'Total: ${formatCurrency(total)}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        final label = [
                          'Jan',
                          'Feb',
                          'Mar',
                          'Apr',
                          'May',
                          'Jun',
                          'Jul',
                          'Aug',
                          'Sep',
                          'Oct',
                          'Nov',
                          'Dec',
                        ][idx];
                        return SideTitleWidget(
                          child: Text(label),
                          axisSide: meta.axisSide,
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                ),
                barGroups: items,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListWithHeader(double total, List list) {
    return Column(
      children: [
        Card(
          margin: EdgeInsets.all(12),
          child: ListTile(
            title: Text('Total'),
            trailing: Text(
              formatCurrency(total),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Expanded(
          child: list.isEmpty
              ? Center(child: Text('No expenses'))
              : ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, idx) {
                    final e = list[idx];
                    return ListTile(
                      title: Text(e.title),
                      subtitle: Text(
                        '${e.category} • ${e.date.split('T').first}',
                      ),
                      trailing: Text(formatCurrency(e.amount)),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
