import 'package:asamurat/models/surat.dart';
import 'package:asamurat/utils/helpers.dart';

// Used for sorting [surat] by tanggal
List<Surat> _merge(
  List<Surat> listA,
  List<Surat> listB,
) {
  var indexA = 0;
  var indexB = 0;
  final result = <Surat>[];

  while (indexA < listA.length && indexB < listB.length) {
    final valueA = listA[indexA];
    final valueB = listB[indexB];

    if (convertDate(valueA.tanggal).compareTo(convertDate(valueB.tanggal)) < 0) {
      result.add(valueA);
      indexA += 1;
    } else if (convertDate(valueA.tanggal).compareTo(convertDate(valueB.tanggal)) > 0) {
      result.add(valueB);
      indexB += 1;
    } else {
      result.add(valueA);
      result.add(valueB);
      indexA += 1;
      indexB += 1;
    }
  }

  if (indexA < listA.length) {
    result.addAll(listA.getRange(indexA, listA.length));
  }

  if (indexB < listB.length) {
    result.addAll(listB.getRange(indexB, listB.length));
  }

  return result;
}

List<Surat> mergeSort(List<Surat> list) {
  if (list.length < 2) return list;

  final middle = list.length ~/ 2;
  final left = mergeSort(list.sublist(0, middle));
  final right = mergeSort(list.sublist(middle));

  return _merge(left, right);
}
