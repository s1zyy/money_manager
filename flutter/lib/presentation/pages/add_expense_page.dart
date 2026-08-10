import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_manager/core/constants/currencies.dart';
import 'package:money_manager/core/utils/overlay_notification.dart';
import 'package:money_manager/core/date_time_extensions.dart';
import 'package:money_manager/core/theme/app_theme.dart';
import 'package:money_manager/core/utils/date_picker_helper.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:money_manager/presentation/providers/trip_dashboard_provider.dart';

class AddExpensePage extends StatefulWidget {
  final String tripId;
  final bool forcePrepaid;
  const AddExpensePage({Key? key, required this.tripId, this.forcePrepaid = false}) : super(key: key);

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
  late bool _isPrepaid;

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
    _isPrepaid = widget.forcePrepaid;
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
        if (_endDate != null && _selectedDate.isAfter(_endDate!)) _selectedDate = _endDate!;
        for (final id in provider.participantsMap.keys) {
          _shareControllers[id] = TextEditingController()..addListener(() => setState(() {}));
        }
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    for (final c in _shareControllers.values) c.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final today = DateTime.now().dateOnly;
    final tripStart = _startDate?.dateOnly ?? today;
    final tripEnd = _endDate?.dateOnly ?? today;
    final maxDate = tripEnd.isBefore(today) ? tripEnd : today;
    var initialDate = _selectedDate.dateOnly;
    if (initialDate.isAfter(tripEnd)) initialDate = tripEnd;
    else if (initialDate.isBefore(tripStart)) initialDate = tripStart;

    final picked = await showStyledDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: tripStart,
      lastDate: maxDate,
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  String _formatDate(DateTime date) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _submitData() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (!_eachPaidOwn && _selectedPayerId == null) {
      showErrorOverlay(context, l10n.selectWhoPaid);
      return;
    }
    if (_selectedParticipantIds.isEmpty) {
      showErrorOverlay(context, l10n.selectParticipants);
      return;
    }
    if (_splitMode == 'CUSTOM' && _remainingCents != 0) {
      showErrorOverlay(context, l10n.sharesMustSumToTotal);
      return;
    }

    final provider = context.read<TripDashboardProvider>();
    final date = _isPrepaid ? null : _selectedDate;
    bool success;
    if (_splitMode == 'EQUAL') {
      success = await provider.addExpense(tripId: widget.tripId, payerId: _eachPaidOwn ? null : _selectedPayerId, amount: _totalAmount, date: date, splitMode: 'EQUAL', participantIds: _selectedParticipantIds, description: _descriptionController.text.trim(), isPrepaid: _isPrepaid);
    } else {
      final shares = <String, double>{};
      for (final id in _selectedParticipantIds) shares[id] = double.tryParse(_shareControllers[id]?.text ?? '') ?? 0.0;
      success = await provider.addExpense(tripId: widget.tripId, payerId: _eachPaidOwn ? null : _selectedPayerId, amount: _totalAmount, date: date, splitMode: 'CUSTOM', customShares: shares, description: _descriptionController.text.trim(), isPrepaid: _isPrepaid);
    }

