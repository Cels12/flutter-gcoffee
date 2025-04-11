import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gcoffee_r/routes/route_name.dart';
import 'package:gcoffee_r/styles/textstyles.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';
import 'package:gcoffee_r/styles/notification_styles.dart';
import 'package:gcoffee_r/controller/auth/auth.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _pesananList = [];
  List<Map<String, dynamic>> _originalPesananList = [];
  String selectedMainFilter = 'Semua';
  String selectedSubFilter = 'Semua';

  // Default values for card info
  int penjualanHarian = 0;
  int penjualanBulanan = 0;
  int jumlahMenu = 0;

  Future<void> filterPesanan(String mainFilter, String subFilter) async {
    try {
      final now = DateTime.now();
      final today = DateFormat('yyyy-MM-dd').format(now);
      final thisMonth = DateFormat('yyyy-MM').format(now);
      final lastMonth = DateFormat(
        'yyyy-MM',
      ).format(DateTime(now.year, now.month - 1));

      var query = supabase.from('pesanan').select();

      //filter berdasarkan waktu
      if (mainFilter == 'Status') {
        if (subFilter != 'Semua') {
          query = query.eq('status_pesanan', subFilter);
        }
      } else if (mainFilter == 'Waktu') {
        switch (subFilter) {
          case 'Hari Ini':
            query = query.gte('created_at', today);
            break;
          case 'Bulan Ini':
            query = query.gte('created_at', '$thisMonth-01');
          case 'Bulan Lalu':
            query = query
                .gte('created_at', '$lastMonth-01')
                .lt('created_at', '$thisMonth-01');
            break;
        }
      }
      final response = await query.order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _pesananList = response;
          currentPage = 1;
        });
      }
    } catch (e) {
      if (mounted) {
        showToast(
          context,
          title: 'Error',
          message: e.toString(),
          Type: ToastificationType.error,
        );
      }
    }
  }

  Future<void> searchPesanan() async {
    String query = search.text.toLowerCase();

    if (query.isEmpty) {
      setState(() {
        _pesananList = _originalPesananList;
      });
      return;
    }

    setState(() {
      _pesananList =
          _originalPesananList.where((pesanan) {
            final username = pesanan['username'].toString().toLowerCase();
            final pesananItems = pesanan['pesanan'].toString().toLowerCase();
            final nomorMeja = pesanan['nomor_meja'].toString().toLowerCase();
            final status = pesanan['status_pesanan'].toString().toLowerCase();

            return username.contains(query) ||
                pesananItems.contains(query) ||
                nomorMeja.contains(query) ||
                status.contains(query);
          }).toList();
    });
  }

  void _onSearchChanged() {
    searchPesanan();
  }

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
      if (mounted) {
        showToast(
          context,
          title: 'Error',
          message: e.toString(),
          Type: ToastificationType.error,
        );
      }
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
      if (mounted) {
        showToast(
          context,
          title: 'Error',
          message: e.toString(),
          Type: ToastificationType.error,
        );
      }

      return 0;
    }
  }

  Future<int> getDataMenu() async {
    try {
      final response = await supabase.from('menu').select();
      return response.length;
    } catch (e) {
      if (mounted) {
        showToast(
          context,
          title: 'Error',
          message: e.toString(),
          Type: ToastificationType.error,
        );
      }
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
          _originalPesananList = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        showToast(
          context,
          title: 'Error',
          message: e.toString(),
          Type: ToastificationType.error,
        );
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Fungsi untuk mengganti status pesanan ke siap diantar
  Future<void> updateStatusAntar(int pesananId) async {
    try {
      // Update status untuk pesanan dengan ID spesifik
      await supabase
          .from('pesanan')
          .update({'status_pesanan': 'Siap Diantar'})
          .eq('id', pesananId);

      if (mounted) {
        showToast(
          context,
          title: 'Berhasil',
          message:
              'Berhasil mengubah status pesanan menjadi siap diantar, mohon beri tahu waitress untuk mengatarkan pesanan',
          Type: ToastificationType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        showToast(
          context,
          title: "Error",
          message: e.toString(),
          Type: ToastificationType.error,
        );
      }
    }
  }

  // Fungsi untuk mengganti status pesanan ke selesai
  Future<void> updateStatusSelesai(int pesananId) async {
    try {
      // Update status untuk pesanan dengan ID spesifik
      await supabase
          .from('pesanan')
          .update({'status_pesanan': 'Selesai'})
          .eq('id', pesananId);

      if (mounted) {
        showToast(
          context,
          title: 'Berhasil',
          message: 'Berhasil mengubah status pesanan menjadi Selesai',
          Type: ToastificationType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        showToast(
          context,
          title: "Error",
          message: e.toString(),
          Type: ToastificationType.error,
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPesanan();
    fetchDashboardData();
    search.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    search.removeListener(_onSearchChanged);
    search.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  bool _isProfileOpen = false;
  void _toogleProfile() {
    setState(() {
      _isProfileOpen = !_isProfileOpen;
    });
  }

  final TextEditingController search = TextEditingController();
  bool _isMenuOpen = false;
  final String initialValue = 'Filter';
  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  int currentPage = 1;
  final int rowsPerPage = 10; // Menampilkan 10 baris per halaman
  bool isTableVisible = false; // Untuk mengontrol visibilitas tabel

  @override
  Widget build(BuildContext context) {
    int totalPages = (_pesananList.length / rowsPerPage).ceil();
    int startIndex = (currentPage - 1) * rowsPerPage;
    int endIndex = (startIndex + rowsPerPage).clamp(0, _pesananList.length);

    List<Map<String, dynamic>> currentData = _pesananList.sublist(
      startIndex,
      endIndex,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background
          Container(color: const Color.fromARGB(255, 247, 247, 247)),

          Positioned(
            //left: 1460,
            right: 20,
            top: 70,
            child: IconButton(
              onPressed: _toogleProfile,
              icon: HeroIcon(HeroIcons.user, size: 40, color: Colors.grey),
            ),
          ),

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
                    controller: search,
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
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(40, 127, 217, 217),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedMainFilter,
                        isExpanded: true,
                        icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
                        style: TextStyle(
                          fontFamily: 'Oxanium',
                          color: Colors.grey,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'Semua',
                            child: Text('Semua'),
                          ),
                          DropdownMenuItem(
                            value: 'Status',
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Status'),
                                PopupMenuButton<String>(
                                  onSelected: (value) {
                                    setState(() {
                                      selectedSubFilter = value;
                                      filterPesanan('Status', value);
                                    });
                                  },
                                  itemBuilder:
                                      (context) => [
                                        PopupMenuItem(
                                          child: Text('Semua'),
                                          value: 'Semua',
                                        ),
                                        PopupMenuItem(
                                          child: Text('Sedang dibuat'),
                                          value: 'Sedang dibuat',
                                        ),
                                        PopupMenuItem(
                                          child: Text('Siap Diantar'),
                                          value: 'Siap Diantar',
                                        ),
                                        PopupMenuItem(
                                          child: Text('Selesai'),
                                          value: 'Selesai',
                                        ),
                                      ],
                                  child: Icon(
                                    Icons.arrow_right,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Waktu',
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Waktu'),
                                PopupMenuButton<String>(
                                  onSelected: (value) {
                                    setState(() {
                                      selectedSubFilter = value;
                                      filterPesanan('Waktu', value);
                                    });
                                  },
                                  itemBuilder:
                                      (context) => [
                                        PopupMenuItem(
                                          child: Text('Hari Ini'),
                                          value: 'Hari Ini',
                                        ),
                                        PopupMenuItem(
                                          child: Text('Bulan Ini'),
                                          value: 'Bulan Ini',
                                        ),
                                        PopupMenuItem(
                                          child: Text('Bulan Lalu'),
                                          value: 'Bulan Lalu',
                                        ),
                                      ],
                                  child: Icon(
                                    Icons.arrow_right,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == 'Semua') {
                            setState(() {
                              selectedMainFilter = value!;
                              selectedSubFilter = 'Semua';
                              _pesananList = _originalPesananList;
                            });
                          } else {
                            setState(() {
                              selectedMainFilter = value!;
                            });
                          }
                        },
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

          // Tabel data pesanan dengan pagination
          Positioned(
            top: 220,
            left: 565,
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 565,
              height: MediaQuery.of(context).size.height - 300,
              child:
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Column(
                            children: [
                              DataTable(
                                sortAscending: true,
                                columnSpacing: 25,
                                dataRowMinHeight: 40,
                                headingRowHeight: 50,
                                border: TableBorder.all(
                                  color: const Color.fromARGB(255, 0, 0, 0),
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
                                    label: Text(
                                      'Total',
                                      style: getDescBlack(context),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Status Pemesanan',
                                      style: getDescBlack(context),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 100.0,
                                      ),
                                      child: Text(
                                        'Aksi',
                                        style: getDescBlack(context),
                                      ),
                                    ),
                                  ),
                                ],
                                rows:
                                    currentData.map((pesanan) {
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
                                            SizedBox(
                                              width: 150,
                                              child: Tooltip(
                                                message:
                                                    pesanan['pesanan']
                                                        .toString(),
                                                child: Text(
                                                  pesanan['pesanan'].toString(),
                                                  style: getDescBlack(context),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
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
                                              pesanan['status_pesanan']
                                                  .toString(),
                                              style: getDescBlack(context),
                                            ),
                                          ),
                                          DataCell(
                                            Row(
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    await updateStatusAntar(
                                                      pesanan['id'],
                                                    );
                                                    await fetchPesanan();
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Color.fromARGB(
                                                              255,
                                                              127,
                                                              88,
                                                              56,
                                                            ),
                                                      ),
                                                  child: Text(
                                                    'Siap Diantar',
                                                    style: getButtonWhite(
                                                      context,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                  width: 5,
                                                ),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    await updateStatusSelesai(
                                                      pesanan['id'],
                                                    );
                                                    await fetchPesanan();
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Color.fromARGB(
                                                              255,
                                                              127,
                                                              88,
                                                              56,
                                                            ),
                                                      ),
                                                  child: Text(
                                                    'Selesai',
                                                    style: getButtonWhite(
                                                      context,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                              ),
                              // Kontrol pagination
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back),
                                    onPressed:
                                        currentPage > 1
                                            ? () {
                                              setState(() {
                                                currentPage--;
                                              });
                                            }
                                            : null,
                                  ),
                                  for (int i = 1; i <= totalPages; i++)
                                    if (i <= 3 ||
                                        i == totalPages ||
                                        (i - currentPage).abs() <= 1)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4.0,
                                        ),
                                        child: TextButton(
                                          style: TextButton.styleFrom(
                                            backgroundColor:
                                                i == currentPage
                                                    ? Colors.orange
                                                    : null,
                                            foregroundColor:
                                                i == currentPage
                                                    ? Colors.white
                                                    : null,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              currentPage = i;
                                            });
                                          },
                                          child: Text(i.toString()),
                                        ),
                                      )
                                    else if (i == currentPage - 2 ||
                                        i == currentPage + 2)
                                      const Text("..."),
                                  IconButton(
                                    icon: const Icon(Icons.arrow_forward),
                                    onPressed:
                                        currentPage < totalPages
                                            ? () {
                                              setState(() {
                                                currentPage++;
                                              });
                                            }
                                            : null,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
            ),
          ),

          //profile dropdown menu
          AnimatedPositioned(
            duration: Duration(microseconds: 300),
            top: _isProfileOpen ? 135 : -200,
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 200,
                height: 100,
                color: const Color.fromARGB(255, 210, 156, 108),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: TextButton(
                        onPressed: () async {
                          final authService = AuthService();
                          await authService.signOut();
                          if (context.mounted) {
                            context.goNamed(ROuteNames.loginScreen);
                          }
                        },
                        child: Text(
                          'Logout',
                          style: TextStyle(
                            fontFamily: 'Oxanium',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
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
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        try {
                          context.goNamed(ROuteNames.menupage);
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

          //sidebar menu icon
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
