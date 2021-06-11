import 'package:flutter/material.dart';
import 'package:recognizing_text2/screens/AddStoreScreen.dart';


class PriceTextField extends StatelessWidget {
  final TextEditingController priceController;
  final FocusNode priceFocusNode;
  final Color primaryColor;
  final Color secundaryColor;
  final double topPadding;

  PriceTextField(
      {Key key,
      this.priceController,
      this.priceFocusNode,
      this.primaryColor,
      this.secundaryColor,
      this.topPadding = 30})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Container(
        padding: EdgeInsets.only(top: topPadding),
        child: TextFormField(
          controller: priceController,
          keyboardType: TextInputType.number,
          focusNode: priceFocusNode,
          decoration: MyBorderInputDecoration(
              suffixIcon: Icon(Icons.monetization_on, color: secundaryColor),
              alignLabelWithHint: true,
              labelText: "Total price",
              labelStyle: TextStyle(color: secundaryColor, fontSize: 18),
              //hintText: 'McDonalds',
              filled: true,
              hintStyle: TextStyle(color: secundaryColor),
              fillColor: primaryColor,
              border: OutlineInputBorder(
                borderSide: BorderSide(color: secundaryColor, width: 2.0),
                borderRadius: BorderRadius.circular(25.0),
              ),
              errorStyle: TextStyle(color: secundaryColor, fontSize: 14)),
          style: TextStyle(color: secundaryColor),
          cursorColor: secundaryColor,
          validator: (v) {
            if (v == '') return 'This field is required';
            if (double.tryParse(v) == null) return 'Please enter number';
            return null;
          },
        ));
  }
}
