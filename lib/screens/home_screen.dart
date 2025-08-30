import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        title: const Text('الشركة السودانية لتوزيع الكهرباء',style: TextStyle(color: Colors.white),),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Card(
              color: Colors.blue,
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.public, size: 40,color:Colors.white),
                title: const Text(
                  'بلاغ عام',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color:Colors.white),
                  textAlign: TextAlign.right,
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/private_report');
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.blue,
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.lock, size: 40,color: Colors.white),
                title: const Text(
                  'بلاغ خاص',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color:Colors.white),
                  textAlign: TextAlign.right,
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/report_status');
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.blue,
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.history, size: 40,color: Colors.white),
                title: const Text(
                  'حالة البلاغ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color:Colors.white),
                  textAlign: TextAlign.right,
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/report');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
