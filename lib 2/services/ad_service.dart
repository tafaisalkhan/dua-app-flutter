import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static InterstitialAd? _interstitialAd;
  static bool _isAdLoading = false;
  static int _navigationCount = 0;
  static int _loadAttempts = 0;

  static const String _prodInterstitialAdUnitId = 'ca-app-pub-1852108665659812/1039323888';
  static const String _testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

  static String get interstitialAdUnitId => kDebugMode ? _testInterstitialAdUnitId : _prodInterstitialAdUnitId;

  /// Pre-loads the Interstitial Ad so it's ready when needed.
  static void loadInterstitialAd() {
    if (_isAdLoading || _interstitialAd != null) return;
    _isAdLoading = true;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoading = false;
          _loadAttempts = 0;
          debugPrint('InterstitialAd loaded successfully.');

          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('InterstitialAd dismissed.');
              ad.dispose();
              _interstitialAd = null;
              loadInterstitialAd(); // Load the next one
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
          _loadAttempts++;
          debugPrint('Failed to load InterstitialAd: ${error.message} (code: ${error.code})');
          
          // Retry loading with exponential backoff up to 4 attempts
          if (_loadAttempts <= 4) {
            final delaySeconds = _loadAttempts * 5;
            debugPrint('Retrying to load InterstitialAd in $delaySeconds seconds...');
            Future.delayed(Duration(seconds: delaySeconds), () {
              loadInterstitialAd();
            });
          }
        },
      ),
    );
  }

  /// Increments the navigation counter. Displays the ad on every 3rd navigation.
  static void incrementNavigation() {
    _navigationCount++;
    debugPrint('Dua navigation count: $_navigationCount');
    if (_navigationCount % 3 == 0) {
      showInterstitialAd();
    }
  }

  /// Shows the pre-loaded interstitial ad if ready.
  static void showInterstitialAd() {
    if (_interstitialAd != null) {
      debugPrint('Showing InterstitialAd now.');
      _interstitialAd!.show();
    } else {
      debugPrint('InterstitialAd was requested but is not ready. Loading again.');
      loadInterstitialAd();
    }
  }
}
