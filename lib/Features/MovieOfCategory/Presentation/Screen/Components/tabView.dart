// ignore_for_file: camel_case_types

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../../Infor_of_Movie/Presentation/screen/movieInfoScreen.dart';
import '../../../Domain/Entities/MovieOfCategories.dart';

class viewMovie extends StatefulWidget {
  final List<Tab> tabTitle;
  final List<ListMovieOfCategories?> list;

  const viewMovie({super.key, required this.tabTitle, required this.list});

  @override
  State<viewMovie> createState() => _viewMovieState();
}

class _viewMovieState extends State<viewMovie> {
  //pushToInfo
  void pushToInfo(String slug, String id) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (c) => Movieinfoscreen(
            slugMovie: slug,
            idMovie: id,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.width >= 700;

    return DefaultTabController(
      initialIndex: 0,
      length: widget.tabTitle.length,
      child: Column(
        children: [
          TabBar(
            indicatorPadding: const EdgeInsets.only(right: 24),
            indicatorColor: Theme.of(context).colorScheme.secondaryContainer,
            labelColor: Theme.of(context).colorScheme.secondaryContainer,
            labelStyle: TextStyle(
                fontSize: isTablet ? 21 : 17, fontWeight: FontWeight.w500),
            tabAlignment: TabAlignment.start,
            dividerHeight: 0,
            isScrollable: true,
            tabs: widget.tabTitle,
          ),
          SizedBox(height: isTablet ? 14 : 10),
          Expanded(
            child: TabBarView(
              children: [
                for (int i = 0; i < widget.tabTitle.length; i++)
                  itemMovie(
                    widget.list[i]!.listMovieOfCategories,
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget itemMovie(
    List<Movieofcategories> movieOfCategories,
  ) {
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.width >= 700;
    final bool isDesktop = size.width >= 1200;

    int crossAxisCount = 2;
    if (isDesktop) {
      crossAxisCount = 4;
    } else if (isTablet) {
      crossAxisCount = 3;
    }

    return MasonryGridView.builder(
        itemCount: movieOfCategories.length,
        padding: EdgeInsets.only(bottom: isTablet ? 18 : 10),
        mainAxisSpacing: isTablet ? 18.0 : 14.0,
        crossAxisSpacing: isTablet ? 16.0 : 12.0,
        gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount),
        itemBuilder: (context, index) => GestureDetector(
              onTap: () => pushToInfo(
                  movieOfCategories[index].slug, movieOfCategories[index].id),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 0.68,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      child: CachedNetworkImage(
                        placeholder: (context, text) => Container(
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.25),
                        ),
                        fit: BoxFit.cover,
                        imageUrl:
                            '${dotenv.env['API_LOAD_IMAGE']}${movieOfCategories[index].posterUrl}',
                        errorWidget: (context, text, ob) {
                          return Container(
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.4),
                            child: Icon(
                              Icons.error,
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                              size: 30,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: isTablet ? 12 : 10,
                  ),
                  Text(
                    movieOfCategories[index].name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: isTablet ? 20 : 17),
                  )
                ],
              ),
            ));
  }
}
