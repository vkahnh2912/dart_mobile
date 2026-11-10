class ApiProduct {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String brand;
  final String thumbnail;

  const ApiProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.brand,
    required this.thumbnail,
  });

  factory ApiProduct.fromJson(Map<String, dynamic> json) {
    return ApiProduct(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? 'Sản phẩm công nghệ').toString(),
      description: (json['description'] ?? '').toString(),
      category: (json['category'] ?? 'general').toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPercentage:
          (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      stock: (json['stock'] as num?)?.toInt() ?? 10,
      brand: (json['brand'] ?? 'TechBrand').toString(),
      thumbnail: (json['thumbnail'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'discountPercentage': discountPercentage,
      'rating': rating,
      'stock': stock,
      'brand': brand,
      'thumbnail': thumbnail,
    };
  }
}

class ApiArticle {
  final int id;
  final int userId;
  final String title;
  final String body;
  final List<String> tags;
  final int likes;
  final int views;

  const ApiArticle({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.tags,
    required this.likes,
    required this.views,
  });

  factory ApiArticle.fromJson(Map<String, dynamic> json) {
    final rawTags = json['tags'];
    final List<String> parsedTags = rawTags is List
        ? rawTags.map((e) => e.toString()).toList()
        : <String>['flutter', 'api', 'mobile'];

    int parsedLikes = 15;
    final reactions = json['reactions'];
    if (reactions is Map) {
      parsedLikes = (reactions['likes'] as num?)?.toInt() ?? 15;
    } else if (reactions is num) {
      parsedLikes = reactions.toInt();
    }

    return ApiArticle(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 1,
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      tags: parsedTags,
      likes: parsedLikes,
      views: (json['views'] as num?)?.toInt() ?? (parsedLikes * 12 + 40),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'tags': tags,
      'likes': likes,
      'views': views,
    };
  }
}

class ApiRemoteUser {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String username;
  final String university;
  final String companyTitle;
  final String image;

  const ApiRemoteUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.username,
    required this.university,
    required this.companyTitle,
    required this.image,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory ApiRemoteUser.fromJson(Map<String, dynamic> json) {
    String compTitle = 'Software Engineer';
    if (json['company'] is Map) {
      compTitle = (json['company']['title'] ?? 'Software Engineer').toString();
    }
    return ApiRemoteUser(
      id: (json['id'] as num?)?.toInt() ?? 0,
      firstName: (json['firstName'] ?? json['name'] ?? 'User').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      email: (json['email'] ?? 'user@example.com').toString(),
      phone: (json['phone'] ?? '').toString(),
      username: (json['username'] ?? 'user').toString(),
      university: (json['university'] ?? 'Đại học Công nghệ').toString(),
      companyTitle: compTitle,
      image: (json['image'] ?? '').toString(),
    );
  }
}

class ApiCallLog {
  final String time;
  final String method;
  final String url;
  final int statusCode;
  final int durationMs;
  final String responsePreview;
  final bool isOnline;

  const ApiCallLog({
    required this.time,
    required this.method,
    required this.url,
    required this.statusCode,
    required this.durationMs,
    required this.responsePreview,
    required this.isOnline,
  });
}

