import 'package:http/http.dart' as http;
import 'package:peliculas/src/models/actores_model.dart';
import 'package:peliculas/src/models/pelicula_model.dart';
import 'dart:convert';
import 'dart:async';

class PeliculasProvider {
  String _apiKey = 'beb8e921242cec9926f3f515dcbf4a61';
  String _url = 'api.themoviedb.org';
  String _lenguage = 'es-ES';

  int _popularesPage = 0;
  bool _cargando = false;

  List<Pelicula> _populares = new List();
  final _popularesStreamController =
      StreamController<List<Pelicula>>.broadcast();

  Function(List<Pelicula>) get popularesSink =>
      _popularesStreamController.sink.add;
  Stream<List<Pelicula>> get popularesStream =>
      _popularesStreamController.stream;

  void disposeStream() {
    _popularesStreamController?.close();
  }

  Future<List<Pelicula>> _procesarRespuesta(Uri url) async {
    final resp = await http.get(url);
    final decodedData = json.decode(resp.body);

    final peliculas = Peliculas.fromJsonList(decodedData['results']);
    return peliculas.items;
  }

  Future<List<Pelicula>> getEnCines() async {
    final url = Uri.https(
      _url,
      '3/movie/now_playing',
      {'api_key': _apiKey, 'language': _lenguage},
    );

    return await _procesarRespuesta(url);
  }

  Future<List<Pelicula>> getPopulares() async {
    if (_cargando) return [];

    _cargando = true;

    _popularesPage++;

    final url = Uri.https(
      _url,
      '3/movie/popular',
      {
        'api_key': _apiKey,
        'language': _lenguage,
        'page': _popularesPage.toString(),
      },
    );

    final resp = await _procesarRespuesta(url);

    _populares.addAll(resp);
    popularesSink(_populares);

    _cargando = false;
    return resp;
  }

  Future<List<Actor>> getCast(String id) async {
    final url = Uri.https(
      _url,
      '3/movie/$id/credits',
      {
        'api_key': _apiKey,
        'language': _lenguage,
      },
    );

    final resp = await http.get(url);
    final decodedData = json.decode(resp.body);
    final cast = new Cast.fromJsonList(decodedData['cast']);
    return cast.actores;
  }

  Future<List<Pelicula>> buscarPelicula(String query) async {
    final url = Uri.https(
      _url,
      '3/search/movie',
      {
        'api_key': _apiKey,
        'language': _lenguage,
        'query': query,
      },
    );

    return await _procesarRespuesta(url);
  }
}
