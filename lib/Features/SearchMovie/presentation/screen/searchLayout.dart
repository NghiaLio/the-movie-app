import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Searchlayout extends StatefulWidget {
  final List<dynamic> listMoviebySearch;
  final Function(String slug, String id) tapToMovieInfo;

  const Searchlayout(
      {super.key,
      required this.listMoviebySearch,
      required this.tapToMovieInfo});

  @override
  State<Searchlayout> createState() => _SearchlayoutState();
}

class _SearchlayoutState extends State<Searchlayout> {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(top: 14, bottom: 24),
      itemCount: widget.listMoviebySearch.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) => itemMovie(
        widget.listMoviebySearch[index].posterUrl,
        widget.listMoviebySearch[index].name,
        widget.listMoviebySearch[index].slug,
        widget.listMoviebySearch[index].id,
      ),
    );
  }

  Widget itemMovie(String imageUrl, String name, String slug, String id) {
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.width >= 700;
    final double posterWidth = isTablet ? size.width * 0.24 : size.width * 0.30;

    return Material(
      color: Theme.of(context).colorScheme.tertiary.withOpacity(0.12),
      borderRadius: const BorderRadius.all(Radius.circular(18)),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(18)),
        onTap: () => widget.tapToMovieInfo(slug, id),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: posterWidth,
                child: AspectRatio(
                  aspectRatio: 2 / 3,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    child: CachedNetworkImage(
                      imageUrl: '${dotenv.env['API_LOAD_IMAGE']}$imageUrl',
                      placeholder: (context, text) => Container(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.22),
                      ),
                      errorWidget: (context, text, ob) {
                        return Container(
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.45),
                          child: Icon(
                            Icons.error,
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            size: 28,
                          ),
                        );
                      },
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                child: SizedBox(
                  height: (posterWidth * 1.5).clamp(130, 240).toDouble(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: isTablet ? 22 : 18,
                            fontWeight: FontWeight.w500),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.play_circle_fill_rounded,
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            size: isTablet ? 24 : 22,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Xem chi tiết',
                            style: TextStyle(
                              fontSize: isTablet ? 16 : 14,
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
