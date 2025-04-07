class UserModel {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String state;
  final String city;
  final String farmSize;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    required this.state,
    required this.city,
    required this.farmSize,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      state: data['state'] ?? '',
      city: data['city'] ?? '',
      farmSize: data['farmSize'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'state': state,
      'city': city,
      'farmSize': farmSize,
    };
  }
}