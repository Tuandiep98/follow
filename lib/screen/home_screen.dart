import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:follow/main.dart';
import 'package:follow/screen/bottom_bar/bottom_bar.dart';
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
  final List<PageData> pages = [
    PageData(const VerticalParallaxCarousel(), Colors.white),
    PageData(const Center(child: Text('Search')), Colors.black),
    PageData(const Center(child: Text('Add')), Colors.green),
    PageData(const Center(child: Text('Favorite')), Colors.blue),
    PageData(const Center(child: Text('Settings')), Colors.pink),
  ];

  @override
  void initState() {
    currentPage = 0;
    tabController = TabController(length: 5, vsync: this);
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
        width: MediaQuery.of(context).size.width * 0.8,
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
                          : currentPage == 2
                              ? pages[2].color
                              : currentPage == 3
                                  ? pages[3].color
                                  : currentPage == 4
                                      ? pages[4].color
                                      : unselectedColor,
                  width: 4),
              insets: EdgeInsets.fromLTRB(16, 0, 16, 8)),
          tabs: [
            SizedBox(
              height: 55,
              width: 40,
              child: Center(
                  child: Icon(
                Icons.home,
                color: currentPage == 0 ? pages[0].color : unselectedColor,
              )),
            ),
            SizedBox(
              height: 55,
              width: 40,
              child: Center(
                  child: Icon(
                Icons.search,
                color: currentPage == 1 ? pages[1].color : unselectedColor,
              )),
            ),
            SizedBox(
              height: 55,
              width: 40,
              child: Center(
                  child: Icon(
                Icons.add,
                color: currentPage == 2 ? pages[2].color : unselectedColor,
              )),
            ),
            SizedBox(
              height: 55,
              width: 40,
              child: Center(
                  child: Icon(
                Icons.favorite,
                color: currentPage == 3 ? pages[3].color : unselectedColor,
              )),
            ),
            SizedBox(
              height: 55,
              width: 40,
              child: Center(
                  child: Icon(
                Icons.settings,
                color: currentPage == 4 ? pages[4].color : unselectedColor,
              )),
            ),
          ],
        ),
      ),
    );
  }
}
