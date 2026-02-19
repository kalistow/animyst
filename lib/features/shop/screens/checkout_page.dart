import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/top_up_package.dart';
import '../services/shop_service.dart';

class CheckoutPage extends StatefulWidget {
  final TopUpPackage package;

  const CheckoutPage({Key? key, required this.package}) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> with SingleTickerProviderStateMixin {
  final ShopService _shopService = ShopService();
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTransferConfirmation() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Anda belum login.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final paymentMethod = _tabController.index == 0 ? 'DANA' : 'GoPay';

    final success = await _shopService.submitTopUpRequest(user.id, widget.package, paymentMethod);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Permintaan Terkirim!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Request Anda telah kami terima dengan detail:'),
              const SizedBox(height: 10),
              Text('• Nominal: ${widget.package.formattedPrice}'),
              Text('• Gems: ${widget.package.formattedGems}'),
              Text('• Via: $paymentMethod'),
              const SizedBox(height: 10),
              const Text(
                'Developer akan mengecek mutasi rekening. Gems akan masuk dalam 1x24 jam jika pembayaran valid.',
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Pop Dialog
                Navigator.of(context).pop();
                // Pop CheckoutPage to go back to Shop
                Navigator.of(context).pop(); 
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.error_outline, color: Colors.red, size: 40),
          title: const Text("Gagal Mengirim"),
          content: const Text(
            "Terjadi kesalahan saat mengirim request. Pastikan koneksi internet stabil atau coba lagi nanti.\n\nJika masalah berlanjut, hubungi developer.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Tutup"),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran Manual'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blueGrey.shade900,
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Scan QRIS untuk Bayar',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Total: ${widget.package.formattedPrice}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.amberAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 30),
                
                // QRIS Image Container with Tabs
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Colors.deepPurple,
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white60,
                        tabs: const [
                          Tab(text: 'DANA'),
                          Tab(text: 'GoPay'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 380, // Fixed height for content
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // DANA View
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Image.asset(
                                  'assets/images/qris_dana.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                        child: Text('QR DANA Image Not Found', style: TextStyle(color: Colors.black54)));
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Scan via DANA',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          // GoPay View
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Image.asset(
                                  'assets/images/qris_gopay.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                        child: Text('QR GoPay Image Not Found', style: TextStyle(color: Colors.black54)));
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Scan via GoPay',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                const Text(
                  'A/N Muhamad Kurniawan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),
                const Text(
                  'Silahkan Screenshot QRIS ini jika perlu.',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                
                const SizedBox(height: 30),
                
                // Disclaimer
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    border: Border.all(color: Colors.amber.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 30),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          "Mohon Maaf. Saat ini Developer hanya menyediakan pembayaran manual via QRIS Statis (DANA/GoPay). Pembayaran otomatis belum tersedia.",
                          style: TextStyle(
                            color: Colors.amber.shade100,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Action Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleTransferConfirmation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 5,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Saya Sudah Transfer',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
