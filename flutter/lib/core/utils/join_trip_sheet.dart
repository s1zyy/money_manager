import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_manager/core/theme/app_theme.dart';
import 'package:money_manager/core/utils/overlay_notification.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/presentation/providers/auth_provider.dart';
import 'package:money_manager/presentation/providers/trips_provider.dart';
import 'package:provider/provider.dart';

void showJoinTripSheet(BuildContext context, {String? initialCode}) {
  final isLoggedIn = context.read<AuthProvider>().currentUserEmail != null;
  if (!isLoggedIn) {
    showErrorOverlay(context, 'Please log in to join a trip');
    return;
  }

  final codeController = TextEditingController(text: initialCode ?? '');
  final budgetController = TextEditingController();
  final l10n = AppLocalizations.of(context)!;

  showModalBottomSheet(
    context: context,
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
              autofocus: initialCode == null,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 8,
              style: const TextStyle(fontSize: 16, letterSpacing: 2, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: l10n.inviteCodeHint,
                counterText: '',
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
              autofocus: initialCode != null,
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
                        final provider = context.read<TripsProvider>();
                        final success = await provider.joinTrip(code, budget);
                        if (!sheetContext.mounted) return;
                        if (success) {
                          Navigator.pop(sheetContext);
                          if (!context.mounted) return;
                          showSuccessOverlay(context, l10n.joinedSuccessfully);
                        } else {
                          Navigator.pop(sheetContext);
                          if (!context.mounted) return;
                          showErrorOverlay(context, provider.joinError ?? l10n.errorJoiningTrip);
                        }
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
