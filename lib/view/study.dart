import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:dio/dio.dart';
import 'package:speakean/model/user.dart';

import 'package:speakean/view/component/box.dart';
import 'package:speakean/view/component/button.dart';
import 'package:speakean/view/component/dialog.dart';
import 'package:speakean/view/component/loading.dart';
import 'package:speakean/view/component/progressbar.dart';
import 'package:speakean/view/component/scaffold.dart';

import '../constant.dart';
import '../model/problem.dart';
import '../model/pronounce.dart';
import '../path.dart';
import 'component/color.dart';


class Solve extends Cubit<List<Pronounce>> {
  int step;
  String sentence;
  String? pronunciation;

  Solve(this.step, this.sentence, [this.pronunciation]) : super([]);

  bool get isPronounced => state.isNotEmpty;

  Pronounce get currentPronounce => state.last;

  void add(Pronounce pronounce) {
    emit([ ...state, pronounce ]);
  }
}

class SolvesCubit extends Cubit<List<Solve>> {
  final Problem problem;

  SolvesCubit(this.problem) : super([ Solve(1, problem.sentence) ]);

  void add(Solve solve) {
    emit([ ...state, solve ]);
  }

  Solve get currentSolve => state.last;

}


class Study extends StatelessWidget {
  final Problem problem;
  final Record record = Record();

