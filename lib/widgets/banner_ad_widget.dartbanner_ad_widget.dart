
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/ad_config.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _ad;
  AdSize? _size;
  bool _failed = false;
  bool _loading = false;
  int? _lastWidth;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadForWidth(
      MediaQuery.sizeOf(context).width -
          MediaQuery.paddingOf(context).horizontal,
    );
  }

  Future<void> _loadForWidth(double width) async {
    final widthDp = width.floor();
    if (widthDp <= 0 ||
        widthDp == _lastWidth ||
        _loading ||
        AdConfig.bannerId.isEmpty) {
      return;
    }

    _lastWidth = widthDp;
    _loading = true;

    _ad?.dispose();
    _ad = null;
    _size = null;

    final size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      widthDp,
    );

    if (!mounted) return;

    if (size == null) {
      setState(() {
        _loading = false;
        _failed = true;
      });
      return;
    }

    final banner = BannerAd(
      adUnitId: AdConfig.bannerId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _ad = ad as BannerAd;
            _size = size;
            _loading = false;
            _failed = false;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (!mounted) return;
          setState(() {
            _ad = null;
            _size = null;
            _loading = false;
            _failed = true;
          });
        },
      ),
    );

    _ad = banner;
    banner.load();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    final size = _size;

    if (_failed || ad == null || size == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: size.width.toDouble(),
      height: size.height.toDouble(),
      child: AdWidget(key: ValueKey(ad), ad: ad),
    );
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }
}
