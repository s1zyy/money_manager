

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:money_manager/presentation/providers/trip_dashboard_provider.dart';

class AddExpensePage extends StatefulWidget{
  final String tripId;

  const AddExpensePage({Key? key, required this.tripId}) : super(key: key);

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
  
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  String? _selectedPayerId;
  final List<String> _selectedParticipantIds = [];



  @override
  void didChangeDependencies() {//TODO жемини говорит обратно поменять на init state но у тебя были проблемы с init state потому что он не успевал подгрузить с provider expenses.
    super.didChangeDependencies();

    final provider = context.read<TripDashboardProvider>();

    if(_selectedPayerId == null && provider.participantsMap.isNotEmpty) {
      setState(() {
        _selectedPayerId = provider.participantsMap.keys.first;
      _selectedParticipantIds.addAll(provider.participantsMap.keys);
      });
      
    }    
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submitData() async {
    if(!_formKey.currentState!.validate()) return;
    if(_selectedPayerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select who paid')),
      );
      return;
    }

    if(_selectedParticipantIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one participant')),
      );
      return;

    }

    final provider = context.read<TripDashboardProvider>();
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    final success = await provider.addExpense(
      tripId: widget.tripId,
      payerId: _selectedPayerId!,
      amount: amount,
      description: _descriptionController.text.trim(),
      date: DateTime.now(),//TODO change it so the end user can choose date he did his transaction
      participantIds: _selectedParticipantIds,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense added successfully!')),
      );
      Navigator.pop(context);
    } else if (mounted && provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage!), backgroundColor: Colors.red),
      );
    }
  }




  
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TripDashboardProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Expense'),
      ),
      body: provider.isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  //Amount
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      prefixIcon: const Icon(Icons.attach_money),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (val) => (val == null || val.isEmpty || double.tryParse(val) == 0)
                        ? 'Enter a valid amount'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      
                      hintText: 'e.g., Dinner, Taxi, Tickets',
                      prefixIcon: const Icon(Icons.description_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (val) => (val == null || val.isEmpty) ? 'Enter description' : null,
                  ),
                  const SizedBox(height: 24),

                  // Payer
                  Text(
                    'Who Paid?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    key: ValueKey(_selectedPayerId),
                    value: provider.participantsMap.containsKey(_selectedPayerId)
                      ? _selectedPayerId
                      : null,
                    items: provider.participantsMap.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedPayerId = val),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Participants
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Split Between',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            if (_selectedParticipantIds.length == provider.participantsMap.length) {
                              _selectedParticipantIds.clear();
                            } else {
                              _selectedParticipantIds.clear();
                              _selectedParticipantIds.addAll(provider.participantsMap.keys);
                            }
                          });
                        },
                        child: Text(_selectedParticipantIds.length == provider.participantsMap.length
                            ? 'Deselect All' 
                            : 'Select All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Checkboxes
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: colorScheme.outlineVariant),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: provider.participantsMap.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final participantId = provider.participantsMap.keys.elementAt(index);
                        final participantName = provider.participantsMap[participantId] ?? "Unknown";
                        final isSelected = _selectedParticipantIds.contains(participantId);

                        return CheckboxListTile(
                          title: Text(participantName),
                          value: isSelected,
                          onChanged: (bool? checked) {
                            setState(() {
                              if (checked == true) {
                                _selectedParticipantIds.add(participantId);
                              } else {
                                _selectedParticipantIds.remove(participantId);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton.icon(
                      onPressed: _submitData,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Expense', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  

}