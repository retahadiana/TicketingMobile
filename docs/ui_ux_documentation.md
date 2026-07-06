# Dokumentasi UI/UX E-Ticketing Helpdesk - Anti-Gravity Glassmorphism

Dokumen ini menjelaskan spesifikasi desain UI/UX terbaru dari aplikasi **E-Ticketing Helpdesk** yang menerapkan estetika **"Anti-Gravity / Glassmorphism"** modern, premium, dan dinamis, serta sepenuhnya adaptif terhadap mode gelap (*Dark Mode*) dan terang (*Light Mode*).

---

## 🌌 1. Filosofi Desain: Anti-Gravity Glassmorphism
Aplikasi ini beralih dari tampilan *Flat Material Design* yang kaku menuju gaya visual modern yang memberikan kesan kedalaman (*depth*), melayang (*anti-gravity*), dan material semi-transparan seperti kaca buram (*frosted glass*). Efek ini didukung oleh:
- **Radial & Linear Gradients** pada latar belakang global untuk menciptakan ilusi kedalaman luar angkasa/cahaya nebula.
- **Backdrop Blur** untuk mensimulasikan pembiasan cahaya melalui material kaca tipis.
- **Thin High-Contrast Borders** untuk mendefinisikan batas fisik kontainer tanpa membuatnya terlihat tebal.

---

## 🎨 2. Palet Warna Dinamis (Dynamic Color Palette)

Aplikasi secara otomatis mendeteksi kecerahan sistem (`Brightness.light` / `Brightness.dark`) dan mengadaptasi warna latar belakang serta kontainer *glassmorphism*.

### A. Dark Mode (High-Tech Deep Navy & Charcoal)
Sesuai untuk memberikan kesan premium, modern, dan futuristik.
* **Latar Belakang Scaffold (Gradiasi Linear 4 Titik)**:
  * `#192A56` (Deep Navy Blue)
  * `#2D3436` (Dark Charcoal)
  * `#1E1545` (Midnight Purple)
  * `#6C5CE7` (Soft Purple)
* **Glass Container Fill**: `#FFFFFF` dengan opacity `8%` (`0x14FFFFFF`)
* **Glass Container Border**: `#FFFFFF` dengan opacity `15%` (`0x26FFFFFF`)
* **Accent Colors**:
  * `#00CEC9` (Accent Cyan) - Digunakan untuk sorot status aktif, timeline selesai, dan tombol utama.
  * `#74B9FF` (Accent Blue) - Digunakan untuk variasi ikon dan tombol sekunder.

### B. Light Mode (Modern Clean Pastel & Sky)
Memberikan antarmuka yang bersih, lembut, menyenangkan, namun tetap mempertahankan estetika *glassmorphism*.
* **Latar Belakang Scaffold (Gradiasi Linear 4 Titik)**:
  * `#E8DFFF` (Soft Lavender)
  * `#D6EAFF` (Sky Blue)
  * `#E0D4FF` (Pastel Purple)
  * `#C8E6FF` (Light Cyan)
* **Glass Container Fill**: `#FFFFFF` dengan opacity `55%` (`0x8CFFFFFF`)
* **Glass Container Border**: `#FFFFFF` dengan opacity `70%` (`0xB3FFFFFF`)

---

## ✍️ 3. Sistem Tipografi Adaptif (Adaptive Typography System)

Untuk menghindari masalah teks tidak terbaca (*invisible text*) saat berpindah ke Light Mode, seluruh teks di dalam aplikasi menggunakan hirarki tipografi berbasis properti tema `Theme.of(context).colorScheme.onSurface` yang dikombinasikan dengan tingkat transparansi (*opacity*) untuk penekanan informasi.

| Tingkatan Kontrast | Properti Warna | Keterangan & Penggunaan |
| :--- | :--- | :--- |
| **Primary/Bold** | `fg` (100% Opacity) | Judul halaman, nama tiket, teks penting, dan field input. |
| **Secondary/Sub** | `fgSub` (60% Opacity) | Deskripsi tiket, detail meta-data, dan tanggal riwayat. |
| **Muted/Disabled** | `fgMuted` (40% Opacity) | Penunjuk bantuan (hint text), teks non-aktif, label tidak penting. |

* **Font Utama**: **Poppins** (diintegrasikan melalui `google_fonts` untuk kesan modern editorial).
* **Font Weights**:
  * `FontWeight.w400` (Default Body)
  * `FontWeight.w600` (Label, Navigation, & Subtitle)
  * `FontWeight.w700` (Heading & Emphasis)

---

## 🎫 4. Komponen Kustom UI (Custom UI Components)

Seluruh widget kustom ini dideklarasikan secara sentral di `lib/core/theme/glassmorphism.dart`:

### 1. `GradientScaffold`
Scaffold kustom yang menggantikan Scaffold standar. Menyediakan latar belakang gradasi linear 4 titik yang mengalir secara otomatis sesuai mode brightness.

### 2. `GlassCard`
Kontainer *frosted glass* serbaguna dengan pembiasan `BackdropFilter` (blur radius 12) dan garis tepi tipis semi-transparan.

### 3. `TicketCard`
Kontainer khusus tiket yang memadukan efek *frosted glass* dengan bentuk tiket fisik yang memiliki potongan setengah lingkaran (*die-cut semi-circular notches*) di bagian kanan dan kiri menggunakan kelas kustom `TicketNotchClipper`.

### 4. `glassAppBar`
AppBar transparan adaptif yang memastikan judul teks dan ikon navigasi (misal, tombol kembali) secara otomatis menggunakan warna kontras yang tepat (`Colors.white` di Dark Mode, dan `AGColors.deepNavy` di Light Mode).

---

## 🏷️ 5. Skema Status Tiket (Ticket Status System)
Warna status tiket dirancang agar informatif namun tetap menyatu dengan estetika gradasi:
* 🟢 **Open**: `#0F766E` (Teal) - Melambangkan tiket baru yang bersih dan siap diproses.
* 🟠 **In Progress**: `#EA580C` (Orange) - Melambangkan aktivitas aktif.
* 🔵 **Resolved**: `#16A34A` (Green) - Menandakan keberhasilan pemecahan masalah.
* ⚪ **Closed**: Outline tipis atau abu-abu netral untuk menandakan riwayat selesai.

---

## 📂 6. File Sumber Utama (Source of Truth)
Jika ingin melakukan modifikasi visual lebih lanjut, file berikut adalah acuannya:
- **Sistem Tema & Komponen Glass**: [glassmorphism.dart](file:///d:/434241107_Reta-Hadiana-Unggula_B3-Aplikasi-Mobile_UTS-main/lib/core/theme/glassmorphism.dart)
- **Logika Kontrol Aplikasi**: [app_controller.dart](file:///d:/434241107_Reta-Hadiana-Unggula_B3-Aplikasi-Mobile_UTS-main/lib/core/app_controller.dart)
