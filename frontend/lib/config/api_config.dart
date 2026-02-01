/// API Configuration - Backend sunucu ayarları
class ApiConfig {
  // ADB Reverse kullanıldığında (En kararlı yöntem)
  // Komut: adb reverse tcp:3000 tcp:3000

  static const String baseUrl =
      'https://waspiest-flintiest-spencer.ngrok-free.dev/api';

  // Alternatif: Bilgisayarın yerel IP adresi (Eğer reverse çalışmazsa bunu deneyin)
  // static const String baseUrl = 'http://192.168.1.14:3000/api';

  // Android Emulator için özel IP
  // static const String baseUrl = 'http://10.0.2.2:3000/api';
}
