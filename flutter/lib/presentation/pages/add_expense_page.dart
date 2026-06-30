import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_manager/core/date_time_extensions.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:money_manager/presentation/providers/trip_dashboard_provider.dart';

class AddExpensePage extends StatefulWidget {
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
  DateTime _selectedDate = DateTime.now();

  String _splitMode = 'EQUAL';
  bool _eachPaidOwn = false;

  final List<String> _selectedParticipantIds = [];
  final Map<String, TextEditingController> _shareControllers = {};

  double get _totalAmount => double.tryParse(_amountController.text) ?? 0.0;

  int get _totalCents => (_totalAmount * 100).round();

  int get _distributedCents {
    int sum = 0;
    for (final id in _selectedParticipantIds) {
      final val = double.tryParse(_shareControllers[id]?.text ?? '') ?? 0.0;
      sum += (val * 100).round();
    }
    return sum;
  }

  int get _remainingCents => _totalCents - _distributedCents;

  double get _remaining => _remainingCents / 100.0;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
  }

  void _onAmountChanged() {
    if (_splitMode == 'CUSTOM') setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<TripDashboardProvider>();
    if (_selectedPayerId == null && provider.participantsMap.isNotEmpty) {
      setState(() {
        _selectedPayerId = provider.participantsMap.keys.first;
        _selectedParticipantIds.addAll(provider.participantsMap.keys);
        _startDate = provider.dashboard?.trip.startDate;
        _endDate = provider.dashboard?.trip.endDate;
        if (_endDate != null && _selectedDate.isAfter(_endDate!)) {
          _selectedDate = _endDate!;
        }
        for (final id in provider.participantsMap.keys) {
          _shareControllers[id] = TextEditingController()
            ..addListener(() => setState(() {}));
        }
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    for (final c in _shareControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _submitData() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    if (_splitMode == 'EQUAL') {
      if (!_eachPaidOwn && _selectedPayerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.selectWhoPaid)),
        );
        return;
      }
      if (_selectedParticipantIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.selectParticipants)),
        );
        return;
      }
    } else {
      // CUSTOM
      if (!_eachPaidOwn && _selectedPayerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.selectWhoPaid)),
        );
        return;
      }
      if (_selectedParticipantIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.selectParticipants)),
        );
        return;
      }
      if (_remainingCents != 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.sharesMustSumToTotal),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final provider = context.read<TripDashboardProvider>();
    final amount = _totalAmount;

    bool success;
    if (_splitMode == 'EQUAL') {
      success = await provider.addExpense(
        tripId: widget.tripId,
        payerId: _eachPaidOwn ? null : _selectedPayerId,
        amount: amount,
        date: _selectedDate,
        splitMode: 'EQUAL',
        participantIds: _selectedParticipantIds,
        description: _descriptionController.text.trim(),
      );
    } else {
      final shares = <String, double>{};
      for (final id in _selectedParticipantIds) {
        shares[id] = double.tryParse(_shareControllers[id]?.text ?? '') ?? 0.0;
      }
      success = await provider.addExpense(
        tripId: widget.tripId,
        payerId: _eachPaidOwn ? null : _selectedPayerId,
        amount: amount,
        date: _selectedDate,
        splitMode: 'CUSTOM',
        customShares: shares,
        description: _descriptionController.text.trim(),
      );
    }

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

    DateTime initialDate = _selectedDate.dateOnly;
    if (initialDate.isAfter(tripEnd)) {
      initialDate = tripEnd;
    } else if (initialDate.isBefore(tripStart)) {
      initialDate = tripStart;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: tripStart,
      lastDate: maxCalendarDate,
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
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
    final isCustom = _splitMode == 'CUSTOM';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addNewExpense)),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Amount
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

                  // Description
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

                  // Date
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

                  // Split mode toggle
                  Row(
                    children: [
                      Text(
                        'Split mode',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      SegmentedButton<String>(
                        segments: [
                          ButtonSegment(value: 'EQUAL', label: Text(l10n.splitEqual)),
                          ButtonSegment(value: 'CUSTOM', label: Text(l10n.splitCustom)),
                        ],
                        selected: {_splitMode},
                        onSelectionChanged: (val) => setState(() {
                          _splitMode = val.first;
                          _eachPaidOwn = false;
                        }),
                        style: const ButtonStyle(
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Who paid
                  if (!_eachPaidOwn) ...[
                    Text(
                      l10n.whoPaid,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      key: ValueKey(_selectedPayerId),
                      value: provider.participantsMap.containsKey(_selectedPayerId) ? _selectedPayerId : null,
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
                    const SizedBox(height: 8),
                  ],

                  // Each paid own toggle (only in CUSTOM mode)
                  if (isCustom)
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.eachPaidOwn),
                      value: _eachPaidOwn,
                      onChanged: (val) => setState(() => _eachPaidOwn = val),
                    ),

                  const SizedBox(height: 8),

                  // Participants header
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

                  // Remaining counter (only in CUSTOM mode)
                  if (isCustom) ...[
                    _RemainingBanner(remaining: _remaining),
                    const SizedBox(height: 8),
                  ],

                  // Participants list
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

                        if (!isCustom) {
                          return CheckboxListTile(
                            title: Text(participantName),
                            value: isSelected,
                            onChanged: (checked) {
                              setState(() {
                                if (checked == true) {
                                  _selectedParticipantIds.add(participantId);
                                } else {
                                  _selectedParticipantIds.remove(participantId);
                                }
                              });
                            },
                          );
                        }

                        // CUSTOM mode row
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          child: Row(
                            children: [
                              Checkbox(
                                value: isSelected,
                                onChanged: (checked) {
                                  setState(() {
                                    if (checked == true) {
                                      _selectedParticipantIds.add(participantId);
                                    } else {
                                      _selectedParticipantIds.remove(participantId);
                                      _shareControllers[participantId]?.clear();
                                    }
                                  });
                                },
                              ),
                              Expanded(child: Text(participantName)),
                              if (isSelected)
                                SizedBox(
                                  width: 100,
                                  child: TextField(
                                    controller: _shareControllers[participantId],
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                                    ],
                                    textAlign: TextAlign.right,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      hintText: '0.00',
                                    ),
                                  ),
                                ),
                            ],
                          ),
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

class _RemainingBanner extends StatelessWidget {
  final double remaining;
  const _RemainingBanner({required this.remaining});

  @override
  Widget build(BuildContext context) {
    final isZero = (remaining * 100).round() == 0;
    final color = isZero ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isZero ? 'All distributed' : 'Remaining to distribute',
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
          Text(
            isZero ? '✓' : '${remaining.toStringAsFixed(2)}',
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
