# ShishuCare UI refresh

This version keeps the original Deep Purple visual identity while giving the app a more polished Material 3 interface.

## Updated
- Centralized purple palette in `lib/constants/app_colours.dart`.
- Global Material 3 theme in `lib/main.dart`.
- Redesigned login screen with responsive layout, password visibility and animated hover states.
- Redesigned portal with responsive action cards, clearer hierarchy and logout.
- Redesigned child registration form with grouped sections, age preview and loading state.
- Redesigned child search with result cards, empty states and responsive interactions.
- Redesigned child profile with profile header, information tiles and screening actions.
- Redesigned screening flow with live progress, checked/red-flag counters and improved checklist cards.
- Redesigned screening history and screening report screens.
- Added reusable `AppCard`, `AppSectionTitle` and `PortalActionCard` widgets.
- Set Android `compileSdk = 36` to match the installed SDK and the `file_picker` dependency requirement from the original build error.
- No new third-party dependencies were added.

## Run
From the project root:

```powershell
flutter clean
flutter pub get
flutter run
```

The ZIP intentionally omits generated `.dart_tool` and `build` folders. They will be recreated by Flutter.
