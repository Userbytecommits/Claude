# Local Gemini-style Assistant (Android)

An Android app that runs **Gemma locally on-device** (via Google's MediaPipe LLM
Inference API) and behaves like the Gemini/Google Assistant app on Pixel phones:
it can be set as the phone's default Assistant, answer questions, read your
notifications, read what's on screen, and open/change system settings — all
without any network call. The model, the prompt, and everything it reads about
your phone stay on the device.

## What's included

| Piece | File | Role |
|---|---|---|
| On-device inference | `llm/GemmaInferenceEngine.kt` | Loads a Gemma `.task` model with MediaPipe's `LlmInference`/`LlmInferenceSession` and runs multi-turn chat, fully offline. |
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

MediaPipe's LLM Inference API needs a `.task` bundle, not a raw checkpoint.
The model file is intentionally *not* bundled in this repo (it's multiple GB
and under its own license). Three ways to get one into this app:

**A) You already downloaded it in Google's "AI Edge Gallery" app.**
Tap **"Load model"** here and, in the system file picker, navigate to
`Internal storage > Android > data > com.google.ai.edge.gallery > files`
(the exact sub-path can vary) and pick the `.task` file. The system file
picker (unlike a regular app) is allowed to browse into another app's
`Android/data` folder even on scoped-storage Android versions, so this
usually works without root.

**B) Use the in-app "Download model" button.** Paste the *direct* `.task`
file URL (open the model's Hugging Face page, e.g. under
`litert-community/...` or `google/...`, go to **Files**, and copy the link
behind the download icon for the `.task` file) and, since every current
Gemma release is a gated model, your Hugging Face **access token** (Hugging
Face account → Settings → Access Tokens). The app downloads it straight into
its own storage and loads it — no Gallery app needed.

**C) adb.** `adb push your-model.task /sdcard/Download/model.task`, then
pick it from Downloads via "Load model".

## Building the APK

This sandbox has no network access to Google's Maven repository
(`dl.google.com`), so the Android Gradle Plugin and the AndroidX/MediaPipe
dependencies could not be downloaded or compiled here. The Gradle wrapper
(`./gradlew`) is already committed. To build:

```bash
# Requires Android Studio (or the Android SDK + JDK 17) with normal internet access
./gradlew assembleDebug
# APK: app/build/outputs/apk/debug/app-debug.apk
adb install app/build/outputs/apk/debug/app-debug.apk
```

Easiest path: open the project folder in Android Studio (Hedgehog or newer) —
it will fetch the SDK/dependencies and let you run "Build > Build APK(s)".

## First-run setup on the phone

1. Install the APK, open it, tap **Load model** and pick your `.task` file.
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
