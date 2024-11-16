import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:piano_hero/models/box_model.dart';
import 'package:piano_hero/services/song_provider.dart';
import 'package:piano_hero/widgets/box_widget.dart';

class LineDivider extends StatelessWidget {
  const LineDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: double.infinity,
      color: Colors.white,
    );
  }
}

class PlayPage extends StatefulWidget {
  const PlayPage({super.key});

  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> with TickerProviderStateMixin {
  List<BoxModel> boxes = initBoxModels();
  int currentBoxIndex = 0;
  late AnimationController animationController;
  int score = 0;
  bool isStarted = false;
  bool isPlaying = false;
  bool showFinishDialog = false;
  AudioPlayer audioPlayer = AudioPlayer();
  double progressValue = 0.0;
  bool showLineProgress = true;
  bool isForbiddenTapped = false;
  late int boxStateReadyCount;
  double animHeight = 0;
  final GlobalKey containerKey = GlobalKey();
  Timer? timer;
  bool isHeightSet = false;

  void startIncrementing() {
    timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        animHeight += 40;
      });
    });
  }

  void stopIncrementing() {
    if (timer != null) {
      timer!.cancel();
      timer = null;
    }
  }

  void moveContainerHeight(PointerMoveEvent? details) {
    if (details == null || isHeightSet) return;
    final RenderBox renderBox =
        containerKey.currentContext?.findRenderObject() as RenderBox;
    final Offset localPosition = renderBox.globalToLocal(details.position);
    final double containerHeight = renderBox.size.height;
    double tapY =
        (containerHeight - localPosition.dy + 75).clamp(0.0, containerHeight);
    setState(() {
      animHeight = tapY;
    });
    startIncrementing();
    isHeightSet = true;
  }

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    boxStateReadyCount = boxes.fold(
        0,
        (previousValue, element) =>
            previousValue +
            element.boxColumn.values
                .where((state) => state == BoxState.ready)
                .length);

    // SET GAME SPEED
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && isPlaying) {
        // SONG FINISHED
        if (currentBoxIndex == boxes.length) {
          showLineProgress = false;
          audioPlayer.stop();
          audioPlayer.seek(Duration.zero);
          setState(() => showFinishDialog = true);
        }

        // BOX MISSED
        else if (boxes[currentBoxIndex].boxColumn.entries.any((entry) =>
            entry.value == BoxState.ready &&
            entry.value != BoxState.forbidden)) {
          setState(() {
            isStarted = false;
            showLineProgress = false;
            audioPlayer.stop();
            isPlaying = false;
            boxes[currentBoxIndex].boxColumn.updateAll((key, value) {
              if (value == BoxState.ready) {
                return BoxState.missed;
              }
              return value;
            });
          });
          animationController
              .reverse()
              .then((value) => setState(() => showFinishDialog = true));
        }

        // BOX INCREMENT
        else {
          setState(() {
            ++currentBoxIndex;
          });
          animationController.forward(from: 0);
        }
      }
    });

    audioPlayer.setAsset("sounds/9mm.wav");
  }

  @override
  void dispose() {
    timer?.cancel();
    animationController.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double containerWidth = MediaQuery.sizeOf(context).width * 0.9;
    return Stack(
      children: [
        SizedBox.expand(
          child: Image.asset(
            "images/play_background.jpg",
            fit: BoxFit.fill,
          ),
        ),
        Row(
          children: [
            drawBox(0),
            const LineDivider(),
            drawBox(1),
            const LineDivider(),
            drawBox(2),
            const LineDivider(),
            drawBox(3),
          ],
        ),
        drawScore(),
        drawLineProgress(containerWidth),
        drawCirclePoint(containerWidth),
        showFinishDialog ? drawFinishDialog() : const SizedBox(),
      ],
    );
  }

  String scoreFont = "LeagueSpartan";
  bool animatingScore = false;

  void boxPressed(BoxModel box, int column, PointerMoveEvent? details) {
    // JIKA SEMUA BOX SUDAH DITEKAN DAN STATUS BOX READY
    if (box.height != 4) {
      moveContainerHeight(details!);
    }
    bool allPreviousTapped = boxes.sublist(0, box.boxNumber).every((element) =>
        element.boxColumn.values.every((state) =>
            state == BoxState.tapped || state == BoxState.forbidden));

    // KONDISI KETIKA NORMAL BOX DI TAP
    if (allPreviousTapped &&
        box.boxColumn[column] == BoxState.ready &&
        isForbiddenTapped != true) {
      if (!isStarted) {
        setState(() {
          isPlaying = true;
          isStarted = true;
        });
        animationController.forward();
      }

      audioPlayer.play();

      setState(() {
        box.boxColumn[column] = BoxState.tapped;
        ++score;
        // TAP BOX BERSTATE READY BERIKUTNYA DI BOXCOLUMN YANG SAMA
        for (int x = box.boxNumber + 1; x < boxes.length; x++) {
          BoxModel nextBox = boxes[x];
          if (nextBox.boxColumn[column] == BoxState.ready) {
            nextBox.boxColumn[column] = BoxState.tapped;
          } else {
            // BREAK JIKA BOX SELANJUTNYA STATENYA TIDAK READY
            break;
          }
        }
        // UNTUK MENGHITUNG PROGRESS SESUAI DENGAN JUMLAH BOXSTATE READY
        int remainingBoxStateReady = boxes.fold(
            0,
            (previousValue, element) =>
                previousValue +
                element.boxColumn.values
                    .where((state) => state == BoxState.ready)
                    .length);
        progressValue =
            ((boxStateReadyCount - remainingBoxStateReady) / boxStateReadyCount)
                .clamp(0, 1.0);
        // MENGANIMASIKAN SCORE
        animatingScore = true;
        Future.delayed(const Duration(milliseconds: 100), () {
          setState(() {
            animatingScore = false;
          });
        });
      });
    }

    // KONDISI KETIKA FORBIDDEN BOX DI TAP
    if (isStarted &&
        box.boxColumn[column] == BoxState.forbidden &&
        isForbiddenTapped != true) {
      setState(() {
        isForbiddenTapped = true;
        box.boxColumn[column] = BoxState.forbiddenTapped;
        showLineProgress = false;
        audioPlayer.stop();
        isPlaying = false;
      });
      animationController
          .reverse()
          .then((value) => setState(() => showFinishDialog = true));
    }
  }

  void boxPressedUp(BoxModel box, int column) {
    stopIncrementing();
  }

  void restart() {
    setState(() {
      isForbiddenTapped = false;
      audioPlayer.seek(Duration.zero);
      showFinishDialog = false;
      isStarted = false;
      isPlaying = true;
      boxes = initBoxModels();
      score = 0;
      currentBoxIndex = 0;
      progressValue = 0;
      showLineProgress = true;
      animHeight = 0;
      isHeightSet = false;
    });
    animationController.reset();
  }

  drawBox(int rowNumber) {
    return Expanded(
      child: BoxWidget(
        rowNumber: rowNumber,
        currentBox: boxes.sublist(currentBoxIndex, boxes.length),
        animation: animationController,
        onBoxTap: (box, column, details) => boxPressed(box, column, details),
        onBoxTapUp: (box, column) => boxPressedUp(box, column),
        animHeight: animHeight,
        conKey: containerKey,
      ),
    );
  }

  drawScore() {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      height: 100,
      margin: const EdgeInsets.fromLTRB(0, 40, 0, 0),
      alignment: Alignment.center,
      child: TweenAnimationBuilder(
        tween: Tween(begin: 1.0, end: animatingScore ? 1.3 : 1.0),
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Text(
              "$score",
              style: TextStyle(
                fontFamily: scoreFont,
                fontSize: 40,
                color: Colors.white,
                decoration: TextDecoration.none,
                shadows: const [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 2,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  drawLineProgress(double width) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: width,
        // margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: TweenAnimationBuilder(
              tween: Tween(begin: 0.0, end: progressValue),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  minHeight: 7,
                  color: Colors.black,
                  backgroundColor: Colors.white,
                  value: value,
                );
              }),
        ),
      ),
    );
  }

  drawCirclePoint(double width) {
    return Align(
      alignment: Alignment.topLeft,
      child: TweenAnimationBuilder(
        tween: Tween(begin: width * progressValue, end: width * progressValue),
        duration: const Duration(milliseconds: 500),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(value, 0),
            child: Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.fromLTRB(7, 14, 0, 0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          );
        },
      ),
    );
  }

  drawFinishDialog() {
    return Align(
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () {
          restart();
        },
        child: Container(
          alignment: Alignment.center,
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height,
          color: Colors.black.withOpacity(0.3),
          child: Text(
            "Tap to restart",
            style: TextStyle(
              fontFamily: scoreFont,
              fontSize: 25,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }
}
