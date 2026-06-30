import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await MobileAds.instance.initialize();
  }
  runApp(const TenSecRushApp());
}


class AdIds {
  static String get banner => kReleaseMode
      ? 'ca-app-pub-7094485651472008/6547815794'
      : 'ca-app-pub-3940256099942544/6300978111';

  static String get interstitial => kReleaseMode
      ? 'ca-app-pub-7094485651472008/3454748591'
      : 'ca-app-pub-3940256099942544/1033173712';

  static String get rewarded => kReleaseMode
      ? 'ca-app-pub-7094485651472008/8392370188'
      : 'ca-app-pub-3940256099942544/5224354917';
}

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _bannerAd = BannerAd(
        adUnitId: AdIds.banner,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (_) => setState(() => _loaded = true),
          onAdFailedToLoad: (ad, error) => ad.dispose(),
        ),
      )..load();
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || !_loaded || _bannerAd == null) {
      return const SizedBox(height: 0);
    }
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}

class TenSecRushApp extends StatelessWidget {
  const TenSecRushApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '10 Sec Rush',
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

bool isTr(BuildContext context) =>
    WidgetsBinding.instance.platformDispatcher.locale.languageCode == 'tr';

enum TaskType {
  tap,
  redSquare,
  hold,
  blueCircles,
  findNumber,
  dragBox,
}

class GameTask {
  final TaskType type;
  final String en;
  final String tr;
  final int target;

