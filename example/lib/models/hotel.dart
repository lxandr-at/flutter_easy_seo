class Review {
  final String author;
  final String text;
  final int rating;
  final DateTime date;

  const Review({
    required this.author,
    required this.text,
    required this.rating,
    required this.date,
  });
}

class Hotel {
  final String id;
  final String name;
  final String description;
  final String location;
  final int stars;
  final double pricePerNight;
  final String imageUrl;
  final List<Review> reviews;

  const Hotel({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.stars,
    required this.pricePerNight,
    required this.imageUrl,
    required this.reviews,
  });
}

class Reservation {
  final String id;
  final String hotelId;
  final String hotelName;
  final String roomType;
  final DateTime checkIn;
  final DateTime checkOut;
  final String status;
  final double totalPrice;

  const Reservation({
    required this.id,
    required this.hotelId,
    required this.hotelName,
    required this.roomType,
    required this.checkIn,
    required this.checkOut,
    required this.status,
    required this.totalPrice,
  });

  int get nights => checkOut.difference(checkIn).inDays;
}
