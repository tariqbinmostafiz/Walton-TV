import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({super.key});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  bool _isPlaying = false;
  double _currentPosition = 14.0;
  final double _totalDuration = 180.0;
  double _volume = 0.8;
  String _videoTitle = 'Sample Walton TV Demo Media';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0F14),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'In-App Video Player',
          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Notice banner explaining Slot 5 behavior
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: RemoteColors.videoPlayerBlue.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: RemoteColors.videoPlayerBlue.withAlpha(80)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info_outline_rounded, color: RemoteColors.videoPlayerBlue, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Custom Slot 5 is assigned as an in-app Video Player. This operates inside the app on your phone, separate from TV IR.',
                      style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),

            // Video Canvas area
            Container(
              margin: const EdgeInsets.all(16),
              height: 220,
              decoration: BoxDecoration(
                color: const Color(0xFF161922),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(150),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isPlaying ? Icons.movie_rounded : Icons.videocam_rounded,
                        size: 54,
                        color: RemoteColors.videoPlayerBlue.withAlpha(180),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _videoTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isPlaying ? 'Playing • 1080p 60fps' : 'Paused',
                        style: TextStyle(
                          color: _isPlaying ? RemoteColors.connectedGreen : Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  // Center Play/Pause button
                  Positioned(
                    child: GestureDetector(
                      onTap: () => setState(() => _isPlaying = !_isPlaying),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(140),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Icon(
                          _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Video Timeline slider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: RemoteColors.videoPlayerBlue,
                      inactiveTrackColor: Colors.white24,
                      thumbColor: Colors.white,
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    ),
                    child: Slider(
                      value: _currentPosition,
                      min: 0.0,
                      max: _totalDuration,
                      onChanged: (val) => setState(() => _currentPosition = val),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_currentPosition),
                        style: const TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                      Text(
                        _formatDuration(_totalDuration),
                        style: const TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Controls Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.replay_10_rounded, color: Colors.white70, size: 28),
                    onPressed: () {
                      setState(() {
                        _currentPosition = (_currentPosition - 10).clamp(0.0, _totalDuration);
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      _isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                      color: RemoteColors.videoPlayerBlue,
                      size: 48,
                    ),
                    onPressed: () => setState(() => _isPlaying = !_isPlaying),
                  ),
                  IconButton(
                    icon: const Icon(Icons.forward_10_rounded, color: Colors.white70, size: 28),
                    onPressed: () {
                      setState(() {
                        _currentPosition = (_currentPosition + 10).clamp(0.0, _totalDuration);
                      });
                    },
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.white10, height: 32),

            // File selection action
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.white12),
                ),
                tileColor: const Color(0xFF161922),
                leading: const Icon(Icons.folder_open_rounded, color: Colors.amber),
                title: const Text(
                  'Select Video from Device',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Uses zero-permission system file picker (SAF)',
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white54),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('System file picker ready for offline media playback.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(double seconds) {
    final int sec = seconds.toInt();
    final int minutes = sec ~/ 60;
    final int remainingSec = sec % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSec.toString().padLeft(2, '0')}';
  }
}
