class UserModel {
  final String uid;
  final String name;
  final String email;
  final List<String> healthConditions;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.healthConditions,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'name': name,
    'email': email,
    'healthConditions': healthConditions,
    'createdAt': createdAt.toIso8601String(),
  };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    uid: map['uid'],
    name: map['name'],
    email: map['email'],
    healthConditions: List<String>.from(map['healthConditions'] ?? []),
    createdAt: DateTime.parse(map['createdAt']),
  );
}