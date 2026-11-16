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
  static const String _prefPopupStep = 'no_ads_popup_step';
  static const String _prefAdsRemoved = 'ads_removed_permanently';

  static String _adFreeDate = '';
  static int _popupStep = 0;
  static int _streakDays = 1;
  static bool _isStreakRewardToday = false;
  static bool _dialogCurrentlyVisible = false;
  static bool _popupShownThisLaunch = false;
  static bool _adsRemoved = false;

  static final ValueNotifier<bool> adFreeTodayNotifier = ValueNotifier<bool>(false);

  static const String _prodInterstitialAdUnitId =
      String.fromEnvironment('ADMOB_INTERSTITIAL_ID', defaultValue: 'ca-app-pub-3940256099942544/1033173712');
  static const String _testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

  static String get interstitialAdUnitId =>
      kDebugMode ? _testInterstitialAdUnitId : _prodInterstitialAdUnitId;

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
    _popupStep = prefs.getInt(_prefPopupStep) ?? 0;

    if (lastOpen != today) {
      if (lastOpen == yesterday) {
        _streakDays += 1;
      } else {
        _streakDays = 1;
      }
      if (_streakDays >= streakRewardDays) {
        _isStreakRewardToday = true;
        _adFreeDate = today;
        _streakDays = 0;
        await prefs.setString(_prefAdFreeDate, today);
      }
      await prefs.setString(_prefLastOpenDate, today);
      await prefs.setInt(_prefStreakDays, _streakDays);
    } else if (_adFreeDate == today && _streakDays == 0) {
      _isStreakRewardToday = true;
    }

    if (adsPausedForSuspension) {
      _adFreeDate = today;
      await prefs.setString(_prefAdFreeDate, today);
    }

    adFreeTodayNotifier.value = isAdFreeToday;
  }

  static Future<void> markNoFillTodayAndNotify(String adUnitId) async {
    if (!isValidAdUnitId(adUnitId)) return;
    final today = _todayKey();
    if (_adFreeDate != today) {
      _adFreeDate = today;
      adFreeTodayNotifier.value = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefAdFreeDate, today);
    }
  }

  static Future<void> showNoAdsPopupIfNeeded(BuildContext context) async {
    if (!isAdFreeToday || _popupShownThisLaunch || _dialogCurrentlyVisible) return;
    if (ModalRoute.of(context)?.isCurrent != true) return;

    final prefs = await SharedPreferences.getInstance();
    final currentStep = _popupStep;
    _popupShownThisLaunch = true;
    _popupStep = (_popupStep + 1) % 3;
    await prefs.setInt(_prefPopupStep, _popupStep);

    if (!context.mounted) return;
    _dialogCurrentlyVisible = true;
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => NoAdsPopup(
        step: currentStep,
        isStreakReward: _isStreakRewardToday,
        streakDays: _streakDays,
        isAdFreePurchased: _adsRemoved,
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
