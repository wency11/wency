import '../l10n/app_localizations.dart';
import '../models/app_notification.dart';
import '../models/farm_advice.dart';
import '../models/farm_models.dart';
import '../models/price_prediction.dart';
import '../models/weather_models.dart';

/// Nagsasalin ng mga ID sa data (pananim, status, atbp.) papunta sa tekstong
/// nasa ARB. Gamitin ito bilang: `t.crop('Rice')`.
extension AppL10nData on AppLocalizations {
  String crop(String id) {
    switch (id) {
      case 'Rice':
        return cropRice;
      case 'Eggplant':
        return cropEggplant;
      case 'Tomato':
        return cropTomato;
      case 'String beans':
        return cropStringBeans;
      case 'Banana':
        return cropBanana;
      default:
        return id;
    }
  }

  String plotStatus(PlotStatus s) {
    switch (s) {
      case PlotStatus.harvested:
        return plotHarvested;
      case PlotStatus.growing:
        return plotGrowing;
    }
  }

  String weatherLabel(WeatherKind k) {
    switch (k) {
      case WeatherKind.sunny:
        return weatherSunny;
      case WeatherKind.clearNight:
        return weatherClearNight;
      case WeatherKind.partlyCloudy:
        return weatherPartlyCloudy;
      case WeatherKind.cloudy:
        return weatherCloudy;
      case WeatherKind.foggy:
        return weatherFoggy;
      case WeatherKind.drizzle:
        return weatherDrizzle;
      case WeatherKind.rain:
        return weatherRain;
      case WeatherKind.thunderstorm:
        return weatherThunderstorm;
    }
  }

  String farmAdviceTitle(AdviceType a) {
    switch (a) {
      case AdviceType.thunderstorm:
        return adviceThunderTitle;
      case AdviceType.rainToday:
        return adviceRainTitle;
      case AdviceType.hot:
        return adviceHotTitle;
      case AdviceType.wind:
        return adviceWindTitle;
      case AdviceType.fieldWork:
        return adviceFieldTitle;
      case AdviceType.normal:
        return adviceNormalTitle;
    }
  }

  String farmAdviceMessage(AdviceType a) {
    switch (a) {
      case AdviceType.thunderstorm:
        return adviceThunderMsg;
      case AdviceType.rainToday:
        return adviceRainMsg;
      case AdviceType.hot:
        return adviceHotMsg;
      case AdviceType.wind:
        return adviceWindMsg;
      case AdviceType.fieldWork:
        return adviceFieldMsg;
      case AdviceType.normal:
        return adviceNormalMsg;
    }
  }

  String notifTitle(NotificationType n) {
    switch (n) {
      case NotificationType.weather:
        return notifWeatherTitle;
      case NotificationType.market:
        return notifMarketTitle;
      case NotificationType.planting:
        return notifPlantingTitle;
      case NotificationType.pest:
        return notifPestTitle;
      case NotificationType.subsidy:
        return notifSubsidyTitle;
    }
  }

  String notifMessage(NotificationType n) {
    switch (n) {
      case NotificationType.weather:
        return notifWeatherMsg;
      case NotificationType.market:
        return notifMarketMsg;
      case NotificationType.planting:
        return notifPlantingMsg;
      case NotificationType.pest:
        return notifPestMsg;
      case NotificationType.subsidy:
        return notifSubsidyMsg;
    }
  }

  String priceReason(PriceReason r) {
    switch (r) {
      case PriceReason.heavyRain:
        return reasonHeavyRain;
      case PriceReason.dry:
        return reasonDry;
      case PriceReason.stable:
        return reasonStable;
    }
  }

  String sellTipText(SellTip s) {
    switch (s) {
      case SellTip.wait:
        return sellWait;
      case SellTip.slightRise:
        return sellSlight;
      case SellTip.sellSoon:
        return sellSoon;
    }
  }

  String guideHarvest(String cropId) {
    switch (cropId) {
      case 'Rice':
        return guideHarvestRice;
      case 'Eggplant':
        return guideHarvestEggplant;
      case 'Tomato':
        return guideHarvestTomato;
      case 'String beans':
        return guideHarvestStringBeans;
      case 'Banana':
        return guideHarvestBanana;
      default:
        return '';
    }
  }

  String guideTip(String cropId) {
    switch (cropId) {
      case 'Rice':
        return guideTipRice;
      case 'Eggplant':
        return guideTipEggplant;
      case 'Tomato':
        return guideTipTomato;
      case 'String beans':
        return guideTipStringBeans;
      case 'Banana':
        return guideTipBanana;
      default:
        return '';
    }
  }
}