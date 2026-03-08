# guncelle.ps1
$ErrorActionPreference = "Continue" # Hata olsa bile ilerle ki nerede takıldığını görelim

# TİTCK Güncel Liste (Alternatif çalışan bir link)
$excelUrl = "https://www.titck.gov.tr/storage/Archive/2024/dynamicPageFiles/fiyat-listesi.xlsx"
$tempExcel = "fiyat_listesi.xlsx"

Write-Host "[*] TLS Guvenlik Protokolleri Ayarlaniyor..."
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

try {
    Write-Host "[*] TITCK verisi indiriliyor..."
    $client = New-Object System.Net.WebClient
    $client.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
    $client.DownloadFile($excelUrl, $tempExcel)

    Write-Host "[*] Modul yukleniyor (Guvenli mod)..."
    # Modül kurulumu sırasında onay beklememesi için Force ekliyoruz
    if (!(Get-Module -ListAvailable -Name ImportExcel)) {
        Install-Module ImportExcel -Scope CurrentUser -Force -AllowClobber -Confirm:$false
    }

    Write-Host "[*] Excel verisi JSON'a aktariliyor..."
    $veriler = Import-Excel -Path $tempExcel
    
    # Barkod, IlacAdi ve Fiyat alanlarını Swift modeline (Ilac struct) uygun eşliyoruz
    $temizVeri = $veriler | Where-Object { $_.'Barkod' -ne $null } | Select-Object `
        @{Name='Barkod'; Expression={ [string]$_.'Barkod' }},
        @{Name='IlacAdi'; Expression={ [string]$_.'İlaç Adı' }},
        @{Name='Fiyat'; Expression={ [string]$_.'Fiyat' }}

    $temizVeri | ConvertTo-Json -Compress | Out-File -FilePath "ilaclar.json" -Encoding utf8
    Write-Host "[+] Basarili! ilaclar.json guncellendi."

} catch {
    Write-Host "[-] Beklenmedik bir hata olustu: $_"
    exit 1
}
