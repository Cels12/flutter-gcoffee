// ignore_for_file: unused_local_variable

import 'dart:async';
import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gcoffee_r/routes/route_name.dart';
import 'package:gcoffee_r/styles/sidebarAdmin.dart';
import 'package:gcoffee_r/styles/textstyles.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';
import 'package:gcoffee_r/styles/notification_styles.dart';
import 'package:gcoffee_r/controller/auth/auth.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart' show kIsWeb;

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
  Timer? _statusUpdateTimer;

  // Default values for card info
  int penjualanHarian = 0;
  int penjualanBulanan = 0;
  int jumlahMenu = 0;
  int pendapatanBulanan = 0;

  Future<void> filterPesanan(String mainFilter, String subFilter) async {
    try {
      final now = DateTime.now();
      final today = DateFormat('yyyy-MM-dd').format(now);
      final thisMonth = DateFormat('yyyy-MM').format(now);
      final lastMonth = DateFormat(
        'yyyy-MM',
      ).format(DateTime(now.year, now.month - 1));
      final thisYear = DateFormat('yyyy').format(now);
      final lastYear = DateFormat('yyyy').format(DateTime(now.year - 1));

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
          case 'Tahun Ini':
            query = query.gte('created_at', '$thisYear-01-01');
          case 'Tahun Lalu':
            query = query
                .gte('created_at', '$lastYear-01-01')
                .lt('created_at', '$thisYear-01-01');
            break;
        }
      }
      final response = await query.order('created_at', ascending: false);

      if (mounted) {
        if (response.isEmpty) {
          showToast(
            context,
            title: 'Data kosong',
            message: 'Tidak ada data untuk periode yang dipilih',
            Type: ToastificationType.info,
          );
        }
      }

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
            final id = pesanan['id'].toString().toLowerCase();
            final username = pesanan['username'].toString().toLowerCase();
            final pesananItems = pesanan['pesanan'].toString().toLowerCase();
            final nomorMeja = pesanan['nomor_meja'].toString().toLowerCase();
            final status = pesanan['status_pesanan'].toString().toLowerCase();

            return username.contains(query) ||
                pesananItems.contains(query) ||
                nomorMeja.contains(query) ||
                status.contains(query) ||
                id.contains(query);
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

  Future<int> getPendapatanBulanan() async {
    try {
      final bulanIni = DateFormat('yyyy-MM').format(DateTime.now());
      final response = await supabase
          .from('pesanan')
          .select('total')
          .eq('status_pesanan', 'Selesai')
          .gte('created_at', '$bulanIni-01');
      double totalPendapatan = 0;
      for (var item in response) {
        totalPendapatan += item['total'];
      }
      return totalPendapatan.toInt();
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
    return 0;
  }

  Future<void> fetchDashboardData() async {
    await getDataHarian();
    await getDataBulanan();
    await getDataMenu();
    await getPendapatanBulanan();
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
      // Get current status first
      final response =
          await supabase
              .from('pesanan')
              .select('status_pesanan')
              .eq('id', pesananId)
              .single();

      final currentStatus = response['status_pesanan'] as String;

      if (currentStatus == 'Sedang dibuat') {
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
      } else if (currentStatus == 'Siap Diantar') {
        if (mounted) {
          showToast(
            context,
            title: 'Warning!',
            message: 'Status pesanan sudah Siap Diantar!',
            Type: ToastificationType.info,
          );
        }
      } else {
        if (mounted) {
          showToast(
            context,
            title: 'Warning!',
            message: 'Status pesanan tidak dapat diubah lagi!',
            Type: ToastificationType.warning,
          );
        }
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
      // Get current status first
      final response =
          await supabase
              .from('pesanan')
              .select('status_pesanan')
              .eq('id', pesananId)
              .single();

      final currentStatus = response['status_pesanan'] as String;

      if (currentStatus == 'Selesai') {
        if (mounted) {
          showToast(
            context,
            title: 'Warning!',
            message: 'Status pesanan sudah selesai!',
            Type: ToastificationType.warning,
          );
        }
      } else {
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

  Future<void> checkAndUpdateOrderStatus() async {
    try {
      // Get current timestamp
      final now = DateTime.now();

      // Get orders that are still in 'Sedang dibuat' status
      final response = await supabase
          .from('pesanan')
          .select()
          .eq('status_pesanan', 'Sedang dibuat');

      for (var order in response) {
        // Parse the created_at timestamp
        final createdAt = DateTime.parse(order['created_at']);

        // Calculate time difference
        final difference = now.difference(createdAt);

        // If more than 30 minutes have passed
        if (difference.inMinutes >= 30) {
          // Update the order status
          await supabase
              .from('pesanan')
              .update({'status_pesanan': 'Siap Diantar'})
              .eq('id', order['id']);

          // Refresh the orders list
          await fetchPesanan();
        }
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

  @override
  void initState() {
    super.initState();
    fetchPesanan();
    fetchDashboardData();
    _statusUpdateTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      checkAndUpdateOrderStatus();
    });
    search.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    search.removeListener(_onSearchChanged);
    search.dispose();
    _statusUpdateTimer?.cancel();
    super.dispose();
  }

  bool _isLoading = false;

  bool _isDownloadOpen = false;
  void _toogleDownload() {
    setState(() {
      _isDownloadOpen = !_isDownloadOpen;
    });
  }

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

  Future<void> exportToExcel() async {
    try {
      // Create a new workbook
      final xlsio.Workbook workbook = xlsio.Workbook();
      final xlsio.Worksheet sheet = workbook.worksheets[0];

      // Add headers
      sheet.getRangeByIndex(1, 1).setText('Menu');
      sheet.getRangeByIndex(1, 2).setText('Tanggal Pembelian');
      sheet.getRangeByIndex(1, 3).setText('Harga');
      sheet.getRangeByIndex(1, 4).setText('Total Penjualan (Item)');
      sheet.getRangeByIndex(1, 5).setText('Total Pendapatan');

      // Group orders by date
      Map<String, List<Map<String, dynamic>>> ordersByDate = {};
      Map<String, int> dailyItemCount = {};
      Map<String, double> dailyRevenue = {};

      for (var order in _pesananList) {
        String date = DateFormat(
          'yyyy-MM-dd',
        ).format(DateTime.parse(order['created_at']));

        if (!ordersByDate.containsKey(date)) {
          ordersByDate[date] = [];
          dailyItemCount[date] = 0;
          dailyRevenue[date] = 0;
        }

        ordersByDate[date]!.add(order);

        // Parse pesanan string to get individual items
        String pesananStr = order['pesanan'].toString();
        List<String> items =
            pesananStr.split(',').map((e) => e.trim()).toList();
        dailyItemCount[date] = dailyItemCount[date]! + items.length;
        dailyRevenue[date] =
            dailyRevenue[date]! + (order['total'] as num).toDouble();
      }

      // Write data rows
      int rowIndex = 2;
      ordersByDate.forEach((date, orders) {
        for (var order in orders) {
          String pesananStr = order['pesanan'].toString();
          List<String> items =
              pesananStr.split(',').map((e) => e.trim()).toList();

          for (var item in items) {
            // Write individual menu items
            sheet.getRangeByIndex(rowIndex, 1).setText(item);
            sheet
                .getRangeByIndex(rowIndex, 2)
                .setText(
                  DateFormat(
                    'dd/MM/yyyy HH:mm',
                  ).format(DateTime.parse(order['created_at'])),
                );
            // For simplicity, dividing total by number of items. You may want to adjust this based on your actual price structure
            double pricePerItem =
                (order['total'] as num).toDouble() / items.length;
            sheet.getRangeByIndex(rowIndex, 3).setNumber(pricePerItem);
            sheet
                .getRangeByIndex(rowIndex, 4)
                .setNumber(dailyItemCount[date]!.toDouble());
            sheet.getRangeByIndex(rowIndex, 5).setNumber(dailyRevenue[date]!);
            rowIndex++;
          }
        }
        // Add a separator line between dates
        sheet.getRangeByIndex(rowIndex, 1, rowIndex, 5).cellStyle.backColor =
            '#E0E0E0';
        rowIndex++;
      });

      // Format header
      final xlsio.Style headerStyle = workbook.styles.add('headerStyle');
      headerStyle.backColor = '#4472C4';
      headerStyle.fontColor = '#FFFFFF';
      headerStyle.bold = true;
      sheet.getRangeByIndex(1, 1, 1, 5).cellStyle = headerStyle;

      // Auto fit columns
      sheet.autoFitColumn(1); // Menu
      sheet.autoFitColumn(2); // Tanggal
      sheet.autoFitColumn(3); // Harga
      sheet.autoFitColumn(4); // Total Items
      sheet.autoFitColumn(5); // Total Pendapatan

      // Format currency columns
      final xlsio.Style currencyStyle = workbook.styles.add('currencyStyle');
      currencyStyle.numberFormat = 'Rp#,##0';
      sheet.getRangeByIndex(2, 3, rowIndex - 1, 3).cellStyle = currencyStyle;
      sheet.getRangeByIndex(2, 5, rowIndex - 1, 5).cellStyle = currencyStyle;

      // Save file
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      if (kIsWeb) {
        // For web
        final blob = html.Blob([
          bytes,
        ], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor =
            html.AnchorElement(href: url)
              ..setAttribute('download', 'laporan_pesanan.xlsx')
              ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        // For mobile
        final directory = await getApplicationDocumentsDirectory();
        final file = io.File('${directory.path}/laporan_pesanan.xlsx');
        await file.writeAsBytes(bytes, flush: true);
        await OpenFile.open(file.path);
      }

      if (mounted) {
        showToast(
          context,
          title: 'Berhasil',
          message: 'Laporan berhasil diekspor ke Excel',
          Type: ToastificationType.success,
        );
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
            right: 20,
            top: 70,
            child: IconButton(
              onPressed: _toogleProfile,
              icon: HeroIcon(HeroIcons.user, size: 40, color: Colors.grey),
            ),
          ),

          // Cards Information
          Positioned(
            top: 40,
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
                    width: 50,
                    height: 50,
                  ),
                  getDataMenu(),
                ),
                const SizedBox(height: 10),
                // Card for menu count
                _buildCard(
                  "Pendapatan Total Bulan Ini",
                  HeroIcon(
                    HeroIcons.currencyDollar,
                    size: 70,
                    color: Colors.grey,
                  ),
                  getPendapatanBulanan(),
                ),
              ],
            ),
          ),
          // Teks Laporan,filter, sama button download laporan
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
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.62,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //search field
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

                  //dropdown filter status
                  SizedBox(
                    width: 165,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(40, 127, 217, 217),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value:
                              selectedMainFilter == 'Status'
                                  ? selectedSubFilter
                                  : 'Semua',
                          isExpanded: true,
                          icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
                          style: TextStyle(
                            fontFamily: 'Oxanium',
                            color: Colors.grey,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'Semua',
                              child: Text('Status'),
                            ),
                            DropdownMenuItem(
                              value: 'Sedang dibuat',
                              child: Text('Sedang dibuat'),
                            ),
                            DropdownMenuItem(
                              value: 'Siap Diantar',
                              child: Text('Siap Diantar'),
                            ),
                            DropdownMenuItem(
                              value: 'Selesai',
                              child: Text('Selesai'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedMainFilter = 'Status';
                              selectedSubFilter = value!;
                              filterPesanan('Status', value);
                            });
                          },
                        ),
                      ),
                    ),
                  ),

                  //dropdown filter waktu
                  SizedBox(
                    width: 165,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(40, 127, 217, 217),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value:
                              selectedMainFilter == 'Waktu'
                                  ? selectedSubFilter
                                  : 'Semua',
                          isExpanded: true,
                          icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
                          style: TextStyle(
                            fontFamily: 'Oxanium',
                            color: Colors.grey,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'Semua',
                              child: Text('Waktu'),
                            ),
                            DropdownMenuItem(
                              value: 'Hari Ini',
                              child: Text('Hari Ini'),
                            ),
                            DropdownMenuItem(
                              value: 'Bulan Ini',
                              child: Text('Bulan Ini'),
                            ),
                            DropdownMenuItem(
                              value: 'Bulan Lalu',
                              child: Text('Bulan Lalu'),
                            ),
                            DropdownMenuItem(
                              value: 'Tahun Ini',
                              child: Text('Tahun Ini'),
                            ),
                            DropdownMenuItem(
                              value: 'Tahun Lalu',
                              child: Text('Tahun Lalu'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedMainFilter = 'Waktu';
                              selectedSubFilter = value!;
                              filterPesanan('Waktu', value);
                            });
                          },
                        ),
                      ),
                    ),
                  ),

                  //button download laporan
                  TextButton(
                    onPressed: () {
                      _toogleDownload();
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
          ),

          // Tabel data pesanan dengan pagination
          Positioned(
            top: 220,
            left: 565,
            child: Column(
              children: [
                SizedBox(
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
                                                  pesanan['username']
                                                      .toString(),
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
                                                      pesanan['pesanan']
                                                          .toString(),
                                                      style: getDescBlack(
                                                        context,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  pesanan['nomor_meja']
                                                      .toString(),
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
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Color.fromARGB(
                                                              255,
                                                              127,
                                                              88,
                                                              56,
                                                            ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                5,
                                                              ),
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
                                                    const SizedBox(width: 15),
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        await updateStatusSelesai(
                                                          pesanan['id'],
                                                        );
                                                        await fetchPesanan();
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.green,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                5,
                                                              ),
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
                                ],
                              ),
                            ),
                          ),
                ),
                const SizedBox(height: 20),
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
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  i == currentPage ? Colors.orange : null,
                              foregroundColor:
                                  i == currentPage ? Colors.white : null,
                            ),
                            onPressed: () {
                              setState(() {
                                currentPage = i;
                              });
                            },
                            child: Text(i.toString()),
                          ),
                        )
                      else if (i == currentPage - 2 || i == currentPage + 2)
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

          //button dropdown download laporan
          AnimatedPositioned(
            duration: Duration(microseconds: 300),
            top: _isDownloadOpen ? 200 : -200,
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
                          await exportToExcel();
                          _toogleDownload();
                        },
                        child: Text(
                          'EXCEL',
                          style: TextStyle(
                            fontFamily: 'Oxanium',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.only(top: 12.0),
                    //   child: TextButton(
                    //     onPressed: () async {
                    //       await exportToPDF();
                    //       _toogleDownload();
                    //     },
                    //     child: Text(
                    //       'PDF',
                    //       style: TextStyle(
                    //         fontFamily: 'Oxanium',
                    //         fontSize: 16,
                    //         fontWeight : FontWeight.w500,
                    //         color: Colors.white,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
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
                width: 120,
                height: 50,
                color: Colors.red,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5.5, left: 5),
                      child: TextButton(
                        onPressed: () async {
                          final authService = AuthService();
                          await authService.signOut();
                          if (context.mounted) {
                            context.goNamed(RouteNames.loginScreen);
                          }
                        },
                        child: Text(
                          'Logout',
                          style: TextStyle(
                            fontFamily: 'Oxanium',
                            fontSize: 24,
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
          buildSidebarAdmin(context: context, isMenuOpen: _isMenuOpen),

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
        ],
      ),
    );
  }

  Widget _buildCard(String title, Widget iconWidget, Future<int> futureData) {
    return SizedBox(
      width: 430,
      height: 170,
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
