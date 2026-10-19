# ==============================================================================
# Script Otomatis: Sinkronisasi Kartu HTML Baru ke index.html & Auto Git Commit
# ==============================================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$nicheDir = $PSScriptRoot
if (-not $nicheDir) { $nicheDir = (Get-Location).Path }

Write-Host "Memindai file HTML baru di folder Niche_Card..." -ForegroundColor Cyan

$indexPath = Join-Path $nicheDir "index.html"
if (-not (Test-Path $indexPath)) {
    Write-Error "File index.html tidak ditemukan di $nicheDir"
    exit 1
}

$indexContent = [System.IO.File]::ReadAllText($indexPath, [System.Text.Encoding]::UTF8)
$htmlFiles = Get-ChildItem -Path $nicheDir -Filter "*.html" | Where-Object { $_.Name -ne "index.html" }

$newCardsFound = 0
$newCardBlocks = [System.Collections.Generic.List[string]]::new()

$navSnippet = "<script>`r`nif (window.self === window.top) {`r`n  var hubBtn = document.createElement('a');`r`n  hubBtn.href = 'index.html';`r`n  hubBtn.innerText = '<- Menu Utama';`r`n  hubBtn.style.cssText = 'position:fixed;top:12px;right:12px;z-index:9999;background:#14171f;color:#3b82f6;border:1px solid #2a3142;padding:6px 14px;border-radius:20px;font-size:12px;font-weight:600;text-decoration:none;box-shadow:0 4px 14px rgba(0,0,0,0.6);font-family:sans-serif;transition:0.2s;';`r`n  hubBtn.onmouseover = function() { hubBtn.style.background = '#1e2433'; };`r`n  hubBtn.onmouseout = function() { hubBtn.style.background = '#14171f'; };`r`n  document.body.appendChild(hubBtn);`r`n}`r`n</script>`r`n</body>"

foreach ($file in $htmlFiles) {
    $fileName = $file.Name
    if (-not $indexContent.Contains($fileName)) {
        Write-Host "  [+] Ditemukan file baru: $fileName" -ForegroundColor Green
        $newCardsFound++
        
        $fileRaw = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
        
        # Injek tombol menu utama jika belum ada
        if (-not $fileRaw.Contains("window.self === window.top")) {
            $fileRaw = $fileRaw -replace '(?i)</body>', $navSnippet
            [System.IO.File]::WriteAllText($file.FullName, $fileRaw, [System.Text.Encoding]::UTF8)
        }
        
        # Ambil Metadata Judul & Deskripsi
        $title = $fileName -replace '\.html$', ''
        if ($fileRaw -match '(?i)<h1>(.*?)</h1>') {
            $title = $matches[1] -replace '<[^>]+>', ''
        }
        
        $desc = "Panduan dan materi strategi: $title"
        if ($fileRaw -match '(?i)<p class="sub">(.*?)</p>') {
            $desc = $matches[1] -replace '<[^>]+>', ''
        }
        
        # Tentukan Kategori sederhana berdasarkan nama file
        $category = "bicolink"
        $icon = [char]::ConvertFromUtf32(0x1F4D1) # Buku
        $catLabel = "Strategi"
        $catClass = "cat-bicolink"
        
        if ($fileName -match 'dating|cpa') {
            $category = "dating"
            $icon = [char]::ConvertFromUtf32(0x1F491) # Dating
            $catLabel = "Dating CPA"
            $catClass = "cat-dating"
        } elseif ($fileName -match 'fb|facebook|reels') {
            $category = "facebook"
            $icon = [char]::ConvertFromUtf32(0x1F4F1) # HP
            $catLabel = "Facebook"
            $catClass = "cat-facebook"
        } elseif ($fileName -match 'adult|18') {
            $category = "adult"
            $icon = [char]::ConvertFromUtf32(0x1F51E) # 18+
            $catLabel = "Adult 18+"
            $catClass = "cat-adult"
        } elseif ($fileName -match 'ban|protect|domain') {
            $category = "antiban"
            $icon = [char]::ConvertFromUtf32(0x1F6E1) # Perisai
            $catLabel = "Anti-Ban"
            $catClass = "cat-antiban"
        } elseif ($fileName -match 'game|cheat|mod') {
            $category = "bicolink"
            $icon = [char]::ConvertFromUtf32(0x1F3AE) # Game
            $catLabel = "Gaming"
            $catClass = "cat-gaming"
        }

        $cleanTitle = [System.Security.SecurityElement]::Escape($title.Trim())
        $cleanDesc = [System.Security.SecurityElement]::Escape($desc.Trim())

        $cardHtml = "      <!-- Card Baru: $fileName -->`r`n" +
                    "      <div class=`"card`" data-category=`"$category`" data-file=`"$fileName`" data-title=`"$cleanTitle`" data-icon=`"$icon`" data-tags=`"$cleanTitle, $catLabel`">`r`n" +
                    "        <div class=`"card-top`">`r`n" +
                    "          <div class=`"card-icon`">$icon</div>`r`n" +
                    "          <span class=`"card-cat $catClass`">$catLabel</span>`r`n" +
                    "        </div>`r`n" +
                    "        <h2 class=`"card-title`">$cleanTitle</h2>`r`n" +
                    "        <p class=`"card-desc`">$cleanDesc</p>`r`n" +
                    "        <div class=`"card-tags`">`r`n" +
                    "          <span class=`"tag`">$catLabel</span>`r`n" +
                    "          <span class=`"tag`">Materi Baru</span>`r`n" +
                    "        </div>`r`n" +
                    "        <div class=`"card-footer`">`r`n" +
                    "          <button class=`"btn-read`" onclick=`"openReader('$fileName', '$icon $cleanTitle')`">`r`n" +
                    "            <span>Baca Modul</span>`r`n" +
                    "          </button>`r`n" +
                    "          <a href=`"$fileName`" target=`"_blank`" class=`"btn-open`" title=`"Buka di tab baru`">Tab Baru</a>`r`n" +
                    "        </div>`r`n" +
                    "      </div>"

        $newCardBlocks.Add($cardHtml)
    }
}

if ($newCardsFound -gt 0) {
    $insertBlock = ($newCardBlocks -join "`r`n")
    $updatedIndex = $indexContent -replace '(?s)(<!-- Empty State -->)', "$insertBlock`r`n      `$1"
    [System.IO.File]::WriteAllText($indexPath, $updatedIndex, [System.Text.Encoding]::UTF8)
    Write-Host "[OK] Berhasil menambahkan $newCardsFound kartu baru ke index.html!" -ForegroundColor Green
} else {
    Write-Host "[OK] Semua file HTML ($($htmlFiles.Count) file) sudah terdaftar di index.html." -ForegroundColor Yellow
}

# Opsi Git Commit
Write-Host ""
Write-Host "Menyiapkan Git Commit..." -ForegroundColor Cyan
git -C $nicheDir add .
$status = git -C $nicheDir status --porcelain
if ($status) {
    git -C $nicheDir commit -m "feat: sinkronisasi file HTML baru ke dashboard"
    Write-Host "[OK] Perubahan berhasil di-commit ke Git lokal!" -ForegroundColor Green
    Write-Host ">> Untuk update online ke Vercel, cukup jalankan: git push" -ForegroundColor Magenta
} else {
    Write-Host "[INFO] Semua file bersih, tidak ada perubahan baru untuk di-commit." -ForegroundColor Gray
}
