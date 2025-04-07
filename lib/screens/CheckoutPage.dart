import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class CheckoutPage extends StatefulWidget {
  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.replaceAll(RegExp(r'[^0-9]'), ''); // Allow only numbers

    if (text.length > 4) {
      text = text.substring(0, 4); // Limit to 4 digits (MMYY)
    }

    if (text.length >= 3) {
      text = text.substring(0, 2) + '/' + text.substring(2); // Add the slash automatically
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}


class _CheckoutPageState extends State<CheckoutPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  String _name = '';
  String _address = '';
  String _phone = '';
  String _cardNumber = '';
  String _expiryDate = '';
  String _cvv = '';
  double _totalPrice = 0.0;
  List<Map<String, dynamic>> _cartItems = [];

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  Future<void> _fetchCartItems() async {
    var userId = _auth.currentUser?.uid;
    if (userId == null) return;

    var cartSnapshot = await _firestore.collection('users').doc(userId).collection('cart').get();
    List<Map<String, dynamic>> items = [];
    double total = 0.0;

    for (var doc in cartSnapshot.docs) {
      var data = doc.data();
      items.add(data);
      total += (data['price'] ?? 0);
    }

    setState(() {
      _cartItems = items;
      _totalPrice = total;
    });
  }

  void _placeOrder() async {
    await _fetchCartItems(); // Ensure cart is updated before placing an order
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    var userId = _auth.currentUser?.uid;
    if (userId == null) return;

    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cart is empty!')));
      return;
    }

    // 🔥 Fix: Use price directly instead of multiplying by quantity
    double totalPrice = 0.0;
    for (var item in _cartItems) {
      totalPrice += (item['price'] ?? 0).toDouble();
    }

    // 🔍 Debugging: Print total price calculation
    print("✅ Final Total Price: $totalPrice");

    // Save order details to Firestore
    await _firestore.collection('users').doc(userId).collection('orders').add({
      'name': _name,
      'address': _address,
      'phone': _phone,
      'cardNumber': _cardNumber,
      'expiryDate': _expiryDate,
      'cvv': _cvv,
      'totalPrice': totalPrice, // 🔥 FIXED: Uses correct total price
      'items': _cartItems.isNotEmpty ? _cartItems : [],
      'status': 'pending',
      'orderDate': FieldValue.serverTimestamp(),
    });

    print("✅ Order saved successfully with total: $totalPrice");

    // Clear the cart collection
    var cartRef = _firestore.collection('users').doc(userId).collection('cart');
    var cartSnapshot = await cartRef.get();
    for (var doc in cartSnapshot.docs) {
      await doc.reference.delete();
    }
    var menuRef = _firestore.collection('users').doc(userId).collection('recipes');
    var menuSnapshot = await menuRef.get();
    for (var doc in menuSnapshot.docs) {
      await doc.reference.delete();
    }

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order placed successfully!')),
    );

    // Navigate to Orders Page and refresh
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, '/orders');
  }




  void _formatExpiryDate(String value) {
    if (value.length == 2 && !value.contains('/')) {
      _expiryDateController.text = '$value/';
      _expiryDateController.selection = TextSelection.fromPosition(
        TextPosition(offset: _expiryDateController.text.length),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Order Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              _cartItems.isEmpty
                  ? Center(child: Text("Your cart is empty", style: TextStyle(color: Colors.grey[600])))
                  : Column(
                children: _cartItems.map((item) {
                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: item['imageUrl'] != null
                          ? Image.network(item['imageUrl'], width: 50, height: 50, fit: BoxFit.cover)
                          : Icon(Icons.fastfood, size: 50, color: Colors.grey[400]),
                      title: Text(item['name'] ?? 'Unknown', style: TextStyle(fontSize: 16)),
                      subtitle: Text("\$${item['price']?.toStringAsFixed(2) ?? '0.00'} x ${item['quantity']}"),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 10),
              Divider(),
              SizedBox(height: 10),
              Text("Delivery & Payment Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Full Name
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                      validator: (value) => value!.isEmpty ? 'Enter your name' : null,
                      onSaved: (value) => _name = value!,
                    ),
                    SizedBox(height: 10),
                    // Address
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Address', border: OutlineInputBorder()),
                      validator: (value) => value!.isEmpty ? 'Enter your address' : null,
                      onSaved: (value) => _address = value!,
                    ),
                    SizedBox(height: 10),
                    // Phone Number
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                      keyboardType: TextInputType.phone,
                      validator: (value) => value!.isEmpty ? 'Enter your phone number' : null,
                      onSaved: (value) => _phone = value!,
                    ),
                    SizedBox(height: 20),

                    // Card Number
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Card Number', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.length < 16 ? 'Enter a valid card number' : null,
                      onSaved: (value) => _cardNumber = value!,
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _expiryDateController,
                            decoration: InputDecoration(labelText: 'Expiry Date (MM/YY)', border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                            validator: (value) => value!.isEmpty || value.length != 5 ? 'Enter valid expiry date' : null,
                            onSaved: (value) => _expiryDate = value!,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly, // Allow only numbers
                              ExpiryDateFormatter(), // Apply the custom formatter
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'CVV', border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            validator: (value) => value!.length < 3 ? 'Enter valid CVV' : null,
                            onSaved: (value) => _cvv = value!,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("\$${_totalPrice.toStringAsFixed(2)}",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[700])),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _placeOrder,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.blue[700],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Center(
                  child: Text("Place Order",
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}