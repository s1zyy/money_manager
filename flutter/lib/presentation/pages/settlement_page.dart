import 'package:flutter/material.dart';
import 'package:money_manager/core/constants/currencies.dart';
import 'package:money_manager/domain/entities/settlement_transfer.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/presentation/providers/trip_dashboard_provider.dart';
import 'package:provider/provider.dart';

class SettlementPage extends StatefulWidget {
  final String tripId;
  final String currency;

  const SettlementPage({
    Key? key,
    required this.tripId,
    required this.currency,
  }) : super(key: key);

  @override
  State<SettlementPage> createState() => _SettlementPageState();
}

class _SettlementPageState extends State<SettlementPage> {
  final Set<int> _paid = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripDashboardProvider>().loadSettlement(widget.tripId);
    });
  }

  bool _allPaid(List<SettlementTransfer> transfers) =>
      transfers.isNotEmpty && _paid.length == transfers.length;

  Future<void> _archiveAndFinish(BuildContext context, TripDashboardProvider provider) async {
    final l10n = AppLocalizations.of(context)!;
    final success = await provider.archiveTrip(widget.tripId);
    if (!context.mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.settlementDone),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? l10n.failedToArchive),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final provider = context.watch<TripDashboardProvider>();
    final cs = currencySymbol(widget.currency);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settleUp)),
      body: provider.isLoading && provider.settlement == null
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(context, provider, l10n, colorScheme, cs),
    );
  }

  Widget _buildBody(
    BuildContext context,
    TripDashboardProvider provider,
    AppLocalizations l10n,
    ColorScheme colorScheme,
    String cs,
  ) {
    final transfers = provider.settlement ?? [];

    if (transfers.isEmpty) {
      return _buildAllEven(context, provider, l10n, colorScheme);
    }

    final allDone = _allPaid(transfers);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            l10n.settleUpSubtitle,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: transfers.length,
            itemBuilder: (context, i) {
              final t = transfers[i];
              final isPaid = _paid.contains(i);
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: isPaid ? Colors.green : colorScheme.outlineVariant,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 10),
                child: CheckboxListTile(
                  value: isPaid,
                  onChanged: (_) {
                    setState(() {
                      if (isPaid) {
                        _paid.remove(i);
                      } else {
                        _paid.add(i);
                      }
                    });
                  },
                  title: Text(
                    l10n.paysTo(t.fromName, t.toName),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      decoration: isPaid ? TextDecoration.lineThrough : null,
                      color: isPaid ? colorScheme.onSurfaceVariant : null,
                    ),
                  ),
                  subtitle: Text(
                    '${t.amount.toStringAsFixed(2)} $cs',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isPaid ? colorScheme.onSurfaceVariant : colorScheme.primary,
                    ),
                  ),
                  secondary: Icon(
                    isPaid ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isPaid ? Colors.green : colorScheme.outlineVariant,
                  ),
                  controlAffinity: ListTileControlAffinity.trailing,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
          ),
        ),
        if (allDone)
          _buildAllDoneFooter(context, provider, l10n, colorScheme)
        else
          const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAllEven(
    BuildContext context,
    TripDashboardProvider provider,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, size: 72, color: Colors.green[400]),
            const SizedBox(height: 16),
            Text(
              l10n.allSettled,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noSettlementNeeded,
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: provider.isLoading
                  ? null
                  : () => _archiveAndFinish(context, provider),
              icon: provider.isLoading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.archive_outlined),
              label: Text(l10n.archiveAndFinish),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllDoneFooter(
    BuildContext context,
    TripDashboardProvider provider,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[400], size: 20),
                const SizedBox(width: 8),
                Text(
                  l10n.allSettled,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              l10n.allSettledMessage,
              style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: provider.isLoading
                  ? null
                  : () => _archiveAndFinish(context, provider),
              icon: provider.isLoading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.archive_outlined),
              label: Text(l10n.archiveAndFinish),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
