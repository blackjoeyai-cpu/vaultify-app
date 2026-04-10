import 'package:hive/hive.dart';
import '../../domain/entities/password_entry.dart';
import '../../../../core/constants/storage_keys.dart';

class VaultLocalDatasource {
  late Box<String> _passwordBox;

  Future<void> init() async {
    _passwordBox = await Hive.openBox<String>(StorageKeys.passwordEntries);
  }

  Future<List<PasswordEntry>> getAllPasswords() async {
    final entries = <PasswordEntry>[];
    for (final key in _passwordBox.keys) {
      final json = _passwordBox.get(key);
      if (json != null) {
        entries.add(_passwordEntryFromJson(json));
      }
    }
    return entries;
  }

  Future<PasswordEntry?> getPasswordById(String id) async {
    final json = _passwordBox.get(id);
    if (json == null) return null;
    return _passwordEntryFromJson(json);
  }

  Future<void> savePassword(PasswordEntry entry) async {
    await _passwordBox.put(entry.id, _passwordEntryToJson(entry));
  }

  Future<void> deletePassword(String id) async {
    await _passwordBox.delete(id);
  }

  PasswordEntry _passwordEntryFromJson(String json) {
    final map = Map<String, dynamic>.from(_parseJson(json));
    return PasswordEntry(
      id: map['id'] as String,
      title: map['title'] as String,
      username: map['username'] as String,
      password: map['password'] as String,
      url: map['url'] as String?,
      notes: map['notes'] as String?,
      category: PasswordCategory.values[map['category'] as int],
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      isFavorite: map['isFavorite'] as bool? ?? false,
    );
  }

  String _passwordEntryToJson(PasswordEntry entry) {
    return _encodeJson({
      'id': entry.id,
      'title': entry.title,
      'username': entry.username,
      'password': entry.password,
      'url': entry.url,
      'notes': entry.notes,
      'category': entry.category.index,
      'createdAt': entry.createdAt.toIso8601String(),
      'updatedAt': entry.updatedAt.toIso8601String(),
      'isFavorite': entry.isFavorite,
    });
  }

  Map<String, dynamic> _parseJson(String json) {
    return Map<String, dynamic>.from(
      (json.isEmpty ? {} : _decodeJson(json)) as Map,
    );
  }

  String _encodeJson(Map<String, dynamic> map) {
    final buffer = StringBuffer('{');
    var first = true;
    map.forEach((key, value) {
      if (!first) buffer.write(',');
      first = false;
      buffer.write('"$key":');
      if (value is String) {
        buffer.write('"$value"');
      } else if (value is List) {
        buffer.write('[');
        var firstItem = true;
        value.forEach((item) {
          if (!firstItem) buffer.write(',');
          firstItem = false;
          buffer.write(item is String ? '"$item"' : item.toString());
        });
        buffer.write(']');
      } else if (value == null) {
        buffer.write('null');
      } else {
        buffer.write(value.toString());
      }
    });
    buffer.write('}');
    return buffer.toString();
  }

  Map<String, dynamic> _decodeJson(String json) {
    final result = <String, dynamic>{};
    json = json.trim();
    if (json.isEmpty || json == '{}') return result;

    json = json.substring(1, json.length - 1);
    var i = 0;
    while (i < json.length) {
      while (i < json.length && (json[i] == ' ' || json[i] == ',')) i++;
      if (i >= json.length) break;

      if (json[i] != '"') {
        i++;
        continue;
      }
      i++;
      var keyEnd = json.indexOf('"', i);
      var key = json.substring(i, keyEnd);
      i = keyEnd + 1;
      while (i < json.length && json[i] == ' ') i++;
      if (i >= json.length || json[i] != ':') continue;
      i++;
      while (i < json.length && json[i] == ' ') i++;

      dynamic value;
      if (json[i] == '"') {
        i++;
        var valueEnd = json.indexOf('"', i);
        value = json.substring(i, valueEnd);
        i = valueEnd + 1;
      } else if (json[i] == 'n' && json.substring(i, i + 4) == 'null') {
        value = null;
        i += 4;
      } else if (json[i] == 't' && json.substring(i, i + 4) == 'true') {
        value = true;
        i += 4;
      } else if (json[i] == 'f' && json.substring(i, i + 5) == 'false') {
        value = false;
        i += 5;
      } else {
        var numEnd = i;
        while (numEnd < json.length &&
            json[numEnd] != ',' &&
            json[numEnd] != '}' &&
            json[numEnd] != ' ') {
          numEnd++;
        }
        var numStr = json.substring(i, numEnd).trim();
        value = numStr.contains('.')
            ? double.tryParse(numStr)
            : int.tryParse(numStr);
        i = numEnd;
      }
      result[key] = value;
    }
    return result;
  }
}
