import 'package:test/test.dart';

void main() {
  test('Math', () async {
    // Örnek bir liste oluştur
    List<int> numbers = List.generate(100, (index) => index + 1);

    // Paginasyon ayarları
    int itemsPerPage = 20;

    // Sayfa numarasına göre öğeleri döndüren fonksiyon
    List<T> paginateList<T>(List<T> list, int itemsPerPage, int pageNumber) {
      int startIndex = (pageNumber - 1) * itemsPerPage;
      int endIndex = startIndex + itemsPerPage;
      if (startIndex >= list.length) return [];
      if (endIndex > list.length) endIndex = list.length;
      return list.sublist(startIndex, endIndex);
    }

    // Örnek olarak ilk 3 sayfayı yazdıralım
    for (int i = 1; i <= 3; i++) {
      List<int> pageItems = paginateList(numbers, itemsPerPage, i);
      print('Page $i: $pageItems');
    }
  });
}
