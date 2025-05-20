import 'package:denta_koas/src/features/appointment/data/model/review_model.dart';
import 'package:denta_koas/src/features/personalization/model/stats_model.dart';
import 'package:denta_koas/src/features/personalization/model/user_model.dart';

enum StatusKoas {
  Pending,
  Approved,
  Rejected,
}

class KoasProfileModel {
  final String? id;
  final String? koasNumber;
  final String? age;
  final String? gender;
  final String? departement;
  final String? university;
  final int? experience;
  final String? bio;
  final String? whatsappLink;
  final String? status;
  final Stats? stats;
  final UserModel? user;
  final List<ReviewModel>? review;
  final DateTime? createdAt;
  final DateTime? updateAt;


  KoasProfileModel({
    this.id,
    this.koasNumber,
    this.age,
    this.gender,
    this.departement,
    this.university,
    this.experience,
    this.bio,
    this.whatsappLink,
    this.status,
    this.stats,
    this.user,
    this.review,
    this.createdAt,
    this.updateAt,
  });

  // Static function to create an empty user model
  static KoasProfileModel empty() {
    return KoasProfileModel(
      id: '',
      koasNumber: '',
      age: '',
      gender: '',
      departement: '',
      university: '',
      bio: '',
      whatsappLink: '',
      status: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'koasNumber': koasNumber,
      'age': age,
      'gender': gender,
      'departement': departement,
      'university': university,
      'experience': experience,
      'bio': bio,
      'whatsappLink': whatsappLink,
      'status': status ?? 'Pending',
    };
  }

  factory KoasProfileModel.fromJson(Map<String, dynamic> json) {
    return KoasProfileModel(
      id: json['id'] ?? '',
      koasNumber: json['koasNumber'] ?? '',
      age: json['age'] ?? '',
      gender: json['gender'] ?? '',
      departement: json['departement'] ?? '',
      university: json['university'] ?? '',
      experience: json['experience'] ?? 0,
      bio: json['bio'] ?? '',
      whatsappLink: json['whatsappLink'] ?? '',
      status: json['status'] ?? 'Pending',
      stats: json['stats'] != null ? Stats.fromJson(json['stats']) : null,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      review: json['Review'] != null
          ? List<ReviewModel>.from(json['Review'].map((x) => ReviewModel.fromJson(x)))
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updateAt:
          json['updateAt'] != null ? DateTime.tryParse(json['updateAt']) : null,
    );
  }

  /// Mendapatkan tahun masuk dari NIM
  /// Contoh: 231611101055 -> 2023
  String getTahunMasuk() {
    return '20${koasNumber!.substring(0, 2)}';
  }

  /// Mendapatkan kode fakultas dari NIM
  /// Contoh: 231611101055 -> 16
  String getKodeFakultas() {
    return koasNumber!.substring(2, 4);
  }

  /// Mendapatkan kode jurusan dari NIM
  /// Contoh: 231611101055 -> 11
  String getKodeJurusan() {
    return koasNumber!.substring(4, 6);
  }

  /// Mendapatkan nomor identitas dari NIM
  /// Contoh: 231611101055 -> 101055
  String getNomorIdentitas() {
    return koasNumber!.substring(6);
  }

  /// Menampilkan informasi lengkap NIM
  Map<String, String> getInfoLengkap() {
    return {
      'koasNumber': koasNumber!,
      'tahunMasuk': getTahunMasuk(),
      'kodeFakultas': getKodeFakultas(),
      'kodeJurusan': getKodeJurusan(),
      'nomorIdentitas': getNomorIdentitas(),
    };
  }
}
