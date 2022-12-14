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

  static int enumToZIndex(ItemType type) {
    switch (type) {
      case ItemType.coat:
        return 7;
      case ItemType.jacket:
        return 6;
      case ItemType.shoe:
        return 5;
      case ItemType.tShirt:
        return 4;
      case ItemType.sweater:
        return 3;
      case ItemType.pants:
        return 2;
      case ItemType.shorts:
        return 1;
      case ItemType.other:
        return 0;
    }
  }

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