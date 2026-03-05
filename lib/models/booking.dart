import 'package:flutter/material.dart';

enum BookingMainStatus { upcoming, ongoing, completed }

enum BookingTimeFilter { today, tomorrow, thisWeek, haircut }

enum BookingActionStatus { newRequest, confirmed, pending, rejected }

class Booking {
  final String id;
  final String customerName;
  final String? customerPhone;
  final String serviceName;
  final String priceDisplay;
  final int durationMinutes;
  final String timeDisplay;
  final String locationLabel;
  final String locationDetail;
  final String avatarUrl;
  final BookingMainStatus mainStatus;
  final BookingTimeFilter timeFilter;
  final BookingActionStatus actionStatus;

  const Booking({
    required this.id,
    required this.customerName,
    this.customerPhone,
    required this.serviceName,
    required this.priceDisplay,
    required this.durationMinutes,
    required this.timeDisplay,
    required this.locationLabel,
    required this.locationDetail,
    required this.avatarUrl,
    required this.mainStatus,
    required this.timeFilter,
    required this.actionStatus,
  });

  Booking copyWith({
    BookingMainStatus? mainStatus,
    BookingActionStatus? actionStatus,
  }) {
    return Booking(
      id: id,
      customerName: customerName,
      customerPhone: customerPhone,
      serviceName: serviceName,
      priceDisplay: priceDisplay,
      durationMinutes: durationMinutes,
      timeDisplay: timeDisplay,
      locationLabel: locationLabel,
      locationDetail: locationDetail,
      avatarUrl: avatarUrl,
      mainStatus: mainStatus ?? this.mainStatus,
      timeFilter: timeFilter,
      actionStatus: actionStatus ?? this.actionStatus,
    );
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    final statusStr = (json['status'] ?? '').toString().toUpperCase();
    BookingMainStatus status;
    switch (statusStr) {
      case 'ONGOING':
        status = BookingMainStatus.ongoing;
        break;
      case 'COMPLETED':
        status = BookingMainStatus.completed;
        break;
      case 'UPCOMING':
      default:
        status = BookingMainStatus.upcoming;
        break;
    }

    // Format time display
    final date = json['slotDate'] ?? '';
    final start = json['startTime'] ?? '';
    final end = json['endTime'] ?? '';
    final timeDisplay = date.isNotEmpty ? '$date · $start - $end' : '$start - $end';

    return Booking(
      id: json['bookingId']?.toString() ?? '',
      customerName: json['customerName'] ?? 'Unknown',
      customerPhone: json['customerPhone'],
      serviceName: json['serviceType'] ?? 'Service',
      priceDisplay: 'N/A', // Not in current API
      durationMinutes: 30, // Default duration
      timeDisplay: timeDisplay,
      locationLabel: 'At Salon',
      locationDetail: json['customerPhone'] ?? '',
      avatarUrl: '',
      mainStatus: status,
      timeFilter: BookingTimeFilter.today, // Map appropriately if needed
      actionStatus: BookingActionStatus.confirmed,
    );
  }

  String get statusString {
    switch (mainStatus) {
      case BookingMainStatus.ongoing:
        return 'ONGOING';
      case BookingMainStatus.completed:
        return 'COMPLETED';
      case BookingMainStatus.upcoming:
      default:
        return 'UPCOMING';
    }
  }

  BookingMainStatus? get nextStatus {
    switch (mainStatus) {
      case BookingMainStatus.upcoming:
        return BookingMainStatus.ongoing;
      case BookingMainStatus.ongoing:
        return BookingMainStatus.completed;
      case BookingMainStatus.completed:
      default:
        return null;
    }
  }
}

const List<Booking> kMockBookings = [
  Booking(
    id: '1',
    customerName: 'Aarav Mehta',
    serviceName: 'Haircut + Beard Grooming',
    priceDisplay: '₹850',
    durationMinutes: 45,
    timeDisplay: 'Today · 4:30 PM',
    locationLabel: 'At Salon',
    locationDetail: 'Khar West, Mumbai',
    avatarUrl: '',
    mainStatus: BookingMainStatus.upcoming,
    timeFilter: BookingTimeFilter.today,
    actionStatus: BookingActionStatus.confirmed,
  ),
  Booking(
    id: '2',
    customerName: 'Riya Kapoor',
    serviceName: 'Facial + Cleanup',
    priceDisplay: '₹1,200',
    durationMinutes: 60,
    timeDisplay: 'Today · 6:15 PM',
    locationLabel: 'Home Service',
    locationDetail: 'Bandra East · Flat 702',
    avatarUrl: '',
    mainStatus: BookingMainStatus.upcoming,
    timeFilter: BookingTimeFilter.today,
    actionStatus: BookingActionStatus.pending,
  ),
  Booking(
    id: '3',
    customerName: 'Karan Patel',
    serviceName: 'Hair Styling',
    priceDisplay: '₹650',
    durationMinutes: 30,
    timeDisplay: 'Started · 3:10 PM',
    locationLabel: 'At Salon',
    locationDetail: 'Chair #2',
    avatarUrl: '',
    mainStatus: BookingMainStatus.ongoing,
    timeFilter: BookingTimeFilter.today,
    actionStatus: BookingActionStatus.confirmed,
  ),
];
