import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

void main() => runApp(const KingApp());

class KingApp extends StatelessWidget {
  const KingApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'KING STUDIO SIKAR',
    theme: ThemeData(brightness: Brightness.dark, colorSchemeSeed: const Color(0xFFFFC857), useMaterial3: true, scaffoldBackgroundColor: const Color(0xFF101010)),
    home: const EditorPage(),
  );
}

class EditorPage extends StatefulWidget {
  const EditorPage({super.key});
  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  final picker = ImagePicker();
  Uint8List? original, preview;
  double brightness = 0, contrast = 1;
  String status = 'Choose a photo to start';

  Future<void> pick(ImageSource source) async {
    final file = await picker.pickImage(source: source, imageQuality: 100);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() { original = bytes; preview = bytes; brightness = 0; contrast = 1; status = 'Photo loaded'; });
  }

  void apply() {
    if (original == null) return;
    final decoded = img.decodeImage(original!);
    if (decoded == null) return;
    final edited = img.adjustColor(decoded, brightness: brightness, contrast: contrast);
    setState(() { preview = Uint8List.fromList(img.encodeJpg(edited, quality: 95)); status = 'Adjustments applied'; });
  }

  Future<void> save() async {
    if (preview == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/KING_STUDIO_SIKAR');
    await folder.create(recursive: true);
    final file = File('${folder.path}/king_studio_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await file.writeAsBytes(preview!);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Photo saved in app storage')));
  }

  Future<void> share() async {
    if (preview == null) return;
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/king_studio_share.jpg');
    await file.writeAsBytes(preview!);
    await Share.shareXFiles([XFile(file.path)], text: 'Edited with KING STUDIO SIKAR');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('KING STUDIO SIKAR', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1))),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      const Card(child: Padding(padding: EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('YOUR CREATIVE STUDIO', style: TextStyle(color: Color(0xFFFFC857), fontWeight: FontWeight.bold)),
        SizedBox(height: 6), Text('Make every photo look amazing.', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text('Simple tools. Full creativity. Always free.'),
      ]))),
      Row(children: [
        Expanded(child: FilledButton.icon(onPressed: () => pick(ImageSource.gallery), icon: const Icon(Icons.photo), label: const Text('Gallery'))),
        const SizedBox(width: 8),
        Expanded(child: OutlinedButton.icon(onPressed: () => pick(ImageSource.camera), icon: const Icon(Icons.camera_alt), label: const Text('Camera'))),
      ]),
      Container(height: 300, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(16)),
        child: preview == null ? const Text('Photo preview') : Image.memory(preview!, fit: BoxFit.contain)),
      Text(status, style: const TextStyle(color: Colors.white60)),
      Text('Brightness: ${brightness.toStringAsFixed(2)}'),
      Slider(value: brightness, min: -0.5, max: 0.5, onChanged: (v) => setState(() => brightness = v)),
      Text('Contrast: ${contrast.toStringAsFixed(2)}'),
      Slider(value: contrast, min: 0.5, max: 1.8, onChanged: (v) => setState(() => contrast = v)),
      FilledButton.icon(onPressed: original == null ? null : apply, icon: const Icon(Icons.auto_fix_high), label: const Text('Apply adjustments')),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: FilledButton.icon(onPressed: preview == null ? null : save, icon: const Icon(Icons.save), label: const Text('Save'))),
        const SizedBox(width: 8),
        Expanded(child: OutlinedButton.icon(onPressed: preview == null ? null : share, icon: const Icon(Icons.share), label: const Text('Share'))),
      ]),
      const SizedBox(height: 18),
      const Text('Next build: crop, filters, blur, collage, text, stickers and AI tools.'),
    ]),
  );
}
