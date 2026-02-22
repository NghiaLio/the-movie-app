// ignore_for_file: camel_case_types

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../Auth/Presentation/Cubit/authCubit.dart';
import '../../../Auth/Presentation/Cubit/auth_States.dart';
import '../../../Components/ErrorScreen.dart';
import '../../../WatchMovie/Domain/SaveTimeEntity.dart';
import '../../../WatchMovie/Presentation/watchmovie.dart';
import '../../Domain/Entities/ComingModel.dart';
import '../Cubit/homeCubit.dart';
import '../Cubit/homeState.dart';
import '../../../Infor_of_Movie/Presentation/screen/movieInfoScreen.dart';

class home extends StatefulWidget {
  const home({
    super.key,
  });

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  bool isAuthen = false;

  void onTapMovie(String slug, String id) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (c) => Movieinfoscreen(
            idMovie: id,
            slugMovie: slug,
          ),
        ));
  }

  void watchMovie(SaveTimeEntity saveTimeEntity) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (c) => Movieinfoscreen(
                slugMovie: saveTimeEntity.slug,
                idMovie: saveTimeEntity.idMovie)));
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (c) => Watchmovie(
                  uid: saveTimeEntity.uid,
                  posterUrl: saveTimeEntity.posterUrl,
                  nameEpisode: saveTimeEntity.nameEpisoda,
                  movieUrl: saveTimeEntity.movieUrl,
                  time: saveTimeEntity.time,
                  slug: saveTimeEntity.slug,
                  idMovie: saveTimeEntity.idMovie,
                )));
  }

  @override
  void initState() {
    final checkAuth = context.read<Authcubit>().state;
    super.initState();
    isAuthen = checkAuth is Authenticated;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.width >= 700;

    return Scaffold(
        body: BlocBuilder<Homecubit, homeState>(builder: (context, state) {
      if (state is SuccessHome) {
        final SaveTimeEntity saveTimeEntity = state.saveTimeEntity ??
            SaveTimeEntity(
                uid: "",
                time: "",
                movieUrl: "",
                nameEpisoda: "",
                posterUrl: "",
                slug: "",
                idMovie: "");
        final List<comingSoon?> listComing = state.comingData!.listComingSoon;
        final List<String> urlImage = listComing.map((e) {
          return '${dotenv.env['API_LOAD_IMAGE']}${e!.image}';
        }).toList();

        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 28 : 16, vertical: isTablet ? 18 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: isTablet ? 10 : 6),
                  child: Row(
                    children: [
                      Text(
                        'Đang',
                        style: TextStyle(
                            fontSize: isTablet ? 32 : 26,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer),
                      ),
                      Text(
                        ' xem....',
                        style: TextStyle(
                            fontSize: isTablet ? 32 : 26,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary),
                      )
                    ],
                  ),
                ),
                SizedBox(height: isTablet ? 22 : 16),
                SizedBox(
                  height: isTablet ? 300 : size.height * 0.24,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(24)),
                          child: isAuthen && saveTimeEntity.posterUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl:
                                      '${dotenv.env['API_LOAD_IMAGE']}${saveTimeEntity.posterUrl}',
                                  placeholder: (context, url) => Container(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withOpacity(0.5),
                                  ),
                                  errorWidget: (context, url, error) {
                                    return Container(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.2),
                                      child: const Center(
                                        child: Icon(Icons.error),
                                      ),
                                    );
                                  },
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  'assets/images/default_image.png',
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 14,
                        left: 14,
                        right: isTablet ? size.width * 0.45 : size.width * 0.3,
                        child: GestureDetector(
                          onTap: isAuthen && saveTimeEntity.movieUrl.isNotEmpty
                              ? () => watchMovie(saveTimeEntity)
                              : null,
                          child: Container(
                            height: isTablet ? 88 : 78,
                            decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withOpacity(0.62),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(24))),
                            padding: EdgeInsets.symmetric(
                                vertical: isTablet ? 10 : 8,
                                horizontal: isTablet ? 16 : 12),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.play_circle_filled_sharp,
                                  size: isTablet ? 50 : 42,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Xem tiếp',
                                        style: TextStyle(
                                          fontSize: isTablet ? 15 : 13,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.68),
                                        ),
                                      ),
                                      Text(
                                        isAuthen &&
                                                saveTimeEntity
                                                    .movieUrl.isNotEmpty
                                            ? 'Sẵn sàng'
                                            : 'Không tồn tại',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: isTablet ? 19 : 16,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: isTablet ? 24 : 18),
                Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: Text(
                    'Sắp chiếu...',
                    style: TextStyle(
                        fontSize: isTablet ? 32 : 26,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                SizedBox(height: isTablet ? 16 : 12),
                CarouselSlider.builder(
                    itemCount: urlImage.length,
                    itemBuilder: (context, index, realIndex) {
                      final imagelink = urlImage[index];
                      return buildImage(
                          imagelink,
                          index,
                          listComing[index]!.nameMovie.trim(),
                          listComing[index]!.voteAverage.toStringAsFixed(1),
                          () => onTapMovie(
                              listComing[index]!.slug, listComing[index]!.id));
                    },
                    options: CarouselOptions(
                        height: isTablet ? 420 : size.height * 0.38,
                        viewportFraction: isTablet ? 0.52 : 0.82,
                        enableInfiniteScroll: true,
                        autoPlay: true,
                        enlargeCenterPage: true,
                        enlargeFactor: 0.18)),
                SizedBox(height: isTablet ? 24 : 14)
              ],
            ),
          ),
        );
      }
      if (state is getFail) {
        return const Errorscreen();
      } else {
        return const HomeSkeleton();
      }
    }));
  }

  Widget buildImage(String urlImage, int index, String name, String rating,
      Function()? onTap) {
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.width >= 700;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              child: CachedNetworkImage(
                imageUrl: urlImage,
                placeholder: (context, url) => Container(
                  height: isTablet ? 395 : size.height * 0.36,
                  width: isTablet ? size.width * 0.5 : size.width * 0.688,
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                ),
                fit: BoxFit.cover,
                height: isTablet ? 410 : size.height * 0.38 + 10,
                width: isTablet ? size.width * 0.5 : size.width * 0.688,
              ),
            ),
          ),
          Positioned(
              bottom: 10,
              left: isTablet ? size.width * 0.05 - 11 : 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                    height: isTablet ? 84 : size.height * 0.08,
                    width: isTablet ? size.width * 0.4 : size.width * 0.6,
                    decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.6),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15))),
                    child: Center(
                      child: Text(name,
                          style: TextStyle(
                              fontSize: isTablet ? 24 : 20,
                              fontWeight: FontWeight.w400,
                              overflow: TextOverflow.ellipsis)),
                    )),
              )),
          Positioned(
              top: 10,
              right: 20,
              child: Container(
                  height:
                      isTablet ? size.height * 0.057 + 10 : size.height * 0.057,
                  width: isTablet ? size.width * 0.1 : size.width * 0.22,
                  decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.6),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(15))),
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'IMDB',
                        style: TextStyle(
                            fontSize: isTablet ? 11 : 10,
                            fontWeight: FontWeight.w600),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.yellow,
                            size: 26,
                          ),
                          Text(rating,
                              style: TextStyle(
                                  fontSize: isTablet ? 21 : 19,
                                  fontWeight: FontWeight.w600))
                        ],
                      )
                    ],
                  ))),
        ],
      ),
    );
  }
}

