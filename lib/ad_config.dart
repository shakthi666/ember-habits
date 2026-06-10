// ============================================================
//  AD CONFIG — THE ONLY CODE FILE YOU WILL EVER EDIT
// ============================================================
//
//  Right now this app uses Google's official TEST ads.
//  Test ads are required while you develop — Google bans
//  accounts that click their own real ads.
//
//  WHEN YOU HAVE YOUR REAL ADMOB IDs (see SETUP_GUIDE.md
//  Part 5), replace ONLY the two quoted values below, then
//  the app rebuilds automatically.
//
//  An AdMob ad unit ID looks like:
//  ca-app-pub-1234567890123456/1234567890
//
// ============================================================

class AdConfig {
  // PASTE YOUR REAL **BANNER** AD UNIT ID between the quotes below:
  static const String bannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111'; // <-- Google TEST id

  // PASTE YOUR REAL **INTERSTITIAL** AD UNIT ID between the quotes below:
  static const String interstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712'; // <-- Google TEST id

  // Show a full-screen ad after this many habit check-ins.
  // Don't lower this: too many ads kills streaks AND can get
  // the app removed from the Play Store.
  static const int actionsPerInterstitial = 6;

  // Minimum seconds between two full-screen ads:
  static const int interstitialCooldownSeconds = 120;
}
