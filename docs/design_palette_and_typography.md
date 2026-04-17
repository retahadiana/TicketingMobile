# Design Palette and Typography Notes

warna dan tipografi yang saat ini dipakai pada aplikasi Ticketing Helpdesk Flutter.

## 1) Typography

### Primary font family
- **Plus Jakarta Sans** (global text theme)
- Sumber:
  - `GoogleFonts.plusJakartaSansTextTheme(base.textTheme)`
  - `GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)` untuk label NavigationBar

### Font weight yang terlihat dipakai
- 400 (default body)
- 600 (label/navigation/meta)
- 700 (heading/emphasis)

### Catatan konsistensi
- Tidak ditemukan font family lain di folder `lib/`.
- Seluruh tampilan mengikuti tema global dan override lokal seperlunya.

## 2) Core Color Tokens

### Brand tokens (light-first)
- `brand`: **#0F766E**
- `brandDark`: **#134E4A**
- `accent`: **#EA580C**

### Light surface/background
- `surface`: **#F4F7F8**
- `scaffoldBackgroundColor`: **#F4F7F8**
- Input fill light: **#FFFFFF**

### Dark mode tokens
- `primary` dark: **#2DD4BF**
- `secondary` dark: **#FB923C**
- Input fill dark: **#0F172A**

## 3) Ticket Status Palette

Status warna yang dipakai pada daftar tiket/dashboard:
- **Open**: #0F766E
- **In Progress**: #EA580C (dan variasi #CA6702 pada kartu statistik)
- **Resolved**: #16A34A (dan variasi #0A9396 pada kartu statistik)
- **Closed**: outline theme (dan #6C757D pada kartu statistik)

## 4) Gradient and Hero Usage

### Splash gradient
- **#005F73 -> #0A9396 -> #94D2BD**

### Login hero gradient
- `colorScheme.primary` -> `colorScheme.primary` dengan alpha 0.75

## 5) Semantic Material Colors in Use

Aplikasi sudah memanfaatkan semantic colors dari Material 3:
- `primaryContainer` / `onPrimaryContainer`
- `secondaryContainer`
- `errorContainer` / `onErrorContainer`
- `outline` / `outlineVariant`
- `surfaceContainerHighest`

Ini bagus untuk menjaga kompatibilitas light/dark mode dan aksesibilitas kontras.

## 6) Neutrals and Utility Colors

Warna netral/utility yang dipakai di beberapa komponen:
- White: **#FFFFFF** (`Colors.white`)
- White 70: `Colors.white70`
- Black transparan untuk border light: `Colors.black` alpha 0.05/0.1
- White transparan untuk border dark: `Colors.white` alpha 0.08/0.15
- Green/Grey utility pada timeline detail tiket: `Colors.green`, `Colors.grey`

## 7) Source of Truth (Files)

- `lib/core/theme/app_theme.dart` (token utama tema + font global)
- `lib/features/auth/presentation/splash_screen.dart` (gradient splash)
- `lib/features/auth/presentation/login_screen.dart` (gradient login + error container)
- `lib/features/tickets/presentation/ticket_list_screen.dart` (status chip colors)
- `lib/features/tickets/presentation/dashboard_screen.dart` (warna statistik dashboard)

## 8) Rekomendasi Ringkas

- Pertahankan `app_theme.dart` sebagai sumber utama token.
- Jika ingin rapikan lebih lanjut, pindahkan warna status dashboard hardcoded ke konstanta tunggal (misal `TicketStatusColors`) agar konsisten lintas layar.
- Hindari menambah hardcoded color baru tanpa token agar maintainability tetap baik.
