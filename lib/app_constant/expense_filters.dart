/// List Expense Date Wise
/*
Widget listOfExpense(List<DateWiseExpenseModel> dateWiseExpense) {
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
}*/

/// Portrait Layout for Date Wise
/*Widget portraitLayout(
      List<DateWiseExpenseModel> dateWiseExpense, bool isDark) {
    return Column(
      children: [
        Expanded(
          child: balanceHeader(isDark),
        ),
        Expanded(
          flex: 2,
          child: listOfExpense(dateWiseExpense),
        ),
      ],
    );
  }*/

/// Landscape Layout for Date Wise
/*
Widget landscapeLayout(
    List<DateWiseExpenseModel> dateWiseExpense, bool isDark) {
  return Row(
    children: [
      Expanded(
        child: balanceHeader(isDark),
      ),
      Expanded(
        flex: 2,
        child: listOfExpense(dateWiseExpense),
      ),
    ],
  );
}*/
