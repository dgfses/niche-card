# ==============================================================================
# Script Otomatis: Sinkronisasi Kartu HTML Baru ke index.html & Auto Git Push
# ==============================================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$nicheDir = $PSScriptRoot
if (-not $nicheDir) { $nicheDir = Get-Location }

Write-Host "🔍 Memindai file HTML baru di folder Niche_Card..." -ForegroundColor Cyan

$indexPath = Join-Path $nicheDir "index.html"
if (-not (Test-Path $indexPath)) {
    Write-Error "File index.html tidak ditemukan di $nicheDir"
    exit 1
}

$indexContent = Get-Content $indexPath -Raw -Encoding UTF8
$htmlFiles = Get-ChildItem -Path $nicheDir -Filter "*.html" | Where-Object { $_.Name -ne "index.html" }

$newCardsFound = 0
$newCardBlocks = @()

$navSnippet = @"

<script>
if (window.self === window.top) {
  const hubBtn = document.createElement('a');
  hubBtn.href = 'index.html';
  hubBtn.innerText = '← Menu Utama';
  hubBtn.style.cssText = 'position:fixed;top:12px;right:12px;z-index:9999;background:#14171f;color:#3b82f6;border:1px solid #2a3142;padding:6px 14px;border-radius:20px;font-size:12px;font-weight:600;text-decoration:none;box-shadow:0 4px 14px rgba(0,0,0,0.6);font-family:sans-serif;transition:0.2s;';
  hubBtn.onmouseover = () => hubBtn.style.background = '#1e2433';
  hubBtn.onmouseout = () => hubBtn.style.background = '#14171f';
  document.body.appendChild(hubBtn);
}
</script>
</body>
"@

foreach ($file in $htmlFiles) {
    $fileName = $file.Name
    if (-not $indexContent.Contains($fileName)) {
        Write-Host "  ✨ Ditemukan file baru: $fileName" -ForegroundColor Green
        $newCardsFound++
        
        $fileRaw = Get-Content $file.FullName -Raw -Encoding UTF8
        
        # Injek tombol menu utama jika belum ada
        if (-not $fileRaw.Contains("window.self === window.top")) {
            $fileRaw = $fileRaw -replace '</body>', $navSnippet
            Set-Content -Path $file.FullName -Value $fileRaw -Encoding UTF8
        }
        
        # Ambil Metadata
        $title = if ($fileRaw -match '<h1>(.*?)</h1>') { $matches[1] -replace '<[^>]+>', '' } else { $fileName -replace '\.html$', '' }
        $desc = if ($fileRaw -match '<p class="sub">(.*?)</p>') { $matches[1] -replace '<[^>]+>', '' } else { "Panduan dan materi strategi: $title" }
        
        # Tentukan Kategori sederhana berdasarkan nama file
        $category = "bicolink"
        $icon = "📑"
        $catLabel = "Strategi"
        $catClass = "cat-bicolink"
        
        if ($fileName -match 'dating|cpa') {
            $category = "dating"; $icon = "💑"; $catLabel = "Dating CPA"; $catClass = "cat-dating"
        } elseif ($fileName -match 'fb|facebook|reels') {
            $category = "facebook"; $icon = "📱"; $catLabel = "Facebook"; $catClass = "cat-facebook"
        } elseif ($fileName -match 'adult|18') {
            $category = "adult"; $icon = "🔞"; $catLabel = "Adult 18+"; $catClass = "cat-adult"
        } elseif ($fileName -match 'ban|protect|domain') {
            $category = "antiban"; $icon = "🛡️"; $catLabel = "Anti-Ban"; $catClass = "cat-antiban"
        } elseif ($fileName -match 'game|cheat|mod') {
            $category = "bicolink"; $icon = "🎮"; $catLabel = "Gaming"; $catClass = "cat-gaming"
        }

        $cleanTitle = [System.Security.SecurityElement]::Escape($title.Trim())
        $cleanDesc = [System.Security.SecurityElement]::Escape($desc.Trim())

        $cardHtml = @"
      <!-- Card Baru: $fileName -->
      <div class="card" data-category="$category" data-file="$fileName" data-title="$cleanTitle" data-icon="$icon" data-tags="$cleanTitle, $catLabel">
        <div class="card-top">
          <div class="card-icon">$icon</div>
          <span class="card-cat $catClass">$catLabel</span>
        </div>
        <h2 class="card-title">$cleanTitle</h2>
        <p class="card-desc">$cleanDesc</p>
        <div class="card-tags">
          <span class="tag">$catLabel</span>
          <span class="tag">Materi Baru</span>
        </div>
        <div class="card-footer">
          <button class="btn-read" onclick="openReader('$fileName', '$icon $cleanTitle')">
            <span>📖 Baca Modul</span>
          </button>
          <a href="$fileName" target="_blank" class="btn-open" title="Buka di tab baru">↗</a>
        </div>
      </div>

"@
        $newCardBlocks += $cardHtml
    }
}

if ($newCardsFound -gt 0) {
    $insertBlock = ($newCardBlocks -join "`n")
    $updatedIndex = $indexContent -replace '(?s)(<!-- Empty State -->)', "$insertBlock`n      `$1"
    Set-Content -Path $indexPath -Value $updatedIndex -Encoding UTF8
    Write-Host "✅ Berhasil menambahkan $newCardsFound kartu baru ke index.html!" -ForegroundColor Green
} else {
    Write-Host "👌 Semua file HTML ($($htmlFiles.Count) file) sudah terdaftar di index.html." -ForegroundColor Yellow
}

# Opsi Git Commit & Push
Write-Host ""
Write-Host "🚀 Menyiapkan Git Commit..." -ForegroundColor Cyan
git -C $nicheDir add .
$status = git -C $nicheDir status --porcelain
if ($status) {
    git -C $nicheDir commit -m "feat: sinkronisasi file HTML baru ke dashboard"
    Write-Host "✅ Perubahan berhasil di-commit!" -ForegroundColor Green
    Write-Host "💡 Untuk update ke Vercel secara online, jalankan: git push" -ForegroundColor Magenta
} else {
    Write-Host "Semua file bersih, tidak ada perubahan baru untuk di-commit." -ForegroundColor Gray
}
