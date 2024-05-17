# Schwifty

This is a simple stream-based state machine for Flutter. It was designed to be a simplified version of the BLoC pattern that does not rely on context and requires less boilerplate.

## Installation

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  schwifty: ^0.0.1
```

## Usage

### Creating a Schwifty State Stream

To create a new state stream, use the `Schwifty` class. This class has a single method, `create`, which takes a function that returns a stream of the state you want to manage. The function will be called when the stream is first listened to.

```dart
final Schwifty<int> _schwifty = Schwifty<int>('counter');
```

In the example above, we create a new `Schwifty` instance that will manage an integer state. You need to pass a unique name to the constructor and specify the value type for the instance so that the state can be identified. Using the name of an existing instance will return the same instance. If you access an existing instance with a different type, an exception will be thrown.

You can access the current value of the state by using the `value` property of the `Schwifty` instance.

```dart
print(_schwifty.value);
```

You can also set the initial value of the state by passing it to the constructor.

```dart
final Schwifty<int> _schwifty = Schwifty<int>('counter')..emit(1);
```

You can access the previous value of the state by using the `previousValue` property of the `Schwifty` instance.

```dart
print(_schwifty.previousValue);
```

### Listening to the State Stream

To listen to the value stream, you can listen to the `stream` property of the `Schwifty` instance, use a `StreamBuilder` widget, or use the `SchwiftyBuilder` widget.

#### Using the `stream` Property

```dart
_schwifty.stream.listen((value) {
  print(value);
});
```

#### Using a `StreamBuilder` Widget

```dart
StreamBuilder<int>(
  stream: _schwifty.stream,
  builder: (context, snapshot) {
    return Text(snapshot.data.toString());
  },
);
```

#### Using a `SchwiftyBuilder` Widget

```dart
SchwiftyBuilder<int>(
  schwifty: _schwifty,
  builder: (context, schwifty) {
    return Text(schwifty.value.toString());
  },
);
```

### Updating the State

You can update the state value by calling the `emit` method of the `Schwifty` instance.

```dart
_schwifty.emit(1);
```

You can also use the `emitFromFuture` method to update the state value from a future. This will automatically handle the loading state and error state for you.

```dart
_schwifty.emitFromFuture(Future.value(1));
```

Lastly, you can use the `emitFromStream` method to update the state value from a stream. This will put the stream in a loading state until the stream emits a value or an error.

```dart
_schwifty.emitFromStream(Stream.value(1));
```

### Handling Loading and Error States

When you use the `emitFromFuture` or `emitFromStream` methods, the state will automatically be set to a loading state until the future or stream emits a value. If the future or stream throws an error, the state will be set to an error state with the error object.

You can check if a `Schwifty` instance is in a loading or error state by checking the `isLoading` and `hasError` properties.

```dart
if (_schwifty.isLoading) {
  print('Loading...');
}

if (_schwifty.hasError) {
  print('Error: ${_schwifty.error}');
}
```

### Disposing the State Stream

To dispose of the state stream, you can call the `dispose` method of the `Schwifty` instance. If you call this on a `Schwifty` instance that was created with a unique name, the instance will still be accessible by the name, but the stream will be closed and will not emit any more values.

```dart
_schwifty.dispose();
```

### The `SchwiftyBuilder` Widget

The `SchwiftyBuilder` is a convenience widget that will automatically listen to the state stream and rebuild the widget when the state changes.

Properties:

- `schwifty`: The `Schwifty` instance to use.
- `builder`: A function that takes a `BuildContext` and a `Schwifty` instance and returns a `Widget`.
- `loadingBuilder`: A function that takes a `BuildContext` and a `Schwifty` instance and returns a `Widget`. This will be called when the state is in a loading state.
- `errorBuilder`: A function that takes a `BuildContext`, a `Schwifty` instance, and an `Object` and returns a `Widget`. This will be called when the state is in an error state.
- `shouldRebuild`: A function that takes the `Schwifty` instance and returns a `bool`. If this function returns `false`, the widget will not be rebuilt.
- `onlyRebuildOnValueChange`: A `bool` that determines if the widget should only be rebuilt when the state value changes. Defaults to `true`.
- `onlyBuildOnce`: A `bool` that determines if the widget should only be built once as soon as the state has a value. Defaults to `false`.

```dart
SchwiftyBuilder<int>(
  schwifty: _schwifty,
  builder: (context, schwifty) {
    return Text(schwifty.value.toString());
  },
  loadingBuilder: (context, schwifty) {
    return CircularProgressIndicator();
  },
  errorBuilder: (context, schwifty, error) {
    return Text('Error: $error');
  },
  shouldRebuild: (schwifty) {
    return schwifty.value % 2 == 0;
  },
  onlyRebuildOnValueChange: false,
  onlyBuildOnce: true,
);
```

### Conclusion

That's it! You now have a simple stream-based state machine for Flutter. Feel free to open an issue on GitHub if you have any suggestions or improvements.