class NebulaUser {
  final String UserId;
  final String Name;
  final String Email;
  final String UserType;
  final String Team;
  final String SubType;

  NebulaUser({required this.UserId,
    required this.Name,
    required this.Email,
    required this.UserType,
    required this.Team,
    required this.SubType,});
}

class NebulaSubscription {
  final String Name;
  final double Price;

  NebulaSubscription({
    required this.Name,
    required this.Price,});
}

class NebulaTeamSubscriptions {
  final String Name;
  final int Quantity;
  final double Price;

  NebulaTeamSubscriptions({
    required this.Name,
    required this.Quantity,
    required this.Price,});
}