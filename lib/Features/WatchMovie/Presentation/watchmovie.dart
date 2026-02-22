// ignore_for_file: avoid_print

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_indicator/loading_indicator.dart';
import '../../Home/Presentation/Cubit/homeCubit.dart';
import '../Domain/SaveTimeEntity.dart';
import 'Cubits/TimeMovie.dart';
import 'package:video_player/video_player.dart';

class Watchmovie extends StatefulWidget {
  final String uid;
  final String posterUrl;
  final String movieUrl;
  final String nameEpisode;
  final String? time;
  final String slug;
  final String idMovie;

  const Watchmovie(
      {super.key,
      required this.movieUrl,
      required this.nameEpisode,
      required this.posterUrl,
      required this.uid,
      this.time,
      required this.idMovie,
      required this.slug});

  @override
  State<Watchmovie> createState() => _WatchmovieState();
}

class _WatchmovieState extends State<Watchmovie> with WidgetsBindingObserver {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  late Duration lastPosition;

  final saveTime = TimeMovie();

  Duration parseDuration(String s) {
    List<String> parts = s.split(':');
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);
    double seconds = double.parse(parts[2]);
    return Duration(hours: hours, minutes: minutes, seconds: seconds.round());
  }

  Future<void> _initializeVideoPlayer() async {
    // Lấy vị trí lưu trước đó
    if (!mounted) return;
    setState(() {
      lastPosition = parseDuration(widget.time ?? "00:00:00");
    });

    // Khởi tạo VideoPlayerController
    _videoPlayerController =
        VideoPlayerController.contentUri(Uri.parse(widget.movieUrl));
    await _videoPlayerController.initialize();

    // Seek đến vị trí đã lưu
    if (lastPosition > Duration.zero) {
      await _videoPlayerController
          .seekTo(lastPosition)
          .then((onValue) => print('success'))
          .catchError((onError) => print(onError.toString()));
    }
    _chewieController = ChewieController(
        autoPlay: true,
        looping: true,
        videoPlayerController: _videoPlayerController,
        playbackSpeeds: [0.5, 0.75, 1.0, 1.5, 2.0],
        materialSeekButtonSize: 28,
        aspectRatio: 16 / 9);

    if (!mounted) return;
    setState(() {});
  }

  //save and update continous movie
  void save_and_update_continous() async {
    final saveTimePause = SaveTimeEntity(
        uid: widget.uid,
        time: _videoPlayerController.value.position.toString(),
        movieUrl: widget.movieUrl,
        nameEpisoda: widget.nameEpisode,
        posterUrl: widget.posterUrl,
        slug: widget.slug,
        idMovie: widget.idMovie);
    await saveTime.saveTimePause(widget.uid, saveTimePause);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _initializeVideoPlayer();
    super.initState();
  }

  @override
  void dispose() {
    save_and_update_continous();
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      _videoPlayerController.play();
    } else if (state == AppLifecycleState.inactive) {
      _videoPlayerController.pause();
    } else if (state == AppLifecycleState.detached) {
    } else if (state == AppLifecycleState.paused) {
      _videoPlayerController.pause();
      save_and_update_continous();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: _chewieController == null
          ? Center(
              child: SizedBox(
                width: size.width * 0.22,
                child: LoadingIndicator(
                  indicatorType: Indicator.ballSpinFadeLoader,
                  colors: [colorScheme.secondaryContainer],
                ),
              ),
            )
          : SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            context.read<Homecubit>().getHome(widget.uid);
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.arrow_back_ios),
                        ),
                        Expanded(
                          child: Text(
                            widget.nameEpisode,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Chewie(controller: _chewieController!),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      widget.nameEpisode,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'Đang phát • Chất lượng tự động',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiary.withOpacity(0.1),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(16)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thông tin phát',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Bạn có thể chạm vào video để hiện điều khiển, tua nhanh/chậm và tiếp tục xem từ vị trí đã lưu.',
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
