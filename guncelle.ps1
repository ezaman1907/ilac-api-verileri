# guncelle.ps1
$ErrorActionPreference = "Stop"

# SGK Direkt İndirme Linki
$excelUrl = "https://www.sgk.gov.tr/Download/DownloadFile?f=0ec1109c-a3fb-4723-867e-20567d7a67f5.xlsx&d=fa049c02-7d15-412e-8fb8-430c4f4f8694"
$tempExcel = "ilac_listesi.xlsx"

Write-Host "[*] SGK Excel dosyasi indiriliyor..."

# ÖNEMLİ: Standart indirme bazen boş dosya çeker, bu yüzden .NET WebClient kullanıyoruz
$webClient = New-Object System.Net.WebClient
$webClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
$webClient.DownloadFile($excelUrl, $tempExcel)

try {
    # Dosya indi mi ve boş mu kontrol et
    if ((Get-Item $tempExcel).Length -lt 1000) {
        throw "Dosya indirildi ama cok kucuk (bos olabilir). Link gecersiz veya engellendi."
    }

    Write-Host "[*] ImportExcel modulu kontrol ediliyor..."
    if (!(Get-Module -ListAvailable -Name ImportExcel)) {
        Install-Module ImportExcel -Scope CurrentUser -Force -AllowClobber
    }

    Write-Host "[*] Excel okunuyor..."
    # SGK Excel'inde başlıkları atlayıp veriye odaklanıyoruz
    $tumVeriler = Import-Excel -Path $tempExcel -StartRow 3

    Write-Host "[*] Swift modeline uyarlaniyor..."
    $temizVeri = $tumVeriler | Where-Object { $_.'Barkod' -ne $null } | Select-Object `
        @{Name='Barkod'; Expression={ [string]$_.'Barkod' }},
        @{Name='IlacAdi'; Expression={ [string]$_.'İlaç Adı' }},
        @{Name='Fiyat'; Expression={ [string]$_.'Kamu Fiyatı' }}

    # JSON Olarak Kaydet (Prettify kapalı, daha az yer kaplasın)
    $temizVeri | ConvertTo-Json -Compress | Out-File -FilePath "ilaclar.json" -Encoding utf8
    
    Write-Host "[+] Islem tamam! $($temizVeri.Count) adet ilac kaydedildi."

} catch {
    Write-Error "[-] Kritik Hata: $_"
    exit 1
} finally {
    if (Test-Path $tempExcel) { Remove-Item $tempExcel -Force }
}
