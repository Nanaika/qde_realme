import 'package:flutter/material.dart';

abstract class LocationTranslator {
  static const Map<String, Map<String, String>> _translations = {
    'tashkent_city': {'ru': 'Ташкент', 'uz': 'Toshkent'},
    'andijan': {'ru': 'Андижан', 'uz': 'Andijon'},
    'bukhara': {'ru': 'Бухара', 'uz': 'Buxoro'},
    'fergana': {'ru': 'Фергана', 'uz': 'Farg\'ona'},
    'jizzakh': {'ru': 'Джизак', 'uz': 'Jizzax'},
    'namangan': {'ru': 'Наманган', 'uz': 'Namangan'},
    'navoiy': {'ru': 'Навои', 'uz': 'Navoiy'},
    'kashkadarya': {'ru': 'Карши', 'uz': 'Qarshi'},
    'samarkand': {'ru': 'Самарканд', 'uz': 'Samarqand'},
    'syrdarya': {'ru': 'Гулистан', 'uz': 'Guliston'},
    'surkhandarya': {'ru': 'Термез', 'uz': 'Termiz'},
    'khorezm': {'ru': 'Ургенч', 'uz': 'Urganch'},
    'karakalpakstan': {'ru': 'Нукус', 'uz': 'Nukus'},

    'bektemir': {'ru': 'Бектемирский район', 'uz': 'Bektemir tumani'},
    'chilanzar': {'ru': 'Чиланзарский район', 'uz': 'Chilonzor tumani'},
    'yashnabad': {'ru': 'Яшнабадский район', 'uz': 'Yashnobod tumani'},
    'mirabad': {'ru': 'Мирабадский район', 'uz': 'Mirobod tumani'},
    'mirzo_ulugbek': {'ru': 'Мирзо-Улугбекский район', 'uz': 'Mirzo Ulug\'bek tumani'},
    'sergeli': {'ru': 'Сергелийский район', 'uz': 'Sergeli tumani'},
    'shaykhantahur': {'ru': 'Шайхантахурский район', 'uz': 'Shayxontohur tumani'},
    'olmazor': {'ru': 'Алмазарский район', 'uz': 'Olmazor tumani'},
    'uchtepa': {'ru': 'Учтепинский район', 'uz': 'Uchtepa tumani'},
    'yakkasaray': {'ru': 'Яккасарайский район', 'uz': 'Yakkasaroy tumani'},
    'yangi_hayot': {'ru': 'Янгихаётский район', 'uz': 'Yangihayot tumani'},
    'yunasabad': {'ru': 'Юнусабадский район', 'uz': 'Yunusobod tumani'},
  };

  // Перевод одного ключа для отображения на UI
  static String translate(BuildContext context, String key) {
    final String lang = Localizations.localeOf(context).languageCode;
    return _translations[key]?[lang] ?? _translations[key]?['ru'] ?? key;
  }

  // Сборка мапы всех городов под текущую локаль
  static Map<String, String> getCities(BuildContext context) {
    final String lang = Localizations.localeOf(context).languageCode;
    final Map<String, String> cities = {};
    final cityKeys = [
      'tashkent_city',
      'andijan',
      'bukhara',
      'fergana',
      'jizzakh',
      'namangan',
      'navoiy',
      'kashkadarya',
      'samarkand',
      'syrdarya',
      'surkhandarya',
      'khorezm',
      'karakalpakstan',
    ];
    for (var key in cityKeys) {
      if (_translations.containsKey(key)) {
        cities[key] = _translations[key]![lang] ?? _translations[key]!['ru']!;
      }
    }
    return cities;
  }

  // Сборка мапы районов Ташкента под текущую локаль
  static Map<String, String> getTashkentDistricts(BuildContext context) {
    final String lang = Localizations.localeOf(context).languageCode;
    final Map<String, String> districts = {};
    final districtKeys = [
      'bektemir',
      'chilanzar',
      'yashnabad',
      'mirabad',
      'mirzo_ulugbek',
      'sergeli',
      'shaykhantahur',
      'olmazor',
      'uchtepa',
      'yakkasaray',
      'yangi_hayot',
      'yunasabad',
    ];
    for (var key in districtKeys) {
      if (_translations.containsKey(key)) {
        districts[key] = _translations[key]![lang] ?? _translations[key]!['ru']!;
      }
    }
    return districts;
  }
}
