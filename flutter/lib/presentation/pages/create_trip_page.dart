import 'package:flutter/material.dart';
import 'package:money_manager/core/constants/currencies.dart';
import 'package:money_manager/core/theme/app_theme.dart';
import 'package:money_manager/core/utils/date_picker_helper.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/presentation/providers/trips_provider.dart';
import 'package:provider/provider.dart';

class CreateTripPage extends StatefulWidget {
  const CreateTripPage({super.key});

  @override
  State<CreateTripPage> createState() => _CreateTripPageState();
}

class _CreateTripPageState extends State<CreateTripPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _budgetController = TextEditingController();

  String _selectedCurrency = 'EUR';
  DateTime? _startDate;
  DateTime? _endDate;

  double get _budget => double.tryParse(_budgetController.text) ?? 0.0;

  @override
  void initState() {
    super.initState();
    _budgetController.addListener(_updateState);
  }

  void _updateState() => setState(() {});

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final minimumDate = isStartDate ? DateTime(2025) : (_startDate ?? DateTime.now());
    final picked = await showStyledDatePicker(
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

  String _formatDate(DateTime? date, AppLocalizations l10n) {
    if (date == null) return l10n.notSet;
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.primary, AppTheme.secondary],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 20, 20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Icon(Icons.luggage, color: Colors.white70, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.createTrip,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.3),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel(l10n.general),
                    const SizedBox(height: 10),
                    _buildField(
                      controller: _nameController,
                      label: l10n.tripName,
                      icon: Icons.edit_outlined,
                      validator: (v) => (v == null || v.isEmpty) ? l10n.enterTripName : null,
                    ),
                    const SizedBox(height: 12),

                    GestureDetector(
                      onTap: () => _showCurrencyPicker(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.currency_exchange, color: AppTheme.textSecondary, size: 20),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.currency, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                const SizedBox(height: 2),
                                Text(
                                  () {
                                    final c = supportedCurrencies.firstWhere((c) => c.code == _selectedCurrency);
                                    return '${c.symbol}  ${c.code} — ${c.name}';
                                  }(),
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
                                ),
                              ],
                            ),
                            const Spacer(),
                            const Icon(Icons.keyboard_arrow_down, color: AppTheme.textSecondary),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    _sectionLabel(l10n.finance),
                    const SizedBox(height: 10),
                    _buildField(
                      controller: _budgetController,
                      label: l10n.myBudget,
                      icon: Icons.account_balance_wallet_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) => (v == null || v.isEmpty) ? l10n.enterTotalBudget : null,
                    ),

                    const SizedBox(height: 24),
                    _sectionLabel(l10n.dates),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _buildDateTile(context, l10n, isStart: true)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDateTile(context, l10n, isStart: false)),
                      ],
                    ),

                    const SizedBox(height: 36),
                    Consumer<TripsProvider>(
                      builder: (context, provider, _) => SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: provider.isLoading
                            ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                            : FilledButton(
                                onPressed: () => _onCreatePressed(context, provider, l10n),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                child: Text(l10n.createTrip,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppTheme.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildDateTile(BuildContext context, AppLocalizations l10n, {required bool isStart}) {
    final date = isStart ? _startDate : _endDate;
    final label = isStart ? l10n.startDateLabel : l10n.endDateLabel;
    final icon = isStart ? Icons.flight_takeoff : Icons.flight_land;

    return GestureDetector(
      onTap: () => _selectDate(context, isStart),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: date != null ? AppTheme.primary.withValues(alpha: 0.4) : Colors.grey.shade200,
            width: date != null ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: date != null ? AppTheme.primary : AppTheme.textSecondary),
                const SizedBox(width: 6),
                Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _formatDate(date, l10n),
              style: TextStyle(
                fontSize: 14,
                fontWeight: date != null ? FontWeight.w600 : FontWeight.normal,
                color: date != null ? AppTheme.textPrimary : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textSecondary),
        prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.red)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final searchController = TextEditingController();
    var filtered = supportedCurrencies.toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (_, scrollController) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    children: [
                      Container(
                        width: 40, height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                      ),
                      Text(l10n.currencyPickerTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                      const SizedBox(height: 14),
                      TextField(
                        controller: searchController,
                        onChanged: (q) {
                          setSheetState(() {
                            filtered = supportedCurrencies
                                .where((c) => c.code.toLowerCase().contains(q.toLowerCase()) || c.name.toLowerCase().contains(q.toLowerCase()))
                                .toList();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: l10n.searchHint,
                          prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary, size: 20),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final c = filtered[i];
                            final isSelected = c.code == _selectedCurrency;
                            return GestureDetector(
                              onTap: () {
                                setState(() => _selectedCurrency = c.code);
                                Navigator.pop(sheetContext);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppTheme.primary.withValues(alpha: 0.08) : Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected ? AppTheme.primary.withValues(alpha: 0.4) : Colors.grey.shade200,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40, height: 40,
                                      decoration: BoxDecoration(
                                        color: isSelected ? AppTheme.primary.withValues(alpha: 0.12) : Colors.grey.shade200,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(c.symbol, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                                            color: isSelected ? AppTheme.primary : AppTheme.textPrimary)),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(c.code, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15,
                                            color: isSelected ? AppTheme.primary : AppTheme.textPrimary)),
                                        Text(c.name, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                      ],
                                    ),
                                    const Spacer(),
                                    if (isSelected) Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 20),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _onCreatePressed(BuildContext context, TripsProvider provider, AppLocalizations l10n) async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.selectDates),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final success = await provider.addTrip(
      name: _nameController.text,
      budget: _budget,
      startDate: _startDate!,
      endDate: _endDate!,
      currency: _selectedCurrency,
    );

    if (!context.mounted) return;
    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(provider.errorMessage ?? l10n.failedToCreateTrip),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }
}
