import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Specifies which side the tabs will be on.
enum TabEdge { left, top, right, bottom }

/// Controls tab selection from outside [TabContainer].
/// [TabContainerController.length] must equal the length of [children] and [tabs].
class TabContainerController extends ValueNotifier<int> {
  int _index;
  int _prevIndex;
  final int _length;

  TabContainerController({
    int initialIndex = 0,
    required int length,
  })  : assert(length > 0),
        assert(initialIndex >= 0 && initialIndex < length),
        _index = initialIndex,
        _prevIndex = initialIndex,
        _length = length,
        super(initialIndex);

  int get index => _index;
  int get prevIndex => _prevIndex;
  int get length => _length;

  void next() {
    jumpTo(_index + 1);
  }

  void prev() {
    jumpTo(_index - 1);
  }

  void jumpTo(int newIndex) {
    if (newIndex >= 0 && newIndex < length) {
      _prevIndex = _index;
      _index = newIndex;
      notifyListeners();
    }
  }
}

/// Displays [children] in accordance with the tab selection.
///
/// Handles styling and animation and exposes control over tab selection through [TabContainerController].
class TabContainer extends ImplicitlyAnimatedWidget {
  const TabContainer({
    Key? key,
    Duration? childDuration,
    Curve? childCurve,
    this.controller,
    this.radius = 12.0,
    this.childPadding = EdgeInsets.zero,
    required this.children,
    required this.tabs,
    this.tabExtent = 50.0,
    this.tabEdge = TabEdge.top,
    this.color,
    this.colors,
    this.tabDuration = const Duration(milliseconds: 300),
    this.tabCurve = Curves.easeInOut,
    this.transitionBuilder,
    this.selectedTextStyle,
    this.unselectedTextStyle,
    this.textDirection,
    this.enabled = true,
    VoidCallback? onEnd,
  })  : assert(children.length == tabs.length),
        assert(controller == null ? true : controller.length == tabs.length),
        assert(!(color != null && colors != null)),
        assert((colors ?? tabs).length == tabs.length),
        assert(radius >= 0),
        assert(tabExtent >= 0),
        childDuration = childDuration ?? tabDuration,
        childCurve = childCurve ?? tabCurve,
        super(
          key: key,
          duration: tabDuration,
          curve: tabCurve,
          onEnd: onEnd,
        );

  /// Changes tab selection from elsewhere in your app.
  ///
  /// If you provide one, you must dispose of it.
  final TabContainerController? controller;

  /// Sets the curve radius.
  ///
  /// Defaults to 12.0.
  final double radius;

  /// Sets the padding to be applied around all [children].
  ///
  /// Defaults to [EdgeInsets.zero].
  final EdgeInsets childPadding;

  /// The list of children you want to tab through, in order.
  ///
  /// Must be equal in length to [tabs] and [colors] (if provided).
  final List<Widget> children;

  /// What will be displayed in each tab, in order.
  ///
  /// Must be equal in length to [children] and [colors] (if provided).
  final List<dynamic> tabs;

  /// Determines how much space the tabs take up.
  ///
  /// If the tabs are on the left/right then this will be the tab width, otherwise it will be the tab height.
  /// Defaults to 50.0.
  final double tabExtent;

  /// Determines which side the tabs will be on.
  ///
  /// Defaults to [TabEdge.top].
  final TabEdge tabEdge;

  /// The background color of this widget.
  ///
  /// Must not set if [colors] is provided.
  final Color? color;

  /// The list of colors used for each tab, in order.
  ///
  /// The first color in the list will be the background color when tab 1 is selected and so on.
  /// Must not set if [color] is provided.
  final List<Color>? colors;

  /// Duration for the tab indicator to slide to a new index.
  ///
  /// Provide a duration of 0 to disable tab animation.
  /// Defaults to Duration(milliseconds: 300).
  final Duration tabDuration;

  /// The curve of the animation that controls tab indicator sliding.
  ///
  /// Defaults to [Curves.easeInOut].
  final Curve tabCurve;

  /// Duration of the child transition animation when the tab selection changes.
  ///
  /// Defaults to [tabDuration].
  final Duration? childDuration;

  /// The curve of the child transition animation when the tab selection changes.
  ///
  /// Defaults to [tabCurve].
  final Curve? childCurve;

