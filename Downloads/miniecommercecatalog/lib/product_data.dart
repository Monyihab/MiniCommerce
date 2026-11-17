
import 'product.dart';

const Product headphones = Product(
  name: 'Wireless Headphones',
  price: 1200,
  category: 'Electronics',
  imagePath: 'assets/Headphones.png',
  description:
      'Comfortable wireless headphones with clear sound. '
      'Perfect for listening to music and enjoying your favorite videos.',
);

const Product smartWatch = Product(
  name: 'Smart Watch',
  price: 1800,
  category: 'Electronics',
  imagePath: 'assets/SmartWatch.png',
  description:
      'A stylish smartwatch for everyday use. '
      'Its modern design makes it a great accessory.',
);

const Product casualShirt = Product(
  name: 'Casual T-Shirt',
  price: 450,
  category: 'Clothing',
  imagePath: 'assets/CasualShirt.png',
  description:
      'A comfortable T-shirt for casual outfits. '
      'An excellent choice for everyday wear.',
);

const Product runningShoes = Product(
  name: 'Running Shoes',
  price: 1500,
  category: 'Clothing',
  imagePath: 'assets/RunningShoes.png',
  description:
      'Lightweight shoes for running and walking. '
      'Designed for comfortable everyday movement.',
);

const Product coffeeMug = Product(
  name: 'Coffee Mug',
  price: 180,
  category: 'Accessories',
  imagePath: 'assets/CoffeMug.png',
  description:
      'A simple mug for your favorite hot drinks. '
      'Enjoy your coffee or tea at home or at work.',
);

const Product travelBackpack = Product(
  name: 'Travel Backpack',
  price: 850,
  category: 'Accessories',
  imagePath: 'assets/TravelBackpack.png',
  description:
      'A practical backpack for school and travel. '
      'Carry your everyday essentials conveniently.',
);

const int productCount = 6;

Product productAt(int index) {
  switch (index) {
    case 0:
      return headphones;
    case 1:
      return smartWatch;
    case 2:
      return casualShirt;
    case 3:
      return runningShoes;
    case 4:
      return coffeeMug;
    default:
      return travelBackpack;
  }
}
