import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:pokemon_app/models/pokemon.dart';
import 'package:pokemon_app/services/database_service.dart';
import 'package:pokemon_app/services/http_service.dart';

final pokemonDataProvider =
    FutureProvider.family<Pokemon?, String>((ref, url) async {
  HttpService _httpService = GetIt.instance.get<HttpService>();
  Response? res = await _httpService.get(
    url,
  );

  if (res != null && res.data != null) {
    return Pokemon.fromJson(
      res.data!,
    );
  }
  return null;
});

final favoritePokemonsProvider =
    StateNotifierProvider<FavoritePokemonsProvider, List<String>>(
  (ref) {
    return FavoritePokemonsProvider(
      [],
    );
  },
);

// Favorite pokemon provider class
class FavoritePokemonsProvider extends StateNotifier<List<String>> {
  final DatabaseService _databaseService =
      GetIt.instance.get<DatabaseService>();

  String FAVORITE_POKEMON_LIST_KEY = "FAVORITE_POKEMON_LIST_KEY";

  FavoritePokemonsProvider(super._state) {
    _setup();
  }

  Future<void> _setup() async {
    List<String>? result = await _databaseService.getList(
      FAVORITE_POKEMON_LIST_KEY,
    );

    state = result ?? [];
  }

  void addFavoritePokemon(String url) {
    state = [...state, url];
    _databaseService.saveList(FAVORITE_POKEMON_LIST_KEY, state);
  }

  void removeFavoritePokemon(String url) {
    state = state.where((e) => e != url).toList();
    _databaseService.saveList(FAVORITE_POKEMON_LIST_KEY, state);
  }
}
