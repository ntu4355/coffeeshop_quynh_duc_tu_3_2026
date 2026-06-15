import 'package:cloud_firestore/cloud_firestore.dart'; // thêm dòng này

class UserModel {
  String? uid;
  String? fullName;
  String? username;
  String? email;
  String? address;
  DateTime? createdAt;

  UserModel({
    this.uid,
    this.fullName,
    this.username,
    this.email,
    this.address,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'username': username,
      'e-mail': email,
      'address': address,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, {String? uid}) {
    // Xử lý createdAt có thể là Timestamp hoặc String
    DateTime? createdAt;
    final raw = map['createdAt'];
    if (raw is Timestamp) {
      createdAt = raw.toDate();
    } else if (raw is String) {
      createdAt = DateTime.tryParse(raw);
    }

    return UserModel(
      uid: uid,
      fullName: map['fullName'] as String?,
      username: map['username'] as String?,
      email: map['e-mail'] as String?,
      address: map['address'] as String?,
      createdAt: createdAt,
    );
  }
}
