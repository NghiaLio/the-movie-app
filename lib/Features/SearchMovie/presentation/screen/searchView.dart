import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Infor_of_Movie/Presentation/screen/movieInfoScreen.dart';
import '../../Domain/Entities/searchMovie.dart';
import '../Cubit/searchCubit.dart';
import '../Cubit/searchState.dart';
import 'searchLayout.dart';
import 'searchSuggest.dart';

class Searchview extends StatefulWidget {
  const Searchview({super.key});

  @override
  State<Searchview> createState() => _SearchviewState();
}

class _SearchviewState extends State<Searchview> {
  final TextEditingController Countrycontroller = TextEditingController();
  final TextEditingController Searchcontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<Searchcubit>().getCountry();
  }

  @override
  void dispose() {
    Countrycontroller.dispose();
    Searchcontroller.dispose();
    super.dispose();
  }

  //back to previous page
  void backToPage() {
    context.read<Searchcubit>().getCountry();
    Navigator.pop(context);
  }

  //option suggest select
  void setSuggestMovieSearch(String label, String slug) {
    //set search
    setState(() {
      Searchcontroller.text = 'Từ khóa: $label';
    });
    //hide keyboard
    FocusScope.of(context).requestFocus(FocusNode());

    //get movie
    context.read<Searchcubit>().getMoviebySuggest(slug);
  }

  //select country
  void selectCountry(dynamic country) {
    if (country != null) {
      setState(() {
        Searchcontroller.text = 'quoc_gia: $country';
      });
    }
    //hide keyboard
    FocusScope.of(context).requestFocus(FocusNode());

    //get movie
    context.read<Searchcubit>().getmovieCountry(country.toString());
  }

  //change value search
  void onChanged(String keyword) {
    if (mounted) {
      setState(() {});
    }

    final normalized = keyword.trim();

    if (normalized.isEmpty) {
      Countrycontroller.clear();
      context.read<Searchcubit>().getCountry();
    } else {
      context.read<Searchcubit>().getMoviebykeyword(normalized);
    }
  }

  //tap to seen infor of movie
  void toToMovieInfo(String slug, String id) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (c) => Movieinfoscreen(
                  slugMovie: slug,
                  idMovie: id,
                )));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.width >= 700;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: backToPage, icon: const Icon(Icons.arrow_back_ios)),
          title: const Text('Tìm kiếm phim'),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 22 : 14, vertical: isTablet ? 16 : 12),
          child: SingleChildScrollView(
            child: Column(
              children: [
                //search barr
                TextField(
                  autofocus: true,
                  // onTap: () => Searchcontroller.clear(),
                  controller: Searchcontroller,
                  onChanged: onChanged,
                  style: TextStyle(
                    fontSize: isTablet ? 22 : 18,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                        vertical: isTablet ? 12.0 : 10.0,
                        horizontal: isTablet ? 14 : 10),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Icon(
                        Icons.search,
                        size: 28,
                      ),
                    ),
                    hintText: 'Nhập từ khóa..',
                    filled: true,
                    fillColor:
                        Theme.of(context).colorScheme.tertiary.withOpacity(0.2),
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    suffixIcon: Searchcontroller.text.trim().isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              Searchcontroller.clear();
                              onChanged('');
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                            icon: const Icon(Icons.close_rounded),
                          )
                        : null,
                  ),
                ),

                // view
                BlocBuilder<Searchcubit, Searchstate>(
                    builder: (context, states) {
                  if (states is loadedCountry) {
                    final listSuggest = states.list_country!.list_Country;
                    List<DropdownMenuEntry<dynamic>> dropdownMenuEntries =
                        listSuggest
                            .map((e) => DropdownMenuEntry(
                                value: e.slug,
                                label: e.name,
                                style: MenuItemButton.styleFrom(
                                    textStyle: const TextStyle(fontSize: 20))))
                            .toList();

                    return Searchsuggest(
                      Searchcontroller: Searchcontroller,
                      Countrycontroller: Countrycontroller,
                      selectCountry: selectCountry,
                      setSuggestMovieSearch: setSuggestMovieSearch,
                      list_Country: dropdownMenuEntries,
                    );
                  } else if (states is loadedMovieofCountry) {
                    List<Searchmovie> listMovieofCountry =
                        states.listMovieCountry!.listSearch;

                    return SizedBox(
                        height: size.height * 0.78,
                        child: Searchlayout(
                          listMoviebySearch: listMovieofCountry,
                          tapToMovieInfo: toToMovieInfo,
                        ));
                  } else if (states is loadedMovieofSuggest) {
                    List<Searchmovie> listSearch =
                        states.listMovieSuggest!.listSearch;
                    return SizedBox(
                        height: size.height * 0.78,
                        child: Searchlayout(
                          listMoviebySearch: listSearch,
                          tapToMovieInfo: toToMovieInfo,
                        ));
                  } else if (states is loadedSearchbykeyword) {
                    List<Searchmovie?> listSearch =
                        context.read<Searchcubit>().listSearch;
                    return SizedBox(
                        height: size.height * 0.78,
                        child: Searchlayout(
                          listMoviebySearch: listSearch,
                          tapToMovieInfo: toToMovieInfo,
                        ));
                  } else if (states is loadingSearch) {
                    return SizedBox(
                      height: size.height * 0.76,
                      child: const SearchResultSkeleton(),
                    );
                  } else {
                    return SizedBox(
                      height: size.height * 0.76,
                      child: Center(
                        child: Icon(
                          Icons.error_outline_rounded,
                          size: 52,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    );
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SearchResultSkeleton extends StatefulWidget {
  const SearchResultSkeleton({super.key});

  @override
  State<SearchResultSkeleton> createState() => _SearchResultSkeletonState();
}

class _SearchResultSkeletonState extends State<SearchResultSkeleton>
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
            base.withOpacity(0.14), base.withOpacity(0.3), _controller.value)!;

        return ListView.separated(
          itemCount: 6,
          separatorBuilder: (context, index) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            return Container(
              height: isTablet ? 170 : 150,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Container(
                    width: isTablet ? size.width * 0.24 : size.width * 0.30,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 18,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 18,
                          width: size.width * 0.45,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
