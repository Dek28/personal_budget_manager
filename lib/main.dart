// main.dart
// Personal Budget Manager App - Complete Flutter Front-End
// Author: Dek Abdi
// This is a self-contained Flutter app with:
// - Dashboard summary (balance, income, expenses)
// - Add transaction form (income/expense, categories)
// - Transaction list with delete
// - Basic stats by category

import 'package:flutter/material.dart';

void main() {
  runApp(const BudgetApp());
}

class BudgetApp extends StatelessWidget {
  const BudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Personal Budget Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade700),
        useMaterial3: true,
      ),
      home: const MainDashboard(),
    );
  }
}

// ---------------- DATA MODELS ----------------

class TransactionModel {
  final String id;
  final String title;
  final String category;
  final double amount;
  final bool isIncome;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.isIncome,
    required this.date,
  });
}

class CategoryModel {
  final String name;
  final IconData icon;

  CategoryModel(this.name, this.icon);
}

// ---------------- MOCK CATEGORIES ----------------

final List<CategoryModel> categories = [
  CategoryModel('Food', Icons.fastfood),
  CategoryModel('Transport', Icons.directions_bus),
  CategoryModel('Shopping', Icons.shopping_bag),
  CategoryModel('Bills', Icons.receipt_long),
  CategoryModel('Salary', Icons.attach_money),
  CategoryModel('Other', Icons.more_horiz),
];

// ---------------- ROOT DASHBOARD WITH STATE ----------------

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int currentIndex = 0;

  final List<TransactionModel> _transactions = [
    TransactionModel(
      id: 't1',
      title: 'Salary',
      category: 'Salary',
      amount: 1200,
      isIncome: true,
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
    TransactionModel(
      id: 't2',
      title: 'Groceries',
      category: 'Food',
      amount: 120,
      isIncome: false,
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    TransactionModel(
      id: 't3',
      title: 'Bus Fare',
      category: 'Transport',
      amount: 30,
      isIncome: false,
      date: DateTime.now(),
    ),
    TransactionModel(
      id: 't4',
      title: 'Shopping',
      category: 'Shopping',
      amount: 200,
      isIncome: false,
      date: DateTime.now(),
    ),
  ];

  void _addTransaction(TransactionModel t) {
    setState(() {
      _transactions.add(t);
      currentIndex = 0; // go back to dashboard after saving
    });
  }

  void _deleteTransaction(String id) {
    setState(() {
      _transactions.removeWhere((t) => t.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(transactions: _transactions, onDelete: _deleteTransaction),
      AddTransactionScreen(onSubmit: _addTransaction),
      StatsScreen(transactions: _transactions),
    ];

    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
        ],
      ),
    );
  }
}

// ---------------- HOME SCREEN ----------------

class HomeScreen extends StatelessWidget {
  final List<TransactionModel> transactions;
  final void Function(String id) onDelete;

  const HomeScreen({
    super.key,
    required this.transactions,
    required this.onDelete,
  });

  double get totalIncome =>
      transactions.where((t) => t.isIncome).fold(0, (sum, t) => sum + t.amount);

  double get totalExpense => transactions
      .where((t) => !t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Dashboard'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SummaryCard(
                  title: 'Balance',
                  value: totalIncome - totalExpense,
                ),
                SummaryCard(
                  title: 'Income',
                  value: totalIncome,
                  color: Colors.green,
                ),
                SummaryCard(
                  title: 'Expense',
                  value: totalExpense,
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Recent Transactions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: transactions.isEmpty
                  ? const Center(child: Text('No transactions yet.'))
                  : ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final t = transactions[index];
                        return TransactionTile(
                          transaction: t,
                          onDelete: () => onDelete(t.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- ADD TRANSACTION SCREEN ----------------

class AddTransactionScreen extends StatefulWidget {
  final void Function(TransactionModel) onSubmit;

  const AddTransactionScreen({super.key, required this.onSubmit});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  String _selectedCategory = categories.first.name;
  bool _isIncome = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount.')),
      );
      return;
    }

    final transaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      category: _selectedCategory,
      amount: amount,
      isIncome: _isIncome,
      date: _selectedDate,
    );

    widget.onSubmit(transaction);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Transaction saved.')));

    _titleController.clear();
    _amountController.clear();
    setState(() {
      _selectedCategory = categories.first.name;
      _isIncome = false;
      _selectedDate = DateTime.now();
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Add Transaction'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value.trim()) == null) {
                    return 'Amount must be a number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Category',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              CategorySelector(
                selected: _selectedCategory,
                onSelected: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Type:'),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    label: const Text('Expense'),
                    selected: !_isIncome,
                    onSelected: (_) {
                      setState(() => _isIncome = false);
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Income'),
                    selected: _isIncome,
                    onSelected: (_) {
                      setState(() => _isIncome = true);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Date:'),
                  const SizedBox(width: 12),
                  Text(
                    '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                  ),
                  const SizedBox(width: 12),
                  TextButton(onPressed: _pickDate, child: const Text('Change')),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Transaction'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- STATS SCREEN ----------------

class StatsScreen extends StatelessWidget {
  final List<TransactionModel> transactions;

  const StatsScreen({super.key, required this.transactions});

  Map<String, double> _expenseByCategory() {
    final Map<String, double> data = {};
    for (final t in transactions.where((t) => !t.isIncome)) {
      data[t.category] = (data[t.category] ?? 0) + t.amount;
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final expenseData = _expenseByCategory();
    final totalExpense = expenseData.values.fold(0.0, (sum, v) => sum + v);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Statistics'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: expenseData.isEmpty
            ? const Center(child: Text('No expense data to show.'))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Expenses by Category',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: expenseData.entries.map((entry) {
                        final category = entry.key;
                        final value = entry.value;
                        final percent = totalExpense == 0
                            ? 0
                            : (value / totalExpense);
                        final categoryIcon = categories.firstWhere(
                          (c) => c.name == category,
                          orElse: () => CategoryModel(category, Icons.circle),
                        );
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(categoryIcon.icon),
                                        const SizedBox(width: 8),
                                        Text(
                                          category,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text('${value.toStringAsFixed(2)}'),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: percent.toDouble(),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${(percent * 100).toStringAsFixed(1)}% of expenses',
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ---------------- REUSABLE WIDGETS ----------------

class SummaryCard extends StatelessWidget {
  final String title;
  final double value;
  final Color? color;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 6),
          Text(
            value.toStringAsFixed(2),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          transaction.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
          color: transaction.isIncome ? Colors.green : Colors.red,
        ),
        title: Text(transaction.title),
        subtitle: Text(
          '${transaction.category} · '
          '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}-${transaction.date.day.toString().padLeft(2, '0')}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              (transaction.isIncome ? '+ ' : '- ') +
                  transaction.amount.toStringAsFixed(2),
              style: TextStyle(
                color: transaction.isIncome ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
              tooltip: 'Delete transaction',
            ),
          ],
        ),
      ),
    );
  }
}

class CategorySelector extends StatelessWidget {
  final String? selected;
  final void Function(String name)? onSelected;

  const CategorySelector({super.key, this.selected, this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selected == category.name;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: InkWell(
              onTap: () => onSelected?.call(category.name),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: isSelected ? 22 : 20,
                    child: Icon(category.icon),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(title: Text(title), centerTitle: true);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