  Study({Key? key, required this.problem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context1) => SolvesCubit(problem),
      child: MyScaffold(
        appBar: MyAppBar(
          leading: Builder(
            builder: (context) {
              return GestureDetector(
                onTap: () {
                  PathManager.instance.pop(context);
                },
                child: const Icon(
                  Icons.arrow_back_ios,
                ),
              );
            },
          ),
          title: const Text(
            "STUDY",
            style: myAppBarTitleTextStyle,
          ),
        ),
        body: Padding(
          padding: myBodyPadding.copyWith(top: 20, bottom: 30),
          child: BlocBuilder<SolvesCubit, List<Solve>>(
            builder: (context1, solves) {
              final currentSolve = solves.last;

              return BlocBuilder<Solve, List<Pronounce>>(
                bloc: currentSolve,
                builder: (context2, pronounces) {
                  const double buttonHeight = 50;
                  const double buttonBorderRadius = 20;
                  final TextStyle buttonTextStyle = myButtonTextStyle.copyWith(color: MyColor.purple);


                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      MyProgressbar(
                        height: 40,
                        min: 0,
                        max: 3,
                        value: currentSolve.step.toDouble(),
                        barPadding: 8,
                        borderRadius: 16,
                        barGradient: const LinearGradient(
                          colors: [
                            MyColor.purple,
                            MyColor.sky,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      Text(
                        "문제 ${problem.id.toString().padLeft(2, "0")}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if(currentSolve.step == 2 && currentSolve.isPronounced) SentenceBox(
                              title: "정확한 발음",
                              sentence: currentSolve.sentence,
                            )
                            else SentenceBox(
                              sentence: currentSolve.sentence,
                            ),

                            if(currentSolve.isPronounced) Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: SentenceBox(
                                title: "나의 발음",
                                sentence: pronounces.last.recognized,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if(currentSolve.isPronounced) ...[
                            MyContainedButton(
                              width: 140,
                              height: buttonHeight,
                              borderRadius: buttonBorderRadius,
                              onPressed: () async {
                                await showRecording(context1);
                              },
                              sameWidgetOnLoading: true,
                              child: Center(
                                child: Text(
                                  "다시 말하기",
                                  style: buttonTextStyle,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            MyContainedButton(
                              width: 140,
                              height: buttonHeight,
                              borderRadius: buttonBorderRadius,
                              onPressed: () async {

                                await showDialog(
                                  context: context2,
                                  builder: (context3) {
                                    return MyDialog(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "STEP${currentSolve.step}${currentSolve.step == 1 ? "을" : "를"} 완료했어요!",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 16,
                                          ),
                                          const Text(
                                            "나의 정답률",
                                            style: TextStyle(
                                              color: MyColor.purple,
                                              fontSize: 14,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 100,
                                            height: 100,
                                            child: MyCircularProgressbar(
                                              min: 0,
                                              max: 5,
                                              value: currentSolve.currentPronounce.score ?? Random().nextDouble() * 5,
                                              backgroundColor: MyColor.sky,
                                              color: MyColor.purple,
                                              thickness: 6,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 24,
                                          ),
                                          MyContainedButton(
                                            height: 40,
                                            onPressed: () async {
                                              Navigator.of(context3, rootNavigator: true).pop();
                                            },
                                            child: const DecoratedBox(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    MyColor.purpleOnSky,
                                                    MyColor.purple,
                                                  ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  "확인",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                );

                                final solvesCubit = context2.read<SolvesCubit>();
                                final random = Random();

                                if(currentSolve.step == 1) {
                                  Diagnosis diagnosis = solvesCubit.problem.diagnoses[random.nextInt(solvesCubit.problem.diagnoses.length)];
                                  Treatment treatment = diagnosis.treatments[random.nextInt(diagnosis.treatments.length)];

                                  final solve = Solve(2, treatment.sentence, treatment.pronunciation);
                                  solvesCubit.add(solve);
                                } else if(currentSolve.step == 2) {
                                  final solve = Solve(3, solvesCubit.problem.sentence);
                                  solvesCubit.add(solve);
                                } else if(currentSolve.step == 3) {
                                  final userCubit = context.read<UserCubit>();

                                  final enableProblemIds = userCubit.state!.enableProblemIds;
                                  final addedProblemId = enableProblemIds.reduce(max) + 1;

                                  await userCubit.update(enableProblemIds: [ ...enableProblemIds, addedProblemId ]);
                                  PathManager.instance.pop(context2);
                                }
                              },
                              sameWidgetOnLoading: true,
                              child: Center(
                                child: Text(
                                  currentSolve.step == 3 ? "종료" : "다음",
                                  style: buttonTextStyle,
                                ),
                              ),
                            ),
                          ] else MyContainedButton(
                            width: 200,
                            height: buttonHeight,
                            borderRadius: buttonBorderRadius,
                            onPressed: () async {
                              await showRecording(context1);
                            },
                            sameWidgetOnLoading: true,
                            child: Center(
                              child: Text(
                                "말하기",
                                style: buttonTextStyle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
              );
            }
          ),
        ),
      ),
    );
  }

  Future<bool> startPronounce() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/voice.pcm";

    if(await record.hasPermission()) {
      await record.start(
        path: path,
        encoder: AudioEncoder.pcm16bit,
        bitRate: 128000,
        samplingRate: 16000,
      );

      return true;
    }

    return false;
  }

  Future<File?> stopPronounce() async {
    String? path = await record.stop();
    if(path == null) {
      return null;
    }
    return File(path);
  }

  Future<Pronounce> evaluatePronounce(File file, [String? script]) async {
    final dio = Dio();
    final formData = FormData.fromMap({
      "audio" : await MultipartFile.fromFile(file.path),
      if(script != null) "script" : script,
    });

    final response = await dio.post("http://49.50.165.101:8080/api/pronunciation/evaluate", data: formData);
    if(kDebugMode) {
      print("response : $response");
    }
    final pronounce = Pronounce.fromJson(response.data);

    return pronounce;
  }

  Future<void> showRecording(BuildContext context) async {
    final isStarted = await startPronounce();
    if(isStarted == false) {
      return;
    }

    final solvesCubit = context.read<SolvesCubit>();
    final MyTimer timer = MyTimer();

    timer.start();
    bool isPronounceProcessing = false;

    final pronounce = await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context1) {
        return MyDialog(
          height: 200,
          child: AnimatedBuilder(
            animation: timer,
            builder: (context2, _) {
              return StatefulBuilder(
                builder: (BuildContext context2, void Function(void Function()) setState1) {

                  return Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: isPronounceProcessing ? const [
                              MyDefaultCircularLoading(
                                size: 40,
                                strokeWidth: 3,
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              Text(
                                "분석하는 중입니다",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ] : [
                              const Icon(
                                Icons.mic,
                                color: MyColor.purple,
                                size: 60,
                              ),
                              Text(
                                "${timer.value.inMinutes.toString().padLeft(2, "0")}:${(timer.value.inSeconds % 60).toString().padLeft(2, "0")}",
                                style: const TextStyle(
                                  fontFamily: "mono",
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      MyContainedButton(
                        height: 40,
                        onPressed: isPronounceProcessing ? null : () async {
                          setState1(() {
                            isPronounceProcessing = true;
                          });
                          timer.stop();

                          final file = await stopPronounce();
                          if(file == null) {
                            Navigator.of(context, rootNavigator: true).pop(null);
                            return;
                          }

                          final pronounce = await evaluatePronounce(file);
                          Navigator.of(context, rootNavigator: true).pop(pronounce);
                        },
                        sameWidgetOnLoading: true,
                        child: Opacity(
                          opacity: isPronounceProcessing ? myDisableOpacity : 1,
                          child: const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  MyColor.purpleOnSky,
                                  MyColor.purple,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "멈추기",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      }
    );

    // pronounce가 null인 경우는 dialog 내부에서 처리하도록 개선될 수 있습니다.
    if(pronounce == null) return;

    solvesCubit.currentSolve.add(pronounce);
  }
}

class MyTimer extends ValueNotifier<Duration> {
  Timer? timer;
  int second = 0;

  MyTimer() : super(Duration.zero);

  // reset의 기능도 겸합니다.
  void start() {
    second = 0;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      second += 1;
      value = Duration(seconds: second);
    });
  }

  void stop() {
    timer?.cancel();
  }
}



class SentenceBox extends StatelessWidget {
  final double borderRadius = 16;
  final TextStyle sentenceTextStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
  final double sentenceHeight = 60;
  final double titleHeight = 32;

  final String? title;
  final String sentence;

  const SentenceBox({
    Key? key,
    this.title,
    required this.sentence,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(title == null) {
      return MyRoundedBox(
        height: sentenceHeight,
        borderRadius: borderRadius,
        child: Center(
          child: Text(
            sentence,
            style: sentenceTextStyle,
          ),
        ),
      );
    } else {
      return MyRoundedBox(
        height: sentenceHeight + titleHeight,
        borderRadius: borderRadius,
        child: Column(
          children: [
            Container(
              height: titleHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
                color: MyColor.sky,
              ),
              child: Center(
                child: Text(
                  title!,
                  style: sentenceTextStyle.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  sentence,
                  style: sentenceTextStyle,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
