# GigTrust-frontend
Frontend for GigTrust using Flutter

## Feature flag: Claude Sonnet 3.5

This project includes a frontend feature flag for "Claude Sonnet 3.5". It's a local, in-memory toggle intended to let the app choose whether client-role users should use the Claude Sonnet 3.5 model when making LLM-related requests.

Where it lives
- `lib/providers/model_provider.dart` holds the flag (`claudeSonnetForClients`).
- The app registers the provider in `lib/main.dart` and exposes a toggle in `Settings` (`lib/screens/settings_screen.dart`).

Important notes
- This is a frontend-only flag. The backend or API gateway must enforce model selection and access control for production usage. The frontend flag is helpful for demos and local testing.
- To persist the flag across restarts, integrate `shared_preferences` (not included here) or wire the setting to a backend user configuration.

