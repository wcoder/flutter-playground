import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  final Function deleteTransaction;

  TransactionList(this.transactions, this.deleteTransaction);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Container(
      child: transactions.isEmpty
        ? LayoutBuilder(builder: (ctx, constraint) {
          return Column(
            children: <Widget>[
              Text(
                  "No transactions added yet!",
                  style: Theme.of(context).textTheme.title
              ),
              SizedBox(
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
            final transaction = transactions[index];
            return Card(
              elevation: 5,
              margin: EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 5,
              ),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 30,
                  child: Padding(
                    padding: EdgeInsets.all(6),
                    child: FittedBox(
                      child: Text('\$${transaction.amount.toStringAsFixed(2)}'),
                    ),
                  ),
                ),
                title: Text(
                  transaction.title,
                  style: Theme.of(context).textTheme.title,
                ),
                subtitle: Text(
                  DateFormat.yMMMd().format(transaction.date),
                  style: TextStyle(
                      color: Colors.grey
                  ),
                ),
                trailing: mediaQuery.size.width > 360
                  ? FlatButton.icon(
                    icon: Icon(Icons.delete),
                    label: Text('Delete'),
                    textColor: Theme.of(context).errorColor,
                    onPressed: () {
                      deleteTransaction(transaction.id);
                    },
                  )
                  : IconButton(
                    icon: Icon(Icons.delete),
                    color: Theme.of(context).errorColor,
                    onPressed: () {
                      deleteTransaction(transaction.id);
                    },
                  ),
              ),
            );
          },
        ),
    );
  }
}
