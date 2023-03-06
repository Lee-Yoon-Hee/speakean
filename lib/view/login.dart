// ignore_for_file: annotate_overrides

import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:speakean/path.dart';

import '../constant.dart';
import '../model/api.dart';
import '../model/user.dart';
import 'component/button.dart';
import 'component/color.dart';

import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:flutter_naver_login/flutter_naver_login.dart' as naver;
import 'package:sign_in_with_apple/sign_in_with_apple.dart' as apple;

import 'component/loading.dart';


class Login extends StatefulWidget {

  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Tween<double> waveContainerHeight;

  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // 애니메이션이 종료되면 home으로 이동합니다.
    controller.addStatusListener((status) {
      if(status == AnimationStatus.completed) {
        PathManager.instance.pushNamedAndRemoveUntil(context, "home", (_) => false, isCanonical: false);
      }
    });
  }

  void didChangeDependencies() {
    super.didChangeDependencies();
    waveContainerHeight = Tween(begin: 500, end: MediaQuery.of(context).size.height);
  }

  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, widget) {
        return Scaffold(
          body: SafeArea(
            child: Stack(

              children: [
                Positioned(
                  bottom: 0,
                  height: waveContainerHeight.evaluate(controller),
                  width: MediaQuery.of(context).size.width,
                  child: ClipPath(
                    clipper: WaveClipper(controller.value),
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            MyColor.purple,
                            MyColor.sky,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Opacity(
                    opacity: 1 - controller.value,
                    child: Column(

                      children: [
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  "images/common/logo.png",
                                  width: 90,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: const [
                                    Text(
                                      "스피키안",
                                      style: TextStyle(
                                        color: MyColor.purple,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      "한국어로 통하는 우리",
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 100,
                        ),
                        SizedBox(
                          height: 200,
                          child: Builder(
                            builder: (context1) {
                              final userCubit = context1.read<UserCubit>();

                              return Column(
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  // LoginWithSocial(
                                  //   socialName: "네이버",
                                  //   icon: SvgPicture.asset(
                                  //     "images/login/naver.svg",
                                  //     width: 20,
                                  //   ),
                                  //   backgroundColor: const Color.fromRGBO(3, 199, 90, 1),
                                  //   textColor: Colors.white,
                                  //   onPressed: () async {
                                  //     final data = await loginViaNaver();
                                  //     if(data == null) {
                                  //       if(kDebugMode) {
                                  //         print("naver 로그인이 제대로 수행되지 않았습니다.");
                                  //       }
                                  //       return;
                                  //     }
                                  //
                                  //     await createIfAbsent(userCubit, "NAVER", data);
                                  //     controller.forward();
                                  //   },
                                  // ),
                                  // const SizedBox(
                                  //   height: 16,
                                  // ),
                                  LoginWithSocial(
                                    socialName: "카카오",
                                    icon: SvgPicture.asset(
                                      "images/login/kakao.svg",
                                      width: 24,
                                    ),
                                    backgroundColor: const Color.fromRGBO(247, 230, 0, 1),
                                    onPressed: () async {
                                      final data = await loginViaKakao();
                                      if(data == null) {
                                        if(kDebugMode) {
                                          print("kakao 로그인이 제대로 수행되지 않았습니다.");
                                        }
                                        return;
                                      }

                                      await createIfAbsent(userCubit, "KAKAO", data);
                                      controller.forward();
                                    },
                                  ),
                                  if(Platform.isIOS) ...[
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    LoginWithSocial(
                                      socialName: "애플",
                                      icon: Padding(
                                        padding: const EdgeInsets.only(bottom: 4),
                                        child: SvgPicture.asset(
                                          "images/login/apple.svg",
                                        ),
                                      ),
                                      backgroundColor: Colors.white,
                                      onPressed: () async {
                                        final data = await loginViaApple();
                                        if(data == null) {
                                          if(kDebugMode) {
                                            print("apple 로그인이 제대로 수행되지 않았습니다.");
                                          }
                                          return;
                                        }

                                        await createIfAbsent(userCubit, "APPLE", data);
                                        controller.forward();
                                      },
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> createIfAbsent(UserCubit userCubit, String socialType, Map<String, dynamic> data) async {
    final String socialId = data["socialId"]!;

    if(await userCubit.isExist(socialType, socialId)) {
      await userCubit.login(socialType, socialId);
    } else {
      await userCubit.create(socialType, socialId, data["name"]);
    }
  }
}



class LoginWithSocial extends StatelessWidget {
  final String socialName;
  final Widget icon;
  final Color backgroundColor;
  final Color textColor;
  final FutureVoidCallback onPressed;

  const LoginWithSocial({
    Key? key,
    required this.socialName,
    required this.icon,
    required this.backgroundColor,
    this.textColor = Colors.black,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyContainedButton(
      width: 240,
      height: 40,
      onPressed: onPressed,
      onLoading: ColoredBox(
        color: backgroundColor,
        child: Center(
          child: MyCircularLoading(
            size: 20,
            strokeWidth: 3,
            colors: [
              backgroundColor,
              textColor,
            ],
          ),
        ),
      ),
      child: ColoredBox(
        color: backgroundColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 32,
              child: icon,
            ),
            const SizedBox(
              width: 4,
            ),
            SizedBox(
              width: 90,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Text(
                    "$socialName 로그인",
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<Map<String, dynamic>?> loginViaKakao() async {
  try {
    // accessToken의 존재 및 유효성 검사
    if(await kakao.AuthApi.instance.hasToken()) {
      throw kakao.KakaoException("토근 없음");
    }
    kakao.AccessTokenInfo tokenInfo = await kakao.UserApi.instance.accessTokenInfo();
    if(tokenInfo.expiresIn <= 0) {
      throw kakao.KakaoException("토큰 만료");
    }
  } catch(e) {
    try {
      // 카카오 로그인 시도(1차)
      await kakao.UserApi.instance.loginWithKakaoTalk();

    } catch(e) {
      // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
      // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
      if (e is PlatformException && e.code == 'CANCELED') {
        return null;
      }

      try {
        // 카카오 계정으로 로그인 시도(2차)
        await kakao.UserApi.instance.loginWithKakaoAccount();
      } on Exception {
        return null;
      }
    }
  }

  kakao.User user = await kakao.UserApi.instance.me();
  String? birthday = user.kakaoAccount?.birthday;
  String? birthYear = user.kakaoAccount?.birthyear;
  String? birthdayValue = birthday == null || birthYear == null ?
  null : "$birthYear-${birthday.substring(0, 2)}-${birthday.substring(2, 4)}";

  kakao.Gender? gender = user.kakaoAccount?.gender;
  String? genderValue = gender == null ?
  null : gender == kakao.Gender.female ?
  "F" : "M";

  return {
    "socialId" : user.id.toString(),
    "birthday" : birthdayValue,
    "email"    : user.kakaoAccount?.email,
    "gender"   : genderValue,
    "phone"    : user.kakaoAccount?.phoneNumber,
    "name"     : user.kakaoAccount?.legalName,
    "nickname" : user.kakaoAccount?.profile?.nickname,
  };
}

Future<Map<String, dynamic>?> loginViaNaver() async {
  late naver.NaverLoginResult res;
  try {
    res = await naver.FlutterNaverLogin.logIn();
  } catch(e) {
    try {
      // 토큰을 갱신한 후 다시 시도합니다.
      final token = await naver.FlutterNaverLogin.currentAccessToken;
      if(!token.isValid()) {
        await naver.FlutterNaverLogin.refreshAccessTokenWithRefreshToken();
      }
      res = await naver.FlutterNaverLogin.logIn();
    } catch(e) {
      print(e);
      return null;
    }
  }

  String? birthdayValue = "${res.account.birthyear}-${res.account.birthday}";
  birthdayValue = RegExp("\d{4}-\d{2}-\d{2}").hasMatch(birthdayValue) ? birthdayValue : null;
  String? emailValue = res.account.email.contains("@") ? res.account.email : null;
  String? genderValue = RegExp("[M|F]").hasMatch(res.account.gender) ? res.account.gender : null;
  String? nameValue = res.account.name.isNotEmpty ? res.account.name : null;
  String? nickNameValue = res.account.nickname.isNotEmpty ? res.account.nickname : null;
  String? phoneValue = res.account.mobile.isNotEmpty ? res.account.mobile : null;

  return {
    "socialId" : res.account.id,
    "birthday" : birthdayValue,
    "email"    : emailValue,
    "gender"   : genderValue,
    "name"     : nameValue,
    "nickname" : nickNameValue,
    "phone"    : phoneValue,
  };
}

Future<Map<String, dynamic>?> loginViaApple() async {
  final credential = await apple.SignInWithApple.getAppleIDCredential(
    scopes: [
      apple.AppleIDAuthorizationScopes.fullName,

    ],
  );

  return {
    "socialId": credential.userIdentifier,
  };
}


class WaveClipper extends CustomClipper<Path> {

  final double t;

  WaveClipper(this.t);

  @override
  Path getClip(Size size) {

    double lerp(double h) {
      return (1 - t) * h;
    }

    final path = Path();
    // path.lineTo(0, size.height / 3);
    // path.cubicTo(size.width, lerp(size.height / 3), size.width * 0.04, lerp(size.height * 0.31), size.width * 0.04, lerp(size.height * 0.31));
    path.cubicTo(size.width * 0.08, lerp(size.height * 0.3), size.width * 0.17, lerp(size.height * 0.26), size.width / 4, lerp(size.height * 0.28));
    path.cubicTo(size.width / 3, lerp(size.height * 0.3), size.width * 0.42, lerp(size.height * 0.37), size.width / 2, lerp(size.height * 0.43));
    path.cubicTo(size.width * 0.58, lerp(size.height * 0.48), size.width * 0.67, lerp(size.height * 0.52), size.width * 0.75, lerp(size.height * 0.46));
    path.cubicTo(size.width * 0.83, lerp(size.height * 0.41), size.width * 0.92, lerp(size.height * 0.26), size.width * 0.96, lerp(size.height * 0.19));
    path.cubicTo(size.width * 0.96, lerp(size.height * 0.19), size.width, lerp(size.height * 0.11), size.width, lerp(size.height * 0.11));
    path.cubicTo(size.width, lerp(size.height * 0.11), size.width, lerp(size.height * 1.11), size.width, lerp(size.height * 1.11));
    // path.cubicTo(0, size.height * 1.11, size.width, size.height * 1.11, size.width, size.height * 1.11);
    path.lineTo(size.width, size.height * 1.11);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    // path.cubicTo(size.width, size.height * 1.11, 0, size.height * 1.11, size.width, size.height * 1.11);
    // path.cubicTo(size.width * 0.92, size.height * 1.11, size.width * 0.83, size.height * 1.11, size.width * 0.75, size.height * 1.11);
    // path.cubicTo(size.width * 0.67, size.height * 1.11, size.width * 0.58, size.height * 1.11, size.width / 2, size.height * 1.11);
    // path.cubicTo(size.width * 0.42, lerp(size.height * 1.11), size.width / 3, lerp(size.height * 1.11), size.width / 4, lerp(size.height * 1.11));
    // path.cubicTo(size.width * 0.17, lerp(size.height * 1.11), size.width * 0.08, lerp(size.height * 1.11), size.width * 0.04, lerp(size.height * 1.11));
    // path.cubicTo(size.width * 0.04, lerp(size.height * 1.11), 0, lerp(size.height * 1.11), 0, lerp(size.height * 1.11));
    // path.cubicTo(0, lerp(size.height * 1.11), 0, lerp(size.height / 3), 0, size.height / 3);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}