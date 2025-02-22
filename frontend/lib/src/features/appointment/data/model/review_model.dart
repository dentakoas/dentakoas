import 'package:denta_koas/src/features/personalization/model/user_model.dart';

class ReviewModel {
  String? id;
  String postId;
  String pasienId;
  String koasId;
  double rating; // Scale 1-5
  UserModel? user;
  String? comment;
  DateTime? createdAt;

  ReviewModel({
    this.id,
    required this.postId,
    required this.pasienId,
    required this.koasId,
    this.user,
    this.rating = 0.0,
    this.comment,
    this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? '',
      postId: json['postId'] ?? '',
      pasienId: json['pasienId'] ?? '',
      koasId: json['koasId'] ?? '',
      rating: json['rating'] is String
          ? double.parse(json['rating'])
          : json['rating'] ?? 0.0,
      comment: json['comment'] ?? '',
      user: json['user'] != null
          ? UserModel.fromJson(json['user'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'pasienId': pasienId,
      'koasId': koasId,
      'rating': rating,
      'comment': comment,
      'user': user?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  static ReviewModel empty() {
    return ReviewModel(
      id: '',
      postId: '',
      pasienId: '',
      koasId: '',
      rating: 0,
      comment: null,
      createdAt: DateTime.now(),
    );
  }

  static ReviewModel reviewFromJson(Map<String, dynamic> json) {
    return ReviewModel.fromJson(json);
  }

  
}
