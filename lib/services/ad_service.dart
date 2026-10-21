
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/ad_config.dart';

class AdService {
  bool _initialized = false;
  bool _initializing = false;
  bool _disposed = false;

  InterstitialAd? _interstitial;
  int _successfulCalculations = 0;
  DateTime? _lastInterstitialTime;

  static const int _minimumCalculations = 5;
  static const Duration _minimumAdInterval = Duration(minutes: 3);

  Future<void> initialize() async {
    if (_disposed || _initialized || _initializing) return;

    if (!AdConfig.useTestAds &&
        (AdConfig.productionAppId.isEmpty ||
            AdConfig.productionBannerId.isEmpty ||
            AdConfig.productionInterstitialId.isEmpty)) {
      debugPrint(
        'AdMob disabled: configure production AdMob IDs first.',
      );
      return;
    }

    _initializing = true;

    try {
      await MobileAds.instance.initialize();

      if (_disposed) return;

      _initialized = true;
      _preloadInterstitial();
    } catch (error) {
      debugPrint('AdMob initialization failed: $error');
    } finally {
      _initializing = false;
    }
  }

  void recordSuccessfulCalculation() {
    _successfulCalculations++;
  }

  void _preloadInterstitial() {
    if (_disposed || !_initialized || _interstitial != null) return;

    InterstitialAd.load(
      adUnitId: AdConfig.interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          if (_disposed) {
            ad.dispose();
            return;
          }

          _interstitial = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial failed to load: $error');
          _interstitial = null;
        },
      ),
    );
  }

  Future<void> showOnHistoryTransition() async {
    if (_disposed || !_initialized) return;
    if (_successfulCalculations < _minimumCalculations) return;

    final now = DateTime.now();
    final previous = _lastInterstitialTime;

    if (previous != null &&
        now.difference(previous) < _minimumAdInterval) {
      return;
    }

    final ad = _interstitial;

    if (ad == null) {
      _preloadInterstitial();
      return;
    }

    _interstitial = null;
    final completer = Completer<void>();

    void finish() {
      if (!completer.isCompleted) {
        completer.complete();
      }
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _preloadInterstitial();
        finish();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Interstitial show failed: $error');
        ad.dispose();
        _preloadInterstitial();
        finish();
      },
    );

    _lastInterstitialTime = now;

    try {
      ad.show();
      await completer.future;
    } catch (error) {
      debugPrint('Interstitial error: $error');
      ad.dispose();
      _preloadInterstitial();
    }
  }

  void dispose() {
    _disposed = true;
    _interstitial?.dispose();
    _interstitial = null;
  }
}
