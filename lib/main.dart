import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:follow/models/response_data.dart';
import 'package:intl/intl.dart';

import 'core/groq_ai_utils.dart';
import 'screen/widgets/my_custom_scroll_behavior.dart';

const Color darkBlue = Color.fromARGB(255, 18, 32, 47);

void main() {
  GroqAIUtils.initGroq();
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
      home: const Scaffold(body: VerticalParallaxCarousel()),
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
      var response = await _getData(
          'Hôm nay ngày ${DateFormat('hh:mm:ss dd/MM/yyyy').format(DateTime.now())}, top các phòng giảm giá trên agoda');
      if (response.isNotEmpty) {
        try {
          data = [ResponseData.fromJson(jsonDecode(response))];
          setState(() {});
        } catch (e) {
          debugPrint(e.toString());
        }
      }
      setState(() {
        _loading = false;
      });
    });
  }

  Future<String> _getData(String promt) async {
    String response = '';
    try {
      GroqAIUtils.setCustomInstructions(
          "You are a helpful assistant who always responds in a friendly, concise manner. "
          "Use casual language and provide clear, direct answers."
          "All the image ensure to be in 16:9 aspect ratio, valid url"
          "Bạn luôn luôn trả lời bằng tiếng anh và là dạng json, theo cấu trúc ${ResponseData().toConstructorString()}, chỉ mỗi dữ liệu json nằm trong ngoặc {}");
      response = await GroqAIUtils.sendMessage(promt);
    } catch (e) {
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
        : data.isEmpty || data.first.featuredArticles.isEmpty
            ? SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Center(
                  child: Text('No data found'),
                ),
              )
            : PageView.builder(
                scrollDirection: Axis.vertical, // Vertical scrolling
                physics:
                    const ClampingScrollPhysics(), // Smooth snapping, works on web
                itemCount: data.first.featuredArticles.length,
                itemBuilder: (context, index) {
                  return LocationListItem(
                    imageUrl: data.first.featuredArticles[index].thumb,
                    name: data.first.featuredArticles[index].title,
                    country: data.first.featuredArticles[index].category,
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
          image: NetworkImage(imageUrl),
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
        Image.network(
          imageUrl,
          key: _backgroundImageKey,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) {
            var a = error;
            return const SizedBox.shrink();
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
      bottom: 20,
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