  const GameTask(this.type, this.en, this.tr, this.target);
}

const List<GameTask> easyTasks = [
  GameTask(TaskType.tap, 'Tap 15 times', '15 kez dokun', 15),
  GameTask(TaskType.tap, 'Tap 20 times', '20 kez dokun', 20),
  GameTask(TaskType.redSquare, 'Tap the red square', 'Kırmızı kareye dokun', 1),
  GameTask(TaskType.blueCircles, 'Tap 2 blue circles', '2 mavi daireye dokun', 2),
  GameTask(TaskType.hold, 'Hold for 3 seconds', '3 saniye basılı tut', 3),
  GameTask(TaskType.findNumber, 'Find number 5', '5 rakamını bul', 5),
  GameTask(TaskType.dragBox, 'Drag box to target', 'Kutuyu hedefe sürükle', 1),
];

const List<GameTask> normalTasks = [
  GameTask(TaskType.tap, 'Tap 25 times', '25 kez dokun', 25),
  GameTask(TaskType.tap, 'Tap 30 times', '30 kez dokun', 30),
  GameTask(TaskType.blueCircles, 'Tap 3 blue circles', '3 mavi daireye dokun', 3),
  GameTask(TaskType.blueCircles, 'Tap 4 blue circles', '4 mavi daireye dokun', 4),
  GameTask(TaskType.hold, 'Hold for 4 seconds', '4 saniye basılı tut', 4),
  GameTask(TaskType.findNumber, 'Find number 7', '7 rakamını bul', 7),
  GameTask(TaskType.redSquare, 'Tap the red square fast', 'Kırmızı kareye hızlı dokun', 1),
];

const List<GameTask> hardTasks = [
  GameTask(TaskType.tap, 'Tap 35 times', '35 kez dokun', 35),
  GameTask(TaskType.tap, 'Tap 40 times', '40 kez dokun', 40),
  GameTask(TaskType.blueCircles, 'Tap 5 blue circles', '5 mavi daireye dokun', 5),
  GameTask(TaskType.hold, 'Hold for 4 seconds', '4 saniye basılı tut', 4),
  GameTask(TaskType.findNumber, 'Find number 9', '9 rakamını bul', 9),
  GameTask(TaskType.redSquare, 'Tiny red square', 'Küçük kırmızı kare', 1),
];


String leagueName(int points, bool tr) {
  if (points >= 5000) return tr ? 'Efsane' : 'Legend';
  if (points >= 2500) return tr ? 'Elmas' : 'Diamond';
  if (points >= 1000) return tr ? 'Altın' : 'Gold';
  if (points >= 400) return tr ? 'Gümüş' : 'Silver';
  if (points >= 100) return tr ? 'Bronz' : 'Bronze';
  return tr ? 'Çaylak' : 'Rookie';
}

int fakeRank(int points) {
  final rank = 1000 - (points ~/ 5);
  return rank < 1 ? 1 : rank;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int bestScore = 0;
  int totalScore = 0;

  @override
  void initState() {
    super.initState();
    loadBest();
  }

  Future<void> loadBest() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      bestScore = prefs.getInt('bestScore') ?? 0;
      totalScore = prefs.getInt('totalScore') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tr = isTr(context);

    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: const SafeArea(child: BannerAdWidget()),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '10 SEC RUSH',
              style: TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              tr ? 'En İyi Skor: $bestScore' : 'Best Score: $bestScore',
              style: const TextStyle(color: Colors.white70, fontSize: 22),
            ),
            const SizedBox(height: 10),
            Text(
              tr ? 'Toplam Puan: $totalScore' : 'Total Points: $totalScore',
              style: const TextStyle(color: Colors.white70, fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              tr ? 'Lig: ${leagueName(totalScore, true)}' : 'League: ${leagueName(totalScore, false)}',
              style: const TextStyle(color: Colors.amber, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              tr ? 'Sıralama: #${fakeRank(totalScore)}' : 'Rank: #${fakeRank(totalScore)}',
              style: const TextStyle(color: Colors.white54, fontSize: 18),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GameScreen()),
                );
                loadBest();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
              ),
              child: Text(
                tr ? 'BAŞLA' : 'START',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final Random random = Random();

  late GameTask currentTask;
  Timer? timer;
  Timer? holdTimer;
  Timer? numberShuffleTimer;

  int score = 0;
  int bestScore = 0;
  int totalScore = 0;
  int timeLeft = 10;
  int progress = 0;
  bool gameOver = false;

  double redX = 0.4;
  double redY = 0.4;

  List<Offset> blueCircles = [];
  List<int> numbers = [];

  Offset boxPosition = const Offset(80, 420);
  final Offset targetPosition = const Offset(250, 420);
  bool draggingDone = false;

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  int _gameOverCount = 0;

  @override
  void initState() {
    super.initState();
    loadBest();
    nextTask();
    _loadInterstitialAd();
    _loadRewardedAd();
  }

  Future<void> loadBest() async {
    final prefs = await SharedPreferences.getInstance();
    bestScore = prefs.getInt('bestScore') ?? 0;
      totalScore = prefs.getInt('totalScore') ?? 0;
  }

  Future<void> saveTotalScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalScore', totalScore);
  }

