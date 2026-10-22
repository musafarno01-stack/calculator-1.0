
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/ad_config.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _banner;
  bool _loading = false;
  bool _failed = false;
  int? _lastWidth;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final width = MediaQuery.sizeOf(context).width.truncate();

    if (width > 0 && width != _lastWidth) {
      _lastWidth = width;
      _loadBanner(width);
    }
  }

  Future<void> _loadBanner(int width) async {
    if (_loading) return;

    _loading = true;

    final previous = _banner;
    _banner = null;
    previous?.dispose();

    if (mounted) {
      setState(() => _failed = false);
    }

    try {
      final size =
          await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);

      if (!mounted || size == null || _lastWidth != width) {
        return;
      }

      final ad = BannerAd(
        adUnitId: AdConfig.bannerId,
        size: size,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (loadedAd) {
            if (!mounted || _lastWidth != width) {
              loadedAd.dispose();
              return;
            }

            setState(() {
              _banner = loadedAd as BannerAd;
              _failed = false;
            });

            debugPrint('Banner ad loaded successfully.');
          },
          onAdFailedToLoad: (failedAd, error) {
            debugPrint(
              'Banner failed to load: '
              '${error.code} - ${error.message}',
            );

            failedAd.dispose();

            if (mounted && _lastWidth == width) {
              setState(() {
                _banner = null;
                _failed = true;
              });
            }
          },
        ),
      );

      await ad.load();
    } catch (error, stackTrace) {
      debugPrint('Could not create banner: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        setState(() => _failed = true);
      }
    } finally {
      _loading = false;

      // Retry if the screen width changed while loading.
      if (mounted && _lastWidth != width && _lastWidth != null) {
        _loadBanner(_lastWidth!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ad = _banner;

    if (ad == null || _failed) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      top: false,
      child: Center(
        child: SizedBox(
          width: ad.size.width.toDouble(),
          height: ad.size.height.toDouble(),
          child: AdWidget(ad: ad),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }
}
