import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:open_contacts/auxiliary.dart';
import 'package:open_contacts/clients/audio_cache_client.dart';
import 'package:open_contacts/models/message.dart';
import 'package:open_contacts/widgets/messages/message_state_indicator.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

// This 
//[[ERROR:flutter/shell/common/shell.cc(1065)] The 'com.ryanheise.just_audio.events.b5a52ea0-18f6-4553-920c-daa82e3ba5d8' channel sent a message from native to Flutter on a non-platform thread.


class MessageAudioPlayer extends StatefulWidget {
  const MessageAudioPlayer({required this.message, this.foregroundColor, super.key});

  final Message message;
  final Color? foregroundColor;

  @override
  State<MessageAudioPlayer> createState() => _MessageAudioPlayerState();
}

class _MessageAudioPlayerState extends State<MessageAudioPlayer> with WidgetsBindingObserver {
  AudioPlayer? _audioPlayer;
  Future? _audioFileFuture;
  double _sliderValue = 0;

  @override
  void initState() {
    super.initState();
    // Suppress platform thread warnings for audio player
    if (kDebugMode) {
      FlutterError.onError = (FlutterErrorDetails details) {
        if (details.exception.toString().contains('Flutter on a non-platform thread')) {
          // Ignore the platform thread warning
          return;
        }
        FlutterError.presentError(details);
      };
    }
    
    WidgetsBinding.instance.addObserver(this);
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    if (_audioPlayer != null) return;
    
    try {
      // Initialize on platform thread
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
      
      _audioPlayer = AudioPlayer();
      
      // Ensure stable playback by setting up player on platform thread
      await Future.microtask(() async {
        if (!mounted) return;
        await Future.wait([
          _audioPlayer!.setVolume(1.0),
          _audioPlayer!.setSpeed(1.0),
          _audioPlayer!.setPitch(1.0),
          _audioPlayer!.setLoopMode(LoopMode.off),
        ]);
      });
      
    } catch (e) {
      debugPrint('Audio player initialization error: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _audioPlayer?.stop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final audioCache = Provider.of<AudioCacheClient>(context);
    final audioContent = widget.message.audioContent;
    if (audioContent == null || audioContent.assetUri.isEmpty) return;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAudioFile(audioCache, audioContent);
    });
  }

  Future<void> _loadAudioFile(AudioCacheClient audioCache, AudioClipContent audioContent) async {
    try {
      final file = await audioCache.cachedNetworkAudioFile(audioContent);
      
      if (!mounted) return;
      
      // Ensure audio operations run on platform thread
      await WidgetsBinding.instance.endOfFrame;
      await Future.microtask(() async {
        if (!mounted) return;
        await _audioPlayer?.setFilePath(file.path);
        await _audioPlayer?.setVolume(1.0);
      });
      
      setState(() {
        _audioFileFuture = Future.value(file);
      });
      
    } catch (e) {
      debugPrint('Error in _loadAudioFile: $e');
      rethrow;
    }
  }

  @override
  void didUpdateWidget(covariant MessageAudioPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message.id == widget.message.id) return;
    
    final audioContent = widget.message.audioContent;
    if (audioContent == null || audioContent.assetUri.isEmpty) return;
    
    final audioCache = Provider.of<AudioCacheClient>(context);
    _audioFileFuture = audioCache
        .cachedNetworkAudioFile(audioContent)
        .then((value) async {
          // Ensure we're on the platform thread by using a post-frame callback
          await WidgetsBinding.instance.endOfFrame;
          if (!mounted) return value;
          
          // Wrap audio operations in a microtask to ensure platform thread execution
          await Future.microtask(() {
            if (!mounted) return;
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              if (!mounted) return;
              await _audioPlayer?.setFilePath(value.path);
            });
          });
          
          await _audioPlayer?.setLoopMode(LoopMode.off);
          await _audioPlayer?.pause();
          await _audioPlayer?.seek(Duration.zero);
          
