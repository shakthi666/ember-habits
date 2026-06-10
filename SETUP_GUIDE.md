# Ember — Complete Setup Guide (no coding required)

You are publishing **Ember**, a warm habit tracker with streaks, light & dark mode, fully offline — monetized with AdMob ads. Habit apps get opened daily, which is exactly what makes ad revenue work.

**Honest expectations before you start**

- Total cost: **$25** (one-time Google fee). Everything else is free.
- Timeline: about **3 weeks**, because Google forces new developers to run a 14-day test.
- You will need **12 friends/family with Android phones** willing to install your test app and keep it for 2 weeks. Google's rule for all new personal accounts — no way around it.
- Revenue starts near **$0/month** and grows only with installs. AdMob pays your bank at **$100** earned.
- Never click ads in your own app. Google detects it and permanently bans the account.

The order matters. Follow the parts in sequence.

---

## Part 1 — Put the app on GitHub (free) — ~20 minutes

GitHub stores your app's files, and its robots compile the app in the cloud. You install nothing.

1. Go to **github.com** → **Sign up** (use shakthi666@gmail.com).
2. Top-right **+** → **New repository**.
   - Repository name: `ember-habits`
   - Visibility: **Public** (required for the free build robots and free website hosting)
   - Click **Create repository**.
3. **Show hidden files on your Mac first:** open the `ember_habits` folder I gave you in Finder and press **Cmd + Shift + .** (period). A greyed-out folder named `.github` appears — it must be uploaded too; it contains the build robot's instructions.
4. On your new GitHub repo page, click the link **"uploading an existing file"**.
5. Drag **everything inside** the `ember_habits` folder (including `.github`, `lib`, `assets`, `docs`, `store_assets`, `pubspec.yaml`, `admob_app_id.txt`) into the upload box. Wait for all files to list, then click **Commit changes**.
6. Click the **Actions** tab → enable workflows if asked.
7. Click **"Build Ember (Play Store files)"** in the left sidebar → **Run workflow** → green **Run workflow** button.
8. Wait ~10–15 minutes for the green checkmark, then open the finished run. Under **Artifacts**:
   - `PLAY-STORE-FILE-upload-this-to-google` — the .aab file Google Play wants
   - `TEST-ON-YOUR-PHONE-apk` — installable test version
   - `SIGNING-KEY-SAVE-THIS-read-instructions-inside` — **first build only**

### 1b — Save your signing key (one time, 3 minutes — do not skip)

1. Download the `SIGNING-KEY...` artifact, unzip, read `READ-ME-FIRST.txt`.
2. Repo → **Settings → Secrets and variables → Actions → New repository secret**:
   - Name `KEYSTORE_BASE64` — Value: the full text of `KEYSTORE_BASE64.txt`.
   - Second secret: Name `KEYSTORE_PASSWORD` — Value: `ember2026`
3. Keep the unzipped folder safe (e.g., iCloud Drive). It's the key to your app's future updates.

---

## Part 2 — Try it on a real Android phone — ~10 minutes

1. Download `TEST-ON-YOUR-PHONE-apk`, unzip, send `app-release.apk` to any Android phone.
2. Tap the file on the phone → allow **"Install unknown apps"** → Install.
3. Open Ember. Add habits, check them off, try the moon/sun button (dark mode). You'll see **"Test Ad"** banners — correct for now; real ads come in Part 5.
4. Take **4–6 screenshots** (Power + Volume-down): home with a few habits checked, the add-habit sheet, progress screen — in both light **and** dark mode. These become your store listing images.

---

## Part 3 — Turn on your free privacy-policy website — ~5 minutes

1. Repo → **Settings → Pages**.
2. Source = **Deploy from a branch**; Branch = **main**, folder = **/docs** → **Save**.
3. After ~2 minutes your policy is live at `https://YOUR-USERNAME.github.io/ember-habits/` — open to confirm, write it down.

---

## Part 4 — Google Play Console — the $25 part

### 4a — Account (1–2 days for approval)

1. **play.google.com/console** → sign up as **Personal** → pay **$25** (real credit/debit card).
2. Identity verification (government ID photo). Few hours to 2 business days.

### 4b — Create the app

