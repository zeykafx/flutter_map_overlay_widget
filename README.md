# flutter_map_overlay_widget
Display any widget on top of a flutter_map instance.

<img src="https://github.com/zeykafx/flutter_map_overlay_widget/blob/main/assets/flutter_map_overlay_widget_example.jpg?raw=true" width="400">
 
## Getting Started
Add the package to your `pubspec.yaml` file:
```yaml
dependencies:
  flutter_map_overlay_widget: any # or the latest version on pub.dev
```

Add an `OverlayWidgetLayer` to your `FlutterMap` widget, this layer contains a list of `OverlayWidget` instances. Each `OverlayWidget` instance contains a `bounds` property that defines the area where the widget will be displayed and a `widget` property that contains the widget to be displayed.
```dart
import 'package:flutter_map_overlay_widget/flutter_map_overlay_widget.dart';
// ...
FlutterMap(
    children: [
        ...,
        OverlayWidgetLayer(
            overlayWidgets: [
                OverlayWidget(
                    bounds: LatLngBounds(
                        LatLng(..., ...),
                        LatLng(..., ...),
                    ),
                    widget: YourWidget(),
                ),
            ],
        ),
    ]
)