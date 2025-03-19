import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gcoffee_r/pages/add_menu.dart';
import 'package:gcoffee_r/pages/dashboard.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
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

          // card CRUD
          Positioned.fill(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 120, left: 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    SizedBox(
                      width: 1300,
                      height: 350,
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
                              // Bagian Gambar + Nama + Harga
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Gambar Menu
                                  SizedBox(
                                    width: 220,
                                    height: 200,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.asset(
                                        fit: BoxFit.cover,
                                        'assets/img/Cappuccino.jpg',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Nama Menu
                                  Text(
                                    'Cappuccino',
                                    style: TextStyle(
                                      fontFamily: 'Oxanium',
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  // Harga Menu
                                  Text(
                                    'Rp. 18,000',
                                    style: TextStyle(
                                      fontFamily: 'Oxanium',
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: Color.fromARGB(255, 84, 47, 17),
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
                                    // Label Deskripsi
                                    Text(
                                      'Deskripsi :',
                                      style: TextStyle(
                                        fontFamily: 'Oxanium',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    // TextField Deskripsi
                                    SizedBox(
                                      width: 800, // Sesuaikan lebar jika perlu
                                      child: TextField(
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(20),
                                        ],
                                        maxLines: 1,
                                        decoration: InputDecoration(
                                          hintText:
                                              'Masukkan deskripsi menu...',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 160),

                                    // Row Tombol
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // Tombol Simpan
                                        ElevatedButton(
                                          onPressed: () {},
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
                                        const SizedBox(width: 10),

                                        // Tombol Edit
                                        ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.brown,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            fixedSize: const Size(120, 40),
                                          ),
                                          child: const Text(
                                            'Edit',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),

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
                    ),

                    const SizedBox(height: 20),
                    SizedBox(
                      width: 1300,
                      height: 350,
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
                              // Bagian Gambar + Nama + Harga
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Gambar Menu
                                  SizedBox(
                                    width: 220,
                                    height: 200,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.asset(
                                        fit: BoxFit.cover,
                                        'assets/img/Cappuccino.jpg',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Nama Menu
                                  Text(
                                    'Cappuccino',
                                    style: TextStyle(
                                      fontFamily: 'Oxanium',
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  // Harga Menu
                                  Text(
                                    'Rp. 18,000',
                                    style: TextStyle(
                                      fontFamily: 'Oxanium',
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: Color.fromARGB(255, 84, 47, 17),
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
                                    // Label Deskripsi
                                    Text(
                                      'Deskripsi :',
                                      style: TextStyle(
                                        fontFamily: 'Oxanium',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    // TextField Deskripsi
                                    SizedBox(
                                      width: 800, // Sesuaikan lebar jika perlu
                                      child: TextField(
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(20),
                                        ],
                                        maxLines: 1,
                                        decoration: InputDecoration(
                                          hintText:
                                              'Masukkan deskripsi menu...',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 160),

                                    // Row Tombol
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // Tombol Simpan
                                        ElevatedButton(
                                          onPressed: () {},
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
                                        const SizedBox(width: 10),

                                        // Tombol Edit
                                        ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.brown,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            fixedSize: const Size(120, 40),
                                          ),
                                          child: const Text(
                                            'Edit',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),

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
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 1300,
                      height: 350,
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
                              // Bagian Gambar + Nama + Harga
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Gambar Menu
                                  SizedBox(
                                    width: 220,
                                    height: 200,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.asset(
                                        fit: BoxFit.cover,
                                        'assets/img/Cappuccino.jpg',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Nama Menu
                                  Text(
                                    'Cappuccino',
                                    style: TextStyle(
                                      fontFamily: 'Oxanium',
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  // Harga Menu
                                  Text(
                                    'Rp. 18,000',
                                    style: TextStyle(
                                      fontFamily: 'Oxanium',
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: Color.fromARGB(255, 84, 47, 17),
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
                                    // Label Deskripsi
                                    Text(
                                      'Deskripsi :',
                                      style: TextStyle(
                                        fontFamily: 'Oxanium',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    // TextField Deskripsi
                                    SizedBox(
                                      width: 800, // Sesuaikan lebar jika perlu
                                      child: TextField(
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(20),
                                        ],
                                        maxLines: 1,
                                        decoration: InputDecoration(
                                          hintText:
                                              'Masukkan deskripsi menu...',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 160),

                                    // Row Tombol
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // Tombol Simpan
                                        ElevatedButton(
                                          onPressed: () {},
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
                                        const SizedBox(width: 10),

                                        // Tombol Edit
                                        ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.brown,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            fixedSize: const Size(120, 40),
                                          ),
                                          child: const Text(
                                            'Edit',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),

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
                      message: 'Hellnaw',
                      child: TextButton(
                        onPressed: () => debugPrint('Add menu'),
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
