import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:muradezema/provider/search_purchased.dart';

import '../utils/nav_constants.dart';

class SearchPurchasedScreen extends StatefulWidget {
  const SearchPurchasedScreen({super.key});

  @override
  State<SearchPurchasedScreen> createState() => _SearchPurchasedScreenState();
}

class _SearchPurchasedScreenState extends State<SearchPurchasedScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;
  final Color textColor = Colors.white;

  String get _selectedType {
    switch (_selectedCategoryIndex) {
      case 0:
        return 'audio';
      case 1:
        return 'video';
      case 2:
        return 'book';
      default:
        return 'audio';
    }
  }

  Widget _buildCategoryButton(String title, int index) {
    final isSelected = _selectedCategoryIndex == index;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.orangeAccent : Colors.white12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: () {
        setState(() {
          _selectedCategoryIndex = index;
        });
        if (_searchController.text.isNotEmpty) {
          _performSearch();
        }
      },
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.black : Colors.white,
        ),
      ),
    );
  }

  void _performSearch() {
    final searchProvider = Provider.of<SearchPurchasesProvider>(context, listen: false);
    searchProvider.fetchPurchases(
      query: _searchController.text,
      type: _selectedType,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Search Purchases', style: TextStyle(color: textColor)),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          Provider.of<SearchPurchasesProvider>(context, listen: false).clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white12,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  _performSearch();
                } else {
                  Provider.of<SearchPurchasesProvider>(context, listen: false).clear();
                }
              },
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCategoryButton("Audio", 0),
                _buildCategoryButton("Video", 1),
                _buildCategoryButton("Book", 2),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: Consumer<SearchPurchasesProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return Center(
                      child: LoadingAnimationWidget.staggeredDotsWave(
                        color: Colors.orangeAccent,
                        size: 50.h,
                      ),
                    );
                  }

                  if (provider.errorMessage != null) {
                    return Center(
                      child: Text(
                        provider.errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (provider.results.isEmpty) {
                    return Center(
                      child: Text(
                        "No results found",
                        style: TextStyle(color: textColor),
                      ),
                    );
                  }

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: size.width > 600 ? 3 : 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: provider.results.length,
                    itemBuilder: (context, index) {
                      final item = provider.results[index];
                      return InkWell(
                        onTap: () {
                          debugPrint('item.isCategory: ${item.isCategory}');
                          debugPrint('id ${item.id}');
                          debugPrint('title ${item.title}');
                          debugPrint('image ${item.image}');
                          if (item.isCategory == true) {
                            if (_selectedType == 'audio') {
                            Navigator.pushNamed(context, NavigationConstants.allAudios, arguments: {'id': item.id, 'artistName': item.title, 'artistImage': item.image});
                              } else if (_selectedType == 'video') {
                              Navigator.pushNamed(context, NavigationConstants.allVideos, arguments: {'id': item.id, 'artistName': item.title, 'artistImage': item.image});
                            } else if (_selectedType == 'book') {
                              Navigator.pushNamed(context, NavigationConstants.bookList, arguments: {'id': item.id, 'bookTitle': item.title, 'bookImage': item.image});
                            }
                          } else {
                            if (_selectedType == 'audio') {
                              Navigator.pushNamed(context, NavigationConstants.allAudios, arguments: {'id': item.id, 'artistName': item.title, 'artistImage': item.image});
                            } else if (_selectedType == 'video') {
                              Navigator.pushNamed(context, NavigationConstants.allVideos, arguments: {'id': item.id, 'artistName': item.title, 'artistImage': item.image});
                            } else if (_selectedType == 'book') {
                              Navigator.pushNamed(context, NavigationConstants.bookList, arguments: {'id': item.id, 'bookTitle': item.title, 'bookImage': item.image});
                            }
                          }
                        },
                        child: Card(
                        color: Colors.white12,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                              child: Image.network(
                                item.image ?? '',
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      height: 120,
                                      color: Colors.grey,
                                      child: Icon(Icons.error),
                                    ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (item.description != null)
                                    Text(
                                      item.description.toString(),
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ));
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
