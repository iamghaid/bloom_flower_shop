class FlowerProduct {
  final String id;
  final String name;
  final String tagline;
  final String emoji;
  final double price;
  final String category;
  final String color;

  const FlowerProduct({
    required this.id,
    required this.name,
    required this.tagline,
    required this.emoji,
    required this.price,
    required this.category,
    required this.color,
  });
}

const List<FlowerProduct> kProducts = [
  FlowerProduct(
    id: '1',
    name: 'Blush Reverie',
    tagline: 'Pink peonies & soft white ranunculus',
    emoji: '🌸',
    price: 68.00,
    category: 'Bouquet',
    color: '#F2C4C4',
  ),
  FlowerProduct(
    id: '2',
    name: 'Golden Hour',
    tagline: 'Sunflowers, marigold & dried wheat',
    emoji: '🌻',
    price: 54.00,
    category: 'Arrangement',
    color: '#F5D98A',
  ),
  FlowerProduct(
    id: '3',
    name: 'Midnight Garden',
    tagline: 'Deep violet anemones & black tulips',
    emoji: '💜',
    price: 82.00,
    category: 'Bouquet',
    color: '#C4A8D4',
  ),
  FlowerProduct(
    id: '4',
    name: 'Wild Meadow',
    tagline: 'Lavender, chamomile & poppy stems',
    emoji: '🌿',
    price: 48.00,
    category: 'Wildflower',
    color: '#B8D4B0',
  ),
  FlowerProduct(
    id: '5',
    name: 'Rose Eternelle',
    tagline: 'Preserved red roses in a glass dome',
    emoji: '🌹',
    price: 120.00,
    category: 'Preserved',
    color: '#D4908A',
  ),
  FlowerProduct(
    id: '6',
    name: 'Spring Whisper',
    tagline: 'Pastel tulips, hyacinth & lily of the valley',
    emoji: '🌷',
    price: 62.00,
    category: 'Seasonal',
    color: '#C8D4E8',
  ),
];

const List<String> kCategories = [
  'All', 'Bouquet', 'Arrangement', 'Wildflower', 'Preserved', 'Seasonal',
];
