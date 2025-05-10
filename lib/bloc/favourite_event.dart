import 'package:equatable/equatable.dart';
import '../models/article.dart';

abstract class FavouriteEvent extends Equatable {
  const FavouriteEvent();
  @override
  List<Object> get props => [];
}

class LoadFavourites extends FavouriteEvent {}

class ToggleFavourite extends FavouriteEvent {
  final Article article;
  const ToggleFavourite(this.article);

  @override
  List<Object> get props => [article];
}