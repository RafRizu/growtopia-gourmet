class FoodItem {
  final String id;
  final String nama;
  final String harga;
  final String deskripsi;
  final String imageAsset;
  final String kategori;
  bool tersedia;

  FoodItem({
    required this.id,
    required this.nama,
    required this.harga,
    required this.deskripsi,
    required this.imageAsset,
    this.kategori = 'Hidangan',
    this.tersedia = true,
  });

  int get hargaWl {
    final Match? match = RegExp(r'\d+').firstMatch(harga);
    return match != null ? int.parse(match.group(0)!) : 0;
  }

  FoodItem copyWith({bool? tersedia}) {
    return FoodItem(
      id: id,
      nama: nama,
      harga: harga,
      deskripsi: deskripsi,
      imageAsset: imageAsset,
      kategori: kategori,
      tersedia: tersedia ?? this.tersedia,
    );
  }
}

List<FoodItem> createInitialGrowtopiaFoods() {
  return <FoodItem>[
    FoodItem(
      id: '1',
      nama: 'Arroz con Pollo',
      harga: '25 WL',
      deskripsi:
          'Nasi ayam kaya bumbu khas Amerika Latin yang disajikan hangat.',
      imageAsset: 'assets/images/arroz_con_pollo.png',
      kategori: 'Hidangan Utama',
    ),
    FoodItem(
      id: '2',
      nama: 'Gingerbread Cookie',
      harga: '10 WL',
      deskripsi: 'Kue jahe renyah bertabur icing manis perayaan hari raya.',
      imageAsset: 'assets/images/gingerbread_cookie.png',
      kategori: 'Kue & Pastry',
    ),
    FoodItem(
      id: '3',
      nama: 'Deep-Fried Tropical Ice Cream',
      harga: '40 WL',
      deskripsi:
          'Es krim goreng renyah di luar, dingin manis buah tropis di dalam.',
      imageAsset: 'assets/images/deep_fried_tropical_ice_cream.png',
      kategori: 'Dessert',
    ),
    FoodItem(
      id: '4',
      nama: 'Berry Crepes',
      harga: '18 WL',
      deskripsi:
          'Krep tipis lembut bertabur aneka beri segar dan selai manis.',
      imageAsset: 'assets/images/berry_crepes.png',
      kategori: 'Dessert',
    ),
    FoodItem(
      id: '5',
      nama: 'Gemonade',
      harga: '12 WL',
      deskripsi:
          'Minuman limun segar berbuih yang berkilau seperti batu permata.',
      imageAsset: 'assets/images/gemonade.png',
      kategori: 'Minuman',
    ),
    FoodItem(
      id: '6',
      nama: 'Apple Strudel',
      harga: '20 WL',
      deskripsi:
          'Pastry renyah berlapis dengan isian apel kayu manis autentik.',
      imageAsset: 'assets/images/apple_strudel.png',
      kategori: 'Kue & Pastry',
    ),
    FoodItem(
      id: '7',
      nama: 'Hot Chocolatte',
      harga: '15 WL',
      deskripsi:
          'Cokelat hangat kental dengan taburan marshmallow lembut di atasnya.',
      imageAsset: 'assets/images/hot_chocolatte.png',
      kategori: 'Minuman',
    ),
    FoodItem(
      id: '8',
      nama: 'Eggs Benedict',
      harga: '30 WL',
      deskripsi:
          'Roti muffin empuk dengan telur poached dan saus hollandaise gurih.',
      imageAsset: 'assets/images/eggs_benedict.png',
      kategori: 'Hidangan Utama',
    ),
    FoodItem(
      id: '9',
      nama: 'Homemade Fish Taco',
      harga: '22 WL',
      deskripsi:
          'Taco tortilla renyah dengan potongan ikan segar dan salsa spesial.',
      imageAsset: 'assets/images/homemade_fish_taco.png',
      kategori: 'Hidangan Utama',
    ),
    FoodItem(
      id: '10',
      nama: 'Pineapple Turnover',
      harga: '16 WL',
      deskripsi:
          'Kue panggang lembut dengan karamel nanas manis yang menggoda lidah.',
      imageAsset: 'assets/images/pineapple_turnover.png',
      kategori: 'Kue & Pastry',
    ),
  ];
}

final List<FoodItem> growtopiaFoods = createInitialGrowtopiaFoods();
