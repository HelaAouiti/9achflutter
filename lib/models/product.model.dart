// lib/models/product.model.dart

class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final double rating;
  final int ratingCount;

  // Champs locaux (pas dans l'API)
  bool isFavorite;
  List<String> comments;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.rating,
    required this.ratingCount,
    this.isFavorite = false,
    this.comments = const [],
  });

  // Pour l'API FakeStoreAPI
  factory Product.fromJson(Map<String, dynamic> json) {
    final ratingMap = json['rating'] as Map<String, dynamic>? ?? {};
    return Product(
      id: json['id'] as int,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String,
      category: json['category'] as String,
      image: json['image'] as String,
      rating: (ratingMap['rate'] as num?)?.toDouble() ?? 0.0,
      ratingCount: (ratingMap['count'] as num?)?.toInt() ?? 0,
      isFavorite: false,
      comments: const [],
    );
  }

  // Pour Hive : sauvegarde complète de l'objet
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'category': category,
      'image': image,
      'rating': rating,
      'ratingCount': ratingCount,
      'isFavorite': isFavorite,
      'comments': comments,
    };
  }

  // Pour recréer depuis Hive
  factory Product.fromJsonLocal(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String,
      category: json['category'] as String,
      image: json['image'] as String,
      rating: (json['rating'] as num).toDouble(),
      ratingCount: json['ratingCount'] as int,
      isFavorite: json['isFavorite'] as bool? ?? false,
      comments: List<String>.from(json['comments'] as List? ?? []),
    );
  }

  Product copyWith({
    bool? isFavorite,
    List<String>? comments,
  }) {
    return Product(
      id: id,
      title: title,
      price: price,
      description: description,
      category: category,
      image: image,
      rating: rating,
      ratingCount: ratingCount,
      isFavorite: isFavorite ?? this.isFavorite,
      comments: comments ?? this.comments,
    );
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is Product && id == other.id;

  @override
  int get hashCode => id.hashCode;
}