import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:pokemon_app/models/page_data.dart';
import 'package:pokemon_app/models/pokemon.dart';
import 'package:pokemon_app/services/http_service.dart';

class HomePageController extends StateNotifier<HomePageData> {
  final GetIt _getIt = GetIt.instance;

  late HttpService _httpService;

  HomePageController(super._state) {
    _httpService = _getIt.get<HttpService>();
    _setup();
  }

  Future<void> _setup() async {
    loadData();
  }

  Future<void> loadData() async {
    if (state.data == null) {
      Response? res = await _httpService.get(
        "https://pokeapi.co/api/v2/pokemon?limit=20&offset=0",
      );
      if (res != null && res.data != null) {
        PokemonListData data = PokemonListData.fromJson(res.data);
        state = state.copyWith(data: data);
      }
      print(state.data?.results?.first);
    } else {
      if (state.data?.next != null) {
        Response? res = await _httpService.get(
          state.data!.next!,
        );

        if (res != null && res.data != null) {
          PokemonListData data = PokemonListData.fromJson(
            res.data!,
          );

          state = state.copyWith(
            // Update the data porperty with the new data that is set
            data: data.copyWith(
              results: [
                // Add the already loaded pokemons with the newly pokemons
                ...?state.data?.results,
                ...?data.results,
              ],
            ),
          );
        }
      }
    }
  }
}
