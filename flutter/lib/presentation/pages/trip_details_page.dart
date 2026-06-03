import 'package:flutter/material.dart';

class TripDetailsPage extends StatelessWidget {
  final String tripId;
  final String tripName;

  const TripDetailsPage({
    Key? key,
    required this.tripId,
    required this.tripName,
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
              // Handle add member button press
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
          //TODO: Handle add expense button press
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
}