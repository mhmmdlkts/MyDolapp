class ItemTypeService {
  static const ItemType defaultItem = ItemType.other;

  static ItemType stringToEnum(String type) {
    for (var element in ItemType.values) {
      if (enumToString(element) == type) {
        return element;
      }
    }
    return defaultItem;
  }

  static String enumToString(ItemType type) => type.toString().split('.').last;

  static String enumToReadableString(ItemType type) {
    switch (type) {
      case ItemType.tShirt:
        return 'T-Shirt';
      case ItemType.pants:
        return 'Pants';
      case ItemType.shorts:
        return 'Shorts';
      case ItemType.shoe:
        return 'Shoe';
      case ItemType.coat:
        return 'Coat';
      case ItemType.jacket:
        return 'Jacket';
      case ItemType.sweater:
        return 'Sweater';
      case ItemType.other:
        return 'Other';
    }
  }
}

enum ItemType {
  tShirt,
  pants,
  shoe,
  jacket,
  coat,
  shorts,
  sweater,
  other,

}