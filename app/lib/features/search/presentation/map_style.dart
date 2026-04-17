// Google Maps style JSON for the MapSearchPage.
//
// Hex literals below are a feature-local exception to the "no hardcoded
// styles" rule: the Google Maps style schema is a serialized third-party
// artifact that cannot read Flutter tokens at runtime. Each hex is chosen
// to be a neutral grayscale that contrasts well with the warm orange
// markers/overlays from BrutalistPalette, without competing with them.
//
// Light (neutral cool-off-white palette):
//   #F5F5F7  ~ surface background
//   #EBEBEF  ~ subtle divider / road stroke
//   #D6D6DA  ~ water
//   #3A3A3D  ~ title / road labels
//   #8B8B90  ~ muted secondary label
//
// Dark (neutral near-black palette):
//   #0F0F11  ~ surface background
//   #1A1A1D  ~ water
//   #26262A  ~ road fill
//   #141417  ~ road stroke
//   #A8A8AD  ~ title / label
//   #6E6E74  ~ muted secondary label
//
// If the design system tokens drift, update both sides.

const String kLightMapStyleJson = '''
[
  {"elementType":"geometry","stylers":[{"color":"#F5F5F7"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#3A3A3D"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#F5F5F7"}]},
  {"featureType":"administrative.land_parcel","stylers":[{"visibility":"off"}]},
  {"featureType":"administrative.neighborhood","stylers":[{"visibility":"off"}]},
  {"featureType":"poi","stylers":[{"visibility":"off"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#FFFFFF"}]},
  {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#EBEBEF"}]},
  {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#8B8B90"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#FFFFFF"}]},
  {"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#E0E0E4"}]},
  {"featureType":"transit","stylers":[{"visibility":"off"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#D6D6DA"}]},
  {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#8B8B90"}]},
  {"featureType":"landscape","elementType":"geometry","stylers":[{"color":"#EFEFF2"}]}
]
''';

const String kDarkMapStyleJson = '''
[
  {"elementType":"geometry","stylers":[{"color":"#0F0F11"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#A8A8AD"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#0F0F11"}]},
  {"featureType":"administrative.land_parcel","stylers":[{"visibility":"off"}]},
  {"featureType":"administrative.neighborhood","stylers":[{"visibility":"off"}]},
  {"featureType":"poi","stylers":[{"visibility":"off"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#26262A"}]},
  {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#141417"}]},
  {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#6E6E74"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#2E2E33"}]},
  {"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#0F0F11"}]},
  {"featureType":"transit","stylers":[{"visibility":"off"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#1A1A1D"}]},
  {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#6E6E74"}]},
  {"featureType":"landscape","elementType":"geometry","stylers":[{"color":"#131316"}]}
]
''';
