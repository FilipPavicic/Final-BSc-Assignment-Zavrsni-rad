import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:recognizing_text2/Utils.dart';
import 'package:recognizing_text2/screens/AddStoreScreen.dart';


class DateTimeTextField extends StatelessWidget {
  final TextEditingController controller;
  final Color primaryColor;
  final Color secundaryColor;
  final IconData sufficIconData;
  final String label;
  final double topPadding;
  final FocusNode focusNode;

  const DateTimeTextField({
    Key key,
    this.controller,
    this.primaryColor,
    this.secundaryColor,
    this.sufficIconData,
    this.label,
    this.topPadding = 30,
    this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(top: topPadding),
        child: TextFormField(
          onTap: () => dateTimeKeybord(context),
          controller: controller,
          readOnly: true,
          showCursor: false,
          decoration: MyBorderInputDecoration(
              suffixIcon: Icon(sufficIconData, color: secundaryColor),
              alignLabelWithHint: true,
              labelText: label,
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
            if (toDateTimeString(controller.text, label.toLowerCase()) == null)
              return 'Incorect ${label.toLowerCase()} ';
            return null;
          },
        ));
  }

  dateTimeKeybord(BuildContext context) {
    switch (label) {
      case 'Time':
        timeKeybord(context);
        break;
      case 'Date':
        dateKeybord(context);
        break;
      default:
        return;
    }
  }

  dateKeybord(BuildContext context) {
    DatePicker.showDatePicker(
      context,
      dateFormat: 'dd-MMMM-yyyy',
      pickerMode: DateTimePickerMode.date,
      initialDateTime: toDateTimeString(controller.text, 'date'),
      onConfirm: (dateTime, selectedIndex) =>
          controller.text = printDateTimeShort(dateTime, 'date'),
      onCancel: () => focusNode.unfocus(),
    );
  }

  timeKeybord(BuildContext context) {
    DatePicker.showDatePicker(
      context,
      dateFormat: 'HH:mm',
      pickerMode: DateTimePickerMode.time,
      initialDateTime: toDateTimeString(controller.text, 'time'),
      onConfirm: (dateTime, selectedIndex) =>
          controller.text = printDateTimeShort(dateTime, 'time'),
      onCancel: () => focusNode.unfocus(),
    );
  }
}
