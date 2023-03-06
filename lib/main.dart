import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:speakean/firebase_options.dart';
import 'package:speakean/model/user.dart';

import 'path.dart';
import 'model/problem.dart';
import 'model/api.dart';
import 'view/view.dart';
import 'view/component/color.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

  KakaoSdk.init(nativeAppKey: "2fce2308146144a19a85032ada08e904");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PathManagerWidget(
      title: "speakean",
      homeName: "/login",
      theme: ThemeData(
        fontFamily: "pretendard",
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: MyColor.purpleOnSky,
            statusBarBrightness: Brightness.light,
          ),
        ),
      ),
      localizationsDelegates: const [
        LocaleNamesLocalizationsDelegate(),
      ],
      materialAppWrapBuilder: (context, app) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<ProblemsCubit>(
              create: (context1) => ProblemsCubit(),
            ),
            BlocProvider<UserCubit>(
              create: (context1) => UserCubit(),
            ),
          ],
          child: app,
        );
      },
      root: [
        PathRoute(
          name: "login",
          builder: (callbacks, arguments) {
            return const Login();
          },
        ),
        PathRoute(
          name: "home",
          builder: (callbacks, arguments) {
            return const Home();
          },
        ),
        PathRoute(
          name: "setting",
          builder: (callbacks, arguments) {
            return const Setting();
          },
        ),
        PathRoute(
          name: "my_info",
          builder: (callbacks, arguments) {
            return const MyInfo();
          },
        ),
        PathRoute(
          name: "study",
          builder: (callbacks, arguments) {
            if(arguments == null) {
              throw Exception("study route는 매개변수를 필요로 합니다.");
            }

            final problem = arguments["problem"];
            return Study(problem: problem);
          }
        ),
      ],
    );
  }
}
