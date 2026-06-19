class HaditsBook {
  final String id; // slug: 'bukhari', 'muslim', dll
  final String name; // display name: 'Bukhari', 'Muslim'
  final int totalHadith;

  HaditsBook({required this.id, required this.name, required this.totalHadith});

  factory HaditsBook.fromJson(Map<String, dynamic> json) {
    return HaditsBook(
      id: json['slug'] ?? '',
      name: json['name'] ?? '',
      totalHadith: json['total'] ?? 0,
    );
  }
}

class HaditsItem {
  final String number;
  final String id; // unique identifier: '{slug}-{number}'
  final String arab;
  final String translatedId;

  HaditsItem({
    required this.number,
    required this.id,
    required this.arab,
    required this.translatedId,
  });

  factory HaditsItem.fromJson(
    Map<String, dynamic> json, {
    String bookSlug = '',
  }) {
    final number = json['number']?.toString() ?? '';
    return HaditsItem(
      number: number,
      id: '$bookSlug-$number',
      arab: json['arab'] ?? '',
      translatedId: json['id'] ?? '',
    );
  }
}

class HaditsBookmark {
  final String bookId;
  final String bookName;
  final String hadithNumber;
  final String hadithText;
  final DateTime createdAt;

  HaditsBookmark({
    required this.bookId,
    required this.bookName,
    required this.hadithNumber,
    required this.hadithText,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'bookId': bookId,
    'bookName': bookName,
    'hadithNumber': hadithNumber,
    'hadithText': hadithText,
    'createdAt': createdAt.toIso8601String(),
  };

  factory HaditsBookmark.fromJson(Map<String, dynamic> json) {
    return HaditsBookmark(
      bookId: json['bookId'] ?? '',
      bookName: json['bookName'] ?? '',
      hadithNumber: json['hadithNumber'] ?? '',
      hadithText: json['hadithText'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}

class HaditsSettings {
  bool showTranslation;
  bool showArabic;
  String fontSize;
  bool autoScroll;

  HaditsSettings({
    this.showTranslation = true,
    this.showArabic = true,
    this.fontSize = 'medium',
    this.autoScroll = false,
  });

  Map<String, dynamic> toJson() => {
    'showTranslation': showTranslation,
    'showArabic': showArabic,
    'fontSize': fontSize,
    'autoScroll': autoScroll,
  };

  factory HaditsSettings.fromJson(Map<String, dynamic> json) {
    return HaditsSettings(
      showTranslation: json['showTranslation'] ?? true,
      showArabic: json['showArabic'] ?? true,
      fontSize: json['fontSize'] ?? 'medium',
      autoScroll: json['autoScroll'] ?? false,
    );
  }
}
