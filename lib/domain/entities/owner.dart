class Owner {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? avatar;
  final bool isProfileComplete;
  final int bedLimit;
  final String plan;

  const Owner({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.avatar,
    this.isProfileComplete = false,
    this.bedLimit = 10,
    this.plan = 'free',
  });
}
