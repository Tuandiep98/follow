import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:follow/core/AI.dart';
import 'package:follow/models/response_data.dart';

import 'screen/home_screen.dart';
import 'screen/widgets/my_custom_scroll_behavior.dart';

const Color darkBlue = Color.fromARGB(255, 18, 32, 47);

void main() {
  AI.init();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: darkBlue),
      debugShowCheckedModeBanner: false,
      scrollBehavior: MyCustomScrollBehavior(),
      home: HomeScreen(),
    );
  }
}

class VerticalParallaxCarousel extends StatefulWidget {
  const VerticalParallaxCarousel({super.key});

  @override
  State<VerticalParallaxCarousel> createState() =>
      _VerticalParallaxCarouselState();
}

class _VerticalParallaxCarouselState extends State<VerticalParallaxCarousel> {
  List<ResponseData> data = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // await AI.getModels();
      // var response = await _getData(
      //     'Hôm nay ngày ${DateFormat('hh:mm:ss dd/MM/yyyy').format(DateTime.now())}, top các phòng giảm giá trên agoda');
      // if (response.isNotEmpty) {
      //   try {
      //     data = [ResponseData.fromJson(jsonDecode(response))];
      //     setState(() {});
      //   } catch (e) {
      //     debugPrint(e.toString());
      //   }
      // }
      setState(() {
        _loading = false;
      });
    });
  }

  Future<String> _getData(String promt) async {
    String response = '';
    try {} catch (e) {
      debugPrint(e.toString());
    }
    debugPrint(response);
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: CupertinoActivityIndicator(),
            ),
          )
        : locations.isEmpty
            // data.isEmpty || data.first.featuredArticles.isEmpty
            ? GestureDetector(
                onTap: () async {
                  await AI.speech('hello');
                },
                child: Container(
                  color: Colors.white,
                  height: MediaQuery.of(context).size.height,
                  child: Center(
                    child: Text('No data found'),
                  ),
                ),
              )
            : PageView.builder(
                scrollDirection: Axis.vertical, // Vertical scrolling
                physics:
                    const ClampingScrollPhysics(), // Smooth snapping, works on web
                itemCount:
                    locations.length, // data.first.featuredArticles.length,
                itemBuilder: (context, index) {
                  return LocationListItem(
                    imageUrl: locations[index].imageUrl,
                    name: locations[index].name,
                    country: locations[index].place,
                  );
                },
              );
  }
}

class LocationListItem extends StatelessWidget {
  LocationListItem({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.country,
  });

  final String imageUrl;
  final String name;
  final String country;
  final GlobalKey _backgroundImageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        MediaQuery.of(context).size.width > MediaQuery.of(context).size.height
            ? const SizedBox.shrink()
            : _buildBlurredBackground(imageUrl),
        _buildParallaxBackground(context),
        _buildGradient(),
        _buildTitleAndSubtitle(),
      ],
    );
  }

  Widget _buildBlurredBackground(String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: CachedNetworkImageProvider(imageUrl),
          fit: BoxFit.cover,
          filterQuality: FilterQuality.low,
          onError: (exception, stackTrace) => const SizedBox.shrink(),
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.0)),
        ),
      ),
    );
  }

  Widget _buildParallaxBackground(BuildContext context) {
    return Flow(
      delegate: ParallaxFlowDelegate(
        scrollable: Scrollable.of(context),
        listItemContext: context,
        backgroundImageKey: _backgroundImageKey,
      ),
      children: [
        CachedNetworkImage(
          imageUrl: imageUrl,
          key: _backgroundImageKey,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          errorWidget: (context, error, stackTrace) {
            return Icon(Icons.error);
          },
        ),
      ],
    );
  }

  Widget _buildGradient() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.6, 0.95],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleAndSubtitle() {
    return Positioned(
      left: 20,
      bottom: 100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            country,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class ParallaxFlowDelegate extends FlowDelegate {
  ParallaxFlowDelegate({
    required this.scrollable,
    required this.listItemContext,
    required this.backgroundImageKey,
  }) : super(repaint: scrollable.position);

  final ScrollableState scrollable;
  final BuildContext listItemContext;
  final GlobalKey backgroundImageKey;

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    return BoxConstraints.tightFor(width: constraints.maxWidth);
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    final scrollableBox = scrollable.context.findRenderObject() as RenderBox;
    final listItemBox = listItemContext.findRenderObject() as RenderBox;
    final listItemOffset = listItemBox.localToGlobal(
      listItemBox.size.centerLeft(Offset.zero),
      ancestor: scrollableBox,
    );

    final viewportDimension = scrollable.position.viewportDimension;
    final scrollFraction =
        (listItemOffset.dy / viewportDimension).clamp(0.0, 1.0);
    final verticalAlignment = Alignment(0.0, scrollFraction * 2 - 1);

    final backgroundSize =
        (backgroundImageKey.currentContext!.findRenderObject() as RenderBox)
            .size;
    final listItemSize = context.size;
    final childRect =
        verticalAlignment.inscribe(backgroundSize, Offset.zero & listItemSize);

    context.paintChild(
      0,
      transform:
          Transform.translate(offset: Offset(0.0, childRect.top)).transform,
    );
  }

  @override
  bool shouldRepaint(ParallaxFlowDelegate oldDelegate) {
    return scrollable != oldDelegate.scrollable ||
        listItemContext != oldDelegate.listItemContext ||
        backgroundImageKey != oldDelegate.backgroundImageKey;
  }
}

class Location {
  const Location({
    required this.name,
    required this.place,
    required this.imageUrl,
  });

  final String name;
  final String place;
  final String imageUrl;
}

const urlPrefix =
    'https://docs.flutter.dev/cookbook/img-files/effects/parallax';
const locations = [
  Location(
    name: 'Mount Rushmore',
    place: 'U.S.A',
    imageUrl: '$urlPrefix/01-mount-rushmore.jpg',
  ),
  Location(
    name: 'Gardens By The Bay',
    place: 'Singapore',
    imageUrl: '$urlPrefix/02-singapore.jpg',
  ),
  Location(
    name: 'Machu Picchu',
    place: 'Peru',
    imageUrl: '$urlPrefix/03-machu-picchu.jpg',
  ),
  Location(
    name: 'Vitznau',
    place: 'Switzerland',
    imageUrl: '$urlPrefix/04-vitznau.jpg',
  ),
  Location(
    name: 'Bali',
    place: 'Indonesia',
    imageUrl: '$urlPrefix/05-bali.jpg',
  ),
  Location(
    name: 'Mexico City',
    place: 'Mexico',
    imageUrl: '$urlPrefix/06-mexico-city.jpg',
  ),
  Location(name: 'Cairo', place: 'Egypt', imageUrl: '$urlPrefix/07-cairo.jpg'),
];
