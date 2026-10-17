# niche-card
Bisa banget! Sangat fleksibel. Begitu Anda menambahkan file HTML baru ke folder tersebut, website di Vercel bisa langsung terupdate otomatis.

Ada 2 cara yang bisa Anda pilih:

Cara 1: Otomatis 1-Klik (Menggunakan sync-cards.ps1) ⚡ Paling Cepat

Saya sudah buatkan skrip pembantu otomatis bernama sync-cards.ps1 di folder Anda.

Alur kerjanya setiap ada materi baru:

Masukkan/salin file HTML baru Anda ke folder Niche_Card (misal: trik_cpa_baru.html).
Buka PowerShell di folder tersebut, lalu ketik:
powershell
.\sync-cards.ps1
Skrip akan otomatis:
Mendeteksi file HTML baru tersebut.
Membaca judul dan deskripsi dari file HTML Anda.
Mendaftarkannya ke dalam index.html lengkap dengan tombol baca dan kategorinya.
Menyuntikkan tombol melayang "← Menu Utama" agar pembaca tidak tersesat.
Menyiapkan git commit otomatis.
Anda tinggal jalankan:
powershell
git push
(Selesai! Vercel akan otomatis mendeteksi push tersebut dan mengupdate web dalam ~15 detik tanpa perlu Anda buka web Vercel lagi).
Cara 2: Manual (Copy-Paste Blok di index.html)

Jika ingin mengatur sendiri kata-kata, ikon, atau kategorinya secara manual:

Buka index.html.
Cari bagian <div class="cards-grid" id="cardsGrid">.
Copy-paste 1 blok kartu berikut tepat di atas <!-- Empty State -->:
html
<!-- Card Baru Anda -->
<div class="card" data-category="bicolink" data-file="nama_file_baru.html" data-title="Judul Strategi Anda" data-icon="🚀" data-tags="Tag1, Tag2">
  <div class="card-top">
    <div class="card-icon">🚀</div>
    <span class="card-cat cat-bicolink">Bicolink</span>
  </div>
  <h2 class="card-title">Judul Strategi Anda</h2>
  <p class="card-desc">Tulis rangkuman singkat isi materi Anda di sini agar pembaca paham.</p>
  <div class="card-tags">
    <span class="tag">Tag 1</span>
    <span class="tag">Tag 2</span>
  </div>
  <div class="card-footer">
    <button class="btn-read" onclick="openReader('nama_file_baru.html', '🚀 Judul Strategi Anda')">
      <span>📖 Baca Modul</span>
    </button>
    <a href="nama_file_baru.html" target="_blank" class="btn-open" title="Buka di tab baru">↗</a>
  </div>
</div>

Catatan:

Bagian data-category bisa diisi: bicolink, dating, facebook, adult, atau antiban.
Angka counter, live search, dan in-page reader akan menghitung dan menyesuaikan secara otomatis tanpa Anda perlu menyentuh kode JavaScript sama sekali.
Ingin Menambah Tombol Kategori Baru?

Jika nanti Anda membuat topik/kategori baru yang belum ada di tombol atas (misalnya: Crypto, E-Commerce, dll.):

Di index.html, cari bagian <div class="filter-tabs">.
Tambahkan 1 tombol baru:
html
<button class="filter-btn" data-category="crypto">
  <span>🪙 Crypto Niche</span>
</button>
Pada kartu yang bersangkutan, cukup beri data-category="crypto".
Langkah Git Push ke Vercel Setiap Selesai Menambah

Cukup jalankan 3 baris standar ini di terminal:

powershell
git add .
git commit -m "Menambahkan materi baru"
git push

Karena Vercel sudah terhubung ke GitHub Anda (Continuous Deployment), Vercel akan otomatis build ulang website Anda dalam 10–20 detik setiap kali perintah git push selesai dijalankan.