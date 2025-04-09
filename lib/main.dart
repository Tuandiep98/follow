import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:follow/core/AI.dart';
import 'package:follow/core/storage_manager.dart';
import 'package:follow/models/response_data.dart';

import 'screen/home_screen.dart';
import 'screen/widgets/my_custom_scroll_behavior.dart';

const Color darkBlue = Color.fromARGB(255, 18, 32, 47);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageManager.initShareReference();
  await SoLoud.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'NotoSansSC',
      ).copyWith(
        scaffoldBackgroundColor: darkBlue,
      ),
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

  @override
  void dispose() {
    unawaited(SoLoud.instance.disposeAllSources());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? SizedBox(
            height: MediaQuery.of(context).size.height,
            child: const Center(
              child: CupertinoActivityIndicator(),
            ),
          )
        : locations.isEmpty
            // data.isEmpty || data.first.featuredArticles.isEmpty
            ? Container(
                color: Colors.white,
                height: MediaQuery.of(context).size.height,
                child: Center(
                  child: Text('No data found'),
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
        // true ? const SizedBox.shrink() : _buildBlurredBackground(imageUrl),
        _buildParallaxBackground(context),
        _buildGradient(),
        _buildTitleAndSubtitle(),
        _buildActions(),
      ],
    );
  }

  // Widget _buildBlurredBackground(String imageUrl) {
  //   return Container(
  //     decoration: BoxDecoration(
  //       image: DecorationImage(
  //         image: CachedNetworkImageProvider(imageUrl),
  //         fit: BoxFit.cover,
  //         filterQuality: FilterQuality.low,
  //         onError: (exception, stackTrace) => const SizedBox.shrink(),
  //       ),
  //     ),
  //     child: BackdropFilter(
  //       filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
  //       child: Container(
  //         decoration: BoxDecoration(color: Colors.white.withOpacity(0.0)),
  //       ),
  //     ),
  //   );
  // }

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
          height: MediaQuery.of(context).size.height,
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
              fontFamily: 'NotoSansSC',
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

  Widget _buildActions() {
    return Positioned(
      right: 20,
      bottom: 100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () async {
              // await AI.speech(
              //     'He lô bà Thảo, bà có khỏe không? Hôm nay trời đẹp quá, bà có muốn đi dạo không?');
              // await AI.speech(
              //     'Chương 945: Một Mình Uống Rượu Dưới TrăngBầu trời quang đãng, vầng trăng sáng treo cao, tỏa ánh sáng dịu dàng xuống mặt đất. Ánh trăng chảy tràn nhẹ nhàng, tựa như một dòng sông ánh bạc.Trần Bình An ngồi một mình trên mái nhà trong tông môn Uyên Ngục, tay cầm bình rượu, lặng lẽ uống. Gió đêm thoảng qua, khẽ làm tung bay vạt áo xanh của hắn, mang theo một vẻ thanh thoát xa cách.Hắn không uống rượu địa phương của Uyên Ngục Tông, mà là một bình rượu quế mang theo từ Phước Địa Liên Hoa. Rượu không quá mạnh, nhưng mang hương thơm thoang thoảng, lưu lại dư vị dễ chịu.Trần Bình An hiếm khi uống rượu một mình như thế này, nhưng tối nay dường như khác biệt. Có lẽ là vì vẻ đẹp tĩnh lặng của ánh trăng, hay sự yên ả của khoảnh khắc đã khơi dậy điều gì đó trong lòng hắn. Hắn nhấp một ngụm, để vị ngọt nhẹ của rượu quế lan tỏa trên đầu lưỡi, rồi ngước nhìn vầng trăng, chìm vào suy tư.Xa xa, âm thanh của Uyên Ngục Tông vọng lại mơ hồ—tiếng trò chuyện khe khẽ của các đệ tử tuần tra đêm hoặc tiếng lá xào xạc trong gió. Nhưng ở đây, chỉ có hắn, vầng trăng và bình rượu. Với một người đã đi qua vô số con đường và đối mặt với muôn vàn thử thách, sự cô đơn hiếm hoi này dường như là một thứ xa xỉ.Hắn nghiêng bình rượu, để chất lỏng mát lạnh trôi xuống cổ họng, khẽ lẩm bẩm: “Ánh trăng rực rỡ, sàn nhà phủ sương…” Đó là một câu thơ cổ, đã nhiều năm hắn không ngâm nga. Một nụ cười nhạt thoáng qua trên môi khi hắn tiếp tục, “Ta nâng chén mời trăng, cùng bóng ta thành ba.”Lời thơ vang vọng trong không gian, hòa quyện cùng màn đêm. Trần Bình An không phải người đa sầu đa cảm, nhưng tối nay, sự bao la của bầu trời và khoảnh khắc cô đơn khiến hắn cảm nhận được sức nặng của hành trình mình đã đi qua. Hắn nghĩ đến những người bạn—một số gần, một số xa—rải rác khắp thế gian như những vì sao trên trời. Hắn tự hỏi họ đang thế nào dưới cùng vầng trăng này.Lại một ngụm nữa. Bình rượu giờ đã vơi nửa. Hắn đặt nó xuống bên cạnh, ngả người ra sau, chống tay, ánh mắt dõi theo đường nét của vầng trăng. Đêm nay trăng rằm, tròn đầy, tỏa ra một sức mạnh thầm lặng. Giống như con đường kiếm đạo, hắn nghĩ—đơn giản mà sâu sắc, vững vàng mà luôn biến đổi.Một cơn gió bất chợt mang theo hương thông từ khu rừng gần đó, hòa lẫn với mùi thơm của hoa quế. Trần Bình An nhắm mắt một lát, để cảm giác ấy tràn qua. Trong tâm trí, hắn thấy những gương mặt thân thương: Ninh Diêu với ánh mắt sắc bén và ý chí kiên định; Lưu Cảnh Long, vững chãi như núi; và Bùi Tiền, đã trưởng thành rất nhiều nhưng vẫn mang nét của cô bé ngày nào.Hắn mở mắt, khẽ cười. “Một mình uống rượu dưới trăng… cũng không tệ.”Đêm dần trôi, và Trần Bình An vẫn ở đó, một bóng người đơn độc dưới ánh bạc, đắm mình trong sự tĩnh lặng đầy mãn nguyện.');
            },
            icon: Icon(Icons.theater_comedy),
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
