class DoaItem {
  final String id;
  final String title;
  final String arabic;
  final String latin;
  final String translation;
  final String source;
  final String categoryId;
  final String categoryTitle;
  final String? subTabId;
  final int? order;

  DoaItem({
    required this.id,
    required this.title,
    required this.arabic,
    required this.latin,
    required this.translation,
    this.source = '',
    required this.categoryId,
    required this.categoryTitle,
    this.subTabId,
    this.order,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'arabic': arabic,
    'latin': latin,
    'translation': translation,
    'source': source,
    'categoryId': categoryId,
    'categoryTitle': categoryTitle,
    'subTabId': subTabId,
    'order': order,
  };

  factory DoaItem.fromJson(Map<String, dynamic> json) {
    return DoaItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      arabic: json['arabic'] ?? '',
      latin: json['latin'] ?? '',
      translation: json['translation'] ?? '',
      source: json['source'] ?? '',
      categoryId: json['categoryId'] ?? '',
      categoryTitle: json['categoryTitle'] ?? '',
      subTabId: json['subTabId'],
      order: json['order'],
    );
  }
}

class DoaCategory {
  final String id;
  final String title;
  final String emoji;
  final List<DoaItem> doas;
  final List<DoaTab>? tabs;
  final bool hasTabs;
  final bool isApi;
  final String? api;
  final bool isCustom;

  DoaCategory({
    required this.id,
    required this.title,
    this.emoji = '🤲',
    this.doas = const [],
    this.tabs,
    this.hasTabs = false,
    this.isApi = false,
    this.api,
    this.isCustom = false,
  });
}

class DoaTab {
  final String id;
  final String label;
  final List<DoaItem> doas;

  DoaTab({required this.id, required this.label, this.doas = const []});
}

class AsmaulHusna {
  final int number;
  final String arabic;
  final String latin;
  final String meaning;

  AsmaulHusna({
    required this.number,
    required this.arabic,
    required this.latin,
    required this.meaning,
  });
}
