import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/crop_l10n.dart';
import '../../../core/heat_index.dart';
import '../../../core/l10n_data.dart';
import '../../../dashboard_data.dart';
import '../../../l10n/app_localizations.dart';
import '../../../main.dart';
import '../../../widgets/common_widgets.dart';
import '../../../widgets/crop_image.dart';
import '../../../widgets/weather_icon.dart';
import '../crop_detail_screen.dart';

class HomeTab extends StatelessWidget {
  final DashboardProvider p;
  const HomeTab({super.key, required this.p});

  String _greeting(AppLocalizations t) {
    final h = DateTime.now().hour;
    if (h < 12) return t.greetingMorning;
    if (h < 18) return t.greetingAfternoon;
    return t.greetingEvening;
  }

  void _openCrop(BuildContext context, PlantingGuide g) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (_, __, ___) => CropDetailScreen(guide: g, p: p),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: SlideTransition(
            position: Tween(begin: const Offset(0, 0.04), end: Offset.zero)
                .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final w = p.weather!;
    final profile = p.profile!;
    final firstName = profile.name.split(' ').first;
    final heat = w.current.heat;

    // Mga oras ng ngayong araw (5 AM - 7 PM) para sa heat timeline.
    final now = w.current.time;
    final todayHours = w.hourlyAll
        .where((e) =>
    e.time.year == now.year &&
        e.time.month == now.month &&
        e.time.day == now.day &&
        e.time.hour >= 5 &&
        e.time.hour <= 19)
        .toList();

    final activeCrops = p.history.where((r) => !r.isHarvested).length;
    final plantNow = p.guides.where((g) => g.statusFor(DateTime.now().month) == PlantStatus.best).length;

    return AnimatedTabList(items: [
      _GreetingHeader(
        title: '${_greeting(t)}, $firstName! 👋',
        subtitle: DateFormat('EEEE, MMMM d', locale).format(DateTime.now()),
        initial: firstName.isNotEmpty ? firstName[0].toUpperCase() : 'P',
      ),
      const SizedBox(height: 14),

      // Panahon
      _WeatherCard(w: w, updated: p.lastUpdated, stale: p.weatherStale, place: profile.barangay),
      const SizedBox(height: 20),

      // Buod ng bukid
      SectionTitle(icon: Icons.dashboard_rounded, text: t.farmOverview),
      Row(children: [
        Expanded(
          child: _OverviewTile(
            label: t.totalLandSize,
            icon: Icons.landscape_rounded,
            value: CountUp(
              value: profile.landSizeHectares,
              decimals: 1,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
              suffix: ' ha',
            ),
            sub: '${(profile.landSizeHectares * 10000).toStringAsFixed(0)} ${t.sqmShort}',
            subColor: AppColors.leaf,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _OverviewTile(
            label: t.overviewCrops,
            icon: Icons.eco_rounded,
            value: CountUp(value: activeCrops.toDouble(), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
            sub: t.overviewCropsSub,
            subColor: AppColors.leaf,
          ),
        ),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(
          child: _OverviewTile(
            label: t.heatIndex,
            icon: Icons.device_thermostat_rounded,
            iconColor: heatColor(heat.level),
            value: CountUp(
              value: heat.celsius,
              suffix: '°C',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: heatColor(heat.level)),
            ),
            sub: t.heatLevelName(heat.level),
            subColor: heatColor(heat.level),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _OverviewTile(
            label: t.overviewPlantNow,
            icon: Icons.spa_rounded,
            value: CountUp(value: plantNow.toDouble(), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
            sub: t.overviewPlantNowSub,
            subColor: AppColors.leaf,
          ),
        ),
      ]),
      const SizedBox(height: 12),
      _HeatIndexCard(heat: heat, todayHours: todayHours),
      const SizedBox(height: 12),
      _ForecastCard(hours: w.hourly, days: w.daily),
      const SizedBox(height: 20),

      // Payo
      SectionTitle(icon: Icons.tips_and_updates_rounded, text: t.adviceTitle, subtitle: t.adviceSubtitle),
      ...p.advice.map((a) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _AdviceCard(a: a))),
      const SizedBox(height: 10),

      // Mga pananim (pindutin para sa DSS graph)
      SectionTitle(icon: Icons.eco_rounded, text: t.homeCropsTitle, subtitle: t.homeCropsSub),
      ...p.guides.map((g) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _CropCard(guide: g, onTap: () => _openCrop(context, g)),
      )),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(t.homeCropsNote, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
      ),
      const SizedBox(height: 24),
    ]);
  }
}

// ---------------------------------------------------------------------------
// Pagbati
// ---------------------------------------------------------------------------

class _GreetingHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String initial;
  const _GreetingHeader({required this.title, required this.subtitle, required this.initial});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.mint,
          border: Border.all(color: AppColors.leaf, width: 2),
        ),
        child: Text(initial, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.leaf)),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
          Text(subtitle, style: const TextStyle(fontSize: 12.5, color: AppColors.muted)),
        ]),
      ),
    ]);
  }
}

