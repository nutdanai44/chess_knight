class ChessStack<T> {
  final List<T> _list = [];

  void push(T value) => _list.add(value);

  T pop() => _list.removeLast();

  T? top() => _list.isNotEmpty ? _list.last : null;

  bool get isEmpty => _list.isEmpty;

  bool get isNotEmpty => _list.isNotEmpty;
}