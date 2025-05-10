import 'package:equatable/equatable.dart';
import '../models/article.dart';

abstract class FavouriteState extends Equatable {
  @override
  List<Object> get props => [];
}

class FavouriteInitial extends FavouriteState {}

class FavouriteLoading extends FavouriteState {}

class FavouriteLoaded extends FavouriteState {
  final List<Article> favourites;

  FavouriteLoaded(this.favourites);

  @override
  List<Object> get props => [favourites];
}

class FavouriteError extends FavouriteState {
  final String message;

  FavouriteError(this.message);

  @override
  List<Object> get props => [message];
}