# guncelle.ps1
$ErrorActionPreference = "Stop"

try {
    Write-Host "[*] Yerel veri tabani hazirlaniyor..."
    
    # Herhangi bir linke bagimli kalmadan, Swift uygulaman icin 
    # test verilerini dogrudan burada olusturuyoruz.
    $ilaclar = @(
        @{ Barkod = "8699514010110"; IlacAdi = "PAROL 500 MG 20 TABLET"; Fiyat = "85.50" },
        @{ Barkod = "8699525010017"; IlacAdi = "MAJEZIK 100 MG 15 FILM TABLET"; Fiyat = "112.25" },
        @{ Barkod = "8699540010016"; IlacAdi = "ARVELLES 25 MG 20 FILM TABLET"; Fiyat = "94.75" },
        @{ Barkod = "8699508010447"; IlacAdi = "APRANAX FORTE 550 MG 20 TABLET"; Fiyat = "105.00" },
        @{ Barkod = "8699514120017"; IlacAdi = "VERIDON 500 MG 60 TABLET"; Fiyat = "210.30" }
    )

    Write-Host "[*] JSON donusumu yapiliyor..."
    # Swift modeline tam uyumlu JSON uretiyoruz
    $jsonOut = $ilaclar | ConvertTo-Json -Compress

    Write-Host "[*] Dosya sisteme yaziliyor..."
    # UTF8 encoding Turkce karakterler (İ, ş, ğ) icin kritik
    $jsonOut | Out-File -FilePath "ilaclar.json" -Encoding utf8
    
    Write-Host "[+] Basarili! ilaclar.json icinde $($ilaclar.Count) adet ilac var."

} catch {
    Write-Error "Hata: $_"
    exit 1
}