// ---------------------------------------------------------------------------
// Panahon (compact)
// ---------------------------------------------------------------------------

class _WeatherCard extends StatelessWidget {
  final WeatherBundle w;
  final DateTime? updated;
  final bool stale;
  final String place;

  const _WeatherCard({required this.w, required this.updated, required this.stale, required this.place});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isEnglish = Localizations.localeOf(context).languageCode != 'tl';
    final tl = lookupAppLocalizations(const Locale('tl')); // pangalawang label (Tagalog) para sa English
    final c = w.current;
    final info = c.info;
    final glyph = glyphFor(c.code, isDay: c.isDay);
    final today = w.daily.first;

    final summary = t.todayRange(
      today.tempMin.round().toString(),
      today.tempMax.round().toString(),
      today.rainMm.toStringAsFixed(1),
    );
    final updatedLine = updated != null ? '\n${t.updatedAt(updated!)}' : '';

    return GlassCard(
      tint: info.gradient.last.withValues(alpha: 0.26),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.location_on_rounded, color: AppColors.leaf, size: 15),
          const SizedBox(width: 4),
          Expanded(
            child: Text('$place, Pagsanjan',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5), overflow: TextOverflow.ellipsis),
          ),
          _LiveDot(color: stale ? Colors.orangeAccent : AppColors.up),
          const SizedBox(width: 6),
          Text(stale ? t.statusOffline : t.statusLive,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
        ]),
        const SizedBox(height: 10),
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          WeatherIcon(glyph: glyph, size: 78, animated: true),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CountUp(value: c.temp, suffix: '°', style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, height: 1.0)),
              const SizedBox(height: 2),
              Text(t.glyphLabel(glyph), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
              if (isEnglish) Text(tl.glyphLabel(glyph), style: const TextStyle(fontSize: 11, color: AppColors.muted)),
            ]),
          ),
          Expanded(
            flex: 6,
            child: Column(children: [
              _StatLine(Icons.thermostat_rounded, t.feelsLike, '${c.feelsLike.round()}°'),
              _StatLine(Icons.water_drop_rounded, t.humidity, '${c.humidity}%'),
              _StatLine(Icons.air_rounded, t.wind, '${c.windKmh.round()} km/h'),
              _StatLine(Icons.umbrella_rounded, t.rainChance, '${today.rainChance}%'),
            ]),
          ),
        ]),
        const SizedBox(height: 10),
        Text(summary + updatedLine, style: const TextStyle(fontSize: 11, color: AppColors.muted, height: 1.4)),
      ]),
    );
  }
}

class _StatLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatLine(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Icon(icon, size: 14, color: AppColors.leaf),
        const SizedBox(width: 6),
        Expanded(
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, color: AppColors.muted)),
        ),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
// Buod ng bukid
// ---------------------------------------------------------------------------

class _OverviewTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Widget value;
  final String sub;
  final Color subColor;

  const _OverviewTile({
    required this.label,
    required this.icon,
    required this.value,
    required this.sub,
    required this.subColor,
    this.iconColor = AppColors.leaf,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
            const SizedBox(height: 4),
            FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: value),
            const SizedBox(height: 4),
            Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: subColor)),
          ]),
        ),
        const SizedBox(width: 8),
        IconBubble(icon: icon, color: iconColor, size: 38),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
// Heat index
// ---------------------------------------------------------------------------

class _HeatIndexCard extends StatelessWidget {
  final HeatIndex heat;
  final List<HourlyWeather> todayHours;
  const _HeatIndexCard({required this.heat, required this.todayHours});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final color = heatColor(heat.level);

    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.device_thermostat_rounded, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(t.heatIndex, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(12)),
            child: Text(t.heatLevelName(heat.level), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: color)),
          ),
        ]),
        const SizedBox(height: 2),
        Text(t.heatIndexSub, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        const SizedBox(height: 10),
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          CountUp(
            value: heat.celsius,
            suffix: '°C',
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: color, height: 1.0),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(t.heatLevelAdvice(heat.level), style: const TextStyle(fontSize: 13, height: 1.35))),
        ]),
        const SizedBox(height: 12),
        _HeatScale(value: heat.celsius),
        if (todayHours.isNotEmpty) ...[
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _HeatTimeline(hours: todayHours),
        ],
        const SizedBox(height: 8),
        Text(t.heatScaleSource, style: const TextStyle(fontSize: 10.5, color: AppColors.muted, height: 1.3)),
      ]),
    );
  }
}

