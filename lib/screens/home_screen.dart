import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import '../bloc/article_bloc.dart';
import '../bloc/article_event.dart';
import '../bloc/article_state.dart';
import '../bloc/favourite_bloc.dart';
import '../bloc/favourite_event.dart';
import '../bloc/favourite_state.dart';
import '../bloc/theme_cubit.dart';
import '../models/article.dart';
import 'article_detail_screen.dart';
import 'favourite_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Articles'),
        actions: [
          // Light/Dark Mode Toggle Button using ToggleButtons
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: ToggleButtons(
                  isSelected: [
                    themeMode == ThemeMode.light,
                    themeMode == ThemeMode.dark,
                  ],
                  onPressed: (index) {
                    if (index == 0) {
                      context.read<ThemeCubit>().setTheme(ThemeMode.light);
                    } else {
                      context.read<ThemeCubit>().setTheme(ThemeMode.dark);
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  constraints: const BoxConstraints(minWidth: 50),
                  children: const [
                    Icon(Icons.light_mode),
                    Icon(Icons.dark_mode),
                  ],
                ),
              );
            },
          ),
          // Navigate to Favourite Articles Screen
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavouriteScreen()),
              );
            },
          ),
        ],
      ),
      body: GestureDetector(
        // Remove focus when tapping anywhere.
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Column(
          children: [
            // Search Field for Articles
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search articles',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (query) {
                  context.read<ArticleBloc>().add(SearchArticles(query));
                },
              ),
            ),
            // Expanded widget for the list of articles (or error state)
            Expanded(
              child: BlocBuilder<ArticleBloc, ArticleState>(
                builder: (context, state) {
                  if (state is ArticleInitial) {
                    context.read<ArticleBloc>().add(FetchArticles());
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ArticleLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ArticleLoaded) {
                    return LiquidPullToRefresh(
                      onRefresh: () async {
                        context.read<ArticleBloc>().add(FetchArticles());
                        return Future.delayed(const Duration(milliseconds: 500));
                      },
                      color: Colors.blueAccent, // Customize as needed.
                      backgroundColor: Colors.white,
                      height: 100,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: state.filteredArticles.length,
                        itemBuilder: (context, index) {
                          final Article article = state.filteredArticles[index];
                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                // Hero widget with a flight shuttle builder and a BlocBuilder for theme changes.
                                title: Hero(
                                  tag: 'title-${article.id}',
                                  flightShuttleBuilder: (
                                      BuildContext flightContext,
                                      Animation<double> animation,
                                      HeroFlightDirection flightDirection,
                                      BuildContext fromHeroContext,
                                      BuildContext toHeroContext,
                                      ) {
                                    // Build using the destination's context to pick up the updated theme.
                                    return Text(
                                      article.title,
                                      style: Theme.of(toHeroContext)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(fontWeight: FontWeight.bold),
                                    );
                                  },
                                  child: BlocBuilder<ThemeCubit, ThemeMode>(
                                    builder: (context, themeMode) {
                                      // Using the current theme data for the Text widget.
                                      return Text(
                                        article.title,
                                        // The value of themeMode is used as key to force rebuild.
                                        key: ValueKey(themeMode),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                // Article subtitle showing a truncated article body.
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Text(
                                    article.body.length > 50
                                        ? '${article.body.substring(0, 50)}...'
                                        : article.body,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.grey.shade600),
                                  ),
                                ),
                                // Toggle favourite using FavouriteBloc.
                                trailing: BlocBuilder<FavouriteBloc, FavouriteState>(
                                  builder: (context, favState) {
                                    bool isFavourite = favState is FavouriteLoaded &&
                                        favState.favourites.any((fav) => fav.id == article.id);
                                    return IconButton(
                                      icon: Icon(
                                        isFavourite ? Icons.favorite : Icons.favorite_border,
                                        color: isFavourite ? Colors.red : Colors.grey,
                                        size: 26,
                                      ),
                                      onPressed: () {
                                        context.read<FavouriteBloc>().add(ToggleFavourite(article));
                                      },
                                    );
                                  },
                                ),
                                // Navigate to ArticleDetailScreen using a fade transition.
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (_, __, ___) =>
                                          ArticleDetailScreen(article: article),
                                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                        return FadeTransition(opacity: animation, child: child);
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  } else if (state is ArticleError) {
                    // Show error state with pull-to-refresh enabled.
                    return LiquidPullToRefresh(
                      onRefresh: () async {
                        context.read<ArticleBloc>().add(FetchArticles());
                        return Future.delayed(const Duration(milliseconds: 500));
                      },
                      color: Colors.blueAccent,
                      backgroundColor: Colors.white,
                      height: 100,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.8,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Error loading articles.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const Center(child: Text('No articles available'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}