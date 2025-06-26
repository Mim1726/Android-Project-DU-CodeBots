class Recipe {
  final String title;
  final String imageName;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;
  final String? youtubeLink;
  final int? duration;
  final String? cuisine;

  Recipe({
    required this.title,
    required this.imageName,
    required this.description,
    required this.ingredients,
    required this.instructions,
    this.youtubeLink,
    this.duration,
    this.cuisine,
  });

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      title: map['title'] ?? '',
      imageName: map['imageName'] ?? '',
      description: map['description'] ?? '',
      ingredients: List<String>.from(map['ingredients'] ?? []),
      instructions: List<String>.from(map['instructions'] ?? []),
      youtubeLink: map['youtubeLink'],
      duration: map['duration'],
      cuisine: map['cuisine'],
    );
  }
}
