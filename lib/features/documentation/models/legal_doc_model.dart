class LegalDocModel {
  final String title;        // Document title
  final String url;          // Download / web URL
  final String category;     // legal_notice | agreement | attorney
  final String? description;
  final DateTime? createdAt;

  const LegalDocModel({
    required this.title,
    required this.url,
    required this.category,
    this.description,
    this.createdAt,
  });

  // ================= FROM MAP =================
  factory LegalDocModel.fromMap(Map<String, dynamic> map) {
    return LegalDocModel(
      title: map['title'] ?? '',
      url: map['url'] ?? '',
      category: map['category'] ?? '',
      description: map['description'],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'])
          : null,
    );
  }

  // ================= TO MAP =================
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'url': url,
      'category': category,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
