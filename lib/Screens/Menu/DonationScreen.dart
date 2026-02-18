import 'package:baseliae_flutter/Screens/Menu/DonationPaymentScreen.dart';
import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Donationscreen extends StatefulWidget {
  const Donationscreen({super.key});

  @override
  State<Donationscreen> createState() => _DonationscreenState();
}

class _DonationscreenState extends State<Donationscreen> {
  double _donationAmount = 1500;
  bool isCandleSelected = false;
  bool isScriptureSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: whit,
        title: const Text(
          'Donate',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: purpal),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // const SizedBox(height: 16),
              // Align(
              //   alignment: Alignment.centerLeft,
              //   child: IconButton(
              //     icon: Icon(Icons.arrow_back, color: Colors.purple),
              //     onPressed: () {},
              //   ),
              // ),
              const SizedBox(height: 20),
              Image.asset(
                'assets/images/donation.png', // Replace with your asset
                height: 120,
              ),
              const SizedBox(height: 20),
              const Text('Choose Amount',
                  style: TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  '\$${_donationAmount.toInt()}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Slider(
                value: _donationAmount,
                min: 100,
                max: 2000,
                activeColor: Colors.green,
                inactiveColor: Colors.grey[300],
                divisions: 38,
                label: _donationAmount.toInt().toString(),
                onChanged: (value) {
                  setState(() {
                    _donationAmount = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              const Text(
                'You can also Select a Operation',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: _buildOperationCard(
                      title: 'Put a Candle',
                      price: 2,
                      icon: Icons.local_fire_department,
                      selected: isCandleSelected,
                      onTap: () {
                        setState(() {
                          if (isCandleSelected) {
                            _donationAmount -= 2;
                          } else {
                            _donationAmount += 2;
                          }
                          isCandleSelected = !isCandleSelected;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildOperationCard(
                      title: 'Scripture',
                      price: 10,
                      icon: Icons.menu_book,
                      selected: isScriptureSelected,
                      onTap: () {
                        setState(() {
                          if (isScriptureSelected) {
                            _donationAmount -= 10;
                          } else {
                            _donationAmount += 10;
                          }
                          isScriptureSelected = !isScriptureSelected;
                        });
                      },
                    ),
                  ),
                ],
              ),

              // Row(
              //   children: [
              //     Expanded(
              //       child: _buildOperationCard(
              //         title: 'Put a Candle',
              //         price: 2,
              //         icon: Icons.local_fire_department,
              //         selected: isCandleSelected,
              //         onTap: () {
              //           setState(() {
              //             isCandleSelected = !isCandleSelected;
              //           });
              //         },
              //       ),
              //     ),
              //     const SizedBox(width: 16),
              //     Expanded(
              //       child: _buildOperationCard(
              //         title: 'Scripture',
              //         price: 10,
              //         icon: Icons.menu_book,
              //         selected: isScriptureSelected,
              //         onTap: () {
              //           setState(() {
              //             isScriptureSelected = !isScriptureSelected;
              //           });
              //         },
              //       ),
              //     ),
              //   ],
              // ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purpal,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Next',
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  onPressed: () {
                    Get.to(() => Donationpaymentscreen(
                          donationAmount: _donationAmount,
                        ));
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildOperationCard({
  required String title,
  required int price,
  required IconData icon,
  required bool selected,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: selected ? Colors.purple.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? Colors.purple : Colors.transparent,
        ),
      ),
      child: Column(
        children: [
          Text(title,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 4),
          Text("\$$price", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Icon(icon, size: 28, color: Colors.black54),
          const SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.purple),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('Choose',
                style: TextStyle(
                    color: Colors.purple, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    ),
  );
}
