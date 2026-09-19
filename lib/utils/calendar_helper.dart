import 'package:hijri/hijri_calendar.dart';

class CalendarHelper {
  // 1. Algoritma Julian Day Number (JDN) Standar Astronomi (Eksak per tanggal kalender)
  static int _getJulianDayNumber(int year, int month, int day) {
    int a = (14 - month) ~/ 12;
    int y = year + 4800 - a;
    int m = month + 12 * a - 3;
    return day + ((153 * m + 2) ~/ 5) + 365 * y + (y ~/ 4) - (y ~/ 100) + (y ~/ 400) - 32045;
  }

  // 2. Kalender Hijriah
  static Map<String, dynamic> convertToHijri(DateTime date) {
    const List<String> namaBulanHijriah = [
      'Muharram',
      'Safar',
      'Rabi\'ul Awwal',
      'Rabi\'ul Akhir',
      'Jumadil Awwal',
      'Jumadil Akhir',
      'Rajab',
      'Sya\'ban',
      'Ramadhan',
      'Syawwal',
      'Dzulqa\'dah',
      'Dzulhijjah',
    ];

    final adjustedDate = DateTime(date.year, date.month, date.day).subtract(const Duration(days: 1));
    final hijri = HijriCalendar.fromDate(adjustedDate);

    final int monthIndex = (hijri.hMonth - 1).clamp(0, 11);
    final String bulanName = namaBulanHijriah[monthIndex];

    return {
      'day': hijri.hDay,
      'month': hijri.hMonth,
      'monthName': bulanName,
      'year': hijri.hYear,
      'fullFormatted': '${hijri.hDay} $bulanName ${hijri.hYear} H',
    };
  }

  // 3. Kalender Weton Jawa (Berbasis JDN)
  static Map<String, dynamic> convertToWeton(DateTime date) {
    const List<String> pasaranList = ['Legi', 'Pahing', 'Pon', 'Wage', 'Kliwon'];
    const List<String> hariList = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];

    const List<int> neptuHari = [5, 4, 3, 7, 8, 6, 9];
    const List<int> neptuPasaran = [5, 9, 7, 4, 8];

    final int jdn = _getJulianDayNumber(date.year, date.month, date.day);
    final int anchorJdnJawa = _getJulianDayNumber(1945, 8, 17);
    final int diffDays = jdn - anchorJdnJawa;
    int pasaranIdx = (0 + (diffDays % 5)) % 5;
    if (pasaranIdx < 0) pasaranIdx += 5;

    final int dayIdx = (jdn + 1) % 7;
    final String namaHari = hariList[dayIdx];
    final String namaPasaran = pasaranList[pasaranIdx];

    final int nHari = neptuHari[dayIdx];
    final int nPasaran = neptuPasaran[pasaranIdx];
    final int totalNeptu = nHari + nPasaran;

    return {
      'hari': namaHari,
      'pasaran': namaPasaran,
      'weton': '$namaHari $namaPasaran',
      'neptuHari': nHari,
      'neptuPasaran': nPasaran,
      'totalNeptu': totalNeptu,
    };
  }

  // 4. Kalender Wuku Bali (Berbasis JDN)
  static String convertToWuku(DateTime date) {
    const List<String> daftarWuku = [
      'Sinta', 'Landep', 'Ukir', 'Kulantir', 'Tolu', 'Gumbreg', 'Wariga', 'Warigadean',
      'Julungwangi', 'Sungsang', 'Galungan', 'Kuningan', 'Langkir', 'Medangsia', 'Pujut',
      'Pahang', 'Krulut', 'Merakih', 'Tambir', 'Medangkungan', 'Matal', 'Uye', 'Menail',
      'Prangbakat', 'Bala', 'Ugu', 'Wayang', 'Kelawu', 'Dukut', 'Watugunung'
    ];

    final int jdn = _getJulianDayNumber(date.year, date.month, date.day);
    final int anchorJdnBali = _getJulianDayNumber(1945, 10, 7);
    final int diffDays = jdn - anchorJdnBali;

    int wukuIdx = (diffDays ~/ 7) % 30;
    if (wukuIdx < 0) wukuIdx += 30;

    return daftarWuku[wukuIdx];
  }

  // 5. Sasih Bali & Tahun Saka
  static String convertToSasih(DateTime date) {
    final m = date.month;
    final d = date.day;
    if ((m == 8 && d >= 25) || (m == 9 && d <= 23)) return 'Katiga';
    if ((m == 9 && d >= 24) || (m == 10 && d <= 23)) return 'Kapat';
    if ((m == 10 && d >= 24) || (m == 11 && d <= 22)) return 'Kalima';
    if ((m == 11 && d >= 23) || (m == 12 && d <= 21)) return 'Kanem';
    if ((m == 12 && d >= 22) || (m == 1 && d <= 20)) return 'Kapitu';
    if ((m == 1 && d >= 21) || (m == 2 && d <= 19)) return 'Kawolu';
    if ((m == 2 && d >= 20) || (m == 3 && d <= 21)) return 'Kasanga';
    if ((m == 3 && d >= 22) || (m == 4 && d <= 20)) return 'Kadasa';
    if ((m == 4 && d >= 21) || (m == 5 && d <= 20)) return 'Jyestha';
    if ((m == 5 && d >= 21) || (m == 6 && d <= 20)) return 'Saddha';
    if ((m == 6 && d >= 21) || (m == 7 && d <= 24)) return 'Kasa';
    return 'Karo';
  }

  static int convertToSakaYear(DateTime date) {
    if (date.month < 3 || (date.month == 3 && date.day < 21)) {
      return date.year - 79;
    }
    return date.year - 78;
  }
}
