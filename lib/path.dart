// ignore_for_file: annotate_overrides

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


typedef WrapBuilder = Widget Function(BuildContext context, Widget widget);

class PathManagerWidget extends StatefulWidget {
  final String title;
  final List<PathRoute> root;
  final String homeName;
  final WrapBuilder? pathWrapBuilder;
  late final WrapBuilder materialAppWrapBuilder;
  final GlobalKey<NavigatorState>? navigatorKey;
  final VoidCallback? onDispose;
  final List<NavigatorObserver> navigatorObservers;
  final ThemeData? theme;
  final List<LocalizationsDelegate>? localizationsDelegates;

  PathManagerWidget({
    Key? key,
    this.onDispose,
    this.navigatorKey,
    required this.root,
    required this.homeName,
    required this.title,
    this.pathWrapBuilder,
    WrapBuilder? materialAppWrapBuilder,
    this.navigatorObservers = const [],
    this.theme,
    this.localizationsDelegates,
  }) : super(key: key) {
    this.materialAppWrapBuilder = materialAppWrapBuilder ?? (context, materialApp) => materialApp;
  }

  @override
  State<PathManagerWidget> createState() => _PathManagerWidgetState();
}

class _PathManagerWidgetState extends State<PathManagerWidget> {
  late final PathManager _pathManager;

  void initState() {
    super.initState();
    _pathManager = PathManager._(homeName: widget.homeName, root: widget.root, pathWrapBuilder: widget.pathWrapBuilder);
  }

  void dispose() {
    if(widget.onDispose != null) {
      widget.onDispose!();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.materialAppWrapBuilder(
      context,
      Builder(
        builder: (BuildContext context) {
          return MaterialApp(
            title: widget.title,
            navigatorKey: widget.navigatorKey,
            debugShowCheckedModeBanner: false,
            onGenerateRoute: _pathManager._generateRoute,
            onUnknownRoute: _unknownRoute,
            initialRoute: widget.homeName,
            onGenerateInitialRoutes: (String initialRoute) {
              return [_pathManager._home];
            },
            navigatorObservers: [...widget.navigatorObservers],
            theme: widget.theme,
            localizationsDelegates: widget.localizationsDelegates,
          );
        },
      ),
    );
  }

  Route _unknownRoute(RouteSettings settings) {
    throw UnimplementedError();
  }
}

/*
class HistoryList<E> extends DelegatingList<E> {

  HistoryList() : super([]);

  void add(E value) {
    super.add(value);

    print(_history);
  }

  String get _history => join(" > ");
}
*/

class PathManager {
  static late final PathManager instance;

  final List<PathRoute> root;
  final Map<String, PathRoute> _map;
  late final Route _home;

  final WrapBuilder? pathWrapBuilder;

  PathManager._({
    required this.root,
    required String homeName,
    this.pathWrapBuilder,
  }) : _map = {} {
    _recursiveMapping("", root);
    _home = _map[homeName]!.createRoute(pathWrapBuilder: pathWrapBuilder);

    instance = this;
  }

  Route _generateRoute(RouteSettings settings) {
    final name = settings.name!;
    final arguments = settings.arguments as Map<String, dynamic>?;

    return _map[name]!.createRoute(arguments: arguments, pathWrapBuilder: pathWrapBuilder);
  }

  void _recursiveMapping(String parentPathName, List<PathRoute> children) {
    for(var pathRoute in children) {
      String currentPathName = "$parentPathName/${pathRoute.name}";
      _map[currentPathName] = pathRoute..name = currentPathName;

      _recursiveMapping(currentPathName, pathRoute.children);
    }
  }

  Future<void> pushCanonicalNamed(BuildContext context, String canonicalName, {Object? arguments}) {
    return _pushNamed(context, canonicalName, arguments);
  }

  Future<void> pushUniqueNamed(BuildContext context, String uniqueName, {Object? arguments}) {
    String canonicalName = uniqueToCanonical(uniqueName);

    return _pushNamed(context, canonicalName, arguments);
  }

