import 'package:flutter/material.dart';
import 'package:money_manager/core/constants/currencies.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:money_manager/presentation/providers/trip_dashboard_provider.dart';

class TripSettingsPage extends StatefulWidget {
  final String tripId;
  const TripSettingsPage({super.key, required this.tripId});

  @override
  State<TripSettingsPage> createState() => _TripSettingsPageState();
}

class _TripSettingsPageState extends State<TripSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _budgetController;
  late TextEditingController _prepaidController;
  
  String _selectedCurrency = 'EUR';

  double get _totalBudget => double.tryParse(_budgetController.text) ?? 0.0;
  double get _prepaidExpenses => double.tryParse(_prepaidController.text) ?? 0.0;
  late DateTime _currentEndDate;
  late DateTime _initialEndDate;

  @override
  void initState() {
    super.initState();

    final dashboard = context.read<TripDashboardProvider>().dashboard;
    _nameController = TextEditingController(text: dashboard?.trip.name ?? '');
    _budgetController = TextEditingController(text: dashboard?.trip.totalBudget.toString() ?? '0.0');
    _prepaidController = TextEditingController(text: dashboard?.trip.prepaidExpenses.toString() ?? '0.0');
    _selectedCurrency = dashboard?.trip.currency ?? 'EUR';
    _currentEndDate = dashboard?.trip.endDate ?? DateTime.now();
    _initialEndDate = dashboard?.trip.endDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    _prepaidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final dashboardProvider = context.watch<TripDashboardProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tripSettings),
        actions: [
          if(dashboardProvider.dashboard!.isOwner)...[
            TextButton(
              onPressed: _saveSettings,
              child: Text(l10n.save, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            )
          ]

        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if(dashboardProvider.dashboard!.isOwner)...[
              Text(l10n.general, style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: l10n.tripName, border: const OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? l10n.enterName : null,
              ),
              const SizedBox(height: 20),

              Text(l10n.finance, style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.totalBudget, border: const OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? l10n.enterBudget : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _prepaidController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.prepaidExpenses, border: const OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) return l10n.enterPrepaid;
                  if (_prepaidExpenses > _totalBudget) {
                    return l10n.prepaidExceedsBudget;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedCurrency,
                decoration: InputDecoration(labelText: l10n.tripCurrency, border: const OutlineInputBorder()),
                items: supportedCurrencies.map((c) => DropdownMenuItem(
                  value: c.code,
                  child: Text('${c.symbol}  ${c.name} (${c.code})'),
                  )).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCurrency = val);
                },
              ),


              const SizedBox(height: 16),

              Text(l10n.dates, style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              OutlinedButton.icon(
                onPressed: _extendTrip,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                icon: const Icon(Icons.calendar_today),
                label: Text(l10n.endDate(_currentEndDate.toIso8601String().split('T')[0])),
                ),

              const SizedBox(height: 32),

              const Divider(),

              const SizedBox(height: 16),
              Text(l10n.dangerZone, style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: _archiveTrip,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: BorderSide(color: colorScheme.error),
                  foregroundColor: colorScheme.error,
                ),
                icon: const Icon(Icons.archive_outlined),
                label: Text(l10n.archiveTrip),
              ),
              const SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: _deleteTrip,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: colorScheme.errorContainer,
                  foregroundColor: colorScheme.onErrorContainer,
                  elevation: 0,
                ),
                icon: const Icon(Icons.delete_forever),
                label: Text(l10n.deleteTrip),
              ),
            ],
              if(dashboardProvider.dashboard!.canLeave)...[
              const Divider(),
              const SizedBox(height: 16),
              Text(l10n.dangerZone, style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _leaveTrip,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: BorderSide(color: colorScheme.error),
                  foregroundColor: colorScheme.error,
                ),
                icon: const Icon(Icons.exit_to_app),
                label: Text(l10n.leaveTrip),
              ),
            ],
            ],
          ),
        ),
      ),
    );
  }

  void _saveSettings() async {
    final l10n = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      final provider = context.read<TripDashboardProvider>();
      final success = await provider.updateTrip(
        tripId: widget.tripId,
        name: _nameController.text.trim(),
        totalBudget: _totalBudget,
        prepaidExpenses: _prepaidExpenses,
        currency: _selectedCurrency,
        endDate: _currentEndDate,
        );

        if(mounted) {
          if(success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.settingsSaved)),
            );
            Navigator.pop(context);
          } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(provider.errorMessage ?? l10n.failedToSave)),
          );


        }
      }
    }
  }

  void _archiveTrip() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await _showConfirmDialog(
      title: l10n.archiveTripConfirm,
      content: l10n.archiveTripMessage,
      confirmLabel: l10n.archiveTrip,
    );
    if (confirm == true) {
      final provider = context.read<TripDashboardProvider>();
      final success = await provider.archiveTrip(widget.tripId);
      if(mounted) {
        if(success) {
          Navigator.pop(context);
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.errorMessage ?? l10n.failedToArchive)),
        );
        }
      }
    }
  }

  void _leaveTrip() async {
  final l10n = AppLocalizations.of(context)!;
  final confirm = await _showConfirmDialog(
    title: l10n.leaveTripConfirm,
    content: l10n.leaveTripMessage,
    confirmLabel: l10n.leaveTrip,
    isDangerous: true,
  );
  if (confirm == true) {
    final provider = context.read<TripDashboardProvider>();
    final success = await provider.leaveTrip(widget.tripId);
    if (mounted) {
      if (success) {
        Navigator.pop(context);
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.errorMessage ?? l10n.failedToLeave)),
        );
      }
    }
  }
}

  void _deleteTrip() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await _showConfirmDialog(
      title: l10n.deleteTripConfirm,
      content: l10n.deleteTripMessage,
      confirmLabel: l10n.deleteTrip,
      isDangerous: true,
    );
    if (confirm == true) {
      await context.read<TripDashboardProvider>().deleteTrip(widget.tripId);
      Navigator.pop(context);
      Navigator.pop(context);
    }
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String content,
    required String confirmLabel,
    bool isDangerous = false,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: isDangerous ? FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error) : null,
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }


  void _extendTrip() async {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    if(now.isAfter(_currentEndDate)){
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.tripHasEnded)),
      );

      return;
    }
    final picked = await showDatePicker(
    context: context,
    initialDate: _currentEndDate,
    firstDate: _initialEndDate,
    lastDate: _currentEndDate.add(const Duration(days: 365)),
    );

    if (picked != null && !picked.isBefore(_initialEndDate)) {
      setState(() => _currentEndDate = picked);
    }
  }
}