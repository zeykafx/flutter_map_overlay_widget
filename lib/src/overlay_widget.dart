library flutter_map_overlay_widget;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Base class for all overlay Widgets
@immutable
sealed class BaseOverlayWidget extends StatelessWidget {
  /// The [ImageProvider] for the image.
  final Widget child;

  /// The opacity in which the image should get rendered on the map.
  final double opacity;

  /// Whether to continue showing the old image (true), or briefly show nothing
  /// (false), when the image provider changes. The default value is false.
  final bool gaplessPlayback;

  const BaseOverlayWidget({
    super.key,
    required this.child,
    this.opacity = 1,
    this.gaplessPlayback = false,
  });

  Widget _render(
    BuildContext context, {
    required Widget child,
    required MapCamera camera,
  });

  @override
  @nonVirtual
  Widget build(BuildContext context) => _render(
        context,
        child: child,
        camera: MapCamera.of(context),
      );
}

/// Unrotated overlay image that spans between a given bounding box.
///
/// The shortest side of the image will be placed along the shortest side of the
/// bounding box to minimize distortion.
@immutable
class OverlayWidget extends BaseOverlayWidget {
  /// The latitude / longitude corners of the image.
  final LatLngBounds bounds;

  /// Create a new [OverlayWidget] used for the [OverlayWidgetLayer].
  const OverlayWidget({
    super.key,
    required super.child,
    required this.bounds,
    super.opacity,
    super.gaplessPlayback,
  });

  @override
  Widget _render(
    BuildContext context, {
    required Widget child,
    required MapCamera camera,
  }) {
    // northWest is not necessarily upperLeft depending on projection
    final bounds = Bounds<double>(
      camera.project(this.bounds.northWest) - camera.pixelOrigin,
      camera.project(this.bounds.southEast) - camera.pixelOrigin,
    );

    return Positioned(
      left: bounds.topLeft.x,
      top: bounds.topLeft.y,
      width: bounds.size.x,
      height: bounds.size.y,
      child: child,
    );
  }
}

/// Spans an widget across three corner points.
///
/// Therefore this layer can be used to rotate or skew an image on the map.
///
/// The image is transformed so that its corners touch the [topLeftCorner],
/// [bottomLeftCorner] and [bottomRightCorner] points while the top-right
/// corner point is derived from the other points.
@immutable
class RotatedOverlayWidget extends BaseOverlayWidget {
  /// The coordinates of the top left corner of the image.
  final LatLng topLeftCorner;

  /// The coordinates of the bottom left corner of the image.
  final LatLng bottomLeftCorner;

  /// The coordinates of the bottom right corner of the image.
  final LatLng bottomRightCorner;

  /// The [FilterQuality] of the image, used to define how high quality the
  /// overlay image should have on the map.
  final FilterQuality? filterQuality;

  /// Create a new [RotatedOverlayWidget] instance that can be provided to the
  /// [OverlayWidgetLayer].
  const RotatedOverlayWidget({
    super.key,
    required super.child,
    required this.topLeftCorner,
    required this.bottomLeftCorner,
    required this.bottomRightCorner,
    this.filterQuality = FilterQuality.medium,
    super.opacity,
    super.gaplessPlayback,
  });

  @override
  Widget _render(
    BuildContext context, {
    required Widget child,
    required MapCamera camera,
  }) {
    final pxTopLeft = camera.project(topLeftCorner) - camera.pixelOrigin;
    final pxBottomRight =
        camera.project(bottomRightCorner) - camera.pixelOrigin;
    final pxBottomLeft = camera.project(bottomLeftCorner) - camera.pixelOrigin;

    /// calculate pixel coordinate of top-right corner by calculating the
    /// vector from bottom-left to top-left and adding it to bottom-right
    final pxTopRight = pxTopLeft - pxBottomLeft + pxBottomRight;

    /// update/enlarge bounds so the new corner points fit within
    final bounds = Bounds<double>(pxTopLeft, pxBottomRight)
        .extend(pxTopRight)
        .extend(pxBottomLeft);

    final vectorX = (pxTopRight - pxTopLeft) / bounds.size.x;
    final vectorY = (pxBottomLeft - pxTopLeft) / bounds.size.y;
    final offset = pxTopLeft - bounds.topLeft;

    final a = vectorX.x;
    final b = vectorX.y;
    final c = vectorY.x;
    final d = vectorY.y;
    final tx = offset.x;
    final ty = offset.y;

    return Positioned(
      left: bounds.topLeft.x,
      top: bounds.topLeft.y,
      width: bounds.size.x,
      height: bounds.size.y,
      child: Transform(
        transform: Matrix4(a, b, 0, 0, c, d, 0, 0, 0, 0, 1, 0, tx, ty, 0, 1),
        filterQuality: filterQuality,
        child: child,
      ),
    );
  }
}
