import 'package:flutter/material.dart';
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
  
  // Самые популярные валюты для App Store
  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'RUB', 'PLN', 'UAH', 'AED', 'CAD'];
  String _selectedCurrency = 'USD'; 

  double get _totalBudget => double.tryParse(_budgetController.text) ?? 0.0;
  double get _prepaidExpenses => double.tryParse(_prepaidController.text) ?? 0.0;

  @override
  void initState() {
    super.initState();
    // Инициализируем контроллеры текущими данными из дашборда
    final dashboard = context.read<TripDashboardProvider>().dashboard;
    _nameController = TextEditingController(text: dashboard?.trip.name ?? '');
    _budgetController = TextEditingController(text: dashboard?.trip.totalBudget.toString() ?? '0.0');
    _prepaidController = TextEditingController(text: dashboard?.trip.prepaidExpenses.toString() ?? '0.0');
    // _selectedCurrency = dashboard?.trip.currency ?? 'USD'; // Когда добавишь в домен
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
    final dashboardProvider = context.watch<TripDashboardProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Settings'),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text('Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('General', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Trip Name', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 20),

              Text('Finance', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Total Budget', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Enter budget' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _prepaidController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Prepaid Expenses', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter prepaid amount';
                  if (_prepaidExpenses > _totalBudget) {
                    return 'Prepaid cannot exceed total budget';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Селектор валюты
              DropdownButtonFormField<String>(
                value: _selectedCurrency,
                decoration: const InputDecoration(labelText: 'Trip Currency', border: OutlineInputBorder()),
                items: _currencies.map((curr) => DropdownMenuItem(value: curr, child: Text(curr))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCurrency = val);
                },
              ),
              const SizedBox(height: 32),

              const Divider(),
              const SizedBox(height: 16),
              Text('Danger Zone', style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // Кнопка Архивирования
              OutlinedButton.icon(
                onPressed: _archiveTrip,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: BorderSide(color: colorScheme.error),
                  foregroundColor: colorScheme.error,
                ),
                icon: const Icon(Icons.archive_outlined),
                label: const Text('Archive Trip'),
              ),
              const SizedBox(height: 12),

              // Кнопка Удаления
              ElevatedButton.icon(
                onPressed: _deleteTrip,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: colorScheme.errorContainer,
                  foregroundColor: colorScheme.onErrorContainer,
                  elevation: 0,
                ),
                icon: const Icon(Icons.delete_forever),
                label: const Text('Delete Trip Permanently'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      // Тут вызываешь метод из своего провайдера для апдейта трипа
      // await context.read<TripDashboardProvider>().updateTripDetails(...);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved!')));
      Navigator.pop(context);
    }
  }

  void _archiveTrip() async {
    // Показываем подтверждение
    final confirm = await _showConfirmDialog(
      title: 'Archive Trip?',
      content: 'This will move the trip to the Archived tab.',
      confirmLabel: 'Archive',
    );
    if (confirm == true) {
      // Исполняем на бэке через провайдер
      Navigator.pop(context); // Возврат на главную
    }
  }

  void _deleteTrip() async {
    final confirm = await _showConfirmDialog(
      title: 'Delete Trip?',
      content: 'Are you absolutely sure? This action cannot be undone and all expense history will be lost.',
      confirmLabel: 'Delete',
      isDangerous: true,
    );
    if (confirm == true) {
      // Удаляем трип через TripsProvider
      // await context.read<TripsProvider>().deleteTrip(widget.tripId);
      Navigator.pop(context); // Выходим из настроек
      Navigator.pop(context); // Выходим из деталей трипа на главный экран
    }
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String content,
    required String confirmLabel,
    bool isDangerous = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: isDangerous ? FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error) : null,
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }
}