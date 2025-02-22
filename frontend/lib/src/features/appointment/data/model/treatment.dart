class TreatmentModel {
  final String? id;
  final String? name;
  final String? alias;
  final String? description;
  final String? image;

  TreatmentModel({
    this.id,
    this.name,
    this.alias,
    this.description,
    this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'alias': alias,
      'image': image,
    };
  }

  factory TreatmentModel.fromJson(Map<String, dynamic> json) {
    return TreatmentModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      alias: json['alias'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
    );
  }

  factory TreatmentModel.fromMap(Map<String, dynamic> map) {
    return TreatmentModel(
      name: map['name'] ?? '',
      alias: map['alias'] ?? '',
      image: map['image'] ?? '',
      
    );
  }

  TreatmentModel copyWith({
    String? name,
    String? alias,
    String? image
  }) {
    return TreatmentModel(
      name: name ?? this.name,
      alias: alias ?? this.alias,
      image: image ?? this.image,
    );
  }

  static TreatmentModel empty() {
    return TreatmentModel(
      name: '',
      alias: '',
      image: '',
    );
  }

  static List<TreatmentModel> treatmentsFromJson(dynamic data) {
    // Pastikan data adalah Map dan memiliki key "treatments".
    if (data is Map<String, dynamic> && data.containsKey("treatments")) {
      final treatments = data["treatments"] as List;
      return treatments.map((item) => TreatmentModel.fromJson(item)).toList();
    }
    throw Exception('Invalid data format for treatments');
  }
}
