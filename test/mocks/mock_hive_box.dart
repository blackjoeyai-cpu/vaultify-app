import 'package:hive/hive.dart';

class MockHiveBox<T> implements Box<T> {
  final Map<dynamic, T> _box = {};

  @override
  T? get(dynamic key, {T? defaultValue}) {
    return _box[key] ?? defaultValue;
  }

  @override
  Future<void> put(dynamic key, T value) async {
    _box[key] = value;
  }

  @override
  Future<void> delete(dynamic key) async {
    _box.remove(key);
  }

  @override
  bool containsKey(dynamic key) {
    return _box.containsKey(key);
  }

  @override
  Iterable<dynamic> get keys => _box.keys;

  @override
  int get length => _box.length;

  @override
  Future<int> clear() async {
    _box.clear();
    return _box.length;
  }

  @override
  List<T> get values => _box.values.toList();

  @override
  Map<dynamic, T> toMap() {
    return Map.from(_box);
  }

  @override
  Future<void> deleteFromDisk() async {
    _box.clear();
  }

  @override
  Future<void> flush() async {}

  @override
  String get name => 'mock_box';

  @override
  bool get isOpen => true;

  @override
  bool get isNotEmpty => _box.isNotEmpty;

  @override
  bool get isEmpty => _box.isEmpty;

  @override
  Future<void> close() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return null;
  }
}