class HomeSkeleton extends StatefulWidget {
  const HomeSkeleton({super.key});

  @override
  State<HomeSkeleton> createState() => _HomeSkeletonState();
}

class _HomeSkeletonState extends State<HomeSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
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

    return SafeArea(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final baseColor = Theme.of(context).colorScheme.secondary;
          final color = Color.lerp(baseColor.withOpacity(0.16),
              baseColor.withOpacity(0.36), _controller.value)!;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 28 : 16, vertical: isTablet ? 18 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _skeletonBox(
                    height: isTablet ? 42 : 34,
                    width: isTablet ? 250 : 190,
                    color: color,
                    radius: 10),
                SizedBox(height: isTablet ? 22 : 16),
                _skeletonBox(
                    height: isTablet ? 300 : size.height * 0.24,
                    width: double.infinity,
                    color: color,
                    radius: 24),
                SizedBox(height: isTablet ? 24 : 18),
                _skeletonBox(
                    height: isTablet ? 42 : 34,
                    width: isTablet ? 200 : 170,
                    color: color,
                    radius: 10),
                SizedBox(height: isTablet ? 18 : 12),
                Row(
                  children: [
                    Expanded(
                      child: _skeletonBox(
                          height: isTablet ? 410 : size.height * 0.38,
                          width: double.infinity,
                          color: color,
                          radius: 20),
                    ),
                    SizedBox(width: isTablet ? 16 : 12),
                    Expanded(
                      child: _skeletonBox(
                          height: isTablet ? 410 : size.height * 0.38,
                          width: double.infinity,
                          color: color,
                          radius: 20),
                    )
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _skeletonBox(
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
