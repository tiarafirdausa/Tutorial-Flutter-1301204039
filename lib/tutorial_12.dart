// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tutorial102_1301204039/Product.dart';
import 'package:tutorial102_1301204039/main.dart';
import 'Product.dart';
import 'package:http/http.dart' as http;

void main() => runApp(
      MaterialApp(
        title: 'Network',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        home: const MyApp12(),
      ),
    );

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

Future<Map<String, dynamic>> addProduct(_name, _price) async {
  final res = await http.post(
    Uri.parse('http://192.168.1.4:8000/api/product'),
    body: {
      'name': _name,
      'price': _price,
    },
  );
  if (res.statusCode == 200) {
    return jsonDecode(res.body);
  } else {
    throw Exception('Failed');
  }
}

class _MyAppState extends State<MyApp12> {
  late Future<List<Product>> products;
  var nameInput = TextEditingController();
  var priceInput = TextEditingController();

  @override
  void initState() {
    super.initState();
    products = fetchProduct();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return SimpleDialog(
                    title: Text('Add New Product'),
                    children: [
                      Column(
                        children: [
                          TextFormField(
                            decoration: InputDecoration(
                                labelText: "Name",
                                contentPadding: EdgeInsets.all(10),
                                hintText: 'Name'),
                            controller: nameInput,
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                                labelText: "Price",
                                contentPadding: EdgeInsets.all(10),
                                hintText: 'Price'),
                            controller: priceInput,
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () async {
                              var res = await addProduct(
                                  nameInput.text, priceInput.text);
                              if (res['error']) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Error'),
                                      content: Text(res['message']),
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else {
                                setState(() {
                                  products = fetchProduct();
                                });
                              }
                              Navigator.of(context).pop();
                              var snackBar = SnackBar(
                                content: Text(res['message']),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            },
                            child: Text('Save'),
                          )
                        ],
                      )
                    ],
                  );
                });
          }),
    );
  }
}
