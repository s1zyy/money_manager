import 'package:flutter/material.dart';
import 'package:money_manager/core/constants/currencies.dart';
import 'package:money_manager/core/theme/app_theme.dart';
import 'package:money_manager/core/utils/date_picker_helper.dart';
import 'package:money_manager/domain/entities/trip.dart';
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
  late TextEditingController _myBudgetController;

  String _selectedCurrency = 'EUR';
  double get _myBudget => double.tryParse(_myBudgetController.text) ?? 0.0;
  late DateTime _currentStartDate;
  late DateTime _currentEndDate;

  @override
  void initState() {
    super.initState();
    final provider = context.read<TripDashboardProvider>();
    final dashboard = provider.dashboard;
    _nameController = TextEditingController(text: dashboard?.trip.name ?? '');
    _myBudgetController = TextEditingController(text: _formatNumber(provider.myBudget));
    _selectedCurrency = dashboard?.trip.currency ?? 'EUR';
    _currentStartDate = dashboard?.trip.startDate ?? DateTime.now();
    _currentEndDate = dashboard?.trip.endDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _myBudgetController.dispose();
    super.dispose();
  }

  String _formatNumber(double value) {
    if (value == value.truncateToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  String _formatDate(DateTime date) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<TripDashboardProvider>();
    final isOwner = provider.dashboard!.isOwner;
    final status = provider.dashboard!.trip.status;
    final isArchived = status == TripStatus.archived;
    final isUpcoming = status == TripStatus.upcoming;
    final canEdit = isOwner && !isArchived;
    final canEditBudget = !isArchived;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppTheme.primary, AppTheme.secondary]),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 8, 20),
                child: Row(
                  children: [
                    IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white), onPressed: () => Navigator.pop(context)),
                    const Icon(Icons.settings_outlined, color: Colors.white70, size: 22),
                    const SizedBox(width: 8),
                    Expanded(child: Text(l10n.tripSettings, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.3))),
                    if (canEditBudget)
                      TextButton(
                        onPressed: _saveSettings,
                        style: TextButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.white.withValues(alpha: 0.2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        child: Text(l10n.save, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    if (canEdit) ...[
                      _sectionLabel(l10n.general),
                      const SizedBox(height: 10),
                      _buildField(controller: _nameController, label: l10n.tripName, icon: Icons.edit_outlined,
                          validator: (v) => (v == null || v.isEmpty) ? l10n.enterName : null),
                      const SizedBox(height: 24),
                    ],

                    if (canEditBudget) ...[
                      _sectionLabel(l10n.finance),
                      const SizedBox(height: 14),
                      _buildField(controller: _myBudgetController, label: l10n.myBudget, icon: Icons.account_balance_wallet_outlined,
                          keyboardType: TextInputType.number, highlighted: true),
                      if (canEdit) ...[
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => _showCurrencyPicker(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade200)),
                            child: Row(
                              children: [
                                const Icon(Icons.currency_exchange, color: AppTheme.textSecondary, size: 20),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(l10n.tripCurrency, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                    const SizedBox(height: 1),
                                    Text(() {
                                      final c = supportedCurrencies.firstWhere((c) => c.code == _selectedCurrency);
                                      return '${c.symbol}  ${c.code} — ${c.name}';
                                    }(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
                                  ],
                                ),
                                const Spacer(),
                                const Icon(Icons.keyboard_arrow_down, color: AppTheme.textSecondary),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                    ],

                    if (canEdit) ...[
                      _sectionLabel(l10n.dates),
                      const SizedBox(height: 10),
                      if (isUpcoming) ...[
                        _buildDateTile(label: l10n.startDateLabel, date: _currentStartDate, icon: Icons.flight_takeoff, onTap: _pickStartDate),
                        const SizedBox(height: 10),
                      ],
                      _buildDateTile(label: l10n.endDateLabel, date: _currentEndDate, icon: Icons.flight_land, onTap: _pickEndDate),
                      const SizedBox(height: 32),
                    ],

                    if (isOwner || provider.dashboard!.canLeave) ...[
                      Container(height: 1, color: Colors.grey.shade200),
                      const SizedBox(height: 24),
                      _sectionLabel(l10n.dangerZone, color: Colors.red.shade400),
                      const SizedBox(height: 12),

                      if (isOwner) ...[
                        if (isArchived)
                          _dangerButton(
                            label: l10n.unarchiveTrip,
                            icon: Icons.unarchive_outlined,
                            color: AppTheme.primary,
                            onTap: _unarchiveTrip,
                          )
                        else
                          _dangerButton(
                            label: l10n.archiveTrip,
                            icon: Icons.archive_outlined,
                            color: Colors.orange.shade600,
                            onTap: _archiveTrip,
                          ),
                        const SizedBox(height: 10),
                        _dangerButton(
                          label: l10n.deleteTrip,
                          icon: Icons.delete_forever_outlined,
                          color: Colors.red.shade500,
                          filled: true,
                          onTap: _deleteTrip,
                        ),
                      ],
                      if (provider.dashboard!.canLeave) ...[
                        if (isOwner) const SizedBox(height: 10),
                        _dangerButton(
                          label: l10n.leaveTrip,
                          icon: Icons.exit_to_app_outlined,
                          color: Colors.red.shade500,
                          onTap: _leaveTrip,
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, {Color? color}) => Text(
    text,
    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color ?? AppTheme.textSecondary, letterSpacing: 0.5),
  );

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool highlighted = false,
    String? Function(String?)? validator,
  }) {
    final fillColor = highlighted ? AppTheme.primary.withValues(alpha: 0.04) : Colors.white;
    final borderColor = highlighted ? AppTheme.primary.withValues(alpha: 0.25) : Colors.grey.shade200;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textSecondary),
        prefixIcon: Icon(icon, color: highlighted ? AppTheme.primary : AppTheme.textSecondary, size: 20),
        filled: true, fillColor: fillColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: borderColor)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: borderColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.red)),
      ),
    );
  }

  Widget _buildDateTile({required String label, required DateTime date, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3))),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primary, size: 20),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                Text(_formatDate(date), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_down, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _dangerButton({required String label, required IconData icon, required Color color, required VoidCallback onTap, bool filled = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: filled ? color.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context) {
    final searchController = TextEditingController();
    var filtered = supportedCurrencies.toList();
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (_, setSheetState) => DraggableScrollableSheet(
          initialChildSize: 0.7, minChildSize: 0.5, maxChildSize: 0.95, expand: false,
          builder: (_, scrollController) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              children: [
                Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                Text(l10n.currencyPickerTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const SizedBox(height: 14),
                TextField(
                  controller: searchController,
                  onChanged: (q) => setSheetState(() {
                    filtered = supportedCurrencies.where((c) =>
                        c.code.toLowerCase().contains(q.toLowerCase()) || c.name.toLowerCase().contains(q.toLowerCase())).toList();
                  }),
                  decoration: InputDecoration(
                    hintText: l10n.searchHint,
                    prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary, size: 20),
                    filled: true, fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: EdgeInsets.zero,
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final c = filtered[i];
                      final isSelected = c.code == _selectedCurrency;
                      return GestureDetector(
                        onTap: () { setState(() => _selectedCurrency = c.code); Navigator.pop(sheetCtx); },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primary.withValues(alpha: 0.08) : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isSelected ? AppTheme.primary.withValues(alpha: 0.4) : Colors.grey.shade200, width: isSelected ? 1.5 : 1),
                          ),
                          child: Row(
                            children: [
                              Container(width: 40, height: 40,
                                decoration: BoxDecoration(color: isSelected ? AppTheme.primary.withValues(alpha: 0.12) : Colors.grey.shade200, shape: BoxShape.circle),
                                child: Center(child: Text(c.symbol, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? AppTheme.primary : AppTheme.textPrimary))),
                              ),
                              const SizedBox(width: 14),
                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(c.code, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: isSelected ? AppTheme.primary : AppTheme.textPrimary)),
                                Text(c.name, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                              ]),
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
          ),
        ),
      ),
    );
  }

  Future<bool?> _showConfirmDialog({required String title, required String content, required String confirmLabel, bool isDangerous = false}) {
    final l10n = AppLocalizations.of(context)!;
    return showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: (isDangerous ? Colors.red : AppTheme.primary).withValues(alpha: 0.08), shape: BoxShape.circle),
              child: Icon(isDangerous ? Icons.warning_amber_rounded : Icons.info_outline, color: isDangerous ? Colors.red.shade500 : AppTheme.primary, size: 32),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(content, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(sheetCtx, false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(14)),
                      child: Text(l10n.cancel, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(sheetCtx, true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(color: isDangerous ? Colors.red.shade500 : AppTheme.primary, borderRadius: BorderRadius.circular(14)),
                      child: Text(confirmLabel, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _unarchiveTrip() async {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<TripDashboardProvider>();
    final confirm = await _showConfirmDialog(title: l10n.unarchiveTripConfirm, content: l10n.unarchiveTripMessage, confirmLabel: l10n.unarchiveTrip);
    if (confirm == true) {
      final success = await provider.unarchiveTrip(widget.tripId);
      if (mounted) {
        if (success) Navigator.of(context).pop();
        else ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage ?? l10n.failedToUnarchive), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
      }
    }
  }

  void _archiveTrip() async {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<TripDashboardProvider>();
    final navigator = Navigator.of(context);
    final confirm = await _showConfirmDialog(title: l10n.archiveTripConfirm, content: l10n.archiveTripMessage, confirmLabel: l10n.archiveTrip, isDangerous: true);
    if (confirm == true) {
      final success = await provider.archiveTrip(widget.tripId);
      if (mounted) {
        if (success) { navigator.pop(); navigator.pop(); }
        else ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage ?? l10n.failedToArchive), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
      }
    }
  }

  void _leaveTrip() async {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<TripDashboardProvider>();
    final navigator = Navigator.of(context);
    final confirm = await _showConfirmDialog(title: l10n.leaveTripConfirm, content: l10n.leaveTripMessage, confirmLabel: l10n.leaveTrip, isDangerous: true);
    if (confirm == true) {
      final success = await provider.leaveTrip(widget.tripId);
      if (mounted) {
        if (success) { navigator.pop(); navigator.pop(); }
        else ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage ?? l10n.failedToLeave), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
      }
    }
  }

  void _deleteTrip() async {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<TripDashboardProvider>();
    final navigator = Navigator.of(context);
    final confirm = await _showConfirmDialog(title: l10n.deleteTripConfirm, content: l10n.deleteTripMessage, confirmLabel: l10n.deleteTrip, isDangerous: true);
    if (confirm == true) {
      await provider.deleteTrip(widget.tripId);
      if (mounted) { navigator.pop(); navigator.pop(); }
    }
  }

  void _saveSettings() async {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<TripDashboardProvider>();
    final isOwner = provider.dashboard!.isOwner;
    final isUpcoming = provider.dashboard?.trip.status == TripStatus.upcoming;

    if (isOwner) {
      if (!_formKey.currentState!.validate()) return;
      final tripSuccess = await provider.updateTrip(
        tripId: widget.tripId,
        name: _nameController.text.trim(),
        currency: _selectedCurrency,
        startDate: isUpcoming ? _currentStartDate : null,
        endDate: _currentEndDate,
      );
      if (!tripSuccess) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage ?? l10n.failedToSave), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
        return;
      }
    }

    final budgetSuccess = await provider.updateMyBudget(tripId: widget.tripId, budget: _myBudget);
    if (mounted) {
      if (budgetSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.settingsSaved), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage ?? l10n.failedToSave), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
      }
    }
  }

  void _pickStartDate() async {
    final picked = await showStyledDatePicker(context: context, initialDate: _currentStartDate, firstDate: DateTime(2020), lastDate: _currentEndDate.subtract(const Duration(days: 1)));
    if (picked != null) setState(() => _currentStartDate = picked);
  }

  void _pickEndDate() async {
    final isActive = context.read<TripDashboardProvider>().dashboard?.trip.status == TripStatus.active;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final minEndDate = isActive ? tomorrow : (_currentStartDate.add(const Duration(days: 1)).isAfter(tomorrow) ? _currentStartDate.add(const Duration(days: 1)) : tomorrow);
    final picked = await showStyledDatePicker(context: context, initialDate: _currentEndDate.isBefore(minEndDate) ? minEndDate : _currentEndDate, firstDate: minEndDate, lastDate: _currentEndDate.add(const Duration(days: 365)));
    if (picked != null) setState(() => _currentEndDate = picked);
  }
}
