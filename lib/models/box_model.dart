enum BoxState {
  ready,
  tapped,
  missed,
  forbidden,
  forbiddenTapped,
}

class BoxModel {
  final int boxNumber;
  final double height;
  Map<int, BoxState> boxColumn;

  BoxModel(
    this.boxNumber,
    List<int> columns, {
    this.height = 4,
    Map<int, BoxState>? initialState,
    BoxState defaultState = BoxState.forbidden,
  }) : boxColumn = {
          for (var column in columns)
            column: initialState?[column] ?? defaultState
        };
}
