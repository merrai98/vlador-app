# Valdor — ColorDesk UI/UX rebuild

This is the Valdor field order-builder app with its **presentation layer rebuilt
to match the supplied `color-order-complete_valdor.html` design**, using the
**Browse → open** order-entry workflow.

## What was kept vs. rewritten

**Kept unchanged** (already a perfect fit for your API):
- Networking (`core/network`, Dio + session cookie auth)
- Data + domain layers (`features/*/data`, `features/*/domain`) and all models
- Hive offline cache (`core/helpers/hive_manager.dart`) and offline-first sync
- BLoC/use-cases for auth + home (login, get_products, create/update sale order,
  sync offline orders, logout)

**Rewritten** to be visually identical to the design:
- `core/theme` — design tokens (`app_colors.dart`), typography (`app_text.dart`
  using Space Grotesk / Inter / JetBrains Mono via `google_fonts`)
- `core/widgets/design/design_widgets.dart` — the reusable component kit
  (CTA, app bar, stepper, colour swatch + meter, status pills, brand mark,
  dark toast, etc.)
- `core/utils/network_cubit` — live online/offline indicator
- All screens under `features/*/presentation/pages`

## Screen ↔ scenario ↔ API map

| Design scenario | Screen file | API endpoint |
|---|---|---|
| S1 Sign in | `auth/.../login_screen.dart` | `POST /api/login` |
| S2 Sync hub (status + customers) | `home/.../customers_screen.dart` | `GET /api/get_products` |
| S3 Build quotation (**Browse → open**) | `home/.../build_quotation_screen.dart` | `POST /api/create_sale_order` |
| S4 Quotations / edit / locked | `home/.../quotations_screen.dart`, `quotation_edit_screen.dart` | `POST /api/update_sale_order_color_qty` (state_code **350** = confirmed/locked) |
| S5 Sync & resolve + logout | `home/.../sync_screen.dart` | batch create + update, `POST /api/logout` |

Navigation: Splash → Login → (first run) Download → `HomeShell` with a 3-tab
bottom bar: **Customers · Quotations · Sync**.

## Honest design deviations (kept strictly within the API)

The mock shows two pieces of data your API does not expose. Per the "nothing
beyond the API" rule these were grounded honestly rather than faked:

1. **Category chips** in the browse screen — the product payload has no category
   field, so the chip bar is replaced with a styled product search (same visual
   language).
2. **"Est. €" on quotation cards** — `get_products` does not return an amount for
   cached quotations (the model has no amount field), so cards show **Units** and
   **colour-line count** instead.

**"Duplicate"** on a confirmed (locked) quotation re-opens the build screen
pre-filled with that order's colour movements and saves via
`create_sale_order` — a normal, API-supported create.

## Fonts

The three design fonts load through the `google_fonts` package (added to
`pubspec.yaml`). They cache on-device after first load, preserving offline-first
behaviour. If you need the fonts available with no network on the very first
launch, drop the TTFs into `assets/fonts/`, declare them in `pubspec.yaml`, and
switch the helpers in `core/theme/app_text.dart` from `GoogleFonts.*` to those
families.

## Run

```bash
flutter pub get
flutter run
```

The server host is editable on the login screen (defaults to the value in
`core/constants/api_url.dart`).

## Build the APK on GitHub (CI)

A workflow is included at `.github/workflows/build-apk.yml`.

**To get an APK:**
1. Push this project to a GitHub repo (`git init`, commit, push to `main`).
2. The **Build APK** workflow runs automatically (or run it manually from the
   repo's **Actions** tab → *Build APK* → **Run workflow**).
3. Open the finished run → **Artifacts** → download **valdor-apk** → install
   the `.apk` on your Android device.

**Optional — versioned releases:** push a tag and the APK is also attached to a
GitHub Release:
```bash
git tag v1.0.0
git push origin v1.0.0
```

**Notes**
- The release APK is signed with the **debug key** (per
  `android/app/build.gradle.kts`), so it installs with no keystore secrets. For
  Play Store distribution, add a real keystore + `android/key.properties` and a
  release `signingConfig`.
- The workflow uses Flutter **stable**. The project's Dart SDK constraint is
  `^3.10.0`; if a CI run reports a Dart/SDK mismatch, pin a Flutter version in
  the workflow (`with: flutter-version: 'x.y.z'`) that bundles Dart ≥ 3.10.
- `android/gradle.properties` heap was lowered to `-Xmx4G` so the build fits
  GitHub-hosted runners.
