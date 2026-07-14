import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_manager/core/constants/currencies.dart';
import 'package:money_manager/core/date_time_extensions.dart';
import 'package:money_manager/core/theme/app_theme.dart';
import 'package:money_manager/domain/entities/trip.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/presentation/pages/add_expense_page.dart';
import 'package:money_manager/presentation/pages/settlement_page.dart';
import 'package:money_manager/presentation/pages/trip_settings_page.dart';
import 'package:money_manager/presentation/providers/trip_dashboard_provider.dart';
import 'package:provider/provider.dart';

class TripDetailsPage extends StatefulWidget {
  final String tripId;
  final String tripName;

  const TripDetailsPage({
    Key? key,
    required this.tripId,
    required this.tripName,
  }) : super(key: key);

  @override
  State<TripDetailsPage> createState() => _TripDetailsPageState();
}

class _TripDetailsPageState extends State<TripDetailsPage> {
  final Map<String, bool> _expandedOverrides = {};

  String _dayKey(DateTime day) =>
      '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

  bool _isExpanded(DateTime day) {
    final key = _dayKey(day);
    if (_expandedOverrides.containsKey(key)) return _expandedOverrides[key]!;
    final today = DateTime.now();
    return day.year == today.year && day.month == today.month && day.day == today.day;
  }