  /// Sets the child transition animation when the tab selection changes.
  ///
  /// Defaults to [AnimatedSwitcher.defaultTransitionBuilder].
  final Widget Function(Widget, Animation<double>)? transitionBuilder;

  /// The [TextStyle] applied to the text of the currently selected tab.
  ///
  /// Defaults to Theme.of(context).textTheme.bodyText2.
  final TextStyle? selectedTextStyle;

  /// The [TextStyle] applied to the text of currently unselected tabs.
  ///
  /// Defaults to Theme.of(context).textTheme.bodyText2.
  final TextStyle? unselectedTextStyle;

  /// The [TextDirection] for tabs and semantics.
  ///
  /// Defaults to Directionality.of(context).
  final TextDirection? textDirection;

  /// Whether tab selection changes on tap.
  ///
  /// Defaults to true.
  final bool enabled;

  @override
  _TabContainerState createState() => _TabContainerState();
}

class _TabContainerState extends AnimatedWidgetBaseState<TabContainer> {
  TabContainerController? _controller;
  late int _currentIndex;
  late int _prevIndex;

  late TextStyle _selectedTextStyle;
  late TextStyle _unselectedTextStyle;
  late TextDirection _textDirection;
  late double _tabExtent;

  TextStyle _textStyle(int i, double progress, int currentIndex, int prevIndex,
      TextStyle selectedTextStyle, TextStyle unselectedTextStyle) {
    final TextStyleTween styleTween = TextStyleTween(
      begin: unselectedTextStyle,
      end: selectedTextStyle,
    );

    final int ceil = max(currentIndex, prevIndex);
    final int floor = min(currentIndex, prevIndex);
    final double pct = progress == ceil
        ? 1
        : ((progress - floor) / (floor == ceil ? 1 : ceil - floor).abs());

    if (i == currentIndex) {
      return styleTween.lerp(prevIndex > currentIndex ? 1 - pct : pct);
    } else if (i == prevIndex) {
      return styleTween.lerp(prevIndex > currentIndex ? pct : 1 - pct);
    } else {
      return unselectedTextStyle;
    }
  }

  double _textScale(int i, double progress, int currentIndex, int prevIndex,
      TextStyle selectedTextStyle, TextStyle unselectedTextStyle) {
    final int ceil = max(currentIndex, prevIndex);
    final int floor = min(currentIndex, prevIndex);
    final double pct = progress == ceil
        ? 1
        : ((progress - floor) / (floor == ceil ? 1 : ceil - floor).abs());

    if (i == currentIndex) {
      return lerpDouble(
          1,
          selectedTextStyle.fontSize! / unselectedTextStyle.fontSize!,
          prevIndex > currentIndex ? 1 - pct : pct)!;
    } else if (i == prevIndex) {
      return lerpDouble(
          1,
          selectedTextStyle.fontSize! / unselectedTextStyle.fontSize!,
          prevIndex > currentIndex ? pct : 1 - pct)!;
    } else {
      return 1;
    }
  }

  List<Semantics> _getTabs() {
    List<Semantics> ts = <Semantics>[];
    final int count = widget.tabs.length;

    for (int i = 0; i < count; i++) {
      final double scale = _textScale(
          i,
          progress?.evaluate(
                  CurvedAnimation(parent: animation, curve: widget.curve)) ??
              0.0,
          _currentIndex,
          _prevIndex,
          _selectedTextStyle,
          _unselectedTextStyle);

      final TextStyle style = _textStyle(
              i,
              progress?.evaluate(CurvedAnimation(
                      parent: animation, curve: widget.curve)) ??
                  0.0,
              _currentIndex,
              _prevIndex,
              _selectedTextStyle,
              _unselectedTextStyle)
          .copyWith(fontSize: _unselectedTextStyle.fontSize);

      ts.add(
        Semantics(
          label: 'Tab $i',
          hint: 'Press to switch to this tab',
          value: widget.tabs is! List<String> ? '' : widget.tabs[i],
          selected: i == _currentIndex,
          enabled: widget.enabled,
          onTap: !widget.enabled
              ? null
              : () {
                  _controller?.jumpTo(i);
                },
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..scale(scale),
            child: Container(
              child: widget.tabs is! List<String>
                  ? widget.tabs[i]
                  : Text(widget.tabs[i],
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.fade,
                      textDirection: _textDirection,
                      style: style),
            ),
          ),
        ),
      );
    }

