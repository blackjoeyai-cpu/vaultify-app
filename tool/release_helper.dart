// ignore_for_file: avoid_print
import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart release_helper.dart <major|minor|patch> [changelog_message]');
    exit(1);
  }

  final type = args[0].toLowerCase();
  final message = args.length > 1 ? args[1] : 'Manual release update';

  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    print('pubspec.yaml not found');
    exit(1);
  }

  String content = pubspecFile.readAsStringSync();
  // Match version: X.Y.Z+W
  final versionRegex = RegExp(r'^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)', multiLine: true);
  final match = versionRegex.firstMatch(content);

  if (match == null) {
    print('Could find version in pubspec.yaml with format X.Y.Z+W');
    exit(1);
  }

  int major = int.parse(match.group(1)!);
  int minor = int.parse(match.group(2)!);
  int patch = int.parse(match.group(3)!);
  int build = int.parse(match.group(4)!);

  final oldVersion = '${match.group(1)}.${match.group(2)}.${match.group(3)}+${match.group(4)}';

  if (type == 'major') {
    major++;
    minor = 0;
    patch = 0;
  } else if (type == 'minor') {
    minor++;
    patch = 0;
  } else if (type == 'patch') {
    patch++;
  } else {
    print('Invalid bump type: $type. Use major, minor, or patch.');
    exit(1);
  }
  build++;

  final newVersion = '$major.$minor.$patch+$build';
  print('Bumping version from $oldVersion to $newVersion');

  content = content.replaceFirst(versionRegex, 'version: $newVersion');
  pubspecFile.writeAsStringSync(content);

  updateChangelog(newVersion, message);
}

void updateChangelog(String version, String message) {
  final changelogFile = File('CHANGELOG.md');
  final date = DateTime.now().toIso8601String().split('T')[0];
  final newEntry = '## [$version] - $date\n\n- $message\n';

  if (!changelogFile.existsSync()) {
    changelogFile.writeAsStringSync('# Changelog\n\n$newEntry');
    print('Created CHANGELOG.md');
  } else {
    String content = changelogFile.readAsStringSync();
    if (content.contains('# Changelog')) {
      content = content.replaceFirst('# Changelog', '# Changelog\n\n$newEntry');
    } else {
      content = '# Changelog\n\n$newEntry\n$content';
    }
    changelogFile.writeAsStringSync(content);
    print('Updated CHANGELOG.md');
  }
}
