import 'package:denta_koas/src/features/appointment/data/model/likes_model.dart';
import 'package:denta_koas/src/features/appointment/data/model/review_model.dart';
import 'package:denta_koas/src/features/appointment/data/model/schedules_model.dart';
import 'package:denta_koas/src/features/appointment/data/model/treatment.dart';
import 'package:denta_koas/src/features/personalization/model/koas_profile.dart';
import 'package:denta_koas/src/features/personalization/model/user_model.dart';

class PostModel {
  String? id;
  String? userId;
  UserModel? user;
  String? koasId;
  KoasProfileModel? koasProfile;
  String? treatmentId;
  TreatmentModel? treatment;
  String? title;
  String? desc;
  List<String>? images;
  dynamic patientRequirement; // json type can be dynamic
  int? requiredParticipant;
  StatusPost? status;
  bool? published;
  List<SchedulesModel>? schedule;
  SchedulesModel? scheduleDetail;
  List<ReviewModel>? review;
  List<LikesModel>? likes;
  DateTime? createdAt;
  DateTime? updatedAt;

  PostModel({
    this.id,
    this.userId,
    this.koasId,
    this.user,
    this.koasProfile,
    this.treatmentId,
    this.treatment,
    this.title,
    this.desc,
    this.images,
    this.patientRequirement,
    this.requiredParticipant = 0,
    this.status = StatusPost.Pending,
    this.published = false,
    this.schedule,
    this.scheduleDetail,
    this.review,
    this.likes,
    this.createdAt,
    this.updatedAt,
  });

  factory PostModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw Exception('Invalid JSON data');
    }

    final data = json['post'] ?? json; // Ambil data dari 'post' jika ada.
    return PostModel(
      id: data['id'],
      userId: data['userId'],
      koasId: data['koasId'],
      treatmentId: data['treatmentId'],
      user: data['user'] != null ? UserModel.fromJson(data['user']) : null,
      koasProfile:
          data['koas'] != null ? KoasProfileModel.fromJson(data['koas']) : null,
      treatment: data['treatment'] != null
          ? TreatmentModel.fromJson(data['treatment'])
          : null,
      title: data['title'],
      desc: data['desc'],
      images: data['images'] != null && data['images'] is List
          ? List<String>.from(data['images'])
          : [],
      patientRequirement: data['patientRequirement'] != null &&
              data['patientRequirement'] is List
          ? List<String>.from(data['patientRequirement'])
          : [],
      requiredParticipant: data['requiredParticipant'],
      status: data['status'] == 'Pending'
          ? StatusPost.Pending
          : data['status'] == 'Open'
              ? StatusPost.Open
              : StatusPost.Closed,
      published: data['published'] ?? false,
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'])
          : null,
      updatedAt:
          data['updateAt'] != null ? DateTime.tryParse(data['updateAt']) : null,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'koasId': koasId,
      'treatmentId': treatmentId,
      'title': title,
      'desc': desc,
      'images': images,
      'patientRequirement': patientRequirement,
      'requiredParticipant': requiredParticipant,
      'status': status.toString().split('.').last,
      'published': published,
      'Schedule': schedule?.map((e) => e.toJson()).toList(),
      'ReviewModel': review?.map((e) => e.toJson()).toList(),
      'likes': likes?.map((e) => e.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updateAt': updatedAt?.toIso8601String(),
    };
  }

  static PostModel empty() {
    return PostModel(
      id: '',
      userId: '',
      koasId: '',
      treatmentId: '',
      treatment: TreatmentModel.empty(),
      title: '',
      desc: '',
      images: [],
      schedule: [],
      review: [],
      likes: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static List<PostModel> postsFromJson(dynamic data) {
    if (data == null) {
      throw Exception('Data is null');
    }
    // Pastikan data adalah Map dan memiliki key "posts".
    if (data is Map<String, dynamic> && data.containsKey("post")) {
      final posts = data["post"] as List;
      return posts.map((item) => PostModel.fromJson(item)).toList();
    }
    throw Exception('Invalid data format for posts');
  }
}

enum StatusPost { Pending, Open, Closed }
