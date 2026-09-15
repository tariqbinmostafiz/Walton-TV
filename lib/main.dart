import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/main_remote_page.dart';
import 'pages/more_controls_page.dart';
import 'services/ir_service.dart';
import 'services/settings_service.dart';
import 'theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system navigation and status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: RemoteColors.darkBackground,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize persistent settings and check IR hardware
  await SettingsService().init();
  await IrService().checkIrEmitter();

  runApp(const WaltonRemoteApp());
}

class WaltonRemoteApp extends StatelessWidget {
  const WaltonRemoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService();

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        return MaterialApp(
          title: 'Walton TV Remote',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settings.themeMode,
          home: const RemoteHomeScreen(),
        );
      },
    );
  }
}

class RemoteHomeScreen extends StatefulWidget {
  const RemoteHomeScreen({super.key});

  @override
  State<RemoteHomeScreen> createState() => _RemoteHomeScreenState();
}

class _RemoteHomeScreenState extends State<RemoteHomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ir = IrService();

    return Scaffold(
      backgroundColor: _currentPage == 0
          ? RemoteColors.darkBackground
          : RemoteColors.lightBackground,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (page) {
              setState(() => _currentPage = page);
              // Update status bar brightness according to current page
              SystemChrome.setSystemUIOverlayStyle(
                SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness:
                      page == 0 ? Brightness.light : Brightness.dark,
                  systemNavigationBarColor: page == 0
                      ? RemoteColors.darkBackground
                      : RemoteColors.lightBackground,
                  systemNavigationBarIconBrightness:
                      page == 0 ? Brightness.light : Brightness.dark,
                ),
              );
            },
            children: [
              // Page 1: Main Controls (Dark Theme)
              MainRemotePage(
                onSwipeToMore: () => _goToPage(1),
              ),

              // Page 2: More Controls (Light Theme)
              MoreControlsPage(
                onSwipeBack: () => _goToPage(0),
              ),
            ],
          ),

          // Non-blocking transmission badge toast on top right
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 0,
            right: 0,
            child: ListenableBuilder(
              listenable: ir,
              builder: (context, _) {
                if (!ir.isTransmitting && ir.lastSentHex == null) {
                  return const SizedBox.shrink();
                }

                if (!ir.isTransmitting) {
                  return const SizedBox.shrink();
                }

                return Center(
                  child: AnimatedOpacity(
                    opacity: ir.isTransmitting ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 150),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(210),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: RemoteColors.connectedGreen.withAlpha(120),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: RemoteColors.connectedGreen.withAlpha(80),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: RemoteColors.connectedGreen,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'IR TX: ${ir.lastSentLabel ?? ''} [${ir.lastSentHex ?? ''}]',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
