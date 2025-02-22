import 'package:denta_koas/src/features/appointment/data/model/tes.dart';
import 'package:denta_koas/src/features/personalization/model/koas_profile.dart';
import 'package:denta_koas/src/features/personalization/model/pasien_profile.dart';

class AppointmentsModel {
  final String? id;
  final String? pasienId;
  final String? koasId;
  final String? scheduleId;
  final String? timeslotId;
  final String? date;
  final StatusAppointment? status;
  final PasienProfileModel? pasien;
  final KoasProfileModel? koas;
  final Schedule? schedule;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AppointmentsModel({
    this.id,
    this.pasienId,
    this.koasId,
    this.scheduleId,
    this.timeslotId,
    this.date,
    this.status,
    this.pasien,
    this.koas,
    this.schedule,
    this.createdAt,
    this.updatedAt,
  });

  static StatusAppointment? parseStatusAppointment(String? status) {
    if (status == null) return null;
    return StatusAppointment.values.firstWhere(
      (e) => e.toString().split('.').last.toLowerCase() == status.toLowerCase(),
      orElse: () => StatusAppointment.Pending, // Default jika tidak cocok
    );
  }


factory AppointmentsModel.fromJson(Map<String, dynamic> json) {
    return AppointmentsModel(
      id: json['id'] ?? '',
      pasienId: json['pasienId'] ?? '',
      koasId: json['koasId'] ?? '',
      scheduleId: json['scheduleId'] ?? '',
      timeslotId: json['timeslotId'] ?? '',
      date: json['date'] ?? '',
      status: parseStatusAppointment(json['status']),
      pasien: json['pasien'] != null
          ? PasienProfileModel.fromJson(json['pasien'])
          : null,
      koas:
          json['koas'] != null ? KoasProfileModel.fromJson(json['koas']) : null,
      schedule:
          json['schedule'] != null ? Schedule.fromJson(json['schedule']) : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pasienId': pasienId,
      'koasId': koasId,
      'scheduleId': scheduleId,
      'timeslotId': timeslotId,
      'date': date,
      'status': status?.toString().split('.').last,
    };
  }

  static AppointmentsModel empty() {
    return AppointmentsModel(
      id: '',
      pasienId: '',
      koasId: '',
      scheduleId: '',
      timeslotId: '',
      date: DateTime.now().toIso8601String(),
      status: StatusAppointment.Pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }


static List<AppointmentsModel> appointmentsFromJson(dynamic json) {
    if (json is! List) {
      throw FormatException('Expected a List, but got: ${json.runtimeType}');
    }
    return List<AppointmentsModel>.from(
      json.map((data) => AppointmentsModel.fromJson(data)),
    );
}



  
}

enum StatusAppointment {
  Canceled,
  Rejected,
  Pending,
  Confirmed,
  Ongoing,
  Completed
}
