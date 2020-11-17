class Currency {
  final String icon;
  final String name;
  final String code;
  final double price;
  final double volDay;
  final double volTotal;
  final double varDay;
  final double varWeek;
  Currency.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        icon = json['icon'],
        code = json['code'],
        price = json['price'],
        volDay = json['volDay'],
        volTotal = json['volTotal'],
        varDay = json['varDay'],
        varWeek = json['varWeek'];
}
