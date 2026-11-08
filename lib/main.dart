import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

void main() => runApp(const KingApp());

const gold = Color(0xFFFFC857);
const black = Color(0xFF101010);

class KingApp extends StatelessWidget {
  const KingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KING STUDIO SIKAR',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: black,
        colorSchemeSeed: gold,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final picker = ImagePicker();

  bool hindi = false;
  Uint8List? original;
  Uint8List? preview;
  double brightness = 0;
  double contrast = 1;
  List<XFile> photos = [];
  String song = '';

  String t(String en, String hi) => hindi ? hi : en;

  Future<void> pickPhoto() async {
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      original = bytes;
      preview = bytes;
      brightness = 0;
      contrast = 1;
    });
    openEditor();
  }

  Future<void> pickGallery() async {
    final files = await picker.pickMultiImage();
    if (files.isNotEmpty) {
      setState(() => photos = files);
      openGallery();
    }
  }

  void openEditor() {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => EditorPage(
        original: original!,
        onSave: (value) => setState(() => preview = value),
      ),
    ));
  }

  void openGallery() {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => GalleryPage(photos: photos),
    ));
  }

  Future<void> pickSong() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );
    if (result != null) {
      setState(() => song = result.files.single.name);
    }
  }

  void openVideoMaker() {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => VideoPage(
        pickImages: () async {
          final files = await picker.pickMultiImage();
          return files;
        },
        pickSong: pickSong,
        getSong: () => song,
      ),
    ));
  }

  void openAdmin() {
    final pin = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF242424),
        title: const Text('KING ADMIN PANEL'),
        content: TextField(
          controller: pin,
          obscureText: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Enter Admin PIN'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (pin.text == '1234') {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const AdminPage(),
                ));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Wrong PIN')),
                );
              }
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  Widget menuCard(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback action,
  ) {
    return Card(
      color: const Color(0xFF202020),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: Icon(icon, color: gold, size: 34),
        title: Text(title,
            style: const TextStyle(
              color: gold,
              fontWeight: FontWeight.bold,
            )),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, color: gold),
        onTap: action,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: black,
        title: const Text(
          '👑 KING STUDIO SIKAR',
          style: TextStyle(color: gold, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () => setState(() => hindi = !hindi),
            child: Text(hindi ? 'English' : 'हिन्दी',
                style: const TextStyle(color: gold)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF49350C), Color(0xFF171717)],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: gold),
            ),
            child: Column(
              children: [
                const Text('👑', style: TextStyle(fontSize: 48)),
                const Text(
                  'KING STUDIO SIKAR',
                  style: TextStyle(
                    color: gold,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(t('YOUR PREMIUM CREATIVE STUDIO',
                    'आपका प्रीमियम क्रिएटिव स्टूडियो')),
              ],
            ),
          ),
          const SizedBox(height: 20),
          menuCard(Icons.photo_library, t('Photo Gallery', 'फोटो गैलरी'),
              t('Select your photos', 'अपनी फोटो चुनें'), pickGallery),
          menuCard(Icons.edit, t('Photo Editing', 'फोटो एडिटिंग'),
              t('Edit your favourite photos', 'फोटो एडिट करें'), pickPhoto),
          menuCard(Icons.movie_creation, t('Photo to Video Maker', 'फोटो वीडियो मेकर'),
              t('Create videos with your photos and song',
                  'फोटो और गाने से वीडियो बनाएं'), openVideoMaker),
          menuCard(Icons.admin_panel_settings, 'Admin Panel',
              t('Studio administration', 'स्टूडियो एडमिन'), openAdmin),
          const SizedBox(height: 18),
          const Center(
            child: Text('© KING STUDIO SIKAR',
                style: TextStyle(color: gold)),
          ),
        ],
      ),
    );
  }
}

class EditorPage extends StatefulWidget {
  final Uint8List original;
  final Function(Uint8List) onSave;

