
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/ad_config.dart';

class AdService {
  InterstitialAd? _interstitial;
  DateTime? _lastShown;
  int _completedCalculations = 0;
  bool _loading = false;

  static const _minimumCalculations = 8;
  static const _minimumInterval = Duration(minutes: 3);

  Future<void> initialize() async {
    if (kIsWeb) return;
    await MobileAds.instance.initialize();
    preloadInterstitial();
  }

  void recordSuccessfulCalculation() {
    _completedCalculations++;
  }

  void preloadInterstitial() {
    if (_loading || _interstitial != null || AdConfig.interstitialId.isEmpty) {
      return;
    }

    _loading = true;
    InterstitialAd.load(
      adUnitId: AdConfig.interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _loading = false;
          _interstitial = ad;
        },
        onAdFailedToLoad: (_) {
          _loading = false;
          _interstitial = null;
        },
      ),
    );
  }

  /// Call only on a non-critical transition, never on every equals press.
  /// Navigation should proceed whether the ad is available or not.
  Future<void> showOnHistoryTransition() async {
    final now = DateTime.now();
    final last = _lastShown;

    if (_completedCalculations < _minimumCalculations ||
        (last != null && now.difference(last) < _minimumInterval)) {
      return;
    }

    final ad = _interstitial;
    if (ad == null) {
      preloadInterstitial();
      return;
    }

    _interstitial = null;
    _lastShown = now;
    _completedCalculations = 0;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (closedAd) {
        closedAd.dispose();
        preloadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (failedAd, _) {
        failedAd.dispose();
        preloadInterstitial();
      },
    );

    await ad.show();
  }

  void dispose() {
    _interstitial?.dispose();
    _interstitial = null;
  }
}
