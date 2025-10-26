import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

late File _storageFile;

Future<void> initStorage() async {
  final dir = await getApplicationDocumentsDirectory();
  _storageFile = File('${dir.path}/task_manager_data.json');
  if (!await _storageFile.exists()) {
    // create an empty structure
    final initial = jsonEncode({'categories': [], 'tasks': []});
    await _storageFile.writeAsString(initial);
  }
}

Future<bool> storageExists() async {
  return await _storageFile.exists();
}

Future<String?> readStorage() async {
  if (!await _storageFile.exists()) return null;
  return await _storageFile.readAsString();
}

Future<void> writeStorage(String data) async {
  await _storageFile.writeAsString(data);
}
