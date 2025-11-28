import 'package:flutter/material.dart';

enum BookingMainStatus { upcoming, ongoing, completed }

enum BookingTimeFilter { today, tomorrow, thisWeek, haircut }

enum BookingActionStatus { newRequest, confirmed, pending, rejected }

class Booking {
  final String id;
  final String customerName;
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
