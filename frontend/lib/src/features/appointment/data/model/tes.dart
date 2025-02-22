import 'package:denta_koas/src/features/appointment/data/model/review_model.dart';
import 'package:denta_koas/src/features/personalization/model/user_model.dart';

class Post {
  final String id;
  final String userId;
  final String koasId;
  final String treatmentId;
  final String title;
  final String desc;
  final List<String>? postImages;
  final List<String> patientRequirement;
  final int requiredParticipant;
  final String status;
  final bool published;
  final DateTime createdAt;
  final DateTime updateAt;
  final List<Schedule> schedule;
  final UserModel user;
  final Treatment treatment;
  final List<dynamic> likes;
  final int? likeCount;
  final int totalCurrentParticipants;
  final List<ReviewModel>? reviews;


  Post({
    required this.id,
    required this.userId,
    required this.koasId,
    required this.treatmentId,
    required this.title,
    required this.desc,
    this.postImages,
    required this.patientRequirement,
    required this.requiredParticipant,
    required this.status,
    required this.published,
    required this.createdAt,
    required this.updateAt,
    required this.schedule,
    required this.user,
    required this.treatment,
    required this.likes,
    this.likeCount,
    this.totalCurrentParticipants = 0,
    this.reviews,
  });


  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      koasId: json['koasId'] ?? '',
      treatmentId: json['treatmentId'] ?? '',
      title: json['title'] ?? '',
      desc: json['desc'] ?? '',
      postImages: json['images'] is List
          ? (json['images'] as List).map((item) => item.toString()).toList()
          : [],
      patientRequirement: (json['patientRequirement'] as List?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
      requiredParticipant: json['requiredParticipant'] ?? 0,
      status: json['status'] ?? '',
      published: json['published'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updateAt: DateTime.tryParse(json['updateAt'] ?? '') ?? DateTime.now(),
      schedule: (json['Schedule'] != null)
          ? (json['Schedule'] as List)
              .map((item) => Schedule.fromJson(item))
              .toList()
          : [],
      user: UserModel.fromJson(json['user'] ?? {}),
      treatment: Treatment.fromJson(json['treatment'] ?? {}),
      likes: json['likes'] is List ? json['likes'] : [],
      likeCount: json['likeCount'] ?? 0,
      totalCurrentParticipants: json['totalCurrentParticipants'] ?? 0,
      reviews: (json['Review'] as List?)
              ?.map((item) => ReviewModel.fromJson(item))
              .toList() ??
          [],
    );
  }

  factory Post.empty() {
    return Post(
      id: '',
      userId: '',
      koasId: '',
      treatmentId: '',
      title: '',
      desc: '',
      patientRequirement: [],
      requiredParticipant: 0,
      status: '',
      published: false,
      createdAt: DateTime.now(),
      updateAt: DateTime.now(),
      schedule: [],
      user: UserModel.empty(),
      treatment: Treatment.empty(),
      likes: [],
      likeCount: 0,
      totalCurrentParticipants: 0,
      reviews: [],
    );
  }

  static Post postFromJson(Map<String, dynamic> json) {
    return Post.fromJson(json);
  }

  static List<Post> postsFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => Post.fromJson(json)).toList();
  }
  
}

class Schedule {
  final String id;
  final String postId;
  final DateTime dateStart;
  final DateTime dateEnd;
  final Post post;
  final List<Timeslot> timeslot;
  final DateTime createdAt;
  final DateTime updateAt;

  Schedule({
    required this.id,
    required this.postId,
    required this.dateStart,
    required this.dateEnd,
    required this.post,
    required this.timeslot,
    required this.createdAt,
    required this.updateAt,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] ?? '',
      postId: json['postId'] ?? '',
      dateStart: DateTime.parse(json['dateStart']),
      dateEnd: DateTime.parse(json['dateEnd']),
      post: Post.fromJson(json['post'] ?? {}),
      timeslot: json['timeslot'] is List
          ? (json['timeslot'] as List)
              .map((item) => Timeslot.fromJson(item))
              .toList()
          : (json['timeslot'] != null
              ? [Timeslot.fromJson(json['timeslot'])]
              : []),
      
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updateAt: DateTime.tryParse(json['updateAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class Timeslot {
  final String id;
  final String scheduleId;
  final String startTime;
  final String endTime;
  final int maxParticipants;
  final int currentParticipants;
  final bool isAvailable;

  Timeslot({
    required this.id,
    required this.scheduleId,
    required this.startTime,
    required this.endTime,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.isAvailable,
  });

  factory Timeslot.fromJson(Map<String, dynamic> json) {
    return Timeslot(
      id: json['id'] ?? '',
      scheduleId: json['scheduleId'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      maxParticipants: json['maxParticipants'] ?? 0,
      currentParticipants: json['currentParticipants'] ?? 0,
      isAvailable: json['isAvailable'] ?? false,
    );
  }
}

class User {
  final String id;
  final String givenName;
  final String familyName;
  final String name;
  final String email;
  final String phone;
  final String? address;
  final String? image;
  final String role;
  final Koas koasProfile;

  User({
    required this.id,
    required this.givenName,
    required this.familyName,
    required this.name,
    required this.email,
    required this.phone,
    this.address,
    this.image,
    required this.role,
    required this.koasProfile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      givenName: json['givenName'] ?? '',
      familyName: json['familyName'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'],
      image: json['image'],
      role: json['role'] ?? '',
      koasProfile: Koas.fromJson(json['KoasProfile'] ?? {}),
    );
  }
}

class Koas {
  final String id;
  final String userId;
  final String koasNumber;
  final String age;
  final String gender;
  final String departement;
  final String university;
  final String bio;
  final String whatsappLink;
  final String status;

  Koas({
    required this.id,
    required this.userId,
    required this.koasNumber,
    required this.age,
    required this.gender,
    required this.departement,
    required this.university,
    required this.bio,
    required this.whatsappLink,
    required this.status,
  });

  factory Koas.fromJson(Map<String, dynamic> json) {
    return Koas(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      koasNumber: json['koasNumber'] ?? '',
      age: json['age'] ?? '',
      gender: json['gender'] ?? '',
      departement: json['departement'] ?? '',
      university: json['university'] ?? '',
      bio: json['bio'] ?? '',
      whatsappLink: json['whatsappLink'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

class Treatment {
  final String id;
  final String name;
  final String alias;

  Treatment({
    required this.id,
    required this.name,
    required this.alias,
  });

  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      alias: json['alias'] ?? '',
    );
  }

  factory Treatment.empty() {
    return Treatment(
      id: '',
      name: '',
      alias: '',
    );
  }
}
