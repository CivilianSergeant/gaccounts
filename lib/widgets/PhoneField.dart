import 'package:country_code_picker/country_code.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';

class PhoneField extends StatefulWidget{

  TextEditingController controller;
  Function callback;
  PhoneField({this.controller,this.callback});

  @override
  State<StatefulWidget> createState() => _PhoneFieldState();

}
class _PhoneFieldState extends State<PhoneField>{

  CountryCode _selectedCountry;

  @override
  void initState() {

    setState(() {
      _selectedCountry = CountryCode(dialCode: "+880");

    });

  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(20),
          child: Material(
            elevation: 2.0,
            borderRadius: BorderRadius.circular(50),
            shadowColor: Colors.black,
            child: TextField(
              controller: widget.controller,
              onChanged: (value){
                if(_selectedCountry.dialCode.endsWith("0") && value.startsWith("0")){
                  widget.controller.text = widget.controller.text.substring(1);
                }
                widget.callback(_selectedCountry.dialCode);
              },
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(left: 15,right: 10,top: 10,bottom: 5),
                hintText: "Mobile No",
                prefix: SizedBox(width: 90,),
                prefixIcon:Icon(Icons.phone),
                filled: true,
                focusColor: Colors.white,
                fillColor: Colors.white,
                focusedBorder: const OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.teal, width: 0.0),
                    borderRadius: BorderRadius.all(Radius.circular(50))
                ),
                enabledBorder: const OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey, width: 0.0),
                    borderRadius: BorderRadius.all(Radius.circular(50))
                ),

              ),
            ),
          ),
        ),

        CountryCodePicker(
          padding: EdgeInsets.only(top: 35,left: 70),
          onChanged: (value){
            setState(() {
              _selectedCountry = value;
              if(_selectedCountry.dialCode.endsWith("0") && widget.controller.text.startsWith("0")){
                widget.controller.text = widget.controller.text.substring(1);
              }
              widget.callback(_selectedCountry.dialCode);
            });
          },
          // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
          initialSelection: 'BD',
          favorite: ['+88','BD'],
          countryFilter: ['AF','BD','BT','IN','LK','MV','NP','PK'],
          showFlagDialog: true,
          comparator: (a, b) => b.name.compareTo(a.name),
          //Get the country information relevant to the initial selection

        )
      ],
    );
  }

}