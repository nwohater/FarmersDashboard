class GameData {
  final String time;
  final GameDate date;
  final Weather weather;
  final List<Farm> farms;
  final List<Field> fields;
  final List<SpecialOffer> specialOffers;
  final Metadata metadata;

  GameData({
    required this.time,
    required this.date,
    required this.weather,
    required this.farms,
    required this.fields,
    required this.specialOffers,
    required this.metadata,
  });

  factory GameData.fromJson(Map<String, dynamic> json) => GameData(
    time: json['time'],
    date: GameDate.fromJson(json['date']),
    weather: Weather.fromJson(json['weather']),
    farms: List<Farm>.from(json['farms'].map((x) => Farm.fromJson(x))),
    fields: List<Field>.from(json['fields'].map((x) => Field.fromJson(x))),
    specialOffers: List<SpecialOffer>.from(json['specialOffers'].map((x) => SpecialOffer.fromJson(x))),
    metadata: Metadata.fromJson(json['metadata']),
  );
}

class GameDate {
  final int day;
  final int month;
  final String monthName;

  GameDate({required this.day, required this.month, required this.monthName});

  factory GameDate.fromJson(Map<String, dynamic> json) => GameDate(
    day: json['day'],
    month: json['month'],
    monthName: json['monthName'],
  );
}

class Weather {
  final String condition;
  final double temperatureF;
  final List<dynamic> forecast; // Empty in the sample

  Weather({
    required this.condition,
    required this.temperatureF,
    required this.forecast,
  });

  factory Weather.fromJson(Map<String, dynamic> json) => Weather(
    condition: json['condition'],
    temperatureF: (json['temperatureF'] ?? 0).toDouble(),
    forecast: List<dynamic>.from(json['forecast']),
  );
}

class Farm {
  final int farmId;
  final String name;
  final double money;
  final double? loan;
  final bool isPlayerFarm;

  Farm({
    required this.farmId,
    required this.name,
    required this.money,
    this.loan,
    required this.isPlayerFarm,
  });

  factory Farm.fromJson(Map<String, dynamic> json) {
    final loanValue = json['loan']; // <--- DEFINE loanValue HERE
    return Farm(
      farmId: json['farmId'] as int,
      name: json['name'] as String,
      money: (json['money'] as num).toDouble(),
      loan: loanValue == null ? null : (loanValue as num).toDouble(), // Now loanValue is known
      isPlayerFarm: json['isPlayerFarm'] as bool,
    );
  }
}

class Field {
  final int fieldId;
  final String fruitType;
  final int growthState;
  final String growthStateLabel;
  final double fieldAreaHa;
  final int farmId;
  final String farmName;

  Field({
    required this.fieldId,
    required this.fruitType,
    required this.growthState,
    required this.growthStateLabel,
    required this.fieldAreaHa,
    required this.farmId,
    required this.farmName,
  });

  factory Field.fromJson(Map<String, dynamic> json) => Field(
    fieldId: json['fieldId'] ?? 0,
    fruitType: json['fruitType'] ?? '',
    growthState: json['growthState'] ?? 0,
    growthStateLabel: json['growthStateLabel'] ?? '',
    fieldAreaHa: (json['fieldAreaHa'] ?? 0).toDouble(),
    farmId: json['farmId'] ?? 0,
    farmName: json['farmName'] ?? '',
  );
}
class SpecialOffer {
  final String brand;
  final String name;
  final double price;
  final double originalPrice;
  final int percentOff;
  final int age;
  final String? type; // ✅ Allow `type` to be nullable

  SpecialOffer({
    required this.brand,
    required this.name,
    required this.price,
    required this.originalPrice,
    required this.percentOff,
    required this.age,
    this.type, // ✅ Allow it to be optional
  });

  factory SpecialOffer.fromJson(Map<String, dynamic> json) => SpecialOffer(
    brand: json['brand'],
    name: json['name'],
    price: (json['price'] as num).toDouble(),
    originalPrice: (json['originalPrice'] as num).toDouble(),
    percentOff: json['percentOff'],
    age: json['age'],
    type: json['type'], // ✅ Parse directly (could be null)
  );
}


class Metadata {
  final String generatedBy;
  final String version;
  final String updatedAt;

  Metadata({
    required this.generatedBy,
    required this.version,
    required this.updatedAt,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
    generatedBy: json['generatedBy'],
    version: json['version'],
    updatedAt: json['updatedAt'],
  );
}
