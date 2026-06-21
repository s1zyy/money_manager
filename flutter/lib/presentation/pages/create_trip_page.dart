import 'package:flutter/material.dart';
import 'package:money_manager/core/constants/currencies.dart';
import 'package:money_manager/presentation/providers/trips_provider.dart';
import 'package:provider/provider.dart';
class CreateTripPage extends StatefulWidget{
  const CreateTripPage({super.key});
  @override
  State<CreateTripPage> createState() => _CreateTripPageState();
}

class _CreateTripPageState extends State<CreateTripPage> {

  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _budgetController = TextEditingController();
  final _prepaidController = TextEditingController();

  String _selectedCurrency = "EUR";

  DateTime? _startDate;
  DateTime? _endDate;

  double get _totalBudget => double.tryParse(_budgetController.text) ?? 0.0;
  double get _prepaidExpenses => double.tryParse(_prepaidController.text) ?? 0.0;


  @override
  void initState() {
    super.initState();
    _budgetController.addListener(_updateState);
    _prepaidController.addListener(_updateState);
  }

  void _updateState() => setState(() {});


  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime minimumDate = isStartDate ? DateTime(2025) : (_startDate ?? DateTime.now());
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: minimumDate.isAfter(DateTime.now()) ? minimumDate : DateTime.now(),
      firstDate: minimumDate,
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Trip'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Trip Name', border: OutlineInputBorder()),
              validator: (value) => value == null || value.isEmpty ? 'Please enter trip name' : null,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedCurrency,
              decoration: const InputDecoration(
                labelText: 'Currency',
                border: OutlineInputBorder(),
              ),
              menuMaxHeight: 300,
              items: supportedCurrencies
                .map((c) => DropdownMenuItem(
                  value: c.code,
                  child: Text('${c.symbol} ${c.code}'),
                )).toList(),
              onChanged: (val) {
                if(val != null) setState(() => _selectedCurrency = val);
              },
            ),


            const SizedBox(height:16),

            
            TextFormField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Total Budget', border: OutlineInputBorder()),
              validator: (value) => value == null || value.isEmpty ? 'Please enter total budget' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _prepaidController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Prepaid Amount',
                border: OutlineInputBorder()
                ),
                validator: (value) {
                  if(value == null || value.isEmpty) {
                    return 'Please enter prepaid amount';
                  } 

                  if(_prepaidExpenses > _totalBudget) {
                    return 'Prepaid amount cannot exceed total budget';
                  }
                  return null;
                }

                
                
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text("Start Date"),
                    subtitle: Text(_startDate == null ? 'Not set' : _startDate!.toIso8601String().split('T')[0]),
                    onTap: () => _selectDate(context, true),
                    tileColor: Colors.grey[200],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ListTile(
                    title: const Text("End Date"),
                    subtitle: Text(_endDate == null ? 'Not set' : _endDate!.toIso8601String().split('T')[0]),
                    onTap: () => _selectDate(context, false),
                    tileColor: Colors.grey[200],
                  ),
                )
              ],
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: () async {
                if(_startDate == null || _endDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select dates')),
                    );
                  return;
                }
                if(_formKey.currentState!.validate()) {
                  

                
                final provider = context.read<TripsProvider>();
                final success = await provider.addTrip(
                  name: _nameController.text,
                  totalBudget: double.tryParse(_budgetController.text) ?? 0.0,
                  prepaidExpenses: double.tryParse(_prepaidController.text) ?? 0.0,
                  startDate: _startDate!,
                  endDate: _endDate!,
                  currency: _selectedCurrency,
                );
                
                if (success) {
                  if(mounted) {
                    Navigator.pop(context);
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(provider.errorMessage ?? 'Failed to create trip')),
                  );
                }
                }
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Text('Create Trip'),
            )
          ]
        ),
      ),
      ),
    );
  }
}