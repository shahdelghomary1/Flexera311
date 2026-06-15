class MyExercisesResponse {
  String? message;
  List<ExercisePlan>? exercises;

  MyExercisesResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['exercises'] != null) {
      exercises = <ExercisePlan>[];
      json['exercises'].forEach((v) {
        exercises!.add(ExercisePlan.fromJson(v));
      });
    }
  }
}

class ExercisePlan {
  String? id;
  String? doctor;
  String? date;
  List<ExerciseItem>? exerciseItems;

  ExercisePlan({this.id, this.doctor, this.date, this.exerciseItems});

  ExercisePlan.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    doctor = json['doctor']?.toString();
    date = json['date'];

    if (json['exercises'] != null) {
      exerciseItems = <ExerciseItem>[];
      json['exercises'].forEach((v) {
        exerciseItems!.add(ExerciseItem.fromJson(v));
      });
    }
  }
}

class ExerciseItem {
  String? id;
  String? name;
  int? sets;
  int? reps;
  String? category;
  String? notes;
  bool isCompleted;
  String? image;

  ExerciseItem({
    this.id,
    this.name,
    this.sets,
    this.reps,
    this.notes,
    this.category,
    this.isCompleted = false,
    this.image,
  });

  factory ExerciseItem.fromJson(Map<String, dynamic> json) {
    return ExerciseItem(
      id: json['_id'],
      name: json['name'],
      sets: int.tryParse(json['sets']?.toString() ?? '0') ?? 0,
      reps: int.tryParse(json['reps']?.toString() ?? '0') ?? 0,
      notes: json['notes'],
      category: json['category'] ?? json['bodyPart'] ?? "General",
      isCompleted: false,
      image: json['image'],
    );
  }
}