/// Heat index kada oras ngayong araw (5 AM - 7 PM). Pinakamainit na oras ay may marka.
class _HeatTimeline extends StatelessWidget {
  final List<HourlyWeather> hours;
  const _HeatTimeline({required this.hours});

  static const _minC = 24.0;
  static const _maxC = 52.0;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    var peak = hours.first;
    for (final h in hours) {
      if (h.heat.celsius > peak.heat.celsius) peak = h;
    }
    final peakColor = heatColor(peak.heat.level);
    String fmt(DateTime d) => DateFormat('h a', locale).format(d);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(t.heatTimeline, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
      const SizedBox(height: 6),
      Row(children: [
        Icon(Icons.local_fire_department_rounded, size: 16, color: peakColor),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            '${t.heatHottest}: ${fmt(peak.time)} • ${peak.heat.celsius.round()}°C',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: peakColor),
          ),
        ),
      ]),
      const SizedBox(height: 8),
      SizedBox(
        height: 64,
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          for (final h in hours)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.5),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 10 + ((h.heat.celsius - _minC).clamp(0.0, _maxC - _minC) / (_maxC - _minC)) * 50),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, __) => Container(
                      height: v,
                      decoration: BoxDecoration(
                        color: heatColor(h.heat.level),
                        borderRadius: BorderRadius.circular(4),
                        border: identical(h, peak) ? Border.all(color: AppColors.ink, width: 1.6) : null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ]),
      ),
      const SizedBox(height: 4),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(fmt(hours.first.time), style: const TextStyle(fontSize: 10, color: AppColors.muted)),
        Text(fmt(hours[hours.length ~/ 2].time), style: const TextStyle(fontSize: 10, color: AppColors.muted)),
        Text(fmt(hours.last.time), style: const TextStyle(fontSize: 10, color: AppColors.muted)),
      ]),
    ]);
  }
}

/// Kulay na scale na may marker sa kasalukuyang heat index.
class _HeatScale extends StatelessWidget {
  final double value;
  const _HeatScale({required this.value});

  static const _min = 24.0;
  static const _max = 56.0;
  static const _stops = [27.0, 33.0, 42.0, 52.0];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final w = box.maxWidth;
      double x(double v) => (math.min(math.max(v, _min), _max) - _min) / (_max - _min) * w;

      Widget seg(HeatLevel l, int flex) => Expanded(flex: flex, child: Container(color: heatColor(l)));

      return SizedBox(
        height: 40,
        child: Stack(clipBehavior: Clip.none, children: [
          Positioned(
            left: 0,
            right: 0,
            top: 6,
            height: 10,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Row(children: [
                seg(HeatLevel.normal, 3),
                seg(HeatLevel.caution, 6),
                seg(HeatLevel.extremeCaution, 9),
                seg(HeatLevel.danger, 10),
                seg(HeatLevel.extremeDanger, 4),
              ]),
            ),
          ),
          for (final s in _stops)
            Positioned(
              left: x(s) - 12,
              top: 22,
              width: 24,
              child: Text('${s.toInt()}',
                  textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: AppColors.muted)),
            ),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: _min, end: value),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (_, v, __) => Positioned(
              left: x(v) - 8,
              top: 3,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.ink, width: 3),
                ),
              ),
            ),
          ),
        ]),
      );
    });
  }
}

/// Maliit na heat index label para sa oras/araw na tile.
class _HeatMini extends StatelessWidget {
  final HeatIndex? heat;
  final bool onAccent;
  const _HeatMini({required this.heat, required this.onAccent});

  @override
  Widget build(BuildContext context) {
    final h = heat;
    if (h == null) return const SizedBox(height: 12);
    final c = onAccent ? Colors.white : heatColor(h.level);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.device_thermostat_rounded, size: 11, color: c),
      Text('${h.celsius.round()}°', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: c)),
    ]);
  }
}

// ---------------------------------------------------------------------------
// Forecast (oras-oras / 7 araw)
// ---------------------------------------------------------------------------

class _ForecastCard extends StatefulWidget {
  final List<HourlyWeather> hours;
  final List<WeatherDay> days;
  const _ForecastCard({required this.hours, required this.days});

  @override
  State<_ForecastCard> createState() => _ForecastCardState();
}

