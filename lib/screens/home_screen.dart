import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:lottie/lottie.dart';
import '../bloc/article_bloc.dart';
import '../bloc/article_event.dart';
import '../bloc/article_state.dart';
import '../bloc/favourite_bloc.dart';
import '../bloc/favourite_event.dart';
import '../bloc/favourite_state.dart';
import '../bloc/theme_cubit.dart';
import '../company_colors.dart'; // Import your logo-based color palette
import '../models/article.dart';
import 'article_detail_screen.dart';
import 'favourite_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Articles',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          // Light/Dark Mode Toggle using ToggleButtons
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
        // Remove focus from text input when tapping anywhere.
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
            // List (or error/loading state) for Articles:
            Expanded(
              child: BlocBuilder<ArticleBloc, ArticleState>(
                builder: (context, state) {
                  if (state is ArticleInitial || state is ArticleLoading) {
                    if (state is ArticleInitial) {
                      context.read<ArticleBloc>().add(FetchArticles());
                    }
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(CompanyColors.primary),
                        strokeWidth: 3.0,
                      ),
                    );
                  } else if (state is ArticleLoaded) {
                    return LiquidPullToRefresh(
                      onRefresh: () async {
                        context.read<ArticleBloc>().add(FetchArticles());
                        return Future.delayed(const Duration(milliseconds: 500));
                      },
                      // Use logo colors for the refresh indicator.
                      color: CompanyColors.primary, // Golden yellow refresh indicator.
                      backgroundColor: CompanyColors.background, // White background.
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
                                // Hero widget for article title with flight shuttle builder.
                                title: Hero(
                                  tag: 'title-${article.id}',
                                  flightShuttleBuilder: (
                                      BuildContext flightContext,
                                      Animation<double> animation,
                                      HeroFlightDirection flightDirection,
                                      BuildContext fromHeroContext,
                                      BuildContext toHeroContext,
                                      ) {
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
                                      return Text(
                                        article.title,
                                        key: ValueKey(themeMode),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(fontWeight: FontWeight.bold),
                                      );
                                    },
                                  ),
                                ),
                                // Display a truncated version of the article body.
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
                                // Favourite toggle button (kept unchanged, red for favourited).
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
                                // Navigate to ArticleDetailScreen with a fade transition.
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (_, __, ___) =>
                                          ArticleDetailScreen(article: article),
                                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        );
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
                    // In the error state, show a Lottie animation along with text.
                    return LiquidPullToRefresh(
                      onRefresh: () async {
                        context.read<ArticleBloc>().add(FetchArticles());
                        return Future.delayed(const Duration(milliseconds: 500));
                      },
                      color: CompanyColors.secondary,
                      backgroundColor: CompanyColors.background,
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
                                  // Lottie animation for network error.
                                  Lottie.asset(
                                    'assets/lottie/network_error.json',
                                    width: 200,
                                    repeat: true,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Error loading articles.\nPlease check your connection.',
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
                  return Center(child: Text('No articles available'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}