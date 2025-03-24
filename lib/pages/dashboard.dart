import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gcoffee_r/pages/menupage.dart';
import 'package:gcoffee_r/pages/styles/textstyles.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';
import 'package:gcoffee_r/pages/styles/notification_styles.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _pesananList = [];

  // Default values for card info
  int penjualanHarian = 0;
  int penjualanBulanan = 0;
  int jumlahMenu = 0;

  Future<int> getDataHarian() async {
    try {
      final hariIni = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final response = await supabase
          .from('pesanan')
          .select()
          .eq('status_pesanan', 'Selesai')
          .gte('created_at', hariIni);
      return response.length;
    } catch (e) {
      showToast(
        context,
        title: 'Error',
        message: e.toString(),
        Type: ToastificationType.error,
      );
      return 0;
    }
  }

  Future<int> getDataBulanan() async {
    try {
      final bulanIni = DateFormat('yyyy-MM').format(DateTime.now());
      final response = await supabase
          .from('pesanan')
          .select()
          .eq('status_pesanan', 'Selesai')
          .gte('created_at', '$bulanIni-01');
      return response.length;
    } catch (e) {
      showToast(
        context,
        title: 'Error',
        message: e.toString(),
        Type: ToastificationType.error,
      );
      return 0;
    }
  }

  Future<int> getDataMenu() async {
    try {
      final response = await supabase.from('menu').select();
      return response.length;
    } catch (e) {
      showToast(
        context,
        title: 'Error',
        message: e.toString(),
        Type: ToastificationType.error,
      );
      return 0;
    }
  }

  Future<void> fetchDashboardData() async {
    await getDataHarian();
    await getDataBulanan();
    await getDataMenu();
  }

  Future<void> fetchPesanan() async {
    try {
      final response = await supabase
          .from('pesanan')
          .select()
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _pesananList = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      showToast(
        context,
        title: 'Error',
        message: e.toString(),
        Type: ToastificationType.error,
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  //fungsi untuk mengganti status pesanan ke selesai
  Future<void> updateStatusSelesai() async {
    try {
      final response = await supabase
          .from('pesanan')
          .update({'status_pesanan': 'Selesai'})
          .eq('status_pesanan', 'Siap Diambil');
      if (response != null) {
        showToast(
          context,
          title: 'Error',
          message: response.error.message,
          Type: ToastificationType.error,
        );
      } else {
        showToast(
          context,
          title: 'Berhasil',
          message: 'Berhasil mengubah status pesanan',
          Type: ToastificationType.success,
        );
      }
    } catch (e) {
      showToast(
        context,
        title: "Error",
        message: e.toString(),
        Type: ToastificationType.error,
      );
    }
  }

  //fungsi untuk mengganti status pesanan ke selesai
  Future<void> updateStatusAmbil() async {
    try {
      final response = await supabase
          .from('pesanan')
          .update({'status_pesanan': 'Siap Diambil'})
          .eq('status_pesanan', 'Sedang dibuat');
      if (response != null) {
        showToast(
          context,
          title: 'Error',
          message: response.error.message,
          Type: ToastificationType.error,
        );
      } else {
        showToast(
          context,
          title: 'Berhasil',
          message: 'Berhasil mengubah status pesanan',
          Type: ToastificationType.success,
        );
      }
    } catch (e) {
      showToast(
        context,
        title: "Error",
        message: e.toString(),
        Type: ToastificationType.error,
      );
    }
  }

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchPesanan();
    fetchDashboardData();
  }

  final TextEditingController search = TextEditingController();
  bool _isMenuOpen = false;
  final String initialValue = 'Filter';
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
          // Background
          Container(color: const Color.fromARGB(255, 247, 247, 247)),

          // Cards Information
          Positioned(
            top: 80,
            left: 110,
            child: Column(
              children: [
                // Card for daily sales
                _buildCard(
                  "Penjualan Hari Ini",
                  SvgPicture.asset(
                    'assets/icons/Chart_trendUp.svg',
                    width: 200,
                    height: 200,
                  ),
                  getDataHarian(),
                ),
                const SizedBox(height: 10),

                // Card for monthly sales
                _buildCard(
                  "Penjualan Bulan Ini",
                  SvgPicture.asset(
                    'assets/icons/Chart_trendUp.svg',
                    width: 200,
                    height: 200,
                  ),
                  getDataBulanan(),
                ),
                const SizedBox(height: 10),

                // Card for menu count
                _buildCard(
                  "Jumlah Menu",
                  SvgPicture.asset(
                    'assets/icons/Coffee_cup.svg',
                    width: 200,
                    height: 200,
                  ),
                  getDataMenu(),
                ),
              ],
            ),
          ),
          // Teks Laporan,filter, sama button laporan
          Positioned(
            top: 60,
            left: 565,
            child: Column(
              children: [
                Text(
                  'Laporan',
                  style: TextStyle(
                    fontSize: 40,
                    fontFamily: 'Oxanium',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 150,
            left: 565,
            child: Row(
              children: [
                SizedBox(
                  width: 250,
                  child: TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color.fromARGB(40, 217, 217, 217),
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      label: Text(
                        'Cari...',
                        style: TextStyle(
                          fontFamily: 'Righteous',
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                SizedBox(
                  width: 250,
                  child: PopupMenuButton<String>(
                    initialValue: initialValue,
                    onSelected: (String value) {
                      debugPrint('Filter Dipilih: $value');
                    },
                    itemBuilder:
                        (BuildContext context) => <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'semua',
                            child: Text('Semua'),
                          ),
                          PopupMenuItem<String>(
                            value: 'dibayar',
                            child: Text('Dibayar'),
                          ),
                          PopupMenuItem<String>(
                            value: 'selesai',
                            child: Text('Selesai'),
                          ),
                        ],
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 12.5,
                      ),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(40, 217, 217, 217),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Filter',
                            style: TextStyle(
                              color: Colors.grey,
                              fontFamily: 'Righteous',
                            ),
                          ),
                          SizedBox(width: 140),
                          Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 176),
                TextButton(
                  onPressed: () {
                    debugPrint('Download laporan');
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 127, 88, 56),
                    fixedSize: Size(250, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Text(
                    'Download Laporan',
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

          //table data
          Positioned(
            top: 220,
            left: 565,
            child: Container(
              color: Colors.white,
              child:
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : DataTable(
                        sortAscending: true,
                        border: TableBorder.all(
                          color: const Color.fromARGB(
                            255,
                            0,
                            0,
                            0,
                          ), // Garis antar sel
                          width: 1,
                        ),
                        columns: [
                          DataColumn(
                            label: Text(
                              'ID pemesanan',
                              style: getDescBlack(context),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Username',
                              style: getDescBlack(context),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Pesanan',
                              style: getDescBlack(context),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Nomor Meja',
                              style: getDescBlack(context),
                            ),
                          ),
                          DataColumn(
                            label: Text('Total', style: getDescBlack(context)),
                          ),
                          DataColumn(
                            label: Text(
                              'Status Pemesanan',
                              style: getDescBlack(context),
                            ),
                          ),
                          DataColumn(
                            label: Padding(
                              padding: const EdgeInsets.only(left: 90.0),
                              child: Text('Aksi', style: getDescBlack(context)),
                            ),
                          ),
                        ],
                        rows:
                            _pesananList.map((pesanan) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      pesanan['id'].toString(),
                                      style: getDescBlack(context),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      pesanan['username'].toString(),
                                      style: getDescBlack(context),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      pesanan['pesanan'].toString(),
                                      style: getDescBlack(context),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      pesanan['nomor_meja'].toString(),
                                      style: getDescBlack(context),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      pesanan['total'].toString(),
                                      style: getDescBlack(context),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      pesanan['status_pesanan'].toString(),
                                      style: getDescBlack(context),
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            updateStatusAmbil();
                                          },
                                          child: Text(
                                            'Siap Diambil',
                                            style: getDescBlack(context),
                                          ),
                                        ),
                                        const SizedBox(height: 10, width: 5),
                                        ElevatedButton(
                                          onPressed: () {
                                            updateStatusSelesai();
                                          },
                                          child: Text(
                                            'Selesai',
                                            style: getDescBlack(context),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
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
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Dashboard()),
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
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        try {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MenuPage()),
                          );
                        } catch (e) {
                          debugPrint('Nav error $e');
                        }
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

  Widget _buildCard(String title, Widget iconWidget, Future<int> futureData) {
    return SizedBox(
      width: 430,
      height: 220,
      child: Card(
        elevation: 3,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon on the left
              SizedBox(width: 80, height: 80, child: iconWidget),
              const SizedBox(width: 20),

              // Text column on the right
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Oxanium',
                      ),
                    ),
                    const SizedBox(height: 10),
                    FutureBuilder<int>(
                      future: futureData,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return const Text(
                            "0",
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Oxanium',
                            ),
                          );
                        }
                        final data = snapshot.data ?? 0;
                        return Text(
                          "$data",
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Oxanium',
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
