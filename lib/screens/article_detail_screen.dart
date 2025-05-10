import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/article.dart';
import '../bloc/favourite_bloc.dart';
import '../bloc/favourite_event.dart';
import '../bloc/favourite_state.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Article Details'),
        actions: [
          BlocBuilder<FavouriteBloc, FavouriteState>(
            builder: (context, state) {
              bool isFavourite = false;
              if (state is FavouriteLoaded) {
                isFavourite = state.favourites.any((fav) => fav.id == article.id);
              }
              return IconButton(
                icon: Icon(
                  isFavourite ? Icons.favorite : Icons.favorite_border,
                  color: isFavourite ? Colors.red : null,
                  size: 28, // Slightly larger for accessibility
                ),
                onPressed: () {
                  context.read<FavouriteBloc>().add(ToggleFavourite(article));
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'title-${article.id}',
              child: Text(
                article.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12), // Space between title & body
            Text(
              article.body,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16, // Improved readability
              ),
            ),
          ],
        ),
      ),
    );
  }
}