  void _toggleDay(DateTime day) {
    setState(() {
      _expandedOverrides[_dayKey(day)] = !_isExpanded(day);
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripDashboardProvider>().loadDashboard(widget.tripId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<TripDashboardProvider>();
    final trip = provider.dashboard?.trip;
    final isArchived = trip?.status == TripStatus.archived;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: () => provider.loadDashboard(widget.tripId),
        child: Column(
          children: [
            _buildHeader(context, provider, l10n),
            Expanded(
              child: provider.dashboard == null && provider.errorMessage == null
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                  : provider.dashboard == null
                      ? _buildError(provider, l10n)
                      : _buildBody(context, provider, l10n),
            ),
          ],
        ),
      ),
      floatingActionButton: isArchived
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _onAddExpense(context, provider, l10n),
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_card),
              label: Text(l10n.addExpense, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
    );
  }

  // ─── HEADER ───────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, TripDashboardProvider provider, AppLocalizations l10n) {
    final trip = provider.dashboard?.trip;
    final name = trip?.name ?? widget.tripName;
    final status = trip?.status;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, AppTheme.secondary],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 8, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.3),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.group_outlined, color: Colors.white),
                    onPressed: () => _showMembersModal(context, provider),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: Colors.white),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider.value(
                          value: provider,
                          child: TripSettingsPage(tripId: widget.tripId),
                        ),
                      ),
                    ).then((_) => provider.loadDashboard(widget.tripId)),
                  ),
                ],
              ),
              if (status != null)
                Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: _StatusChip(status: status, l10n: l10n),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── BODY ─────────────────────────────────────────────────────────────────

  Widget _buildBody(BuildContext context, TripDashboardProvider provider, AppLocalizations l10n) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        const SizedBox(height: 16),
        _buildDailyLimitCard(context, provider, l10n),
        const SizedBox(height: 16),
        _buildBalancesSection(provider, l10n),
        if (_shouldShowSettlement(provider)) ...[
          const SizedBox(height: 12),
          _buildSettlementBanner(context, provider, l10n),
        ],
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(l10n.expenses, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        ),
        const SizedBox(height: 8),
        if (provider.expenses.isEmpty)
          _buildEmptyExpenses(l10n)
        else
          _buildExpenseGroups(context, provider, l10n),
      ],
    );
  }

  // ─── DAILY LIMIT ──────────────────────────────────────────────────────────

  Widget _buildDailyLimitCard(BuildContext context, TripDashboardProvider provider, AppLocalizations l10n) {
    final cs = currencySymbol(provider.dashboard?.trip.currency ?? 'EUR');
    final limit = provider.myDailyLimit;
    final spentToday = provider.todaySpent;
    final remaining = limit - spentToday;
    final progress = (provider.limitProgress).clamp(0.0, 1.0);
    final isOverspent = remaining < 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.dailyLimit, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
              Text('$cs${limit.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(isOverspent ? Colors.red : AppTheme.primary),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.remainingToday, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  Text(
                    '$cs${remaining.abs().toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isOverspent ? Colors.red : AppTheme.primary),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(l10n.spentToday, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  Text('$cs${spentToday.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                ],
              ),
            ],
          ),
          if (isOverspent)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(l10n.overspentToday, style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w500)),
              ),
            ),
        ],
      ),
    );
  }

  // ─── BALANCES ─────────────────────────────────────────────────────────────

  Widget _buildBalancesSection(TripDashboardProvider provider, AppLocalizations l10n) {
    final cs = currencySymbol(provider.dashboard?.trip.currency ?? 'EUR');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(l10n.participantBalances, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 90,
          child: provider.participants.isEmpty
              ? Center(child: Text(l10n.noParticipants, style: const TextStyle(color: AppTheme.textSecondary)))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.participants.length,
                  itemBuilder: (_, i) {
                    final p = provider.participants[i];
                    final name = provider.getParticipantName(p.participantId);
                    final balance = p.balance;
                    final isPositive = balance >= 0;
                    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

                    return Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3))],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
                            child: Text(initial, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                          ),
                          const SizedBox(height: 4),
                          Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppTheme.textPrimary)),
                          Text(
                            '${isPositive ? '+' : ''}$cs${balance.toStringAsFixed(2)}',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isPositive ? const Color(0xFF22C55E) : Colors.red),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ─── SETTLEMENT BANNER ────────────────────────────────────────────────────

  bool _shouldShowSettlement(TripDashboardProvider provider) {
    final trip = provider.dashboard?.trip;
    if (trip == null) return false;
    return trip.status == TripStatus.active && !trip.endDate.dateOnly.isAfter(DateTime.now().dateOnly);
  }

  Widget _buildSettlementBanner(BuildContext context, TripDashboardProvider provider, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          final trip = provider.dashboard!.trip;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: provider,
                child: SettlementPage(tripId: widget.tripId, currency: trip.currency),
              ),
            ),
          ).then((archived) {
            if (archived == true && context.mounted) Navigator.of(context).pop();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.amber.shade600, Colors.orange.shade500]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.handshake_outlined, color: Colors.white, size: 22),
              const SizedBox(width: 12),
              Expanded(child: Text(l10n.tripEndedSettleUp, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15))),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  // ─── EXPENSES ─────────────────────────────────────────────────────────────

  Widget _buildEmptyExpenses(AppLocalizations l10n) {
    return SizedBox(
      height: 220,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: AppTheme.textSecondary.withValues(alpha: 0.35)),
            const SizedBox(height: 16),
            Text(l10n.noExpensesYet, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _buildError(TripDashboardProvider provider, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppTheme.textSecondary, size: 48),
          const SizedBox(height: 12),
          Text(provider.errorMessage ?? l10n.somethingWentWrong, style: const TextStyle(color: AppTheme.textSecondary)),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => provider.loadDashboard(widget.tripId),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseGroups(BuildContext context, TripDashboardProvider provider, AppLocalizations l10n) {
    final cs = currencySymbol(provider.dashboard?.trip.currency ?? 'EUR');
    final grouped = provider.expensesByDay;
    final days = grouped.keys.toList();

    return Column(
      children: days.map((day) {
        final dayExpenses = grouped[day]!;
        final dayTotal = dayExpenses.fold(0.0, (sum, e) => sum + provider.myShareOf(e));
        final dateStr = '${day.day.toString().padLeft(2, '0')}.${day.month.toString().padLeft(2, '0')}.${day.year}';
        final expanded = _isExpanded(day);

        return Column(
          children: [
            InkWell(
              onTap: () => _toggleDay(day),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    AnimatedRotation(
                      turns: expanded ? 0.25 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(Icons.chevron_right, size: 20, color: AppTheme.primary),
                    ),
                    const SizedBox(width: 6),
                    Text(dateStr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('$cs${dayTotal.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primary)),
                    ),
                  ],
                ),
              ),
            ),
            ClipRect(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                child: expanded
                    ? Column(
                        children: dayExpenses.map((expense) {
                          final payerName = expense.payerId != null
                              ? provider.getParticipantName(expense.payerId!)
                              : l10n.eachPaidOwn;
                          return Dismissible(
                            key: Key(expense.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(16)),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(Icons.delete_outline, color: Colors.white),
                            ),
                            onDismissed: (_) {
                              provider.deleteExpense(widget.tripId, expense.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.expenseDeleted), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 42, height: 42,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.receipt_outlined, color: AppTheme.primary, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(expense.description, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.textPrimary)),
                                        const SizedBox(height: 2),
                                        Text(l10n.paidBy(payerName), style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('$cs${expense.amount.toStringAsFixed(2)}',
                                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                                      Text('${l10n.myShare}: $cs${provider.myShareOf(expense).toStringAsFixed(2)}',
                                          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  // ─── ADD EXPENSE ──────────────────────────────────────────────────────────

  void _onAddExpense(BuildContext context, TripDashboardProvider provider, AppLocalizations l10n) {
    final startDate = provider.dashboard?.trip.startDate;
    if (startDate != null && startDate.dateOnly.isAfter(DateTime.now().dateOnly)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.tripNotStarted), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: AddExpensePage(tripId: widget.tripId),
        ),
      ),
    );
  }

  // ─── MEMBERS MODAL ────────────────────────────────────────────────────────

  void _showMembersModal(BuildContext context, TripDashboardProvider provider) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetCtx) {
        return ChangeNotifierProvider.value(
          value: provider,
          child: DraggableScrollableSheet(
          initialChildSize: 0.92,
          minChildSize: 0.5,
          maxChildSize: 0.92,
          expand: false,
          builder: (_, scrollController) {
            return Consumer<TripDashboardProvider>(
              builder: (ctx, p, _) {
                final joinCode = p.dashboard?.trip.joinCode ?? '------';
                final isOwner = p.dashboard?.isOwner ?? false;
                final ownerId = p.dashboard?.trip.ownerId ?? '';
                final myId = p.myParticipantId ?? '';
                final memberCount = p.participantsMap.length;
                return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                children: [
                  Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l10n.members, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                        child: Text('$memberCount', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        ...provider.participantsMap.entries.map((entry) {
                          final id = entry.key;
                          final name = entry.value.name;
                          final isEntryOwner = id == ownerId;
                          final isMe = id == myId;
                          final isVirtual = provider.isVirtualParticipant(id);
                          final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

                          final card = Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: EdgeInsets.symmetric(horizontal: 14, vertical: isOwner && isVirtual ? 10 : 12),
                            decoration: BoxDecoration(
                              color: isMe ? AppTheme.primary.withValues(alpha: 0.05) : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isMe ? AppTheme.primary.withValues(alpha: 0.25) : Colors.grey.shade200,
                                width: isMe ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: isVirtual
                                          ? Colors.grey.shade200
                                          : AppTheme.primary.withValues(alpha: 0.15),
                                      child: isVirtual
                                          ? const Icon(Icons.person_outline, color: AppTheme.textSecondary, size: 20)
                                          : Text(initial, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 15)),
                                    ),
                                    if (isEntryOwner)
                                      Positioned(
                                        right: -4, top: -4,
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                                          child: const Icon(Icons.star, size: 10, color: Colors.white),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.textPrimary)),
                                      if (isEntryOwner || isVirtual || isMe)
                                        Text(
                                          isEntryOwner ? l10n.owner : isMe ? l10n.you : l10n.virtual,
                                          style: TextStyle(fontSize: 11, color: isMe ? AppTheme.primary : AppTheme.textSecondary),
                                        ),
                                    ],
                                  ),
                                ),
                                if (isOwner && !isEntryOwner)
                                  GestureDetector(
                                    onTap: () => _confirmRemoveParticipant(context, provider, widget.tripId, id, name, sheetCtx),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.08), shape: BoxShape.circle),
                                      child: const Icon(Icons.close, color: Colors.red, size: 15),
                                    ),
                                  ),
                              ],
                            ),
                          );
                          if (isOwner && isVirtual) {
                            return GestureDetector(
                              onTap: () => _showVirtualParticipantSheet(context, provider, widget.tripId, id, name),
                              child: card,
                            );
                          }
                          return card;
                        }),
                        if (isOwner)
                          GestureDetector(
                            onTap: () => _showAddVirtualParticipantDialog(context, provider, widget.tripId, sheetCtx),
                            child: Container(
                              margin: const EdgeInsets.only(top: 4, bottom: 20),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.person_add_alt_1, color: AppTheme.primary, size: 18),
                                  const SizedBox(width: 8),
                                  Text(l10n.addWithoutAccount, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.secondary]),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Text(l10n.inviteCode, style: const TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 12),
                              Text(joinCode, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 6, color: Colors.white)),
                              const SizedBox(height: 14),
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: joinCode));
                                  Navigator.pop(sheetCtx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(l10n.joinCodeCopied), behavior: SnackBarBehavior.floating),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.copy, color: Colors.white, size: 16),
                                      const SizedBox(width: 8),
                                      Text(l10n.copyCode, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      ),
    );
  },
  );
  }

  void _showVirtualParticipantSheet(BuildContext context, TripDashboardProvider provider, String tripId, String participantId, String name) {
    final currentBudget = provider.dashboard?.trip.participantBudgets[participantId] ?? 0.0;
    final cs = currencySymbol(provider.dashboard?.trip.currency ?? 'EUR');
    final budgetController = TextEditingController(text: currentBudget > 0 ? currentBudget.toStringAsFixed(0) : '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetCtx) {
        final l10n = AppLocalizations.of(context)!;
        return Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(sheetCtx).viewInsets.bottom + 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            Row(children: [
              CircleAvatar(radius: 20, backgroundColor: Colors.grey.shade200,
                  child: const Icon(Icons.person_outline, color: AppTheme.textSecondary, size: 20)),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                Text(l10n.virtualParticipant, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ]),
            ]),
            const SizedBox(height: 20),
            Text(l10n.budgetWithCurrency(cs), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            TextField(
              controller: budgetController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: '0',
                prefixIcon: Padding(padding: const EdgeInsets.all(12), child: Text(cs, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary))),
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: () async {
                  final budget = double.tryParse(budgetController.text) ?? 0.0;
                  Navigator.pop(sheetCtx);
                  await provider.updateParticipantBudget(tripId: tripId, participantId: participantId, budget: budget);
                },
                child: Text(l10n.saveBudget, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(sheetCtx);
                  _showInviteByEmailDialog(context, provider, tripId, participantId, name);
                },
                icon: const Icon(Icons.email_outlined, size: 18),
                label: Text(AppLocalizations.of(context)!.inviteByEmail, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: const BorderSide(color: AppTheme.primary),
                ),
              ),
            ),
          ],
        ),
        );
      },
      );
      
    
  }

  void _showInviteByEmailDialog(BuildContext context, TripDashboardProvider provider, String tripId, String participantId, String name) {
    final emailController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetCtx) {
        bool sending = false;
        String? sheetError;
        return StatefulBuilder(
          builder: (ctx, setSheetState) => Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(sheetCtx).viewInsets.bottom + 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.08), shape: BoxShape.circle),
                  child: const Icon(Icons.email_outlined, color: AppTheme.primary, size: 32),
                ),
                const SizedBox(height: 16),
                Text(l10n.inviteParticipantTitle(name), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const SizedBox(height: 6),
                Text(l10n.inviteParticipantDescription, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                const SizedBox(height: 24),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
                  onChanged: (_) { if (sheetError != null) setSheetState(() => sheetError = null); },
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: l10n.email,
                    labelStyle: const TextStyle(color: AppTheme.textSecondary),
                    prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.textSecondary, size: 20),
                    errorText: sheetError,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
                    focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14)), borderSide: BorderSide(color: AppTheme.primary, width: 1.5)),
                    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.red)),
                    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: sending ? null : () => Navigator.pop(sheetCtx),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(14)),
                          child: Text(l10n.cancel, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: FilledButton(
                        onPressed: sending ? null : () async {
                          final email = emailController.text.trim();
                          if (email.isEmpty || !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$').hasMatch(email)) {
                            setSheetState(() => sheetError = l10n.enterValidEmail);
                            return;
                          }
                          setSheetState(() { sending = true; sheetError = null; });
                          final success = await provider.inviteVirtualParticipant(tripId, participantId, email);
                          if (!ctx.mounted) return;
                          if (success) {
                            Navigator.pop(sheetCtx);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(l10n.inviteSent),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ));
                          } else {
                            setSheetState(() { sending = false; sheetError = provider.errorMessage ?? l10n.failedToAdd; });
                          }
                        },
                        style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                        child: sending
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(l10n.send, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) => provider.clearError());
  }

  void _showAddVirtualParticipantDialog(BuildContext context, TripDashboardProvider provider, String tripId, BuildContext modalContext) {
    final controller = TextEditingController();
    final budgetController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    final formKey = GlobalKey<FormState>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetCtx) {
        String? serverNameError;
        bool isLoading = false;
        return StatefulBuilder(
          builder: (ctx, setSheetState) => Form(
          key: formKey,
          child: Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(sheetCtx).viewInsets.bottom + 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.08), shape: BoxShape.circle),
                child: const Icon(Icons.person_add_alt_1, color: AppTheme.primary, size: 32),
              ),
              const SizedBox(height: 16),
              Text(l10n.addVirtualParticipant, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const SizedBox(height: 6),
              Text(l10n.virtualParticipantHint, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              const SizedBox(height: 24),
              TextFormField(
                controller: controller,
                autofocus: true,
                onChanged: (_) { if (serverNameError != null) setSheetState(() => serverNameError = null); },
                style: const TextStyle(color: AppTheme.textPrimary),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return l10n.enterName;
                  final taken = provider.participantsMap.values.any(
                    (p) => p.name.trim().toLowerCase() == v.trim().toLowerCase(),
                  );
                  if (taken) return l10n.nameAlreadyTaken;
                  return null;
                },
                decoration: InputDecoration(
                  labelText: l10n.name,
                  labelStyle: const TextStyle(color: AppTheme.textSecondary),
                  prefixIcon: const Icon(Icons.person_outline, color: AppTheme.textSecondary, size: 20),
                  errorText: serverNameError,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
                  errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.red)),
                  focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: budgetController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: AppTheme.textPrimary),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return l10n.enterBudget;
                  final val = double.tryParse(v.trim());
                  if (val == null || val <= 0) return l10n.budgetMustBePositive;
                  return null;
                },
                decoration: InputDecoration(
                  labelText: l10n.budget,
                  labelStyle: const TextStyle(color: AppTheme.textSecondary),
                  prefixIcon: const Icon(Icons.account_balance_wallet_outlined, color: AppTheme.textSecondary, size: 20),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
                  errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.red)),
                  focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(sheetCtx),
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
                      onTap: isLoading ? null : () async {
                        if (!formKey.currentState!.validate()) return;
                        final name = controller.text.trim();
                        final budget = double.parse(budgetController.text.trim());
                        setSheetState(() { isLoading = true; serverNameError = null; });
                        final success = await provider.addVirtualParticipant(tripId, name, budget);
                        if (!ctx.mounted) return;
                        if (success) {
                          Navigator.pop(sheetCtx);
                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(l10n.memberAdded(name)),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ));
                        } else {
                          setSheetState(() { isLoading = false; serverNameError = provider.errorMessage ?? l10n.failedToAdd; });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(14)),
                        child: Text(l10n.add, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  },
  );
  }

  void _confirmRemoveParticipant(BuildContext context, TripDashboardProvider provider, String tripId, String participantId, String name, BuildContext modalContext) {
    final l10n = AppLocalizations.of(context)!;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetCtx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.08), shape: BoxShape.circle),
                child: const Icon(Icons.person_remove_outlined, color: Colors.red, size: 32),
              ),
              const SizedBox(height: 16),
              Text(l10n.removeMember, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
                    child: Text(initial, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                  ),
                  const SizedBox(width: 8),
                  Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppTheme.textPrimary)),
                ],
              ),
              const SizedBox(height: 6),
              Text(l10n.removeMemberConfirm(name), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13), textAlign: TextAlign.center),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(sheetCtx),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(l10n.cancel, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        Navigator.pop(sheetCtx);
                        final success = await provider.removeParticipant(tripId, participantId);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(success ? l10n.memberRemoved(name) : provider.errorMessage ?? l10n.failedToRemove),
                          backgroundColor: success ? Colors.green : Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(l10n.remove, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── STATUS CHIP ──────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final TripStatus status;
  final AppLocalizations l10n;

  const _StatusChip({required this.status, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (status) {
      TripStatus.active   => (l10n.active,   const Color(0xFF22C55E), Icons.flight_takeoff),
      TripStatus.upcoming => (l10n.upcoming,  const Color(0xFFF59E0B), Icons.calendar_month),
      TripStatus.archived => (l10n.archived,  Colors.grey,             Icons.archive),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}
