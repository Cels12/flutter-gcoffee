import 'package:flutter/material.dart';
import 'package:gcoffee_r/styles/notification_styles.dart';
import 'package:gcoffee_r/styles/sidebarAdmin.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';

class AddMeja extends StatefulWidget {
  const AddMeja({super.key});

  @override
  State<AddMeja> createState() => _AddMejaState();
}

class _AddMejaState extends State<AddMeja> {
  final TextEditingController idMejaController = TextEditingController();
  final TextEditingController nomorMejaController = TextEditingController();

  Future<List<Map<String, dynamic>>> fetchMeja() async {
    try {
      final response = await Supabase.instance.client
          .from('meja')
          .select()
          .order('nomor_meja', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching meja: $e');
      if (mounted) {
        showToast(
          context,
          title: 'Error',
          message: 'Gagal mengambil data meja',
          Type: ToastificationType.error,
        );
      }
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
  }

  //add the menu to supabase
  Future<void> _saveMeja() async {
    final id_meja = idMejaController.text.trim();
    final nomor_meja = nomorMejaController.text.trim();

    if (id_meja.isEmpty || nomor_meja.isEmpty) {
      showToast(
        context,
        title: 'Peringatan',
        message: 'ID meja atau Nomor meja tidak boleh kosong!',
        Type: ToastificationType.warning,
      );
      return;
    }
    try {
      await Supabase.instance.client.from('meja').insert({
        'id_meja': id_meja,
        'nomor_meja': nomor_meja,
      });

      // Clear the input fields
      idMejaController.clear();
      nomorMejaController.clear();

      if (mounted) {
        showToast(
          context,
          title: 'Berhasil',
          message: 'Meja berhasil ditambahkan',
          Type: ToastificationType.success,
        );
        // Force a rebuild to refresh the meja list
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        showToast(
          context,
          title: 'Gagal',
          message: 'Gagal menambahkan meja',
          Type: ToastificationType.error,
        );
      }
      debugPrint('Error adding meja : ${e.toString()}');
    }
  }

  void showMessage(String message) {
    showToast(
      context,
      title: message,
      message: message,
      Type: ToastificationType.info,
    );
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
                padding: const EdgeInsets.only(top: 120),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 1200,
                      height: 600,
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Bagian Deskripsi dan Tombol
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  //Meja
                                  SizedBox(
                                    height: 300,
                                    width: 1000,
                                    child: FutureBuilder<
                                      List<Map<String, dynamic>>
                                    >(
                                      future: fetchMeja(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        } else if (snapshot.hasError) {
                                          return Center(
                                            child: Text(
                                              'Error: ${snapshot.error}',
                                            ),
                                          );
                                        } else if (!snapshot.hasData ||
                                            snapshot.data!.isEmpty) {
                                          return const Center(
                                            child: Text('Tidak ada data meja'),
                                          );
                                        }
                                        final mejaList = snapshot.data!;
                                        return SingleChildScrollView(
                                          child: Wrap(
                                            spacing: 60,
                                            runSpacing: 20,
                                            alignment: WrapAlignment.start,
                                            children:
                                                mejaList.map((meja) {
                                                  return Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                      color:
                                                          const Color.fromARGB(
                                                            255,
                                                            217,
                                                            217,
                                                            217,
                                                          ),
                                                    ),
                                                    height: 50,
                                                    width: 150,
                                                    child: Center(
                                                      child: Text(
                                                        meja['id_meja']
                                                            .toString(),
                                                        style: TextStyle(
                                                          fontFamily: 'Oxanium',
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 1152,
                                    child: Divider(
                                      thickness: 1,
                                      color: Colors.black,
                                      height: 2,
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  // TextField nama menu
                                  SizedBox(
                                    width: 800,
                                    child: TextField(
                                      controller: idMejaController,
                                      maxLines: 1,
                                      decoration: InputDecoration(
                                        label: Text(
                                          'ID Meja',
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
                                      controller: nomorMejaController,
                                      maxLines: 1,
                                      decoration: InputDecoration(
                                        label: Text(
                                          'Nomor Meja',
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
                                  const SizedBox(height: 10),
                                  // Row Tombol
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Tombol Simpan
                                      ElevatedButton(
                                        onPressed: () {
                                          _saveMeja();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          fixedSize: const Size(120, 40),
                                        ),
                                        child: const Text(
                                          'Simpan',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      const SizedBox(width: 50),

                                      // Tombol reset
                                      ElevatedButton(
                                        onPressed: () {
                                          idMejaController.clear();
                                          nomorMejaController.clear();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          fixedSize: const Size(120, 40),
                                        ),
                                        child: const Text(
                                          'Reset',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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
          buildSidebarAdmin(context: context, isMenuOpen: _isMenuOpen),
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
