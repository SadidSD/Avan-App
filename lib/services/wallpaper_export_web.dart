// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:typed_data';
import 'dart:html' as html;

Future<String?> exportWallpaperImage(Uint8List bytes, String filename) async {
  try {
    final blob = html.Blob([bytes], 'image/png');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
    return 'Downloaded $filename';
  } catch (e) {
    return null;
  }
}
