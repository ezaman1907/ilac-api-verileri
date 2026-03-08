# guncelle.ps1
$ErrorActionPreference = "Stop"

Write-Host "Excel dosyasi indiriliyor..."
# NOT: Buraya SGK veya TITCK'nin güncel Excel dosyasının gerçek ve direkt indirme linki gelecek.
# Şimdilik hata vermemesi için temsili bir mantık kuruyoruz.
$url = "https://www.sgk.gov.tr/Ekler/GuncelIlacListesi.xlsx" 
$tempExcel = "ilac_listesi.xlsx"

try {
    # Dosyayı indir
    Invoke-WebRequest -Uri $url -OutFile $tempExcel

    Write-Host "ImportExcel modulu yukleniyor..."
    Install-Module ImportExcel -Scope CurrentUser -Force -AllowClobber

    Write-Host "Excel okunuyor ve JSON'a cevriliyor..."
    # Eğer Excel içindeki sayfa adı farklıysa 'WorksheetName' kısmını ona göre değiştirmelisin
    $ilacVerileri = Import-Excel -Path $tempExcel -WorksheetName "Aktif İlaçlar" -ErrorAction Stop | ConvertTo-Json -Depth 5

    # JSON dosyasını repoya kaydediyoruz
    $ilacVerileri | Out-File -FilePath "ilaclar.json" -Encoding utf8

    Write-Host "İşlem tamam! ilaclar.json dosyasi olusturuldu."
} catch {
    Write-Error "Bir hata olustu: $_"
    exit 1
}
