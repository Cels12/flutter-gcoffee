import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:gcoffee_r/pages/styles/notification_styles.dart' as showtoast;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gcoffee_r/pages/admin/edit_menu.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gcoffee_r/pages/admin/add_menu.dart';
import 'package:gcoffee_r/pages/admin/dashboard.dart';
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  // Fungsi untuk delete menu
  Future<void> _deleteMenu(BuildContext context, int id) async {
    try {
      final supabase = Supabase.instance.client;
      final response =
          await supabase.from('menu').select('gambar').eq('id', id).single();
      if (response['gambar'] != null) {
        final imageUrl = response['gambar'];
        final imagePath = Uri.parse(imageUrl).pathSegments.last;

        await supabase.storage.from('image').remove([imagePath]);
      }
      await supabase.from('menu').delete().match({'id': id});

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Menu berhasil di hapus')));
      }
    } catch (e) {
      if (kDebugMode) {
        print('error deleting menu $e');
      }
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menghapus menu')));
      }
    }
  }

  Future<List<Map<String, dynamic>>> _fetchMenu() async {
    final response = await supabase.from('menu').select();
    return response;
  }

  String formatCurrency(int amount) {
    final format = NumberFormat('#,###', 'id_ID');
    return 'Rp. ${format.format(amount)}';
  }

  final TextEditingController search = TextEditingController();

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

          // card Read, Update dan Delete
          Positioned.fill(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 120, left: 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Tombol tambah menu
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 130),
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddMenu(),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              fixedSize: Size(184, 50),
                              backgroundColor: Color.fromARGB(255, 84, 47, 17),
                            ),
                            child: Text(
                              'Tambah Menu',
                              style: TextStyle(
                                fontFamily: 'Oxanium',
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    FutureBuilder(
                      future: _fetchMenu(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('error : ${snapshot.error}'),
                          );
                        } else {
                          final menuList = snapshot.data ?? [];
                          return Column(
                            children:
                                menuList.map((menu) {
                                  return SizedBox(
                                    width: 1300,
                                    child: Card(
                                      elevation: 3,
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Row(
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: 220,
                                                  height: 200,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                    child:
                                                        menu['gambar'] !=
                                                                    null &&
                                                                menu['gambar']
                                                                    .isNotEmpty
                                                            ? Image.network(
                                                              menu['gambar'],
                                                              fit: BoxFit.cover,
                                                            )
                                                            : Placeholder(),
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Text(
                                                  menu['nama_menu'],
                                                  style: TextStyle(
                                                    fontFamily: 'Oxanium',
                                                    fontSize: 30,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  formatCurrency(menu['harga']),
                                                  style: TextStyle(
                                                    fontFamily: 'Oxanium',
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color.fromARGB(
                                                      255,
                                                      84,
                                                      47,
                                                      17,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(width: 20),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Deskripsi :',
                                                    style: TextStyle(
                                                      fontFamily: 'Oxanium',
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Text(menu['deskripsi']),
                                                  const SizedBox(height: 160),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      const SizedBox(width: 10),
                                                      ElevatedButton(
                                                        onPressed: () async {
                                                          final updated = await Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (
                                                                    context,
                                                                  ) => EditMenu(
                                                                    id:
                                                                        menu['id'],
                                                                    intialNamaMenu:
                                                                        menu['nama_menu'],
                                                                    initialDesk:
                                                                        menu['deskripsi'],
                                                                    initialHarga:
                                                                        menu['harga']
                                                                            .toString(),
                                                                    initialGambar:
                                                                        menu['gambar'],
                                                                  ),
                                                            ),
                                                          );
                                                          if (updated == true) {
                                                            if (context
                                                                .mounted) {
                                                              showtoast.showToast(
                                                                context,
                                                                title:
                                                                    'Berhasil mengubah menu',
                                                                message:
                                                                    'Success',
                                                                Type:
                                                                    ToastificationType
                                                                        .success,
                                                              );
                                                            }
                                                          }
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.brown,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  10,
                                                                ),
                                                          ),
                                                          fixedSize: const Size(
                                                            120,
                                                            40,
                                                          ),
                                                        ),
                                                        child: const Text(
                                                          'Edit',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      ElevatedButton(
                                                        onPressed: () async {
                                                          await _fetchMenu();
                                                          if (context.mounted) {
                                                            await _deleteMenu(
                                                              context,
                                                              menu['id'],
                                                            );
                                                          }
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              const Color.fromARGB(
                                                                255,
                                                                249,
                                                                66,
                                                                0,
                                                              ),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  10,
                                                                ),
                                                          ),
                                                          fixedSize: const Size(
                                                            120,
                                                            40,
                                                          ),
                                                        ),
                                                        child: const Text(
                                                          'Hapus',
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
                                  );
                                }).toList(),
                          );
                        }
                      },
                    ),
                    //Card untuk show Menu
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Dashboard(),
                            ),
                          );
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
                      message: 'Add menu',
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AddMenu()),
                          );
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
