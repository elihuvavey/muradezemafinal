import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muradezema/commons/custom_images.dart';

import '../screens/payment_screen.dart';
import 'custom_text.dart';

class BookCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final int episodes;
  final bool isPurchased;
  final double price;
  final int id;
  

  const BookCard({
    required this.imagePath,
    required this.title,
    required this.episodes,
    required this.isPurchased,
    required this.price,
    required this.id,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Background image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CustomNetworkImageView(
              imageUrl: imagePath,
              fallbackImageUrl:
                  "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1974&auto=format&fit=crop",
              width: 150,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          // Dark overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.black.withOpacity(0.1),
            ),
          ),

       if (!isPurchased)
         Positioned(
           top: 8,
           left: 8,
           child: InkWell( 
            onTap: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PaymentPage(
                            isCategory: true,
                            phone: 'phone',
                            price: price.toInt(),
                            productId: id,
                            type: 'book')),
                  );
            },
            child:  Container(
             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
             decoration: BoxDecoration(
               gradient: LinearGradient(
                 colors: [Color(0xFFff9800), Color(0xFFff5722)],
                 begin: Alignment.topLeft,
                 end: Alignment.bottomRight,
               ),
               borderRadius: BorderRadius.circular(8),
               boxShadow: [
                 BoxShadow(
                   color: Colors.black.withOpacity(0.2),
                   blurRadius: 4,
                   offset: Offset(0, 2),
                 ),
               ],
             ),
             child: Row(
               mainAxisSize: MainAxisSize.min,
               children: [
                 Icon(Icons.lock, size: 16, color: Colors.white),
                 SizedBox(width: 4),
                 Text(
                   "purchase",
                   style: TextStyle(
                     color: Colors.white,
                     fontWeight: FontWeight.bold,
                     fontSize: 12,
                   ),
                 ),
               ],
             ),
           ),),
         ),

          // Positioned episodes count (TOP RIGHT)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomText(
                '$episodes',
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                const SizedBox(height: 5),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xff444444),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8.r),
                      bottomRight: Radius.circular(8.r),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomText(
                      title,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
