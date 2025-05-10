import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/favourite_bloc.dart';
import '../bloc/favourite_event.dart';
import '../bloc/favourite_state.dart';
import '../bloc/theme_cubit.dart';
import '../models/article.dart';
import 'article_detail_screen.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

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
          // Light/Dark Mode Toggle Button
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
          // Search Field for Favorites
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
                    itemCount: filteredFavourites.length,
                    itemBuilder: (context, index) {
                      Article article = filteredFavourites[index];
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Hero(
                              tag: 'title-${article.id}',
                              child: Text(
                                article.title,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Text(
                                article.body.length > 50
                                    ? '${article.body.substring(0, 50)}...'
                                    : article.body,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
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
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) => ArticleDetailScreen(article: article),
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
                  );
                } else if (state is FavouriteError) {
                  return Center(child: Text('Error: ${state.message}'));
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