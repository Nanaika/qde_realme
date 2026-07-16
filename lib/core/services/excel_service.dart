import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';

import '../../features/home/add_item/item_model.dart';

class ExcelService {
  List<ItemModel> innerItems = [];

  void clear() {
    innerItems.clear();
  }

  Future<void> parse(String filePath) async {
    try {
      final parsedList = await compute(_parseExcelToItems, filePath);
      innerItems = parsedList;
    } catch (e) {
      print("Error in excel service: $e");
      rethrow;
    }
  }

  static List<ItemModel> _parseExcelToItems(String filePath) {
    final List<ItemModel> items = [];

    final file = File(filePath);
    final bytes = file.readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);

    final String firstSheetName = excel.tables.keys.first;
    final Sheet? sheet = excel.tables[firstSheetName];
    if (sheet == null) return items;

    final int totalRows = sheet.maxRows;

    for (int i = 4; i < totalRows; i++) {
      final cellA = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i));
      final valueA = cellA.value?.toString().trim() ?? '';

      final cellB = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i));
      final valueB = cellB.value?.toString().trim() ?? '';

      final cellC = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i));
      final valueC = cellC.value?.toString().trim() ?? '';

      final cellD = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i));
      final valueD = cellD.value?.toString().trim() ?? '';

      if (valueA.isEmpty || valueB.isEmpty || valueC.isEmpty || valueD.isEmpty) continue;

      items.add(ItemModel(id: '', imei1: valueB, imei2: valueC, article: valueA, skuName: valueD));
    }
    return items;
  }
}
