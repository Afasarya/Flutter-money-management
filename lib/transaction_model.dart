import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  String description;

  @HiveField(1)
  double amount;

  @HiveField(2)
  bool isIncome;

  @HiveField(3)
  String? proofFilePath;

  Transaction({
    required this.description,
    required this.amount,
    required this.isIncome,
    this.proofFilePath,
  });
}
