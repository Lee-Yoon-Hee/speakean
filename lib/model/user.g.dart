// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      json['name'] as String?,
      json['socialId'] as String,
      json['socialType'] as String,
      (json['enableProblemIds'] as List<dynamic>).map((e) => e as int).toList(),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'name': instance.name,
      'socialId': instance.socialId,
      'socialType': instance.socialType,
      'enableProblemIds': instance.enableProblemIds,
    };
