import 'expense_model.dart';

class DateWiseExpenseModel {
  DateWiseExpenseModel({
    required this.date,
    required this.totalAmount,
    required this.allTransaction,
  });

  String date;
  String totalAmount;
  List<ExpenseModel> allTransaction;
}
