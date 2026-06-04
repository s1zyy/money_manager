import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TripDetailsPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(tripName),
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
      body: SingleChildScrollView(
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
                            value: '\$800.0',
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

              ListView.builder(
                shrinkWrap: true,
                physics : const NeverScrollableScrollPhysics(),
                itemCount: 3, // TODO: Replace with actual number of expenses
                itemBuilder:(context, index) {
                  final mockExpenses = [
                    {
                      'title': 'Dinner at Restaurant',
                      'amount': '\$50.0',
                      'payer': 'Alice',
                      'icon': Icons.restaurant_menu_outlined,
                      'date': '2024-06-01',
                    },
                    {
                      'title': 'Museum Tickets',
                      'amount': '\$30.0',
                      'payer': 'Bob',
                      'icon': Icons.museum_outlined,
                      'date': '2024-06-02',
                    },
                    {
                      'title': 'Taxi Ride',
                      'amount': '\$20.0',
                      'payer': 'Charlie',
                      'date': '2024-06-03',
                    },
                  ]; //TODO: Replace with actual expenses data

                  final expense = mockExpenses[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: colorScheme.outlineVariant),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        child: Icon((expense['icon'] as IconData?) ?? Icons.attach_money, color: colorScheme.primary),
                      ),
                      title: Text(expense['title'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('Paid by ${expense['payer']}'),
                      trailing: Text(
                        expense['amount'] as String,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          //TODO: Handle add expense button presы
        },
        label: const Text('Add Expense'),
        icon: const Icon(Icons.add_card),
      )
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
                  joinCode,
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
                    Clipboard.setData(ClipboardData(text: joinCode));

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