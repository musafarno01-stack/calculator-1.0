abstract final class AdConfig {
  // Google's official Android sample App ID. Test only.
  static const String androidTestAppId =
      'ca-app-pub-3940256099942544~3347511713';

  static const String androidTestBannerId =
      'ca-app-pub-3940256099942544/6300978111';

  static const String androidTestInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';

  // Replace these with your own AdMob IDs for a release build.
  // Supply values using --dart-define.
  static const String productionAppId = String.fromEnvironment(
    'ADMOB_ANDROID_APP_ID',
  );

  static const String productionBannerId = String.fromEnvironment(
    'ADMOB_ANDROID_BANNER_ID',
  );

  static const String productionInterstitialId = String.fromEnvironment(
    'ADMOB_ANDROID_INTERSTITIAL_ID',
  );

  static const bool useTestAds = bool.fromEnvironment(
    'USE_TEST_ADS',
    defaultValue: true,
  );

  static String get appId =>
      useTestAds ? androidTestAppId : productionAppId;

  static String get bannerId =>
      useTestAds ? androidTestBannerId : productionBannerId;

  static String get interstitialId =>
      useTestAds ? androidTestInterstitialId : productionInterstitialId;
}