  void pop(BuildContext context) {
    Navigator.pop(context);
  }

  void popUntil(BuildContext context, RoutePredicate predicate) {
    Navigator.popUntil(context, predicate);

    //_historyRemoveUntil(predicate);
  }

  void popUntilUnique(BuildContext context, String uniqueName) {
    String canonicalName = uniqueToCanonical(uniqueName);
    if(kDebugMode) {
      print("canonicalName : $canonicalName");
    }

    bool predicate(Route route) {
      return route.settings.name == canonicalName;
    }

    return popUntil(context, predicate);
  }

  void pushNamedAndRemoveUntil(BuildContext context, String name, RoutePredicate predicate, {bool isCanonical = true, Object? arguments}) {
    String canonicalName = isCanonical ? name : uniqueToCanonical(name);

    Navigator.pushNamedAndRemoveUntil(context, canonicalName, predicate, arguments: arguments);
  }

  Future<void> _pushNamed(BuildContext context, String name, [Object? arguments]) {
    return Navigator.pushNamed(context, name, arguments: arguments);
  }

  /*
  void _historyRemoveUntil(RoutePredicate predicate) {
    Iterable reversed = [...history].reversed;

    for(String name in reversed) {
      if(predicate(_map[name]!.createRoute())) {
        history.removeLast();
        return;
      }
      history.removeLast();
    }
  }
  */

  String uniqueToCanonical(String uniqueName) {
    /*
    final regExp = RegExp(r"\/(?<match>\w+)$");

    for(String key in _map.keys) {
      if(regExp.firstMatch(key)?.namedGroup("match") == uniqueName) {
        return key;
      }
    }
    */
    for(String key in _map.keys) {
      if(key.endsWith(uniqueName)) {
        return key;
      }
    }

    throw Exception("canonical is null");
  }
}

typedef Constructor<T> = T Function(PathRouteCallbacks pathRouteCallback, Map<String, dynamic>? arguments);

class PathRoute {
  final Constructor<Widget>? builder;
  String name;
  final List<PathRoute> children;

  PathRoute({required this.name, this.builder, this.children = const []});

  Route createRoute({Map<String, dynamic>? arguments, WrapBuilder? pathWrapBuilder}) {

    PathRouteCallbacks pathRouteCallbacks = PathRouteCallbacks();

    return PageRouteBuilder(
      settings: RouteSettings(name: name),
      pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {

        Widget child = widget(pathRouteCallbacks, arguments);

        if(pathWrapBuilder != null) {
          child = pathWrapBuilder(context, child);
        }

        return PathRouteAware(
          pathRouteCallbacks: pathRouteCallbacks,
          child: child,
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    );
  }

  Widget widget(PathRouteCallbacks pathRouteCallbacks, Map<String, dynamic>? arguments) {
    if(builder != null) {
      return builder!(pathRouteCallbacks, arguments);
    } else {
      throw Exception("constructor is null");
    }
  }
}


class PathRouteAware extends StatefulWidget {
  final Widget child;
  final PathRouteCallbacks pathRouteCallbacks;

  const PathRouteAware({required this.child, required this.pathRouteCallbacks, Key? key}) : super(key: key);

  @override
  State<PathRouteAware> createState() => _PathRouteAwareState();
}

class _PathRouteAwareState extends State<PathRouteAware> with RouteAware {

  void didChangeDependencies() {
    super.didChangeDependencies();
    // widget.routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  void dispose() {
    // widget.routeObserver.unsubscribe(this);
    super.dispose();
  }

  void didPush() {}

  void didPopNext() {}

  void didPushNext() {}

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class PathRouteCallbacks {
  void Function(String name)? didPush;
  void Function(String name)? didPopNext;
  void Function(String name)? didPushNext;

  PathRouteCallbacks({this.didPush, this.didPopNext, this.didPushNext});
}

