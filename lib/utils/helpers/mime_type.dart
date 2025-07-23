import 'dart:io';

import 'package:mime/mime.dart';

// MIME türleri listesini tanımlayın
const List<String> mimeTypes = ['image/png', 'image/jpeg'];

// Dosya yolunu ve MIME türü listesini alarak kontrol eden fonksiyon
bool isMimeTypeInList(String filePath, List<String> mimeTypesList) {
  try {
    final file = File(filePath);
    // Dosyanın MIME türünü belirleyin
    final mimeType = lookupMimeType(
      filePath,
      headerBytes: file.readAsBytesSync().sublist(0, 4),
    );

    // MIME türünün listede olup olmadığını kontrol edin
    return mimeType != null && mimeTypesList.contains(mimeType);
  } on Exception catch (_) {
    return false;
  }
}
//Ör nek kulanım

// import 'package:cloud_mining/utils/extensions/mime_type.dart';

// void main() {
//   final filePath = 'ohalde_icon.png';

//   // MIME türleri listesini belirleyin
//   final isInList = isMimeTypeInList(filePath, mimeTypes);

//   if (isInList) {
//     print('Dosya MIME türü listede mevcut.');
//   } else {
//     print('Dosya MIME türü listede mevcut değil.');
//   }
// }
