// lib/data/world_cup_teams.dart
// All 48 qualified 2026 FIFA World Cup teams, plus two special bonus
// picks — Lebanon and Manchester United — for the "who will win?" vote.
//
// Flags are described as simple colour data and drawn in-app by
// FlagWidget, so they render identically on mobile and web with no
// image assets to ship.

import 'package:flutter/material.dart';

enum FlagStyle { vertical, horizontal, cross, saltire }

class Country {
  final String name;
  final String code; // short label shown on the flag chip
  final FlagStyle style;
  final List<Color> colors; // stripes; for cross/saltire => [bg, lineColor]
  final Color? emblem; // optional centre emblem colour
  final bool isBonus; // Lebanon / Manchester United

  const Country({
    required this.name,
    required this.code,
    required this.style,
    required this.colors,
    this.emblem,
    this.isBonus = false,
  });
}

class WorldCup {
  WorldCup._();

  // ---- the 48 qualified teams (2026 FIFA World Cup) ----
  static const List<Country> teams = [
    Country(name: 'United States', code: 'USA', style: FlagStyle.horizontal, colors: [Color(0xFFB22234), Colors.white, Color(0xFF3C3B6E)]),
    Country(name: 'Mexico', code: 'MEX', style: FlagStyle.vertical, colors: [Color(0xFF006847), Colors.white, Color(0xFFCE1126)]),
    Country(name: 'Canada', code: 'CAN', style: FlagStyle.vertical, colors: [Color(0xFFFF0000), Colors.white, Color(0xFFFF0000)], emblem: Color(0xFFFF0000)),
    Country(name: 'Japan', code: 'JPN', style: FlagStyle.horizontal, colors: [Colors.white], emblem: Color(0xFFBC002D)),
    Country(name: 'Iran', code: 'IRN', style: FlagStyle.horizontal, colors: [Color(0xFF239F40), Colors.white, Color(0xFFDA0000)]),
    Country(name: 'South Korea', code: 'KOR', style: FlagStyle.horizontal, colors: [Colors.white], emblem: Color(0xFFCD2E3A)),
    Country(name: 'Australia', code: 'AUS', style: FlagStyle.horizontal, colors: [Color(0xFF00008B)], emblem: Colors.white),
    Country(name: 'Saudi Arabia', code: 'KSA', style: FlagStyle.horizontal, colors: [Color(0xFF006C35)], emblem: Colors.white),
    Country(name: 'Qatar', code: 'QAT', style: FlagStyle.vertical, colors: [Colors.white, Color(0xFF8A1538)]),
    Country(name: 'Uzbekistan', code: 'UZB', style: FlagStyle.horizontal, colors: [Color(0xFF0099B5), Colors.white, Color(0xFF1EB53A)]),
    Country(name: 'Jordan', code: 'JOR', style: FlagStyle.horizontal, colors: [Colors.black, Colors.white, Color(0xFF007A3D)]),
    Country(name: 'Iraq', code: 'IRQ', style: FlagStyle.horizontal, colors: [Color(0xFFCE1126), Colors.white, Colors.black]),
    Country(name: 'Argentina', code: 'ARG', style: FlagStyle.horizontal, colors: [Color(0xFF74ACDF), Colors.white, Color(0xFF74ACDF)], emblem: Color(0xFFF6B40E)),
    Country(name: 'Brazil', code: 'BRA', style: FlagStyle.vertical, colors: [Color(0xFF009C3B)], emblem: Color(0xFFFFDF00)),
    Country(name: 'Uruguay', code: 'URU', style: FlagStyle.horizontal, colors: [Colors.white, Color(0xFF0038A8), Colors.white, Color(0xFF0038A8)], emblem: Color(0xFFFCD116)),
    Country(name: 'Colombia', code: 'COL', style: FlagStyle.horizontal, colors: [Color(0xFFFCD116), Color(0xFF003893), Color(0xFFCE1126)]),
    Country(name: 'Ecuador', code: 'ECU', style: FlagStyle.horizontal, colors: [Color(0xFFFFDD00), Color(0xFF034EA2), Color(0xFFED1C24)]),
    Country(name: 'Paraguay', code: 'PAR', style: FlagStyle.horizontal, colors: [Color(0xFFD52B1E), Colors.white, Color(0xFF0038A8)]),
    Country(name: 'New Zealand', code: 'NZL', style: FlagStyle.horizontal, colors: [Color(0xFF00247D)], emblem: Color(0xFFCC142B)),
    Country(name: 'Morocco', code: 'MAR', style: FlagStyle.vertical, colors: [Color(0xFFC1272D)], emblem: Color(0xFF006233)),
    Country(name: 'Senegal', code: 'SEN', style: FlagStyle.vertical, colors: [Color(0xFF00853F), Color(0xFFFDEF42), Color(0xFFE31B23)]),
    Country(name: 'Egypt', code: 'EGY', style: FlagStyle.horizontal, colors: [Color(0xFFCE1126), Colors.white, Colors.black], emblem: Color(0xFFC09300)),
    Country(name: 'Algeria', code: 'ALG', style: FlagStyle.vertical, colors: [Color(0xFF006233), Colors.white], emblem: Color(0xFFD21034)),
    Country(name: 'Tunisia', code: 'TUN', style: FlagStyle.vertical, colors: [Color(0xFFE70013)], emblem: Colors.white),
    Country(name: 'South Africa', code: 'RSA', style: FlagStyle.horizontal, colors: [Color(0xFF007A4D), Color(0xFFFFB81C), Color(0xFFDE3831)]),
    Country(name: 'Ivory Coast', code: 'CIV', style: FlagStyle.vertical, colors: [Color(0xFFF77F00), Colors.white, Color(0xFF009E60)]),
    Country(name: 'Ghana', code: 'GHA', style: FlagStyle.horizontal, colors: [Color(0xFFCE1126), Color(0xFFFCD116), Color(0xFF006B3F)], emblem: Colors.black),
    Country(name: 'Cape Verde', code: 'CPV', style: FlagStyle.horizontal, colors: [Color(0xFF003893), Colors.white, Color(0xFF003893)]),
    Country(name: 'DR Congo', code: 'COD', style: FlagStyle.vertical, colors: [Color(0xFF007FFF)], emblem: Color(0xFFF7D618)),
    Country(name: 'England', code: 'ENG', style: FlagStyle.cross, colors: [Colors.white, Color(0xFFCE1124)]),
    Country(name: 'France', code: 'FRA', style: FlagStyle.vertical, colors: [Color(0xFF0055A4), Colors.white, Color(0xFFEF4135)]),
    Country(name: 'Spain', code: 'ESP', style: FlagStyle.horizontal, colors: [Color(0xFFAA151B), Color(0xFFF1BF00), Color(0xFFAA151B)]),
    Country(name: 'Germany', code: 'GER', style: FlagStyle.horizontal, colors: [Colors.black, Color(0xFFDD0000), Color(0xFFFFCE00)]),
    Country(name: 'Portugal', code: 'POR', style: FlagStyle.vertical, colors: [Color(0xFF006600), Color(0xFFFF0000)], emblem: Color(0xFFFFFF00)),
    Country(name: 'Netherlands', code: 'NED', style: FlagStyle.horizontal, colors: [Color(0xFFAE1C28), Colors.white, Color(0xFF21468B)]),
    Country(name: 'Belgium', code: 'BEL', style: FlagStyle.vertical, colors: [Colors.black, Color(0xFFFAE042), Color(0xFFED2939)]),
    Country(name: 'Croatia', code: 'CRO', style: FlagStyle.horizontal, colors: [Color(0xFFFF0000), Colors.white, Color(0xFF171796)]),
    Country(name: 'Switzerland', code: 'SUI', style: FlagStyle.cross, colors: [Color(0xFFFF0000), Colors.white]),
    Country(name: 'Austria', code: 'AUT', style: FlagStyle.horizontal, colors: [Color(0xFFED2939), Colors.white, Color(0xFFED2939)]),
    Country(name: 'Scotland', code: 'SCO', style: FlagStyle.saltire, colors: [Color(0xFF0065BF), Colors.white]),
    Country(name: 'Norway', code: 'NOR', style: FlagStyle.cross, colors: [Color(0xFFBA0C2F), Color(0xFF00205B)]),
    Country(name: 'Bosnia and Herzegovina', code: 'BIH', style: FlagStyle.vertical, colors: [Color(0xFF002395)], emblem: Color(0xFFFECB00)),
    Country(name: 'Sweden', code: 'SWE', style: FlagStyle.cross, colors: [Color(0xFF006AA7), Color(0xFFFECC00)]),
    Country(name: 'Türkiye', code: 'TUR', style: FlagStyle.vertical, colors: [Color(0xFFE30A17)], emblem: Colors.white),
    Country(name: 'Czechia', code: 'CZE', style: FlagStyle.horizontal, colors: [Colors.white, Color(0xFFD7141A)], emblem: Color(0xFF11457E)),
    Country(name: 'Panama', code: 'PAN', style: FlagStyle.vertical, colors: [Colors.white, Color(0xFFD21034)], emblem: Color(0xFF005293)),
    Country(name: 'Curacao', code: 'CUW', style: FlagStyle.horizontal, colors: [Color(0xFF002B7F)], emblem: Color(0xFFF9E814)),
    Country(name: 'Haiti', code: 'HAI', style: FlagStyle.horizontal, colors: [Color(0xFF00209F), Color(0xFFD21034)]),
  ];

  // ---- special bonus picks (not officially in the tournament 😉) ----
  static const Country lebanon = Country(
    name: 'Lebanon',
    code: 'LBN',
    style: FlagStyle.horizontal,
    colors: [Color(0xFFED1C24), Colors.white, Color(0xFFED1C24)],
    emblem: Color(0xFF00A651), // the cedar
    isBonus: true,
  );

  static const Country manUnited = Country(
    name: 'Manchester United',
    code: 'MUFC',
    style: FlagStyle.vertical,
    colors: [Color(0xFFDA291C)],
    emblem: Color(0xFFFBE122),
    isBonus: true,
  );

  /// Full list used by the prediction selector: 48 teams + 2 bonus picks.
  static List<Country> get allPicks => [...teams, lebanon, manUnited];

  static Country? byName(String name) {
    for (final c in allPicks) {
      if (c.name == name) return c;
    }
    return null;
  }
}
