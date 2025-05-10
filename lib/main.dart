import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bloc/favourite_event.dart';
import 'bloc/theme_cubit.dart';
import 'bloc/article_bloc.dart';
import 'bloc/favourite_bloc.dart';
import 'repositories/article_repository.dart';
import 'models/article.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  // Register adapters if necessary:
  Hive.registerAdapter(ArticleAdapter());

  // Open the box that FavouriteBloc needs.
  await Hive.openBox<Article>('favouriteArticles');

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (_) => ThemeCubit(),
        ),
        BlocProvider<ArticleBloc>(
          create: (_) =>
              ArticleBloc(articleRepository: ArticleRepository()),
        ),
        BlocProvider<FavouriteBloc>(
          create: (_) => FavouriteBloc()..add(LoadFavourites()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure the BuildContext under MaterialApp has access to all provided blocs.
    return Builder(
      builder: (context) {
        return BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp(
              title: 'My Article App',
              debugShowCheckedModeBanner: false,
              theme: ThemeData.light(),
              darkTheme: ThemeData.dark(),
              themeMode: themeMode,
              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}