# guncelle.ps1
$ErrorActionPreference = "Stop"

# Hedef: İlaç listesi sunan güvenilir bir sayfa
$targetUrl = "https://www.ilacabak.com/yeni-eklenen-ilaclar"
$headers = @{ "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" }

try {
    Write-Host "[*] Veri kazima basladi..."
    $response = Invoke-WebRequest -Uri $targetUrl -Headers $headers -UseBasicParsing
    $html = $response.Content

    # Regex ile İlaç Adı ve Fiyat eşleşmelerini yakalıyoruz
    # Bu desen, site yapısındaki ilaç ismi ve yanındaki fiyatı cımbızlar
    $pattern = '(?s)<div class="ilac-adi">.*?<a.*?>(.*?)</a>.*?<div class="fiyat">(.*?) ₺</div>'
    $matches = [regex]::Matches($html, $pattern)

    $ilacListesi = foreach ($match in $matches) {
        [PSCustomObject]@{
            Barkod   = "B-" + (Get-Random -Minimum 100000 -Maximum 999999) # Örnek Barkod
            IlacAdi  = $match.Groups[1].Value.Trim()
            Fiyat    = $match.Groups[2].Value.Trim()
        }
    }

    if ($ilacListesi.Count -eq 0) { throw "Veri bulunamadi!" }

    # JSON'a çevir ve dosyayı mühürle
    $ilacListesi | ConvertTo-Json -Compress | Out-File -FilePath "ilaclar.json" -Encoding utf8
    Write-Host "[+] $($ilacListesi.Count) adet ilac basariyla JSON yapildi."

} catch {
    Write-Error "Hata: $_"
    exit 1
}
