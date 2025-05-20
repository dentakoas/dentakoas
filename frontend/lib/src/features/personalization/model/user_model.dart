import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denta_koas/src/features/appointment/data/model/review_model.dart';
import 'package:denta_koas/src/features/personalization/model/fasilitator_profile.dart';
import 'package:denta_koas/src/features/personalization/model/koas_profile.dart';
import 'package:denta_koas/src/features/personalization/model/pasien_profile.dart';
import 'package:denta_koas/src/utils/formatters/formatter.dart';
import 'package:logger/logger.dart';

class UserModel {
  late final String? id;
  final String? givenName;
  final String? familyName;
  final String? name;
  final String? email;
  final String? gender;
  final DateTime? emailVerified;
  final String? password;
  final String? confirmPassword;
  final String? phone;
  final String? address;
  final String? image;
  final String? role;
  final KoasProfileModel? koasProfile;
  final PasienProfileModel? pasienProfile;
  final FasilitatorProfileModel? fasilitatorProfile;
  final List<ReviewModel>? review;
  final DateTime? createdAt;
  final DateTime? updateAt;

  UserModel({
    this.id,
    this.givenName,
    this.familyName,
    this.name,
    this.gender,
    this.email,
    this.emailVerified,
    this.password,
    this.confirmPassword,
    this.phone,
    this.address,
    this.image,
    this.role,
    this.koasProfile,
    this.pasienProfile,
    this.fasilitatorProfile,
    this.review,
    this.createdAt,
    this.updateAt,
  });

  // Helper to get the full name
  String get fullName => '$givenName $familyName';

  // Helper to set random the name
  String get setUsername =>
      '${givenName?.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

  // Helper function to format the phone number
  String get formattedPhoneNo => TFormatter.formatPhoneNumber(phone!);

  static List<String> nameParts(fullname) => fullname.split(' ');
  
  // Getter to get the active profile dynamically
  dynamic get profile {
    if (role == "Koas") return koasProfile;
    if (role == "Pasien") return pasienProfile;
    if (role == "Fasilitator") return fasilitatorProfile;
    return null; // No profile found
  }

  // Static function to create an empty user model
  static UserModel empty() {
    return UserModel(
      id: '',
      givenName: '',
      familyName: '',
      email: '',
      password: '',
      confirmPassword: '',
      phone: '',
      address: '',
      image: '',
      role: '',
      koasProfile: KoasProfileModel.empty(),
      pasienProfile: PasienProfileModel.empty(),
      fasilitatorProfile: FasilitatorProfileModel.empty(),
      review: [],
    );
  }

