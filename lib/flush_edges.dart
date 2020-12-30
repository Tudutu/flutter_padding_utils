
import 'package:flutter/foundation.dart';

enum FlushEdges {
  none,
  start,
  end,
  top,
  bottom,
  topStart,
  topEnd,
  topHorizontal,
  bottomStart,
  bottomEnd,
  bottomHorizontal,
  horizontal,
  vertical,
  verticalStart,
  verticalEnd,
  all,
}


extension FlushEdgesExtension on FlushEdges {
  String get name => describeEnum(this);

  bool get isFlushStart =>
      this == FlushEdges.all ||
      this == FlushEdges.start ||
      this == FlushEdges.topStart ||
      this == FlushEdges.bottomStart ||
      this == FlushEdges.horizontal ||
      this == FlushEdges.bottomHorizontal ||
      this == FlushEdges.verticalStart ||
      this == FlushEdges.topHorizontal;

  bool get isFlushEnd =>
      this == FlushEdges.all ||
      this == FlushEdges.end ||
      this == FlushEdges.topEnd ||
      this == FlushEdges.bottomEnd ||
      this == FlushEdges.horizontal ||
      this == FlushEdges.bottomHorizontal ||
      this == FlushEdges.verticalEnd ||
      this == FlushEdges.topHorizontal;

  bool get isFlushTop =>
      this == FlushEdges.all ||
      this == FlushEdges.top ||
      this == FlushEdges.topEnd ||
      this == FlushEdges.topStart ||
      this == FlushEdges.topHorizontal ||
      this == FlushEdges.vertical ||
      this == FlushEdges.verticalEnd ||
      this == FlushEdges.verticalStart;

  bool get isFlushBottom =>
      this == FlushEdges.all ||
      this == FlushEdges.bottom ||
      this == FlushEdges.bottomEnd ||
      this == FlushEdges.bottomStart ||
      this == FlushEdges.bottomHorizontal ||
      this == FlushEdges.vertical ||
      this == FlushEdges.verticalEnd ||
      this == FlushEdges.verticalStart;
}

enum GapType {
  none,
  around,
  between,
  after,
  before,
}