    return ts;
  }

  Tween<double>? progress;
  ColorTween? phase;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    progress = visitor(
      progress,
      _currentIndex.toDouble(),
      (dynamic value) => Tween<double>(begin: value as double),
    ) as Tween<double>;

    if (widget.colors != null) {
      phase = visitor(
        phase,
        widget.colors![_currentIndex],
        (dynamic value) => ColorTween(begin: value as Color),
      ) as ColorTween;
    }
  }

  @override
  void initState() {
    _controller =
        widget.controller ?? TabContainerController(length: widget.tabs.length);

    _currentIndex = _controller!.index;
    _prevIndex = _controller!.index;

    _controller!.addListener(() {
      _currentIndex = _controller?.index ?? 0;
      _prevIndex = _controller?.prevIndex ?? 0;
      super.didUpdateWidget(super.widget);
    });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    _selectedTextStyle = widget.selectedTextStyle ??
        Theme.of(context).textTheme.bodyText2 ??
        const TextStyle();
    _unselectedTextStyle = widget.unselectedTextStyle ??
        Theme.of(context).textTheme.bodyText2 ??
        const TextStyle();
    _textDirection = widget.textDirection ?? Directionality.of(context);
    _tabExtent = max(widget.tabExtent, widget.radius * 2);

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _controller?.removeListener(() {});

    if (widget.controller == null) {
      _controller?.dispose();
    }

    _controller = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TabFrame(
      controller: _controller!,
      progress: progress?.evaluate(
              CurvedAnimation(parent: animation, curve: widget.curve)) ??
          0.0,
      radius: widget.radius,
      child: Padding(
        padding: widget.childPadding,
        child: AnimatedSwitcher(
          duration: widget.childDuration!,
          switchInCurve: widget.childCurve!,
          transitionBuilder: widget.transitionBuilder ??
              AnimatedSwitcher.defaultTransitionBuilder,
          child: IndexedStack(
            key: ValueKey<int>(_currentIndex),
            index: _currentIndex,
            children: widget.children,
          ),
        ),
      ),
      tabs: _getTabs(),
      tabExtent: _tabExtent,
      tabEdge: widget.tabEdge,
      color: phase?.evaluate(
              CurvedAnimation(parent: animation, curve: widget.curve)) ??
          widget.color ??
          Colors.transparent,
      enabled: widget.enabled,
      textDirection: _textDirection,
    );
  }
}

class TabFrame extends MultiChildRenderObjectWidget {
  final TabContainerController controller;
  final double progress;
  final double radius;
  final Widget child;
  final List<Semantics> tabs;
  final double tabExtent;
  final TabEdge tabEdge;
  final Color color;
  final bool enabled;
  final TextDirection textDirection;

  TabFrame({
    Key? key,
    required this.controller,
    required this.progress,
    required this.radius,
    required this.child,
    required this.tabs,
    required this.tabExtent,
    required this.tabEdge,
    required this.color,
    required this.enabled,
    required this.textDirection,
  }) : super(key: key, children: [child, ...tabs]);

  @override
  RenderTabFrame createRenderObject(BuildContext context) {
    return RenderTabFrame(
      controller: controller,
      progress: progress,
      radius: radius,
      tabs: tabs,
      tabExtent: tabExtent,
      tabEdge: tabEdge,
      color: color,
      enabled: enabled,
      textDirection: textDirection,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderTabFrame renderObject) {
    renderObject
      ..controller = controller
      ..progress = progress
      ..radius = radius
      ..tabs = tabs
      ..tabExtent = tabExtent
      ..tabEdge = tabEdge
      ..color = color
      ..enabled = enabled
      ..textDirection = textDirection;
  }
}

class TabFrameParentData extends ContainerBoxParentData<RenderBox> {}

class RenderTabFrame extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, TabFrameParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, TabFrameParentData> {
  TabContainerController _controller;
  double _progress;
  double _radius;
  List<Semantics> _tabs;
  double _tabExtent;
  TabEdge _tabEdge;
  Color _color;
  bool _enabled;
  TextDirection _textDirection;

