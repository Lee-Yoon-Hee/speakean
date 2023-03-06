import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'problem.g.dart';


@JsonSerializable(createToJson: false)
class Problem {
  final int id;
  final String theme;
  final String sentence;
  @JsonKey(name: "diagnosis")
  final List<Diagnosis> diagnoses;

  Problem(this.id, this.theme, this.sentence, this.diagnoses);

  factory Problem.fromJson(dynamic json) => _$ProblemFromJson(json);
}

@JsonSerializable(createToJson: false)
class Diagnosis {
  final int start;
  final int end;
  final String pronunciation;
  final List<Treatment> treatments;

  Diagnosis(this.start, this.end, this.pronunciation, this.treatments);

  factory Diagnosis.fromJson(dynamic json) => _$DiagnosisFromJson(json);
}

@JsonSerializable(createToJson: false)
class Treatment {
  final String sentence;
  final String pronunciation;

  Treatment(this.sentence, this.pronunciation);

  factory Treatment.fromJson(dynamic json) => _$TreatmentFromJson(json);
}

// riverpod 만큼 future를 우아하게 다룰 수 있는 방법이 생각나지 않습니다...
// 일단 waiting 상태를 state가 null인 경우에 대응합니다.
// update
// 객체 생성 시 future를 값으로 가집니다.
// lazy가 기본이므로 riverpod와 동일한 동작을 한다고 생각할 수 있습니다.
class ProblemsCubit extends Cubit<Future<List<Problem>>> {

  ProblemsCubit() : super(fetchProblem());

}

Future<List<Problem>> fetchProblem() async {
  final problemsRef = FirebaseFirestore.instance.collection("problems");
  final documents = (await problemsRef.get(const GetOptions(source: Source.server))).docs;

  final List<Problem> problems = [];
  for(var document in documents) {
    final problem = Problem.fromJson(document.data());
    problems.add(problem);
  }

  problems.sort((a, b) => a.id - b.id);

  return problems;
}