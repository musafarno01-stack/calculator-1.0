
abstract final class AdConfig {
  // Google's official Android sample App ID (testing only).
  static const String androidTestAppId =
      'ca-app-pub-3940256099942544~3347511713';

  // Google's official Android sample ad unit IDs (testing only).
  static const String androidTestBannerId =
      'ca-app-pub-3940256099942544/6300978111';

  static const String androidTestInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';

  static const String androidTestNativeId =
      'ca-app-pub-3940256099942544/2247696110';

  // Your AdMob Android App ID.
  // Obtain this from AdMob: Apps > App settings.
  // It is different from your ad unit IDs.
  static const String productionAppId = String.fromEnvironment(
    'ADMOB_ANDROID_APP_ID',
  );

  // YOUR PRODUCTION AD UNIT IDs — unchanged.
  static const String productionBannerId =
      'ca-app-pub-9045925293510194/5601253910';

  static const String productionNativeId =
      'ca-app-pub-9045925293510194/2514171557';

  static const String productionInterstitialId =
      'ca-app-pub-9045925293510194/4667446198';

  // Safe default: test ads enabled.
  // Set USE_TEST_ADS=false for a production build.
  static const bool useTestAds = bool.fromEnvironment(
    'USE_TEST_ADS',
    defaultValue: true,
  );

  static String get appId =>
      useTestAds ? androidTestAppId : productionAppId;

  static String get bannerId =>
      useTestAds ? androidTestBannerId : productionBannerId;

  static String get nativeId =>
      useTestAds ? androidTestNativeId : productionNativeId;

  static String get interstitialId =>
      useTestAds
          ? androidTestInterstitialId
          : productionInterstitialId;
}
