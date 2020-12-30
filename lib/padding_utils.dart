library flutter_padding_utils;
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'flush_edges.dart';

/// The paddings of adjacent siblings are sometimes combined (collapsed)
/// into a single padding whose size is the largest of the individual paddings
/// (or just one of them, if they are equal), a behavior known as margin collapsing.
List<EdgeInsets> collapseEdgeInsets(
    Iterable<EdgeInsetsGeometry> paddings, Axis axis,
    {TextDirection textDirection = TextDirection.ltr,
    PaddingCollapseDistribution distribution}) {
  assert(axis != null);
  assert(textDirection != null);

  // Use a default for the distribution.
  distribution =
      distribution ?? PaddingCollapseDistribution.fromFirstFraction(1);

  // Return null if paddings is null
  if (paddings == null) return null;

  // Return an empty list if no elements.
  if (paddings.isEmpty) return [];

  // First convert all the EdgeInsetsGeometry items to direction-specific
  // EdgeInsets objects.
  final edgeInsets = _resolveAll(paddings, textDirection);

  // Convenience variable
  final horizontal = axis == Axis.horizontal;

  // Loop over each item and change the adjoining paddings to fit the
  // largest value of the two.
  // The first item will remain unchanged if it is the only item, so put a copy
  // in the result list and start the loop from the second item.
  final result = <EdgeInsets>[edgeInsets[0].copyWith()];
  for (var i = 1; i < edgeInsets.length; i++) {
    // Take the first item from the result list as it may already have been
    // altered.
    final p0 = result[i - 1];
    // Take the current item from the original list to be copied.
    final p1 = edgeInsets[i];

    // Find the largest of the two adjoining edges as specified by the axis.
    final largest =
        horizontal ? math.max(p0.right, p1.left) : math.max(p0.bottom, p1.top);

    // Set the first item to have the largest padding along the adjoining edge.
    final first = horizontal
        ? p0.copyWith(right: distribution.first(p0.right, p1.left, largest))
        : p0.copyWith(bottom: distribution.first(p0.bottom, p1.top, largest));
    // Set the second item to have zero padding along the adjoining edge
    // so that the total padding of both combined is equal to the largest.
    final second = horizontal
        ? p1.copyWith(left: distribution.second(p0.right, p1.left, largest))
        : p1.copyWith(top: distribution.second(p0.bottom, p1.top, largest));

    // Put the items in the result list by index.
    result[i - 1] = first;
    result.add(second);
  }

  return result;
}

/// Collapse adjacent padding sides into gaps, the collapsed (max) value of
/// each of the adjoining sizes.
List<double> collapseToGaps(Iterable<EdgeInsetsGeometry> paddings, Axis axis,
    {TextDirection textDirection = TextDirection.ltr}) {
  assert(axis != null);
  assert(textDirection != null);

  // Return null if paddings is null
  if (paddings == null) return null;

  // Return an empty list if no elements.
  if (paddings.isEmpty) return [];

  // First convert all the EdgeInsetsGeometry items to direction-specific
  // EdgeInsets objects.
  final edgeInsets = _resolveAll(paddings, textDirection);

  // Convenience variable
  final horizontal = axis == Axis.horizontal;

  // Loop over each item and take the maximum value of each adjoining gap
  // by taking the right/left values of adjacent paddings.
  final result = <double>[
    if (horizontal) edgeInsets[0].left else edgeInsets[0].top
  ];
  for (var i = 1; i < edgeInsets.length; i++) {
    final p0 = edgeInsets[i - 1] ?? EdgeInsets.zero;
    final p1 = edgeInsets[i] ?? EdgeInsets.zero;

    // Find the largest of the two adjoining edges as specified by the axis.
    final largest =
        horizontal ? math.max(p0.right, p1.left) : math.max(p0.bottom, p1.top);
    result.add(largest);
  }

  final last = edgeInsets[edgeInsets.length - 1] ?? EdgeInsets.zero;
  result.add(horizontal ? last.right : last.bottom);

  return result;
}

class PaddingCollapseDistribution {
  final _Distributor _distributor;

  PaddingCollapseDistribution._(this._distributor);

  PaddingCollapseDistribution.fromFirstFraction(double firstFraction)
      : assert(firstFraction <= 1.0),
        _distributor =
            _FractionalDistributor(firstFraction, 1.0 - firstFraction);

  PaddingCollapseDistribution.fromSecondFraction(double secondFraction)
      : assert(secondFraction <= 1.0),
        _distributor =
            _FractionalDistributor(1.0 - secondFraction, secondFraction);

  PaddingCollapseDistribution.fromRatio(double first, double second)
      : _distributor = _FractionalDistributor(
            first / (first + second), second / (first + second));

  PaddingCollapseDistribution.maxFromFirst()
      : _distributor = _DifferenceDistributor(true);

