python3 <<'PY'
from pathlib import Path

p = Path("lib/main.dart")
s = p.read_text()

s = s.replace("""enum TaskType {
  tap,
  redSquare,
  hold,
  blueCircles,
  findNumber,
  dragBox,
}""", """enum TaskType {
  tap,
  redSquare,
  hold,
  blueCircles,
  findNumber,
  dragBox,
}

enum Difficulty {
  easy,
  normal,
  hard,
}""")

start = s.index("class GameTask {")
end = s.index("class HomeScreen", start)

new_block = r'''class GameTask {
  final TaskType type;
  final Difficulty difficulty;
  final String en;
  final String tr;
  final int target;
  final int seconds;

  const GameTask(
    this.type,
    this.difficulty,
    this.en,
    this.tr,
    this.target,
    this.seconds,
  );
}

const List<GameTask> taskPool = [
  // EASY - 10 seconds
  GameTask(TaskType.tap, Difficulty.easy, 'Tap 10 times', '10 kez dokun', 10, 10),
  GameTask(TaskType.tap, Difficulty.easy, 'Tap 15 times', '15 kez dokun', 15, 10),
  GameTask(TaskType.tap, Difficulty.easy, 'Tap 20 times', '20 kez dokun', 20, 10),
  GameTask(TaskType.redSquare, Difficulty.easy, 'Tap the red square', 'Kırmızı kareye dokun', 1, 10),
  GameTask(TaskType.hold, Difficulty.easy, 'Hold for 2 seconds', '2 saniye basılı tut', 2, 10),
  GameTask(TaskType.blueCircles, Difficulty.easy, 'Tap 3 blue circles', '3 mavi daireye dokun', 3, 10),
  GameTask(TaskType.findNumber, Difficulty.easy, 'Find number 5', '5 rakamını bul', 1, 10),
  GameTask(TaskType.dragBox, Difficulty.easy, 'Drag box to target', 'Kutuyu hedefe sürükle', 1, 10),
  GameTask(TaskType.tap, Difficulty.easy, 'Tap 25 times', '25 kez dokun', 25, 10),
  GameTask(TaskType.hold, Difficulty.easy, 'Hold for 3 seconds', '3 saniye basılı tut', 3, 10),

  // NORMAL - 8 seconds
  GameTask(TaskType.tap, Difficulty.normal, 'Tap 30 times', '30 kez dokun', 30, 8),
  GameTask(TaskType.tap, Difficulty.normal, 'Tap 35 times', '35 kez dokun', 35, 8),
  GameTask(TaskType.tap, Difficulty.normal, 'Tap 40 times', '40 kez dokun', 40, 8),
  GameTask(TaskType.redSquare, Difficulty.normal, 'Catch the red square', 'Kırmızı kareyi yakala', 1, 8),
  GameTask(TaskType.hold, Difficulty.normal, 'Hold for 4 seconds', '4 saniye basılı tut', 4, 8),
  GameTask(TaskType.blueCircles, Difficulty.normal, 'Tap 5 blue circles', '5 mavi daireye dokun', 5, 8),
  GameTask(TaskType.findNumber, Difficulty.normal, 'Find number 5 fast', '5 rakamını hızlı bul', 1, 8),
  GameTask(TaskType.dragBox, Difficulty.normal, 'Drag fast', 'Hızlı sürükle', 1, 8),

  // HARD - 6 seconds
  GameTask(TaskType.tap, Difficulty.hard, 'Tap 45 times', '45 kez dokun', 45, 6),
  GameTask(TaskType.tap, Difficulty.hard, 'Tap 50 times', '50 kez dokun', 50, 6),
  GameTask(TaskType.tap, Difficulty.hard, 'Tap 55 times', '55 kez dokun', 55, 6),
  GameTask(TaskType.redSquare, Difficulty.hard, 'Hit the red square', 'Kırmızı kareye vur', 1, 6),
  GameTask(TaskType.hold, Difficulty.hard, 'Hold for 5 seconds', '5 saniye basılı tut', 5, 6),
  GameTask(TaskType.blueCircles, Difficulty.hard, 'Tap 6 blue circles', '6 mavi daireye dokun', 6, 6),
  GameTask(TaskType.findNumber, Difficulty.hard, 'Find 5 under pressure', 'Baskı altında 5’i bul', 1, 6),
  GameTask(TaskType.dragBox, Difficulty.hard, 'Drag before time ends', 'Süre bitmeden sürükle', 1, 6),
];

'''
s = s[:start] + new_block + s[end:]

s = s.replace(
"currentTask = taskPool[random.nextInt(taskPool.length)];\n      timeLeft = max(5, 10 - (score ~/ 10));",
"""final difficulty = score < 10
          ? Difficulty.easy
          : score < 18
              ? Difficulty.normal
              : Difficulty.hard;

      final availableTasks =
          taskPool.where((task) => task.difficulty == difficulty).toList();

      currentTask = availableTasks[random.nextInt(availableTasks.length)];
      timeLeft = currentTask.seconds;"""
)

s = s.replace(
"tr ? 'Skor: $score' : 'Score: $score',",
"tr ? 'Skor: $score | Süre: ${currentTask.seconds} sn' : 'Score: $score | ${currentTask.seconds} sec',"
)

p.write_text(s)
PY

flutter analyze
