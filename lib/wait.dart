// ignore_for_file: annotate_overrides

import 'package:flutter/material.dart';

/*
위젯(stl or stful) 내 어디서 기다림이 있다고 등록하고, 기다리는 것이 끝났다고 알릴까?
이는 크게 3가지로 나뉠 듯
1. 위젯의 생성자
2. build
3. initState

Builder 및 Promise 개념 활용
*/

/*
void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: WaitingArea(
          onAllWaitEnd: () {
            print("all is done");
          },
          child: Column(

            children: [
              WaitingPart(
                builder: (waitEnd, Widget? child) {
                  Future.delayed(const Duration(seconds: 2)).then((_) {
                    print(1);
                    waitEnd();
                  });
                  return Container();
                },
              ),
              Container(
                child: Column(

                  children: [
                    WaitingPart(
                      builder: (waitEnd, Widget? child) {
                        Future.delayed(const Duration(seconds: 3)).then((_) {
                          print(2);
                          waitEnd();
                        });
                        return Container();
                      },
                    ),
                    Container(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {

                          });
                        },
                        child: Text(
                          "click",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/

class WaitingArea extends StatefulWidget {
  final Widget child;
  final VoidCallback onAllWaitEnd;

  const WaitingArea({Key? key, required this.child, required this.onAllWaitEnd}) : super(key: key);

  @override
  State<WaitingArea> createState() => _WaitingAreaState();
}

class _WaitingAreaState extends State<WaitingArea> {
  _WaitingAreaModel? model;

  void initState() {
    super.initState();
    model = _WaitingAreaModel()..addListener(() {
      if(model!.isAllWaitEnd) {
        widget.onAllWaitEnd();
      }
    });
  }

  void dispose() {
    model = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _WaitingAreaModelAccessor(model!, child: widget.child);
  }
}

class _WaitingAreaModel extends ChangeNotifier {

  final Map<Object, int> map = {};

  void waitStart(Object o) {
    if(map.containsKey(o)) {
      throw Exception("$o is already registered");
    }
    map[o] = 1;
  }

  void waitEnd(Object o) {
    if(!map.containsKey(o)) {
      throw Exception("$o is not registered; so waiting can not end");
    }
    map[o] = map[o]! - 1;
    notifyListeners();
  }

  bool get isAllWaitEnd => map.values.every((e) => e == 0);
}

class _WaitingAreaModelAccessor extends InheritedWidget {
  final _WaitingAreaModel model;

  const _WaitingAreaModelAccessor(this.model, {required super.child});

  static _WaitingAreaModel? of(BuildContext context) {
    final _WaitingAreaModelAccessor? accessor = context.dependOnInheritedWidgetOfExactType<_WaitingAreaModelAccessor>();
    return accessor?.model;
  }

  @override
  bool updateShouldNotify(covariant _WaitingAreaModelAccessor oldWidget) {
    return model == oldWidget.model;
  }

}

class WaitingPart extends StatefulWidget {
  final Widget? child;
  final Widget Function(VoidCallback waitEnd, Widget? child) builder;

  const WaitingPart({Key? key, required this.builder, this.child}) : super(key: key);

  @override
  State<WaitingPart> createState() => _WaitingPartState();
}

class _WaitingPartState extends State<WaitingPart> {
  late final _WaitingAreaModel model;

  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final model = _WaitingAreaModelAccessor.of(context);
      if(model == null) {
        throw Exception("WaitingArea could not be found in ancestor");
      }

      this.model = model..waitStart(this);
    });
  }

  // 몇 개를 기다려야하는지 지정할 수도 있을 듯
  // waitEnd마다 숫자를 매개변수로 넘겨서 프레임워크의
  // rebuild로 인한 중복 카운트를 예방
  void waitStart(int count) {

  }

  void waitEnd() {
    model.waitEnd(this);
  }

  void dispose() {
    model.map.remove(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(waitEnd, widget.child);
  }
}