  PaddingCollapseDistribution.maxFromSecond()
      : _distributor = _DifferenceDistributor(false);

  PaddingCollapseDistribution flip() {
    return PaddingCollapseDistribution._(_distributor.flip());
  }

  double first(double originalFirst, double originalSecond, double max) {
    return _distributor.first(originalFirst, originalSecond, max);
  }

  double second(double originalFirst, double originalSecond, double max) {
    return _distributor.second(originalFirst, originalSecond, max);
  }
}

abstract class _Distributor {
  const _Distributor();

  double first(double originalFirst, double originalSecond, double max);
  double second(double originalFirst, double originalSecond, double max);
  _Distributor flip();
}

class _FractionalDistributor extends _Distributor {
  final double firstFraction;
  final double secondFraction;

  const _FractionalDistributor(this.firstFraction, this.secondFraction);

  @override
  double first(double originalFirst, double originalSecond, double max) {
    return max * firstFraction;
  }

  @override
  double second(double originalFirst, double originalSecond, double max) {
    return max * secondFraction;
  }

  @override
  _Distributor flip() {
    return _FractionalDistributor(secondFraction, firstFraction);
  }
}

class _DifferenceDistributor extends _Distributor {
  final bool maxFirst;

  _DifferenceDistributor(this.maxFirst);

  @override
  double first(double originalFirst, double originalSecond, double max) {
    return maxFirst ? originalFirst : math.max(0, max - originalSecond);
  }

  @override
  double second(double originalFirst, double originalSecond, double max) {
    return maxFirst ? math.max(0, max - originalFirst) : originalSecond;
  }

  @override
  _Distributor flip() {
    return _DifferenceDistributor(!this.maxFirst);
  }
}

enum OuterPaddingSize { max, min }

EdgeInsets outerPadding(Iterable<EdgeInsetsGeometry> paddings, Axis axis,
    {TextDirection textDirection = TextDirection.ltr,
    OuterPaddingSize outerPaddingSize = OuterPaddingSize.max}) {
  assert(axis != null);
  assert(textDirection != null);

  // Return null if paddings is null
  if (paddings == null) return null;

  // Return EdgeInsets.zero if no elements.
  if (paddings.isEmpty) return EdgeInsets.zero;

  // Return the first item if one element.
  if (paddings.length == 1) return paddings.first.resolve(textDirection);

  // First convert all the EdgeInsetsGeometry items to direction-specific
  // EdgeInsets objects.
  final edgeInsets = _resolveAll(paddings, textDirection);

  final horizontal = axis == Axis.horizontal;

  double compare(double x, double y) => outerPaddingSize == OuterPaddingSize.max
      ? math.max(x, y)
      : math.min(x, y);

  EdgeInsets result;
  bool isFirst = true;
  for (var current in edgeInsets) {
    // Copy first one over as-is.
    if (isFirst) {
      result = current;
      isFirst = false;
      continue;
    }

    if (horizontal) {
      result = result.copyWith(
        // left: Leave the left value as the first one
        top: compare(current.top, result.top),
        bottom: compare(current.bottom, result.bottom),
        // Always use the latest value for the right value
        right: current.right,
      );
    } else {
      result = result.copyWith(
        // top: Leave the top value as the first one
        left: compare(current.left, result.left),
        right: compare(current.right, result.right),
        // Always use the latest value for the right value
        bottom: current.bottom,
      );
    }
  }

  return result;
}

EdgeInsets maxEdgeInsets(EdgeInsets a, EdgeInsets b) {
  if(a == null && b == null)
    return null;
  if(a == null && b != null)
    return b;
  if(b == null && a != null)
    return a;
  return EdgeInsets.only(
    left: math.max(a.left, b.left),
    top: math.max(a.top, b.top),
    right: math.max(a.right, b.right),
    bottom: math.max(a.bottom, b.bottom),
  );
}

EdgeInsets minEdgeInsets(EdgeInsets a, EdgeInsets b) {
  if(a == null && b == null)
    return null;
  if(a == null && b != null)
    return b;
  if(b == null && a != null)
    return a;
  return EdgeInsets.only(
    left: math.min(a.left, b.left),
    top: math.min(a.top, b.top),
    right: math.min(a.right, b.right),
    bottom: math.min(a.bottom, b.bottom),
  );
}

