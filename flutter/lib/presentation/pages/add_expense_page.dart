import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_manager/core/date_time_extentions.dart';
import 'package:money_manager/l10n/app_localizations.dart';
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
  DateTime? _startDate;
  DateTime? _endDate;
  final List<String> _selectedParticipantIds = [];

  DateTime _selectedDate = DateTime.now();
  
  

  



  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final provider = context.read<TripDashboardProvider>();

    if(_selectedPayerId == null && provider.participantsMap.isNotEmpty) {
      setState(() {
        _selectedPayerId = provider.participantsMap.keys.first;
        _selectedParticipantIds.addAll(provider.participantsMap.keys);
        _startDate = provider.dashboard?.trip.startDate;
        _endDate = provider.dashboard?.trip.endDate;  
        if(_selectedDate.isAfter(_endDate!)) _selectedDate = _endDate!;   
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
    final l10n = AppLocalizations.of(context)!;
    if(!_formKey.currentState!.validate()) return;
    if(_selectedPayerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectWhoPaid)),
      );
      return;
    }

    if(_selectedParticipantIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectParticipants)),
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
      date: _selectedDate,
      participantIds: _selectedParticipantIds,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.expenseAdded)),
      );
      Navigator.pop(context);
    } else if (mounted && provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage!), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime today = DateTime.now().dateOnly;

    final DateTime tripStart = _startDate?.dateOnly ?? today;
      

    final DateTime tripEnd = _endDate?.dateOnly ?? today;
      

    final DateTime maxCalendarDate = tripEnd.isBefore(today) ? tripEnd : today;
    

    DateTime initialCalendatDate = _selectedDate.dateOnly;
    if(initialCalendatDate.isAfter(tripEnd)) {
      initialCalendatDate = tripEnd;
    } else if(initialCalendatDate.isBefore(tripStart)) {
      initialCalendatDate = tripStart;
    }


    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialCalendatDate,
      firstDate: tripStart,
      lastDate: maxCalendarDate,
    );
    if(picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formalDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }




  
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TripDashboardProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addNewExpense),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: l10n.amount,
                      prefixIcon: const Icon(Icons.attach_money),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (val) => (val == null || val.isEmpty || double.tryParse(val) == 0)
                        ? l10n.enterValidAmount
                        : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: l10n.description,
                      hintText: l10n.descriptionHint,
                      prefixIcon: const Icon(Icons.description_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (val) => (val == null || val.isEmpty) ? l10n.enterDescription : null,
                  ),
                  const SizedBox(height: 16),

                  Card(
                    margin: EdgeInsets.zero,
                    shape: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[400]!)),
                    child: ListTile(
                      leading: const Icon(Icons.calendar_month),
                      title: Text(l10n.transactionDate),
                      subtitle: Text(_formalDate(_selectedDate)),
                      trailing: TextButton(
                        onPressed: () => _selectDate(context),
                        child: Text(l10n.choose),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    l10n.whoPaid,
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
                        child: Text(entry.value.name),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedPayerId = val),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.splitBetween,
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
                            ? l10n.deselectAll
                            : l10n.selectAll),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

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
                        final participantName = provider.getParticipantName(participantId);
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
                      label: Text(l10n.saveExpense, style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  

}