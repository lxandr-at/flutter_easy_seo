import 'hotel.dart';

class SampleData {
  SampleData._();

  static final DateTime _today = DateTime(2026, 6, 28);

  static final List<Hotel> hotels = [
    Hotel(
      id: '1',
      name: 'Hotel Alpenglühen',
      description:
          'Ein luxuriöses 5-Sterne Hotel eingebettet in die atemberaubende Berglandschaft der Alpen. Genießen Sie exzellenten Service, feinste Küche und einen unvergesslichen Ausblick.',
      location: 'Zermatt, Schweiz',
      stars: 5,
      pricePerNight: 280,
      imageUrl: '/images/hotel1.jpg',
      reviews: [
        Review(
          author: 'Anna Müller',
          text: 'Ein unvergesslicher Aufenthalt! Das Personal war äußerst zuvorkommend.',
          rating: 5,
          date: _today.subtract(const Duration(days: 30)),
        ),
        Review(
          author: 'Thomas Berger',
          text: 'Die Aussicht von der Suite war atemberaubend. Absolut empfehlenswert.',
          rating: 5,
          date: _today.subtract(const Duration(days: 60)),
        ),
      ],
    ),
    Hotel(
      id: '2',
      name: 'Seehotel Panorama',
      description:
          'Direkt am malerischen See gelegen, bietet das Seehotel Panorama Erholung pur. Genießen Sie den Wellnessbereich und die regionale Küche.',
      location: 'Tegernsee, Deutschland',
      stars: 4,
      pricePerNight: 190,
      imageUrl: '/images/hotel2.jpg',
      reviews: [
        Review(
          author: 'Sarah Klein',
          text: 'Tolles Hotel mit fantastischem Seeblick. Das Frühstück war hervorragend.',
          rating: 4,
          date: _today.subtract(const Duration(days: 15)),
        ),
        Review(
          author: 'Michael Wolf',
          text: 'Sehr schönes Ambiente, aber die Zimmer könnten etwas moderner sein.',
          rating: 4,
          date: _today.subtract(const Duration(days: 45)),
        ),
        Review(
          author: 'Julia Schmidt',
          text: 'Perfekt für einen entspannten Wellness-Urlaub. Komme gerne wieder!',
          rating: 5,
          date: _today.subtract(const Duration(days: 90)),
        ),
      ],
    ),
    Hotel(
      id: '3',
      name: 'Gasthof zur Post',
      description:
          'Ein traditioneller bayerischer Gasthof mit Charme und Gemütlichkeit. Herzliche Gastfreundschaft und hausgemachte Spezialitäten erwartet Sie.',
      location: 'Oberammergau, Deutschland',
      stars: 3,
      pricePerNight: 95,
      imageUrl: '/images/hotel3.jpg',
      reviews: [
        Review(
          author: 'Hans Wagner',
          text: 'Urgemütlich und sehr freundlich. Das Essen war ausgezeichnet!',
          rating: 4,
          date: _today.subtract(const Duration(days: 20)),
        ),
      ],
    ),
    Hotel(
      id: '4',
      name: 'Château de la Loire',
      description:
          'Ein erlesenes Château-Hotel im Herzen des Loire-Tals. Historische Architektur trifft auf modernen Luxus in einer der schönsten Regionen Frankreichs.',
      location: 'Loiretal, Frankreich',
      stars: 5,
      pricePerNight: 350,
      imageUrl: '/images/hotel4.jpg',
      reviews: [
        Review(
          author: 'Pierre Dubois',
          text: 'Un séjour magnifique. Le château est magnifique et le service impeccable.',
          rating: 5,
          date: _today.subtract(const Duration(days: 25)),
        ),
        Review(
          author: 'Marie Laurent',
          text: 'Ein Traum von einem Hotel. Die Weinverkostung war ein Highlight.',
          rating: 5,
          date: _today.subtract(const Duration(days: 55)),
        ),
      ],
    ),
    Hotel(
      id: '5',
      name: 'Boutique Hotel Mitte',
      description:
          'Ein stilvolles Boutique-Hotel im Herzen der Stadt. Perfekt für Städtereisende mit Sinn für Design und Komfort.',
      location: 'Berlin, Deutschland',
      stars: 4,
      pricePerNight: 150,
      imageUrl: '/images/hotel5.jpg',
      reviews: [
        Review(
          author: 'David Fischer',
          text: 'Zentrale Lage, schickes Design und freundliches Personal. Ideal für einen Städtetrip.',
          rating: 4,
          date: _today.subtract(const Duration(days: 10)),
        ),
        Review(
          author: 'Laura Hoffmann',
          text: 'Die Dachterrasse mit Blick über Berlin ist ein Highlight!',
          rating: 5,
          date: _today.subtract(const Duration(days: 35)),
        ),
        Review(
          author: 'Felix Braun',
          text: 'Gutes Preis-Leistungs-Verhältnis für die Innenstadtlage.',
          rating: 4,
          date: _today.subtract(const Duration(days: 70)),
        ),
      ],
    ),
    Hotel(
      id: '6',
      name: 'Berggasthof Edelweiß',
      description:
          'Ein uriger Berggasthof auf 1.800 Metern Höhe. Ideal für Wanderer und Naturliebhaber, die Ruhe und Ursprünglichkeit suchen.',
      location: 'Saalbach, Österreich',
      stars: 3,
      pricePerNight: 75,
      imageUrl: '/images/hotel6.jpg',
      reviews: [
        Review(
          author: 'Klaus Richter',
          text: 'Einfach, aber herzlich. Die Lage ist ein Traum für Wanderer.',
          rating: 4,
          date: _today.subtract(const Duration(days: 40)),
        ),
      ],
    ),
  ];

  static List<Reservation> sampleReservations = [
    Reservation(
      id: 'res-1',
      hotelId: '1',
      hotelName: 'Hotel Alpenglühen',
      roomType: 'Deluxe Suite',
      checkIn: DateTime(2026, 7, 14),
      checkOut: DateTime(2026, 7, 21),
      status: 'Bestätigt',
      totalPrice: 1960,
    ),
    Reservation(
      id: 'res-2',
      hotelId: '6',
      hotelName: 'Berggasthof Edelweiß',
      roomType: 'Standard Zimmer',
      checkIn: DateTime(2026, 12, 28),
      checkOut: DateTime(2027, 1, 4),
      status: 'Bestätigt',
      totalPrice: 525,
    ),
  ];
}
