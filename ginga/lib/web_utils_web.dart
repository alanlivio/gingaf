import 'dart:html' as html;

String? getSessionStorageItem(String key) {
  try {
    return html.window.sessionStorage[key];
  } catch (e) {
    return null;
  }
}
