import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


class CheckoutPage extends StatefulWidget {
  @override
  CheckoutPageState createState() => CheckoutPageState();
}

class CheckoutPageState extends State<CheckoutPage> {


  // Controllers for TextFormFields
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();

  // State for Card Type Selection
  String selectedCardType = '';

  // List to store saved card details
  List<Map<String, dynamic>> details = [];
  List<Map<String,dynamic>> products=[];


  void saveCardDetails() {
    // Collect data from the form
    final cardDetails = {
      'first name': firstNameController.text,
      'last name': lastNameController.text,
      'card type': selectedCardType,
      'credit card number': cardNumberController.text,
      'expiry date': expiryDateController.text,
      'cvv': cvvController.text,
      'country': countryController.text,
      'city': cityController.text,
      'street': streetController.text,
      'postal code': postalCodeController.text,
    };

    // Save to the details list
    setState(() {
      details.add(cardDetails);
    });

    // Optionally save to Firestore


    // Clear the form for new input
    firstNameController.clear();
    lastNameController.clear();
    cardNumberController.clear();
    expiryDateController.clear();
    cvvController.clear();
    countryController.clear();
    cityController.clear();
    streetController.clear();
    postalCodeController.clear();
    selectedCardType = '';
  }
  bool checkCardDetails() {
    // Gather card details into a map
    final cardDetails = {
      'first name': firstNameController.text,
      'last name': lastNameController.text,
      'card type': selectedCardType,
      'credit card number': cardNumberController.text,
      'expiry date': expiryDateController.text,
      'cvv': cvvController.text,
      'country': countryController.text,
      'city': cityController.text,
      'street': streetController.text,
      'postal code': postalCodeController.text,
    };

    // Loop through the details list
    for (var d in details) {
      if (mapEquals(cardDetails, d)) { // Use `mapEquals` for comparison
        print('Card verified');
        return true; // Return true immediately if a match is found
      }
    }

    print('Card not verified');
    return false; // Return false if no match is found
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout Page'),
      ),
      body: Row(
        children: [
          // Left side: Form and saved details
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Form Section
                  TextFormField(
                    controller: firstNameController,
                    decoration: InputDecoration(labelText: 'First Name'),
                  ),
                  TextFormField(
                    controller: lastNameController,
                    decoration: InputDecoration(labelText: 'Last Name'),
                  ),
                  Text(
                    'Card Type',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                 Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Visa', style: TextStyle(fontSize: 16)), // Title
                      SizedBox(height: 8), // Spacing between title and image
                      Image.network(
                        'https://upload.wikimedia.org/wikipedia/commons/4/41/Visa_Logo.png',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                      Checkbox(
                        value: selectedCardType == 'Visa',
                        onChanged: (bool? value) {
                          if (value == true) {
                            setState(() {
                              selectedCardType = 'Visa';
                            });
                          }
                        },
                      ), // Checkbox
                    ],
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('MasterCard', style: TextStyle(fontSize: 16)), // Title
                      SizedBox(height: 8), // Spacing between title and image
                      Image.network(
                        'https://pngimg.com/uploads/mastercard/mastercard_PNG23.png',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                      Checkbox(
                        value: selectedCardType == 'MasterCard',
                        onChanged: (bool? value) {
                          if (value == true) {
                            setState(() {
                              selectedCardType = 'MasterCard';
                            });
                          }
                        },
                      ), // Checkbox
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('American Express', style: TextStyle(fontSize: 16)), // Title
                      SizedBox(height: 8), // Spacing between title and image
                      Image.network(
                        'https://images.fastcompany.net/image/upload/w_596,c_limit,q_auto:best,f_auto,fl_lossy/wp-cms/uploads/sites/4/2018/04/4-you-might-not-notice-amex-new-brand.jpg',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                      Checkbox(
                        value: selectedCardType == 'American Express',
                        onChanged: (bool? value) {
                          if (value == true) {
                            setState(() {
                              selectedCardType = 'American Express';
                            });
                          }
                        },
                      ), // Checkbox
                    ],
                  ),


                  TextFormField(
                    controller: cardNumberController,
                    decoration: InputDecoration(labelText: 'Credit Card Number'),
                  ),
                  TextFormField(
                    controller: expiryDateController,
                    decoration: InputDecoration(labelText: 'Expiry Date'),
                  ),
                  TextFormField(
                    controller: cvvController,
                    decoration: InputDecoration(labelText: 'CVV'),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Address',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  TextFormField(
                    controller: countryController,
                    decoration: InputDecoration(labelText: 'Country'),
                  ),
                  TextFormField(
                    controller: cityController,
                    decoration: InputDecoration(labelText: 'City'),
                  ),
                  TextFormField(
                    controller: streetController,
                    decoration: InputDecoration(labelText: 'Street'),
                  ),
                  TextFormField(
                    controller: postalCodeController,
                    decoration: InputDecoration(labelText: 'Postal Code'),
                  ),
                  SizedBox(height: 16),
                  Row(children: [
                  ElevatedButton(
                    onPressed: saveCardDetails,
                    child: Text('Save'),
                  ),
                    ElevatedButton(
                      onPressed: () {
                        bool isCardValid = checkCardDetails(); // Call your boolean function
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Validation Result'),
                              content: Text(isCardValid ? 'Card validated' : 'Card not validated'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Close the popup
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Text('Validate'),
                    )

                  ],
                  ),
                  SizedBox(height: 32),
                  // Display Saved Details
                  Text(
                    'Saved Cards',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: details.length,
                    itemBuilder: (context, index) {
                      final card = details[index];
                      return ListTile(
                        title: Text('${card['first name']} ${card['last name']}'),
                        subtitle: Text(
                            '${card['card type']} - ${card['credit card number']}'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // Right side: Additional Content
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[200],
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Existing static content
                    Icon(Icons.shopping_cart, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'checkout items',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16), // Spacing before the ListView

                    // ListView.builder for product details
                    Container(
                      height: 400, // Specify height to constrain the ListView
                      child: ListView.builder(
                        itemCount: products.length, // Replace with the size of your product list
                        itemBuilder: (context, index) {
                          final product = products[index]; // Access each product
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            child: ListTile(
                              leading: Image.network(
                                product['imageUrl'], // Product image
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                              title: Text(product['name']), // Product name
                              subtitle: Text('Quantity: ${product['quantity']}'), // Product quantity
                              trailing: Text('\$${product['price']}'), // Product price
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )

        ],
      ),
    );
  }
}
