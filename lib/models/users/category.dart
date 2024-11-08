class Category {
  final String id;
  final String label;

  const Category({
    required this.id, 
    required this.label,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      label: map['label'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
    };
  }
} 