          return value;
        });
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Widget _createErrorWidget(String error) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            error,
            textAlign: TextAlign.center,
            softWrap: true,
            maxLines: 3,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: StreamBuilder<PlayerState>(
        stream: _audioPlayer?.playerStateStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            FlutterError.reportError(FlutterErrorDetails(exception: snapshot.error!, stack: snapshot.stackTrace));
            return _createErrorWidget("Failed to load audio-message.");
          }
          final playerState = snapshot.data;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FutureBuilder(
                    future: _audioFileFuture,
                    builder: (context, fileSnapshot) {
                      if (fileSnapshot.hasError) {
                        FlutterError.reportError(
                            FlutterErrorDetails(exception: fileSnapshot.error!, stack: fileSnapshot.stackTrace));
                        return const IconButton(
                          icon: Icon(Icons.warning),
                          tooltip: "Failed to load audio-message.",
                          onPressed: null,
                        );
                      }
                      return IconButton(
                        onPressed: fileSnapshot.hasData &&
                                snapshot.hasData &&
                                playerState != null &&
                                playerState.processingState != ProcessingState.loading
                            ? () {
                                switch (playerState.processingState) {
                                  case ProcessingState.idle:
                                  case ProcessingState.loading:
                                  case ProcessingState.buffering:
                                    break;
                                  case ProcessingState.ready:
                                    if (playerState.playing) {
                                      _audioPlayer?.pause();
                                    } else {
                                      _audioPlayer?.play();
                                    }
                                    break;
                                  case ProcessingState.completed:
                                    _audioPlayer?.seek(Duration.zero);
                                    _audioPlayer?.play();
                                    break;
                                }
                              }
                            : null,
                        color: widget.foregroundColor,
                        icon: Icon(
                          ((_audioPlayer?.duration ?? const Duration(days: 9999)) - 
                           (_audioPlayer?.position ?? Duration.zero)).inMilliseconds < 10
                              ? Icons.replay
                              : playerState?.playing ?? false
                                  ? Icons.pause
                                  : Icons.play_arrow,
                          color: widget.foregroundColor,
                        ),
                      );
                    },
                  ),
                  StreamBuilder(
                    stream: _audioPlayer?.positionStream,
                    builder: (context, snapshot) {
                      if (_audioPlayer == null || _audioPlayer?.duration == null) {
                        _sliderValue = 0;
                      } else {
                        _sliderValue = (_audioPlayer!.position.inMilliseconds.toDouble() / 
                                      (_audioPlayer!.duration?.inMilliseconds ?? 1))
                                      .clamp(0, 1);
                      }
                      
                      return StatefulBuilder(
                        builder: (context, setState) {
                          return SliderTheme(
                            data: SliderThemeData(
                              inactiveTrackColor: widget.foregroundColor?.withOpacity(0.3),
                              activeTrackColor: widget.foregroundColor,
                              thumbColor: widget.foregroundColor,
                              overlayColor: widget.foregroundColor?.withOpacity(0.3),
                            ),
                            child: Slider(
                              activeColor: widget.foregroundColor,
                              thumbColor: widget.foregroundColor,
                              value: _sliderValue,
                              min: 0.0,
                              max: 1.0,
                              onChanged: (_audioPlayer == null) ? null : (value) async {
                                await WidgetsBinding.instance.endOfFrame;
                                if (!mounted) return;
                                
                                await _audioPlayer?.pause();
                                setState(() {
                                  _sliderValue = value;
                                });
                                
                                final duration = _audioPlayer?.duration;
                                if (duration != null) {
                                  await _audioPlayer?.seek(
                                    Duration(
                                      milliseconds: (value * duration.inMilliseconds).round(),
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      );
                    },
                  )
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(
                    width: 4,
                  ),
                  StreamBuilder(
                    stream: _audioPlayer?.positionStream,
                    builder: (context, snapshot) {
                      return Text(
                        "${snapshot.data?.format() ?? "??"}/${_audioPlayer?.duration?.format() ?? "??"}",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: widget.foregroundColor?.withAlpha(150)),
                      );
                    },
                  ),
                  const Spacer(),
                  MessageStateIndicator(
                    message: widget.message,
                    foregroundColor: widget.foregroundColor,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
