import 'package:flutter/material.dart';

import '../../constant.dart';
import 'color.dart';


class MyScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final Widget body;

  const MyScaffold({
    Key? key,
    this.appBar,
    this.drawer,
    required this.body,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -(myToolbarHeight + myAppbarBottomHeight),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
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
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - myToolbarHeight,
            child: SafeArea(
              child: body,
            ),
          ),
        ],
      ),
    );
  }
}


class MyAppBar extends AppBar {

  MyAppBar({
    super.key,
    super.leading,
    super.automaticallyImplyLeading = true,
    super.title,
    super.actions,
    super.flexibleSpace,
    super.scrolledUnderElevation,
    super.notificationPredicate = defaultScrollNotificationPredicate,
    super.shadowColor,
    super.surfaceTintColor,
    super.shape,
    super.foregroundColor,
    super.iconTheme,
    super.actionsIconTheme,
    super.primary = true,
    super.excludeHeaderSemantics = false,
    super.titleSpacing,
    super.toolbarOpacity = 1.0,
    super.bottomOpacity = 1.0,
    super.leadingWidth,
    super.toolbarTextStyle,
    super.titleTextStyle,
    super.systemOverlayStyle,
  }) : super(
    backgroundColor: Colors.white.withOpacity(0.2),
    elevation: 0,
    toolbarHeight: myToolbarHeight,
    centerTitle: true,
    bottom: PreferredSize(
      preferredSize: const Size(double.infinity, myAppbarBottomHeight),
      child: Container(
        height: myAppbarBottomHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.12),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    ),
  );
}
