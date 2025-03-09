import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class OrdersPage extends StatefulWidget {
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getOrderStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return '⏳ Pending';
      case 'preparing':
        return '👨‍🍳 Preparing';
      case 'ready':
        return '✅ Ready';
      case 'delivered':
        return '🚚 Delivered';
      case 'cancelled':
        return '❌ Cancelled';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'preparing':
        return Colors.blue;
      case 'ready':
        return Colors.green;
      case 'delivered':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _createInitialOrder() async {
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('orders')
          .add({
        'items': [
          {
            'name': 'Welcome Sample Order',
            'quantity': 1,
          }
        ],
        'status': 'pending',
        'orderDate': FieldValue.serverTimestamp(),
        'total': 0.0,
      });
    } catch (e) {
      print('Error creating initial order: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: _auth.authStateChanges(),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green[600]!),
              ),
            );
          }

          if (!authSnapshot.hasData || authSnapshot.data == null) {
            return Center(
              child: Text('Please log in to view orders'),
            );
          }

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 120.0,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.green[600],
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      'My Orders',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.green[400]!,
                            Colors.green[600]!,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: Colors.green[700],
                      unselectedLabelColor: Colors.grey[600],
                      indicatorColor: Colors.green[700],
                      tabs: [
                        Tab(text: 'Active'),
                        Tab(text: 'Completed'),
                        Tab(text: 'Cancelled'),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildOrdersList(['pending', 'preparing', 'ready']),
                _buildOrdersList(['delivered']),
                _buildOrdersList(['cancelled']),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPlaceOrderDialog(context),
        backgroundColor: Colors.green[600],
        child: Icon(Icons.add_shopping_cart),
      ),
    );
  }

  Widget _buildOrdersList(List<String> statusList) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('orders')
          .where('status', whereIn: statusList)
          .orderBy('orderDate', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red[400],
                ),
                SizedBox(height: 16),
                Text(
                  'Something went wrong',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 16,
                  ),
                ),
                TextButton(
                  onPressed: () => _createInitialOrder(),
                  child: Text('Try Again'),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green[600]!),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 64,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16),
                Text(
                  'No ${statusList.first} orders',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                TextButton(
                  onPressed: () => _showPlaceOrderDialog(context),
                  child: Text('Place a new order'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var order = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            return _buildOrderCard(order, snapshot.data!.docs[index].id);
          },
        );
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, String orderId) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${orderId.substring(0, 8)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order['status'] ?? 'pending').withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getOrderStatus(order['status'] ?? 'pending'),
                    style: TextStyle(
                      color: _getStatusColor(order['status'] ?? 'pending'),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            if (order['items'] != null) ...[
              SizedBox(height: 16),
              Text(
                'Items:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8),
              ...(order['items'] as List<dynamic>).map(
                (item) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '• ${item['name']}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      Text(
                        'x${item['quantity']}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '\$${(order['total'] ?? 0.0).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            if (order['orderDate'] != null) ...[
              SizedBox(height: 8),
              Text(
                'Ordered on ${DateFormat('MMM d, y • h:mm a').format(
                  (order['orderDate'] as Timestamp).toDate(),
                )}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showPlaceOrderDialog(BuildContext context) {
    final itemNameController = TextEditingController();
    final quantityController = TextEditingController();
    List<Map<String, dynamic>> items = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Place New Order'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (items.isNotEmpty) ...[
                  Text(
                    'Items in Order:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  ...items.map(
                    (item) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text('${item['name']} x${item['quantity']}'),
                          ),
                          IconButton(
                            icon: Icon(Icons.remove_circle_outline,
                                color: Colors.red),
                            onPressed: () {
                              setState(() {
                                items.remove(item);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(),
                ],
                TextField(
                  controller: itemNameController,
                  decoration: InputDecoration(
                    labelText: 'Item Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: quantityController,
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (itemNameController.text.isNotEmpty &&
                        quantityController.text.isNotEmpty) {
                      setState(() {
                        items.add({
                          'name': itemNameController.text,
                          'quantity': int.parse(quantityController.text),
                        });
                        itemNameController.clear();
                        quantityController.clear();
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                  ),
                  child: Text('Add Item'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: items.isEmpty
                  ? null
                  : () async {
                      try {
                        await _firestore
                            .collection('users')
                            .doc(_auth.currentUser?.uid)
                            .collection('orders')
                            .add({
                          'items': items,
                          'status': 'pending',
                          'orderDate': FieldValue.serverTimestamp(),
                          'total': items.fold(
                            0.0,
                            (sum, item) => sum + (item['quantity'] * 10.0),
                          ),
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Order placed successfully!'),
                            backgroundColor: Colors.green[600],
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error placing order: $e'),
                            backgroundColor: Colors.red[600],
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
              ),
              child: Text('Place Order'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
} 