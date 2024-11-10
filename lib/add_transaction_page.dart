import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'transaction_model.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class AddTransactionPage extends StatefulWidget {
  final Transaction? transaction;

  const AddTransactionPage({Key? key, this.transaction}) : super(key: key);

  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  String selectedTransactionType = 'Pemasukan'; // Default value
  String? proofFilePath;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      descriptionController.text = widget.transaction!.description;
      amountController.text = widget.transaction!.amount.toString();
      selectedTransactionType = widget.transaction!.isIncome ? 'Pemasukan' : 'Pengeluaran';
      proofFilePath = widget.transaction!.proofFilePath;
    }
  }

  Future<void> pickProofFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      setState(() {
        if (kIsWeb) {
          // Menambahkan awalan `data:image/png;base64,` untuk mendeteksi gambar base64.
          proofFilePath = 'data:image/png;base64,${base64Encode(result.files.single.bytes!)}';
        } else {
          proofFilePath = result.files.single.path;
        }
      });
    }
  }

  void saveTransaction() {
    final description = descriptionController.text;
    final amount = double.tryParse(amountController.text) ?? 0.0;

    if (description.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mohon isi deskripsi dan jumlah yang valid')),
      );
      return;
    }

    final isIncome = selectedTransactionType == 'Pemasukan';

    final newTransaction = Transaction(
      description: description,
      amount: amount,
      isIncome: isIncome,
      proofFilePath: proofFilePath,
    );

    final transactionBox = Hive.box<Transaction>('transactions');
    if (widget.transaction == null) {
      transactionBox.add(newTransaction);
    } else {
      widget.transaction!
        ..description = description
        ..amount = amount
        ..isIncome = isIncome
        ..proofFilePath = proofFilePath
        ..save();
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transaction == null ? 'Tambah Transaksi' : 'Edit Transaksi'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Jumlah',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButton<String>(
                value: selectedTransactionType,
                onChanged: (value) {
                  setState(() {
                    selectedTransactionType = value!;
                  });
                },
                items: <String>['Pemasukan', 'Pengeluaran']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: pickProofFile,
                child: Text('Pilih Bukti Transaksi'),
              ),
              if (proofFilePath != null)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  child: kIsWeb
                      ? Image.network(proofFilePath!)
                      : Image.file(File(proofFilePath!)),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: saveTransaction,
                child: Text(widget.transaction == null ? 'Simpan Transaksi' : 'Perbarui Transaksi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