class _ForecastCardState extends State<_ForecastCard> {
  bool _week = false;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    final Widget list = _week
        ? ListView.separated(
      key: const ValueKey('week'),
      scrollDirection: Axis.horizontal,
      itemCount: widget.days.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (_, i) => _DayItem(day: widget.days[i], isToday: i == 0, locale: locale, todayLabel: t.today),
    )
        : ListView.separated(
      key: const ValueKey('hours'),
      scrollDirection: Axis.horizontal,
      itemCount: widget.hours.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (_, i) => _HourItem(hour: widget.hours[i], isFirst: i == 0, locale: locale, nowLabel: t.now),
    );

    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.insights_rounded, color: AppColors.leaf),
          const SizedBox(width: 8),
          Text(t.forecastTitle, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        ]),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<bool>(
            showSelectedIcon: false,
            style: const ButtonStyle(visualDensity: VisualDensity.compact),
            segments: [
              ButtonSegment(value: false, label: Text(t.hourlyTab)),
              ButtonSegment(value: true, label: Text(t.weeklyTab)),
            ],
            selected: {_week},
            onSelectionChanged: (s) => setState(() => _week = s.first),
          ),
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: SizedBox(key: ValueKey(_week), height: 130, child: list),
        ),
      ]),
    );
  }
}

class _HourItem extends StatelessWidget {
  final HourlyWeather hour;
  final bool isFirst;
  final String locale;
  final String nowLabel;
  const _HourItem({required this.hour, required this.isFirst, required this.locale, required this.nowLabel});

  @override
  Widget build(BuildContext context) {
    final glyph = glyphFor(hour.code, isDay: hour.isDay);
    return Container(
      width: 64,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isFirst ? AppColors.accentDark : AppColors.mint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isFirst ? AppColors.leaf : AppColors.border),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(isFirst ? nowLabel : DateFormat('h a', locale).format(hour.time),
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: isFirst ? Colors.white : AppColors.muted)),
        WeatherIcon(glyph: glyph, size: 34),
        Text('${hour.temp.round()}°', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
        Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.water_drop, size: 10, color: isFirst ? Colors.white70 : AppColors.rain),
          const SizedBox(width: 2),
          Text('${hour.rainChance}%', style: const TextStyle(fontSize: 10)),
        ]),
        _HeatMini(heat: hour.heat, onAccent: isFirst),
      ]),
    );
  }
}

class _DayItem extends StatelessWidget {
  final WeatherDay day;
  final bool isToday;
  final String locale;
  final String todayLabel;
  const _DayItem({required this.day, required this.isToday, required this.locale, required this.todayLabel});

  @override
  Widget build(BuildContext context) {
    final glyph = glyphFor(day.code);
    return Container(
      width: 72,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isToday ? AppColors.accentDark : AppColors.mint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isToday ? AppColors.leaf : AppColors.border),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(isToday ? todayLabel : DateFormat('EEE d', locale).format(day.date),
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: isToday ? Colors.white : AppColors.muted)),
        WeatherIcon(glyph: glyph, size: 34),
        Column(mainAxisSize: MainAxisSize.min, children: [
          Text('${day.tempMax.round()}°', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
          Text('${day.tempMin.round()}°', style: TextStyle(fontSize: 11, color: isToday ? Colors.white70 : AppColors.muted)),
        ]),
        Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.water_drop, size: 10, color: isToday ? Colors.white70 : AppColors.rain),
          const SizedBox(width: 2),
          Text('${day.rainChance}%', style: const TextStyle(fontSize: 10)),
        ]),
        _HeatMini(heat: day.heatPeak, onAccent: isToday),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
// Payo sa pagsasaka
// ---------------------------------------------------------------------------

class _AdviceCard extends StatelessWidget {
  final FarmAdvice a;
  const _AdviceCard({required this.a});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        IconBubble(icon: a.icon, color: a.color, size: 46),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t.farmAdviceTitle(a.type), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
            const SizedBox(height: 2),
            Text(t.farmAdviceMessage(a.type), style: const TextStyle(height: 1.35, color: AppColors.muted)),
          ]),
        ),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
// Mga pananim
// ---------------------------------------------------------------------------

class _CropCard extends StatelessWidget {
  final PlantingGuide guide;
  final VoidCallback onTap;
  const _CropCard({required this.guide, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final status = guide.statusFor(DateTime.now().month);

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(width: 92, height: 92, child: CropImage(guide: guide)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t.cropLabel(guide.crop), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
            const SizedBox(height: 2),
            Text(
              t.cropAbout(guide.crop),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12.5, color: AppColors.muted, height: 1.3),
            ),
            const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: 6, children: [
              Pill(t.plantStatusLabel(status), plantStatusColor(status), icon: plantStatusIcon(status)),
              Pill(monthRangesLabel(guide, locale), AppColors.soil, icon: Icons.calendar_month_rounded),
            ]),
          ]),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Icon(Icons.chevron_right_rounded, color: AppColors.muted),
        ),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
// Animations
// ---------------------------------------------------------------------------

class _LiveDot extends StatefulWidget {
  final Color color;
  const _LiveDot({required this.color});

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.3, end: 1.0).animate(_c),
      child: Container(width: 9, height: 9, decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle)),
    );
  }
}