import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../firebase_options.dart';
import '../storage/app_pref.dart';
import 'network_info.dart';

final instance = GetIt.instance;

Future<void> initAppModule() async {


  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  instance.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  instance.registerLazySingleton<AppPreferences>(() => AppPreferences(instance<SharedPreferences>()));


  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

}
