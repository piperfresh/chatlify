extension AssetsExtension on String{
  String get svg => 'assets/svgs/$this.svg';
  String get png => 'assets/pngs/$this.png';
}