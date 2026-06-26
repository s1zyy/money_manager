import 'package:flutter/material.dart';
import 'package:money_manager/core/constants/currencies.dart';
import 'package:money_manager/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createTrip),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: l10n.tripName, border: const OutlineInputBorder()),
              validator: (value) => value == null || value.isEmpty ? l10n.enterTripName : null,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedCurrency,
              decoration: InputDecoration(
                labelText: l10n.currency,
                border: const OutlineInputBorder(),
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
              decoration: InputDecoration(labelText: l10n.totalBudget, border: const OutlineInputBorder()),
              validator: (value) => value == null || value.isEmpty ? l10n.enterTotalBudget : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _prepaidController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.prepaidAmount,
                border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if(value == null || value.isEmpty) {
                    return l10n.enterPrepaidAmount;
                  }

                  if(_prepaidExpenses > _totalBudget) {
                    return l10n.prepaidExceedsBudget;
                  }
                  return null;
                }
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text(l10n.startDateLabel),
                    subtitle: Text(_startDate == null ? l10n.notSet : _startDate!.toIso8601String().split('T')[0]),
                    onTap: () => _selectDate(context, true),
                    tileColor: Colors.grey[200],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ListTile(
                    title: Text(l10n.endDateLabel),
                    subtitle: Text(_endDate == null ? l10n.notSet : _endDate!.toIso8601String().split('T')[0]),
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
                    SnackBar(content: Text(l10n.selectDates)),
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
                    SnackBar(content: Text(provider.errorMessage ?? l10n.failedToCreateTrip)),
                  );
                }
                }
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: Text(l10n.createTrip),
            )
          ]
        ),
      ),
      ),
    );
  }
}