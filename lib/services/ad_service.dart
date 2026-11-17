import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/no_ads_popup.dart';

class AdService {
  static InterstitialAd? _interstitialAd;
  static bool _isAdLoading = false;
  static int _navigationCount = 0;

  /// Set to true if you want to pause all AdMob requests client-side during suspension.
  /// Even when false, NO_FILL (code 3) on valid AdMob IDs automatically triggers No-Ads-Today.
  static const bool adsPausedForSuspension = false;
  static const int streakRewardDays = 3;

  static const String _prefLastOpenDate = 'ad_streak_last_open_date';
  static const String _prefStreakDays = 'ad_streak_days';
  static const String _prefAdFreeDate = 'ad_free_date';
  static const String _prefAdsRemoved = 'ads_removed_permanently';

  static String _adFreeDate = '';
  static int _streakDays = 1;
  static bool _isStreakRewardToday = false;
  static bool _noFillThisLaunch = false;
  static bool _dialogCurrentlyVisible = false;
  static bool _popupShownThisLaunch = false;
  static bool _adsRemoved = false;

  static final ValueNotifier<bool> adFreeTodayNotifier = ValueNotifier<bool>(false);

  static const String _prodInterstitialAdUnitId =
      String.fromEnvironment('ADMOB_INTERSTITIAL_ID');

  static String get interstitialAdUnitId => _prodInterstitialAdUnitId;

  static bool isValidAdUnitId(String id) {
    return RegExp(r'^ca-app-pub-\d+/\d+$').hasMatch(id.trim());
  }

  static String _dateKey(DateTime dt) {
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '${dt.year}-$m-$d';
  }

  static String _todayKey() => _dateKey(DateTime.now());

  static bool get isAdsRemoved => _adsRemoved;

  static bool get isAdFreeToday =>
      _adsRemoved || adsPausedForSuspension || _adFreeDate == _todayKey();

  static Future<void> setAdsRemoved(bool value) async {
    _adsRemoved = value;
    adFreeTodayNotifier.value = isAdFreeToday;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefAdsRemoved, value);
  }

  static int get streakDays => _streakDays;

  static Future<void> initDailyState() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final yesterday = _dateKey(DateTime.now().subtract(const Duration(days: 1)));

    final lastOpen = prefs.getString(_prefLastOpenDate) ?? '';
    _adsRemoved = prefs.getBool(_prefAdsRemoved) ?? false;
    _streakDays = prefs.getInt(_prefStreakDays) ?? 0;
    _adFreeDate = prefs.getString(_prefAdFreeDate) ?? '';

    if (lastOpen != today) {
      if (lastOpen == yesterday) {
        _streakDays += 1;
      } else {
        _streakDays = 1;
      }
      if (_streakDays >= streakRewardDays) {
        final tomorrow = _dateKey(DateTime.now().add(const Duration(days: 1)));
        _adFreeDate = tomorrow;
        _streakDays = 0;
        await prefs.setString(_prefAdFreeDate, tomorrow);
      }
      await prefs.setString(_prefLastOpenDate, today);
      await prefs.setInt(_prefStreakDays, _streakDays);
    }
    _isStreakRewardToday = _adFreeDate == today;

    if (adsPausedForSuspension) {
      _adFreeDate = today;
      await prefs.setString(_prefAdFreeDate, today);
    }

    adFreeTodayNotifier.value = isAdFreeToday;
  }

  static String streakNotificationSuffix() {
    if (_adsRemoved) return '';
    final tomorrow = _dateKey(DateTime.now().add(const Duration(days: 1)));
    if (_adFreeDate == tomorrow) {
      return ' Streak complete! Today is 100% Ad-Free!';
    }
    if (_streakDays == 1) {
      return ' Open today (Day 2/3) toward a Free Ad-Free Day!';
    }
    if (_streakDays == 2) {
      return ' 1 more day (Day 3/3) to unlock tomorrow Ad-Free!';
    }
    return '';
  }

  static Future<void> markNoFillTodayAndNotify(String adUnitId) async {
    if (!isValidAdUnitId(adUnitId)) return;
    _noFillThisLaunch = true;
  }

  static Future<void> showNoAdsPopupIfNeeded(BuildContext context) async {
    if (_popupShownThisLaunch || _dialogCurrentlyVisible) {
      return;
    }
    if (ModalRoute.of(context)?.isCurrent != true) return;

    final randomStep = Random().nextInt(3);
    _popupShownThisLaunch = true;

    if (!context.mounted) return;
    _dialogCurrentlyVisible = true;
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => NoAdsPopup(
        step: randomStep,
        isStreakReward: _isStreakRewardToday,
        streakDays: _streakDays,
        isAdFreePurchased: _adsRemoved,
        isNoFill: _noFillThisLaunch,
      ),
    );
    _dialogCurrentlyVisible = false;
  }

  /// Pre-loads the Interstitial Ad so it's ready when needed.
  static void loadInterstitialAd() {
    if (kIsWeb || isAdFreeToday) return;
    if (_isAdLoading || _interstitialAd != null) return;
    _isAdLoading = true;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoading = false;
          debugPrint('InterstitialAd loaded successfully.');

          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('InterstitialAd dismissed.');
              ad.dispose();
              _interstitialAd = null;
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('InterstitialAd failed to show: ${error.message}');
              ad.dispose();
              _interstitialAd = null;
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isAdLoading = false;
          _interstitialAd = null;
          debugPrint('Failed to load InterstitialAd: ${error.message} (code: ${error.code})');

          markNoFillTodayAndNotify(interstitialAdUnitId);
        },
      ),
    );
  }

  /// Increments the navigation counter. Displays the ad on every 3rd navigation.
  static void incrementNavigation() {
    if (isAdFreeToday) return;
    _navigationCount++;
    debugPrint('Dua navigation count: $_navigationCount');
    if (_navigationCount % 3 == 0) {
      showInterstitialAd();
    }
  }

  /// Shows the pre-loaded interstitial ad if ready.
  static void showInterstitialAd() {
    if (isAdFreeToday) return;
    if (_interstitialAd != null) {
      debugPrint('Showing InterstitialAd now.');
      _interstitialAd!.show();
    } else {
      debugPrint('InterstitialAd was requested but is not ready. Loading again.');
      loadInterstitialAd();
    }
  }
}
