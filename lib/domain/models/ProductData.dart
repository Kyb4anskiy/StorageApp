
class ProductData {

  int id;
  String uuid;
  String title;
  String description;
  bool isActive;
  String linkImage;

  ProductData({
    required this.id,
    required this.uuid,
    required this.title,
    required this.description,
    required this.isActive,
    required this.linkImage,
  });

  factory ProductData.fromMap(Map<String, dynamic> row) {
    return ProductData(
      id: row['id'] as int,
      uuid: row['uuid'] as String,
      title: row['title'] as String,
      description: row['description'] as String,
      linkImage: row['link_image'] as String,
      isActive: (row['status_id'] as int) == 1, // 1=in_stock, 2=out_of_stock
    );
  }

  static Map<String, String> toQRString({
    required String uuid,
    required String title,
    required String description
}){
    return {
      'uuid': uuid,
      'title': title,
      'description': description,
    };
  }


}

// List<ProductData> products = [
//   ProductData(
//     id: 1,
//     title: "Резиновые шлёпанцы",
//     description: "Лёгкие и удобные шлёпанцы для дома, пляжа и повседневной носки. "
//         "Изготовлены из мягкого материала, который не натирает ногу и хорошо держит форму. "
//         "Подходят для длительной ходьбы и быстро высыхают после воды.",
//     isActive: true,
//     linkImage: "assets/images/cart1.png",
//   ),
//
//   ProductData(
//     id: 2,
//     title: "Спортивная футболка",
//     description: "Дышащая футболка из лёгкой ткани, предназначенная для спорта и активного отдыха. "
//         "Материал хорошо отводит влагу и позволяет коже дышать даже при интенсивных тренировках. "
//         "Идеально подходит для занятий в зале и на улице.",
//     isActive: true,
//     linkImage: "assets/images/cart2.png",
//   ),
//
//   ProductData(
//     id: 3,
//     title: "Городской рюкзак",
//     description: "Компактный рюкзак для повседневного использования. "
//         "Имеет несколько отделений для ноутбука, документов и личных вещей. "
//         "Прочные молнии и удобные регулируемые лямки делают его отличным выбором для работы или учёбы.",
//     isActive: false,
//     linkImage: "assets/images/cart3.png",
//   ),
//
//   ProductData(
//     id: 4,
//     title: "Беспроводные наушники",
//     description: "Современные Bluetooth-наушники с чистым звучанием и удобной посадкой. "
//         "Поддерживают быстрое подключение к смартфону и работают до 6 часов без подзарядки. "
//         "Подходят для прослушивания музыки, подкастов и общения.",
//     isActive: true,
//     linkImage: "assets/images/cart4.png",
//   ),
//
//   ProductData(
//     id: 5,
//     title: "Умные часы",
//     description: "Функциональные смарт-часы с мониторингом активности и уведомлениями со смартфона. "
//         "Отслеживают шаги, пульс и уровень физической активности. "
//         "Стильный дизайн позволяет носить их как на тренировке, так и в повседневной жизни.",
//     isActive: false,
//     linkImage: "assets/images/cart5.png",
//   ),
//
//   ProductData(
//     id: 6,
//     title: "Портативная колонка",
//     description: "Компактная беспроводная колонка с мощным звучанием. "
//         "Легко подключается к телефону через Bluetooth и обеспечивает стабильное соединение. "
//         "Подходит для прогулок, поездок и отдыха на природе.",
//     isActive: true,
//     linkImage: "assets/images/cart6.png",
//   ),
//
//   ProductData(
//     id: 7,
//     title: "Кружка с термоизоляцией",
//     description: "Термокружка из нержавеющей стали, сохраняющая температуру напитков "
//         "в течение нескольких часов. Удобная крышка предотвращает проливание, "
//         "а компактный размер позволяет брать её с собой в дорогу.",
//     isActive: false,
//     linkImage: "assets/images/cart7.png",
//   ),
//
//   ProductData(
//     id: 8,
//     title: "Настольная лампа",
//     description: "Современная настольная лампа с регулируемой яркостью. "
//         "Подходит для работы, учёбы или чтения вечером. "
//         "Минималистичный дизайн хорошо вписывается в интерьер рабочего стола.",
//     isActive: true,
//     linkImage: "assets/images/cart8.png",
//   ),
// ];