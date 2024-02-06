import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wscube_expense_app/model/cat_model.dart';
import 'package:wscube_expense_app/app_constant/content_constant.dart';
import 'package:wscube_expense_app/app_constant/date_utils.dart';
import 'package:wscube_expense_app/exp_bloc/expense_bloc.dart';
import 'package:wscube_expense_app/exp_bloc/expense_event.dart';
import 'package:wscube_expense_app/exp_bloc/expense_state.dart';
import 'package:wscube_expense_app/model/year_wise_expense_model.dart';
import 'package:wscube_expense_app/provider/theme_provider.dart';
import 'package:wscube_expense_app/screens/add_expense_screen.dart';
import '../Screens/login_screen.dart';
import '../model/category_wise_expense_model.dart';
import '../model/date_wise_expense_model.dart';
import '../model/expense_model.dart';
import '../model/month_wise_expense_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  num lastBalance = 0.0;
  String selectedItem = "Date";

  @override
  void initState() {
    super.initState();
    BlocProvider.of<ExpenseBloc>(context).add(FetchAllExpenseEvent());
  }

  Future<void> _handleRefresh() async {
    return await Future.delayed(const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    var mQuery = MediaQuery.of(context);
    //var mWidth = mQuery.size.width;
    //var mHeight = mQuery.size.height;
    var isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.white10 : Colors.white,
      appBar: AppBar(
        title: const Text(
          "HomeScreen",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton(
              dropdownColor: Colors.white,
              focusColor: Colors.white,
              value: selectedItem,
              onChanged: (newValue) {
                setState(() {
                  selectedItem = newValue!;
                });
              },
              items: ["Date", "Month", "Year", "Category"].map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(
                    type,
                    style: const TextStyle(color: Colors.black),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
        backgroundColor: isDark ? Colors.grey.shade800 : Colors.blue,
      ),
      drawer: Drawer(
        backgroundColor: isDark ? Colors.black : Colors.white,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 21),
              SwitchListTile(
                title: Text(
                  "Dark Mode",
                  style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  "Control theme of App from here",
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
                value: context.watch<ThemeProvider>().themeValue,
                onChanged: (value) {
                  context.read<ThemeProvider>().themeValue = value;
                  Navigator.pop(context);
                },
              ),
              TextButton.icon(
                onPressed: () async {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (ctx) => LoginScreen()));
                  var prefs = await SharedPreferences.getInstance();
                  prefs.setBool(LoginScreen.LOGIN_PREFS_KEY, false);
                },
                icon: const Icon(
                  Icons.logout,
                  color: Colors.blue,
                ),
                label: const Text(
                  "Log out",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (_, state) {
          if (state is ExpenseLoadingState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state is ExpenseErrorState) {
            return Center(
              child: Text(state.errorMsg),
            );
          }
          if (state is ExpenseLoadedState) {
            /// This List is for Category Wise

            if (state.loadData.isNotEmpty) {
              updateBalance(state.loadData);
              if (selectedItem == "Date") {
                var dateWiseExpense = filterDateWiseExpense(state.loadData);

                return mQuery.orientation == Orientation.landscape
                    ? landscapeLayoutDate(dateWiseExpense, isDark)
                    : portraitLayoutDate(dateWiseExpense, isDark);
              } else if (selectedItem == "Month") {
                var monthWiseExpense = filterMonthWiseExpense(state.loadData);

                return mQuery.orientation == Orientation.landscape
                    ? landscapeLayoutMonth(monthWiseExpense, isDark)
                    : portraitLayoutMonth(monthWiseExpense, isDark);
              } else if (selectedItem == "Category") {
                var catWiseExpense = filterCategoryWiseExpense(state.loadData);

                return mQuery.orientation == Orientation.landscape
                    ? landscapeLayoutCategory(catWiseExpense, isDark)
                    : portraitLayoutCategory(catWiseExpense, isDark);
              } else {
                var yearWiseExpense = filterYearWiseExpense(state.loadData);

                return mQuery.orientation == Orientation.landscape
                    ? landscapeLayoutYear(yearWiseExpense, isDark)
                    : portraitLayoutYear(yearWiseExpense, isDark);
              }
            } else {
              return Center(
                child: Text(
                  "No Expense yet!!!",
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }
          }

          return Container();
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: isDark ? Colors.white : Colors.black,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (ctx) => AddExpense(
                        balance: lastBalance,
                      )));
        },
        child: Icon(
          Icons.add,
          size: 35,
          color: isDark ? Colors.black : Colors.white,
        ),
      ),
    );
  }

  /// Update Balance
  void updateBalance(List<ExpenseModel> mData) {
    var lastTransactionId = -1;

    for (ExpenseModel exp in mData) {
      if (exp.expId > lastTransactionId) {
        lastTransactionId = exp.expId;
      }
    }

    var lastExpenseBalance = mData
        .firstWhere((element) => element.expId == lastTransactionId)
        .expBal;
    lastBalance = lastExpenseBalance;
  }

  /// BalanceHeader
  Widget balanceHeader(isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? Colors.black54 : Colors.grey.shade400,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Your balance till now",
            style: TextStyle(fontSize: 27, fontWeight: FontWeight.w500),
          ),
          Text(
            "$lastBalance",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 27),
          ),
        ],
      ),
    );
  }

  /// Portrait Layout for Date Wise
  Widget portraitLayoutDate(
      List<DateWiseExpenseModel> dateWiseExpense, bool isDark) {
    return Column(
      children: [
        Expanded(
          child: balanceHeader(isDark),
        ),
        Expanded(
          flex: 2,
          child: listOfExpenseDate(dateWiseExpense),
        ),
      ],
    );
  }

  /// Landscape Layout for Date Wise
  Widget landscapeLayoutDate(
      List<DateWiseExpenseModel> dateWiseExpense, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: balanceHeader(isDark),
        ),
        Expanded(
          flex: 2,
          child: listOfExpenseDate(dateWiseExpense),
        ),
      ],
    );
  }

  /// Portrait Layout for Month Wise
  Widget portraitLayoutMonth(
      List<MonthWiseExpenseModel> monthWiseExpense, bool isDark) {
    return Column(
      children: [
        Expanded(
          child: balanceHeader(isDark),
        ),
        Expanded(
          flex: 2,
          child: listOfExpenseMonth(monthWiseExpense),
        ),
      ],
    );
  }

  /// Landscape Layout for Month Wise
  Widget landscapeLayoutMonth(
      List<MonthWiseExpenseModel> monthWiseExpense, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: balanceHeader(isDark),
        ),
        Expanded(
          flex: 2,
          child: listOfExpenseMonth(monthWiseExpense),
        ),
      ],
    );
  }

  /// Portrait Layout for Year Wise
  Widget portraitLayoutYear(
      List<YearWiseExpenseModel> yearWiseExpense, bool isDark) {
    return Column(
      children: [
        Expanded(
          child: balanceHeader(isDark),
        ),
        Expanded(
          flex: 2,
          child: listOfExpenseYear(yearWiseExpense),
        ),
      ],
    );
  }

  /// Landscape Layout for Year Wise
  Widget landscapeLayoutYear(
      List<YearWiseExpenseModel> yearWiseExpense, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: balanceHeader(isDark),
        ),
        Expanded(
          flex: 2,
          child: listOfExpenseYear(yearWiseExpense),
        ),
      ],
    );
  }

  /// Portrait Layout for Category Wise
  Widget portraitLayoutCategory(
      List<CategoryWiseExpenseModel> catWiseExpense, bool isDark) {
    return Column(
      children: [
        Expanded(
          child: balanceHeader(isDark),
        ),
        Expanded(
          flex: 2,
          child: listOfExpenseCategory(catWiseExpense),
        ),
      ],
    );
  }

  /// Landscape Layout for Category Wise
  Widget landscapeLayoutCategory(
      List<CategoryWiseExpenseModel> catWiseExpense, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: balanceHeader(isDark),
        ),
        Expanded(
          flex: 2,
          child: listOfExpenseCategory(catWiseExpense),
        ),
      ],
    );
  }

  /// List of Expense by Date Wise
  Widget listOfExpenseDate(List<DateWiseExpenseModel> dateWiseExpense) {
    var isDark = Theme.of(context).brightness == Brightness.dark;
    return LiquidPullToRefresh(
      onRefresh: _handleRefresh,
      color: Colors.purple,
      child: ListView.builder(
        itemCount: dateWiseExpense.length,
        itemBuilder: (ctx, parentIndex) {
          var eachItem = dateWiseExpense[parentIndex];

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 5, right: 5),
                child: Container(
                  color: Colors.grey.shade700,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        eachItem.date,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        eachItem.totalAmount,
                        style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              ListView.builder(
                itemCount: eachItem.allTransaction.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (_, childIndex) {
                  var eachTrans = eachItem.allTransaction[childIndex];

                  return Container(
                    margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.blue : Colors.blue.shade200,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Dismissible(
                      key: Key(eachItem.date),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        BlocProvider.of<ExpenseBloc>(context)
                            .add(DeleteExpenseEvent(id: eachTrans.expId));
                      },
                      background: Container(
                        alignment: AlignmentDirectional.centerEnd,
                        color: Colors.red,
                        child: const Center(
                          child: Icon(Icons.delete_forever),
                        ),
                      ),
                      child: ListTile(
                        leading: Image.asset(
                          AppConstants
                              .mCategories[eachTrans.expCatType].catImgPath,
                          height: 45,
                          width: 45,
                        ),
                        title: Text(
                          eachTrans.expTitle,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          eachTrans.expDesc,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        trailing: Column(
                          children: [
                            Text(
                              eachTrans.expAmt.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            Text(
                              eachTrans.expBal.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  /// List of Expense by Month Wise
  Widget listOfExpenseMonth(List<MonthWiseExpenseModel> monthWiseExpense) {
    var isDark = Theme.of(context).brightness == Brightness.dark;
    return LiquidPullToRefresh(
      onRefresh: _handleRefresh,
      color: Colors.purple,
      child: ListView.builder(
        itemCount: monthWiseExpense.length,
        itemBuilder: (ctx, parentIndex) {
          var eachItem = monthWiseExpense[parentIndex];

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 5, right: 5),
                child: Container(
                  color: Colors.grey.shade700,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        eachItem.month,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        eachItem.totalAmount,
                        style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              ListView.builder(
                itemCount: eachItem.allTransaction.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (_, childIndex) {
                  var eachTrans = eachItem.allTransaction[childIndex];

                  return Container(
                    margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.blue : Colors.blue.shade200,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Dismissible(
                      key: Key(eachItem.month),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        BlocProvider.of<ExpenseBloc>(context)
                            .add(DeleteExpenseEvent(id: eachTrans.expId));
                      },
                      background: Container(
                        alignment: AlignmentDirectional.centerEnd,
                        color: Colors.red,
                        child: const Center(
                          child: Icon(Icons.delete_forever),
                        ),
                      ),
                      child: ListTile(
                        leading: Image.asset(
                          AppConstants
                              .mCategories[eachTrans.expCatType].catImgPath,
                          height: 45,
                          width: 45,
                        ),
                        title: Text(
                          eachTrans.expTitle,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          eachTrans.expDesc,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        trailing: Column(
                          children: [
                            Text(
                              eachTrans.expAmt.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            Text(
                              eachTrans.expBal.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  /// List of Expense by Year Wise
  Widget listOfExpenseYear(List<YearWiseExpenseModel> yearWiseExpense) {
    var isDark = Theme.of(context).brightness == Brightness.dark;
    return LiquidPullToRefresh(
      onRefresh: _handleRefresh,
      color: Colors.purple,
      child: ListView.builder(
        itemCount: yearWiseExpense.length,
        itemBuilder: (ctx, parentIndex) {
          var eachItem = yearWiseExpense[parentIndex];

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 5, right: 5),
                child: Container(
                  color: Colors.grey.shade700,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        eachItem.year,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        eachItem.totalAmount,
                        style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              ListView.builder(
                itemCount: eachItem.allTransaction.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (_, childIndex) {
                  var eachTrans = eachItem.allTransaction[childIndex];

                  return Container(
                    margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.blue : Colors.blue.shade200,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Dismissible(
                      key: Key(eachItem.year),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        BlocProvider.of<ExpenseBloc>(context)
                            .add(DeleteExpenseEvent(id: eachTrans.expId));
                      },
                      background: Container(
                        alignment: AlignmentDirectional.centerEnd,
                        color: Colors.red,
                        child: const Center(
                          child: Icon(Icons.delete_forever),
                        ),
                      ),
                      child: ListTile(
                        leading: Image.asset(
                          AppConstants
                              .mCategories[eachTrans.expCatType].catImgPath,
                          height: 45,
                          width: 45,
                        ),
                        title: Text(
                          eachTrans.expTitle,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          eachTrans.expDesc,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        trailing: Column(
                          children: [
                            Text(
                              eachTrans.expAmt.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            Text(
                              eachTrans.expBal.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  /// List of Expense by Category Wise
  Widget listOfExpenseCategory(List<CategoryWiseExpenseModel> catWiseExpense) {
    var isDark = Theme.of(context).brightness == Brightness.dark;
    return LiquidPullToRefresh(
      onRefresh: _handleRefresh,
      color: Colors.purple,
      child: ListView.builder(
        itemCount: catWiseExpense.length,
        itemBuilder: (ctx, parentIndex) {
          var eachItem = catWiseExpense[parentIndex];

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 5, right: 5),
                child: Container(
                  color: Colors.grey.shade700,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        eachItem.catName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        eachItem.totalAmount,
                        style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              ListView.builder(
                itemCount: eachItem.allTransaction.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (_, childIndex) {
                  var eachTrans = eachItem.allTransaction[childIndex];

                  return Container(
                    margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.blue : Colors.blue.shade200,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Dismissible(
                      key: Key(eachItem.catName),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        BlocProvider.of<ExpenseBloc>(context)
                            .add(DeleteExpenseEvent(id: eachTrans.expId));
                      },
                      background: Container(
                        alignment: AlignmentDirectional.centerEnd,
                        color: Colors.red,
                        child: const Center(
                          child: Icon(Icons.delete_forever),
                        ),
                      ),
                      child: ListTile(
                        leading: Image.asset(
                          AppConstants
                              .mCategories[eachTrans.expCatType].catImgPath,
                          height: 45,
                          width: 45,
                        ),
                        title: Text(
                          eachTrans.expTitle,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          eachTrans.expDesc,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        trailing: Column(
                          children: [
                            Text(
                              eachTrans.expAmt.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            Text(
                              eachTrans.expBal.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  /// Filtration by Date Wise
  List<DateWiseExpenseModel> filterDateWiseExpense(
      List<ExpenseModel> allExpense) {
    List<DateWiseExpenseModel> dateWiseExpenses = [];

    /// This is for each Expense
    var listUniqueDate = [];

    for (ExpenseModel eachExp in allExpense) {
      var mDate = DateTimeUtils.getFormattedDateFromMilli(
          int.parse(eachExp.expTimeStamp));

      if (!listUniqueDate.contains(mDate)) {
        /// Not contains
        listUniqueDate.add(mDate);
      }
    }

    /// This is for each Date
    for (String date in listUniqueDate) {
      List<ExpenseModel> eachDateExp = [];
      var totalAmt = 0.0;

      for (ExpenseModel eachExp in allExpense) {
        var mDate = DateTimeUtils.getFormattedDateFromMilli(
            int.parse(eachExp.expTimeStamp));

        if (date == mDate) {
          eachDateExp.add(eachExp);

          if (eachExp.expType == 0) {
            /// Debit
            totalAmt -= eachExp.expAmt;
          } else {
            /// Credit
            totalAmt += eachExp.expAmt;
          }
        }
      }

      /// for Today
      var formattedTodayDate =
          DateTimeUtils.getFormattedDateFromDateTime(DateTime.now());

      if (formattedTodayDate == date) {
        date = "Today";
      }

      /// for Yesterday
      var formattedYesterdayDate = DateTimeUtils.getFormattedDateFromDateTime(
          DateTime.now().subtract(const Duration(days: 1)));

      if (formattedYesterdayDate == date) {
        date = "Yesterday";
      }

      dateWiseExpenses.add(DateWiseExpenseModel(
        date: date,
        totalAmount: totalAmt.toString(),
        allTransaction: eachDateExp,
      ));
    }

    return dateWiseExpenses;
  }

  /// Filtration of Month Wise Expense
  List<MonthWiseExpenseModel> filterMonthWiseExpense(
      List<ExpenseModel> allExpense) {
    List<MonthWiseExpenseModel> monthWiseExpense = [];

    var listUniqueMonth = [];

    for (ExpenseModel eachExp in allExpense) {
      var mMonth = DateTimeUtils.getFormattedMonthFromMilli(
          int.parse(eachExp.expTimeStamp));

      if (!listUniqueMonth.contains(mMonth)) {
        listUniqueMonth.add(mMonth);
      }
    }

    for (String month in listUniqueMonth) {
      List<ExpenseModel> eachMonthExp = [];
      var totalAmt = 0.0;

      for (ExpenseModel eachExp in allExpense) {
        var mMonth = DateTimeUtils.getFormattedMonthFromMilli(
            int.parse(eachExp.expTimeStamp));

        if (month == mMonth) {
          eachMonthExp.add(eachExp);

          if (eachExp.expType == 0) {
            totalAmt -= eachExp.expAmt;
          } else {
            totalAmt += eachExp.expAmt;
          }
        }
      }

      /*/// for Today
      var formattedTodayDate =
          DateTimeUtils.getFormattedMonthFromDateTime(DateTime.now());

      if (formattedTodayDate == month) {
        month = "This Month";
      }

      /// for Yesterday
      var formattedYesterdayDate = DateTimeUtils.getFormattedMonthFromDateTime(
          DateTime.now().subtract(const Duration(days: 30)));

      if (formattedYesterdayDate == month) {
        month = "Previous Month";
      }*/

      monthWiseExpense.add(MonthWiseExpenseModel(
        month: month,
        totalAmount: totalAmt.toString(),
        allTransaction: eachMonthExp,
      ));
    }

    return monthWiseExpense;
  }

  /// Filtration by Year Wise
  List<YearWiseExpenseModel> filterYearWiseExpense(
      List<ExpenseModel> allExpense) {
    List<YearWiseExpenseModel> yearWiseExpense = [];

    var listUniqueYear = [];

    for (ExpenseModel eachExp in allExpense) {
      var mYear = DateTimeUtils.getFormattedYearFromMilli(
          int.parse(eachExp.expTimeStamp));

      if (!listUniqueYear.contains(mYear)) {
        listUniqueYear.add(mYear);
      }
    }

    for (String year in listUniqueYear) {
      List<ExpenseModel> eachMonthExp = [];
      var totalAmt = 0.0;

      for (ExpenseModel eachExp in allExpense) {
        var mYear = DateTimeUtils.getFormattedYearFromMilli(
            int.parse(eachExp.expTimeStamp));

        if (year == mYear) {
          eachMonthExp.add(eachExp);

          if (eachExp.expType == 0) {
            totalAmt -= eachExp.expAmt;
          } else {
            totalAmt += eachExp.expAmt;
          }
        }
      }

      /* /// for Today
      var formattedTodayDate =
          DateTimeUtils.getFormattedYearFromDateTime(DateTime.now());

      if (formattedTodayDate == year) {
        year = "This Year";
      }

      /// for Yesterday
      var formattedYesterdayDate = DateTimeUtils.getFormattedYearFromDateTime(
          DateTime.now().subtract(const Duration(days: 366)));

      if (formattedYesterdayDate == year) {
        year = "Previous Year";
      }*/

      yearWiseExpense.add(YearWiseExpenseModel(
        year: year,
        totalAmount: totalAmt.toString(),
        allTransaction: eachMonthExp,
      ));
    }

    return yearWiseExpense;
  }

  /// Filtration by Category Wise
  List<CategoryWiseExpenseModel> filterCategoryWiseExpense(
      List<ExpenseModel> allExpense) {
    List<CategoryWiseExpenseModel> catWiseData = [];
    for (CategoryModel eachCat in AppConstants.mCategories) {
      var catName = eachCat.catTitle;
      var eachCatAmt = 0.0;
      List<ExpenseModel> catTrans = [];

      for (ExpenseModel eachExp in allExpense) {
        if ((eachExp.expCatType + 1) == eachCat.catId) {
          catTrans.add(eachExp);

          if (eachExp.expType == 0) {
            ///debit
            eachCatAmt -= eachExp.expAmt;
          } else {
            ///credit
            eachCatAmt += eachExp.expAmt;
          }
        }
      }

      if (catTrans.isNotEmpty) {
        catWiseData.add(CategoryWiseExpenseModel(
            catName: catName,
            totalAmount: eachCatAmt.toString(),
            allTransaction: catTrans));

        /*listOrdinalData.add(OrdinalData(
            domain: catName,
            measure: eachCatAmt.isNegative ? eachCatAmt * -1 : eachCatAmt,
            color: Colors.blue));*/
      }
    }
    return catWiseData;
    //listOrdinalGrp.add(OrdinalGroup(id: "1", data: listOrdinalData));
  }
}
