import 'package:muradezema/utils/dio_client.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:muradezema/utils/endpoint.dart';
import 'package:muradezema/utils/user_prefs.dart';
import 'package:provider/provider.dart';
import '../provider/bank_provider.dart';

class PendingPaymentsScreen extends StatefulWidget {
  const PendingPaymentsScreen({super.key});

  @override
  _PendingPaymentsScreenState createState() => _PendingPaymentsScreenState();
}

class _PendingPaymentsScreenState extends State<PendingPaymentsScreen> {
  List<Map<String, dynamic>> pendingPayments = [];
  bool isLoading = false;
  String? errorMessage;

  List<String> banks = [
    'Commercial Bank of Ethiopia',
    'Awash Bank',
    'Dashen Bank',
    'Abyssinia Bank',
    'Cooperative Bank of Oromia',
  ];

  @override
  void initState() {
    super.initState();
    _fetchPendingPayments();
  }

  Future<void> _fetchPendingPayments() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final dio = createDio();
      final response = await dio.get(
        ApiConstants.pendingPayments,
        options: Options(headers: {
          'Accept': 'application/json',
          
        }),
      );
      if (response.statusCode == 200 && response.data != null) {
        debugPrint('Pending payments: ${response.data}');
        final List<dynamic> orders = response.data['pending_orders'] ?? [];
        pendingPayments = orders
            .map<Map<String, dynamic>>((order) => {
                  'id': order['id'],
                  'payment_status': order['payment_status'],
                  'amount': order['amount'],
                  'date': order['date'],
                  'product': order['product'],
                  'type': order['type'],
                })
            .toList();
      } else {
        errorMessage = 'Failed to load pending payments.';
      }
    } catch (e) {
      errorMessage = 'Error loading pending payments.';
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showPaymentBottomSheet(
      BuildContext context, Map<String, dynamic> payment) {
    Map<String, dynamic>? selectedBank;
    TextEditingController referralController = TextEditingController();
    XFile? paymentImage;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final cardColor = isDark ? Color(0xFF232323) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtitleColor = isDark
        ? theme.textTheme.bodyMedium?.color
        : theme.textTheme.bodyMedium?.color;
    final iconColor = isDark ? Colors.orange[300] : Colors.orange[700];
    final checkColor = Colors.green;
    final checkBgColor = isDark ? Colors.green[900] : Colors.green[50];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return Theme(
          data: theme,
          child: Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: StatefulBuilder(
              builder: (context, setModalState) {
                return Consumer<BankProvider>(
                  builder: (context, bankProvider, _) {
                    if (bankProvider.isLoading) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (bankProvider.errorMessage != null) {
                      return Center(child: Text(bankProvider.errorMessage!));
                    }
                    final banks = bankProvider.banks;
                    if (banks.isEmpty) {
                      // Trigger fetch if not already loaded
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        bankProvider.fetchBanks();
                      });
                      return Center(child: CircularProgressIndicator());
                    }
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: subtitleColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Complete Your Payment",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: iconColor,
                            ),
                          ),
                          SizedBox(height: 24),
                          Text(
                            "Select Bank",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: textColor,
                            ),
                          ),
                          SizedBox(height: 8),
                          DropdownButtonFormField<Map<String, dynamic>>(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: backgroundColor,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                            value: selectedBank,
                            hint: Text("Choose your bank",
                                style: TextStyle(color: textColor)),
                            dropdownColor: cardColor,
                            items: banks
                                .map<DropdownMenuItem<Map<String, dynamic>>>(
                                    (bank) =>
                                        DropdownMenuItem<Map<String, dynamic>>(
                                          value: bank,
                                          child: Text(bank['name'],
                                              style:
                                                  TextStyle(color: textColor)),
                                        ))
                                .toList(),
                            onChanged: (bank) {
                              setModalState(() {
                                selectedBank = bank;
                              });
                            },
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Referral Number (optional)",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: textColor,
                            ),
                          ),
                          SizedBox(height: 8),
                          TextField(
                            controller: referralController,
                            decoration: InputDecoration(
                              hintText: "Enter referral number",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: backgroundColor,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              hintStyle: TextStyle(color: subtitleColor),
                            ),
                            style: TextStyle(color: textColor),
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Upload Payment Image",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: textColor,
                            ),
                          ),
                          SizedBox(height: 8),
                          GestureDetector(
                            onTap: () async {
                              final ImageSource? source =
                                  await showModalBottomSheet<ImageSource>(
                                context: context,
                                builder: (context) => SafeArea(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        leading: Icon(Icons.camera_alt),
                                        title: Text('Take a picture'),
                                        onTap: () => Navigator.pop(
                                            context, ImageSource.camera),
                                      ),
                                      ListTile(
                                        leading: Icon(Icons.photo_library),
                                        title: Text('Choose from gallery'),
                                        onTap: () => Navigator.pop(
                                            context, ImageSource.gallery),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                              if (source != null) {
                                final ImagePicker _picker = ImagePicker();
                                final XFile? image =
                                    await _picker.pickImage(source: source);
                                if (image != null) {
                                  setModalState(() {
                                    paymentImage = image;
                                  });
                                }
                              }
                            },
                            child: Container(
                              height: 140,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: iconColor ?? Colors.orange,
                                    width: 1.2),
                              ),
                              child: paymentImage == null
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.camera_alt,
                                            color: iconColor, size: 40),
                                        SizedBox(height: 8),
                                        Text(
                                          "Tap to upload image",
                                          style: TextStyle(color: iconColor),
                                        ),
                                      ],
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        File(paymentImage!.path),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: 140,
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                debugPrint('Selected bank: $selectedBank');
                                if (selectedBank == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Please select a bank!')),
                                  );
                                  return;
                                }
                                final bankId = selectedBank!['id'];
                                debugPrint('Bank ID: $bankId');
                                if (bankId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Invalid bank selected!')),
                                  );
                                  return;
                                }
                                if (paymentImage == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Please upload a payment image!')),
                                  );
                                  return;
                                }
                                final url = ApiConstants.confirmPayment;
                                final fields = {
                                  'orderid': payment['id'].toString(),
                                  'bankid': bankId.toString(),
                                  if (referralController.text.isNotEmpty)
                                    'ref_no': referralController.text,
                                  'file': paymentImage!.path,
                                };
                                print('POST $url');
                                print('Fields: $fields');
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => Center(
                                      child: CircularProgressIndicator()),
                                );
                                try {
                                  final dio = createDio();
                                  final formData = FormData();
                                  formData.fields
                                    ..add(MapEntry(
                                        'orderid', payment['id'].toString()))
                                    ..add(
                                        MapEntry('bankid', bankId.toString()));
                                  if (referralController.text.isNotEmpty) {
                                    formData.fields.add(MapEntry(
                                        'ref_no', referralController.text));
                                  }
                                  formData.files.add(MapEntry(
                                    'file',
                                    await MultipartFile.fromFile(
                                      paymentImage!.path,
                                      filename: paymentImage!.name,
                                    ),
                                  ));
                                  final response = await dio.post(
                                    url,
                                    data: formData,
                                    options: Options(
                                      headers: {
                                        'Authorization':
                                            'Bearer ${HivePrefs.getString('token')}',
                                        'Accept': 'multipart/form-data',
                                      },
                                    ),
                                  );
                                  debugPrint(
                                      'Response: ${response.statusCode} ${response.data}');
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                  if (response.statusCode == 200 ||
                                      response.statusCode == 201) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Payment confirmation submitted!')),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Failed to submit payment confirmation.')),
                                    );
                                  }
                                } catch (e) {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                  print('Error: $e');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Error: ${e.toString()}')),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: iconColor,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                "Submit Payment",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentCard(
      Map<String, dynamic> payment, Color cardColor, BuildContext context) {
    debugPrint('Payment: $payment');

    IconData icon = Icons.payment;
    Color color = Colors.grey;
    final type = (payment['type'] ?? '').toString().toLowerCase();
    if (type.contains('audio')) {
      icon = Icons.audiotrack;
      color = Colors.blueAccent;
    } else if (type.contains('video')) {
      icon = Icons.videocam;
      color = Colors.redAccent;
    } else if (type.contains('book')) {
      icon = Icons.book;
      color = Colors.green;
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final iconColor = isDark ? Colors.orange[300] : Colors.orange[700];
    final cardColor = isDark
        ? const Color.fromARGB(255, 103, 102, 102)
        : const Color.fromARGB(255, 90, 90, 90);
    return Card(
      color: cardColor,
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              radius: 28,
              child: Icon(icon, color: color, size: 32),
            ),
            SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Wrap product and type in Flexible widgets to prevent overflow
                      Flexible(
                        flex: 2,
                        child: Text(
                          payment['product'] ?? 'N/A',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.orange,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 15, color: Colors.white),
                      children: [
                        const TextSpan(text: "Amount: "),
                        TextSpan(
                          text: "${payment['amount']}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.hourglass_top, color: iconColor, size: 16),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          payment['payment_status'],
                          style: TextStyle(
                            color: iconColor,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: () => _showPaymentBottomSheet(context, payment),
              style: ElevatedButton.styleFrom(
                backgroundColor: iconColor,
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: Text(
                "Make Payment",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final cardColor = isDark ? Color(0xFF232323) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtitleColor = isDark ? Colors.grey[300] : Colors.grey[700];
    final iconColor = isDark ? Colors.orange[300] : Colors.orange[700];
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          "Pending Payments",
          style: TextStyle(
            color: isDark ? Colors.orange[300] : Colors.orange[800],
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(
            color: isDark ? Colors.orange[300] : Colors.orange[800]),
        centerTitle: true,
      ),
      body: pendingPayments.isEmpty
          ? isLoading
              ? Center(child: CircularProgressIndicator())
              : errorMessage != null
                  ? Center(child: Text(errorMessage!))
                  : Center(
                      child: Text(
                        "No pending payments!",
                        style: TextStyle(
                          fontSize: 18,
                          color: subtitleColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
          : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              itemCount: pendingPayments.length,
              itemBuilder: (context, index) {
                return _buildPaymentCard(
                    pendingPayments[index], cardColor, context);
              },
            ),
    );
  }
}
