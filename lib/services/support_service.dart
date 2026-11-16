import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Handles Rate App, Share App, and $0.99 Buy Developer a Coffee IAP.
class SupportService {
  SupportService._();

  static const String coffeeProductId = 'cofee';
  static const String packageId = 'com.nextlevel.duaulanbiya';
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=$packageId';

  static StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  static bool _initialized = false;
  static bool _updateCheckedThisLaunch = false;

  static void init() {
    if (_initialized || kIsWeb) return;
    _initialized = true;
    _purchaseSub = InAppPurchase.instance.purchaseStream.listen(
      _onPurchaseUpdated,
      onError: (Object error) {
        debugPrint('Coffee IAP stream error: $error');
      },
    );
  }

  static void dispose() {
    _purchaseSub?.cancel();
    _purchaseSub = null;
    _initialized = false;
  }

  static Future<void> _onPurchaseUpdated(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        debugPrint('Coffee purchase completed: ${purchase.productID}');
      } else if (purchase.status == PurchaseStatus.error) {
        debugPrint('Coffee purchase error: ${purchase.error?.message}');
      }
      if (purchase.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchase);
      }
    }
  }

  static Future<void> rateApp() async {
    if (!kIsWeb) {
      final inAppReview = InAppReview.instance;
      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
        return;
      }
    }
    final marketUri = Uri.parse('market://details?id=$packageId');
    final webUri = Uri.parse(playStoreUrl);
    if (await canLaunchUrl(marketUri)) {
      await launchUrl(marketUri, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> shareApp() async {
    await Share.share(
      'Check out Dua ul Anbiya — daily prophetic Duas & reminders!\n$playStoreUrl',
    );
  }

  static Future<void> buyCoffee(BuildContext context) async {
    if (kIsWeb) return;
    init();
    final available = await InAppPurchase.instance.isAvailable();
    if (!available) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google Play Billing is unavailable on this device.'),
          ),
        );
      }
      return;
    }

    final response =
        await InAppPurchase.instance.queryProductDetails({coffeeProductId});
    if (response.productDetails.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Coffee support ($coffeeProductId) is not configured in Play Console yet.',
            ),
          ),
        );
      }
      return;
    }

    final param = PurchaseParam(productDetails: response.productDetails.first);
    await InAppPurchase.instance.buyConsumable(purchaseParam: param);
  }

  static Future<void> checkForAppUpdate(BuildContext context) async {
    if (kIsWeb || _updateCheckedThisLaunch) return;
    _updateCheckedThisLaunch = true;
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability != UpdateAvailability.updateAvailable) return;
      if (!context.mounted) return;

      await showDialog<void>(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Update Available',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          content: const Text(
            'A newer version of Dua-ul-Anbiya is available on Google Play. Update now for the latest improvements!',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text(
                'Later',
                style: TextStyle(color: Color(0xFF888888)),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogCtx).pop();
                try {
                  if (info.immediateUpdateAllowed) {
                    await InAppUpdate.performImmediateUpdate();
                  } else if (info.flexibleUpdateAllowed) {
                    await InAppUpdate.startFlexibleUpdate();
                    await InAppUpdate.completeFlexibleUpdate();
                  } else {
                    await launchUrl(
                      Uri.parse(playStoreUrl),
                      mode: LaunchMode.externalApplication,
                    );
                  }
                } catch (e) {
                  debugPrint('In-app update failed: $e');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F7A5A),
                foregroundColor: Colors.white,
              ),
              child: const Text('Update Now'),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('Update check skipped: $e');
    }
  }
}