  Future<void> saveBest() async {
    if (score > bestScore) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('bestScore', score);
      bestScore = score;
    }
  }

  void nextTask() {
    timer?.cancel();
    holdTimer?.cancel();
    numberShuffleTimer?.cancel();

    setState(() {
      final pool = score >= 25 ? hardTasks : (score >= 10 ? normalTasks : easyTasks);
      currentTask = pool[random.nextInt(pool.length)];
      if (score >= 25) {
      timeLeft = 6;
    } else if (score >= 10) {
      timeLeft = 8;
    } else {
      timeLeft = 10;
    }
      progress = 0;
      gameOver = false;
      draggingDone = false;
      boxPosition = const Offset(80, 420);

      redX = random.nextDouble() * 0.7 + 0.1;
      redY = random.nextDouble() * 0.5 + 0.25;

      blueCircles = List.generate(
        5,
        (_) => Offset(
          random.nextDouble() * 300 + 30,
          random.nextDouble() * 400 + 180,
        ),
      );

      numbers = List.generate(9, (i) => i + 1)..shuffle(random);
    });

    if (currentTask.type == TaskType.findNumber) {
      numberShuffleTimer?.cancel();
      numberShuffleTimer = Timer.periodic(const Duration(seconds: 2), (_) {
        if (!mounted || gameOver || currentTask.type != TaskType.findNumber) return;
        setState(() {
          numbers = List.generate(9, (i) => i + 1)..shuffle(random);
        });
      });
    }

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || gameOver) return;
      setState(() => timeLeft--);
      if (timeLeft <= 0) finishGame();
    });
  }

  void successTask() {
    numberShuffleTimer?.cancel();
    if (gameOver) return;

    setState(() {
      score++;
      totalScore++;
    });
    saveTotalScore();

    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted && !gameOver) nextTask();
    });
  }

  void finishGame() async {
    timer?.cancel();
    holdTimer?.cancel();

    await saveBest();

    if (!mounted) return;

    setState(() {
      gameOver = true;
    });

    _showInterstitialIfReady();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        final tr = isTr(context);
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text(
            tr ? 'KAYBETTİN!' : 'GAME OVER!',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.redAccent, fontSize: 30),
          ),
          content: Text(
            tr
                ? 'Skor: $score\nEn İyi: $bestScore\nToplam: $totalScore\nLig: ${leagueName(totalScore, true)}\nSıralama: #${fakeRank(totalScore)}'
                : 'Score: $score\nBest: $bestScore\nTotal: $totalScore\nLeague: ${leagueName(totalScore, false)}\nRank: #${fakeRank(totalScore)}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 22),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  score = 0;
                });
                nextTask();
              },
              child: Text(tr ? 'TEKRAR OYNA' : 'TRY AGAIN'),
            ),
            TextButton(
              onPressed: () {
                _showRewardedContinue();
              },
              child: Text(tr ? 'REKLAM İZLE DEVAM ET' : 'WATCH AD CONTINUE'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text(tr ? 'ANA MENÜ' : 'HOME'),
            ),
          ],
        );
      },
    );
  }

  void handleTap() {
    if (gameOver) return;

    if (currentTask.type == TaskType.tap) {
      if (progress >= currentTask.target) return;
      setState(() {
        progress++;
        if (progress > currentTask.target) progress = currentTask.target;
      });
      if (progress >= currentTask.target) successTask();
    }
  }

  void _loadInterstitialAd() {
    if (kIsWeb) return;
    InterstitialAd.load(
      adUnitId: AdIds.interstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) => _interstitialAd = null,
      ),
    );
  }

  void _showInterstitialIfReady() {
    _gameOverCount++;
    if (_gameOverCount % 3 != 0) return;
    final ad = _interstitialAd;
    if (ad == null) return;

    _interstitialAd = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadInterstitialAd();
      },
    );
    ad.show();
  }

  void _loadRewardedAd() {
    if (kIsWeb) return;
    RewardedAd.load(
      adUnitId: AdIds.rewarded,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (error) => _rewardedAd = null,
      ),
    );
  }

  void _showRewardedContinue() {
    final ad = _rewardedAd;
    if (ad == null) return;

    _rewardedAd = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadRewardedAd();
      },
    );

    ad.show(
      onUserEarnedReward: (ad, reward) {
        Navigator.pop(context);
        setState(() {
          gameOver = false;
        });
        nextTask();
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    holdTimer?.cancel();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    super.dispose();
  }

  
  void shuffleNumbers() {
    numbers = List.generate(9, (index) => index + 1)..shuffle(random);
  }

  void startNumberShuffleTimer() {
    numberShuffleTimer?.cancel();
    if (currentTask.type != TaskType.findNumber) return;

    numberShuffleTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted || gameOver || currentTask.type != TaskType.findNumber) return;
      setState(() {
        numbers = List.generate(9, (index) => index + 1)..shuffle(random);
      });
    });
  }

