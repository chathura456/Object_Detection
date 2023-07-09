import 'package:flutter/material.dart';

class FeatureBox extends StatelessWidget {
  final Color color;
  final String headerText;
  final String descText;
  final Function()? onPress;
  const FeatureBox({Key? key, required this.color, required this.headerText, required this.descText, required this.onPress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        margin: const EdgeInsets.symmetric(
            horizontal: 35,
            vertical: 10
        ),
        decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(
                Radius.circular(15)
            )
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 20,left: 15,bottom: 20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(headerText, style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                ),),
              ),
              const SizedBox(height: 3,),
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Text(descText, style: const TextStyle(
                ),),
              ),
            ],
          ),
        ),
      ),
    );
  }}