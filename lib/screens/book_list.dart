import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:muradezema/screens/payment_screen.dart';
import 'package:muradezema/utils/endpoint.dart';
import 'package:provider/provider.dart';
import '../provider/book_list_provider.dart';
import '../utils/nav_constants.dart';
import '../provider/favorite_provider.dart';
import '../utils/user_prefs.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  int? _seasonId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final newSeasonId = args['id'] as int;
    if (_seasonId != newSeasonId) {
      _seasonId = newSeasonId;
      Provider.of<BookListProvider>(context, listen: false)
          .loadBooks(_seasonId.toString());
    }
  }

  bool isFavorite = false;
  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final screenTitle = args['bookTitle'] as String;
    final provider = Provider.of<BookListProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          screenTitle,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: provider.isLoading
          ? Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.orangeAccent,
                size: 50.h,
              ),
            )
          : provider.error != null
              ? Center(
                  child: Text(
                    "No books found",
                    style: TextStyle(color: Colors.redAccent, fontSize: 16.sp),
                    textAlign: TextAlign.center,
                  ),
                )
              : Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: GridView.builder(
                    itemCount: provider.books.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14.w,
                      mainAxisSpacing: 14.h,
                      childAspectRatio: 0.68,
                    ),
                    itemBuilder: (context, index) {
                      final book = provider.books[index];
                      return GestureDetector(
                        onTap: book.isPurchased
                            ? () async {
                                try {
                                  final resp = await Dio().get(
                                      '${ApiConstants.baseUrl}/books/${book.id}/read', options: Options(
                                        headers: {
                                          'Authorization': 'Bearer ${HivePrefs.getString('token')}',
                                        },
                                      ));
                                  final pdfUrl = resp.data['pdf'] as String;
                                  if (pdfUrl.isNotEmpty) {
                                    Navigator.pushNamed(
                                        context, NavigationConstants.bookReader,
                                        arguments: {
                                          'filePath': pdfUrl,
                                          'fileType': 'pdf',
                                        });
                                  }
                                } catch (e) {
                                  debugPrint('Error loading PDF: $e');
                                }
                              }
                            : () {
                                bool? isLocal = HivePrefs.getBool('isLocal');
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PaymentPage(
                                          isCategory: false,
                                          phone: 'phone',
                                          price: isLocal ?? false
                                              ? book.priceInLocal ?? 0
                                              : book.priceInForeign ?? 0,
                                          productId: book.id,
                                          type: 'book')),
                                );
                              },
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.r),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF2A2A2A),
                                    Color(0xFF1A1A1A)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.4),
                                    offset: const Offset(0, 4),
                                    blurRadius: 8,
                                  ),
                                  BoxShadow(
                                    color: Colors.orange.withOpacity(0.08),
                                    offset: const Offset(-2, -2),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Hero(
                                    tag: 'book_cover_${book.id}',
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20.r),
                                        topRight: Radius.circular(20.r),
                                      ),
                                      child: Image.network(
                                        book.image ?? '',
                                        height: 140.h,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10.w, vertical: 8.h),
                                    child: Text(
                                      book.name,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14.sp,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10.w),
                                    child: Text(
                                      book.description ?? '',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12.sp,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Favorite Icon
                            Positioned(
                              top: 6.h,
                              right: 6.w,
                              child: Container(
                                width: 35.w,
                                // padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black45,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: IconButton(
                                    onPressed: () {
                                      Provider.of<FavoriteProvider>(context,
                                              listen: false)
                                          .toggleFavorite(
                                            isPurchased: book.isPurchased,
                                        'book',
                                        book.id.toString(),
                                        title: book.name ?? '',
                                        description: book.description ?? '',
                                        image: book.image ?? '',
                                      );
                                    },
                                    icon: Icon(
                                      Provider.of<FavoriteProvider>(context)
                                              .isFavorite(
                                                  'book', book.id.toString())
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color:
                                          Provider.of<FavoriteProvider>(context)
                                                  .isFavorite('book',
                                                      book.id.toString())
                                              ? Colors.orange
                                              : Colors.white,
                                      size: 20.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Buy Icon
                            book.isPurchased
                                ? SizedBox.shrink()
                                : Positioned(
                                    top: 10.h,
                                    left: 10.w,
                                    child: GestureDetector(
                                      onTap: () async {
                                        bool? isLocal =
                                            HivePrefs.getBool('isLocal');
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => PaymentPage(
                                                  isCategory: false,
                                                  phone: 'phone',
                                                  price: isLocal ?? false
                                                      ? book.priceInLocal ?? 0
                                                      : book.priceInForeign ??
                                                          0,
                                                  productId: book.id,
                                                  type: 'book')),
                                        );
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 4.h, horizontal: 10.w),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.orange.withOpacity(0.85),
                                              Colors.deepOrange
                                                  .withOpacity(0.85),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 8,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.payment,
                                              color: Colors.white,
                                              size: 14.sp,
                                            ),
                                            SizedBox(width: 4.w),
                                            Text(
                                              HivePrefs.getBool('isLocal') ??
                                                      false
                                                  ? "${book.priceInLocal} ETB"
                                                  : "${book.priceInForeign} USD",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11.sp,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
