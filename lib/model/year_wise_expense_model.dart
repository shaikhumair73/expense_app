import 'expense_model.dart';

class YearWiseExpenseModel {
  String year;
  String totalAmount;
  List<ExpenseModel> allTransaction;

  YearWiseExpenseModel({
    required this.year,
    required this.totalAmount,
    required this.allTransaction,
  });
}
