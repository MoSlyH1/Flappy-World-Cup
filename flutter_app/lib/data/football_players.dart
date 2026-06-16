// lib/data/football_players.dart
// The bird becomes a different football "star" each round. These are
// ORIGINAL, stylised characters (a bird wearing a national-team kit),
// not photos — just jersey colours + a name + country so each round
// feels different and on-theme.

import 'package:flutter/material.dart';

class FootballPlayer {
  final String name;
  final String country; // must match a Country.name in world_cup_teams.dart
  final Color shirt; // jersey body colour (the bird's body)
  final Color trim; // secondary jersey colour (a chest stripe)
  final Color skin; // head colour
  final Color hair; // hair colour

  const FootballPlayer({
    required this.name,
    required this.country,
    required this.shirt,
    required this.trim,
    required this.skin,
    required this.hair,
  });
}

class Players {
  Players._();

  static const List<FootballPlayer> all = [
    FootballPlayer(name: 'Messi', country: 'Argentina', shirt: Color(0xFF74ACDF), trim: Colors.white, skin: Color(0xFFE8B98A), hair: Color(0xFF3A2A1A)),
    FootballPlayer(name: 'Ronaldo', country: 'Portugal', shirt: Color(0xFF8B0000), trim: Color(0xFF006600), skin: Color(0xFFE0A878), hair: Color(0xFF2A1B10)),
    FootballPlayer(name: 'Mbappé', country: 'France', shirt: Color(0xFF1A2C6B), trim: Colors.white, skin: Color(0xFF8D5524), hair: Color(0xFF1A1208)),
    FootballPlayer(name: 'Neymar', country: 'Brazil', shirt: Color(0xFFFFDF00), trim: Color(0xFF009C3B), skin: Color(0xFFD9A066), hair: Color(0xFF6B4A2A)),
    FootballPlayer(name: 'Vinícius', country: 'Brazil', shirt: Color(0xFFFFDF00), trim: Color(0xFF003893), skin: Color(0xFF7A4A24), hair: Color(0xFF120C06)),
    FootballPlayer(name: 'Bellingham', country: 'England', shirt: Colors.white, trim: Color(0xFFCE1124), skin: Color(0xFFD9A066), hair: Color(0xFF2A1B10)),
    FootballPlayer(name: 'Kane', country: 'England', shirt: Colors.white, trim: Color(0xFF1A2C6B), skin: Color(0xFFE8B98A), hair: Color(0xFF6B4A2A)),
    FootballPlayer(name: 'Yamal', country: 'Spain', shirt: Color(0xFFAA151B), trim: Color(0xFFF1BF00), skin: Color(0xFF8D5524), hair: Color(0xFF120C06)),
    FootballPlayer(name: 'Haaland', country: 'Norway', shirt: Color(0xFFBA0C2F), trim: Color(0xFF00205B), skin: Color(0xFFF0C9A0), hair: Color(0xFFE6C200)),
    FootballPlayer(name: 'De Bruyne', country: 'Belgium', shirt: Color(0xFFED2939), trim: Colors.black, skin: Color(0xFFF0C9A0), hair: Color(0xFFB8702A)),
    FootballPlayer(name: 'Modrić', country: 'Croatia', shirt: Color(0xFFFF0000), trim: Colors.white, skin: Color(0xFFF0C9A0), hair: Color(0xFFD9C3A0)),
    FootballPlayer(name: 'Salah', country: 'Egypt', shirt: Color(0xFFCE1126), trim: Colors.white, skin: Color(0xFFC68642), hair: Color(0xFF1A1208)),
    FootballPlayer(name: 'Son', country: 'South Korea', shirt: Colors.white, trim: Color(0xFFCD2E3A), skin: Color(0xFFE8C39E), hair: Color(0xFF120C06)),
    FootballPlayer(name: 'Pulisic', country: 'United States', shirt: Color(0xFF3C3B6E), trim: Color(0xFFB22234), skin: Color(0xFFE8B98A), hair: Color(0xFF5A3A20)),
    // Manchester United nod (Jad's club) — wears the red kit.
    FootballPlayer(name: 'Bruno (Man Utd)', country: 'Portugal', shirt: Color(0xFFDA291C), trim: Color(0xFFFBE122), skin: Color(0xFFE0A878), hair: Color(0xFF2A1B10)),
    // Lebanon nod (Jad's country) — the Cedars.
    FootballPlayer(name: 'The Cedar', country: 'Lebanon', shirt: Color(0xFFED1C24), trim: Color(0xFF00A651), skin: Color(0xFFD9A066), hair: Color(0xFF1A1208)),
  ];
}