  const EditorPage({
    super.key,
    required this.original,
    required this.onSave,
  });

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  late Uint8List preview;
  double brightness = 0;
  double contrast = 1;

  @override
  void initState() {
    super.initState();
    preview = widget.original;
  }

  void apply() {
    final decoded = img.decodeImage(widget.original);
    if (decoded == null) return;
    final edited = img.adjustColor(
      decoded,
      brightness: brightness,
      contrast: contrast,
    );
    setState(() => preview =
        Uint8List.fromList(img.encodeJpg(edited, quality: 95)));
  }

  Future<void> save() async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/KING_STUDIO_SIKAR');
    await folder.create(recursive: true);
    final file = File(
      '${folder.path}/photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await file.writeAsBytes(preview);
    widget.onSave(preview);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo saved successfully!')),
    );
  }

  Future<void> share() async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/king_studio.jpg');
    await file.writeAsBytes(preview);
    await Share.shareXFiles([XFile(file.path)],
        text: 'Edited with KING STUDIO SIKAR');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Photo Editor')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Image.memory(preview, height: 320, fit: BoxFit.contain),
          Text('Brightness ${brightness.toStringAsFixed(2)}'),
          Slider(
            value: brightness,
            min: -0.5,
            max: 0.5,
            onChanged: (v) => setState(() => brightness = v),
          ),
          Text('Contrast ${contrast.toStringAsFixed(2)}'),
          Slider(
            value: contrast,
            min: 0.5,
            max: 1.8,
            onChanged: (v) => setState(() => contrast = v),
          ),
          FilledButton.icon(
            onPressed: apply,
            icon: const Icon(Icons.auto_fix_high),
            label: const Text('Apply Editing'),
          ),
          FilledButton.icon(
            onPressed: save,
            icon: const Icon(Icons.save),
            label: const Text('Save Photo'),
          ),
          OutlinedButton.icon(
            onPressed: share,
            icon: const Icon(Icons.share),
            label: const Text('Share Photo'),
          ),
        ],
      ),
    );
  }
}

class GalleryPage extends StatelessWidget {
  final List<XFile> photos;
  const GalleryPage({super.key, required this.photos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Photo Gallery')),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: photos.length,
        itemBuilder: (context, index) =>
            Image.file(File(photos[index].path), fit: BoxFit.cover),
      ),
    );
  }
}

class VideoPage extends StatefulWidget {
  final Future<List<XFile>> Function() pickImages;
  final Future<void> Function() pickSong;
  final String Function() getSong;

  const VideoPage({
    super.key,
    required this.pickImages,
    required this.pickSong,
    required this.getSong,
  });

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  List<XFile> selected = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Photo to Video Maker')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Icon(Icons.movie_creation, size: 75, color: gold),
          const Text('CREATE YOUR VIDEO',
              textAlign: TextAlign.center,
              style: TextStyle(color: gold, fontSize: 20)),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () async {
              final files = await widget.pickImages();
              setState(() => selected = files);
            },
            icon: const Icon(Icons.photo_library),
            label: const Text('Select Photos'),
          ),
          Text('Selected photos: ${selected.length}'),
          const SizedBox(height: 15),
          FilledButton.icon(
            onPressed: () async {
              await widget.pickSong();
              setState(() {});
            },
            icon: const Icon(Icons.music_note),
            label: const Text('Choose Your MP3 Song'),
          ),
          Text('Song: ${widget.getSong().isEmpty ? "Not selected" : widget.getSong()}'),
          const SizedBox(height: 20),
          const Text(
            'Your photos and song are selected. Video export processing will be added in the next build.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KING ADMIN PANEL')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Welcome Admin 👑\n\n'
            'KING STUDIO SIKAR\n'
            'Admin dashboard starter\n\n'
            'Default demo PIN: 1234',
            textAlign: TextAlign.center,
            style: TextStyle(color: gold, fontSize: 20),
          ),
        ),
      ),
    );
  }
}
