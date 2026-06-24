import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_manager/core/constants/currencies.dart';
import 'package:money_manager/core/date_time_extentions.dart';
import 'package:money_manager/presentation/pages/add_expense_page.dart';
import 'package:money_manager/presentation/pages/trip_settings_page.dart';
import 'package:money_manager/presentation/providers/trip_dashboard_provider.dart';
import 'package:provider/provider.dart';

class TripDetailsPage extends StatefulWidget {
  final String tripId;
  final String tripName;


  const TripDetailsPage({
    Key? key,
    required this.tripId,
    required this.tripName,
  }) : super(key: key);

  @override
  State<TripDetailsPage> createState() => _TripDetailsPageState();
}
class _TripDetailsPageState extends State<TripDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripDashboardProvider>().loadDashboard(widget.tripId);
    });
  }


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final tripDashboardProvider = context.watch<TripDashboardProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(tripDashboardProvider.dashboard?.trip.name ?? "Unknown"),
        actions: [
          IconButton(
            icon:const Icon(Icons.group),
            onPressed: () {
              _showMembersModal(context, tripDashboardProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider.value(
                    value: tripDashboardProvider,
                    child: TripSettingsPage(tripId: widget.tripId),
                  ),
                ),
              ).then((_) {
                tripDashboardProvider.loadDashboard(widget.tripId);
              });
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => tripDashboardProvider.loadDashboard(widget.tripId),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            

              _buildDashboardHeader(context, tripDashboardProvider),
              const SizedBox(height: 12,),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                'Expenses',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ),
              const SizedBox(height: 8),
              

              Expanded(
                child: _buildExpensesContent(tripDashboardProvider, colorScheme),
              ),
              
            ],
          ),
        
      
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final tripDashboardProvider = context.read<TripDashboardProvider>();
          final DateTime? startDate = tripDashboardProvider.dashboard?.trip.startDate;

          if(startDate != null) {
            final DateTime today = DateTime.now().dateOnly;
            final DateTime cleanStart = startDate.dateOnly;
            if(cleanStart.isAfter(today)){
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('This trip has not started yet! You can only log expenses once it begins. ')),
              );
              return;
            }

          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider.value(
                value: tripDashboardProvider,
                child: AddExpensePage(tripId: widget.tripId,
                  
                    ),
              ),
            ),
          );
        },
        label: const Text('Add Expense'),
        icon: const Icon(Icons.add_card),
      ),
    );
      
      
      
  }
  Widget _buildDashboardHeader(BuildContext context, TripDashboardProvider provider) {

  final cs = currencySymbol(provider.dashboard?.trip.currency ?? 'EUR');
  final limit = provider.dashboard?.dailyLimit ?? 0.0;
  final spentToday = provider.todaySpent;
  final remaining = limit - spentToday;
  final progress = provider.limitProgress;

  final colorScheme = Theme.of(context).colorScheme;
  final isOverspent = remaining < 0;

  return Column(
    children: [
      Card(
        margin: const EdgeInsets.all(16.0),
        color: colorScheme.primaryContainer.withOpacity(0.4),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daily Limit',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.primary),
                  ),
                  Text(
                    '${spentToday.toStringAsFixed(2)} / ${limit.toStringAsFixed(2)} $cs',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(isOverspent ? Colors.red : Colors.deepPurple),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isOverspent ? 'Overspent today:' : 'Remaining for today:',
                    style: TextStyle(color: isOverspent ? Colors.red : Colors.grey[700]),
                  ),
                  Text(
                    '${remaining.abs().toStringAsFixed(2)} $cs',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isOverspent ? Colors.red : Colors.green
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text('Participant Balances', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
      Container(
        height: 85,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: provider.participants.isEmpty
            ? const Center(child: Text('No participants'))
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: provider.participants.length,
                itemBuilder: (context, index) {
                  final participant = provider.participants[index];
                  final name = provider.getParticipantName(participant.participantId);
                  final balanceValue = participant.balance;

                  final isPositive = balanceValue >= 0;

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(
                            "${isPositive ? '+' : ''}${balanceValue.toStringAsFixed(2)} $cs",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isPositive ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      const Divider(indent: 16, endIndent: 16),
    ],
  );
}

  Widget _buildExpensesContent(TripDashboardProvider provider, ColorScheme colorScheme) {
    final cs = currencySymbol(provider.dashboard?.trip.currency ?? 'EUR');
    if(provider.isLoading && provider.expenses.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    if (provider.errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 40),
                const SizedBox(height: 8),
                Text(provider.errorMessage!, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => provider.loadDashboard(widget.tripId),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (provider.expenses.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          Padding(
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
        ],
      );
    }

    final grouped = provider.expensesByDay;
    final days = grouped.keys.toList();

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: days.length,
      itemBuilder: (context, dayIndex) {
        final day = days[dayIndex];
        final dayExpenses = grouped[day]!;
        final dayTotal = dayExpenses.fold(0.0, (sum, e) => sum + e.amount);
        final dateStr = '${day.day.toString().padLeft(2, '0')}.${day.month.toString().padLeft(2, '0')}.${day.year}';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateStr,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  Text(
                    '${dayTotal.toStringAsFixed(2)} $cs',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            ...dayExpenses.map((expense) {
              final payerName = provider.getParticipantName(expense.payerId);
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
                      'Paid by: $payerName',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Text(
                      '${expense.amount.toStringAsFixed(2)} $cs',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  void _showMembersModal(BuildContext context, TripDashboardProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;
    final joinCode = provider.dashboard?.trip.joinCode ?? '------';
    final isOwner = provider.dashboard?.isOwner ?? false;
    final ownerId = provider.dashboard?.trip.ownerId ?? '';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
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
              Text(
                'Members',
                style: Theme.of(modalContext).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...provider.participantsMap.entries.map((entry) {
                final id = entry.key;
                final name = entry.value.name;
                final isEntryOwner = id == ownerId;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(
                      provider.isVirtualParticipant(id) ? Icons.person_outline : Icons.person,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Text(
                    isEntryOwner
                        ? '$name (owner)'
                        : provider.isVirtualParticipant(id)
                            ? '$name (virtual)'
                            : name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  trailing: isOwner && !isEntryOwner
                      ? IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => _confirmRemoveParticipant(
                            context, provider, widget.tripId, id, name, modalContext,
                          ),
                        )
                      : null,
                );
              }),
              if (isOwner)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: OutlinedButton.icon(
                    onPressed: () => _showAddVirtualParticipantDialog(context, provider, widget.tripId, modalContext),
                    icon: const Icon(Icons.person_add_alt_1),
                    label: const Text('Add without account'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                    ),
                  ),
                ),
              const Divider(height: 32),
              Text(
                'Invite Code',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      joinCode,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: joinCode));
                      Navigator.pop(modalContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Join code copied to clipboard!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddVirtualParticipantDialog(
    BuildContext context,
    TripDashboardProvider provider,
    String tripId,
    BuildContext modalContext,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Virtual Participant'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isEmpty) return;
                Navigator.pop(dialogContext);
                Navigator.pop(modalContext);
                final success = await provider.addVirtualParticipant(tripId, name);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? '$name added' : provider.errorMessage ?? 'Failed to add'),
                    backgroundColor: success ? Colors.green : Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _confirmRemoveParticipant(
    BuildContext context,
    TripDashboardProvider provider,
    String tripId,
    String participantId,
    String name,
    BuildContext modalContext,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Remove Member'),
          content: Text('Remove $name from this trip?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.pop(dialogContext);
                Navigator.pop(modalContext);
                final success = await provider.removeParticipant(tripId, participantId);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? '$name removed from trip'
                        : provider.errorMessage ?? 'Failed to remove participant'),
                    backgroundColor: success ? Colors.green : Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }
}