import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:like_button/like_button.dart';
import 'package:readmore/readmore.dart';

import '../../../Auth/Presentation/Cubit/authCubit.dart';
import '../../../Auth/Presentation/Cubit/auth_States.dart';
import '../../../Auth/Presentation/Screen/auth.dart';
import '../../../Components/DialogLogin.dart';
import '../../../Components/ErrorScreen.dart';
import '../../../Favorite/Presentation/Cubit/favoriteCubit.dart';
import '../../../MovieOfCategory/Domain/Entities/MovieOfCategories.dart';
import '../../../WatchMovie/Presentation/watchmovie.dart';
import '../../Domain/Entities/movie.dart';
import '../../Domain/Entities/newCategories.dart';
import '../Cubit/movieInfoCubit.dart';
import '../Cubit/movieInfoState.dart';

class Movieinfoscreen extends StatefulWidget {
  String idMovie;
  String slugMovie;
  final String? previousSlugMovie;

  Movieinfoscreen(
      {super.key,
      required this.slugMovie,
      this.previousSlugMovie,
      required this.idMovie});

  @override
  State<Movieinfoscreen> createState() => _MovieinfoscreenState();
}

class _MovieinfoscreenState extends State<Movieinfoscreen> {
  int currentEpisode = 1;
  bool isAuthen = false;
  String uid = '';
  bool isFavorite = false;