@override
  Widget build(BuildContext context) {
    final tr = isTr(context);
    final title = tr ? currentTask.tr : currentTask.en;

    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: const SafeArea(child: BannerAdWidget()),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: currentTask.type == TaskType.tap ? handleTap : null,
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tr ? 'Skor: $score' : 'Score: $score',
                      style: const TextStyle(color: Colors.white70, fontSize: 22),
                    ),
                    Text(
                      '$timeLeft',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                top: 82,
                left: 18,
                right: 18,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 25),
                    if (currentTask.type == TaskType.tap ||
                        currentTask.type == TaskType.hold ||
                        currentTask.type == TaskType.blueCircles)
                      Text(
                        currentTask.type == TaskType.hold
                            ? '${(progress / 2).floor()} / ${currentTask.target}'
                            : '$progress / ${currentTask.target}',
                        style: const TextStyle(color: Colors.white70, fontSize: 28),
                      ),
                  ],
                ),
              ),

              if (currentTask.type == TaskType.redSquare)
                Positioned(
                  left: MediaQuery.of(context).size.width * redX,
                  top: MediaQuery.of(context).size.height * redY,
                  child: GestureDetector(
                    onTap: successTask,
                    child: Container(
                      width: 80,
                      height: 80,
                      color: Colors.red,
                    ),
                  ),
                ),

              if (currentTask.type == TaskType.hold)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 220),
                    child: GestureDetector(
                      onTapDown: (_) {
                        holdTimer?.cancel();
                        setState(() => progress = 0);
                        holdTimer = Timer.periodic(
                          const Duration(milliseconds: 500),
                          (_) {
                            if (!mounted || gameOver) return;
                            setState(() => progress++);
                            if (progress >= currentTask.target * 2) {
                              holdTimer?.cancel();
                              successTask();
                            }
                          },
                        );
                      },
                      onTapUp: (_) {
                        holdTimer?.cancel();
                        if (!gameOver && progress < currentTask.target * 2) {
                          setState(() => progress = 0);
                        }
                      },
                      onTapCancel: () {
                        holdTimer?.cancel();
                        if (!gameOver && progress < currentTask.target * 2) {
                          setState(() => progress = 0);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 25,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              tr ? 'BASILI TUT' : 'HOLD',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${(progress / 2).floor()} / ${currentTask.target}',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              if (currentTask.type == TaskType.blueCircles)
                ...blueCircles.toList().map(
                  (circle) => Positioned(
                    left: circle.dx,
                    top: circle.dy,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          blueCircles.remove(circle);
                          progress++;

                          final size = MediaQuery.of(context).size;
                          blueCircles = blueCircles
                              .map((_) => Offset(
                                    40 + random.nextDouble() * (size.width - 100),
                                    120 + random.nextDouble() * (size.height - 260),
                                  ))
                              .toList();
                        });
                        if (progress >= currentTask.target) successTask();
                      },
                      child: Container(
                        width: 55,
                        height: 55,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),

              if (currentTask.type == TaskType.findNumber)
                ...List.generate(numbers.length, (index) {
                  final number = numbers[index];
                  return Positioned(
                    left: 54 + (index % 3) * 96,
                    top: 235 + (index ~/ 3) * 82,
                    child: GestureDetector(
                      onTap: () {
                        if (number == currentTask.target) {
                          successTask();
                        } else {
                          finishGame();
                        }
                      },
                      child: Container(
                        width: 64,
                        height: 64,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          '$number',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }),

              if (currentTask.type == TaskType.dragBox)
                Positioned(
                  left: targetPosition.dx,
                  top: targetPosition.dy,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.greenAccent, width: 4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

              if (currentTask.type == TaskType.dragBox)
                Positioned(
                  left: boxPosition.dx,
                  top: boxPosition.dy,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        boxPosition += details.delta;
                      });

                      final dx = boxPosition.dx - targetPosition.dx;
                      final dy = boxPosition.dy - targetPosition.dy;
                      final distance = sqrt(dx * dx + dy * dy);

                      if (distance < 45 && !draggingDone) {
                        draggingDone = true;
                        successTask();
                      }
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}