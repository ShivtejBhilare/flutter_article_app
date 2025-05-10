import 'package:equatable/equatable.dart';

abstract class ArticleEvent extends Equatable {
  const ArticleEvent();
  @override
  List<Object> get props => [];
}

class FetchArticles extends ArticleEvent {}

class SearchArticles extends ArticleEvent {
  final String query;
  const SearchArticles(this.query);

  @override
  List<Object> get props => [query];
}