class Food {
  Food(
      {required this.userId,
      required this.documentID,
      required this.title,
      required this.description,
      required this.cost,
      required this.image1,
      required this.image2,
      required this.image3,
      this.amount});
  final String userId;
  final String documentID;
  final String title;
  final String description;
  final double cost;
  final String image1, image2, image3;
  int? amount;
}
