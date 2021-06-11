import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:recognizing_text2/FirebaseUtils.dart';
import 'package:recognizing_text2/Utils.dart';
import 'package:recognizing_text2/screens/AddStoreScreen.dart';

class StoreTypeAheadWidget extends StatefulWidget {
  final TextEditingController storeControler;
  final FocusNode storeFocusNode;
  final FocusNode nextFocusNode;
  final AddStoreBottomSheet bottomSheet;
  final Color primaryColor;
  final Color secundaryColor;
  final BuildContext context;
  final List<String> initList;

  StoreTypeAheadWidget({
    Key key,
    this.storeControler,
    this.storeFocusNode,
    this.nextFocusNode,
    this.bottomSheet,
    this.primaryColor,
    this.secundaryColor,
    this.context,
    this.initList,
  }) : super(key: key);

  @override
  _StoreTypeAheadWidgetState createState() => _StoreTypeAheadWidgetState();
}

class _StoreTypeAheadWidgetState extends State<StoreTypeAheadWidget> {
  List<String> storeNameSuggestion = [];

  @override
  void initState() {
    if(widget.initList != null) storeNameSuggestion.addAll(widget.initList);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return TypeAheadFormField<String>(
      debounceDuration: Duration(milliseconds: 500),
      textFieldConfiguration: TextFieldConfiguration(
        textCapitalization: TextCapitalization.sentences,
        controller: widget.storeControler,
        focusNode: widget.storeFocusNode,
        onEditingComplete: () =>
            FocusScope.of(context).requestFocus(widget.nextFocusNode),
        decoration: MyBorderInputDecoration(
            suffixIcon:
                Icon(Icons.store_mall_directory, color: widget.secundaryColor),
            labelText: "Store name",
            labelStyle: TextStyle(color: widget.secundaryColor, fontSize: 18),
            filled: true,
            hintStyle: TextStyle(color: widget.secundaryColor),
            fillColor: widget.primaryColor,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: widget.secundaryColor, width: 2.0),
              borderRadius: BorderRadius.circular(25.0),
            ),
            errorStyle: TextStyle(color: widget.secundaryColor, fontSize: 14)),
        style: TextStyle(color: widget.secundaryColor),
        cursorColor: widget.secundaryColor,
      ),
      validator: (v) {
        if (v == '') return 'This field is required';
        if (!storeNameSuggestion.contains(v))
          return 'Please select name from suggestion list';
        return null;
      },
      suggestionsBoxDecoration: SuggestionsBoxDecoration(
          color: widget.secundaryColor,
          elevation: 20,
          constraints: BoxConstraints(maxHeight: 200)),
      suggestionsCallback: (str) async {
        if (str == '') return [];
        storeNameSuggestion = await get10BySearch(storeCollectionReference,
            'ascii_name', adjustOneAndASCII(str, {}), null, (e) => e['name']);
        return storeNameSuggestion;
      },
      hideOnLoading: true,
      noItemsFoundBuilder: (context) => Container(
        constraints: BoxConstraints(minWidth: double.infinity),
        height: 40,
        alignment: Alignment.topLeft,
        child: TextButton.icon(
            style: ButtonStyle(
              overlayColor: MaterialStateColor.resolveWith(
                  (states) => Colors.transparent),
            ),
            onPressed: () async {
              String text = await widget.bottomSheet.showBottomSheet<String>(
                  context, //TODO
                  themeData,
                  widget.storeControler.text);
              setState(() {
                widget.storeControler.text = text;
              });
            },
            icon: Icon(
              Icons.add,
              color: widget.primaryColor,
            ),
            label: Text(
              'Add new store',
              style: TextStyle(color: widget.primaryColor),
            )),
      ),
      onSuggestionSelected: (str) {
        widget.storeControler.text = str;
        FocusScope.of(context).requestFocus(widget.nextFocusNode);
      },
      itemBuilder: (context, itemData) {
        return Container(
          padding: EdgeInsets.only(left: 10),
          alignment: Alignment.centerLeft,
          height: 40,
          child: Text(
            itemData,
            style: TextStyle(color: widget.primaryColor),
          ),
        );
      },
    );
  }
}