  RenderTabFrame({
    required TabContainerController controller,
    required double progress,
    required double radius,
    required List<Semantics> tabs,
    required double tabExtent,
    required TabEdge tabEdge,
    required Color color,
    required bool enabled,
    required TextDirection textDirection,
  })  : _controller = controller,
        _progress = progress,
        _radius = radius,
        _tabs = tabs,
        _tabExtent = tabExtent,
        _tabEdge = tabEdge,
        _color = color,
        _enabled = enabled,
        _textDirection = textDirection;

  set controller(TabContainerController value) {
    if (value == _controller) return;
    _controller = value;
  }

  set progress(double value) {
    if (value == _progress) return;
    assert(value >= 0 && value <= _tabs.length);
    _progress = value;
    if (value == value.floor() || value == value.ceil()) {
      markNeedsSemanticsUpdate();
    }
    markNeedsLayout();
  }

  set radius(double value) {
    if (value == _radius) return;
    assert(value >= 0);
    _radius = value;
    markNeedsPaint();
  }

  set tabs(List<Semantics> value) {
    if (value == _tabs) return;
    assert(value.isNotEmpty);
    _tabs = value;
    markNeedsLayout();
  }

  set tabExtent(double value) {
    if (value == _tabExtent) return;
    assert(value >= 0);
    _tabExtent = value;
    markNeedsLayout();
  }

  set tabEdge(TabEdge value) {
    if (value == _tabEdge) return;
    _tabEdge = value;
    markNeedsLayout();
  }

  set color(Color value) {
    if (value == _color) return;
    _color = value;
    markNeedsPaint();
  }

  set enabled(bool value) {
    if (value == _enabled) return;
    _enabled = value;
    markNeedsSemanticsUpdate();
  }

  set textDirection(TextDirection value) {
    if (value == _textDirection) return;
    _textDirection = value;
    markNeedsSemanticsUpdate();
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! TabFrameParentData) {
      child.parentData = TabFrameParentData();
    }
  }

  @override
  void attach(covariant PipelineOwner owner) {
    super.attach(owner);

    _tapRecognizer = TapGestureRecognizer(debugOwner: this)
      ..onTapDown = !_enabled ? null : _onTapDown;
  }

  @override
  void detach() {
    _tapRecognizer.dispose();

    super.detach();
  }

  late TapGestureRecognizer _tapRecognizer;

  void _onTapDown(TapDownDetails details) {
    switch (_tabEdge) {
      case TabEdge.left:
        if (details.localPosition.dx <= _tabExtent + _radius) {
          final double tabHeight = size.height / _tabs.length;

          for (int i = 1; i <= _tabs.length; i++) {
            if (details.localPosition.dy < i * tabHeight) {
              _controller.jumpTo(i - 1);
              return;
            }
          }
        }
        return;
      case TabEdge.top:
        if (details.localPosition.dy <= _tabExtent + _radius) {
          final double tabWidth = size.width / _tabs.length;

          for (int i = 1; i <= _tabs.length; i++) {
            if (details.localPosition.dx < i * tabWidth) {
              _controller.jumpTo(i - 1);
              return;
            }
          }
        }
        return;
      case TabEdge.right:
        if (details.localPosition.dx >= size.width - _tabExtent - _radius) {
          final double tabHeight = size.height / _tabs.length;

          for (int i = 1; i <= _tabs.length; i++) {
            if (details.localPosition.dy < i * tabHeight) {
              _controller.jumpTo(i - 1);
              return;
            }
          }
        }
        return;
      case TabEdge.bottom:
        if (details.localPosition.dy >= size.height - _tabExtent - _radius) {
          final double tabWidth = size.width / _tabs.length;

          for (int i = 1; i <= _tabs.length; i++) {
            if (details.localPosition.dx < i * tabWidth) {
              _controller.jumpTo(i - 1);
              return;
            }
          }
        }
        return;
    }
  }

  @override
  bool hitTestSelf(Offset position) {
    return size.contains(position);
  }

  @override
  void handleEvent(PointerEvent event, covariant HitTestEntry entry) {
    assert(debugHandleEvent(event, entry));

    if (event is PointerDownEvent) {
      _tapRecognizer.addPointer(event);
    }
  }

