import 'package:flutter/widgets.dart';
import 'package:schwifty/src/schwifty.dart';

class SchwiftyBuilder<T> extends StatefulWidget {
  const SchwiftyBuilder({
    super.key,
    required this.builder,
    required this.schwifty,
    this.errorBuilder,
    this.loadingBuilder,
    this.shouldRebuild,
    this.onlyBuildOnce = false,
  });

  /// Schwifty instance to use.
  final Schwifty<T> schwifty;

  /// Builder to use when the data is loaded.
  final Widget Function(BuildContext context, Schwifty<T> schwifty) builder;

  /// Builder to use when the data is in error.
  final Widget Function(
      BuildContext context, Object? error, Schwifty<T> schwifty)? errorBuilder;

  /// Builder to use when the data is loading.
  final Widget Function(BuildContext context, Schwifty<T> schwifty)?
      loadingBuilder;

  /// Function to determine if the builder should rebuild.
  final bool Function(Schwifty<T> schwifty)? shouldRebuild;

  /// Only build the widget once then stop listening to the stream.
  final bool onlyBuildOnce;

  @override
  State<SchwiftyBuilder<T>> createState() => _SchwiftyBuilderState<T>();
}

class _SchwiftyBuilderState<T> extends State<SchwiftyBuilder<T>> {
  Widget? _currentChild;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: widget.schwifty.stream,
      builder: (context, snapshot) {
        if (widget.onlyBuildOnce && widget.schwifty.value != null) {
          // If the widget should only build once and the value is not null, then
          _currentChild ??= widget.builder(context, widget.schwifty);
        } else if (widget.shouldRebuild != null &&
            !widget.shouldRebuild!(widget.schwifty)) {
          // If the widget should not rebuild
          return _currentChild ??= widget.builder(context, widget.schwifty);
        } else if (snapshot.hasError && widget.errorBuilder != null) {
          // If there is an error and an error builder is provided
          _currentChild =
              widget.errorBuilder!(context, snapshot.error, widget.schwifty);
        } else if (snapshot.connectionState == ConnectionState.waiting &&
            widget.loadingBuilder != null) {
          // If the data is loading and a loading builder is provided
          _currentChild = widget.loadingBuilder!(context, widget.schwifty);
        } else {
          // If the data is loaded
          _currentChild = widget.builder(context, widget.schwifty);
        }

        return _currentChild!;
      },
    );
  }
}
