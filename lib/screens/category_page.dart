import 'package:d_chart/commons/config_render.dart';
import 'package:d_chart/commons/data_model.dart';
import 'package:d_chart/ordinal/bar.dart';
import 'package:d_chart/ordinal/pie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wscube_expense_app/model/category_wise_expense_model.dart';

import '../app_constant/content_constant.dart';
import '../exp_bloc/expense_bloc.dart';
import '../exp_bloc/expense_event.dart';
import '../model/cat_model.dart';
import '../model/expense_model.dart';

class StatsPage extends StatefulWidget {
  List<ExpenseModel> mData;

  StatsPage({required this.mData});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  List<CategoryWiseExpenseModel> catWiseData = [];
  List<OrdinalGroup> listOrdinalGrp = [];
  List<OrdinalData> listOrdinalData = [];

  @override
  void initState() {
    super.initState();
    filterCatWiseData();
  }

  @override
  Widget build(BuildContext context) {
    var isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        title: const Text(
          "Category Wise Expense",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: DChartBarO(
                fillColor: (_, __, index) {
                  if (index! % 2 == 0) {
                    return Colors.grey;
                  } else {
                    return Colors.blue;
                  }
                },
                groupList: listOrdinalGrp,
              ),
            ),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: DChartPieO(
                data: listOrdinalData,
                configRenderPie: const ConfigRenderPie(
                  arcWidth: 30,
                ),
              ),
            ),
            ListView.builder(
              itemCount: catWiseData.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (ctx, parentIndex) {
                var eachItem = catWiseData[parentIndex];

                return Column(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 20, left: 5, right: 5),
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
                          margin: const EdgeInsets.only(
                              top: 10, left: 10, right: 10),
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
                                AppConstants.mCategories[eachTrans.expCatType]
                                    .catImgPath,
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
                                      color:
                                          isDark ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  Text(
                                    eachTrans.expBal.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                      color:
                                          isDark ? Colors.white : Colors.black,
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
          ],
        ),
      ),
    );
  }

  void filterCatWiseData() {
    for (CategoryModel eachCat in AppConstants.mCategories) {
      var catName = eachCat.catTitle;
      var eachCatAmt = 0.0;
      List<ExpenseModel> catTrans = [];

      for (ExpenseModel eachExp in widget.mData) {
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

        listOrdinalData.add(OrdinalData(
            domain: catName,
            measure: eachCatAmt.isNegative ? eachCatAmt * -1 : eachCatAmt,
            color: Colors.blue));
      }
    }
    listOrdinalGrp.add(OrdinalGroup(id: "1", data: listOrdinalData));
  }
}
