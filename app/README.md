# ClaudeControl

Steuert dein Android-Gerät über den Accessibility-Tree (keine Screenshots) mittels Claude API (dein eigener API-Key, lokal auf dem Gerät gespeichert).

## Setup
1. Repo auf GitHub pushen (Branch `main`) → Actions baut automatisch die APK.
2. APK aus dem Workflow-Artifact "ClaudeControl-debug-apk" herunterladen, auf Handy installieren.
3. App öffnen: API-Key + Ziel eintragen → Speichern.
4. "Bedienungshilfen-Zugriff aktivieren" → ClaudeControl in Einstellungen > Bedienungshilfen aktivieren.
5. Zurück zur App: "Einen Schritt ausführen" (einzelner Call) oder "Auto-Loop starten" (alle 3s ein Schritt, bis Claude "done" meldet).

## Hinweise
- API-Key liegt unverschlüsselt in SharedPreferences (nur für private Nutzung gedacht).
- Modell: `claude-sonnet-5` (in `AppState.kt` änderbar).
- Kosten: jeder Schritt = 1 API-Call.