    if (success && mounted) {
      showSuccessOverlay(context, l10n.expenseAdded);
      Navigator.pop(context);
    } else if (mounted && provider.errorMessage != null) {
      showErrorOverlay(context, provider.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TripDashboardProvider>();
    final l10n = AppLocalizations.of(context)!;
    final cs = currencySymbol(provider.dashboard?.trip.currency ?? 'EUR');
    final isCustom = _splitMode == 'CUSTOM';
    final isSolo = provider.participantsMap.length == 1;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppTheme.primary, AppTheme.secondary]),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 20, 20),
                child: Row(
                  children: [
                    IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white), onPressed: () => Navigator.pop(context)),
                    const Icon(Icons.add_card, color: Colors.white70, size: 22),
                    const SizedBox(width: 8),
                    Expanded(child: Text(l10n.addNewExpense, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.3), overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                      children: [
                        TextFormField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          decoration: InputDecoration(
                            labelText: l10n.amount,
                            labelStyle: const TextStyle(color: AppTheme.textSecondary),
                            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: Text(cs, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                            ),
                            filled: true, fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
                            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.red)),
                          ),
                          validator: (val) => (val == null || val.isEmpty || double.tryParse(val) == 0) ? l10n.enterValidAmount : null,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _descriptionController,
                          style: const TextStyle(color: AppTheme.textPrimary),
                          decoration: InputDecoration(
                            labelText: l10n.description,
                            hintText: l10n.descriptionHint,
                            labelStyle: const TextStyle(color: AppTheme.textSecondary),
                            prefixIcon: const Icon(Icons.description_outlined, color: AppTheme.textSecondary, size: 20),
                            filled: true, fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
                            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.red)),
                          ),
                          validator: (val) => (val == null || val.isEmpty) ? l10n.enterDescription : null,
                        ),
                        const SizedBox(height: 12),

                        GestureDetector(
                          onTap: widget.forcePrepaid ? null : () => setState(() => _isPrepaid = !_isPrepaid),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: _isPrepaid ? AppTheme.primary.withValues(alpha: 0.08) : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: _isPrepaid ? AppTheme.primary.withValues(alpha: 0.3) : Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.credit_card_outlined, color: _isPrepaid ? AppTheme.primary : AppTheme.textSecondary, size: 20),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(l10n.prepaid, style: TextStyle(fontWeight: FontWeight.w500, color: _isPrepaid ? AppTheme.primary : AppTheme.textPrimary)),
                                    Text(l10n.prepaidDescription, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                  ],
                                ),
                                const Spacer(),
                                Switch(value: _isPrepaid, onChanged: widget.forcePrepaid ? null : (val) => setState(() => _isPrepaid = val), activeThumbColor: AppTheme.primary),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        if (!_isPrepaid) ...[
                          GestureDetector(
                            onTap: () => _selectDate(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined, color: AppTheme.textSecondary, size: 20),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(l10n.transactionDate, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                      Text(_formatDate(_selectedDate), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                                    ],
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.keyboard_arrow_down, color: AppTheme.textSecondary),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Split mode
                        if (!isSolo) ...[
                        _sectionLabel('Split'),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(14)),
                          child: Row(
                            children: ['EQUAL', 'CUSTOM'].map((mode) {
                              final selected = _splitMode == mode;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() { _splitMode = mode; _eachPaidOwn = false; }),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: selected ? Colors.white : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: selected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6, offset: const Offset(0, 2))] : [],
                                    ),
                                    child: Text(
                                      mode == 'EQUAL' ? l10n.splitEqual : l10n.splitCustom,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontWeight: FontWeight.w600, color: selected ? AppTheme.primary : AppTheme.textSecondary),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Who paid
                        if (!_eachPaidOwn) ...[
                          _sectionLabel(l10n.whoPaid),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade200)),
                            child: DropdownButtonFormField<String>(
                              key: ValueKey(_selectedPayerId),
                              value: provider.participantsMap.containsKey(_selectedPayerId) ? _selectedPayerId : null,
                              items: provider.participantsMap.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value.name))).toList(),
                              onChanged: (val) => setState(() => _selectedPayerId = val),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                prefixIcon: Icon(Icons.person_outline, color: AppTheme.textSecondary, size: 20),
                                contentPadding: EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        if (isCustom)
                          GestureDetector(
                            onTap: () => setState(() => _eachPaidOwn = !_eachPaidOwn),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: _eachPaidOwn ? AppTheme.primary.withValues(alpha: 0.08) : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: _eachPaidOwn ? AppTheme.primary.withValues(alpha: 0.3) : Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.people_outline, color: _eachPaidOwn ? AppTheme.primary : AppTheme.textSecondary, size: 20),
                                  const SizedBox(width: 12),
                                  Text(l10n.eachPaidOwn, style: TextStyle(fontWeight: FontWeight.w500, color: _eachPaidOwn ? AppTheme.primary : AppTheme.textPrimary)),
                                  const Spacer(),
                                  Switch(value: _eachPaidOwn, onChanged: (val) => setState(() => _eachPaidOwn = val), activeThumbColor: AppTheme.primary),
                                ],
                              ),
                            ),
                          ),

                        const SizedBox(height: 20),

                        // Participants
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _sectionLabel(l10n.splitBetween),
                            GestureDetector(
                              onTap: () => setState(() {
                                if (_selectedParticipantIds.length == provider.participantsMap.length) {
                                  _selectedParticipantIds.clear();
                                } else {
                                  _selectedParticipantIds.clear();
                                  _selectedParticipantIds.addAll(provider.participantsMap.keys);
                                }
                              }),
                              child: Text(
                                _selectedParticipantIds.length == provider.participantsMap.length ? l10n.deselectAll : l10n.selectAll,
                                style: const TextStyle(fontSize: 13, color: AppTheme.primary, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        if (isCustom)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _RemainingBanner(remaining: _remaining),
                          ),

                        Container(
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade200)),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: provider.participantsMap.length,
                            separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
                            itemBuilder: (_, index) {
                              final id = provider.participantsMap.keys.elementAt(index);
                              final name = provider.getParticipantName(id);
                              final isSelected = _selectedParticipantIds.contains(id);
                              final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

                              if (!isCustom) {
                                return InkWell(
                                  onTap: () => setState(() {
                                    if (isSelected) _selectedParticipantIds.remove(id);
                                    else _selectedParticipantIds.add(id);
                                  }),
                                  borderRadius: BorderRadius.circular(14),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    child: Row(
                                      children: [
                                        CircleAvatar(radius: 16, backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
                                          child: Text(initial, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary))),
                                        const SizedBox(width: 12),
                                        Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w500, color: AppTheme.textPrimary))),
                                        Container(
                                          width: 22, height: 22,
                                          decoration: BoxDecoration(
                                            color: isSelected ? AppTheme.primary : Colors.transparent,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: isSelected ? AppTheme.primary : Colors.grey.shade300, width: 1.5),
                                          ),
                                          child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 13) : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => setState(() {
                                        if (isSelected) { _selectedParticipantIds.remove(id); _shareControllers[id]?.clear(); }
                                        else _selectedParticipantIds.add(id);
                                      }),
                                      child: Container(
                                        width: 22, height: 22,
                                        decoration: BoxDecoration(
                                          color: isSelected ? AppTheme.primary : Colors.transparent,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: isSelected ? AppTheme.primary : Colors.grey.shade300, width: 1.5),
                                        ),
                                        child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 13) : null,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    CircleAvatar(radius: 14, backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
                                      child: Text(initial, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary))),
                                    const SizedBox(width: 10),
                                    Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w500, color: AppTheme.textPrimary))),
                                    if (isSelected)
                                      SizedBox(
                                        width: 90,
                                        child: TextField(
                                          controller: _shareControllers[id],
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                                          decoration: InputDecoration(
                                            isDense: true,
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
                                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.primary)),
                                            hintText: '0.00',
                                            filled: true, fillColor: AppTheme.background,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        ], // isSolo

                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton.icon(
                            onPressed: _submitData,
                            icon: const Icon(Icons.check_rounded),
                            label: Text(l10n.saveExpense, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary, letterSpacing: 0.5));
}

class _RemainingBanner extends StatelessWidget {
  final double remaining;
  const _RemainingBanner({required this.remaining});

  @override
  Widget build(BuildContext context) {
    final isZero = (remaining * 100).round() == 0;
    final color = isZero ? const Color(0xFF22C55E) : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(isZero ? Icons.check_circle_outline : Icons.pending_outlined, color: color, size: 18),
              const SizedBox(width: 8),
              Text(isZero ? 'All distributed' : 'Remaining', style: TextStyle(color: color, fontWeight: FontWeight.w600)),
            ],
          ),
          Text(isZero ? '✓' : remaining.toStringAsFixed(2), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
