import 'package:piano_hero/models/box_model.dart';

List<BoxModel> initBoxModels() {
  return [
    BoxModel(0, [0], initialState: {0: BoxState.ready}),
    BoxModel(1, []), // ROW KOSONG
    BoxModel(
      2,
      [0, 1, 2, 3],
      initialState: {1: BoxState.ready},
    ),
    BoxModel(
      3,
      [0, 1, 2, 3],
      initialState: {2: BoxState.ready},
    ),
    BoxModel(
      4,
      [],
    ),
    BoxModel(
      5,
      [1],
      height: 2,
      initialState: {1: BoxState.ready},
    ),
    BoxModel(
      6,
      [0, 1, 2, 3],
      initialState: {2: BoxState.ready},
    ),
    BoxModel(
      7,
      [0, 1, 2, 3],
      initialState: {1: BoxState.ready},
    ),
    BoxModel(
      8,
      [0, 1, 2, 3],
      initialState: {0: BoxState.ready, 2: BoxState.ready},
    ),
    BoxModel(
      9,
      [0, 1, 2, 3],
      initialState: {3: BoxState.ready},
    ),
    BoxModel(
      10,
      [0, 1, 2, 3],
      initialState: {0: BoxState.ready, 2: BoxState.ready},
    ),
    BoxModel(
      11,
      [0, 1, 2, 3],
      initialState: {1: BoxState.ready},
    ),
  ];
}
