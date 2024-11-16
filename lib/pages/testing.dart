import 'dart:async';
import 'package:flutter/material.dart';

class TestingPage extends StatefulWidget {
  const TestingPage({
    super.key,
  });

  @override
  State<TestingPage> createState() => _TestingPageState();
}

class _TestingPageState extends State<TestingPage> {
  final GlobalKey containerKey = GlobalKey();
  double height = 0;
  double containerYOffset = 0;

  @override
  void initState() {
    super.initState();
  }

  void moveContainerHeight(PointerMoveEvent details) {
    final RenderBox renderBox =
        containerKey.currentContext?.findRenderObject() as RenderBox;
    final Offset localPosition = renderBox.globalToLocal(details.position);
    final double containerHeight = renderBox.size.height;
    double tapY =
        (containerHeight - localPosition.dy + 100).clamp(0.0, containerHeight);
    setState(() {
      height = tapY;
    });
  }

  void animateContainer() {
    setState(() {
      containerYOffset = 0;
    });
  }

  bool isHolding = false;
  Timer? holdTimer;
  double holdProgress = 0.0;
  Duration holdDuration = const Duration(milliseconds: 500);
  Alignment align = Alignment.topCenter;
  double tapOffsetY = 0.0;

  void startHolding(PointerDownEvent details) {
    final RenderBox renderBox =
        containerKey.currentContext?.findRenderObject() as RenderBox;
    final Offset localPosition = renderBox.globalToLocal(details.position);
    final double containerHeight = renderBox.size.height;
    tapOffsetY = 1.0 - (localPosition.dy / containerHeight);

    setState(() {
      isHolding = true;
      holdProgress = 0.0;
      align = Alignment.center;
    });

    holdTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      setState(() {
        holdProgress += 16 / holdDuration.inMilliseconds;
        if (holdProgress >= 1.0) {
          stopHolding();
        }
      });
    });
  }

  void stopHolding() {
    holdTimer?.cancel();
    setState(() {
      isHolding = false;
      align = Alignment.topCenter;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          TweenAnimationBuilder(
            tween: Tween(begin: Alignment.topCenter, end: align),
            duration: const Duration(milliseconds: 300),
            builder: (context, value, child) {
              return Align(
                alignment: value,
                child: Listener(
                  onPointerDown: (event) => startHolding(event),
                  onPointerUp: (event) => stopHolding(),
                  child: Container(
                    key: containerKey,
                    width: 100,
                    height: 400,
                    color:
                        isHolding ? Colors.blue.withOpacity(0.7) : Colors.blue,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: FractionallySizedBox(
                            alignment: Alignment.bottomCenter,
                            heightFactor:
                                holdProgress * (1 - tapOffsetY) + tapOffsetY,
                            child: Container(color: Colors.green),
                          ),
                        ),
                        Center(
                          child: Text(
                            isHolding ? "HOLDING" : "HOLD",
                            style: const TextStyle(
                              fontFamily: "Nunito",
                              fontSize: 15,
                              color: Colors.white,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
