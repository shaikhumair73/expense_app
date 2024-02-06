import 'package:wscube_expense_app/model/expense_model.dart';

abstract class ExpenseEvent {}

class AddExpenseEvent extends ExpenseEvent {
  AddExpenseEvent({required this.newExpense});

  ExpenseModel newExpense;
}

class FetchAllExpenseEvent extends ExpenseEvent {}

class UpdateExpenseEvent extends ExpenseEvent {
  UpdateExpenseEvent({required this.updateExpense, required this.index});

  ExpenseModel updateExpense;
  int index;
}

class DeleteExpenseEvent extends ExpenseEvent {
  DeleteExpenseEvent({required this.id});

  int id;
}
