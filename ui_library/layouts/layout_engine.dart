import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Reusable page layout engine: sections are built once and can be reordered
/// by passing a different section list. Keep business/data logic outside.
class LayoutEngine extends StatefulWidget {
  final List<Widget> sections;
  final EdgeInsetsGeometry padding;
  final bool shrinkWrap;

  const LayoutEngine({
    super.key,
    required this.sections,
    this.padding = EdgeInsets.zero,
    this.shrinkWrap = false,
  });

  @override
  State<LayoutEngine> createState() => _LayoutEngineState();
}

class _LayoutEngineState extends State<LayoutEngine> {
  late final ScrollController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _focusNode = FocusNode(debugLabel: 'layout-scroll');
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollBy(double delta) {
    if (!_controller.hasClients) return;
    final target = (_controller.offset + delta).clamp(
      0.0,
      _controller.position.maxScrollExtent,
    );
    _controller.animateTo(
      target,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
    );
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowDown:
        _scrollBy(120);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowUp:
        _scrollBy(-120);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.pageDown:
        _scrollBy(0.85 * MediaQuery.sizeOf(context).height);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.pageUp:
        _scrollBy(-0.85 * MediaQuery.sizeOf(context).height);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.home:
        _controller.animateTo(
          0,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
        );
        return KeyEventResult.handled;
      case LogicalKeyboardKey.end:
        if (_controller.hasClients) {
          _controller.animateTo(
            _controller.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        }
        return KeyEventResult.handled;
      default:
        return KeyEventResult.ignored;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKey,
      child: ScrollConfiguration(
        behavior: const MaterialScrollBehavior().copyWith(
          scrollbars: false,
          overscroll: true,
        ),
        child: RawScrollbar(
          controller: _controller,
          thumbVisibility: true,
          trackVisibility: true,
          interactive: true,
          scrollbarOrientation: ScrollbarOrientation.right,
          thickness: 10,
          radius: const Radius.circular(8),
          minThumbLength: 40,
          notificationPredicate: (notification) => notification.depth == 0,
          child: ListView.separated(
            controller: _controller,
            padding: widget.padding,
            shrinkWrap: widget.shrinkWrap,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: widget.shrinkWrap
                ? const NeverScrollableScrollPhysics()
                : const ClampingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
            itemCount: widget.sections.length,
            separatorBuilder: (_, __) => const SizedBox.shrink(),
            itemBuilder: (_, index) => widget.sections[index],
          ),
        ),
      ),
    );
  }
}

/// A named reusable section used by configurable page layouts.
class LayoutSection {
  final String id;
  final WidgetBuilder builder;

  const LayoutSection({required this.id, required this.builder});
}

/// Builds a page from an ordered list of reusable sections.
class ConfigurableLayout extends StatelessWidget {
  final List<LayoutSection> sections;
  final EdgeInsetsGeometry padding;

  const ConfigurableLayout({
    super.key,
    required this.sections,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutEngine(
      padding: padding,
      sections: [
        for (final section in sections) section.builder(context),
      ],
    );
  }
}
