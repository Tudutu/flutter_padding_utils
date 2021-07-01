import 'package:flutter/painting.dart';
import 'package:flutter_padding_utils/flutter_padding_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('collapseEdgeInsets', () {
    test('returns a empty list unchanged.', () {
      final paddings = <EdgeInsetsGeometry>[];
      final result = collapseEdgeInsets(paddings, Axis.horizontal);
      expect(result.length, equals(0));
    });

    test('returns a single item unchanged.', () {
      final padding = EdgeInsets.fromLTRB(10, 20, 30, 40);
      final result = collapseEdgeInsets([padding], Axis.horizontal);
      expect(result.length, equals(1),
          reason: 'Length of paddings is not correct.');
      expect(result[0], equals(EdgeInsets.fromLTRB(10, 20, 30, 40)),
          reason:
              'Returned padding does not have the same values as the original.');
      expect(result[0], isNot(same(padding)),
          reason:
              'Returned padding is the same instance as the original and not a copy.');
    });

    test('returns list of EdgeInsets of same length as original.', () {
      final paddings = [EdgeInsets.zero, EdgeInsetsDirectional.zero];
      final result = collapseEdgeInsets(paddings, Axis.horizontal);
      expect(result.length, equals(paddings.length),
          reason: 'Length of paddings is not the same.');
      for (var item in result) {
        expect(item is EdgeInsets, equals(true),
            reason: 'item is not of correct type.');
      }
    });

    test('collapses inner padding horizontally.', () {
      final size = 10.0;
      final paddings = [
        EdgeInsets.only(right: 6),
        EdgeInsetsDirectional.only(start: size)
      ];
      final result = collapseEdgeInsets(paddings, Axis.horizontal);
      expect(result[0].right + result[1].left, equals(size),
          reason: 'Collapsed padding size is incorrect.');
    });

    test(
        'doesn\'t collapse padding horizontally when vertical collapse is requested.',
        () {
      final paddings = [
        EdgeInsets.only(right: 6),
        EdgeInsetsDirectional.only(start: 10, end: 8),
        EdgeInsets.only(left: 12),
      ];
      final result = collapseEdgeInsets(paddings, Axis.vertical);
      expect(result[0].right + result[1].left, equals(16.0),
          reason: 'Collapsed padding size is incorrect.');
      expect(result[1].right + result[2].left, equals(20.0),
          reason: 'Collapsed padding size is incorrect.');
    });

    test('collapses inner padding vertically.', () {
      final paddings = [
        EdgeInsets.only(bottom: 6),
        EdgeInsetsDirectional.only(top: 10, bottom: 10),
        EdgeInsets.only(top: 15, bottom: 10),
      ];
      final result = collapseEdgeInsets(paddings, Axis.vertical);
      expect(result[0].bottom + result[1].top, equals(10.0),
          reason: 'Collapsed padding size is incorrect.');
      expect(result[1].bottom + result[2].top, equals(15.0),
          reason: 'Collapsed padding size is incorrect.');
    });

    test(
        'doesn\'t collapse padding vertically when horizontal collapse is requested.',
        () {
      final paddings = [
        EdgeInsets.only(bottom: 6),
        EdgeInsetsDirectional.only(top: 10)
      ];
      final expectedSize = 16.0;
      final result = collapseEdgeInsets(paddings, Axis.horizontal);
      expect(result[0].bottom + result[1].top, equals(expectedSize),
          reason: 'Collapsed padding size is incorrect.');
    });

    test('collapses inner padding with correct proportions.', () {
      final paddings = [
        EdgeInsets.only(bottom: 6),
        EdgeInsetsDirectional.only(top: 10, bottom: 10),
        EdgeInsets.only(top: 15, bottom: 10),
      ];
      final result = collapseEdgeInsets(paddings, Axis.vertical,
          distribution: PaddingCollapseDistribution.fromFirstFraction(0.5));
      expect(result[0].bottom, equals(5.0),
          reason: 'Collapsed padding size is incorrect.');
      expect(result[1].top, equals(5.0),
          reason: 'Collapsed padding size is incorrect.');
      expect(result[1].bottom, equals(7.5),
          reason: 'Collapsed padding size is incorrect.');
      expect(result[2].top, equals(7.5),
          reason: 'Collapsed padding size is incorrect.');
    });

    test('collapses inner padding by allowing max from the first.', () {
      final paddings = [
        EdgeInsets.only(bottom: 6),
        EdgeInsetsDirectional.only(top: 10, bottom: 10),
        EdgeInsets.only(top: 15, bottom: 10),
      ];
      final result = collapseEdgeInsets(paddings, Axis.vertical,
          distribution: PaddingCollapseDistribution.maxFromFirst());
      expect(result[0].bottom, equals(6.0),
          reason: 'Collapsed padding size is incorrect.');
      expect(result[1].top, equals(4.0),
          reason: 'Collapsed padding size is incorrect.');
      expect(result[1].bottom, equals(10),
          reason: 'Collapsed padding size is incorrect.');
      expect(result[2].top, equals(5.0),
          reason: 'Collapsed padding size is incorrect.');
    });

    test('collapses inner padding by allowing max from the second.', () {
      final paddings = [
        EdgeInsets.only(bottom: 16),
        EdgeInsetsDirectional.only(top: 10, bottom: 20),
        EdgeInsets.only(top: 15, bottom: 10),
      ];
      final result = collapseEdgeInsets(paddings, Axis.vertical,
          distribution: PaddingCollapseDistribution.maxFromSecond());
      expect(result[0].bottom, equals(6),
          reason: 'Collapsed padding size is incorrect.');
      expect(result[1].top, equals(10.0),
          reason: 'Collapsed padding size is incorrect.');
      expect(result[1].bottom, equals(5),
          reason: 'Collapsed padding size is incorrect.');
      expect(result[2].top, equals(15.0),
          reason: 'Collapsed padding size is incorrect.');
    });
  });

  group('collapseToGaps', () {
    test('returns a empty list unchanged.', () {
      final paddings = <EdgeInsetsGeometry>[];
      final result = collapseToGaps(paddings, Axis.horizontal);
      expect(result.length, equals(0));
    });

    test('processes a single item horizontally.', () {
      final padding = EdgeInsets.fromLTRB(10, 20, 30, 40);
      final result = collapseToGaps([padding], Axis.horizontal);
      expect(result.length, equals(2),
          reason: 'Length of paddings is not correct.');
      expect(result, equals([10, 30]));
    });

    test('processes a single item vertically.', () {
      final padding = EdgeInsets.fromLTRB(10, 20, 30, 40);
      final result = collapseToGaps([padding], Axis.vertical);
      expect(result.length, equals(2),
          reason: 'Length of paddings is not correct.');
      expect(result, equals([20.0, 40.0]));
    });

    test('returns list of gaps of a correct length.', () {
      final paddings = [EdgeInsets.zero, EdgeInsetsDirectional.zero];
      final result = collapseToGaps(paddings, Axis.horizontal);
      expect(result.length, equals(paddings.length + 1),
          reason: 'Length of paddings is incorrect.');
      for (var item in result) {
        expect(item is double, equals(true),
            reason: 'item is not of correct type.');
      }
    });

    test('collapses inner padding horizontally.', () {
      final paddings = [
        EdgeInsets.only(right: 6),
        EdgeInsetsDirectional.only(start: 10.0)
      ];
      final result = collapseToGaps(paddings, Axis.horizontal);
      expect(result, equals([0, 10, 0]));
    });

    test('collapses inner padding vertically.', () {
      final paddings = [
        EdgeInsets.only(bottom: 6),
        EdgeInsetsDirectional.only(top: 10, bottom: 10),
        EdgeInsets.only(top: 15, bottom: 10),
      ];
      final result = collapseToGaps(paddings, Axis.vertical);
      expect(result, equals([0.0, 10.0, 15.0, 10.0]));
    });
  });

  group('outerPadding', () {
    test('returns EdgeInsets.zero if list is empty.', () {
      final paddings = <EdgeInsetsGeometry>[];
      final result = outerPadding(paddings, Axis.horizontal);
      expect(result, equals(EdgeInsets.zero));
    });

    test('returns the first item if one element given.', () {
      final paddings = <EdgeInsetsGeometry>[EdgeInsets.all(5)];
      final result = outerPadding(paddings, Axis.horizontal);
      expect(result, equals(paddings[0]));
    });

    group('combines multiple paddings into outerpadding', () {
      test('using the max values horizontally', () {
        expect(
            outerPadding([
              EdgeInsets.all(1),
              EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
              EdgeInsets.only(top: 15, bottom: 10),
            ], Axis.horizontal, outerPaddingSize: OuterPaddingSize.max),
            equals(EdgeInsets.fromLTRB(1, 15, 0, 10)));
        expect(
            outerPadding([
              EdgeInsets.all(10),
              EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
              EdgeInsets.only(right: 10),
            ], Axis.horizontal, outerPaddingSize: OuterPaddingSize.max),
            equals(EdgeInsets.all(10)));
      });

      test('using the min values horizontally', () {
        expect(
            outerPadding([
              EdgeInsets.all(1),
              EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
              EdgeInsets.only(top: 15, bottom: 10, right: 20),
            ], Axis.horizontal, outerPaddingSize: OuterPaddingSize.min),
            equals(EdgeInsets.fromLTRB(1, 1, 20, 1)));
        expect(
            outerPadding([
              EdgeInsets.all(0),
              EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
              EdgeInsets.only(top: 15, bottom: 10, right: 0),
            ], Axis.horizontal, outerPaddingSize: OuterPaddingSize.min),
            equals(EdgeInsets.zero));
      });

      test('using the max values vertically', () {
        expect(
            outerPadding([
              EdgeInsets.all(5),
              EdgeInsetsDirectional.fromSTEB(20, 2, 20, 2),
              EdgeInsets.only(top: 15, bottom: 10, right: 15),
            ], Axis.vertical, outerPaddingSize: OuterPaddingSize.max),
            equals(EdgeInsets.fromLTRB(20, 5, 20, 10)));
        expect(
            outerPadding([
              EdgeInsets.all(10),
              EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
              EdgeInsets.only(bottom: 10),
            ], Axis.vertical, outerPaddingSize: OuterPaddingSize.max),
            equals(EdgeInsets.all(10)));
      });

      test('using the min values vertically', () {
        expect(
            outerPadding([
              EdgeInsets.all(5),
              EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
              EdgeInsets.only(top: 15, bottom: 10, right: 20),
            ], Axis.vertical, outerPaddingSize: OuterPaddingSize.min),
            equals(EdgeInsets.fromLTRB(0, 5, 2, 10)));
        expect(
            outerPadding([
              EdgeInsets.all(0),
              EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
              EdgeInsets.only(top: 15, bottom: 0, right: 20),
            ], Axis.vertical, outerPaddingSize: OuterPaddingSize.min),
            equals(EdgeInsets.all(0)));
      });
    });
  });

  group('EdgeInsetsGeometry.collapse', () {
    test('collapses inner padding horizontally.', () {
      final size = 10.0;
      final result = EdgeInsets.only(right: 6).collapseWith(
          EdgeInsetsDirectional.only(start: size), Axis.horizontal);
      expect(result[0].right + result[1].left, equals(size),
          reason: 'Collapsed padding size is incorrect.');
    });
  });

  group('maxEdgeInsets', () {
    test('returns the max size from combining two EdgeInsets', () {
      expect(maxEdgeInsets(EdgeInsets.all(1), EdgeInsets.zero),
          equals(EdgeInsets.all(1)));
      expect(
          maxEdgeInsets(EdgeInsets.symmetric(horizontal: 10),
              EdgeInsets.symmetric(vertical: 10)),
          equals(EdgeInsets.all(10)));
    });
  });

  group('minEdgeInsets', () {
    test('returns the min size from combining two EdgeInsets', () {
      expect(minEdgeInsets(EdgeInsets.all(1), EdgeInsets.zero),
          equals(EdgeInsets.zero));
      expect(
          minEdgeInsets(EdgeInsets.symmetric(horizontal: 10),
              EdgeInsets.symmetric(vertical: 10)),
          equals(EdgeInsets.zero));
    });
  });

  group('splitEdgeInsets', () {
    test('splits an EdgeInsets instance into 2 instances horizontally', () {
      final edgeInsets = EdgeInsets.fromLTRB(10, 20, 30, 40);
      expect(
          splitEdgeInsets(edgeInsets, Axis.horizontal),
          equals([
            EdgeInsets.fromLTRB(10, 20, 0, 40),
            EdgeInsets.fromLTRB(0, 20, 30, 40),
          ]));
    });
    test('splits an EdgeInsets instance into 2 instances vertically', () {
      final edgeInsets = EdgeInsets.fromLTRB(10, 20, 30, 40);
      expect(
          splitEdgeInsets(edgeInsets, Axis.vertical),
          equals([
            EdgeInsets.fromLTRB(10, 20, 30, 0),
            EdgeInsets.fromLTRB(10, 0, 30, 40),
          ]));
    });
    test('splits an EdgeInsets instance into multiple instances horizontally',
        () {
      final edgeInsets = EdgeInsets.fromLTRB(10, 20, 30, 40);
      expect(
          edgeInsets.split(Axis.horizontal, noOfParts: 3),
          equals([
            EdgeInsets.fromLTRB(10, 20, 0, 40),
            EdgeInsets.fromLTRB(0, 20, 0, 40),
            EdgeInsets.fromLTRB(0, 20, 30, 40),
          ]));
    });
    test('splits an EdgeInsets instance into multiple instances vertically',
        () {
      final edgeInsets = EdgeInsets.fromLTRB(10, 20, 30, 40);
      expect(
          edgeInsets.split(Axis.vertical, noOfParts: 4),
          equals([
            EdgeInsets.fromLTRB(10, 20, 30, 0),
            EdgeInsets.fromLTRB(10, 0, 30, 0),
            EdgeInsets.fromLTRB(10, 0, 30, 0),
            EdgeInsets.fromLTRB(10, 0, 30, 40),
          ]));
    });
  });

  group('flip', () {
    test('flips an EdgeInsets instance along its horizontal axis', () {
      final edgeInsets = EdgeInsets.fromLTRB(10, 20, 30, 40);
      expect(edgeInsets.flip(Axis.horizontal),
          equals(EdgeInsets.fromLTRB(30, 20, 10, 40)));
    });
    test('flips an EdgeInsets instance along its vertical axis', () {
      final edgeInsets = EdgeInsets.fromLTRB(10, 20, 30, 40);
      expect(edgeInsets.flip(Axis.vertical),
          equals(EdgeInsets.fromLTRB(10, 40, 30, 20)));
    });
  });

  group('flush', () {
    group('flushes edges using FlushEdges', () {
      test('all', () {
        final edgeInsets = EdgeInsets.all(10);
        expect(edgeInsets.flush(FlushEdges.all), equals(EdgeInsets.all(0)));
      });
      test('bottom', () {
        final edgeInsets = EdgeInsets.all(10);
        expect(edgeInsets.flush(FlushEdges.bottom),
            equals(EdgeInsets.fromLTRB(10, 10, 10, 0)));
      });
      test('bottomEnd', () {
        final edgeInsets = EdgeInsets.all(10);
        expect(edgeInsets.flush(FlushEdges.bottomEnd),
            equals(EdgeInsets.fromLTRB(10, 10, 0, 0)));
      });
      test('bottomStart', () {
        final edgeInsets = EdgeInsets.all(10);
        expect(edgeInsets.flush(FlushEdges.bottomStart),
            equals(EdgeInsets.fromLTRB(0, 10, 10, 0)));
      });
      test('bottomHorizontal', () {
        final edgeInsets = EdgeInsets.all(10);
        expect(edgeInsets.flush(FlushEdges.bottomHorizontal),
            equals(EdgeInsets.fromLTRB(0, 10, 0, 0)));
      });
      test('end', () {
        final edgeInsets = EdgeInsets.all(10);
        expect(edgeInsets.flush(FlushEdges.end),
            equals(EdgeInsets.fromLTRB(10, 10, 0, 10)));
      });
      test('horizontal', () {
        final edgeInsets = EdgeInsets.all(10);
        expect(edgeInsets.flush(FlushEdges.horizontal),
            equals(EdgeInsets.fromLTRB(0, 10, 0, 10)));
      });
      test('none', () {
        final edgeInsets = EdgeInsets.all(10);
        expect(edgeInsets.flush(FlushEdges.none), equals(EdgeInsets.all(10)));
      });
      test('start', () {
        final edgeInsets = EdgeInsets.all(10);
        expect(edgeInsets.flush(FlushEdges.start),
            equals(EdgeInsets.fromLTRB(0, 10, 10, 10)));
      });
      test('top', () {
        final edgeInsets = EdgeInsets.all(10);
        expect(edgeInsets.flush(FlushEdges.top),
            equals(EdgeInsets.fromLTRB(10, 0, 10, 10)));
      });
      test('topEnd', () {
        final edgeInsets = EdgeInsets.all(10);
        expect(edgeInsets.flush(FlushEdges.topEnd),
            equals(EdgeInsets.fromLTRB(10, 0, 0, 10)));
      });
      test('topHorizontal', () {
        final edgeInsets = EdgeInsets.all(10);
        expect(edgeInsets.flush(FlushEdges.topHorizontal),
            equals(EdgeInsets.fromLTRB(0, 0, 0, 10)));
      });
      test('topStart', () {
        final edgeInsets = EdgeInsets.all(10);
        expect(edgeInsets.flush(FlushEdges.topStart),
            equals(EdgeInsets.fromLTRB(0, 0, 10, 10)));
      });
      test('vertical', () {
        final edgeInsets = EdgeInsets.all(10);
        expect(edgeInsets.flush(FlushEdges.vertical),
            equals(EdgeInsets.fromLTRB(10, 0, 10, 0)));
      });
      test('verticalEnd', () {
        final edgeInsets = EdgeInsets.all(10);
        expect(edgeInsets.flush(FlushEdges.verticalEnd),
            equals(EdgeInsets.fromLTRB(10, 0, 0, 0)));
      });
      test('verticalStart', () {
        final edgeInsets = EdgeInsets.all(10);
        expect(edgeInsets.flush(FlushEdges.verticalStart),
            equals(EdgeInsets.fromLTRB(0, 0, 10, 0)));
      });
    });
  });

  group('conditionalZero', () {
    test('returns EdgeInsets.zero if conditional is false', () {
      expect(
          conditionalZero(false, EdgeInsets.all(10)), equals(EdgeInsets.zero));
    });
    test(
        'returns edgeInsets parameter if conditional is true and edgeInsets is not null',
        () {
      expect(conditionalZero(true, EdgeInsets.all(10)),
          equals(EdgeInsets.all(10)));
    });
  });
}
