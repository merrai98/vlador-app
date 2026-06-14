import 'dart:convert';

class UserModel {
  final int? uid;
  final String? userName;
  final String? login;
  final int? partnerId;
  final String? sessionId;

  UserModel({
    this.uid,
    this.userName,
    this.login,
    this.partnerId,
    this.sessionId,
  });

  UserModel copyWith({
    int? uid,
    String? userName,
    String? login,
    int? partnerId,
    String? sessionId,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      userName: userName ?? this.userName,
      login: login ?? this.login,
      partnerId: partnerId ?? this.partnerId,
      sessionId: sessionId ?? this.sessionId,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      userName: json['user_name'],
      login: json['login'],
      partnerId: json['partner_id'],
      sessionId: json['session_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'user_name': userName,
      'login': login,
      'partner_id': partnerId,
      'session_id': sessionId,
    };
  }

  String toRawJson() => json.encode(toJson());

  factory UserModel.fromRawJson(String str) => UserModel.fromJson(json.decode(str));
}