  @override
  void performLayout() {
    size = constraints.biggest;

    //Layout the main child
    var child = firstChild;

    if (child == null) {
      return;
    }

    BoxConstraints mainChildConstraints = BoxConstraints(
        maxWidth: size.width, maxHeight: size.height - _tabExtent);
    if (_tabEdge == TabEdge.left || _tabEdge == TabEdge.right) {
      mainChildConstraints = BoxConstraints(
          maxWidth: size.width - _tabExtent, maxHeight: size.height);
    }

    child.layout(mainChildConstraints, parentUsesSize: true);

    final double horizontalGap =
        (mainChildConstraints.maxWidth - child.size.width) / 2;
    final double verticalGap =
        (mainChildConstraints.maxHeight - child.size.height) / 2;

    Offset mainChildOffset = Offset(horizontalGap, verticalGap);

    if (_tabEdge == TabEdge.left) {
      mainChildOffset = Offset(horizontalGap + _tabExtent, verticalGap);
    } else if (_tabEdge == TabEdge.top) {
      mainChildOffset = Offset(horizontalGap, verticalGap + _tabExtent);
    }

    (child.parentData as TabFrameParentData).offset = mainChildOffset;

    child = childAfter(child);

    //Layout the tab text
    late final double tabBreadth;
    late final BoxConstraints textConstraints;

    if (_tabEdge == TabEdge.left || _tabEdge == TabEdge.right) {
      tabBreadth = size.height / _tabs.length;
      textConstraints =
          BoxConstraints(maxWidth: _tabExtent, maxHeight: tabBreadth);
    } else {
      tabBreadth = size.width / _tabs.length;
      textConstraints =
          BoxConstraints(maxWidth: tabBreadth, maxHeight: _tabExtent);
    }

    for (var i = 0; child != null; i++, child = childAfter(child)) {
      child.layout(textConstraints, parentUsesSize: true);

      late final Offset textOffset;

      final double indexOffset = tabBreadth * i;

      final double horizontalGap =
          (textConstraints.maxWidth - child.size.width) / 2;
      final double verticalGap =
          (textConstraints.maxHeight - child.size.height) / 2;

      switch (_tabEdge) {
        case TabEdge.left:
          textOffset = Offset(horizontalGap, verticalGap + indexOffset);
          break;
        case TabEdge.top:
          textOffset = Offset(horizontalGap + indexOffset, verticalGap);
          break;
        case TabEdge.right:
          textOffset = Offset(size.width - horizontalGap - child.size.width,
              verticalGap + indexOffset);
          break;
        case TabEdge.bottom:
          textOffset = Offset(horizontalGap + indexOffset,
              size.height - verticalGap - child.size.height);
          break;
      }

      (child.parentData as TabFrameParentData).offset = textOffset;
    }
  }

  @override
  bool get isRepaintBoundary => true;

