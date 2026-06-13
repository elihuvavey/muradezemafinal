import 'dart:io';
import 'package:muradezema/services/iap_service.dart';
import 'package:muradezema/utils/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:muradezema/commons/custom_info_dialog.dart';
import 'package:muradezema/screens/peinding_payments.dart';
import 'package:muradezema/utils/endpoint.dart';
import 'package:muradezema/utils/user_prefs.dart';
import 'package:provider/provider.dart';
import '../commons/custom_appbar.dart';
import '../commons/custom_bottom_nav.dart';
import '../provider/dark_mode.dart';
import '../utils/location_utils.dart';
import '../utils/nav_constants.dart';
import 'inapp_web_screen.dart';

class PaymentPage extends StatefulWidget {
  final String type;
  final int price;
  final bool isCategory;
  final String phone;
  final int productId;

  const PaymentPage({
    super.key,
    required this.isCategory,
    required this.phone,
    required this.price,
    required this.productId,
    required this.type,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  List<Map<String, String>> get paymentMethods {
    if (Platform.isIOS) {
      // Show IAP products on iOS
      if (IAPService.instance.availableProducts.isNotEmpty) {
        return IAPService.instance.availableProducts.map((p) => {
          'icon': '__IAP_ICON__',
          'name': '${p.title} - ${p.price}',
          'productId': p.id,
        }).toList();
      }
      return [{
        'icon': '__IAP_ICON__',
        'name': 'In-App Purchase',
        'productId': '${widget.type}.${widget.productId}',
      }];
    }
    if (HivePrefs.getBool('isLocal') == true) {
      return [
        {
          'icon': 'assets/images/cbe.png',
          'name': 'Bank Transfer',
        },
        {
          'icon': 'assets/images/paypal.png',
          'name': 'Paypal',
        },
        {
          'icon': 'assets/images/santimpay.png',
          'name': 'SantimPay',
        },
      ];
    } else {
      return [
        {
          'icon': 'assets/images/paypal.png',
          'name': 'Paypal',
        },
      ];
    }
  }

  int _currentIndex = 1;
  int? selectedMethodIndex;
  bool isLoading = false;
  int? _copiedBankIndex;
  List<Map<String, dynamic>> banks = [];
  bool isBanksLoading = false;
  String? banksError;

  final _phoneController = TextEditingController(text: '+251');

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      IAPService.instance.onPurchaseSuccess = (productId) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Purchase successful!')),
          );
          Navigator.pop(context, true);
        }
      };
      IAPService.instance.onPurchaseError = (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Purchase failed: $error')),
          );
        }
      };
      IAPService.instance.fetchProducts({'com.app.muradezema.audio.test'});
    } else {
      _fetchBanks();
    }
  }

  Future<void> _fetchBanks() async {
    debugPrint('Fetching banks... url: ${ApiConstants.banks}');
    setState(() {
      isBanksLoading = true;
      banksError = null;
    });
    try {
      final dio = createDio();
      final response = await dio.get(ApiConstants.banks);
      debugPrint(
          'Fetching banks: statusCode=${response.statusCode}, data=${response.data}');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> banksData = response.data['banks'] ?? [];
        banks = banksData
            .map<Map<String, dynamic>>((bank) => {
                  'name': bank['name']?.toString() ?? '',
                  'account_number': bank['account_number']?.toString() ?? '',
                })
            .toList();
        debugPrint('Banks loaded: $banks');
      } else {
        banksError = 'Failed to load banks.';
        debugPrint(
            'Failed to load banks: statusCode=${response.statusCode}, data=${response.data}');
      }
    } catch (e) {
      banksError = 'Error loading banks.';
      debugPrint('Error loading banks: $e');
    } finally {
      if (mounted)
        setState(() {
          isBanksLoading = false;
        });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  bool get isSantimPaySelected =>
      selectedMethodIndex != null &&
      paymentMethods[selectedMethodIndex!]['name']?.toLowerCase() ==
          'santimpay';

  String getSelectedEndpoint() {
    if (selectedMethodIndex == null)
      return ApiConstants.cbeUrl; // default/fallback
    final methodName =
        paymentMethods[selectedMethodIndex!]['name']?.toLowerCase();
    if (methodName == 'santimpay') {
      return ApiConstants.orderUrl;
    } else if (methodName == 'paypal') {
      return ApiConstants.paypalUrl;
    } else if (methodName == 'Bank Transfer') {
      return ApiConstants.cbeUrl;
    }
    return ApiConstants.cbeUrl; // fallback
  }

  @override
  Widget build(BuildContext context) {
    bool? isLocal = HivePrefs.getBool('isLocal');
    debugPrint('islocal $isLocal and iscategory ${widget.isCategory} type ${widget.type}');
    bool isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;
    Color backgroundColor = isDarkMode ? Color(0xFF1C1C1E) : Color(0xfff0eded);
    Color textColor = isDarkMode ? Colors.white : Colors.black;

    final cardColor = isDarkMode ? Color(0xFF232323) : Colors.white;
    final iconColor = isDarkMode ? Colors.orange[300] : Colors.orange[700];
    final subtitleColor = isDarkMode ? Colors.grey[300] : Colors.grey[700];
    final checkColor = Colors.green;
    final checkBgColor = isDarkMode ? Colors.green[900] : Colors.green[50];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: MyCustomAppBar(
        title: '',
        onBack: () => Navigator.of(context).pop(),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Color(0xffB4A0B1)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.dark_mode, color: Color(0xffB4A0B1)),
            onPressed: () =>
                Provider.of<DarkModeProvider>(context, listen: false)
                    .toggleDarkMode(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () =>
                  Navigator.pushNamed(context, NavigationConstants.profile),
              child: CircleAvatar(
                backgroundColor: Colors.orange,
                child:
                    Image.asset('assets/images/avatar.png', fit: BoxFit.cover),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 0) {
            Navigator.pushNamed(context, NavigationConstants.bookHome);
          } else if (index == 1) {
            Navigator.pushNamed(context, NavigationConstants.audioHome);
          } else if (index == 2) {
            Navigator.pushNamed(context, NavigationConstants.videoHome);
          } else {
            Navigator.pushNamed(context, NavigationConstants.purchased);
          }
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12.h),
              Text(
                'Total: ${widget.price} ${isLocal ?? false ? 'ETB' : '\$'}',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Choose payment method',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: ListView.builder(
                  itemCount: paymentMethods.length,
                  itemBuilder: (context, index) {
                    final method = paymentMethods[index];
                    final isSelected = selectedMethodIndex == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedMethodIndex = index;
                        });
                        selectedMethodIndex == 0 && HivePrefs.getBool('isLocal') == true
                            ? showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: backgroundColor,
                                builder: (context) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: backgroundColor,
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(28),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.08),
                                          blurRadius: 16,
                                          offset: const Offset(0, -4),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          24, 24, 24, 32),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Center(
                                            child: Container(
                                              width: 40,
                                              height: 4,
                                              decoration: BoxDecoration(
                                                color: subtitleColor,
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 18),
                                          Row(
                                            children: [
                                              Icon(
                                                  Icons
                                                      .account_balance_wallet_rounded,
                                                  color: iconColor,
                                                  size: 28),
                                              const SizedBox(width: 10),
                                              Text(
                                                'Bank Transfer',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: iconColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            'Select and copy a bank account below to make your payment.',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: subtitleColor,
                                            ),
                                          ),
                                          const SizedBox(height: 18),
                                          if (isBanksLoading)
                                            Center(
                                                child:
                                                    CircularProgressIndicator()),
                                          if (banksError != null)
                                            Center(child: Text(banksError!)),
                                          if (!isBanksLoading &&
                                              banksError == null)
                                            ...banks
                                                .asMap()
                                                .entries
                                                .map((entry) {
                                              final bank = entry.value;
                                              final index = entry.key;
                                              return Card(
                                                elevation: 2,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 6),
                                                child: ListTile(
                                                  leading: Icon(
                                                      Icons.account_balance),
                                                  title:
                                                      Text(bank['name'] ?? ''),
                                                  subtitle: Text(
                                                      bank['account_number'] ??
                                                          ''),
                                                  trailing: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      IconButton(
                                                        icon: Icon(Icons.copy),
                                                        onPressed: () {
                                                          Clipboard.setData(
                                                              ClipboardData(
                                                                  text: bank[
                                                                          'account_number'] ??
                                                                      ''));
                                                          setState(() =>
                                                              _copiedBankIndex =
                                                                  index);
                                                          Future.delayed(
                                                              Duration(
                                                                  seconds: 1),
                                                              () {
                                                            if (mounted &&
                                                                _copiedBankIndex ==
                                                                    index) {
                                                              setState(() =>
                                                                  _copiedBankIndex =
                                                                      null);
                                                            }
                                                          });
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                  'Account number copied!'),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      if (_copiedBankIndex ==
                                                          index)
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 4.0),
                                                          child: Text('Copied!',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .green,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }),
                                          const SizedBox(height: 28),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8),
                                            child: SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton.icon(
                                                icon: isLoading
                                                    ? LoadingAnimationWidget
                                                        .staggeredDotsWave(
                                                        color: Colors.white,
                                                        size: 28,
                                                      )
                                                    : const Icon(
                                                        Icons
                                                            .arrow_forward_rounded,
                                                        color: Colors.white),
                                                label: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 2),
                                                  child: Text(
                                                    isLoading ? '' : 'Continue',
                                                    style: const TextStyle(
                                                      fontSize: 17,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                onPressed: isLoading
                                                    ? null
                                                    : () async {
                                                        if (banks.isEmpty) {
                                                          return;
                                                        }
                                                        final selectedBank =
                                                            banks.first[
                                                                    'name'] ??
                                                                '';
                                                        final purchaseBody = {
                                                          "product_id":
                                                              widget.productId,
                                                          "product_type": widget.type,
                                                          "price": widget.price,
                                                          "is_category":
                                                              widget.isCategory,
                                                          "payment_method":
                                                              selectedBank,
                                                        };
                                                        final url = ApiConstants
                                                            .purchase;
                                                        debugPrint('POST $url');
                                                        debugPrint(
                                                            'Body: $purchaseBody');
                                                        setState(() =>
                                                            isLoading = true);
                                                        showDialog(
                                                          context: context,
                                                          barrierDismissible:
                                                              false,
                                                          builder: (context) =>
                                                              Center(
                                                                  child:
                                                                      CircularProgressIndicator()),
                                                        );
                                                        try {
                                                          final dio = createDio();
                                                          final response =
                                                              await dio.post(
                                                            url,
                                                            data: purchaseBody,
                                                            options: Options(
                                                              headers: {
                                                                'Accept':
                                                                    'application/json',
                                                                'Content-Type':
                                                                    'application/json',
                                                                'Authorization':
                                                                    'Bearer ${HivePrefs.getString('token')}',
                                                              },
                                                            ),
                                                          );
                                                          debugPrint(
                                                              'Response: ${response.statusCode} ${response.data}');
                                                          Navigator.of(context,
                                                                  rootNavigator:
                                                                      true)
                                                              .pop(); // dismiss loading
                                                          if (response.statusCode ==
                                                                  200 ||
                                                              response.statusCode ==
                                                                  201) {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        PendingPaymentsScreen(),
                                                              ),
                                                            );
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                  content: Text(
                                                                      'Your payment is pending! Please click on make payment and upload your payment receipt!')),
                                                            );
                                                          } else {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                  content: Text(
                                                                      'Purchase failed: \\${response.statusCode}')),
                                                            );
                                                          }
                                                        } catch (e) {
                                                          Navigator.of(context,
                                                                  rootNavigator:
                                                                      true)
                                                              .pop(); // dismiss loading
                                                          debugPrint(
                                                              'Error: $e');
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                                content: Text(
                                                                    'Error: \\${e.toString()}')),
                                                          );
                                                        } finally {
                                                          if (mounted)
                                                            setState(() =>
                                                                isLoading =
                                                                    false);
                                                        }
                                                      },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.orange[700],
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 16),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  elevation: 2,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              )
                            : null;
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.orange
                              : Colors.grey.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40.w,
                              height: 40.h,
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: method['icon'] == '__IAP_ICON__'
                                  ? Icon(Icons.apple, color: Colors.white, size: 30)
                                  : Image.asset(
                                      method['icon']!,
                                      fit: BoxFit.contain,
                                    ),
                            ),
                            SizedBox(width: 16.h),
                            Text(
                              method['name'] ?? '',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (isSantimPaySelected)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number (+251...)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixText: '',
                    ),
                  ),
                ),
              if (selectedMethodIndex != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handlePayment,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: isLoading
                          ? LoadingAnimationWidget.staggeredDotsWave(
                              color: Colors.white,
                              size: 30,
                            )
                          : const Text(
                              'Continue',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handlePayment() async {
    debugPrint('Handle payment called');
    
    // iOS: Use In-App Purchase
    if (Platform.isIOS) {
      if (selectedMethodIndex != null && selectedMethodIndex! < paymentMethods.length) {
        final productId = paymentMethods[selectedMethodIndex!]['productId'];
        if (productId != null) {
          setState(() => isLoading = true);
          await IAPService.instance.buyProduct(productId);
          setState(() => isLoading = false);
          return;
        }
      }
      return;
    }
    
    final methodName = selectedMethodIndex != null
        ? paymentMethods[selectedMethodIndex!]['name']?.toLowerCase()
        : null;
    debugPrint('Selected method: $methodName');

    if (methodName == 'Bank Transfer') {
      showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return FutureBuilder(
            future: createDio().get(ApiConstants.banks),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(child: Text('Failed to load banks.')),
                );
              } else if (!snapshot.hasData || snapshot.data == null) {
                return Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(child: Text('No banks found.')),
                );
              }
              final response = snapshot.data as Response;
              final List<dynamic> banksData = response.data['banks'] ?? [];
              return StatefulBuilder(
                builder: (context, setModalState) {
                  int? copiedBankIndex;
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Please select and copy one of these banks:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),
                        ...banksData.asMap().entries.map((entry) {
                          final bank = entry.value;
                          final index = entry.key;
                          return Card(
                            child: ListTile(
                              title: Text(bank['name']?.toString() ?? ''),
                              subtitle: Text(
                                  bank['account_number']?.toString() ?? ''),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.copy),
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(
                                          text: bank['account_number']
                                                  ?.toString() ??
                                              ''));
                                      setModalState(
                                          () => copiedBankIndex = index);
                                      Future.delayed(Duration(seconds: 1), () {
                                        if (copiedBankIndex == index) {
                                          setModalState(
                                              () => copiedBankIndex = null);
                                        }
                                      });
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text('Account number copied!'),
                                        ),
                                      );
                                    },
                                  ),
                                  if (copiedBankIndex == index)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4.0),
                                      child: Text('Copied!',
                                          style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }),
                        SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Continue'),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      );
      return;
    }

    if (isSantimPaySelected) {
      String phone = _phoneController.text.trim();
      if (phone.isEmpty || phone.length < 13 || !phone.startsWith('+251')) {
        showDialog(
          context: context,
          builder: (_) => CustomInfoDialog(
            title: 'Invalid Phone',
            message:
                'Please enter a valid phone number that starts with +251 and has at least 9 digits after +251.',
            buttonText: 'OK',
            onButtonPressed: () => Navigator.pop(context),
          ),
        );
        return;
      }
    }

    setState(() => isLoading = true);

    final dio = createDio();

    try {
      debugPrint('Making payment request...');
      debugPrint('Request data:  ${{
        "type": widget.type,
        "phone": _phoneController.text,
        "price": widget.price,
        "product_id": widget.productId,
        "is_category": widget.isCategory
      }}');

      debugPrint('endpoint  [35m${getSelectedEndpoint()}');

      final response = await dio.post(getSelectedEndpoint(),
          data: {
            "type": widget.type,
            "phone": _phoneController.text,
            "price": widget.price,
            "product_id": widget.productId,
            "is_category": widget.isCategory
          },
          options: Options(headers: {
            "Authorization": "Bearer  ${HivePrefs.getString('token')}",
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          }));

      debugPrint('Payment response: ${response.data}');

      if (!mounted) return;

      if (response.statusCode == 200 && response.data != null) {
        String? url;
        final methodName =
            paymentMethods[selectedMethodIndex!]['name']?.toLowerCase();
        if (methodName == 'paypal') {
          url = response.data['payment_url'];
        } else {
          url = response.data['url'];
        }
        if (url != null && url.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WebPageScreen(
                url: url!, // url is checked for null above
                title: "Payment Screen",
              ),
            ),
          );
        } else {
          throw Exception('Invalid payment URL received');
        }
      } else {
        throw Exception('Payment request failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Payment error: $e');
      if (!mounted) return;

      String errorMessage = 'An unexpected error occurred. Please try again.';

      if (e is DioException) {
        if (e.response != null) {
          final statusCode = e.response?.statusCode;
          switch (statusCode) {
            case 400:
              errorMessage =
                  'Bad request. Please check your input and try again.';
              break;
            case 401:
              errorMessage = 'Unauthorized. Please log in again.';
              break;
            case 403:
              errorMessage =
                  'You do not have permission to perform this action.';
              break;
            case 404:
              errorMessage =
                  'Payment service not found. Please try again later.';
              break;
            case 500:
              errorMessage = 'Server error. Please try again later.';
              break;
            default:
              errorMessage = e.response?.data?['message']?.toString() ??
                  'Payment failed with status code $statusCode.';
          }
        } else if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          errorMessage =
              'Connection timed out. Please check your internet connection.';
        } else if (e.type == DioExceptionType.badCertificate) {
          errorMessage = 'Bad certificate. Please contact support.';
        } else if (e.type == DioExceptionType.cancel) {
          errorMessage = 'Payment request was cancelled.';
        } else {
          errorMessage = 'Network error. Please check your connection.';
        }
      } else {
        errorMessage = e.toString();
      }

      showDialog(
        context: context,
        builder: (_) => CustomInfoDialog(
          title: 'Payment Error',
          message: errorMessage,
          buttonText: 'OK',
          onButtonPressed: () => Navigator.pop(context),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }
}
