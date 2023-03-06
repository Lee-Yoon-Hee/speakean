import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speakean/path.dart';
import 'package:speakean/view/component/button.dart';

import '../constant.dart';
import '../model/problem.dart';
import '../utils.dart';
import '../model/user.dart';
import 'component/box.dart';
import 'component/carousel/carousel_slider.dart';
import 'component/color.dart';
import 'component/scaffold.dart';



class Home extends StatefulWidget {

  const Home({Key? key, Object? arguments}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final double gap = 24;

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBar: MyAppBar(
        leading: Builder(
          builder: (context) {
            return GestureDetector(
              onTap: () {
                Scaffold.of(context).openDrawer();
              },
              child: const Icon(
                Icons.menu,
              ),
            );
          },
        ),
        title: const Text(
          "SPEAKEAN",
          style: myAppBarTitleTextStyle,
        ),
      ),
      drawer: Container(
        width: 80,
        color: Colors.white,
        child: Column(
          children: [
            const SizedBox(
              height: 200,
            ),
            DrawerDestination(
              icon: const Icon(
                Icons.account_circle_outlined,
              ),
              title: "내 정보",
              onPressed: () {
                PathManager.instance.pushUniqueNamed(context, "my_info");
              },
            ),
            const SizedBox(
              height: 24,
            ),
            DrawerDestination(
              icon: const Icon(
                Icons.settings_outlined,
              ),
              title: "설정",
              onPressed: () {
                PathManager.instance.pushUniqueNamed(context, "setting");
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: myBodyPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LayoutBuilder(
              builder: (context1, constraints) {
                return Center(
                  child: MyRoundedBox(
                    height: 110,
                    width: constraints.maxWidth - myPaddingForBodyContentShadow * 2,
                    color: Colors.white,
                    borderRadius: 12,
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  MyColor.purple,
                                  MyColor.sky,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                "images/home/person.svg",
                                width: 30,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: BlocBuilder<UserCubit, User?>(
                              builder: (context2, user) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Text(
                                      user?.name ?? "스피키안",
                                      style: const TextStyle(
                                        color: MyColor.purple,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    // const SizedBox(
                                    //   height: 4,
                                    // ),
                                    // Text(
                                    //   "${fakeUser.school?.kor ?? "스피키안 학교"} ${fakeUser.grade ?? 1}학년",
                                    //   style: TextStyle(
                                    //     color: MyColor.purple.withOpacity(0.9),
                                    //     fontSize: 12,
                                    //     fontWeight: FontWeight.w500,
                                    //   ),
                                    // ),
                                    // const SizedBox(
                                    //   height: 2,
                                    // ),
                                    // Text(
                                    //   fakeUser.locale?.countryName(context) ?? "대한민국",
                                    //   style: TextStyle(
                                    //     color: MyColor.purple.withOpacity(0.9),
                                    //     fontSize: 12,
                                    //     fontWeight: FontWeight.w500,
                                    //   ),
                                    // ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(
              height: gap,
            ),
            Padding(
              padding: const EdgeInsets.only(right: myPaddingForBodyContentShadow),
              child: ScrollConfiguration(
                behavior: NoGlowScrollBehavior(),
                child: BlocBuilder<ProblemsCubit, Future<List<Problem>>>(
                  builder: (context1, problemsFuture) {
                    return BlocBuilder<UserCubit, User?>(
                      builder: (context2, user) {
                        if(user == null) {
                          throw Exception("user 정보가 존재하지 않습니다.");
                        }

                        final carouselOption = CarouselOptions(
                          initialPage: 0,
                          height: 240,
                          viewportFraction: 0.55,
                          enableInfiniteScroll: false,
                          align: Alignment.centerLeft,
                        );

                        return FutureBuilder(
                            future: problemsFuture,
                            builder: (context2, snapshot) {
                              const double carouselBottomPadding = 12;

                              if(snapshot.hasData) {
                                final problems = snapshot.data!;

                                return CarouselSlider(
                                  options: carouselOption,
                                  items: [
                                    for(int i = 1, len = problems.length; i <= len; i++) Padding(
                                      padding: EdgeInsets.only(
                                        left: myPaddingForBodyContentShadow,
                                        right: i < len ? 16 : myPaddingForBodyContentShadow,
                                        bottom: carouselBottomPadding,
                                      ),
                                      child: Builder(
                                        builder: (context3) {
                                          final problem = problems[i - 1];
                                          final isEnabled = user.enableProblemIds.contains(i);

                                          return MyRoundedBox(
                                            elevation: 5,
                                            borderRadius: 12,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            i.toString().padLeft(2, "0"),
                                                            style: const TextStyle(
                                                              fontSize: 18,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 4,
                                                          ),
                                                          Text(
                                                            problem.theme,
                                                            style: const TextStyle(
                                                              fontSize: 18,
                                                            ),
                                                          ),
                                                        ]
                                                    ),
                                                  ),
                                                  MyContainedButton(
                                                    height: 60,
                                                    borderRadius: 16,
                                                    onPressed: isEnabled ? () async {
                                                      PathManager.instance.pushUniqueNamed(context, "study", arguments: {
                                                        "problem" : problem,
                                                      });
                                                    } : null,
                                                    child: Opacity(
                                                      opacity: isEnabled ? 1 : myDisableOpacity,
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
                                                            "시작하기",
                                                            style: myButtonTextStyle,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              } else if(snapshot.hasError) {
                                return const Center(
                                  child: Text(
                                    "error",
                                  ),
                                );
                              } else {
                                return CarouselSlider(
                                  options: carouselOption,
                                  items: [
                                    for(int i = 1, len = 10; i <= len; i++) Padding(
                                      padding: EdgeInsets.only(
                                        left: myPaddingForBodyContentShadow,
                                        right: i < len ? 16 : myPaddingForBodyContentShadow,
                                        bottom: carouselBottomPadding,
                                      ),
                                      child: Builder(
                                        builder: (context2) {
                                          final isEnabled = user.enableProblemIds.contains(i);

                                          return MyRoundedBox(
                                            elevation: 5,
                                            borderRadius: 12,
                                            child: Opacity(
                                              opacity: isEnabled ? 1 : myDisableOpacity,
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
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              }
                            }
                        );
                      }
                    );
                  }
                ),
              ),
            ),
            SizedBox(
              height: gap - 12,
            ),
            LayoutBuilder(
                builder: (context, constraints) {
                  return Center(
                    child: MyRoundedBox(
                      height: 80,
                      width: constraints.maxWidth - myPaddingForBodyContentShadow * 2,
                      elevation: 5,
                      borderRadius: 12,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  "FINAL",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(
                                  height: 2,
                                ),
                                Text(
                                  "정리 학습",
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                )
                              ],
                            ),
                            const Icon(
                              Icons.lock,
                              color: MyColor.purpleOnSky,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
            ),
          ],
        ),
      ),
    );
  }
}


class DrawerDestination extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final Widget icon;

  const DrawerDestination({
    Key? key,
    required this.title,
    required this.onPressed,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconTheme(
            data: const IconThemeData(
              color: MyColor.purpleOnSky,
              size: 32,
            ),
            child: icon,
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            title,
            style: const TextStyle(
              color: MyColor.purpleOnSky,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}