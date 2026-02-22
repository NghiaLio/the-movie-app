// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../Components/Loading.dart';
import '../Cubit/favoriteCubit.dart';
import '../Cubit/favoriteSate.dart';
import '../../domain/Entities/Favorite.dart';

import '../../../Infor_of_Movie/Presentation/screen/movieInfoScreen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Favoritescreen extends StatefulWidget {
  final String uid;
  const Favoritescreen({super.key, required this.uid});

  @override
  State<Favoritescreen> createState() => _FavoritescreenState();
}

class _FavoritescreenState extends State<Favoritescreen> {
  bool isEditItem = false;
  List<bool> checkItem = [];

  @override
  void initState() {
    super.initState();
    context.read<Favoritecubit>().getFavoriteMovie(widget.uid);
    final dataFavorite = context.read<Favoritecubit>().listFavotite;
    if (dataFavorite != null) {
      final listMovie = dataFavorite.ListFavoriteMovie;
      checkItem = listMovie.map((e) => false).toList();
    }
  }

  void _syncCheckedItems(int length) {
    if (checkItem.length == length) return;
    checkItem = List<bool>.generate(length, (index) {
      if (index < checkItem.length) {
        return checkItem[index];
      }
      return false;
    });
    if (length == 0) {
      isEditItem = false;
    }
  }

  int get selectedCount => checkItem.where((e) => e).length;

  //back
  void back() {
    Navigator.pop(context);
  }

  // nhan giu item
  void onLongPress(int index) {
    if (index >= checkItem.length) return;
    setState(() {
      isEditItem = true;
      checkItem[index] = true;
    });
  }

  // cancle edit
  void cancleEdit() {
    setState(() {
      isEditItem = false;
      checkItem = checkItem.map((e) => false).toList();
    });
  }

  //selected all
  void selectedAll() {
    if (checkItem.isEmpty) return;
    setState(() {
      isEditItem = true;
      checkItem = checkItem.map((e) => true).toList();
    });
  }

  void tapToMovieInfo(String slug, String idMovie) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (c) => Movieinfoscreen(
                  slugMovie: slug,
                  idMovie: idMovie,
                )));
  }

  void onDelete(List<FavoriteMovie> listMovie) async {
    // index of checkbox
    List<int> indexCheked = [];
    checkItem.asMap().forEach(
      (key, value) {
        if (value) {
          indexCheked.add(key);
        }
      },
    );

    if (indexCheked.isEmpty) return;

    for (var e in indexCheked) {
      await context
          .read<Favoritecubit>()
          .deleteMovie(widget.uid, listMovie[e].id);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:
          Text('Đã xóa ${indexCheked.length} phim khỏi danh sách yêu thích'),
    ));

    cancleEdit();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocBuilder<Favoritecubit, Favoritesate>(builder: (context, state) {
      if (state is loadedFavorite) {
        final dataState =
            state.listFavorite ?? ListFavorite(ListFavoriteMovie: []);
        final listFavorite = dataState.ListFavoriteMovie;
        _syncCheckedItems(listFavorite.length);

        return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: back,
                icon: const Icon(Icons.arrow_back_ios_new),
              ),
              title: const Text('Phim yêu thích'),
              actions: [
                if (isEditItem)
                  TextButton(
                    onPressed: cancleEdit,
                    child: const Text('Hủy', style: TextStyle(fontSize: 16)),
                  ),
                if (listFavorite.isNotEmpty)
                  PopupMenuButton(
                    iconSize: 24,
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'all',
                        child: Text('Chọn tất cả'),
                      ),
                    ],
                    onSelected: (value) => selectedAll(),
                  ),
              ],
            ),
            body: listFavorite.isNotEmpty
                ? ListView.separated(
                    padding: EdgeInsets.fromLTRB(12, 12, 12,
                        selectedCount > 0 ? size.height * 0.12 : 12),
                    itemCount: listFavorite.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) =>
                        itemMovie(index, listFavorite[index]),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 60,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Không có phim yêu thích',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
            bottomNavigationBar: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: selectedCount > 0 ? size.height * 0.08 : 0,
              child: selectedCount > 0
                  ? SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => onDelete(listFavorite),
                            icon: const Icon(Icons.delete_outline),
                            label: Text('Xóa khỏi yêu thích ($selectedCount)'),
                          ),
                        ),
                      ),
                    )
                  : null,
            ));
      } else {
        return const loadingIndicator();
      }
    });
  }

  Widget itemMovie(int index, FavoriteMovie movie) {
    final size = MediaQuery.of(context).size;
    final isChecked = index < checkItem.length ? checkItem[index] : false;

    return InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      onLongPress: () => onLongPress(index),
      onTap: () {
        if (isEditItem) {
          setState(() {
            checkItem[index] = !checkItem[index];
          });
        } else {
          tapToMovieInfo(movie.slug, movie.id);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          border: Border.all(
            color: isChecked
                ? Theme.of(context).colorScheme.secondaryContainer
                : Theme.of(context).colorScheme.tertiary.withOpacity(0.2),
            width: isChecked ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: isEditItem ? 42 : 0,
              child: isEditItem
                  ? Checkbox(
                      activeColor:
                          Theme.of(context).colorScheme.secondaryContainer,
                      value: isChecked,
                      onChanged: (value) {
                        setState(() {
                          checkItem[index] = value ?? false;
                        });
                      },
                    )
                  : null,
            ),
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: '${dotenv.env['API_LOAD_IMAGE']}${movie.posterUrl}',
                placeholder: (context, text) => Container(
                  alignment: Alignment.center,
                  height: size.height * 0.18,
                  width: size.width * 0.28,
                  child: const Text('Đang tải...'),
                ),
                errorWidget: (context, text, ob) {
                  return Container(
                    height: size.height * 0.18,
                    width: size.width * 0.28,
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
                height: size.height * 0.18,
                width: size.width * 0.28,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  movie.name,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
