import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:the_movie_app/controllers/movie_cast_controller.dart';
import 'package:the_movie_app/controllers/movie_controller.dart';
import 'package:the_movie_app/controllers/movie_detail_controller.dart';
import 'package:the_movie_app/core/constants.dart';
import 'package:the_movie_app/models/movie_genre_model.dart';
import 'package:the_movie_app/utils/open_page.dart';
import 'package:the_movie_app/widgets/build_image_poster.dart';
import 'package:blur/blur.dart';
import 'package:the_movie_app/widgets/section_title.dart';

class MovieDetailPage extends StatefulWidget {
  final int movieId;

  const MovieDetailPage(this.movieId, {Key? key}) : super(key: key);

  @override
  _MovieDetailPageState createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  final _controllerDetail = MovieDetailController();
  final _controllerCast = MovieCastController();
  final _controllerSimilar = MovieController();

  @override
  void initState() {
    super.initState();
    _initializeDetail();
    _initializeCast();
    _initializeSimilar();
  }

  _initializeDetail() async {
    setState(() {
      _controllerDetail.loading = true;
    });

    await _controllerDetail.fetchMovieById(widget.movieId);

    setState(() {
      _controllerDetail.loading = false;
    });
  }

  _initializeCast() async {
    setState(() {
      _controllerCast.loading = true;
    });

    await _controllerCast.fetchCastMovieById(movieId: widget.movieId);

    setState(() {
      _controllerCast.loading = false;
    });
  }

  _initializeSimilar() async {
    setState(() {
      _controllerSimilar.loading = true;
    });

    await _controllerSimilar.fetchMovies(
        idMovie: widget.movieId, responseType: 1);

    setState(() {
      _controllerSimilar.loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBodyMovieDetail(),
    );
  }

  _buildBodyMovieDetail() {
    if (_controllerDetail.loading) {
      return Container(
        width: MediaQuery.of(context).size.width,
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    return Container(
      color: mainColor,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          _buildCover(),
          Center(
            child: ListView(
              physics: const ScrollPhysics(),
              children: [
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    _transitionShadow(),
                    _movieTitle(),
                  ],
                ),
                Container(
                  color: mainColor,
                  child: Column(
                    children: [
                      _buildOverview(),
                      _buildCast(),
                      const SizedBox(height: 10),
                      // _buildVideos(),
                      // const SizedBox(height: 10),
                      _buildSimilar(),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildVideos() {
    return Container();
  }

  _buildOverview() {
    String? movieOverview = _controllerDetail.movieDetail?.overview;
    return Container(
      color: mainColor,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [buildSectionTitle("Sinopse")],
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            movieOverview ?? 'Sinopse não fornecida.',
            textAlign: TextAlign.justify,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 13.0,
              letterSpacing: 0.2,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  _buildSimilar() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0, bottom: 10.0),
          child: Row(
            children: [
              buildSectionTitle("Similar"),
            ],
          ),
        ),
        SingleChildScrollView(
          child: SizedBox(
            height: 250,
            child: ListView.builder(
              padding: const EdgeInsets.all(5.0),
              itemCount: _controllerSimilar.moviesCount,
              itemBuilder: _builSimilarMovie,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
            ),
          ),
        )
      ],
    );
  }

  Widget _builSimilarMovie(_, index) {
    final similar = _controllerSimilar.movies[index];
    final similarPath = similar.posterPath;
    final urlPoster = '$urlPoster400$similarPath';
    final pathImage = similarPath == null ? urlAlternative : urlPoster;
    return GestureDetector(
      child: buildImagePoster(pathImage),
      onTap: () => openDetailPage(similar.id, context),
    );
  }

  _buildCast() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20.0, bottom: 10.0),
          child: Row(
            children: [buildSectionTitle("Elenco")],
          ),
        ),
        SingleChildScrollView(
          child: SizedBox(
            height: 160,
            child: ListView.builder(
              padding: const EdgeInsets.all(5.0),
              itemCount: _controllerCast.castCount,
              itemBuilder: _buildCastMovie,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCastMovie(_, index) {
    final cast = _controllerCast.cast[index];
    final castPath = cast.profilePath;
    final castName = cast.name;
    final castCharacter = cast.character;
    final urlPoster = '$urlPoster400$castPath';
    final pathImage = castPath == null ? urlAlternative : urlPoster;
    return GestureDetector(
        child: buildImage(pathImage, index, '$castName', '$castCharacter'),
        onTap: () => openPersonPage(cast.id, context));
  }

  Widget buildImage(
      String urlImage, int index, String castName, String character) {
    return Column(
      children: [
        Container(
          height: 80,
          width: 80,
          margin: const EdgeInsets.symmetric(horizontal: 7),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: CachedNetworkImage(
              placeholder: (context, url) => const SizedBox(
                width: 60,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
              imageUrl: urlImage,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          width: 80,
          child: Text(
            castName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.0,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 2,
            overflow: TextOverflow.clip,
            softWrap: true,
          ),
        ),
        const SizedBox(
          height: 2,
        ),
        SizedBox(
          width: 80,
          child: Text(
            character,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 10.0,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.clip,
            softWrap: true,
          ),
        )
      ],
    );
  }

  _buildCover() {
    String? posterPath = _controllerDetail.movieDetail?.backdropPath;
    return SizedBox(
      height: 420,
      child: CachedNetworkImage(
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
        fit: BoxFit.cover,
        imageUrl: '$urlPosterOriginal$posterPath',
      ),
    );
  }

  _movieTitle() {
    String? movieTitle = _controllerDetail.movieDetail?.title;
    int? movieYear = _controllerDetail.movieDetail?.releaseDate?.year;
    List<Genre>? movieGenre = _controllerDetail.movieDetail?.genres;
    int? movieRuntime = _controllerDetail.movieDetail?.runtime;
    double? movieRate = _controllerDetail.movieDetail?.voteAverage;
    String moviePoster = _controllerDetail.movieDetail?.posterPath ?? '';
    double posterWidth = 140;
    double posterHeight = 200;
    double titleWidth = MediaQuery.of(context).size.width - posterWidth - 40;

    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: posterWidth,
            child: buildImagePoster(
              '$urlPoster400$moviePoster',
              margin: 0,
              altura: posterHeight,
              larg: posterWidth,
              border: 8,
            ),
          ),
          Container(
            width: titleWidth,
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movieTitle ?? 'Sem Título',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '$movieYear',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12.0,
                      ),
                    ),
                    const Text(
                      ' • ',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      '$movieRuntime min',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '$movieRate',
                      style: const TextStyle(
                        color: Colors.yellow,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.yellow,
                      size: 18.0,
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  _transitionShadow() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            mainColor,
            Colors.transparent,
            Colors.transparent,
            mainColor
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          stops: [0.25, 1, 0, 0],
        ),
      ),
    );
  }
}
