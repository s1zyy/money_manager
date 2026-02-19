

import 'package:flutter/material.dart';
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
                },
              );
            }
          );
        }
      )
    );
  }
  
}