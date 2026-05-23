import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'screens/home/home_screen.dart';
import 'screens/onboarding/onboarding_screen_2.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/lock/lock_screen.dart';
import 'services/notification_service.dart';
import 'services/scheduler_service.dart';
import 'services/billing_service.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'theme/design_system.dart';
import 'widgets/sajda_logo.dart';
import 'widgets/sajda_fade_page_route.dart';
import 'screens/lock/post_lock_screen.dart';
import 'services/platform_channel_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  tz.initializeTimeZones();
  final String timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
  
  await NotificationService().initialize();
  await BillingService().initialize();
  await AndroidAlarmManager.initialize();
  await SchedulerService().start();
  runApp(const SajdaApp());
}

class SajdaApp extends StatelessWidget {
  const SajdaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sajda',
      debugShowCheckedModeBanner: false,
      theme: SajdaTheme.light(),
      darkTheme: SajdaTheme.dark(),
      themeMode: ThemeMode.system,
      home: const InitialScreen(),
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/home':
            page = const HomeScreen();
            break;
          case '/settings':
            page = const SettingsScreen();
            break;
          case '/lock':
            page = const LockScreen();
            break;
          default:
            return null;
        }
        return SajdaFadePageRoute(child: page);
      },
    );
  }
}

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  void initState() {
    super.initState();
    _setupReflectionHandler();
    _checkOnboardingStatus();
  }

  void _setupReflectionHandler() {
    PlatformChannelService.setReflectionHandler((prayerName) async {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostLockScreen(prayerName: prayerName),
          ),
        );
      }
    });
  }

  Future<void> _checkOnboardingStatus() async {
    final initialIntent = await PlatformChannelService.getInitialIntent();
    if (initialIntent != null && initialIntent['show_reflection'] == true) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PostLockScreen(
              prayerName: initialIntent['prayer_name'],
            ),
          ),
        );
        return;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final hasCompletedOnboarding = prefs.getBool('onboarding_completed') ?? false;

    // Simulate splash duration
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      if (hasCompletedOnboarding) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacement(
          context,
          SajdaFadePageRoute(
            child: const OnboardingScreen2(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.bgPrimaryDark : AppColors.bgPrimaryLight,
      body: const Center(
        child: SajdaLogo(size: 80),
      ),
    );
  }
}
