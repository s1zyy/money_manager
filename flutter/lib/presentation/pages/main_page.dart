
import 'package:flutter/material.dart';
import 'package:money_manager/core/constants/currencies.dart';
import 'package:money_manager/domain/entities/trip.dart';
import 'package:money_manager/injection_container.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/presentation/pages/create_trip_page.dart';
import 'package:money_manager/presentation/pages/login_page.dart';
import 'package:money_manager/presentation/pages/trip_details_page.dart';
import 'package:money_manager/presentation/providers/locale_provider.dart';
import 'package:money_manager/presentation/providers/trip_dashboard_provider.dart';
import 'package:money_manager/presentation/providers/auth_provider.dart';
import 'package:money_manager/presentation/providers/trips_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TripsPage extends StatefulWidget {
  const TripsPage({super.key});
  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
      context.read<TripsProvider>().loadTrips());
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 3,

      child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.logout, color: Colors.red),
          onPressed: () => _showLogoutDialog(context),
        ),
        title: Text(l10n.trips),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => _showLanguageDialog(context),
          ),
        ],

        bottom: TabBar(
          tabs: [
            Tab(icon: const Icon(Icons.flight_takeoff), text: l10n.active),
            Tab(icon: const Icon(Icons.calendar_month), text: l10n.upcoming),
            Tab(icon: const Icon(Icons.archive), text: l10n.archived),
          ],
          indicatorColor: Colors.blue,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
        )

      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrJoinTripModal(context),
        child: const Icon(Icons.add),
      ),
      body: Consumer<TripsProvider>(
        builder: (context, provider, child) {
          if(provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if(provider.errorMessage != null) {
            return Center(child: Text(provider.errorMessage!));
          }

          if(provider.trips.isEmpty) {
            return Center(child: Text(l10n.noTripsYet));
          }

          final activeTrips = provider.trips.where((t) => t.status == TripStatus.active).toList();
          final upcomingTrips = provider.trips.where((t) => t.status == TripStatus.upcoming).toList();
          final archivedTrips = provider.trips.where((t) => t.status == TripStatus.archived).toList();

          return TabBarView(
            children: [
              _buildTripsList(activeTrips, l10n.noActiveTrips),
              _buildTripsList(upcomingTrips, l10n.noUpcomingTrips),
              _buildTripsList(archivedTrips, l10n.noArchivedTrips),
            ],
          );
        },
      ),
    ),
    );
  }

  Widget _buildTripsList(List<Trip> trips, String emptyMessage) {
    final l10n = AppLocalizations.of(context)!;
    return RefreshIndicator(
      onRefresh: () => context.read<TripsProvider>().loadTrips(),
      child: trips.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Center(
                    child: Text(
                      emptyMessage,
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                ),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: trips.length,
              itemBuilder: (context, index) {
                final trip = trips[index];
                return ListTile(
                  title: Text(trip.name),
                  subtitle: Text(l10n.budgetAmount("${currencySymbol(trip.currency)}${trip.totalBudget}")),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangeNotifierProvider(
                          create: (_) => sl<TripDashboardProvider>(),
                          child: TripDetailsPage(
                            tripId: trip.id,
                            tripName: trip.name,
                          ),
                        ),
                      ),
                    );
                    if (mounted) {
                      context.read<TripsProvider>().loadTrips();
                    }
                  },
                );
              },
            ),
    );
  }

  void _showAddOrJoinTripModal(BuildContext pageContext) {
    final colorScheme = Theme.of(pageContext).colorScheme;
    final l10n = AppLocalizations.of(pageContext)!;

    showModalBottomSheet(
      context: pageContext,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                l10n.addTrip,
                style: Theme.of(modalContext).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              ListTile(
                leading: CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(Icons.add, color: colorScheme.onPrimaryContainer),
                ),
                title: Text(l10n.createNewTrip, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(l10n.youWillBeOwner),
                onTap: () {
                  Navigator.pop(modalContext);
                  Navigator.push(
                    pageContext,
                    MaterialPageRoute(builder: (context) => const CreateTripPage()),
                  );
                },
              ),
              const Divider(height: 20),

              ListTile(
                leading: CircleAvatar(
                  backgroundColor: colorScheme.secondaryContainer,
                  child: Icon(Icons.group_add, color: colorScheme.onSecondaryContainer),
                ),
                title: Text(l10n.joinTripByCode, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(l10n.enterInviteCode),
                onTap: () {
                  Navigator.pop(modalContext);
                  _showJoinTripDialog(pageContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.logout),
          content: Text(l10n.logoutConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await context.read<AuthProvider>().logout();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
              child: Text(l10n.logout),
            ),
          ],
        );
      },
    );
  }

  void _showJoinTripDialog(BuildContext pageContext) {
    final TextEditingController codeController = TextEditingController();
    final l10n = AppLocalizations.of(pageContext)!;

    showDialog(
      context: pageContext,
      
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.joinTrip),
          content: TextField(
            controller: codeController,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: l10n.inviteCodeHint,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () async {
                final code = codeController.text.trim();
                if (code.isNotEmpty) {
                  Navigator.pop(dialogContext);

                  final provider = pageContext.read<TripsProvider>();
                  final success = await provider.joinTrip(code);

                  if (!pageContext.mounted) return;

                  if (success) {
                    ScaffoldMessenger.of(pageContext).showSnackBar(
                      SnackBar(
                        content: Text(l10n.joinedSuccessfully),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(pageContext).showSnackBar(
                      SnackBar(
                        content: Text(provider.errorMessage ?? l10n.errorJoiningTrip),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              child: Text(l10n.join),
            ),
          ],
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.read<LocaleProvider>();
    final current = localeProvider.locale.languageCode;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;
        return AlertDialog(
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.language,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
            ],
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final entry in [
                  ('en', 'English'),
                  ('ru', 'Русский'),
                  ('es', 'Español'),
                  ('de', 'Deutsch'),
                  ('fr', 'Français'),
                  ('pt', 'Português'),
                  ('zh', '中文'),
                ]) ...[
                  ListTile(
                    dense: true,
                    title: Text(
                      entry.$2,
                      style: TextStyle(
                        fontWeight: current == entry.$1 ? FontWeight.bold : FontWeight.normal,
                        color: current == entry.$1 ? colorScheme.primary : null,
                      ),
                    ),
                    trailing: current == entry.$1
                        ? Icon(Icons.check_circle, color: colorScheme.primary)
                        : const Icon(Icons.circle_outlined, color: Colors.grey),
                    onTap: () async {
                      Navigator.pop(ctx);
                      await localeProvider.setLocale(Locale(entry.$1), sl<SharedPreferences>());
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                ],
              ],
            ),
          ),
          actionsPadding: EdgeInsets.zero,
        );
      },
    );
  }
}
