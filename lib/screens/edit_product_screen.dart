import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _decsriptionFocusNode = FocusNode();
  final _imageUrlControll = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  var _editProduct = Product(
    id: null,
    title: '',
    description: '',
    price: 0,
    imageUrl: '',
  );
  var _initialValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };
  var _isInit = true;

  var _isLoading = false;

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlControll.text.startsWith('http') &&
              !_imageUrlControll.text.startsWith('https')) ||
          (!_imageUrlControll.text.endsWith('.png') &&
              !_imageUrlControll.text.endsWith('.jpg') &&
              !_imageUrlControll.text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final _isValid = _formKey.currentState.validate();
    if (!_isValid) {
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editProduct.id != null) {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editProduct.id, _editProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editProduct);
      } catch (e) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text("An Error ocurred"),
            content: Text("Something went wrong"),
            actions: [
              FlatButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text("OK"),
              ),
            ],
          ),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    _imageUrlFocusNode.addListener(_updateImageUrl);
  }

  @override
  void dispose() {
    super.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _decsriptionFocusNode.dispose();
    _imageUrlControll.dispose();
    _imageUrlFocusNode.dispose();
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initialValues = {
          'title': _editProduct.title,
          'description': _editProduct.description,
          'price': _editProduct.price.toString(),
          'imageUrl': '',
        };
        _imageUrlControll.text = _editProduct.imageUrl;
      }
      _isInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Edit Product"),
          actions: [
            IconButton(icon: Icon(Icons.save), onPressed: _saveForm),
          ],
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        initialValue: _initialValues["title"],
                        decoration: InputDecoration(labelText: 'Title'),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_priceFocusNode);
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please input a value';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editProduct = Product(
                            id: _editProduct.id,
                            title: value,
                            description: _editProduct.description,
                            price: _editProduct.price,
                            imageUrl: _editProduct.imageUrl,
                            isFavorite: _editProduct.isFavorite,
                          );
                        },
                      ),
                      TextFormField(
                        initialValue: _initialValues["price"],
                        decoration: InputDecoration(labelText: 'Price'),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        focusNode: _priceFocusNode,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_decsriptionFocusNode);
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please input a price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please input a valid number';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Please input a valid price';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editProduct = Product(
                            id: _editProduct.id,
                            title: _editProduct.title,
                            description: _editProduct.description,
                            price: double.parse(value),
                            imageUrl: _editProduct.imageUrl,
                            isFavorite: _editProduct.isFavorite,
                          );
                        },
                      ),
                      TextFormField(
                        initialValue: _initialValues["description"],
                        decoration: InputDecoration(labelText: 'Description'),
                        maxLength: 3,
                        keyboardType: TextInputType.multiline,
                        focusNode: _decsriptionFocusNode,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please input a description';
                          }
                          if (value.length < 10) {
                            return 'Please input a valid description';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editProduct = Product(
                            id: _editProduct.id,
                            title: _editProduct.title,
                            description: value,
                            price: _editProduct.price,
                            imageUrl: _editProduct.imageUrl,
                            isFavorite: _editProduct.isFavorite,
                          );
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: EdgeInsets.only(top: 8.0, right: 10.0),
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey),
                            ),
                            child: _imageUrlControll.text.isEmpty
                                ? Text("enter Image URL")
                                : FittedBox(
                                    child:
                                        Image.network(_imageUrlControll.text),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: _imageUrlControll,
                              decoration:
                                  InputDecoration(labelText: 'Image URL'),
                              keyboardType: TextInputType.url,
                              focusNode: _imageUrlFocusNode,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please input a URL';
                                }
                                if (!value.startsWith('http') &&
                                    !value.startsWith('https')) {
                                  return 'Please input a valid URL';
                                }
                                if (!value.endsWith('png') &&
                                    !value.endsWith('jpg') &&
                                    !value.endsWith('jpeg')) {
                                  return 'Please input a valid URL';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _editProduct = Product(
                                  id: _editProduct.id,
                                  title: _editProduct.title,
                                  description: _editProduct.description,
                                  price: _editProduct.price,
                                  imageUrl: value,
                                  isFavorite: _editProduct.isFavorite,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ));
  }
}
