import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/scheduler.dart';

import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Painting Lessons with Jide Guru',
        theme: ThemeData(
          primarySwatch: Colors.teal,
        ),
        home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late ui.Image image;
  late img.Image imagePixels;
  bool _loading = true;
  List<Offset> offsets = List.empty(growable: true);
  Random _random = Random();
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    loadImage();
    _ticker = createTicker((elapsed) {
      if (!_loading) {
        for (int i = 1; i < 500; i++) {
          randomizePoints();
        }
      }

      setState(() {});
    });
    _ticker.start();
  }

  void loadImage() async {
    var data = await rootBundle.load('assets/cr.jpeg');
    final buffer = data.buffer;
    var bytes = buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    image = await decodeImageFromList(bytes);
    imagePixels = await img.decodeJpg(bytes)!;
    _loading = false;
    randomizePoints();

    setState(() {});
  }

  randomizePoints() {
    int x = _random.nextInt(imagePixels.width);
    int y = _random.nextInt(imagePixels.height);

    Offset offset = Offset(x.toDouble(), y.toDouble());
    if (!offsets.contains(offset)) {
      offsets.add(offset);
    } else {
      randomizePoints();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(title: const Text('Painting With pixels')),
        body: _loading
            ? SizedBox.shrink()
            : CustomPaint(
                child: SizedBox(
                  height: size.height,
                  width: size.width,
                ),
                painter: _PixelPainter(
                  image: image,
                  imagePixels: imagePixels,
                  offsets: offsets,
                ),
              ));
  }
}

class _PixelPainter extends CustomPainter {
  ui.Image image;
  img.Image imagePixels;
  final List<Offset> offsets;
  _PixelPainter(
      {required this.image, required this.imagePixels, required this.offsets});
  @override
  void paint(Canvas canvas, Size size) {
    // canvas.drawImage(image, Offset.zero, Paint());
    // for (int x = 0; x < imagePixels.width; x++) {
    //   for (int y = 0; y < imagePixels.height; y++) {

    //   }
    // }
    for (Offset offset in offsets) {
      img.Pixel pixel =
          imagePixels.getPixelSafe(offset.dx.toInt(), offset.dy.toInt());
      List colorList = pixel.toList();

      canvas.drawCircle(
          offset,
          3,
          Paint()
            ..color =
                Color.fromARGB(255, colorList[0], colorList[1], colorList[2]));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
