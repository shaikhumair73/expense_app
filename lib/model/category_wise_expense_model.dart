import 'expense_model.dart';

class CategoryWiseExpenseModel {
  String catName;
  String totalAmount;
  List<ExpenseModel> allTransaction;

  CategoryWiseExpenseModel({
    required this.catName,
    required this.totalAmount,
    required this.allTransaction,
  });
}
