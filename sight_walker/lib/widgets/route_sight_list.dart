import 'package:flutter/material.dart';

import '/widgets/route_sight_tile.dart';
import 'utils.dart';

List<Widget> routeList(List tour, List isOpen) {
  List<Widget> out = [];
  out.add(routeTile(tour[0], expandable: false));
  for (var i = 1; i < tour.length; i++) {
    out.add(
        Container(
          padding: EdgeInsets.only(left: 30,),
          child: Row(
            children: [
              Column(
                children: [
                  Icon(Icons.more_vert),
                  SizedBox(height: 5),
                  Icon(Icons.directions_walk),
                  SizedBox(height: 5),
                  Icon(Icons.more_vert),
                ],
              ),
              SizedBox(width: 20,),
              Text(toTimeString(walkingTime(tour[i-1], tour[i]))),
            ],
          ),
        )
    );
    out.add(routeTile(tour[i]));
  }
  out.add(
      Container(
        padding: EdgeInsets.only(left: 30, bottom: 5),
        child: Row(
          children: [
            Column(
              children: [
                Icon(Icons.more_vert),
                SizedBox(height: 5),
                Icon(Icons.directions_walk),
                SizedBox(height: 5),
                Icon(Icons.more_vert),
              ],
            ),
            SizedBox(width: 20,),
            Text(toTimeString(walkingTime(tour[tour.length - 1], tour[0]))),
          ],
        ),
      )
  );
  out.add(routeTile(tour[0], expandable: false));
  return out;
}