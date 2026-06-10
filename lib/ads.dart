import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';

/// Full-screen (interstitial) ad manager: preloads one ad, shows it at most
/// every [AdConfig.actionsPerInterstitial] check-ins, never more often than
/// the cooldown allows.
class InterstitialManager {
  static final InterstitialManager instance = InterstitialManager._();
  InterstitialManager._();

  InterstitialAd? _ad;
  int _actionCount = 0;
  DateTime _lastShown = DateTime.fromMillisecondsSinceEpoch(0);

  void preload() {
    if (_ad != null) return;
    InterstitialAd.load(
      adUnitId: AdConfig.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
        },
        onAdFailedToLoad: (error) {
          _ad = null;
        },
      ),
    );
  }

  /// Call after every positive action (habit checked off).
  void registerAction() {
    _actionCount++;
    final cooldownOver = DateTime.now().difference(_lastShown).inSeconds >
        AdConfig.interstitialCooldownSeconds;
    if (_actionCount >= AdConfig.actionsPerInterstitial &&
        cooldownOver &&
        _ad != null) {
      _actionCount = 0;
      _lastShown = DateTime.now();
      final ad = _ad!;
      _ad = null;
      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (a) {
          a.dispose();
          preload();
        },
        onAdFailedToShowFullScreenContent: (a, e) {
          a.dispose();
          preload();
        },
      );
      ad.show();
    } else {
      preload();
    }
  }
}

/// Banner ad that sizes itself and disappears gracefully if no ad loads.
class BannerAdBox extends StatefulWidget {
  const BannerAdBox({super.key});

  @override
  State<BannerAdBox> createState() => _BannerAdBoxState();
}

class _BannerAdBoxState extends State<BannerAdBox> {
  BannerAd? _banner;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    final banner = BannerAd(
      adUnitId: AdConfig.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) setState(() => _loaded = false);
        },
      ),
    );
    banner.load();
    _banner = banner;
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _banner == null) return const SizedBox.shrink();
    return SafeArea(
      top: false,
      child: SizedBox(
        width: _banner!.size.width.toDouble(),
        height: _banner!.size.height.toDouble(),
        child: AdWidget(ad: _banner!),
      ),
    );
  }
}
