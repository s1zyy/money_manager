import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_manager/presentation/providers/expense_provider.dart';
import 'package:provider/provider.dart';

class TripDetailsPage extends StatefulWidget {
  final String tripId;
  final String tripName;
  final String joinCode;

  const TripDetailsPage({
    Key? key,
    required this.tripId,
    required this.tripName,
    required this.joinCode,
  }) : super(key: key);

  @override
  State<TripDetailsPage> createState() => _TripDetailsPageState();
}
class _TripDetailsPageState extends State<TripDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpensesProvider>().loadExpenses(widget.tripId);
    });
  }


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final expensesProvider = context.watch<ExpensesProvider>();

    final double totalSpent = expensesProvider.expenses.fold(0, (sum, item) => sum + item.amount);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tripName),
        actions: [
          IconButton(
            icon:const Icon(Icons.group_add_outlined),
            onPressed: () {
              _showAddParticipantModal(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // Handle settings button press
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => expensesProvider.loadExpenses(widget.tripId),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 0,
                color: colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                            Text(
                              'Total Budget',
                              style: TextStyle(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            // card -> padding -> column -> row -> text
                            Text(
                              '\$1200.0',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                        ],
                      ),
                      const Divider(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMiniStat(
                            context,
                            title: 'Spent',
                            value: '${totalSpent.toStringAsFixed(2)} ',
                            valueColor: colorScheme.primary,
                          ),
                          _buildMiniStat(
                            context,
                            title: 'Your balance',
                            value: '+\$25.0',
                            valueColor: Colors.green,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Expenses',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12,),

              _buildExpensesContent(expensesProvider, colorScheme),
            ],
          ),
        ),
      ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          //TODO: Handle add expense button pressed DOING THIS RIGHT NOW
        },
        label: const Text('Add Expense'),
        icon: const Icon(Icons.add_card),
      ),
    );
      
      
      
  }

  Widget _buildExpensesContent(ExpensesProvider provider, ColorScheme colorScheme) {
    if(provider.isLoading && provider.expenses.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 40),
              const SizedBox(height: 8),
              Text(provider.errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => provider.loadExpenses(widget.tripId),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.expenses.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Column(
            children: [
              Icon(Icons.receipt_long_outlined, color: Colors.grey, size: 48),
              SizedBox(height: 12),
              Text(
                'No expenses yet. Add your first check!',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.expenses.length,
      itemBuilder: (context, index) {
        final expense = provider.expenses[index];

        return Dismissible(
          key: Key(expense.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              provider.deleteExpense(widget.tripId, expense.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Expense deleted')),
              );
            },
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 6.0),
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: colorScheme.surfaceContainerHighest,
                child: Icon(Icons.attach_money, color: colorScheme.primary),
              ),
              title: Text(
                expense.description,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Paid by ID: ${expense.payerId.substring(0, 5)}... • ${expense.date.toIso8601String().split('T')[0]}',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: Text(
                '${expense.amount.toStringAsFixed(2)} €',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            ),
          );
      },
    );
  }

  Widget _buildMiniStat(BuildContext context, {required String title, required String value, required Color valueColor}) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: valueColor),
        ),
      ],
    );
  }

  void _showAddParticipantModal(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    

    showModalBottomSheet(
      context: context,
      
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text('Invite Participants',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),


              const SizedBox(height: 8),


              Text(
                'Share the code below to invite others to join this trip',
                style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Text(
                  widget.joinCode,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.joinCode));

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Join code copied to clipboard!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    
                    );
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy Code', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}