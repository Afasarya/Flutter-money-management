import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart'; // Untuk kIsWeb
import 'dart:io'; // Untuk File (hanya untuk seluler dan desktop)
import 'transaction_model.dart';
import 'add_transaction_page.dart'; // Halaman untuk menambah dan mengedit transaksi

class HomePage extends StatelessWidget {
  final Box<Transaction> transactionBox = Hive.box<Transaction>('transactions');

  double calculateTotalBalance() {
    double total = 0;
    for (var transaction in transactionBox.values) {
      if (transaction.isIncome) {
        total += transaction.amount;
      } else {
        total -= transaction.amount;
      }
    }
    return total;
  }

  void _navigateToAddTransactionPage(BuildContext context, [Transaction? transaction]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionPage(transaction: transaction),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pencatatan Keuangan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saldo Saat Ini:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            ValueListenableBuilder(
              valueListenable: transactionBox.listenable(),
              builder: (context, Box<Transaction> box, _) {
                double currentBalance = calculateTotalBalance();
                return Text(
                  'Rp ${currentBalance.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 32, color: Colors.green),
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Riwayat Transaksi:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: transactionBox.listenable(),
                builder: (context, Box<Transaction> box, _) {
                  if (box.isEmpty) {
                    return Center(
                      child: Text('Belum ada transaksi.'),
                    );
                  }
                  return ListView.builder(
                    itemCount: box.length,
                    itemBuilder: (context, index) {
                      final transaction = box.getAt(index);
                      return GestureDetector(
                        onTap: () {
                          _navigateToAddTransactionPage(context, transaction);
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: transaction?.proofFilePath != null && transaction!.proofFilePath!.isNotEmpty
    ? (kIsWeb
        ? Image.network(
            transaction.proofFilePath!,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Jika ada kesalahan saat memuat gambar di web
              return Icon(Icons.broken_image);
            },
          )
        : (File(transaction.proofFilePath!).existsSync()
            ? Image.file(
                File(transaction.proofFilePath!),
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Jika ada kesalahan saat memuat gambar di perangkat lokal
                  return Icon(Icons.broken_image);
                },
              )
            : Icon(Icons.broken_image)))
    : Icon(Icons.receipt),

                            title: Text(transaction!.description),
                            subtitle:
                                Text(transaction.isIncome ? 'Pemasukan' : 'Pengeluaran'),
                            trailing: Text(
                              'Rp ${transaction.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: transaction.isIncome ? Colors.green : Colors.red,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _navigateToAddTransactionPage(context);
                },
                child: Text('Tambah Transaksi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
