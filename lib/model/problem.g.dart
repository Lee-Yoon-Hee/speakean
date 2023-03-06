// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'problem.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Problem _$ProblemFromJson(Map<String, dynamic> json) => Problem(
      json['id'] as int,
      json['theme'] as String,
      json['sentence'] as String,
      (json['diagnosis'] as List<dynamic>)
          .map((e) => Diagnosis.fromJson(e))
          .toList(),
    );

Diagnosis _$DiagnosisFromJson(Map<String, dynamic> json) => Diagnosis(
      json['start'] as int,
      json['end'] as int,
      json['pronunciation'] as String,
      (json['treatments'] as List<dynamic>)
          .map((e) => Treatment.fromJson(e))
          .toList(),
    );

Treatment _$TreatmentFromJson(Map<String, dynamic> json) => Treatment(
      json['sentence'] as String,
      json['pronunciation'] as String,
    );
