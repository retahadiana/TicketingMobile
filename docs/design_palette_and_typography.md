# Dokumentasi Desain: Warna dan Tipografi (Terbaru)

Dokumentasi ini berisi rincian sistem desain, palet warna, tipografi, serta komponen visual utama yang saat ini digunakan pada aplikasi **Ticketing Helpdesk (Anti-Gravity)**.

---

## 1. Tipografi (Typography)

Aplikasi menggunakan paket Google Fonts sebagai dasar tipografinya.

*   **Primary Font Family**: **Poppins**
    *   *Sumber*:
        *   `GoogleFonts.poppinsTextTheme(...)` sebagai tema teks dasar.
        *   `GoogleFonts.poppins(...)` untuk penyesuaian khusus (seperti AppBar title, buttons, dll).
*   **Font Weights yang Digunakan**:
    *   `FontWeight.w400` (Regular) - Digunakan untuk teks deskripsi, isi body, dan petunjuk form (*hint*).
    *   `FontWeight.w500` (Medium) - Digunakan untuk teks dropdown, tombol navigasi tidak aktif, dll.
    *   `FontWeight.w600` (Semi-Bold) - Digunakan untuk sub-header, teks tombol utama, judul kartu, dan AppBar.
    *   `FontWeight.w700` (Bold) - Digunakan untuk judul utama (*Welcome Screen*, judul *Dashboard*, dll).

---

## 2. Token Warna Inti (Core Color Tokens)

Palet warna utama didefinisikan secara statis dalam kelas `AGColors` dan `AppTheme`:

| Token | Warna (HEX) | Deskripsi |
| :--- | :--- | :--- |
| `deepNavy` | **#192A56** | Warna navy gelap dasar untuk tema gelap & teks utama mode terang |
| `charcoal` | **#2D3436** | Warna abu-abu gelap untuk transisi latar belakang gelap |
| `softPurple` | **#6C5CE7** | Warna ungu utama (brand primary) untuk elemen interaktif di mode terang |
| `accentBlue` | **#74B9FF** | Warna biru sekunder untuk highlight dan penanda |
| `accentCyan` | **#00CEC9** | Warna cyan terang (brand primary) untuk elemen interaktif di mode gelap |

---

## 3. Sistem Glassmorphism

Aplikasi menggunakan kartu transparan dengan efek buram (*backdrop blur*) yang beradaptasi secara dinamis sesuai mode kecerahan layar.

### Mode Gelap (Dark Mode Glass)
*   **Latar Belakang (`glassFill`)**: `#FFFFFF` dengan opasitas 8% (`Color(0x14FFFFFF)`)
*   **Batas/Border (`glassBorder`)**: `#FFFFFF` dengan opasitas 15% (`Color(0x26FFFFFF)`)
*   **Highlight (`glassHighlight`)**: `#FFFFFF` dengan opasitas 5% (`Color(0x0DFFFFFF)`)
*   **Backdrop Blur**: `sigmaX: 12`, `sigmaY: 12`

### Mode Terang (Light Mode Glass)
*   **Latar Belakang (`lightGlassFill`)**: `#FFFFFF` dengan opasitas 55% (`Color(0x8CFFFFFF)`)
*   **Batas/Border (`lightGlassBorder`)**: `#FFFFFF` dengan opasitas 70% (`Color(0xB3FFFFFF)`)
*   **Backdrop Blur**: `sigmaX: 12`, `sigmaY: 12`

---

## 4. Gradien Latar Belakang (Gradient Backgrounds)

Seluruh halaman dibalut menggunakan `GradientScaffold` yang merender gradien halus:

*   **Gradien Mode Gelap**:
    *   Warna: `AGColors.deepNavy` (#192A56) -> `AGColors.charcoal` (#2D3436) -> Dark Purple (#1E1545) -> `AGColors.softPurple` (#6C5CE7)
    *   Posisi Transisi (*Stops*): `[0.0, 0.35, 0.7, 1.0]`
*   **Gradien Mode Terang**:
    *   Warna: Soft Lavender (#E8DFFF) -> Sky Blue (#D6EAFF) -> Pastel Purple (#E0D4FF) -> Light Cyan (#C8E6FF)
    *   Posisi Transisi (*Stops*): `[0.0, 0.35, 0.7, 1.0]`

---

## 5. Palet Warna Status Tiket (Ticket Status Palette)

Warna representatif untuk status pelaporan tiket:
*   **Open**: `#0F766E` (Cyan Gelap)
*   **In Progress**: `#EA580C` (Oranye) / `#CA6702` (Statistik)
*   **Resolved**: `#16A34A` (Hijau) / `#0A9396` (Statistik)
*   **Closed**: `#6C757D` (Abu-abu)

---

## 6. Desain Custom Navbar (Animated Glass Navigation Bar)

Navbar menggunakan desain kustom melayang dengan indikator lingkaran menonjol (*mockup-inspired*):

*   **Bentuk & Layout**: Baris rata bawah dengan kelengkungan sudut atas sebesar 30 (`borderRadius: only(topLeft, topRight: 30)`).
*   **Warna Latar Belakang Navbar (`navBgColor`)**:
    *   Mode Terang: Opaque White (`Colors.white`)
    *   Mode Gelap: Dark Slate Purple (`#1E1E2C`)
*   **Warna Elemen Aktif (`activeColor`)**:
    *   Mode Terang: `AGColors.softPurple` (#6C5CE7)
    *   Mode Gelap: `AGColors.accentCyan` (#00CEC9)
*   **Warna Elemen Tidak Aktif (`inactiveColor`)**:
    *   Mode Terang: `AGColors.deepNavy` dengan opasitas 50%
    *   Mode Gelap: Putih transparan dengan opasitas 54% (`Colors.white54`)
*   **Efek Interaktif**:
    *   Lingkaran indikator tab aktif berdiameter 52 melayang keluar di bagian atas navbar dengan pergeseran animasi pegas `Curves.easeOutBack`.
    *   Ikon di dalam lingkaran melayang berubah menggunakan transisi skala (`AnimatedSwitcher` + `ScaleTransition`).
    *   Ikon menu yang aktif disembunyikan dari baris dasar menu utama (hanya menyisakan label teks di bawah lingkaran indikator).

---

## 7. Sumber Rujukan Utama di Codebase (Source of Truth)

*   [app_theme.dart](file:///d:/434241107_Reta-Hadiana-Unggula_B3-Aplikasi-Mobile_UTS-main/lib/core/theme/app_theme.dart) - Konfigurasi global ThemeData, tipografi Poppins, dan form style.
*   [glassmorphism.dart](file:///d:/434241107_Reta-Hadiana-Unggula_B3-Aplikasi-Mobile_UTS-main/lib/core/theme/glassmorphism.dart) - Nilai dasar hex `AGColors`, widget GradientScaffold, GlassCard, dan TicketCard.
*   [home_shell_screen.dart](file:///d:/434241107_Reta-Hadiana-Unggula_B3-Aplikasi-Mobile_UTS-main/lib/features/home/presentation/home_shell_screen.dart) - Implementasi `AnimatedGlassNavigationBar` beserta warna & dimensi layout navbar terbaru.
