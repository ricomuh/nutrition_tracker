import '../models/app_settings.dart';

class LanguageService {
  static String getLanguagePrompt(ResponseLanguage language) {
    switch (language) {
      case ResponseLanguage.english:
        return '';
      case ResponseLanguage.indonesian:
        return '\n\nIMPORTANT: Please respond in Indonesian language. Translate all food names, units, comments, and analysis text to Indonesian while keeping the JSON structure exactly the same.';
    }
  }

  static String translateFoodName(String foodName, ResponseLanguage language) {
    if (language == ResponseLanguage.english) return foodName;

    // Basic food name translations - you can expand this
    final translations = {
      'rice': 'nasi',
      'chicken': 'ayam',
      'beef': 'daging sapi',
      'fish': 'ikan',
      'egg': 'telur',
      'bread': 'roti',
      'milk': 'susu',
      'cheese': 'keju',
      'yogurt': 'yogurt',
      'apple': 'apel',
      'banana': 'pisang',
      'orange': 'jeruk',
      'potato': 'kentang',
      'tomato': 'tomat',
      'carrot': 'wortel',
      'onion': 'bawang merah',
      'garlic': 'bawang putih',
      'ginger': 'jahe',
      'chili': 'cabai',
      'coconut': 'kelapa',
      'peanut': 'kacang tanah',
      'tofu': 'tahu',
      'tempeh': 'tempe',
      'lettuce': 'selada',
      'cabbage': 'kubis',
      'spinach': 'bayam',
      'corn': 'jagung',
      'mushroom': 'jamur',
      'shrimp': 'udang',
      'crab': 'kepiting',
      'squid': 'cumi-cumi',
      'pork': 'daging babi',
      'lamb': 'daging kambing',
      'turkey': 'kalkun',
      'duck': 'bebek',
    };

    String translated = foodName.toLowerCase();
    for (var entry in translations.entries) {
      translated = translated.replaceAll(entry.key, entry.value);
    }

    return translated;
  }

  static String translateUnit(String unit, ResponseLanguage language) {
    if (language == ResponseLanguage.english) return unit;

    final translations = {
      'gram': 'gram',
      'grams': 'gram',
      'g': 'g',
      'kilogram': 'kilogram',
      'kg': 'kg',
      'piece': 'buah',
      'pieces': 'buah',
      'pcs': 'buah',
      'cup': 'gelas',
      'cups': 'gelas',
      'bowl': 'mangkuk',
      'bowls': 'mangkuk',
      'plate': 'piring',
      'plates': 'piring',
      'tablespoon': 'sendok makan',
      'tablespoons': 'sendok makan',
      'tbsp': 'sdm',
      'teaspoon': 'sendok teh',
      'teaspoons': 'sendok teh',
      'tsp': 'sdt',
      'liter': 'liter',
      'liters': 'liter',
      'l': 'l',
      'milliliter': 'mililiter',
      'ml': 'ml',
      'ounce': 'ons',
      'ounces': 'ons',
      'oz': 'ons',
      'pound': 'pon',
      'pounds': 'pon',
      'lb': 'pon',
      'slice': 'potong',
      'slices': 'potong',
      'can': 'kaleng',
      'cans': 'kaleng',
      'bottle': 'botol',
      'bottles': 'botol',
      'glass': 'gelas',
      'glasses': 'gelas',
    };

    String translated = unit.toLowerCase();
    for (var entry in translations.entries) {
      if (translated == entry.key) {
        return entry.value;
      }
    }

    return unit;
  }

  static String translateMealType(String mealType, ResponseLanguage language) {
    if (language == ResponseLanguage.english) return mealType;

    final translations = {
      'breakfast': 'Sarapan',
      'lunch': 'Makan Siang',
      'dinner': 'Makan Malam',
      'snack': 'Camilan',
    };

    return translations[mealType.toLowerCase()] ?? mealType;
  }

  static String translateComment(String comment, ResponseLanguage language) {
    if (language == ResponseLanguage.english) return comment;

    // Basic comment phrase translations
    final translations = {
      'good source of protein': 'sumber protein yang baik',
      'high in fiber': 'tinggi serat',
      'low in calories': 'rendah kalori',
      'rich in vitamins': 'kaya vitamin',
      'healthy choice': 'pilihan sehat',
      'balanced meal': 'makanan seimbang',
      'good for muscle building': 'baik untuk pembentukan otot',
      'heart healthy': 'baik untuk jantung',
      'high in antioxidants': 'tinggi antioksidan',
      'good for digestion': 'baik untuk pencernaan',
      'energy booster': 'penambah energi',
      'weight loss friendly': 'ramah untuk diet',
      'nutrient dense': 'padat nutrisi',
      'wholesome food': 'makanan bergizi',
      'natural ingredients': 'bahan alami',
    };

    String translated = comment.toLowerCase();
    for (var entry in translations.entries) {
      translated = translated.replaceAll(entry.key, entry.value);
    }

    return translated;
  }
}
