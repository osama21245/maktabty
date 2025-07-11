import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mktabte/core/comman/app_user/app_user_state.dart';
import 'package:mktabte/features/auth/presentation/screens/onboarding.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/comman/app_user/app_user_riverpod.dart';
import 'core/utils/custom_error_screen.dart';

import 'features/auth/presentation/screens/login.dart';

import 'features/home/presentation/widgets/mainbar.dart';
// add
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PaintingBinding.instance.imageCache.maximumSize = 1000;

  await Supabase.initialize(
    url: 'https://gwzvpnetxlpqpjsemttw.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd3enZwbmV0eGxwcXBqc2VtdHR3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzE1NDMyNDMsImV4cCI6MjA0NzExOTI0M30.M_gXPVEvhH0z69l1VxMt7VwuybOZqQ2gAAnHC1ZMBn0',
  );

  await ScreenUtil.ensureScreenSize();

  customErorrScreen();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);

  runApp(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return const ProviderScope(child: MyApp());
      },
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(appUserRiverpodProvider.notifier).isFirstInstallation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appUserRiverpodProvider);
    final appUserRiverpod = ref.read(appUserRiverpodProvider.notifier);
    // Add listener for debugging
    ref.listen(appUserRiverpodProvider, (previous, next) {
      print('AppUserState changed from ${previous?.state} to ${next.state}');
      if (next.user != null) {
        print('User: ${next.user!.email}');
      }
      if (next.isInstalled()) {
        appUserRiverpod.isUserLoggedIn();
      }
    });

    return ScreenUtilInit(
      designSize: const Size(390, 849),
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 0,
            ),
            useMaterial3: true,
          ),
          home: state.isLoading()
              ? const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : state.isNotInstalled()
                  ? const Onboard()
                  : state.isGettedDataFromLocalStorage() ||
                          state.isUpdateUserData()
                      ? const MainBar()
                      : const LoginPage(),
        );
      },
    );
  }
}
