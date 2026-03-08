# guncelle.ps1
$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

try {
    Write-Host "[*] TITCK Duyurularindan guncel Excel linki avlaniyor..."
    $baseUrl = "https://www.titck.gov.tr/dinamiksayfa/28"
    $web = Invoke-WebRequest -Uri $baseUrl -UseBasicParsing
    
    # Sayfa icindeki ilk .xlsx uzantili linki yakala
    $relLink = $web.Links | Where-Object { $_.href -like "*.xlsx*" } | Select-Object -First 1 -ExpandProperty href
    $excelUrl = "https://www.titck.gov.tr" + $relLink
    
    Write-Host "[+] Bulunan Link: $excelUrl"
    $tempExcel = "tum_ilaclar.xlsx"
    
    $client = New-Object System.Net.WebClient
    $client.Headers.Add("User-Agent", "Mozilla/5.0")
    $client.DownloadFile($excelUrl, $tempExcel)

    Write-Host "[*] ImportExcel modulu kuruluyor..."
    Install-Module ImportExcel -Scope CurrentUser -Force -AllowClobber

    Write-Host "[*] 15.000+ satir okunuyor (Bu biraz surebilir)..."
    $veriler = Import-Excel -Path $tempExcel -StartRow 3

    $temizVeri = $veriler | Where-Object { $_.'Barkod' -ne $null } | Select-Object `
        @{Name='Barkod'; Expression={ [string]$_.'Barkod' }},
        @{Name='IlacAdi'; Expression={ [string]$_.'İlaç Adı' }},
        @{Name='Fiyat'; Expression={ [string]$_.'Fiyat' }}

    $temizVeri | ConvertTo-Json -Compress | Out-File -FilePath "ilaclar.json" -Encoding utf8
    Write-Host "[+] Basarili! $($temizVeri.Count) adet ilac sisteme yuklendi."

} catch {
    Write-Error "Hata: $_"
    exit 1
}
