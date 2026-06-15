class BookingModel {
  final String id;
  final String name;
  final String image;
  final String specialization;

  BookingModel({
    required this.id,
    required this.name,
    required this.image,
    this.specialization = "General Doctor",
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? 'Unknown Doctor',
      image: json['image'] ?? json['photo'] ?? '',
      specialization: json['specialization'] ?? 'General Doctor',
    );
  }
}