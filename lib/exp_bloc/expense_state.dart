import '../model/expense_model.dart';

abstract class ExpenseState {}

class ExpenseInitialState extends ExpenseState {}

class ExpenseLoadingState extends ExpenseState {}

class ExpenseLoadedState extends ExpenseState {
  ExpenseLoadedState({required this.loadData});

  List<ExpenseModel> loadData;
}

class ExpenseErrorState extends ExpenseState {
  ExpenseErrorState({required this.errorMsg});

  String errorMsg;
}
