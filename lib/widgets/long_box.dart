import 'package:flutter/material.dart';
import 'package:piano_hero/models/box_model.dart';

// ignore: must_be_immutable
class LongBox extends StatefulWidget {
  final double height;
  final BoxState state;
  final int boxIndex;
  final Function(PointerMoveEvent) onTapDown;
  final VoidCallback onTapUp;
  final double animationHeight;
  final GlobalKey containerKey;
  const LongBox({
    super.key,
    required this.height,
    required this.state,
    required this.boxIndex,
    required this.onTapDown,
    required this.onTapUp,
    required this.animationHeight,
    required this.containerKey
  });

  @override
  State<LongBox> createState() => _LongBoxState();
}

class _LongBoxState extends State<LongBox> {
  Color get color {
    switch (widget.state) {
      case BoxState.ready:
        return Colors.blue;
      case BoxState.tapped:
        return Colors.blue.withOpacity(0.3);
      case BoxState.missed:
        return Colors.red;
      case BoxState.forbidden:
        return Colors.transparent;
      case BoxState.forbiddenTapped:
        return Colors.red.withOpacity(0.3);
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: widget.height,
      child: Listener(
        onPointerUp: (_) {
          widget.onTapUp();
        },
        onPointerMove: (PointerMoveEvent event) {
          widget.onTapDown(event);
        },
        child: Container(
          key: widget.containerKey,
          alignment: Alignment.bottomCenter,
          color: color,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 50),
            height: widget.animationHeight,
            decoration: const BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(100),
                topRight: Radius.circular(100),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
