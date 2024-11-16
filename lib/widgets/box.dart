import 'package:flutter/material.dart';
import 'package:piano_hero/models/box_model.dart';

class Box extends StatelessWidget {
  final double height;
  final BoxState state;
  final int boxIndex;
  final VoidCallback onTapDown;
  const Box({
    super.key,
    required this.height,
    required this.state,
    required this.boxIndex,
    required this.onTapDown,
  });

  Color get color {
    switch (state) {
      case BoxState.ready:
        return Colors.black;
      case BoxState.tapped:
        return Colors.black.withOpacity(0.3);
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
      height: height,
      child: Listener(
        onPointerDown: (_) => onTapDown(),
        child: Container(
          alignment: Alignment.center,
          color: color,
          child: Text(
            boxIndex == 0 ? "Start" : "",
            style: const TextStyle(
              fontFamily: "Nunito",
              fontSize: 20,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }
}
