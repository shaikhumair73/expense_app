import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wscube_expense_app/DataBase/app_db.dart';
import 'package:wscube_expense_app/exp_bloc/expense_event.dart';
import 'package:wscube_expense_app/exp_bloc/expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  AppDataBase db;

  ExpenseBloc({required this.db}) : super(ExpenseInitialState()) {
    /// Add Expense
    on<AddExpenseEvent>((event, emit) async {
      emit(ExpenseLoadingState());
      var check = await db.addExpense(event.newExpense);
      if (check) {
        var mExp = await db.fetchAllExpense();
        emit(ExpenseLoadedState(loadData: mExp));
      } else {
        emit(ExpenseErrorState(errorMsg: "Expense not added!!!"));
      }
    });

    /// Fetch Expense
    on<FetchAllExpenseEvent>((event, emit) async {
      emit(ExpenseLoadingState());
      var mExp = await db.fetchAllExpense();
      emit(ExpenseLoadedState(loadData: mExp));
    });

    /// Update Expense
    on<UpdateExpenseEvent>((event, emit) async {
      emit(ExpenseLoadingState());
      db.updateExpense(event.updateExpense);
      var mExp = await db.fetchAllExpense();
      emit(ExpenseLoadedState(loadData: mExp));
    });

    /// Delete Expense
    on<DeleteExpenseEvent>((event, emit) async {
      emit(ExpenseLoadingState());
      var check = await db.deleteExpense(event.id);
      if (check) {
        var mExp = await db.fetchAllExpense();
        emit(ExpenseLoadedState(loadData: mExp));
      } else {
        emit(ExpenseErrorState(errorMsg: "Expense not added!!!"));
      }
    });
  }
}
