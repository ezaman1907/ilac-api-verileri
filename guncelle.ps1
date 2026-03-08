# guncelle.ps1
$ErrorActionPreference = "Stop"

# İndirilecek SGK Excel linki
$excelUrl = "https://www.sgk.gov.tr/Download/DownloadFile?f=0ec1109c-a3fb-4723-867e-20567d7a67f5.xlsx&d=fa049c02-7d15-412e-8fb8-430c4f4f8694" 
$tempExcel = "ilac_listesi.xlsx"

Write-Host "[*] SGK Excel dosyasi indiriliyor..."
$headers = @{
    "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    "Accept" = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8"
}

try {
    # 1. Excel'i İndir
    Invoke-WebRequest -Uri $excelUrl -OutFile $tempExcel -Headers $headers -UseBasicParsing

    # 2. Modül Kontrolü ve Yükleme
    Write-Host "[*] ImportExcel modulu kontrol ediliyor..."
    if (!(Get-Module -ListAvailable -Name ImportExcel)) {
        Install-Module ImportExcel -Scope CurrentUser -Force -AllowClobber
    }

    # 3. Excel'i Oku (SGK Ek-4A listesi genelde 3. satırdan başlar)
    Write-Host "[*] Excel okunuyor..."
    $tumVeriler = Import-Excel -Path $tempExcel -StartRow 3

    # 4. Swift Tarafındaki JSON Modeline Uygun Şekilde İsimlendir ve Boş Satırları At
    Write-Host "[*] Veriler filtreleniyor ve Swift modeline uyarlaniyor..."
    $temizVeri = $tumVeriler | Select-Object `
        @{Name='Barkod'; Expression={$_.'Barkod'}},
        @{Name='IlacAdi'; Expression={$_.'İlaç Adı'}},
        @{Name='Fiyat'; Expression={$_.'Kamu Fiyatı'}} | 
        Where-Object { ![string]::IsNullOrWhiteSpace($_.Barkod) }

    # 5. JSON'a Çevir ve Kaydet
    Write-Host "[*] JSON dosyasi uretiliyor..."
    $temizVeri | ConvertTo-Json -Depth 5 | Out-File -FilePath "ilaclar.json" -Encoding utf8

    $kayitSayisi = ($temizVeri | Measure-Object).Count
    Write-Host "[+] İşlem basarili! $kayitSayisi adet ilac ilaclar.json dosyasina yazildi."

} catch {
    Write-Error "[-] Kritik Hata Olustu: $_"
    exit 1
} finally {
    # İşlem bitince sunucuda yer kaplamaması için geçici Excel dosyasını sil
    if (Test-Path $tempExcel) { Remove-Item $tempExcel -Force }
}
