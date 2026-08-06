import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:money_manager/core/utils/join_trip_sheet.dart';
import 'package:money_manager/presentation/pages/claim_invite_page.dart';

class DeepLinkService {
  final GlobalKey<NavigatorState> navigatorKey;
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  DeepLinkService({required this.navigatorKey});

  Future<void> init() async {
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _handle(initialUri));
    }
    _sub = _appLinks.uriLinkStream.listen(_handle);
  }

  void _handle(Uri uri) {
    if (uri.scheme != 'trippace') return;
    final context = navigatorKey.currentContext;
    if (context == null) return;

    switch (uri.host) {
      case 'join':
        final code = uri.queryParameters['code'];
        if (code != null) {
          showJoinTripSheet(context, initialCode: code);
        }
      case 'invite':
        final token = uri.queryParameters['token'];
        if (token != null) {
          navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (_) => ClaimInvitePage(initialToken: token)),
          );
        }
    }
  }

  void dispose() => _sub?.cancel();
}
