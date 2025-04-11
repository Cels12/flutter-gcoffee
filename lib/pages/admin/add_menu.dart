import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gcoffee_r/pages/admin/dashboard.dart';
import 'package:gcoffee_r/pages/admin/menupage.dart';
import 'package:gcoffee_r/routes/route_name.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class AddMenu extends StatefulWidget {
  const AddMenu({super.key});

  @override
  State<AddMenu> createState() => _AddMenuState();
}

class _AddMenuState extends State<AddMenu> {
  Uint8List? _imageBytes;
  String? _imageName;
  final TextEditingController search = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();
  final TextEditingController namaMenuController = TextEditingController();
  final TextEditingController hargaController = TextEditingController();

  Future pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final Uint8List bytes = await image.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _imageName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        });
      } else {
        if (kDebugMode) {
          print('No image selected.');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('gagal memilih gambar: ${e.toString()}')),
        );
      }
    }
  }

  //upload image to storage supabase
  Future<String?> uploadImage() async {
    if (_imageBytes == null || _imageName == null) return null;
    final path = 'image/$_imageName';

    try {
      await Supabase.instance.client.storage
          .from('image')
          .uploadBinary(
            path,
            _imageBytes!,
            fileOptions: const FileOptions(contentType: 'image/jpg'),
          );
      return Supabase.instance.client.storage.from('image').getPublicUrl(path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image gagal di upload: ${e.toString()}')),
        );
        return null;
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Image berhasil di upload')));
        }
      }
    }
    return null;
  }

  //add the menu to supabase
  Future<void> _saveMenu() async {
    final namaMenu = namaMenuController.text.trim();
    final hargaMenu = hargaController.text.trim();
    final deskripsiMenu = deskripsiController.text.trim();

    if (namaMenu.isEmpty || hargaMenu.isEmpty || deskripsiMenu.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nama menu, harga, dan deskripsi tidak boleh kosong'),
        ),
      );
      return;
    }
    String? imageUrl;
    if (_imageBytes != null) {
      imageUrl = await uploadImage();
      if (imageUrl == null) return;
    }

    try {
      await Supabase.instance.client.from('menu').insert({
        'nama_menu': namaMenu,
        'deskripsi': deskripsiMenu,
        'harga': hargaMenu,
        'gambar': imageUrl,
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan menu : ${e.toString()}')),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Menu berhasil di tambahkan')));
        }
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _isMenuOpen = false;
  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background utama
          Container(
            color: Color.fromARGB(255, 247, 247, 247),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 50,
                  ),
                  child: Row(
                    children: <Widget>[
                      // Teks GCoffee yang bergeser mengikuti sidebar
                      AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        padding: EdgeInsets.only(
                          left: _isMenuOpen ? 50 : 20,
                        ), // Bergeser
                        child: Text(
                          'GCoffee',
                          style: TextStyle(
                            color: Color.fromARGB(255, 84, 47, 17),
                            fontSize: 32,
                            fontFamily: 'Righteous',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // card CRUD
          Positioned.fill(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 120, left: 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 1000,
                      height: 450,
                      child: Card(
                        elevation: 3,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Bagian Gambar
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Gambar Menu
                                  _imageBytes != null
                                      ? Image.memory(
                                        _imageBytes!,
                                        width: 220,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      )
                                      : SizedBox(
                                        width: 218,
                                        height: 220,
                                        child: const Placeholder(
                                          child: Center(
                                            child: Text('Belum ada gambar'),
                                          ),
                                        ),
                                      ),
                                  const SizedBox(height: 10),

                                  // disini tombol untuk memilih image
                                  TextButton(
                                    onPressed: () {
                                      pickImage();
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor: Color.fromARGB(
                                        255,
                                        127,
                                        88,
                                        56,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      fixedSize: Size(220, 30),
                                    ),
                                    child: Text(
                                      'Tambahkan Foto',
                                      style: TextStyle(
                                        fontFamily: 'Oxanium',
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                width: 20,
                              ), // Jarak antara gambar dan deskripsi
                              // Bagian Deskripsi dan Tombol
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // TextField nama menu
                                    SizedBox(
                                      width: 800,
                                      child: TextField(
                                        controller: namaMenuController,
                                        // inputFormatters: [
                                        //   LengthLimitingTextInputFormatter(20),
                                        // ],
                                        maxLines: 1,
                                        decoration: InputDecoration(
                                          label: Text(
                                            'Nama menu',
                                            style: TextStyle(
                                              fontFamily: 'Oxanium',
                                            ),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    //textField harga
                                    SizedBox(
                                      width: 800,
                                      child: TextField(
                                        controller: hargaController,
                                        // inputFormatters: [
                                        //   LengthLimitingTextInputFormatter(20),
                                        // ],
                                        maxLines: 1,
                                        decoration: InputDecoration(
                                          label: Text(
                                            'Harga',
                                            style: TextStyle(
                                              fontFamily: 'Oxanium',
                                            ),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      width: 800,
                                      child: TextField(
                                        controller: deskripsiController,
                                        // inputFormatters: [
                                        //   LengthLimitingTextInputFormatter(20),
                                        // ],
                                        maxLines: 4,
                                        decoration: InputDecoration(
                                          label: Text(
                                            'Deskripsi',
                                            style: TextStyle(
                                              fontFamily: 'Oxanium',
                                            ),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 100),
                                    // Row Tombol
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // Tombol Simpan
                                        ElevatedButton(
                                          onPressed: () {
                                            _saveMenu();
                                            Navigator.pop(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            fixedSize: const Size(120, 40),
                                          ),
                                          child: const Text(
                                            'Simpan',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 50),

                                        // Tombol Hapus
                                        ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            fixedSize: const Size(120, 40),
                                          ),
                                          child: const Text(
                                            'Reset',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Sidebar
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            top: 0,
            left: _isMenuOpen ? 0 : -200,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              child: Container(
                width: 80,
                height: MediaQuery.of(context).size.height,
                color: Color.fromARGB(255, 84, 47, 17),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Tooltip(
                      message: 'Home',
                      child: TextButton(
                        onPressed: () {
                          context.goNamed(ROuteNames.dashboard);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: SvgPicture.asset(
                            'assets/icons/home.svg',
                            width: 40,
                            height: 40,
                          ),
                        ),
                      ),
                    ),
                    Tooltip(
                      message: 'Show Menu',
                      child: TextButton(
                        onPressed: () {
                          context.goNamed(ROuteNames.menupage);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Icon(
                            Icons.add_circle_outline_outlined,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          //sidebar
          Positioned(
            top: 12,
            left: 10,
            child: IconButton(
              iconSize: 40,
              color: Color.fromARGB(255, 210, 156, 108),
              onPressed: _toggleMenu,
              icon: Icon(Icons.menu),
            ),
          ),
          // Area di luar sidebar untuk menutup menu saat diklik
        ],
      ),
    );
  }
}