/// Splits an EdgeInsets instance into multiple EdgeInsets instances, which when
/// placed adjacent to each other along the axis specified would be the equivalent
/// to the initial EdgeInsets instance.
List<EdgeInsets> splitEdgeInsets(EdgeInsets edgeInsets, Axis axis,
    {int noOfParts = 2}) {
  // If noOfParts is 0, return zero parts, i.e. an empty array.
  if (noOfParts == 0) {
    return <EdgeInsets>[];
  }

  // If noOfParts is 1, return a copy of the original value unsplit.
  if (noOfParts == 1) {
    return [edgeInsets.copyWith()];
  }

  if (axis == Axis.horizontal) {
    return [
      EdgeInsets.fromLTRB(
          edgeInsets.left, edgeInsets.top, 0.0, edgeInsets.bottom),
      for (var i = 1; i < noOfParts - 1; i++)
        EdgeInsets.fromLTRB(0.0, edgeInsets.top, 0.0, edgeInsets.bottom),
      EdgeInsets.fromLTRB(
          0.0, edgeInsets.top, edgeInsets.right, edgeInsets.bottom),
    ];
  } else {
    // Vertical
    return [
      EdgeInsets.fromLTRB(
          edgeInsets.left, edgeInsets.top, edgeInsets.right, 0.0),
      for (var i = 1; i < noOfParts - 1; i++)
        EdgeInsets.fromLTRB(edgeInsets.left, 0.0, edgeInsets.right, 0.0),
      EdgeInsets.fromLTRB(
          edgeInsets.left, 0.0, edgeInsets.right, edgeInsets.bottom),
    ];
  }
}

EdgeInsetsGeometry onlyEdgeInsetsAlongAxis(EdgeInsetsGeometry edgeInsets, Axis axis,
    {TextDirection textDirection = TextDirection.ltr}) {
  var resolved = edgeInsets.resolve(textDirection).copyWith();
  if (axis == Axis.vertical) {
    return EdgeInsets.only(
      top: resolved.top,
      bottom: resolved.bottom,
    );
  } else {
    return EdgeInsets.only(
      left: resolved.left,
      right: resolved.right,
    );
  }
}

EdgeInsetsGeometry flushEdgeInsets(EdgeInsetsGeometry edgeInsets, FlushEdges flushEdges,
    {TextDirection textDirection = TextDirection.ltr}) {

  final resolved = edgeInsets.resolve(textDirection);
  final isFlushLeft = textDirection == TextDirection.ltr ? flushEdges.isFlushStart : flushEdges.isFlushEnd;
  final isFlushRight = textDirection == TextDirection.ltr ? flushEdges.isFlushEnd : flushEdges.isFlushStart;
  
  final result = resolved.copyWith(
    left: isFlushLeft ? 0 : resolved.left,
    right: isFlushRight ? 0 : resolved.right,
    top: flushEdges.isFlushTop ? 0 : resolved.top,
    bottom: flushEdges.isFlushBottom ? 0 : resolved.bottom,
  );
  return result;
}

EdgeInsets conditionalZero(bool condition, EdgeInsets edgeInsets) {
  return condition ?
    edgeInsets ?? EdgeInsets.zero 
    : EdgeInsets.zero;
}

extension EdgeInsetsGeometryExtensions on EdgeInsetsGeometry {
  List<EdgeInsets> collapseWith(EdgeInsetsGeometry other, Axis axis,
      {TextDirection textDirection = TextDirection.ltr,
      PaddingCollapseDistribution distribution}) {
    return collapseEdgeInsets([this, other], axis,
        textDirection: textDirection, distribution: distribution);
  }

  List<EdgeInsets> split(Axis axis, {int noOfParts = 2}) {
    return splitEdgeInsets(this, axis, noOfParts: noOfParts);
  }
  
  EdgeInsetsGeometry flush(FlushEdges flushEdges,
    {TextDirection textDirection = TextDirection.ltr}) {
    return flushEdgeInsets(this, flushEdges, textDirection: textDirection);
  }

  EdgeInsetsGeometry onlyAlongAxis(Axis axis,
    {TextDirection textDirection = TextDirection.ltr}) {
    return onlyEdgeInsetsAlongAxis(this, axis, textDirection: textDirection);
  }

  EdgeInsetsGeometry flip(Axis axis) {
    if (this is EdgeInsets) {
      EdgeInsets e = this;
      return axis == Axis.horizontal
          ? e.copyWith(left: e.right, right: e.left)
          : e.copyWith(top: e.bottom, bottom: e.top);
    } else if (this is EdgeInsetsDirectional) {
      EdgeInsetsDirectional e = this;
      return axis == Axis.horizontal
          ? EdgeInsetsDirectional.only(
              start: e.end,
              end: e.start,
              top: e.top,
              bottom: e.bottom,
            )
          : EdgeInsetsDirectional.only(
              start: e.start,
              end: e.end,
              top: e.bottom,
              bottom: e.top,
            );
    } else {
      return this;
    }
  }
}

List<EdgeInsets> _resolveAll(List<EdgeInsetsGeometry> edgeInsets, TextDirection textDirection) {
  return edgeInsets.map((p) => p != null ? p.resolve(textDirection) : null).toList();
} 