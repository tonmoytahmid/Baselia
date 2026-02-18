import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Donationpaymentscreen extends StatefulWidget {
  final double donationAmount;

  const Donationpaymentscreen({super.key, required this.donationAmount});

  @override
  State<Donationpaymentscreen> createState() => _DonationpaymentscreenState();
}

class _DonationpaymentscreenState extends State<Donationpaymentscreen> {
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _churches = [];
  List<DocumentSnapshot> _filteredChurches = [];

  // Store selected church details
  String _selectedChurchName = '';
  String _selectedChurchLocation = '';
  String _selectedChurchProfileImage = '';
  bool _isChurchSelected = false;

  @override
  void initState() {
    super.initState();
    _fetchChurches();
  }

  // Fetch churches from Firestore
  void _fetchChurches() async {
    final QuerySnapshot churchData =
        await FirebaseFirestore.instance.collection('ChurchPages').get();
    setState(() {
      _churches = churchData.docs;
      _filteredChurches = _churches;
    });
  }

  // Filter churches based on search query
  void _filterChurches(String query) {
    setState(() {
      _filteredChurches = _churches.where((church) {
        final churchName = church['churchName'].toLowerCase();
        final location = church['churchLocation'].toLowerCase();
        return churchName.contains(query.toLowerCase()) ||
            location.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Donate",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.purple),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // Ensure scrollable content
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // Donation Info Card (Dynamic content after selection)
                if (_selectedChurchName.isNotEmpty &&
                    _selectedChurchLocation.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedChurchName, // Dynamic church name
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedChurchLocation, // Dynamic church location
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '\$${widget.donationAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.purple,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      ],
                    ),
                  ),

                // const SizedBox(height: 24),

                // const SizedBox(height: 30),

                // Add Comment Section
                if (_selectedChurchName.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add a comment (optional)',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: TextField(
                          controller: _noteController,
                          maxLines: 4,
                          decoration: const InputDecoration.collapsed(
                            hintText: "Write your comment here...",
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),

                // Donate Button
                if (_selectedChurchName.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Show payment method dialog when the user taps donate
                        _showPaymentDialog(
                            _selectedChurchName, _noteController.text);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Donate",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),

                SizedBox(
                  height: 10,
                ),

                // Show search bar & results only if no church is selected
                if (!_isChurchSelected) ...[
                  TextField(
                    controller: _searchController,
                    onChanged: _filterChurches,
                    decoration: InputDecoration(
                      labelText: 'Search for a Church',
                      hintText: 'Enter church name or location',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _filteredChurches.length,
                    itemBuilder: (context, index) {
                      final church = _filteredChurches[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(church['profileImage']),
                        ),
                        title: Text(church['churchName']),
                        subtitle: Text(church['churchLocation']),
                        onTap: () {
                          _selectChurch(church);
                        },
                      );
                    },
                  ),
                ],

                // Search Bar
                // TextField(
                //   controller: _searchController,
                //   onChanged: _filterChurches,
                //   decoration: InputDecoration(
                //     labelText: 'Search for a Church',
                //     hintText: 'Enter church name or location',
                //     prefixIcon: Icon(Icons.search),
                //     border: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(12),
                //     ),
                //   ),
                // ),

                // const SizedBox(height: 24),

                // // Search Results
                // ListView.builder(
                //   shrinkWrap:
                //       true, // Ensures the list does not take too much space
                //   itemCount: _filteredChurches.length,
                //   itemBuilder: (context, index) {
                //     final church = _filteredChurches[index];
                //     return ListTile(
                //       leading: CircleAvatar(
                //         backgroundImage: NetworkImage(church['profileImage']),
                //       ),
                //       title: Text(church['churchName']),
                //       subtitle: Text(church['churchLocation']),
                //       onTap: () {
                //         _selectChurch(church);
                //       },
                //     );
                //   },
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Handle church selection and update dynamic church info
  void _selectChurch(DocumentSnapshot church) {
    setState(() {
      _selectedChurchName = church['churchName'];
      _selectedChurchLocation = church['churchLocation'];
      _selectedChurchProfileImage = church['profileImage'];
      _isChurchSelected = true; // ✅ mark as selected
    });
  }

  // Display Payment Dialog
  void _showPaymentDialog(String churchName, String comment) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Donate to $churchName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Your Comment: $comment'),
            const SizedBox(height: 10),
            const Text('Select payment method:'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPaymentButton("PayPal", Icons.account_balance_wallet, () {
                  _processPayment("PayPal");
                }),
                _buildPaymentButton("Plaid", Icons.account_balance, () {
                  _processPayment("Plaid");
                }),
                _buildPaymentButton("MTN Money", Icons.phone_android, () {
                  _processPayment("MTN Money");
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Payment Button Widget
  Widget _buildPaymentButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.purple.shade50,
            child: Icon(icon, color: Colors.purple),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  // Process Payment based on selected method
  void _processPayment(String method) async {
    // if (method == "PayPal") {
    //   final Uri url =
    //       Uri.parse('https://paypal.me/AKedje?country.x=CA&locale.x=en_US');

    //   if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    //     _showMessageDialog(
    //       title: "Error",
    //       message: "Could not launch PayPal donation link.",
    //     );
    //   }
    //   return;
    // }

    // // For Plaid and MTN Money, show placeholder
    // _showMessageDialog(
    //   title: "$method Payment",
    //   message: "$method integration coming soon. Please use PayPal for now.",
    // );
  }

  // Show message dialog
  void _showMessageDialog({required String title, required String message}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }
}






// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';

// import '../../Style/AppStyle.dart';

// class Donationpaymentscreen extends StatefulWidget {
//   final double donationAmount;

//   const Donationpaymentscreen({super.key, required this.donationAmount});

//   @override
//   State<Donationpaymentscreen> createState() => _DonationpaymentscreenState();
// }

// class _DonationpaymentscreenState extends State<Donationpaymentscreen> {
//   final TextEditingController _noteController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: whit,
//       appBar: AppBar(
//         backgroundColor: whit,
//         title: const Text(
//           "Donate",
//           style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         iconTheme: IconThemeData(color: purpal),
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 20),

//               // Donation Info Card
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Class Aptent Church',
//                       style:
//                           TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                     ),
//                     const SizedBox(height: 8),
//                     const Text(
//                       'Nullam non arcu et fermentuma port church\nlacinia non elit. Pellentesque habitant morbi',
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                     const SizedBox(height: 10),
//                     Text(
//                       '\$${widget.donationAmount.toStringAsFixed(2)}',
//                       style: const TextStyle(
//                         color: Colors.purple,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     )
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 24),

//               // Add Note
//               const Text(
//                 "Add Note",
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//               const SizedBox(height: 12),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.grey.shade200),
//                 ),
//                 child: TextField(
//                   controller: _noteController,
//                   maxLines: 4,
//                   decoration: const InputDecoration.collapsed(
//                     hintText: "Write your note...",
//                     hintStyle: TextStyle(color: Colors.grey),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 24),

//               const Text(
//                 "Choose Payment Method",
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//               const SizedBox(height: 12),

//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   _buildPaymentButton("PayPal", Icons.account_balance_wallet,
//                       () {
//                     _processPayment("PayPal");
//                   }),
//                   _buildPaymentButton("Plaid", Icons.account_balance, () {
//                     _processPayment("Plaid");
//                   }),
//                   _buildPaymentButton("MTN Money", Icons.phone_android, () {
//                     _processPayment("MTN Money");
//                   }),
//                 ],
//               ),

//               const SizedBox(height: 30),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildPaymentButton(String label, IconData icon, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         children: [
//           CircleAvatar(
//             radius: 28,
//             backgroundColor: Colors.purple.shade50,
//             child: Icon(icon, color: Colors.purple),
//           ),
//           const SizedBox(height: 8),
//           Text(label, style: const TextStyle(fontSize: 13)),
//         ],
//       ),
//     );
//   }

//   void _processPayment(String method) async {
//     if (method == "PayPal") {
//       final Uri url =
//           Uri.parse('https://paypal.me/AKedje?country.x=CA&locale.x=en_US');

//       if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
//         _showMessageDialog(
//           title: "Error",
//           message: "Could not launch PayPal donation link.",
//         );
//       }
//       return;
//     }

//     // For Plaid and MTN Money, show placeholder
//     _showMessageDialog(
//       title: "$method Payment",
//       message: "$method integration coming soon. Please use PayPal for now.",
//     );
//   }

//   void _showMessageDialog({required String title, required String message}) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text(title),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("OK"),
//           )
//         ],
//       ),
//     );
//   }
// }




// import 'package:baseliae_flutter/Style/AppStyle.dart';
// import 'package:flutter/material.dart';

// class Donationpaymentscreen extends StatefulWidget {
//   const Donationpaymentscreen({super.key});

//   @override
//   State<Donationpaymentscreen> createState() => _DonationpaymentscreenState();
// }

// class _DonationpaymentscreenState extends State<Donationpaymentscreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: whit,
//       appBar: AppBar(
//         backgroundColor: whit,
//         title: Text(
//           "Donate",
//           style: TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//         iconTheme: IconThemeData(color: purpal),
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
             

//               const SizedBox(height: 20),

//               // Donation Info Card
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: const [
//                     Text(
//                       'Class Aptent Church',
//                       style:
//                           TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       'Nullam non arcu et fermentuma port church\nlacinia non elit. Pellentesque habitant morbi',
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                     SizedBox(height: 10),
//                     Text(
//                       '\$2,500',
//                       style: TextStyle(
//                         color: Colors.purple,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     )
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 24),

//               // Payment Method
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: const [
//                   Text(
//                     "Payment Method",
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                   ),
//                   Text(
//                     "edit",
//                     style: TextStyle(
//                         color: Colors.purple, fontWeight: FontWeight.w500),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Row(
//                   children: [
//                     const Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "Caspian Bellevedere",
//                             style: TextStyle(fontWeight: FontWeight.w600),
//                           ),
//                           SizedBox(height: 6),
//                           Text(
//                             "**** **** **** 1234",
//                             style: TextStyle(color: Colors.grey),
//                           )
//                         ],
//                       ),
//                     ),
//                     Container(
//                       height: 30,
//                       width: 40,
//                       decoration: BoxDecoration(
//                         color: Colors.blueGrey.shade100,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     )
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 24),

//               // Add Note
//               const Text(
//                 "Add Note",
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//               const SizedBox(height: 12),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.grey.shade200),
//                 ),
//                 child: const TextField(
//                   maxLines: 4,
//                   decoration: InputDecoration.collapsed(
//                     hintText: "Write your note...",
//                     hintStyle: TextStyle(color: Colors.grey),
//                   ),
//                 ),
//               ),

//               const Spacer(),

//               // Donate Button
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () {},
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: purpal,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: const Text(
//                     "Donate",
//                     style: TextStyle(fontSize: 18, color: whit),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
