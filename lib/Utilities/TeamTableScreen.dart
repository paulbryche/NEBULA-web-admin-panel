import 'package:flutter/material.dart';

import 'Classes.dart';

Widget buildBillTable(List<NebulaTeamSubscriptions> items) {
  return Table(
    border: TableBorder.all(),
    children: [
      const TableRow(
        decoration: BoxDecoration(
          color: Colors.grey,
        ),
        children: [
          TableCell(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Subscriptions Type',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          TableCell(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Number Of Team Members Subscriptions',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          TableCell(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Price For 1 Subscription',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          TableCell(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Total',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      for (final item in items)
        TableRow(
          children: [
            TableCell(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(item.Name),
              ),
            ),
            TableCell(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(item.Quantity.toString()),
              ),
            ),
            TableCell(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(item.Price.toString()),
              ),
            ),
            TableCell(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  (item.Quantity * item.Price).toString(),
                ),
              ),
            ),
          ],
        ),
      TableRow(
        decoration: BoxDecoration(
          color: Colors.grey[200],
        ),
        children: [
          const TableCell(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                '',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const TableCell(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                '',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const TableCell(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Total For Your Team Subscriptions',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          TableCell(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                items.fold<double>(
                    0, (previousValue, element) => previousValue + (element.Quantity * element.Price)).toStringAsFixed(2),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

