import 'package:flutter/material.dart';

import '../model/country.dart';

class CountryDetailsScreen extends StatelessWidget {
  final CountryPresentation country;

  CountryDetailsScreen(this.country);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(country.name),
      ),
      body: Container(
        color: !country.isSelected
      ? Theme.of(context).primaryColor
            : Theme.of(context).accentColor,
        child: Center(
            child: Text(country.name,style: Theme.of(context).textTheme.body1,)
        ),
      ),
    );
  }
}
