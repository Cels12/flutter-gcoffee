import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gcoffee_r/pages/customer/homepage_cust.dart';
import 'package:gcoffee_r/pages/styles/notification_styles.dart';
import 'package:gcoffee_r/pages/styles/textstyles.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: mejaInput());
  }
}

class mejaInput extends StatefulWidget {
  const mejaInput({super.key});

  @override
  State<mejaInput> createState() => _mejaInputState();
}

class _mejaInputState extends State<mejaInput> {
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
              .maybeSingle(); // Handle no rows gracefully

      if (response != null &&
          response['id_meja'] == nomorMejaController.text.trim()) {
        // If the kode meja is valid, navigate to homePageCust with the id_meja
        setState(() {
          isLoading = false;
          isMejaCorrect = true;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    homePageCust(idMeja: response['nomor_meja'].toString()),
          ),
        );
      } else {
        // If no match is found
        setState(() {
          isLoading = false;
          isMejaCorrect = false;
        });
        showToast(
          context,
          title: 'Kode Meja Tidak Valid!',
          message: '$response',
          Type: ToastificationType.error,
        );
      }
    } catch (e) {
      // Handle errors (e.g., database connection issues)
      setState(() {
        isLoading = false;
        isMejaCorrect = false;
      });
      showToast(
        context,
        title: 'Terjadi Kesalahan!',
        message: 'Gagal memverifikasi kode meja: $e',
        Type: ToastificationType.error,
      );
    }
  }

  @override
  void dispose() {
    nomorMejaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('GCoffee', style: getTitleWhite(context)),
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
            width: 550,
            height: 600,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 5,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      'Selamat datang!',
                      style: TextStyle(fontFamily: 'Righteous', fontSize: 36),
                    ),
                  ),
                  SizedBox(height: 5),
                  Center(
                    child: Text(
                      'Silahkan meminta kode akses ke pelayan atau lihat di nomor meja',
                      style: TextStyle(
                        fontFamily: 'Oxanium',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 70),
                  SizedBox(
                    width: 450,
                    child: TextField(
                      controller: nomorMejaController,
                      decoration: InputDecoration(
                        labelText: 'Masukkan Kode Meja',
                        labelStyle: TextStyle(
                          fontFamily: 'Oxanium',
                          fontSize: 16,
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

                  SizedBox(height: 10),
                  if (isMejaCorrect)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        'Kode meja tidak valid',
                        style: TextStyle(
                          color: Colors.red,
                          fontFamily: 'Oxanium',
                          fontSize: 14,
                        ),
                      ),
                    ),

                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: isLoading ? null : _checkMeja,
                    style: TextButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 127, 88, 56),
                      fixedSize: Size(450, 40),
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
