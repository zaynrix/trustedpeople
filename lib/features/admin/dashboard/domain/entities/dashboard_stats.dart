class DashboardStats {
  final int todayVisitors;
  final double percentChange;
  final int totalVisitors;
  final int monthlyVisitors;
  final String avgSessionDuration;

  DashboardStats({
    required this.todayVisitors,
    required this.percentChange,
    required this.totalVisitors,
    required this.monthlyVisitors,
    required this.avgSessionDuration,
  });

  factory DashboardStats.fromMap(Map<String, dynamic> map) {
    return DashboardStats(
      todayVisitors: map['todayVisitors'] ?? 0,
      percentChange: (map['percentChange'] ?? 0).toDouble(),
      totalVisitors: map['totalVisitors'] ?? 0,
      monthlyVisitors: map['monthlyVisitors'] ?? 0,
      avgSessionDuration: map['avgSessionDuration'] ?? '0:00',
    );
  }
}

class ChartDataPoint {
  final String date;
  final int visits;
  final String day;

  ChartDataPoint({
    required this.date,
    required this.visits,
    required this.day,
  });

  factory ChartDataPoint.fromMap(Map<String, dynamic> map) {
    return ChartDataPoint(
      date: map['date'] ?? '',
      visits: map['visits'] ?? 0,
      day: map['day'] ?? '',
    );
  }
}

class VisitorLocation {
  final String ipAddress;
  final String country;
  final String city;
  final String region;
  final double latitude;
  final double longitude;
  final String timestamp;

  VisitorLocation({
    required this.ipAddress,
    required this.country,
    required this.city,
    required this.region,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  factory VisitorLocation.fromMap(Map<String, dynamic> map) {
    return VisitorLocation(
      ipAddress: map['ipAddress'] ?? '',
      country: map['country'] ?? '',
      city: map['city'] ?? '',
      region: map['region'] ?? '',
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      timestamp: map['timestamp'] ?? '',
    );
  }
}
