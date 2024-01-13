
import 'dart:math';

class EmojiProvider {

  static const _allConsideredAnimalEmojis = ["🐶", "🐱", "🐭", "🐹", "🐰",
    "🦊", "🐻", "🐼", "🐨", "🐯", "🦁", "🐮", "🐷", "🐸", "🐒", "🐔",
    "🐧", "🐦", "🐥", "🪿", "🦆", "🦅", "🦉", "🦇", "🐺", "🐗", "🐴", "🦄",
    "🫎", "🐝", "🐛", "🦋", "🐌", "🐜", "🪲", "🪳", "🦗", "🐢", "🐍", "🦎",
    "🦖", "🦕", "🦑", "🪼", "🦞", "🦐", "🦀", "🐡", "🐠", "🐟", "🐬", "🐳",
    "🐋", "🦈", "🦭", "🐊", "🦧", "🐘", "🦣", "🦬", "🦒", "🐫", "🐐", "🦌",
    "🐕", "🐓", "🦤", "🦚", "🦜", "🦢", "🐿️", "🦫", "🦨"];

  static final EmojiProvider instance = EmojiProvider._();

  EmojiProvider._() {
    _allShuffledAnimalEmojis = _allConsideredAnimalEmojis.toList()..shuffle(Random(0));
  }

  late final List<String> _allShuffledAnimalEmojis;

  String getEmojiForDailyMonthCompletion(DateTime date) {
    final year = date.year;
    final month = date.month;
    final emojiIndex = (year * 12 + month) % _allShuffledAnimalEmojis.length;
    return _allShuffledAnimalEmojis[emojiIndex];
  }
}
