import 'package:expenseapp/widgets/transaction_item.dart';
import 'package:flutter/material.dart';
import '../models/transaction.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  final Function deleteTransaction;

  TransactionList(this.transactions, this.deleteTransaction);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: transactions.isEmpty
        ? LayoutBuilder(builder: (ctx, constraint) {
          return Column(
            children: <Widget>[
              Text(
                  "No transactions added yet!",
                  style: Theme.of(context).textTheme.title
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: constraint.maxHeight * 0.6,
                child: Image.asset(
                  'assets/images/waiting.png',
                  fit: BoxFit.cover,
                ),
              ),
            ],
          );
        })
        : ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            return TransactionItem(
              transaction: transactions[index],
              deleteTransaction: deleteTransaction
            );
          },
        ),
    );
  }
}

