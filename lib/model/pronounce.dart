import 'package:json_annotation/json_annotation.dart';

part 'pronounce.g.dart';


@JsonSerializable(createToJson: false)
class Pronounce {
  final String recognized;
  @JsonKey(required: false)
  final double? score;

  Pronounce(this.recognized, this.score);

  factory Pronounce.fromJson(dynamic json) => _$PronounceFromJson(json);
}