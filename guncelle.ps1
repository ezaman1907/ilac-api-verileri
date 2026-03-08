# guncelle.ps1
$ErrorActionPreference = "Stop"

# DİKKAT: Buraya SGK'nın en güncel Ek-4A Excel dosyasının direkt indirme linkini koymalısın.
# Test edebilmen için temsili olmayan, indirilebilir örnek bir format bıraktım.
$excelUrl = "BURAYA_GUNCEL_EXCEL_LINKINI_YAPISTIR" 
$tempExcel = "ilac_listesi.xlsx"

Write-Host "[*] SGK Excel dosyasi indiriliyor..."
# Devlet sitelerinin WAF (Güvenlik Duvarı) engeline takılmamak için tarayıcı kimliği
$headers = @{
    "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    "Accept" = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8"
}

try {
    Invoke-WebRequest -Uri $excelUrl -OutFile $tempExcel -Headers $headers -UseBasicParsing

    Write-Host "[*] ImportExcel modulu yukleniyor (Yoksa kurulur)..."
    Install-Module ImportExcel -Scope CurrentUser -Force -AllowClobber

    Write-Host "[*] Excel okunuyor ve JSON'a cevriliyor..."
    # SGK Excel'lerinde ilk 2 satır genelde başlık/logo olur, veriler 3. satırdan başlar.
    # Çalışma sayfası adı SGK listelerinde genelde "Ek-4A" veya sayfa1 olur.
    $tumVeriler = Import-Excel -Path $tempExcel -StartRow 3

    # Mobil uygulamanı şişirmemek için 30+ sütun arasından sadece ihtiyacımız olanları seçiyoruz
    $temizVeri = $tumVeriler | Select-Object "Barkod", "İlaç Adı", "Kamu Fiyatı"

    # Veriyi JSON formatına dönüştür ve UTF-8 olarak kaydet (Türkçe karakter sorunu yaşamamak için)
    $temizVeri | ConvertTo-Json -Depth 5 | Out-File -FilePath "ilaclar.json" -Encoding utf8

    Write-Host "[+] İşlem basariyla tamamlandi! ilaclar.json uretildi."
} catch {
    Write-Error "[-] Hata olustu: $_"
    exit 1
}
