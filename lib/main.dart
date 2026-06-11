import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:muradezema/provider/audio_category.dart';
import 'package:muradezema/provider/book.dart';
import 'package:muradezema/provider/book_season.dart';
import 'package:muradezema/provider/episode_provider.dart';
import 'package:muradezema/provider/favorite_provider.dart';
import 'package:muradezema/provider/profile_provider.dart';
import 'package:muradezema/provider/related_audio_provider.dart';
import 'package:muradezema/provider/related_video_provider.dart';
import 'package:muradezema/provider/search_provider.dart';
import 'package:muradezema/provider/search_purchased.dart';
import 'package:muradezema/provider/top_selling_provider.dart';
import 'package:muradezema/provider/vide_id_provider.dart';
import 'package:muradezema/provider/video_category.dart';
import 'package:muradezema/provider/video_category_detail.dart';
import 'package:muradezema/provider/video_provider.dart';
import 'package:muradezema/repositiory/season_repository.dart';
import 'package:muradezema/screens/audio/player_task.dart';
import 'package:muradezema/screens/audio_list.dart';
import 'package:muradezema/screens/book_list.dart';
import 'package:muradezema/screens/books_home.dart';
import 'package:muradezema/screens/favorite_screen.dart';
import 'package:muradezema/screens/forget_password.dart';
import 'package:muradezema/screens/peinding_payments.dart';
import 'package:muradezema/screens/search_purchased.dart';
import 'package:muradezema/screens/search_screen.dart';
import 'package:muradezema/screens/splash_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muradezema/screens/video_home.dart';
import 'package:provider/provider.dart';
import 'package:muradezema/utils/hive_adapters.dart';
// import 'package:muradezema/services/location_service.dart';

import 'commons/mini_audio_player.dart';
import 'provider/album_provider.dart';
import 'provider/audio_manager.dart';
import 'provider/bank_provider.dart';
import 'provider/book_list_provider.dart';
import 'provider/dark_mode.dart';
import 'provider/notification_provider.dart';
import 'provider/podcast_provider.dart';
import 'provider/purchase_provider.dart';
import 'provider/saeson_provider.dart';
import 'repositiory/podcast_repository.dart';
import 'screens/audio_home.dart';
import 'screens/audio_player_screen.dart';
import 'screens/book_reader_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/video_list_screen.dart';
import 'screens/video_player_screen.dart';
import 'screens/login_screen.dart';
import 'screens/purchased_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/welcome_screen.dart';
import 'utils/nav_constants.dart';
import 'utils/user_prefs.dart';
import 'package:muradezema/services/iap_service.dart';
import 'utils/developer_mode.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:receive_intent/receive_intent.dart';
import 'screens/verify_screen.dart';
import 'screens/top_selling_list.dart';
import 'screens/reset_password.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:geolocator/geolocator.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