  @override
  bool get sizedByParent => false;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  double computeMinIntrinsicWidth(double height) {
    final double childMinIntrinsicWidth =
        firstChild?.getMinIntrinsicWidth(height) ?? 0.0;
    if (_tabEdge == TabEdge.left || _tabEdge == TabEdge.right) {
      return childMinIntrinsicWidth + _tabExtent;
    }
    return max(childMinIntrinsicWidth, _radius * 2 * _tabs.length);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    final double childMaxIntrinsicWidth =
        firstChild?.getMaxIntrinsicWidth(height) ?? 0.0;
    if (_tabEdge == TabEdge.left || _tabEdge == TabEdge.right) {
      return childMaxIntrinsicWidth + _tabExtent;
    }
    return max(childMaxIntrinsicWidth, _radius * 2 * _tabs.length);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    final double childMinIntrinsicHeight =
        firstChild?.getMinIntrinsicHeight(width) ?? 0.0;
    if (_tabEdge == TabEdge.left || _tabEdge == TabEdge.right) {
      return max(childMinIntrinsicHeight, _radius * 2 * _tabs.length);
    }
    return childMinIntrinsicHeight + _tabExtent;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    final double childMaxIntrinsicHeight =
        firstChild?.getMaxIntrinsicHeight(width) ?? 0.0;
    if (_tabEdge == TabEdge.left || _tabEdge == TabEdge.right) {
      return max(childMaxIntrinsicHeight, _radius * 2 * _tabs.length);
    }
    return childMaxIntrinsicHeight + _tabExtent;
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    defaultComputeDistanceToHighestActualBaseline(baseline);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final double width = size.width;
    final double height = size.height;

    double tabBreadth = size.width / _tabs.length;

    if (_tabEdge == TabEdge.left || _tabEdge == TabEdge.right) {
      tabBreadth = size.height / _tabs.length;
    }

    final double leftPos = _progress * tabBreadth;
    final double rightPos = leftPos + tabBreadth;

    final Path horizontalPath = Path()
      ..moveTo(0, _radius)
      ..quadraticBezierTo(
        0,
        0,
        _radius,
        0,
      )
      ..lineTo(width - _radius, 0)
      ..quadraticBezierTo(
        width,
        0,
        width,
        _radius,
      )
      ..lineTo(width, height - _tabExtent - _radius)
      ..quadraticBezierTo(
        width,
        height - _tabExtent,
        max(width - _radius, rightPos),
        height - _tabExtent,
      )
      ..lineTo(
          min(max(width - _radius, rightPos), min(width, rightPos + _radius)),
          height - _tabExtent)
      ..quadraticBezierTo(
        rightPos,
        height - _tabExtent,
        rightPos,
        height - _tabExtent + _radius,
      )
      ..lineTo(rightPos, height - _radius)
      ..quadraticBezierTo(
        rightPos,
        height,
        rightPos - _radius,
        height,
      )
      ..lineTo(leftPos + _radius, height)
      ..quadraticBezierTo(
        leftPos,
        height,
        leftPos,
        height - _radius,
      )
      ..lineTo(leftPos, height - _tabExtent + _radius)
      ..quadraticBezierTo(
        leftPos,
        height - _tabExtent,
        max(min(_radius, leftPos), max(0, leftPos - _radius)),
        height - _tabExtent,
      )
      ..lineTo(min(_radius, leftPos), height - _tabExtent)
      ..quadraticBezierTo(
        0,
        height - _tabExtent,
        0,
        height - _tabExtent - _radius,
      );

    final Path verticalPath = Path()
      ..moveTo(width - _radius, 0)
      ..quadraticBezierTo(
        width,
        0,
        width,
        _radius,
      )
      ..lineTo(width, height - _radius)
      ..quadraticBezierTo(
        width,
        height,
        width - _radius,
        height,
      )
      ..lineTo(_tabExtent + _radius, height)
      ..quadraticBezierTo(
        _tabExtent,
        height,
        _tabExtent,
        max(height - _radius, rightPos),
      )
      ..lineTo(_tabExtent,
          min(max(height - _radius, rightPos), min(height, rightPos + _radius)))
      ..quadraticBezierTo(
        _tabExtent,
        rightPos,
        _tabExtent - _radius,
        rightPos,
      )
      ..lineTo(_radius, rightPos)
      ..quadraticBezierTo(
        0,
        rightPos,
        0,
        rightPos - _radius,
      )
      ..lineTo(0, leftPos + _radius)
      ..quadraticBezierTo(
        0,
        leftPos,
        _radius,
        leftPos,
      )
      ..lineTo(_tabExtent - _radius, leftPos)
      ..quadraticBezierTo(
        _tabExtent,
        leftPos,
        _tabExtent,
        max(min(_radius, leftPos), max(0, leftPos - _radius)),
      )
      ..lineTo(_tabExtent, min(_radius, leftPos))
      ..quadraticBezierTo(
        _tabExtent,
        0,
        _tabExtent + _radius,
        0,
      );

    Path path = horizontalPath;

    if (_tabEdge == TabEdge.left || _tabEdge == TabEdge.right) {
      path = verticalPath;
    }

    final Canvas canvas = context.canvas;
    final Paint paint = Paint()..color = _color;

    if (_tabEdge == TabEdge.top) {
      canvas.save();
      canvas.scale(1, -1);
      canvas.translate(0, -height);
      canvas.drawPath(path, paint);
      canvas.restore();
    } else if (_tabEdge == TabEdge.right) {
      canvas.save();
      canvas.scale(-1, 1);
      canvas.translate(-width, 0);
      canvas.drawPath(path, paint);
      canvas.restore();
    } else {
      canvas.drawPath(path, paint);
    }

    for (var child = firstChild; child != null; child = childAfter(child)) {
      context.paintChild(
        child,
        (child.parentData as TabFrameParentData).offset,
      );
    }
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    config
      ..textDirection = _textDirection
      ..isButton = true
      ..isEnabled = _enabled;
  }
}
