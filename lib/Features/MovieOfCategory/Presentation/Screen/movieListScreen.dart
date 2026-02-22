import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Components/ErrorScreen.dart';
import '../../../SearchMovie/presentation/screen/searchView.dart';
import '../../Domain/Entities/Categories.dart';
import '../../Domain/Entities/MovieOfCategories.dart';
import '../Cubits/movieCubit.dart';
import '../Cubits/movieState.dart';
import 'Components/tabView.dart';

class Information extends StatefulWidget {
  const Information({super.key});

  @override
  State<Information> createState() => _InformationState();
}

class _InformationState extends State<Information> {
  void pushSearch() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const Searchview()));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.width >= 700;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 22 : 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: isTablet ? 24 : 16),
                child: DefaultTextStyle(
                  style: TextStyle(
                      fontSize: isTablet ? 30 : 24,
                      fontWeight: FontWeight.w600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Danh sách phim..'),
                      Text(
                        'và tìm kiếm..',
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                onTap: pushSearch,
                readOnly: true,
                style: TextStyle(
                    fontSize: isTablet ? 22 : 18,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.8)),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                      vertical: isTablet ? 14.0 : 10.0,
                      horizontal: isTablet ? 14 : 10),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Icon(
                      Icons.search,
                      size: 28,
                    ),
                  ),
                  hintText: 'Tìm kiếm..',
                  filled: true,
                  fillColor:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.12),
                  enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: BlocBuilder<movieCubit, movieStates>(
                  builder: (context, states) {
                    if (states is successLoadMovie) {
                      List<Categories> categories =
                          states.listCategories!.listCategories;
                      List<Tab> tabTitle = categories
                          .map((e) => Tab(
                                text: e.name,
                              ))
                          .toList();
                      List<ListMovieOfCategories?> movieOfCategories =
                          states.listMovieOfCategories;
                      return viewMovie(
                        tabTitle: tabTitle,
                        list: movieOfCategories,
                      );
                    }
                    if (states is ErrorMovie) {
                      return const Errorscreen();
                    }
                    return const MovieListSkeleton();
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MovieListSkeleton extends StatefulWidget {
  const MovieListSkeleton({super.key});

  @override
  State<MovieListSkeleton> createState() => _MovieListSkeletonState();
}

class _MovieListSkeletonState extends State<MovieListSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
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
          final color = Color.lerp(baseColor.withOpacity(0.14),
              baseColor.withOpacity(0.32), _controller.value)!;

          return Padding(
            padding: EdgeInsets.symmetric(vertical: isTablet ? 8 : 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _box(
                    height: isTablet ? 34 : 30,
                    width: isTablet ? 110 : 94,
                    color: color,
                    radius: 22),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _box(height: 34, width: 110, color: color, radius: 22),
                    const SizedBox(width: 10),
                    _box(height: 34, width: 120, color: color, radius: 22),
                    const SizedBox(width: 10),
                    _box(height: 34, width: 100, color: color, radius: 22),
                  ],
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: GridView.builder(
                    itemCount: 6,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isTablet ? 3 : 2,
                      crossAxisSpacing: isTablet ? 16 : 12,
                      mainAxisSpacing: isTablet ? 16 : 12,
                      childAspectRatio: 0.62,
                    ),
                    itemBuilder: (context, index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _box(
                                height: double.infinity,
                                width: double.infinity,
                                color: color,
                                radius: 18),
                          ),
                          const SizedBox(height: 8),
                          _box(
                              height: 18,
                              width: double.infinity,
                              color: color,
                              radius: 8),
                        ],
                      );
                    },
                  ),
                )
              ],
            ),
          );
        },
      ),
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