  // Convert model to JSON structure for storing data in database
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'id': id,
      'givenName': givenName,
      'familyName': familyName,
      'name': name,
      'email': email,
      'emailVerified': emailVerified,
      'password': password,
      'confirmPassword': confirmPassword,
      'phone': phone,
      'address': address,
      'image': image,
      'role': role,
    };

    switch (role) {
      case 'Koas':
        json['koasProfile'] = koasProfile?.toJson();
        break;
      case 'Pasien':
        json['pasienProfile'] = pasienProfile?.toJson();
        break;
      case 'Fasilitator':
        json['fasilitatorProfile'] = fasilitatorProfile?.toJson();
        break;
      default:
        break;
    }

    return json;
  }

  static List<UserModel> usersFromJson(dynamic data) {
    try {
      // Pastikan data adalah Map dan memiliki key "treatments".
      if (data is Map<String, dynamic> && data.containsKey("users")) {
        final users = data["users"] as List;
        return users.map((item) => UserModel.fromJson(item)).toList();
      }
    } catch (e) {
      Logger().e(e);
    }
    Logger().e('Invalid data format for users');
    throw Exception('Invalid data format for users');
  }

  Map<String, dynamic> toJsonAuth() {
    Map<String, dynamic> json = {
      'id': id,
      'givenName': givenName,
      'familyName': familyName,
      'name': name,
      'gender': gender,
      'email': email,
      'phone': phone,
      'image': image,
      'role': role,
    };

    // switch (role) {
    //   case 'Koas':
    //     json['koasProfile'] = koasProfile?.toJson();
    //     break;
    //   case 'Pasien':
    //     json['pasienProfile'] = pasienProfile?.toJson();
    //     break;
    //   case 'Fasilitator':
    //     json['fasilitatorProfile'] = fasilitatorProfile?.toJson();
    //     break;
    //   default:
    //     break;
    // }

    return json;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      givenName: json['givenName'] ?? '', // Default to empty string if null
      familyName: json['familyName'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      emailVerified: json['emailVerified'] != null
          ? DateTime.tryParse(json['emailVerified'])
          : null,
      password: json['password'] ?? '',
      confirmPassword: json['confirmPassword'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      image: json['image'],
      role: json['role'] ?? '',
      koasProfile: json['KoasProfile'] != null
          ? KoasProfileModel.fromJson(json['KoasProfile'])
          : KoasProfileModel.empty(),
      pasienProfile: json['PasienProfile'] != null
          ? PasienProfileModel.fromJson(json['PasienProfile'])
          : PasienProfileModel.empty(),
      fasilitatorProfile: json['FasilitatorProfile'] != null
          ? FasilitatorProfileModel.fromJson(json['FasilitatorProfile'])
          : FasilitatorProfileModel.empty(),
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

  factory UserModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data();

      return UserModel(
        id: document.id,
        givenName: data!['givenName'] ?? '',
        familyName: data['familyName'] ?? '',
        name: data['name'] ?? '',
        gender: data['gender'] ?? '',
        email: data['email'] ?? '',
        emailVerified:
            data['emailVerified'] != null && data['emailVerified'] is String
                ? DateTime.tryParse(
                    data['emailVerified']) // Safely parse only if it's a string
                : null,
        password: data['password'] ?? '',
        address: data['address'] ?? '',
        phone: data['phone'] ?? '',
        image: data['image'] ?? '',
        role: data['role'] ?? '',
      );
    } else {
      return UserModel.empty();
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'givenName': givenName,
      'familyName': familyName,
      'email': email,
      'emailVerified': emailVerified,
      'password': password,
      'confirmPassword': confirmPassword,
      'phone': phone,
      'address': address,
      'image': image,
      'role': role,
      'koasProfile': koasProfile?.toJson(),
      'pasienProfile': pasienProfile?.toJson(),
    };
  }
}

// class StatusKoas {
//   static const String rejected = 'Rejected';
//   static const String pending = 'Pending';
//   static const String approved = 'Approved';

//   final String value;

//   const StatusKoas._(this.value);

//   static const List<StatusKoas> values = [
//     StatusKoas._(rejected),
//     StatusKoas._(pending),
//     StatusKoas._(approved),
//   ];

//   static StatusKoas fromString(String status) {
//     return values.firstWhere((element) => element.value == status,
//         orElse: () => throw Exception('Invalid status'));
//   }
// }



Map<String, dynamic> filterProfileByRole(Map<String, dynamic> data) {
  // Safely extract role with null check
  String role = data['role'] ?? '';
  Map<String, dynamic> filteredProfile = {};

  try {
    switch (role) {
      case 'Fasilitator':
        // Handle case when fasilitatorProfile is a string (JSON) or already a Map
        if (data['fasilitatorProfile'] != null) {
          if (data['fasilitatorProfile'] is String) {
            try {
              filteredProfile = {
                'fasilitatorProfile': jsonDecode(data['fasilitatorProfile']),
              };
            } catch (e) {
              Logger().e("Error decoding fasilitatorProfile: $e");
              filteredProfile = {'fasilitatorProfile': null};
            }
          } else {
            filteredProfile = {
              'fasilitatorProfile': data['fasilitatorProfile']
            };
          }
        } else {
          filteredProfile = {'fasilitatorProfile': null};
        }
        break;
      case 'Koas':
        filteredProfile = {
          'koasProfile': data['koasProfile'],
        };
        break;
      case 'Pasien':
        filteredProfile = {
          'pasienProfile': data['pasienProfile'],
        };
        break;
      default:
        filteredProfile = {
          'message': 'No profile available for this role',
        };
    }

    return {
      'id': data['id'] ?? '',
      'email': data['email'] ?? '',
      'password': data['password'] ?? '',
      'role': role,
      ...filteredProfile, // Spread the filtered profile into the result
    };
  } catch (e) {
    Logger().e("Error in filterProfileByRole: $e");
    // Return a safe default in case of error
    return {
      'id': data['id'] ?? '',
      'email': data['email'] ?? '',
      'password': data['password'] ?? '',
      'role': role,
      'error': 'Failed to process profile data',
    };
  }
}

enum Role { Koas, Pasien, Fasilitator, Admin }
