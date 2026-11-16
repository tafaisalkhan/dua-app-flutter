import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';

class AdBanner extends StatefulWidget {
  const AdBanner({super.key, required this.position});

  final String position;

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    if (!AdService.isAdFreeToday) {
      _loadAd();
    }
  }

  void _loadAd() {
    if (kIsWeb || AdService.isAdFreeToday) return;
    final adUnitId = widget.position == 'Top Ad'
        ? (kDebugMode ? 'ca-app-pub-3940256099942544/6300978111' : const String.fromEnvironment('ADMOB_BANNER_ID', defaultValue: 'ca-app-pub-3940256099942544/6300978111'))
        : (kDebugMode ? 'ca-app-pub-3940256099942544/6300978111' : const String.fromEnvironment('ADMOB_BANNER_ID', defaultValue: 'ca-app-pub-3940256099942544/6300978111'));

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('Ad loaded: ${widget.position}');
          if (mounted) {
            setState(() => _isLoaded = true);
          }
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('Ad failed to load (${widget.position}): ${err.message} (code: ${err.code})');
          ad.dispose();
          AdService.markNoFillTodayAndNotify(adUnitId);
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AdService.adFreeTodayNotifier,
      builder: (context, isAdFree, _) {
        if (isAdFree) {
          return const SizedBox.shrink();
        }
        if (_isLoaded && _bannerAd != null) {
          return Container(
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: AdWidget(ad: _bannerAd!),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
