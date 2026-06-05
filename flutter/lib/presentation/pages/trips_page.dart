
import 'package:flutter/material.dart';
import 'package:money_manager/presentation/pages/create_trip_page.dart';
import 'package:money_manager/presentation/pages/trip_details_page.dart';
import 'package:money_manager/presentation/providers/trips_provider.dart';
import 'package:provider/provider.dart';

class TripsPage extends StatefulWidget {
  const TripsPage({super.key});
  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
      context.read<TripsProvider>().loadTrips());
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trips'),
        
      ),
      //TODO: add join trip button in app bar and implement join trip page
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrJoinTripModal(context),
        child: const Icon(Icons.add),
      ),
      body: Consumer<TripsProvider>(
        builder: (context, provider, child) {
          if(provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if(provider.errorMessage != null) {
            return Center(child: Text(provider.errorMessage!));
          }

          if(provider.trips.isEmpty) {
            return const Center(child: Text('No trips here yet!'));
          }

          return ListView.builder(
            itemCount: provider.trips.length,
            itemBuilder: (context, index) {
              final trip = provider.trips[index];
              return ListTile(
                title: Text(trip.name),
                subtitle: Text("Budget: \$${trip.totalBudget}"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TripDetailsPage(
                        tripId: trip.id,
                        tripName: trip.name,
                        joinCode: trip.joinCode,
                      ),
                    ),
                  );
                },
              );
            }
          );
        }
      )
    );
  }

  void _showAddOrJoinTripModal(BuildContext pageContext) {
    final colorScheme = Theme.of(pageContext).colorScheme;

    showModalBottomSheet(
      context: pageContext,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Add Trip',
                style: Theme.of(modalContext).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(Icons.add, color: colorScheme.onPrimaryContainer),
                ),
                title: const Text('Create New Trip', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('You will become the owner and set the budget'),
                onTap: () {
                  Navigator.pop(modalContext); 
                  Navigator.push(
                    pageContext,
                    MaterialPageRoute(builder: (context) => const CreateTripPage()),
                  );
                },
              ),
              const Divider(height: 20),
              
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: colorScheme.secondaryContainer,
                  child: Icon(Icons.group_add, color: colorScheme.onSecondaryContainer),
                ),
                title: const Text('Join Trip by Code', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Enter invite code from a friend'),
                onTap: () {
                  Navigator.pop(modalContext);
                  _showJoinTripDialog(pageContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showJoinTripDialog(BuildContext pageContext) {
    final TextEditingController codeController = TextEditingController();

    showDialog(
      context: pageContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Join Trip'),
          content: TextField(
            controller: codeController,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              hintText: 'Enter invite code',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final code = codeController.text.trim();
                if (code.isNotEmpty) {
                  Navigator.pop(dialogContext);
                  
                  final provider = pageContext.read<TripsProvider>();
                  final success = await provider.joinTrip(code);

                  if (!pageContext.mounted) return;

                  if (success) {
                    ScaffoldMessenger.of(pageContext).showSnackBar(
                      const SnackBar(
                        content: Text('Successfully joined the trip!'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(pageContext).showSnackBar(
                      SnackBar(
                        content: Text(provider.errorMessage ?? 'Error joining trip'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              child: const Text('Join'),
            ),
          ],
        );
      },
    );
  }

  


  
}

