import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';


enum School {
  @JsonValue("ELEMENTARY")
  elementary("초등학교"),
  @JsonValue("MIDDLE")
  middle("중학교"),
  @JsonValue("HIGH")
  high("고등학교");

  const School(this.kor);

  final String kor;
}

@JsonSerializable()
class User {
  final String? name;
  // final School? school;
  // final int? grade;
  // @LocaleConverter()
  // final Locale? locale;
  final String socialId;
  final String socialType;
  final List<int> enableProblemIds;

  User(this.name, this.socialId, this.socialType, this.enableProblemIds);

  factory User.fromJson(dynamic json) => _$UserFromJson(json);
  Map toJson() => _$UserToJson(this);
}

class LocaleConverter extends JsonConverter<Locale, String> {

  const LocaleConverter();

  @override
  Locale fromJson(String json) {
    final codes = json.split("_");
    return Locale(codes[0], codes[1]);
  }

  @override
  String toJson(Locale object) {
    if(object.countryCode != null) {
      return "${object.languageCode}_${object.countryCode}";
    } else {
      return "ko_KR";
    }
  }
}


class UserCubit extends Cubit<User?> {
  DocumentReference? userRef;  

  UserCubit() : super(null);
  
  Future<DocumentReference?> fetch(String socialType, String socialId) async {
    final userRef = FirebaseFirestore.instance.collection("users")
        .where("socialType", isEqualTo: socialType)
        .where("socialId", isEqualTo: socialId);

    final snapshot = await userRef.get();
    if(snapshot.size == 0) {
      return null;
    }
    
    return snapshot.docs.first.reference;
  }

  Future<void> regenerate() async {
    final doc = await userRef!.get();
    final user = User.fromJson(doc.data());
    emit(user);
  }
  
  Future<bool> isExist(String socialType, String socialId) async {
    final userRef = await fetch(socialType, socialId);
    if(userRef == null) {
      return false;
    } else {
      return true;
    }
  }

  Future<void> create(String socialType, String socialId, String? name) async {
    userRef = await FirebaseFirestore.instance.collection("users").add({
      "socialType"       : socialType,
      "socialId"         : socialId,
      "enableProblemIds" : [1],
      if(name != null) "name" : name
    });
    await regenerate();
  }
  
  // isExist로 검사해야 합니다.
  Future<void> login(String socialType, String socialId) async {
    userRef = await fetch(socialType, socialId);
    await regenerate();
  }
  
  void logout() {
    userRef = null;
    emit(null);
  }
  
  Future<void> withdrawal() async {
    logout();
    await userRef?.delete(); 
  }

  Future<void> update({String? name, List<int>? enableProblemIds}) async {
    await userRef?.update({
      if(name != null) "name" : name,
      if(enableProblemIds != null) "enableProblemIds" : enableProblemIds,
    });

    regenerate();
  }
}