import 'package:flutter/material.dart';
import 'package:piano_hero/models/box_model.dart';
import 'package:piano_hero/widgets/box.dart';
import 'package:piano_hero/widgets/long_box.dart';

class BoxWidget extends AnimatedWidget {
  final int rowNumber;
  final List<BoxModel> currentBox;
  final Function(BoxModel, int, PointerMoveEvent?) onBoxTap;
  final Function(BoxModel, int) onBoxTapUp;
  final double animHeight;
  final GlobalKey conKey;
  const BoxWidget({
    super.key,
    required this.rowNumber,
    required this.currentBox,
    required Animation<double> animation,
    required this.onBoxTap,
    required this.onBoxTapUp,
    required this.animHeight,
    required this.conKey,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    // SET BOX HEIGHT
    double deviceHeight = MediaQuery.sizeOf(context).height;
    double boxHeight = deviceHeight / 4;

    // GET BOX FOR THAT COLUMN
    List<BoxModel> thisRowBox = currentBox
        .where((element) => element.boxColumn.containsKey(rowNumber))
        .toList();

    Animation<double> animation = super.listenable as Animation<double>;

    // MAP BOXES TO WIDGET
    List<Widget> boxes = thisRowBox.map((e) {
      int index = currentBox.indexOf(e);
      double offset = (3 - index + animation.value) * boxHeight;
      BoxState state = e.boxColumn[rowNumber] ?? BoxState.ready;
      return Transform.translate(
        offset: Offset(0, offset),
        child: e.height != 4
            ? LongBox(
                height: deviceHeight / e.height,
                state: state,
                boxIndex: e.boxNumber,
                onTapDown: (PointerMoveEvent event) => onBoxTap(e, rowNumber, event),
                onTapUp: () => onBoxTapUp(e, rowNumber),
                animationHeight: animHeight,
                containerKey: conKey,
              )
            : Box(
                height: boxHeight,
                state: state,
                boxIndex: e.boxNumber,
                onTapDown: () => onBoxTap(e, rowNumber, null),
              ),
      );
    }).toList();

    return SizedBox.expand(
      child: Stack(
        children: boxes,
      ),
    );
  }
}
