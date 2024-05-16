import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:schwifty/schwifty.dart';

class SchwiftyBuilder<T> extends StatefulWidget {
  const SchwiftyBuilder({
    super.key,
    required this.builder,
    required this.schwifty,
    this.errorBuilder,
    this.loadingBuilder,
    this.shouldRebuild,
    this.onlyRebuildOnValueChange = true,
    this.onlyBuildOnce = false,
  });

  /// Schwifty instance to use.
  /// If not provided, a new instance will be used.
  final Schwifty<T> schwifty;

  /// Builder to use when the data is loaded.
  final Widget Function(BuildContext context, Schwifty<T> schwifty) builder;

  /// Builder to use when the data is in error.
  /// If not provided, builder will be used.
  final Widget Function(
      BuildContext context, Object? error, Schwifty<T> schwifty)? errorBuilder;

  /// Builder to use when the data is loading.
  /// If not provided, builder will be used.
  final Widget Function(BuildContext context, Schwifty<T> schwifty)?
      loadingBuilder;

  /// Function to determine if the builder should rebuild.
  final bool Function(Schwifty<T> schwifty)? shouldRebuild;

  /// Only rebuild the widget if the value changes.
  final bool onlyRebuildOnValueChange;

  /// Only build the widget once then stop listening to the stream.
  final bool onlyBuildOnce;

  @override
  State<SchwiftyBuilder<T>> createState() => _SchwiftyBuilderState<T>();
}

class _SchwiftyBuilderState<T> extends State<SchwiftyBuilder<T>> {
  late var _child = const _Child(child: null);

  StreamSubscription<T>? _subscription;

  /// Schwifty instance
  late Schwifty<T> schwifty;

  @override
  void initState() {
    super.initState();
    schwifty = Schwifty<T>(Schwifty.generateNamespace());

    // Listen to the Schwifty instance
    _subscription = schwifty.stream.listen((value) {
      _setChild();
    });

    _setChild();
  }

  @override
  void dispose() {
    super.dispose();

    _subscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return _child;
  }

  void _setChild() {
    if (widget.shouldRebuild != null && !widget.shouldRebuild!(schwifty)) {
      return;
    }

    if (widget.onlyRebuildOnValueChange &&
        schwifty.value != null &&
        schwifty.previousValue == schwifty.value &&
        _child.child != null) {
      return;
    }

    if (widget.onlyBuildOnce && schwifty.value != null) {
      _subscription?.cancel();
      _child = _Child(child: widget.builder(context, schwifty));
      return;
    }

    if (schwifty.hasError && widget.errorBuilder != null) {
      _child = _Child(
          child: widget.errorBuilder!(context, schwifty.error, schwifty));
      return;
    } else if (schwifty.isLoading && widget.loadingBuilder != null) {
      _child = _Child(child: widget.loadingBuilder!(context, schwifty));
      return;
    }

    _child = _Child(child: widget.builder(context, schwifty));
    if (context.mounted) {
      setState(() {});
    }
  }
}

class _Child extends StatelessWidget {
  const _Child({required this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return child ?? const SizedBox.shrink();
  }
}
