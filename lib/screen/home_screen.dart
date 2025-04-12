import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:follow/main.dart';
import 'package:follow/screen/bottom_bar/bottom_bar.dart';
import 'package:follow/screen/setting/setting_screen.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

class PageData {
  final Widget child;
  final Color color;
  PageData(this.child, this.color);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late int currentPage;
  late TabController tabController;
  var screenColor = Color.fromARGB(
    255, // Fully opaque
    Random().nextInt(256), // Red (0-255)
    Random().nextInt(256), // Green (0-255)
    Random().nextInt(256), // Blue (0-255)
  );
  List<PageData> pages = [];

  @override
  void initState() {
    pages = [
      PageData(const VerticalParallaxCarousel(), Colors.white),
      PageData(SettingScreen(screenColor: screenColor), screenColor),
    ];
    currentPage = 1;
    tabController = TabController(length: 2, vsync: this);
    tabController.animation!.addListener(
      () {
        final value = tabController.animation!.value.round();
        if (value != currentPage && mounted) {
          changePage(value);
        }
      },
    );
    super.initState();
  }

  void changePage(int newPage) {
    setState(() {
      currentPage = newPage;
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color unselectedColor =
        pages[currentPage].color.computeLuminance() < 0.5
            ? Colors.black
            : Colors.white;
    return Scaffold(
      bottomNavigationBar: BottomBar(
        fit: StackFit.expand,
        icon: (width, height) => Center(
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: null,
            icon: Icon(
              Icons.arrow_upward_rounded,
              color: unselectedColor,
              size: width,
            ),
          ),
        ),
        borderRadius: BorderRadius.circular(500),
        duration: Duration(seconds: 1),
        curve: Curves.decelerate,
        showIcon: true,
        barColor: pages[currentPage].color.computeLuminance() > 0.5
            ? Colors.black
            : Colors.white,
        start: 2,
        end: 0,
        offset: 10,
        barAlignment: Alignment.bottomCenter,
        iconHeight: 35,
        iconWidth: 35,
        reverse: false,
        hideOnScroll: true,
        scrollOpposite: false,
        onBottomBarHidden: () {},
        onBottomBarShown: () {},
        body: (context, controller) => TabBarView(
          controller: tabController,
          dragStartBehavior: DragStartBehavior.down,
          physics: const BouncingScrollPhysics(),
          children: pages
              .map((e) => InfiniteList(
                    key: ValueKey('infinite_list_key#${e.color.toString()}'),
                    scrollController: controller,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        height: MediaQuery.of(context).size.height + 1,
                        color: e.color,
                        child: e.child,
                      );
                    },
                    itemCount: 1,
                    onFetchData: () {},
                  ))
              .toList(),
        ),
        child: TabBar(
          dividerHeight: 0,
          indicatorPadding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
          controller: tabController,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(
              color: currentPage == 0
                  ? pages[0].color
                  : currentPage == 1
                      ? pages[1].color
                      : unselectedColor,
              width: 2,
            ),
            insets: EdgeInsets.fromLTRB(16, 0, 16, 8),
          ),
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              return states.contains(WidgetState.focused)
                  ? null
                  : Colors.transparent;
            },
          ),
          tabs: [
            SizedBox(
              height: 55,
              width: 40,
              child: Center(
                child: Icon(
                  Icons.home,
                  color: currentPage == 0 ? pages[0].color : unselectedColor,
                ),
              ),
            ),
            SizedBox(
              height: 55,
              width: 40,
              child: Center(
                child: Icon(
                  Icons.settings,
                  color: currentPage == 1 ? pages[1].color : unselectedColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