late AudioHandler audioHandler;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  IAPService.instance.initialize();
  print('Initializing app...');

  audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.ryanheise.myapp.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      androidNotificationClickStartsActivity: true,
    ),
  );

  print('Initializing Hive...');
  await Hive.initFlutter();
  HiveAdapters.registerAdapters();
  await HivePrefs.init();
  await dotenv.load();

  // Initialize flutter_local_notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      navigatorKey.currentState?.pushNamed(NavigationConstants.notifications);
    },
  );

  // Initialize Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCVV0GG3rvcetm4gadebg_5juTbytqkHpI",
      appId: "1:506650546784:android:258f068e2051d03a792905",
      messagingSenderId: "506650546784",
      projectId: "biloap",
      databaseURL: "https://biloap-default-rtdb.firebaseio.com",
      storageBucket: "biloap.firebasestorage.app",
    ),
  );
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission();
  String? token = await messaging.getToken();
  print("FCM Token: $token");

  // Show notification in foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print('Received a message while in the foreground!');
    print('Message data:  [36m${message.data} [0m');
    if (message.notification != null) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        await flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              channelDescription:
                  'This channel is used for important notifications.',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
          payload: 'notification',
        );
      }
    }
  });

  // Handle notification tap when app is in background/terminated
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    navigatorKey.currentState?.pushNamed(NavigationConstants.notifications);
  });

  print('Starting app...');
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool _dialogShown = false;
    final RouteObserver<PageRoute> _routeObserver = RouteObserver<PageRoute>();
  late final _RouteListener _routeListener; // ✅ Keep reference

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _routeListener = _RouteListener(_checkDevOptions); 
    checkIntentAndNavigate();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _routeObserver.subscribe(
        _routeListener,
        ModalRoute.of(context)! as PageRoute, 
      );

      _checkDevOptions();
    });
  }


  Future<void> _checkDevOptions() async {
    if (_dialogShown) return;

    final isDev = await DeveloperModeChecker.isDeveloperOptionsEnabled();
    final isAdb = await DeveloperModeChecker.isUsbDebuggingEnabled();

    if (isDev || isAdb) {
      if (!mounted) return;
      _dialogShown = true;

      showDialog(
        context: context,
        // barrierDismissible: false,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.deepOrange, size: 64),
                const SizedBox(height: 18),
                Text(
                  'Developer Mode Detected',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Please disable Developer options and USB debugging to continue using the app.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    icon: Icon(Icons.settings),
                    label: Text(
                      'Open Settings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      _dialogShown = false; // reset so it can re-check later
                      await DeveloperModeChecker.openDeveloperOptions();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  void checkIntentAndNavigate() async {
    final intent = await ReceiveIntent.getInitialIntent();
    if (intent != null) {
      final mediaItem = AudioService.currentMediaItem;
      if (mediaItem != null) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => MainScreen(
              isFromNotification: true,
              id: mediaItem.id,
              title: mediaItem.title,
              album: mediaItem.album ?? '',
              artist: mediaItem.artist ?? '',
              artUri: mediaItem.artUri ?? Uri(),
              duration: mediaItem.duration ?? Duration(milliseconds: 4),
              description: mediaItem.displayDescription ??
                  HivePrefs.getString('description') ??
                  '',
            ),
          ),
        );
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkDevOptions();
    }
  }

   @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _routeObserver.unsubscribe(_routeListener); // ✅ same instance
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            Provider<PodcastRepository>(create: (_) => PodcastRepository()),
            ChangeNotifierProvider(create: (context) => EpisodesProvider()),
            ChangeNotifierProvider(create: (_) => BankProvider()),
            ChangeNotifierProvider(create: (_) => ReaderSettings()),
            ChangeNotifierProvider(create: (_) => DarkModeProvider()),
            ChangeNotifierProvider(create: (_) => SeasonEpisodeProvider()),
            Provider<SeasonRepository>(create: (_) => SeasonRepository()),
            ChangeNotifierProvider(
              create: (context) => SeasonProvider(
                Provider.of<SeasonRepository>(context, listen: false),
              ),
            ),
            ChangeNotifierProvider(create: (_) => AudioManager()),
            ChangeNotifierProvider(create: (_) => VideoProvider()),
            ChangeNotifierProvider(create: (_) => VideoIdProvider()),
            ChangeNotifierProvider(create: (_) => RelatedAudioProvider()),
            ChangeNotifierProvider(create: (_) => RelatedVideoProvider()),
            ChangeNotifierProvider(create: (_) => AudioCategoryProvider()),
            ChangeNotifierProvider(create: (_) => AlbumProvider()),
            ChangeNotifierProvider(create: (_) => BookSeasonProvider()),
            ChangeNotifierProvider(
                create: (_) => VideoCategoryDetailProvider()),
            ChangeNotifierProvider<VideoCategoryProvider>(
              create: (context) => VideoCategoryProvider(),
            ),
            ChangeNotifierProvider(create: (_) => BookProvider()),
            ChangeNotifierProvider(create: (_) => BookListProvider()),
            ChangeNotifierProvider(create: (_) => ProfileProvider()),
            ChangeNotifierProvider(create: (_) => TopSellingProvider()),
            ChangeNotifierProvider(create: (_) => SearchProvider()),
            ChangeNotifierProvider(create: (_) => PurchaseProvider()),
            ChangeNotifierProvider(create: (_) => SearchPurchasesProvider()),
            ChangeNotifierProvider(create: (_) => FavoriteProvider()),
            ChangeNotifierProvider(create: (_) => NotificationProvider()),
          ],
          child: Consumer<DarkModeProvider>(
            builder: (context, darkModeProvider, child) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                navigatorKey: navigatorKey,
                 navigatorObservers: [_routeObserver],

                initialRoute: NavigationConstants.splashScreen,
                routes: {
                  NavigationConstants.splashScreen: (context) =>
                      const SplashScreen(),
                  NavigationConstants.welcomePage: (context) =>
                      const WelcomePage(),
                  NavigationConstants.loginPage: (context) =>
                      const LoginScreen(),
                  NavigationConstants.registerPage: (context) =>
                      const RegisterScreen(),
                  NavigationConstants.audioHome: (context) =>
                      const AudioHomeScreen(),
                  NavigationConstants.videoHome: (context) =>
                      const VideoHomeScreen(),
                  NavigationConstants.bookHome: (context) =>
                      const BookHomeScreen(),
                  NavigationConstants.purchased: (context) =>
                      const PurchasedFilesPage(),
                  NavigationConstants.audioPlayer: (context) =>
                      const AudioPlayerScreen(),
                  NavigationConstants.videoPlayer: (context) =>
                      const VideoPlayerScreen(),
                  NavigationConstants.bookReader: (context) =>
                      const BookReaderScreen(),
                  NavigationConstants.forgetPassword: (context) =>
                      const ForgetPasswordScreen(),
                  NavigationConstants.allAudios: (context) =>
                      ArtistAudioListScreen(),
                  NavigationConstants.notifications: (context) =>
                      const NotificationScreen(),
                  NavigationConstants.allVideos: (context) =>
                      const RelatedEpisodesScreen(),
                  NavigationConstants.bookList: (context) =>
                      const BookListScreen(),
                  NavigationConstants.profile: (context) =>
                      const ProfileScreen(),
                  NavigationConstants.search: (context) => const SearchScreen(),
                  NavigationConstants.verify: (context) => VerifyScreen(),
                  NavigationConstants.topSellingList: (context) =>
                      TopSellingListScreen(),
                  NavigationConstants.resetPassword: (context) =>
                      ResetPasswordScreen(),
                  NavigationConstants.favoriteScreen: (context) =>
                      FavoriteScreen(),
                  NavigationConstants.searchPurchased: (context) =>
                      SearchPurchasedScreen(),
                  NavigationConstants.pendingPayments: (context) =>
                      PendingPaymentsScreen(),
                },
                theme: ThemeData(
                  primaryColor: darkModeProvider.primaryColor,
                  scaffoldBackgroundColor: darkModeProvider.backgroundColor,
                  textTheme: TextTheme(
                    bodyLarge: TextStyle(color: darkModeProvider.textColor),
                  ),
                  iconTheme: IconThemeData(color: darkModeProvider.iconColor),
                  appBarTheme: AppBarTheme(
                    backgroundColor: darkModeProvider.primaryColor,
                    iconTheme: IconThemeData(color: darkModeProvider.iconColor),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _RouteListener extends RouteAware {
  final VoidCallback onResume;

  _RouteListener(this.onResume);

  @override
  void didPopNext() {
    onResume(); // Called when returning to this route
  }

  @override
  void didPush() {}

  @override
  void didPop() {}

  @override
  void didPushNext() {}
}



class MiniPlayerOverlay extends StatelessWidget {
  const MiniPlayerOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Consumer<AudioManager>(
        builder: (context, audioManager, child) {
          if (audioManager.currentAudioTitle == null) {
            return const SizedBox.shrink();
          }
          return const MiniPlayer();
        },
      ),
    );
  }
}
