# Local Gemini-style Assistant (Android)

An Android app that runs **Gemma locally on-device** (via Google's LiteRT-LM runtime -
the same one the official "AI Edge Gallery" app uses) and behaves like the
Gemini/Google Assistant app on Pixel phones: it can be set as the phone's default
Assistant, answer questions, read your notifications, read what's on screen, and
open/change system settings — all without any network call once a model is loaded.
The model, the prompt, and everything it reads about your phone stay on the device.
Requires Android 12+ (minSdk 31) - same requirement as LiteRT-LM/AI Edge Gallery.

## What's included

| Piece | File | Role |
|---|---|---|
| On-device inference | `llm/GemmaInferenceEngine.kt` | Loads a Gemma `.litertlm` model with Google's LiteRT-LM `Engine`/`Conversation` API and runs multi-turn chat, fully offline. |
| Chat UI | `ui/MainActivity.kt`, `ui/ChatAdapter.kt` | Load the model file, grant permissions, and chat directly. |
| System Assistant role | `assistant/AssistantSessionService.kt`, `AssistantSessionServiceImpl.kt`, `AssistantSession.kt` | Registers the app so it can be picked in *Settings > Apps > Default apps > Digital assistant app*, and shows an overlay session (like Gemini's sheet) when invoked. |
| Device control | `accessibility/DeviceControlAccessibilityService.kt` | AccessibilityService: reads on-screen text, taps a labeled element, presses back/home/recents, opens Quick Settings/notification shade. |
| Settings control | `control/SettingsController.kt` | Opens the relevant system Settings screens/panels (Wi-Fi, Bluetooth, display, battery, security, per-app settings, …). |
| Notification reading | `notifications/NotificationReaderService.kt` | `NotificationListenerService` that keeps a small in-memory buffer of recent notification titles/text so the assistant can summarize them. |
| Function calling | `control/ActionExecutor.kt` | Parses `[ACTION:NAME key=value]` tags the model emits and dispatches them to the pieces above. |

## Why it can't silently do *everything* Assistant does

Two Android platform rules apply to every third-party app, including this one:

- **Accessibility, Notification access, and the Assistant role must be granted
  by the user manually** in Settings — no app can silently self-grant these,
  regardless of how it is built. The app has buttons that jump straight to the
  right settings screen for you.
- **Directly flipping Wi-Fi/Bluetooth/etc. from code was removed in API 29**
  for privacy reasons. This app instead opens the matching Settings panel
  (the OS-sanctioned way, and what Gemini itself does), and can additionally
  tap the visible toggle via the Accessibility service if you ask it to.

## Getting a model file

LiteRT-LM needs a `.litertlm` bundle (older Gemma 3n releases used `.task` -
also supported). The model file is intentionally *not* bundled in this repo
(it's multiple GB and gated behind Google's model license on Hugging Face).

**Recommended: the in-app "Download model" button.** It fetches the model
directly from Hugging Face - no need to hunt for a URL, no dependency on
another app having downloaded it first. It's prefilled with the exact repo/file
the AI Edge Gallery app itself uses for **Gemma 4 E2B-it**
(`litert-community/gemma-4-E2B-it-litert-lm` / `gemma-4-E2B-it.litertlm`, confirmed
by reading that app's own source); swap the repo id for another Gemma variant if
you want a different size. You only need a free Hugging Face account:

1. Open the repo's page on huggingface.co (e.g.
   `https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm`) and
   accept Gemma's license if prompted.
2. Create an access token: Hugging Face → Settings → Access Tokens → New token
   (read access is enough).
3. In the app, tap **"Download model"**, leave the repo/filename as they are
   (or change them for a different variant), paste the token, confirm.

**Alternative: adb**, if you'd rather push a file you already have locally:
`adb push your-model.litertlm /sdcard/Download/model.litertlm`, then pick it
from Downloads via **"Load model"**.

## Building the APK

This sandbox has no network access to Google's Maven repository
(`dl.google.com`), so the Android Gradle Plugin and the AndroidX/LiteRT-LM
dependencies could not be downloaded or compiled here (CI builds it instead,
see `.github/workflows/build_apk.yml`). The Gradle wrapper (`./gradlew`) is
already committed. To build locally:

```bash
# Requires Android Studio (or the Android SDK + JDK 17) with normal internet access
./gradlew assembleDebug
# APK: app/build/outputs/apk/debug/app-debug.apk
adb install app/build/outputs/apk/debug/app-debug.apk
```

Easiest path: open the project folder in Android Studio (Hedgehog or newer) —
it will fetch the SDK/dependencies and let you run "Build > Build APK(s)".

## First-run setup on the phone

1. Install the APK, open it, tap **Download model** (see above) or **Load model**
   to pick a `.litertlm` file already on your device.
2. Tap **"Enable device control (Accessibility)"** and turn the service on.
3. Grant notification access via *Settings > Apps > Special app access >
   Notification access* (a shortcut for this can be wired to a button the
   same way as the Accessibility one — see `SettingsController.openNotificationListenerSettings`).
4. Tap **"Set as default Assistant app"** and confirm the system role prompt
   (Android 10+: `RoleManager.ROLE_ASSISTANT`; on some OEM skins this is under
   *Settings > Apps > Default apps > Digital assistant app* instead).
5. Trigger the assistant the way your device normally launches it (long-press
   power button / home-button gesture, depending on OEM) — it now opens this
   app's overlay instead of Gemini.

## Extending it

- The model's replies are plain text plus an optional `[ACTION:...]` tag
  (see the system prompt in `AssistantSession.kt`). Add new tags to
  `ActionExecutor.runAction` to support more actions (e.g. media controls,
  clipboard, calendar).
- `DeviceControlAccessibilityService.tapByLabel` does a simple text/content-description
  search; for more reliable automation, extend it to match by resource-id too.
