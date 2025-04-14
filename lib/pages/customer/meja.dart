import 'package:flutter/material.dart';
import 'package:gcoffee_r/routes/route_name.dart';
import 'package:gcoffee_r/styles/notification_styles.dart';
import 'package:gcoffee_r/styles/textstyles.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MejaInput());
  }
}

class MejaInput extends StatefulWidget {
  const MejaInput({super.key});

  @override
  State<MejaInput> createState() => _MejaInputState();
}

class _MejaInputState extends State<MejaInput> {
  final TextEditingController nomorMejaController = TextEditingController();
  final SupabaseClient supabase = Supabase.instance.client;
  bool isLoading = false;
  bool isMejaCorrect = false;
  bool isMejaInputEmpty = false;

  Future<void> _checkMeja() async {
    setState(() {
      isLoading = true;
      isMejaInputEmpty = nomorMejaController.text.trim().isEmpty;
      isMejaCorrect = false;
    });

    if (isMejaInputEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      // Query the database to check if the input matches any id_meja
      final response =
          await supabase
              .from('meja')
              .select('*')
              .ilike('id_meja', nomorMejaController.text.trim())
              .maybeSingle();

      if (response != null &&
          response['id_meja'] == nomorMejaController.text.trim()) {
        // If the kode meja is valid, navigate to homePageCust with the id_meja
        setState(() {
          isLoading = false;
          isMejaCorrect = true;
        });
        if (mounted) {
          context.goNamed(
            RouteNames.homepageCust,
            extra: response['nomor_meja'].toString(),
          );
        }
      } else {
        // If no match is found
        setState(() {
          isLoading = false;
          isMejaCorrect = false;
        });
        if (mounted) {
          showToast(
            context,
            title: 'Kode Meja Tidak Valid!',
            message: 'Tolong masukkan kode meja yang valid',
            Type: ToastificationType.error,
          );
        }
      }
    } catch (e) {
      // Handle errors (e.g., database connection issues)
      setState(() {
        isLoading = false;
        isMejaCorrect = false;
      });
      if (mounted) {
        showToast(
          context,
          title: 'Terjadi Kesalahan!',
          message: 'Gagal memverifikasi kode meja: $e',
          Type: ToastificationType.error,
        );
      }
    }
  }

  @override
  void dispose() {
    nomorMejaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('GCoffee', style: getTitleWhite(context)),
        actions:
            isMobile
                ? [
                  IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: () {
                      // Buka drawer atau menu
                    },
                  ),
                ]
                : null,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color.fromRGBO(141, 58, 4, 1.0),
              Color.fromRGBO(39, 16, 1, 1.0),
            ],
          ),
        ),
        child: Center(
          child: Container(
            width: isMobile ? screenWidth * 0.9 : 550,
            height: isMobile ? screenHeight * 0.7 : 600,
            padding: EdgeInsets.all(isMobile ? 15 : 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(50),
                  blurRadius: 5,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.only(top: isMobile ? 15 : 25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      'Selamat datang!',
                      style: TextStyle(
                        fontFamily: 'Righteous',
                        fontSize: isMobile ? 28 : 36,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Center(
                    child: Text(
                      'Silahkan meminta kode akses ke pelayan atau lihat di nomor meja',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Oxanium',
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: isMobile ? 40 : 70),
                  Container(
                    width: isMobile ? screenWidth * 0.8 : 450,
                    child: TextField(
                      controller: nomorMejaController,
                      decoration: InputDecoration(
                        labelText: 'Masukkan Kode Meja',
                        labelStyle: TextStyle(
                          fontFamily: 'Oxanium',
                          fontSize: isMobile ? 14 : 16,
                        ),
                        border: OutlineInputBorder(),
                        errorText:
                            isMejaInputEmpty
                                ? 'Kode meja tidak boleh kosong'
                                : null,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isLoading ? null : _checkMeja,
                    style: TextButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 127, 88, 56),
                      fixedSize: Size(isMobile ? screenWidth * 0.8 : 450, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child:
                        isLoading
                            ? const CircularProgressIndicator(
                              color: Color.fromARGB(255, 210, 156, 100),
                            )
                            : const Text(
                              'Masuk',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Oxanium',
                                fontSize: 16,
                              ),
                            ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