  void tapToWatch(String movieUrl, String nameEpisode, String posterUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (c) => Watchmovie(
          movieUrl: movieUrl,
          nameEpisode: nameEpisode,
          posterUrl: posterUrl,
          uid: uid,
          slug: widget.slugMovie,
          idMovie: widget.idMovie,
        ),
      ),
    );
  }

  void showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialoglogin(onLoginTap: tapToLogin),
    );
  }

  void tapToLogin() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (c) => const authScreen(isLoginError: false)),
    );
  }

  void selectEpisode(
      int index, String urlMovie, String nameEpisode, String posterUrl) {
    setState(() {
      currentEpisode = index + 1;
    });
    tapToWatch(urlMovie, nameEpisode, posterUrl);
  }

  void tapAnotherMovie(String slugMovie, String id) async {
    final resultSlug = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (c) => Movieinfoscreen(
          idMovie: id,
          slugMovie: slugMovie,
          previousSlugMovie: widget.slugMovie,
        ),
      ),
    );

    if (!mounted) return;
    if (resultSlug != null) {
      context.read<MovieinfoCubit>().getMovieInfo(resultSlug);
    }
  }

  void popToHome() {
    Navigator.pop(context, widget.previousSlugMovie);
  }

  String parseTime(String time) {
    final dateTime = DateTime.parse(time);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String genre(List<Newcategories> categories) {
    return categories.map((e) => e.name).join(', ');
  }

  Future<bool> onLikeButtonTapped(
      bool isLiked, movie favoriteMovie, String uid) async {
    if (!isLiked) {
      await context.read<MovieinfoCubit>().setFavoriteMovie(favoriteMovie, uid);
      await context.read<Favoritecubit>().getFavoriteMovie(uid);
    } else {
      await context.read<Favoritecubit>().deleteMovie(uid, widget.idMovie);
    }
    return !isLiked;
  }

  Future<bool> onUnLikeButtonTapped(bool isLiked) async {
    showLoginDialog();
    return isLiked;
  }

  bool checkFavorite() {
    final data = context.read<Favoritecubit>().listFavotite;
    if (data != null) {
      final listMovieOfFavorite = data.ListFavoriteMovie;
      return listMovieOfFavorite.any((e) => e.id == widget.idMovie);
    }
    return false;
  }

  void onTapTrailler() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Trailer chưa được cập nhật ',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<MovieinfoCubit>().getMovieInfo(widget.slugMovie);

    final currentAuthState = context.read<Authcubit>().state;
    if (currentAuthState is Authenticated) {
      isAuthen = true;
      uid = currentAuthState.user!.uid;
      isFavorite = checkFavorite();
    } else {
      isAuthen = false;
      isFavorite = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.width >= 700;

    return BlocListener<Authcubit, AuthStates>(
      listener: (context, stateAuth) {
        if (stateAuth is Authenticated) {
          setState(() {
            isAuthen = true;
            uid = stateAuth.user!.uid;
            isFavorite = checkFavorite();
          });
        } else if (stateAuth is UnAuthenticated) {
          setState(() {
            isAuthen = false;
            isFavorite = false;
          });
        }
      },
      child: BlocBuilder<MovieinfoCubit, MovieInfoState>(
        builder: (context, state) {
          if (state is loadedMovieInfo) {
            final movie movieInfo = state.movieInfo!;
            final listAnotherMovie = state.listMovieOfCategories
                .whereType<Movieofcategories>()
                .toList();

            return Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height:
                          isTablet ? size.height * 0.47 : size.height * 0.39,
                      width: size.width,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CachedNetworkImage(
                              imageUrl:
                                  '${dotenv.env['API_LOAD_IMAGE']}${movieInfo.poster_url}',
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.15),
                                    Colors.black.withOpacity(0.7),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: isTablet ? 56 : 44,
                            left: isTablet ? 24 : 16,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.35),
                                  shape: BoxShape.circle),
                              child: IconButton(
                                onPressed: popToHome,
                                icon: const Icon(
                                  Icons.arrow_back_ios,
                                  size: 24,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: isTablet ? 56 : 44,
                            right: isTablet ? 24 : 16,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.35),
                                  shape: BoxShape.circle),
                              child: LikeButton(
                                size: 32,
                                isLiked: isFavorite,
                                likeBuilder: (isTapped) {
                                  return Icon(
                                    Icons.favorite,
                                    size: 32,
                                    color: isTapped
                                        ? Theme.of(context)
                                            .colorScheme
                                            .secondaryContainer
                                        : Colors.white70,
                                  );
                                },
                                onTap: (bool isLiked) async => isAuthen
                                    ? onLikeButtonTapped(
                                        isLiked, movieInfo, uid)
                                    : onUnLikeButtonTapped(isLiked),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 16,
                            right: 16,
                            bottom: 18,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Text(
                                    movieInfo.nameTitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: isTablet ? 30 : 24,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                GestureDetector(
                                  onTap: () => isAuthen
                                      ? tapToWatch(
                                          movieInfo.listEpisode[0].link_m3u8,
                                          '${movieInfo.nameTitle}: Tập 1',
                                          movieInfo.poster_url,
                                        )
                                      : showLoginDialog(),
                                  child: Container(
                                    height: isTablet ? 64 : 58,
                                    width: isTablet ? 64 : 58,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.72),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.play_arrow,
                                        size: isTablet ? 44 : 38,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondaryContainer,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 14, 15, 6),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _chipBadge(movieInfo.quality),
                          _chipBadge(movieInfo.lang),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 10,
                        children: [
                          _metaBadge(Icons.av_timer_rounded, movieInfo.timeOn),
                          _metaBadge(Icons.star_purple500_sharp,
                              '${movieInfo.vote_average} (TMDB)'),
                        ],
                      ),
                    ),
                    _divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Phát hành',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  parseTime(movieInfo.releaseDate),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Thể loại',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  genre(movieInfo.genre),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  movieInfo.episode_current,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              GestureDetector(
                                onTap: onTapTrailler,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0, vertical: 6.0),
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    color: Color.fromARGB(255, 69, 67, 67),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0)),
                                  ),
                                  child: Text(
                                    'Giới thiệu',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondaryContainer,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tập',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: movieInfo.listEpisode.length > 6
                                ? (isTablet
                                    ? size.height * 0.16
                                    : size.height * 0.13)
                                : size.height * 0.058,
                            child: GridView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: movieInfo.listEpisode.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                mainAxisSpacing: 8.0,
                                crossAxisSpacing: 8,
                                childAspectRatio: 16 / 9,
                                crossAxisCount: isTablet ? 10 : 5,
                              ),
                              itemBuilder: (context, index) => GestureDetector(
                                onTap: () => isAuthen
                                    ? selectEpisode(
                                        index,
                                        movieInfo.listEpisode[index].link_m3u8,
                                        '${movieInfo.nameTitle}: Tập ${index + 1}',
                                        movieInfo.poster_url,
                                      )
                                    : showLoginDialog(),
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    color: Color.fromARGB(255, 69, 67, 67),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0)),
                                  ),
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: (index + 1) == currentEpisode
                                          ? Theme.of(context)
                                              .colorScheme
                                              .secondaryContainer
                                          : Theme.of(context)
                                              .colorScheme
                                              .primary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mô tả',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          ReadMoreText(
                            movieInfo.describe,
                            trimMode: TrimMode.Line,
                            trimLines: 2,
                            colorClickableText:
                                Theme.of(context).colorScheme.primary,
                            trimCollapsedText: 'Mở rộng',
                            trimExpandedText: 'Thu gọn',
                            moreStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Phim khác..',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: isTablet
                                ? size.height * 0.32
                                : size.height * 0.29,
                            child: listAnotherMovie.isEmpty
                                ? Center(
                                    child: Text(
                                      'Chưa có phim gợi ý',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: listAnotherMovie.length,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(width: 10),
                                    itemBuilder: (context, index) =>
                                        itemMovieOther(
                                      listAnotherMovie[index].name,
                                      listAnotherMovie[index].posterUrl,
                                      () => tapAnotherMovie(
                                        listAnotherMovie[index].slug,
                                        listAnotherMovie[index].id,
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          }

          if (state is errorMovieInfo) {
            return const Errorscreen();
          }

          return const MovieInfoSkeleton();
        },
      ),
    );
  }

  Widget _divider() {
    return Divider(
      color: Theme.of(context).colorScheme.secondary.withOpacity(0.4),
      thickness: 1,
      indent: 15,
      endIndent: 15,
    );
  }

  Widget _chipBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: const BoxDecoration(
        color: Color.fromARGB(153, 69, 68, 68),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.secondaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _metaBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.14),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.secondary,
            size: 20,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget itemMovieOther(String name, String urlImage, Function()? onTap) {
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.width >= 700;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isTablet ? size.width * 0.29 : size.width * 0.43,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiary.withOpacity(0.12),
          borderRadius: const BorderRadius.all(Radius.circular(18)),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(14)),
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  width: double.infinity,
                  imageUrl: '${dotenv.env['API_LOAD_IMAGE']}$urlImage',
                  placeholder: (context, text) => Container(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.25),
                  ),
                  errorWidget: (context, text, ob) {
                    return Container(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.5),
                      child: Icon(
                        Icons.error,
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        size: 30,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class MovieInfoSkeleton extends StatefulWidget {
  const MovieInfoSkeleton({super.key});

  @override
  State<MovieInfoSkeleton> createState() => _MovieInfoSkeletonState();
}

class _MovieInfoSkeletonState extends State<MovieInfoSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.width >= 700;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final base = Theme.of(context).colorScheme.secondary;
        final color = Color.lerp(
          base.withOpacity(0.14),
          base.withOpacity(0.32),
          _controller.value,
        )!;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _box(
                height: isTablet ? size.height * 0.47 : size.height * 0.39,
                width: double.infinity,
                color: color,
                radius: 0,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 14, 15, 6),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _box(height: 30, width: 88, color: color, radius: 8),
                    _box(height: 30, width: 84, color: color, radius: 8),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _box(height: 36, width: 150, color: color, radius: 10),
                    _box(height: 36, width: 170, color: color, radius: 10),
                  ],
                ),
              ),
              _divider(context),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: _box(
                          height: 52,
                          width: double.infinity,
                          color: color,
                          radius: 10),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: _box(
                          height: 52,
                          width: double.infinity,
                          color: color,
                          radius: 10),
                    ),
                  ],
                ),
              ),
              _divider(context),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: _box(height: 24, width: 180, color: color, radius: 8),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 10,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isTablet ? 10 : 5,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 16 / 9,
                  ),
                  itemBuilder: (context, index) =>
                      _box(height: 20, width: 40, color: color, radius: 8),
                ),
              ),
              _divider(context),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _box(height: 24, width: 80, color: color, radius: 8),
                    const SizedBox(height: 10),
                    _box(
                        height: 16,
                        width: double.infinity,
                        color: color,
                        radius: 8),
                    const SizedBox(height: 8),
                    _box(
                        height: 16,
                        width: size.width * 0.8,
                        color: color,
                        radius: 8),
                  ],
                ),
              ),
              _divider(context),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _box(height: 24, width: 96, color: color, radius: 8),
                    const SizedBox(height: 10),
                    SizedBox(
                      height:
                          isTablet ? size.height * 0.32 : size.height * 0.29,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: 4,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 10),
                        itemBuilder: (context, index) => Container(
                          width:
                              isTablet ? size.width * 0.29 : size.width * 0.43,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .tertiary
                                .withOpacity(0.12),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(18)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _box(
                                  height: double.infinity,
                                  width: double.infinity,
                                  color: color,
                                  radius: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _box(
                                  height: 16,
                                  width: double.infinity,
                                  color: color,
                                  radius: 8),
                              const SizedBox(height: 6),
                              _box(
                                  height: 16,
                                  width: size.width * 0.26,
                                  color: color,
                                  radius: 8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _divider(BuildContext context) {
    return Divider(
      color: Theme.of(context).colorScheme.secondary.withOpacity(0.4),
      thickness: 1,
      indent: 15,
      endIndent: 15,
    );
  }

  Widget _box(
      {required double height,
      required double width,
      required Color color,
      required double radius}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