1. **Create app** → App name: `Ember: Habit Tracker & Streaks` → App / Free → **Create**.
2. Work through **Dashboard → "Set up your app"**. Exact answers:
   - **Privacy policy**: your Part-3 URL.
   - **App access**: "All functionality is available without special access".
   - **Ads**: **Yes, my app contains ads**.
   - **Content rating**: category **Utility/Productivity**; answer **No** to everything sensitive → "Everyone"-level rating.
   - **Target audience**: **18 and over** only.
   - **News / COVID / Government**: No.
   - **Financial features**: none.
   - **Health**: not a health app (it's a general habit/productivity tool — pick the "my app is not a health app" style answer).
   - **Data safety** (copy these):
     - Collect or share user data? **Yes**
     - Data types: **Device or other IDs → Device or other IDs** only.
     - Collected? **Yes**. Shared? **Yes** (with Google, for advertising). Ephemeral? **No**. Required. Purpose: **Advertising or marketing**.
     - Encrypted in transit? **Yes**. User-requestable deletion? **No** (data is held by Google AdMob, not you).
     - Google's current recommended answers: support.google.com/admob/answer/10787295
   - **Store listing**:
     - Short description: `Build habits that stick — warm streaks, gentle stats, dark mode. Offline & free.`
     - Full description — paste:

       ```
       Ember is the warm, simple way to build habits that stick.

       Check off your habits each day, grow your streak flame, and watch
       your progress bloom. No account, no cloud, no pressure — just you
       and your daily embers.

       • One-tap daily check-ins
       • Streaks that motivate (current & best)
       • Last-7-days dots on every habit
       • Gentle 30-day progress stats
       • Beautiful light AND dark mode
       • 100% offline — your data never leaves your phone
       • No account, no sign-up, free forever

       Small and daily beats big and rare. Light your first ember today.
       ```

     - App icon: `store_assets/play_store_icon_512.png`.
     - Feature graphic: `store_assets/feature_graphic_1024x500.png`.
     - Phone screenshots: the ones from Part 2 (include dark mode ones).
     - Category: **Productivity**. Tags: habit tracker, self-improvement.

### 4c — Closed testing (Google's mandatory 14-day gate)

1. **Testing → Closed testing → Create track** (default "Alpha" is fine).
2. **Create release** → upload `app-release.aab` → name `1.0.0` → Save → **Start rollout**.
3. **Testers tab** → create email list → add 12+ tester Gmail addresses → Save → share the **opt-in link** with them.
4. Testers: open link → Accept invite → install from Play. They should **keep it installed and open it occasionally for 14 days** (a habit app makes this easy — ask them to track one real habit!).
5. Don't pay "tester farm" services — Google detects fake testing.
6. After 14 days with 12+ opted-in testers: **Apply for production**, answer honestly.
7. Approved → **Production → Create release** → same .aab → rollout. Live within a few days' review.

---

## Part 5 — AdMob: switch test ads to real ads (real money)

Once the app is live in production:

1. **admob.google.com** → sign in with the same Google account → finish sign-up.
2. **Apps → Add app** → Android → "Yes, it's listed on a supported app store" → find Ember.
3. Note your **App ID** (`ca-app-pub-…~…`).
4. **Ad units → Add ad unit**:
   - **Banner** → name `home_banner` → Create → copy unit ID.
   - **Interstitial** → name `checkin_interstitial` → Create → copy unit ID.
5. Paste the three IDs **on the GitHub website**:
   - `admob_app_id.txt` → pencil icon → replace placeholder with your **App ID** (the `~` one) → Commit.
   - `lib/ad_config.dart` → pencil icon → replace the two quoted test IDs with your **banner** and **interstitial** IDs (keep quotes) → Commit.
   - `pubspec.yaml` → change `version: 1.0.0+1` to `version: 1.0.1+2` → Commit.
6. The robot rebuilds automatically (Actions tab) → download the new `.aab`.
7. Play Console → **Production → Create new release** → upload → rollout.
8. **Get paid**: AdMob → **Payments** → add bank details. Google mails a PIN postcard to verify your address. Monthly automatic payouts once you pass **$100**.

---

## Part 6 — What "passive" really looks like (read once)

- **One real annual chore**: Google raises the required "target Android version" yearly. You'll get a Play Console email months ahead — bring it to me, it's a 10-minute fix. Ignoring it eventually hides the app from new users. This is the biggest threat to the income stream.
- **Never click your own real ads.** Permanent ban.
- **Growth is the bottleneck.** Free levers that actually move habit apps: ask early users to leave 5-star reviews (Play ranking feeds on them), share in self-improvement communities (New Year's resolution season in January is this category's gold rush), and keep "habit tracker" in the title. When you're ready, I can add features that earn reviews — reminders, widgets, more stats.
- Keep your **signing key secrets** and Google account 2FA safe. Those two things are the business.

*Income disclaimer: nothing is guaranteed. Unpromoted apps typically earn $0–5/month; a habit app that finds a few thousand active users can earn tens to hundreds monthly because of daily opens — that's the bet we're making with this category.*
