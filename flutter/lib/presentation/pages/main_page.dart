
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_manager/core/theme/app_theme.dart';
import 'package:money_manager/domain/entities/trip.dart';
import 'package:money_manager/injection_container.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/presentation/pages/create_trip_page.dart';
import 'package:money_manager/presentation/pages/profile_page.dart';
import 'package:money_manager/presentation/pages/trip_details_page.dart';
import 'package:money_manager/presentation/providers/locale_provider.dart';
import 'package:money_manager/presentation/providers/trip_dashboard_provider.dart';
import 'package:money_manager/presentation/providers/trips_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TripsPage extends StatefulWidget {
  const TripsPage({super.key});
  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() {
      if (!mounted) return;
      context.read<TripsProvider>().loadTrips();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pageContext = context;
    return Scaffold(
      body: Stack(
        children: [
          _animatedTab(0, _buildTripsTab(pageContext, l10n)),
          _animatedTab(1, _buildFriendsTab(l10n)),
          _animatedTab(2, const ProfilePage()),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        backgroundColor: Colors.white,
        indicatorColor: AppTheme.primary.withValues(alpha: 0.12),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.flight_takeoff_outlined),
            selectedIcon: const Icon(Icons.flight_takeoff, color: AppTheme.primary),
            label: l10n.trips,
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline),
            selectedIcon: const Icon(Icons.people, color: AppTheme.primary),
            label: l10n.friends,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person, color: AppTheme.primary),
            label: l10n.profile,
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => _showAddOrJoinTripModal(pageContext),
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: Text(l10n.createNewTrip, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: 0.3)),
            )
          : null,
    );
  }

  String _badgeLabel(int count, {int cap = 99}) =>
      count > cap ? '$cap+' : '$count';

  Widget _tabWithBadge(IconData icon, String label, int count, Color badgeColor, {int cap = 99}) {
    return Tab(
      text: label,
      icon: count > 0
          ? Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(icon, size: 18),
                ),
                Positioned(
                  right: -12,
                  top: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text(
                      _badgeLabel(count, cap: cap),
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700, height: 1),
                    ),
                  ),
                ),
              ],
            )
          : Icon(icon, size: 18),
    );
  }

  Widget _buildTripsTab(BuildContext pageContext, AppLocalizations l10n) {
    return Consumer<TripsProvider>(
      builder: (context, provider, _) {
        final activeCount = provider.activeTrips.length;
        final upcomingCount = provider.upcomingTrips.length;
        final archivedCount = provider.archivedTrips.length;
        return _buildTripsTabContent(pageContext, l10n, activeCount, upcomingCount, archivedCount);
      },
    );
  }

  Widget _buildTripsTabContent(BuildContext pageContext, AppLocalizations l10n,
      int activeCount, int upcomingCount, int archivedCount) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBar(
          pinned: true,
          toolbarHeight: 72,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [AppTheme.primary, AppTheme.secondary],
              ),
            ),
          ),
          title: Row(
            children: [
              const Icon(Icons.airplanemode_active, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.trips,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.language, color: Colors.white, size: 22),
              onPressed: () => _showLanguageDialog(pageContext),
            ),
            const SizedBox(width: 4),
          ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(52),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x18000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppTheme.primary,
                  unselectedLabelColor: AppTheme.textSecondary,
                  indicatorColor: AppTheme.primary,
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                  tabs: [
                    _tabWithBadge(Icons.flight_takeoff, l10n.active, activeCount, const Color(0xFF22C55E), cap: 10),
                    _tabWithBadge(Icons.calendar_month, l10n.upcoming, upcomingCount, const Color(0xFFF59E0B)),
                    _tabWithBadge(Icons.archive, l10n.archived, archivedCount, AppTheme.textSecondary),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: Consumer<TripsProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              );
            }

            if (provider.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: AppTheme.textSecondary, size: 48),
                    const SizedBox(height: 12),
                    Text(provider.errorMessage!, style: const TextStyle(color: AppTheme.textSecondary)),
                  ],
                ),
              );
            }

            return TabBarView(
              controller: _tabController,
              children: [
                _buildTripsList(provider.activeTrips, l10n.noActiveTrips, TripStatus.active),
                _buildTripsList(provider.upcomingTrips, l10n.noUpcomingTrips, TripStatus.upcoming),
                _buildTripsList(provider.archivedTrips, l10n.noArchivedTrips, TripStatus.archived),
              ],
            );
          },
        ),
      );
  }

  Widget _animatedTab(int index, Widget child) {
    final visible = _selectedIndex == index;
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: IgnorePointer(ignoring: !visible, child: child),
    );
  }

  Widget _buildFriendsTab(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline, size: 64, color: AppTheme.textSecondary.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(l10n.friends, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Text(l10n.comingSoon, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildTripsList(List<Trip> trips, String emptyMessage, TripStatus status) {
    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: () => context.read<TripsProvider>().loadTrips(),
      child: trips.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _statusIcon(status),
                          size: 56,
                          color: AppTheme.textSecondary.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          emptyMessage,
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: trips.length,
              itemBuilder: (context, index) => _TripCard(
                trip: trips[index],
                onTap: () => _openTrip(trips[index]),
              ),
            ),
    );
  }

  IconData _statusIcon(TripStatus status) {
    switch (status) {
      case TripStatus.active:
        return Icons.flight_takeoff;
      case TripStatus.upcoming:
        return Icons.calendar_month;
      case TripStatus.archived:
        return Icons.archive;
    }
  }

  Future<void> _openTrip(Trip trip) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => sl<TripDashboardProvider>(),
          child: TripDetailsPage(tripId: trip.id, tripName: trip.name),
        ),
      ),
    );
    if (mounted) context.read<TripsProvider>().loadTrips();
  }

  void _showAddOrJoinTripModal(BuildContext pageContext) {
    final l10n = AppLocalizations.of(pageContext)!;
    showModalBottomSheet(
      context: pageContext,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                l10n.addTrip,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 20),
              _ModalOption(
                icon: Icons.add_circle_outline,
                color: AppTheme.primary,
                title: l10n.createNewTrip,
                subtitle: l10n.youWillBeOwner,
                onTap: () {
                  Navigator.pop(modalContext);
                  Navigator.push(pageContext, MaterialPageRoute(builder: (_) => const CreateTripPage()))
                      .then((_) => pageContext.read<TripsProvider>().clearError());
                },
              ),
              const SizedBox(height: 12),
              _ModalOption(
                icon: Icons.group_add_outlined,
                color: AppTheme.secondary,
                title: l10n.joinTripByCode,
                subtitle: l10n.enterInviteCode,
                onTap: () {
                  Navigator.pop(modalContext);
                  _showJoinTripDialog(pageContext);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }


  void _showJoinTripDialog(BuildContext pageContext) {
    final codeController = TextEditingController();
    final budgetController = TextEditingController();
    final l10n = AppLocalizations.of(pageContext)!;
    showModalBottomSheet(
      context: pageContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.secondary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.group_add_outlined, color: AppTheme.secondary, size: 28),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.joinTrip,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: codeController,
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(fontSize: 16, letterSpacing: 2, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: l10n.inviteCodeHint,
                  prefixIcon: const Icon(Icons.vpn_key_outlined, color: AppTheme.secondary),
                  filled: true,
                  fillColor: AppTheme.secondary.withValues(alpha: 0.06),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppTheme.secondary.withValues(alpha: 0.2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppTheme.secondary.withValues(alpha: 0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppTheme.secondary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: budgetController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                decoration: InputDecoration(
                  hintText: l10n.myBudget,
                  prefixIcon: const Icon(Icons.account_balance_wallet_outlined, color: AppTheme.primary),
                  filled: true,
                  fillColor: AppTheme.primary.withValues(alpha: 0.06),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppTheme.primary.withValues(alpha: 0.2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppTheme.primary.withValues(alpha: 0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(l10n.cancel, style: const TextStyle(color: AppTheme.textSecondary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: () async {
                        final code = codeController.text.trim();
                        final budget = double.tryParse(budgetController.text) ?? 0.0;
                        if (code.isNotEmpty) {
                          Navigator.pop(sheetContext);
                          final provider = pageContext.read<TripsProvider>();
                          final success = await provider.joinTrip(code, budget);
                          if (!pageContext.mounted) return;
                          ScaffoldMessenger.of(pageContext).showSnackBar(
                            SnackBar(
                              content: Text(success ? l10n.joinedSuccessfully : (provider.joinError ?? l10n.errorJoiningTrip)),
                              backgroundColor: success ? Colors.green : Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.secondary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(l10n.join, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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

  void _showLanguageDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.read<LocaleProvider>();
    final current = localeProvider.locale.languageCode;

    const languages = [
      ('en', 'English', '🇬🇧'),
      ('es', 'Español', '🇪🇸'),
      ('de', 'Deutsch', '🇩🇪'),
      ('fr', 'Français', '🇫🇷'),
      ('pt', 'Português', '🇵🇹'),
      ('zh', '中文', '🇨🇳'),
      ('ru', 'Русский', '🇷🇺'),
      ('uk', 'Українська', '🇺🇦'),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                  ),
                  Text(
                    l10n.language,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        children: languages.map((entry) {
                          final isSelected = current == entry.$1;
                          return GestureDetector(
                            onTap: () async {
                              Navigator.pop(sheetContext);
                              await localeProvider.setLocale(Locale(entry.$1), sl<SharedPreferences>());
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
                                  Text(entry.$3, style: const TextStyle(fontSize: 22)),
                                  const SizedBox(width: 14),
                                  Text(
                                    entry.$2,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (isSelected)
                                    Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 20),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _TripCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback onTap;

  const _TripCard({required this.trip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(trip.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 5,
              height: 72,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(TripStatus status) {
    switch (status) {
      case TripStatus.active:
        return const Color(0xFF22C55E);
      case TripStatus.upcoming:
        return const Color(0xFFF59E0B);
      case TripStatus.archived:
        return AppTheme.textSecondary;
    }
  }
}

class _ModalOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ModalOption({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppTheme.textPrimary)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
