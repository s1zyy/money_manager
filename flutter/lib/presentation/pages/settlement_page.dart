import 'package:flutter/material.dart';
import 'package:money_manager/core/constants/currencies.dart';
import 'package:money_manager/core/theme/app_theme.dart';
import 'package:money_manager/domain/entities/settlement_transfer.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/presentation/providers/trip_dashboard_provider.dart';
import 'package:provider/provider.dart';

class SettlementPage extends StatefulWidget {
  final String tripId;
  final String currency;

  const SettlementPage({Key? key, required this.tripId, required this.currency}) : super(key: key);

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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.settlementDone), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage ?? l10n.failedToArchive), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<TripDashboardProvider>();
    final cs = currencySymbol(widget.currency);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Хедер
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
                    const Icon(Icons.handshake_outlined, color: Colors.white70, size: 22),
                    const SizedBox(width: 8),
                    Expanded(child: Text(l10n.settleUp, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.3), overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: provider.isLoading && provider.settlement == null
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : _buildBody(context, provider, l10n, cs),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, TripDashboardProvider provider, AppLocalizations l10n, String cs) {
    final transfers = provider.settlement ?? [];

    if (transfers.isEmpty) return _buildAllEven(context, provider, l10n);

    final allDone = _allPaid(transfers);
    final paidCount = _paid.length;
    final total = transfers.length;

    return Column(
      children: [
        // Прогресс-бар
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.settleUpSubtitle, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text('$paidCount / $total', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text('${((paidCount / total) * 100).round()}%', style: const TextStyle(fontSize: 13, color: AppTheme.primary, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total > 0 ? paidCount / total : 0,
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
          ),
        ),
        const SizedBox(height: 12),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            itemCount: transfers.length,
            itemBuilder: (_, i) {
              final t = transfers[i];
              final isPaid = _paid.contains(i);
              return GestureDetector(
                onTap: () => setState(() {
                  if (isPaid) _paid.remove(i); else _paid.add(i);
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isPaid ? const Color(0xFF22C55E).withValues(alpha: 0.06) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isPaid ? const Color(0xFF22C55E).withValues(alpha: 0.4) : Colors.grey.shade200,
                      width: isPaid ? 1.5 : 1,
                    ),
                    boxShadow: isPaid ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    children: [
                      // Аватар отправителя
                      _avatar(t.fromName, isPaid ? Colors.grey.shade400 : AppTheme.primary, isPaid),
                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    t.fromName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: isPaid ? AppTheme.textSecondary : AppTheme.textPrimary,
                                      decoration: isPaid ? TextDecoration.lineThrough : null,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  child: Icon(Icons.arrow_forward, size: 14, color: isPaid ? Colors.grey.shade400 : AppTheme.textSecondary),
                                ),
                                Flexible(
                                  child: Text(
                                    t.toName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: isPaid ? AppTheme.textSecondary : AppTheme.textPrimary,
                                      decoration: isPaid ? TextDecoration.lineThrough : null,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${t.amount.toStringAsFixed(2)} $cs',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: isPaid ? Colors.grey.shade400 : AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),
                      // Аватар получателя
                      _avatar(t.toName, isPaid ? Colors.grey.shade400 : AppTheme.secondary, isPaid),

                      const SizedBox(width: 12),
                      // Чекбокс
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 26, height: 26,
                        decoration: BoxDecoration(
                          color: isPaid ? const Color(0xFF22C55E) : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(color: isPaid ? const Color(0xFF22C55E) : Colors.grey.shade300, width: 2),
                        ),
                        child: isPaid ? const Icon(Icons.check, color: Colors.white, size: 15) : null,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        if (allDone) _buildAllDoneFooter(context, provider, l10n),
      ],
    );
  }

  Widget _avatar(String name, Color color, bool faded) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return CircleAvatar(
      radius: 20,
      backgroundColor: faded ? Colors.grey.shade100 : color.withValues(alpha: 0.12),
      child: Text(initial, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: faded ? Colors.grey.shade400 : color)),
    );
  }

  Widget _buildAllEven(BuildContext context, TripDashboardProvider provider, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: const Color(0xFF22C55E).withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_outline_rounded, size: 64, color: Color(0xFF22C55E)),
            ),
            const SizedBox(height: 24),
            Text(l10n.allSettled, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            Text(l10n.noSettlementNeeded, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: provider.isLoading ? null : () => _archiveAndFinish(context, provider),
                icon: provider.isLoading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.archive_outlined),
                label: Text(l10n.archiveAndFinish, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                style: FilledButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllDoneFooter(BuildContext context, TripDashboardProvider provider, AppLocalizations l10n) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [const Color(0xFF22C55E).withValues(alpha: 0.1), const Color(0xFF22C55E).withValues(alpha: 0.05)]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E), size: 20),
                const SizedBox(width: 8),
                Text(l10n.allSettled, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textPrimary)),
              ],
            ),
            const SizedBox(height: 4),
            Text(l10n.allSettledMessage, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: provider.isLoading ? null : () => _archiveAndFinish(context, provider),
                icon: provider.isLoading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.archive_outlined, size: 18),
                label: Text(l10n.archiveAndFinish, style: const TextStyle(fontWeight: FontWeight.w600)),
                style: FilledButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
