import 'package:flutter/material.dart';
import '../services/support_service.dart';

/// Daily popup shown when ads are unavailable/suspended or earned via login streak.
/// Rotates one primary action button across appearances:
///   step 0 (1st time): Rate App
///   step 1 (2nd time): Share With Friends
///   step 2 (3rd time): Buy a Coffee for Developer ($0.99)
class NoAdsPopup extends StatelessWidget {
  const NoAdsPopup({
    super.key,
    required this.step,
    required this.isStreakReward,
    required this.streakDays,
    this.isAdFreePurchased = false,
  });

  final int step;
  final bool isStreakReward;
  final int streakDays;
  final bool isAdFreePurchased;

  @override
  Widget build(BuildContext context) {
    final actionIndex = step % 3;

    late final IconData headerIcon;
    late final String title;
    late final String body;
    late final String primaryLabel;
    late final IconData primaryIcon;

    final resolvedTitle = isAdFreePurchased
        ? 'Thank You for Your Support!'
        : (isStreakReward
            ? '3-Day Streak Reward: No Ads Today!'
            : 'No Ads Today!');
    final prefix = isAdFreePurchased ? '' : 'Enjoy an ad-free experience today! ';
    if (actionIndex == 0) {
      headerIcon = Icons.star_rounded;
      title = resolvedTitle;
      body = '${prefix}If you love the app, please rate us on the Play Store.';
      primaryLabel = 'Rate App';
      primaryIcon = Icons.star_rounded;
    } else if (actionIndex == 1) {
      headerIcon = Icons.share_rounded;
      title = resolvedTitle;
      body = '${prefix}Please share this app with your friends and family.';
      primaryLabel = 'Share With Friends';
      primaryIcon = Icons.share_rounded;
    } else {
      headerIcon = Icons.local_cafe_rounded;
      title = resolvedTitle;
      body =
          '${prefix}Support the developer with a \$1.99 coffee to help keep the app growing.';
      primaryLabel = 'Buy Developer a Coffee (\$1.99)';
      primaryIcon = Icons.local_cafe_rounded;
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 16,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFEAF8F2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                headerIcon,
                color: const Color(0xFF1F7A5A),
                size: 36,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              body,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF555555),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final rootContext =
                      Navigator.of(context, rootNavigator: true).context;
                  Navigator.of(context).pop();
                  if (actionIndex == 0) {
                    await SupportService.rateApp(rootContext);
                  } else if (actionIndex == 1) {
                    await SupportService.shareApp();
                  } else {
                    await SupportService.buyCoffee(rootContext);
                  }
                },
                icon: Icon(primaryIcon),
                label: Text(
                  primaryLabel,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F7A5A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                isAdFreePurchased ? 'Close' : 'Enjoy Ad-Free',
                style: const TextStyle(
                  color: Color(0xFF888888),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
