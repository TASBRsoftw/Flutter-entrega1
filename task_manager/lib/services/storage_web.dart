import 'dart:async';
import 'dart:html' as html;

Future<void> initStorage() async {
  if (true) {
    // debug only
    print('storage_web.initStorage() running (web)');
  }
}

Future<bool> storageExists() async {
  return html.window.localStorage.containsKey('task_manager_data');
}

Future<String?> readStorage() async {
  return html.window.localStorage['task_manager_data'];
}

Future<void> writeStorage(String data) async {
  html.window.localStorage['task_manager_data'] = data;
}
