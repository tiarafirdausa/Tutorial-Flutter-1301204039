// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tutorial102_1301204039/Product.dart';
import 'package:tutorial102_1301204039/main.dart';
import 'Product.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp12());

class MyApp12 extends StatefulWidget {
  const MyApp12({super.key});

  @override
  State<MyApp12> createState() => _MyAppState();
}

Future<List<Product>> fetchProduct() async {
  final res = await http.get(Uri.parse('http://192.168.1.4:8000/api/product'));
  if (res.statusCode == 200) {
    var data = jsonDecode(res.body);
    var parsed = data['list'].cast<Map<String, dynamic>>();
    return parsed.map<Product>((json) => Product.fromJson(json)).toList();
  } else {
    throw Exception('Failed');
  }
}

class _MyAppState extends State<MyApp12> {
  late Future<List<Product>> products;

  @override
  void initState() {
    super.initState();
    products = fetchProduct();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Network',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: FutureBuilder<List<Product>>(
            future: products,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Tidak ada data',
                      style: TextStyle(
                        color: Colors.teal,
                        fontSize: 28,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return Card(
                        color: Colors.white,
                        child: InkWell(
                          child: Container(
                            padding: EdgeInsets.only(left: 20, top: 15),
                            margin:
                                EdgeInsets.only(bottom: 40, left: 10, top: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(snapshot.data![index].name,
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 28,
                                    )),
                                Text(snapshot.data![index].price.toString(),
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 24,
                                    )),
                              ],
                            ),
                          ),
                        ),
                      );
                    });
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
