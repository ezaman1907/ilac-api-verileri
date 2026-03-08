# guncelle.ps1
$ErrorActionPreference = "Stop"

# Resmi TİTCK Güncel İlaç Listesi (Sabit indirme linki denemesi)
$excelUrl = "https://www.titck.gov.tr/storage/Archive/2024/dynamicPageFiles/fiyat-listesi.xlsx"
$tempExcel = "fiyat_listesi.xlsx"

Write-Host "[*] TITCK verisi indiriliyor..."

# TLS güvenliğini sağla (Modern siteler için şart)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

try {
    # Dosyayı indir (Standard Invoke-WebRequest yerine New-Object WebClient kullanıyoruz)
    $client = New-Object System.Net.WebClient
    $client.Headers.Add("User-Agent", "Mozilla/5.0")
    $client.DownloadFile($excelUrl, $tempExcel)

    Write-Host "[*] ImportExcel modulu kuruluyor..."
    Install-Module ImportExcel -Scope CurrentUser -Force -AllowClobber

    Write-Host "[*] Excel okunuyor..."
    # TITCK dosyaları genelde ilk satırdan başlar
    $veriler = Import-Excel -Path $tempExcel

    # Swift modeline uygun hale getir
    $temizVeri = $veriler | Select-Object `
        @{Name='Barkod'; Expression={$_.'Barkod'}},
        @{Name='IlacAdi'; Expression={$_.'İlaç Adı'}},
        @{Name='Fiyat'; Expression={$_.'Fiyat'}} |
        Where-Object { $_.Barkod -ne $null }

    # JSON dosyasına yaz
    $temizVeri | ConvertTo-Json -Compress | Out-File -FilePath "ilaclar.json" -Encoding utf8
    Write-Host "[+] Islem tamamlandi!"

} catch {
    Write-Error "Hata detayi: $_"
    exit 1
}
