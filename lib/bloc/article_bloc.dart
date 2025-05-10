import 'package:bloc/bloc.dart';
import 'article_event.dart';
import 'article_state.dart';
import '../repositories/article_repository.dart';

class ArticleBloc extends Bloc<ArticleEvent, ArticleState> {
  final ArticleRepository articleRepository;

  ArticleBloc({required this.articleRepository}) : super(ArticleInitial()) {
    on<FetchArticles>(_onFetchArticles);
    on<SearchArticles>(_onSearchArticles);
  }

  Future<void> _onFetchArticles(
      FetchArticles event, Emitter<ArticleState> emit) async {
    emit(ArticleLoading());
    try {
      final articles = await articleRepository.fetchArticles();
      emit(ArticleLoaded(allArticles: articles, filteredArticles: articles));
    } catch (e) {
      emit(ArticleError(e.toString()));
    }
  }

  void _onSearchArticles(
      SearchArticles event, Emitter<ArticleState> emit) {
    final currentState = state;
    if (currentState is ArticleLoaded) {
      final query = event.query;
      if (query.isEmpty) {
        emit(ArticleLoaded(
          allArticles: currentState.allArticles,
          filteredArticles: currentState.allArticles,
        ));
      } else {
        final filtered = currentState.allArticles.where((article) =>
        article.title.toLowerCase().contains(query.toLowerCase()) ||
            article.body.toLowerCase().contains(query.toLowerCase())).toList();
        emit(ArticleLoaded(
          allArticles: currentState.allArticles,
          filteredArticles: filtered,
        ));
      }
    }
  }
}