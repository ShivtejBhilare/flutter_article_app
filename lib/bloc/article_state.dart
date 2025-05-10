import '../models/article.dart';

abstract class ArticleState {}

class ArticleInitial extends ArticleState {}

class ArticleLoading extends ArticleState {}

class ArticleLoaded extends ArticleState {
  final List<Article> allArticles;
  final List<Article> filteredArticles;

  ArticleLoaded({
    required this.allArticles,
    required this.filteredArticles,
  });
}

class ArticleError extends ArticleState {
  final String message;
  ArticleError(this.message);
}