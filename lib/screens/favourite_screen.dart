import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/favourite_bloc.dart';
import '../bloc/favourite_event.dart';
import '../bloc/favourite_state.dart';
import '../bloc/theme_cubit.dart';
import '../models/article.dart';
import 'article_detail_screen.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({Key? key}) : super(key: key);

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourite Articles'),
        actions: [
          // Light/Dark Mode toggle using ToggleButtons
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
        ],
      ),
      body: Column(
        children: [
          // Search field for filtering favourite articles
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search favourites',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (query) {
                setState(() {
                  searchQuery = query.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<FavouriteBloc, FavouriteState>(
              builder: (context, state) {
                if (state is FavouriteLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is FavouriteLoaded) {
                  final filteredFavourites = state.favourites.where((article) {
                    return article.title.toLowerCase().contains(searchQuery) ||
                        article.body.toLowerCase().contains(searchQuery);
                  }).toList();

                  if (filteredFavourites.isEmpty) {
                    return const Center(child: Text('No matching favourites'));
                  }

                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: filteredFavourites.length,
                    itemBuilder: (context, index) {
                      final Article article = filteredFavourites[index];
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            // Hero with a flight shuttle builder and a BlocBuilder to update theme changes
                            title: Hero(
                              tag: 'title-${article.id}',
                              flightShuttleBuilder: (
                                  BuildContext flightContext,
                                  Animation<double> animation,
                                  HeroFlightDirection flightDirection,
                                  BuildContext fromHeroContext,
                                  BuildContext toHeroContext,
                                  ) {
                                // Build using the destination context to pick up the updated theme.
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
                            // Favourite toggle button (assumed always favourited in Favourites screen)
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.favorite,
                                color: Colors.red,
                                size: 26,
                              ),
                              onPressed: () {
                                context
                                    .read<FavouriteBloc>()
                                    .add(ToggleFavourite(article));
                              },
                            ),
                            // Navigate to the article details with fade transition.
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) =>
                                      ArticleDetailScreen(article: article),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
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
                  );
                } else if (state is FavouriteError) {
                  return Center(
                    child: Text(
                      'Error: ${state.message}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}