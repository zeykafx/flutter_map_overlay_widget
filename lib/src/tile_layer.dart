library flutter_map_overlay_widget;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'overlay_widget.dart';

/// [OverlayWidgetLayer] is used to display one or multiple widgets on the map.
class OverlayWidgetLayer extends StatelessWidget {
  /// The widgets that the map should get overlayed with.
  final List<BaseOverlayWidget> overlayWidgets;

  /// Create a new [OverlayWidgetLayer].
  const OverlayWidgetLayer({super.key, required this.overlayWidgets});

  @override
  Widget build(BuildContext context) => MobileLayerTransformer(
        child: ClipRect(child: Stack(children: overlayWidgets)),
      );
}
