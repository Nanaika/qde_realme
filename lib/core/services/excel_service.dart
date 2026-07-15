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
      print("Ошибка в сервисе: $e");
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
      final cellB = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i));
      final value = cellB.value?.toString().trim() ?? '';

      if (value.isEmpty) continue;

      items.add(ItemModel(id: '', imei1: value, imei2: '', article: '', skuName: ''));
    }

    return items;
  }
}

// import 'dart:io';
//
// import 'package:excel/excel.dart';
// import 'package:flutter/foundation.dart';
//
// import '../../features/home/add_item/item_model.dart';
//
// class ExcelService {
//   List<ItemModel> innerItems = [];
//
//   void clear() {
//     innerItems.clear();
//   }
//
//   void parse(String filePath) async {
//     await compute(_parseExcelToItems, filePath);
//   }
//
//   List<ItemModel> _parseExcelToItems(String filePath) {
//     final List<ItemModel> items = [];
//
//     try {
//       final file = File(filePath);
//       final bytes = file.readAsBytesSync();
//       final excel = Excel.decodeBytes(bytes);
//
//       final String firstSheetName = excel.tables.keys.first;
//       final Sheet? sheet = excel.tables[firstSheetName];
//       if (sheet == null) return items;
//
//       // Запоминаем максимальное количество строк
//       final int totalRows = sheet.maxRows;
//
//       // Начинаем с 4-й строки (индекс 4), чтобы пропустить шапку прайса
//       for (int i = 4; i < totalRows; i++) {
//         // columnIndex: 1 — это ВСЕГДА колонка Б на листе, без сдвигов
//         final cellB = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i));
//
//         final value = cellB.value?.toString().trim() ?? '';
//
//         // Если в колонке Б пусто (строка производителя или пустая ячейка) — пропускаем
//         if (value.isEmpty) continue;
//
//         items.add(ItemModel(id: '', imei: value));
//       }
//     } catch (e) {
//       print("Ошибка парсинга: $e");
//     }
//     innerItems = items;
//     return items;
//   }
// }
