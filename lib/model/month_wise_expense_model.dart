import 'expense_model.dart';

class MonthWiseExpenseModel {
  String month;
  String totalAmount;
  List<ExpenseModel> allTransaction;

  MonthWiseExpenseModel({
    required this.month,
    required this.totalAmount,
    required this.allTransaction,
  });
}
