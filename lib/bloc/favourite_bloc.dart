import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';
import 'favourite_event.dart';
import 'favourite_state.dart';
import '../models/article.dart';

class FavouriteBloc extends Bloc<FavouriteEvent, FavouriteState> {
  // Open the Hive box that stores Article objects.
  final Box<Article> favouritesBox = Hive.box<Article>('favouriteArticles');

  FavouriteBloc() : super(FavouriteInitial()) {
    on<LoadFavourites>(_onLoadFavourites);
    on<ToggleFavourite>(_onToggleFavourite);
  }

  Future<void> _onLoadFavourites(
      LoadFavourites event, Emitter<FavouriteState> emit) async {
    emit(FavouriteLoading());
    try {
      final favourites = favouritesBox.values.toList();
      emit(FavouriteLoaded(favourites));
    } catch (e) {
      emit(FavouriteError(e.toString()));
    }
  }

  Future<void> _onToggleFavourite(
      ToggleFavourite event, Emitter<FavouriteState> emit) async {
    try {
      final article = event.article;
      // Use the article ID as a unique key.
      if (favouritesBox.containsKey(article.id)) {
        await favouritesBox.delete(article.id);
      } else {
        await favouritesBox.put(article.id, article);
      }
      final favourites = favouritesBox.values.toList();
      emit(FavouriteLoaded(favourites));
    } catch (e) {
      emit(FavouriteError(e.toString()));
    }
  }
}