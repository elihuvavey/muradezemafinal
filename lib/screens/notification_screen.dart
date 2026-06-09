import 'package:muradezema/utils/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/dark_mode.dart';
import '../provider/notification_provider.dart';
import '../utils/nav_constants.dart';
import '../utils/user_prefs.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<NotificationProvider>(context, listen: false)
        .fetchNotifications(token: HivePrefs.getString('token'));
  }

  void _handleNotificationTap(BuildContext context, NotificationItem item) async {
    // Mark as read update
    Provider.of<NotificationProvider>(context, listen: false)
        .markAsRead(item.id);
    Dio dio = createDio();
    final response = await dio.get('${dotenv.env['BASE_URL']}/mynotification/${item.id}',
        options: Options(headers: {'Authorization': 'Bearer ${HivePrefs.getString('token')}'}));

    print('notification response read ${response.data}');

  
    // Navigate based on notification type
    switch (item.type) {
      case 'audiopaid':
        if (!item.isCategory) {
          Navigator.pushNamed(context, NavigationConstants.audioHome);
        } else {
          Navigator.pushNamed(
            context,
            NavigationConstants.allAudios,
            arguments: {
              'id': item.productId ?? '',
              'artistName': item.title,
              'artistImage': item.message
            },
          );        }
        break;
      case 'bookpaid':
        if (item.isCategory) {
          Navigator.pushNamed(context, NavigationConstants.bookHome);
        } else {
          Navigator.pushNamed(
            context,
            NavigationConstants.bookList,
            arguments: {
              'id': item.productId ?? '',
              'bookTitle': item.title,
              'bookImage': item.message
            },
          );        }
        break;
      case 'videopaid':
        if (item.isCategory) {
        Navigator.pushNamed(context, NavigationConstants.videoHome);
        } else {
          Navigator.pushNamed(
            context,
            NavigationConstants.allVideos,
            arguments: {
              'id': item.productId ?? '',
              'artistName': item.title,
              'artistImage': item.message
            },
          );
        }
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;
    Color backgroundColor = isDarkMode ? const Color(0xFF1C1C1E) : Colors.white;
    Color textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Notifications', style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return  Center(
                child: LoadingAnimationWidget.inkDrop(
                    color: Colors.orange, size: 30));
          }
          if (provider.error != null) {
            return Center(
              child: Text(
                provider.error!,
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
            );
          }
          if (provider.notifications.isEmpty) {
            return Center(
              child: Text(
                'No notifications yet.',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemCount: provider.notifications.length,
            itemBuilder: (context, index) {
              final item = provider.notifications[index];
              return GestureDetector(
                onTap: () => _handleNotificationTap(context, item),
                child: NotificationTile(item: item, isDarkMode: isDarkMode),
              );
            },
          );
        },
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final NotificationItem item;
  final bool isDarkMode;

  const NotificationTile({
    super.key,
    required this.item,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    String readableType;
    switch (item.type) {
      case 'audiopaid':
        icon = Icons.headphones;
        color = Colors.purpleAccent;
        readableType = 'Audio';
        break;
      case 'videopaid':
        icon = Icons.video_library;
        color = Colors.redAccent;
        readableType = 'Video';
        break;
      case 'bookpaid':
        icon = Icons.book;
        color = Colors.green;
        readableType = 'Book';
        break;
      default:
        icon = Icons.notifications;
        color = Colors.orangeAccent;
        readableType = 'General';
    }

    final bool isUnread = !item.isRead;

    return Card(
      elevation: isUnread ? 4 : 1,
      color: isUnread
          ? (isDarkMode ? Colors.deepPurple[900] : Colors.deepPurple[50])
          : (isDarkMode ? Colors.white10 : Colors.grey[100]),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isUnread ? BorderSide(color: color, width: 1.5) : BorderSide.none,
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color),
            ),
            if (isUnread)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: isDarkMode ? Colors.black : Colors.white,
                        width: 1),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          item.title,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.message,
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black54,
                fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time,
                    size: 14, color: color.withOpacity(0.7)),
                const SizedBox(width: 4),
                Text(
                  _formatTime(item.time),
                  style: TextStyle(
                    color: isDarkMode ? Colors.white54 : Colors.black38,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    readableType,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        // trailing: isUnread
        //     ? Icon(Icons.fiber_manual_record, color: color, size: 16)
        //     : null,
      ),
    );
  }

  String _formatTime(String isoTime) {
    // Try to parse and format as 'Aug 6, 08:34'
    try {
      final dt = DateTime.parse(isoTime);
      final now = DateTime.now();
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        // Today: show only time
        return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } else {
        // Show date and time
        return '${_monthShort(dt.month)} ${dt.day}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      return isoTime;
    }
  }

  String _monthShort(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month];
  }
}
