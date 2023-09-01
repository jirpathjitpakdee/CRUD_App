// To parse this JSON data, do
//
//     final users = usersFromJson(jsonString);

import 'dart:convert';

List<Users> usersFromJson(String str) =>
    List<Users>.from(json.decode(str).map((x) => Users.fromJson(x)));

String usersToJson(List<Users> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Users {
  int? id;
  String? fullname;
  String? email;
  String? password;
  String? imgUrl;
  String? gender;

  Users({
    this.id,
    this.fullname,
    this.email,
    this.password,
    this.imgUrl,
    this.gender,
  });

  factory Users.fromJson(Map<String, dynamic> json) => Users(
        id: json["id"],
        fullname: json["fullname"],
        email: json["email"],
        password: json["password"],
        imgUrl: json["imgUrl"],
        gender: json["gender"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "fullname": fullname,
        "email": email,
        "password": password,
        "imgUrl": imgUrl,
        "gender": gender,
      };
}
