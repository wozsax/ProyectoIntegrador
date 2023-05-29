import 'package:flutter/material.dart';

class LocationListTile extends StatelessWidget {
  const LocationListTile({
    Key? key,
    required this.location,
    required this.press,
  }) : super(key: key);

  final String location;
  final ValueChanged<String> press;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: () {
            press(location);
          },
          horizontalTitleGap: 0,
          leading: const Icon(Icons.location_pin),
          title: Text(
            location,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Divider(
          color: Color.fromARGB(255, 222, 219, 219),
          thickness: 2,
          height: 1,
        ),
      ],
    );
  }
}
