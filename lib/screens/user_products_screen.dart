import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/user_product_item.dart';

class UserProductScreen extends StatelessWidget {
  static const routeName = '/user-product-detail';

  Future<void> _refreshproduct(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fatchAndSetProdcts(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Products"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () =>
                Navigator.of(context).pushNamed(EditProductScreen.routeName),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
          future: _refreshproduct(context),
          builder: (ctx, AsyncSnapshot snapshot) =>
              snapshot.connectionState == ConnectionState.waiting
                  ? Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () => _refreshproduct(context),
                      child:Consumer<Products>(
                        builder: (ctx , ProductData, _)=>Padding(
                          padding: EdgeInsets.all(8.0),
                          child: ListView.builder(
                            itemCount:ProductData.items.length,
                            itemBuilder: (_ , int index)=>Column(
                              children: [
                                UserProductItem(ProductData.items[index].id ,ProductData.items[index].title,ProductData.items[index].imageUrl,),
                                Divider(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )),
    );
  }
}
