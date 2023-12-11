import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CollectionReference _products =
      FirebaseFirestore.instance.collection('products');
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  Future<void> _update([DocumentSnapshot? doc]) async {
    if (doc != null) {
      _nameController.text = doc['name'];
      _priceController.text = doc['price'].toString();
      _imageController.text = doc['image'];
    }
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                      )),
                  TextField(
                    controller: _imageController,
                    decoration: const InputDecoration(labelText: 'Image'),
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      child: const Text('Update'),
                      onPressed: () async {
                        final String name = _nameController.text;
                        final double? price =
                            double.tryParse(_priceController.text);
                        final String? image = _imageController.text;
                        if (name != null && price != null && image != null) {
                          await _products.doc(doc!.id).update(
                              {'name': name, 'price': price, 'image': image});
                          _nameController.text = '';
                          _priceController.text = '';
                          _imageController.text = '';
                          Navigator.pop(ctx);
                        }
                      }),
                ]),
          );
        });
  }

  Future<void> _create([DocumentSnapshot? doc]) async {
    if (doc != null) {
      _nameController.text = doc['name'];
      _priceController.text = doc['price'].toString();
      _imageController.text = doc['image'];
    }
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                      )),
                  TextField(
                    controller: _imageController,
                    decoration: const InputDecoration(labelText: 'Image'),
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    child: const Text('Create'),
                    onPressed: () async {
                      final String name = _nameController.text;
                      final double? price =
                          double.tryParse(_priceController.text);
                      final String image = _imageController.text;
                      if (name != null && price != null && image != null) {
                        await _products.add(
                            {'name': name, 'price': price, 'image': image});
                        _nameController.text = '';
                        _imageController.text = '';
                        _priceController.text = '';
                        Navigator.pop(ctx);
                      }
                    },
                  ),
                ]),
          );
        });
  }

  Future<void> _delete(String proid) async {
    await _products.doc(proid).delete();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Product deleted'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _imageController.text = '';
          _nameController.text = '';
          _priceController.text = '';
          _create();
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: StreamBuilder(
          stream: _products.snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            if (streamSnapshot.hasData) {
              return streamSnapshot.data!.docs.isEmpty
                  ? Center(child: Text("No Data"))
                  : ListView.builder(
                      itemCount: streamSnapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final DocumentSnapshot documentSnapshot =
                            streamSnapshot.data!.docs[index];
                        return Card(
                          margin: EdgeInsets.all(10),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      documentSnapshot['image'],
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder: (BuildContext context,
                                          Object error,
                                          StackTrace? stackTrace) {
                                        return Image.asset(
                                            "assets/img.png"); // Replace with your error handling widget
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(documentSnapshot['name']),
                                        Text(documentSnapshot['price']
                                            .toString()),
                                      ]),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () {
                                          _update(documentSnapshot);
                                        }),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        _delete(documentSnapshot.id);
                                      },
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
