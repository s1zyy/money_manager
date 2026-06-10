

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
  void initState() {// TODO check why we should change init state on didChangeDependencies
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<TripDashboardProvider>();
      print("Participants: ${provider.participants.length}");
      if (provider.participants.isNotEmpty) {
        setState(() {
          //base case 
          _selectedPayerId = provider.participants.first.participantId;
          _selectedParticipantIds.addAll(provider.participants.map((p) => p.participantId));
        });
      }
    });

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
                    value: _selectedPayerId,
                    items: provider.participants.map((p) {
                      return DropdownMenuItem<String>(
                        value: p.participantId,
                        child: Text(p.name),
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
                            if (_selectedParticipantIds.length == provider.participants.length) {
                              _selectedParticipantIds.clear();
                            } else {
                              _selectedParticipantIds.clear();
                              _selectedParticipantIds.addAll(provider.participants.map((p) => p.participantId));
                            }
                          });
                        },
                        child: Text(_selectedParticipantIds.length == provider.participants.length 
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
                      itemCount: provider.participants.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final participant = provider.participants[index];
                        final isSelected = _selectedParticipantIds.contains(participant.participantId);

                        return CheckboxListTile(
                          title: Text(participant.name),
                          value: isSelected,
                          onChanged: (bool? checked) {
                            setState(() {
                              if (checked == true) {
                                _selectedParticipantIds.add(participant.participantId);
                              } else {
                                _selectedParticipantIds.remove(participant.participantId);
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
  // Widget build(BuildContext context) {
  //   final colorScheme = Theme.of(context).colorScheme;
  //   final isLoading = context.watch<TripDashboardProvider>().isLoading;

  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text('Add new Expense'),
  //     ),
  //     body: GestureDetector(
  //       onTap: () => FocusScope.of(context).unfocus(), 
  //       child: SingleChildScrollView(
  //         padding: const EdgeInsets.all(24.0),
  //         child: Form(
  //           key: _formKey,
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 'Enter expense details',
  //                 style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
  //               ),
  //               const SizedBox(height: 24),

  //               TextFormField(
  //                 controller: _descriptionController,
  //                 decoration: const InputDecoration(
  //                   labelText: 'Description',
  //                   prefixIcon: Icon(Icons.description_outlined),
  //                   border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
  //                   hintText: 'e.g., Dinner, Gasoline, Hotel',
  //                 ),
  //                 validator: (value) {
  //                   if (value == null || value.trim().isEmpty) {
  //                     return 'Please enter a description';
  //                   }
  //                   return null;
  //                 },
  //               ),
  //               const SizedBox(height: 20),

  //               // --- ПОЛЕ СУММЫ ---
  //               TextFormField(
  //                 controller: _amountController,
  //                 keyboardType: const TextInputType.numberWithOptions(decimal: true),
  //                 decoration: const InputDecoration(
  //                   labelText: 'Amount',
  //                   prefixIcon: Icon(Icons.euro_outlined),
  //                   border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
  //                   hintText: '0.00',
  //                 ),
  //                 validator: (value) {
  //                   if (value == null || value.trim().isEmpty) {
  //                     return 'Please enter an amount';
  //                   }
  //                   if (double.tryParse(value) == null) {
  //                     return 'Please enter a valid number';
  //                   }
  //                   if (double.parse(value) <= 0) {
  //                     return 'Amount must be greater than zero';
  //                   }
  //                   return null;
  //                 },
  //               ),
  //               const SizedBox(height: 40),

  //               // --- КНОПКА ОТПРАВКИ ---
  //               SizedBox(
  //                 width: double.infinity,
  //                 height: 54,
  //                 child: FilledButton(
  //                   onPressed: isLoading ? null : _submitData,
  //                   style: FilledButton.styleFrom(
  //                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //                   ),
  //                   child: isLoading
  //                       ? const SizedBox(
  //                           width: 24,
  //                           height: 24,
  //                           child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
  //                         )
  //                       : const Text('Save Expense', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

}