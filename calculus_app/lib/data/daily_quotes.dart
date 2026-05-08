/// Static catalogue of short motivational quotes. The selected quote is a
/// deterministic function of the current date so it stays constant all day.
class DailyQuotes {
  static const _quotes = <String>[
    "Mathematics is the music of reason.",
    "What we know is a drop, what we do not know is an ocean.",
    "The only way to learn mathematics is to do mathematics.",
    "Pure mathematics is, in its way, the poetry of logical ideas.",
    "Calculus is the most powerful weapon of thought yet devised.",
    "An expert is a person who has made all the mistakes — in a narrow field.",
    "Don't worry about your difficulties in mathematics. I can assure you mine are still greater.",
    "Mathematics is not about numbers, equations, computations, or algorithms: it is about understanding.",
    "Without mathematics, there's nothing you can do. Everything around you is mathematics.",
    "Logic will get you from A to B. Imagination will take you everywhere.",
    "If people do not believe that mathematics is simple, it is only because they do not realise how complicated life is.",
    "The essence of mathematics lies in its freedom.",
    "A mathematician is a device for turning coffee into theorems.",
    "Mathematics is the language with which God has written the universe.",
    "It is not knowledge, but the act of learning, that gives the greatest enjoyment.",
    "Practice isn't the thing you do once you're good. It's the thing you do that makes you good.",
    "Small steps every day beat heroic effort once a week.",
    "Patience and persistence beat raw talent.",
    "You don't have to be great to start, but you have to start to be great.",
    "The expert in anything was once a beginner.",
    "Difficult roads often lead to beautiful destinations.",
    "The student of mathematics has to develop a tolerance for ambiguity.",
    "Mathematics knows no races or geographic boundaries.",
    "There is geometry in the humming of the strings, there is music in the spacing of the spheres.",
    "Do not worry about your problems with mathematics; the universe has bigger problems.",
    "Mathematics rightly viewed possesses not only truth, but supreme beauty.",
    "If you stop, you fail. If you keep going, you eventually win.",
    "The harder you work for something, the greater you'll feel when you achieve it.",
    "Don't watch the clock; do what it does. Keep going.",
    "Tiny gains compound into enormous outcomes. Show up.",
  ];

  static String forToday() {
    final n = DateTime.now();
    final dayOfYear =
        n.difference(DateTime(n.year, 1, 1)).inDays;
    return _quotes[dayOfYear % _quotes.length];
  }
}
