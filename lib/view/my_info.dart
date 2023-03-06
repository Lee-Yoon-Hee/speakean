import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speakean/model/user.dart';
import 'package:speakean/view/component/box.dart';
import 'package:speakean/view/component/button.dart';

import '../constant.dart';
import '../path.dart';
import 'component/color.dart';
import 'component/scaffold.dart';


class MyInfo extends StatefulWidget {

  const MyInfo({Key? key}) : super(key: key);

  @override
  State<MyInfo> createState() => _MyInfoState();
}

class _MyInfoState extends State<MyInfo> {
  late final TextEditingController nameController;

  void initState() {
    super.initState();
    final userCubit = context.read<UserCubit>();

    nameController = TextEditingController(text: userCubit.state!.name);
  }

  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
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
          "MY INFO",
          style: myAppBarTitleTextStyle,
        ),
      ),
      body: Padding(
        padding: myBodyPadding.copyWith(bottom: 40),
        child: MyRoundedBox(
          color: Colors.white,
          borderRadius: 18,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      child: Column(
                          children: [
                            TextFormField(
                              controller: nameController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                labelText: '이름',
                                labelStyle: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ]
                      ),
                    ),
                  ),
                ),
                MyContainedButton(
                  height: 50,
                  onPressed: () async {
                    final userCubit = context.read<UserCubit>();
                    userCubit.update(name: nameController.text);
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
                        "저장",
                        style: myButtonTextStyle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
