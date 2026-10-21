import 'dart:async';

import 'package:flutter/material.dart';

import '../core/localization.dart';
import '../models/app_notification.dart';
import '../models/farm_advice.dart';
import '../models/farm_models.dart';
import '../models/planting_guide.dart';
import '../models/price_prediction.dart';
import '../models/weather_models.dart';
import '../services/advice_service.dart';
import '../services/farmer_repository.dart';
import '../services/notification_service.dart';
import '../services/price_prediction_service.dart';
import '../services/weather_service.dart';

class DashboardProvider extends ChangeNotifier {
  final _repo = FarmerRepository();
  final _weather = WeatherService();
  final _advice = AdviceService();
  final _pricing = PricePredictionService();
  final _notifService = NotificationService();

  Timer? _timer;

  // Language State
  AppLanguage currentLanguage = AppLanguage.tagalog; // Default to Tagalog

  bool get isTagalog => currentLanguage == AppLanguage.tagalog;

  void setLanguage(AppLanguage lang) {
    if (currentLanguage != lang) {
      currentLanguage = lang;
      notifyListeners();
    }
  }

  // Display State - laki ng teksto (1.0 = normal)
  double textScale = 1.0;

  void setTextScale(double v) {
    if (textScale != v) {
      textScale = v;
      notifyListeners();
    }
  }

  // Auth & Session State
  bool isLoggedIn = true;

  void logout() {
    isLoggedIn = false;
    notifyListeners();
  }

  void login() {
    isLoggedIn = true;
    notifyListeners();
  }

  // Account Metadata (view only - galing sa admin)
  String phoneNumber = '+63 912 345 6789';
  String birthday = '08/11/2001';

  // Notifications List State
  List<AppNotification> notifications = [];

  int get unreadNotificationCount => notifications.where((n) => !n.isRead).length;

  void markAllNotificationsRead() {
    for (final n in notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  void markNotificationRead(String id) {
    for (final n in notifications) {
      if (n.id == id) {
        n.isRead = true;
        break;
      }
    }
    notifyListeners();
  }

  // Data State
  FarmerProfile? profile;
  List<FarmPlot> plots = [];
  List<CropRecord> history = [];
  List<PlantingGuide> guides = [];
  WeatherBundle? weather;
  List<FarmAdvice> advice = [];
  List<PricePrediction> predictions = [];
  DateTime? lastUpdated;
  bool isLoading = true;
  bool weatherStale = false;
  bool hasError = false; // ang teksto ng error ay nasa ARB (errorLoad)

  List<WeatherDay> get forecast => weather?.daily ?? [];

  void start() {
    load();
    _timer = Timer.periodic(const Duration(minutes: 10), (_) => load(silent: true));
  }

  Future<void> load({bool silent = false}) async {
    if (!silent && weather == null) {
      isLoading = true;
      notifyListeners();
    }
    hasError = false;
    try {
      profile ??= await _repo.getProfile();
      plots = await _repo.getPlots();
      history = await _repo.getCropHistory();
      guides = _repo.getPlantingGuides();
      weather = await _weather.fetch();
      advice = _advice.build(weather!);
      predictions = _pricing.predict(profile!.cropTypes, weather!.daily);
      notifications = _notifService.build();

      lastUpdated = DateTime.now();
      weatherStale = false;
    } catch (e) {
      if (weather == null) {
        hasError = true;
      } else {
        weatherStale = true;
      }
    }
    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}