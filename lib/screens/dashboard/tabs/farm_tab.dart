import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/crop_l10n.dart';
import '../../../dashboard_data.dart';
import '../../../l10n/app_localizations.dart';
import '../../../main.dart';
import '../../../widgets/common_widgets.dart';
import '../../../widgets/crop_image.dart';
import '../crop_detail_screen.dart';

/// Tantiyang araw bago maani (min, max). Ayon sa gabay sa bawat pananim.
/// Walang laman ang Niyog at Calamansi dahil taon ang hinihintay.
const Map<String, (int, int)> _harvestDays = {
  'Rice': (110, 120),
  'Eggplant': (90, 120),
  'Tomato': (90, 110),
  'String beans': (60, 70),
  'Banana': (270, 360),
  'Ampalaya': (60, 90),
  'Squash': (90, 120),
  'Sweet potato': (90, 120),
  'Taro': (180, 270),
};

class FarmTab extends StatelessWidget {
  final DashboardProvider p;
  const FarmTab({super.key, required this.p});

  PlantingGuide? _guideFor(String crop) {
    for (final g in p.guides) {
      if (g.crop == crop) return g;
    }
    return null;
  }

  /// Pinakabagong tala ng pananim (kung may).
  CropRecord? _latestRecord(String crop, {bool? harvested}) {
    CropRecord? best;
    for (final r in p.history) {
      if (r.crop != crop) continue;
      if (harvested != null && r.isHarvested != harvested) continue;
      if (best == null || r.datePlanted.isAfter(best.datePlanted)) best = r;
    }
    return best;
  }

  bool _isGrowing(String crop) => _latestRecord(crop, harvested: false) != null;

  void _open(BuildContext context, PlantingGuide g) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => CropDetailScreen(guide: g, p: p)));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final profile = p.profile!;

    final growing = p.plots.where((pl) => _isGrowing(pl.crop)).length;
    final harvested = p.plots.length - growing;
    final totalYield = p.history.where((r) => r.isHarvested).fold<double>(0, (s, r) => s + r.yieldKg);

    return AnimatedTabList(items: [
      _ProfileCard(profile: profile),
      const SizedBox(height: 16),
      _LandCard(profile: profile, plots: p.plots),
      const SizedBox(height: 16),

      // Buod
      Row(children: [
        Expanded(child: _StatTile(icon: Icons.spa_rounded, color: AppColors.fern, value: '$growing', label: t.plotGrowing)),
        const SizedBox(width: 10),
        Expanded(child: _StatTile(icon: Icons.inventory_2_rounded, color: AppColors.soil, value: '$harvested', label: t.plotHarvested)),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            icon: Icons.scale_rounded,
            color: AppColors.leaf,
            value: '${NumberFormat('#,###').format(totalYield)} kg',
            label: t.farmTotalHarvest,
          ),
        ),
      ]),
      const SizedBox(height: 16),

      // Mga pananim
      SectionTitle(icon: Icons.eco_rounded, text: t.farmCropsTitle, subtitle: t.farmCropsSub),
      ...p.plots.map((pl) {
        final guide = _guideFor(pl.crop);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _CropPlotCard(
            plot: pl,
            guide: guide,
            totalHectares: profile.landSizeHectares,
            growingRecord: _latestRecord(pl.crop, harvested: false),
            lastHarvest: _latestRecord(pl.crop, harvested: true),
            onTap: guide == null ? null : () => _open(context, guide),
          ),
        );
      }),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(t.farmEstimateNote, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
      ),
      const SizedBox(height: 14),

      _CropHistoryList(records: p.history),
      const SizedBox(height: 24),
    ]);
  }
}

// ---------------------------------------------------------------------------
// Profile + land
// ---------------------------------------------------------------------------

class _ProfileCard extends StatelessWidget {
  final FarmerProfile profile;
  const _ProfileCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.leaf,
                child: Icon(Icons.agriculture, color: AppColors.bg0, size: 32),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(profile.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 2),
                  Row(children: [
                    const Icon(Icons.location_on_rounded, size: 16, color: AppColors.soil),
                    const SizedBox(width: 3),
                    Flexible(child: Text('${profile.barangay}, Pagsanjan, Laguna')),
                  ]),
                ]),
              ),
            ]),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: profile.cropTypes
                  .map((c) => Chip(
                avatar: Icon(Icons.eco, size: 16, color: AppColors.forCrop(c)),
                label: Text(t.cropLabel(c), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                backgroundColor: AppColors.mint,
                side: BorderSide.none,
              ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _LandCard extends StatelessWidget {
  final FarmerProfile profile;
  final List<FarmPlot> plots;
  const _LandCard({required this.profile, required this.plots});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final total = profile.landSizeHectares;
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t.totalLandSize, style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700)),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: total),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => Text(v.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 52, fontWeight: FontWeight.w900, color: AppColors.leaf, height: 1.1)),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 6, bottom: 8),
              child: Text(t.hectares, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Pill('${(total * 10000).toStringAsFixed(0)} ${t.sqmShort}', AppColors.soil, icon: Icons.square_foot_rounded),
            ),
          ]),
          const SizedBox(height: 14),
          Container(
            height: 18,
            decoration: BoxDecoration(color: AppColors.mint, borderRadius: BorderRadius.circular(9)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 1100),
                curve: Curves.easeOutCubic,
                builder: (_, v, child) => Align(alignment: Alignment.centerLeft, widthFactor: v, child: child),
                child: Row(children: [
                  for (final pl in plots)
                    Expanded(flex: (pl.hectares * 100).round(), child: Container(color: AppColors.forCrop(pl.crop))),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 14, runSpacing: 6, children: [
            for (final pl in plots)
              Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 12, height: 12, decoration: BoxDecoration(color: AppColors.forCrop(pl.crop), shape: BoxShape.circle)),
                const SizedBox(width: 5),
                Text('${t.cropLabel(pl.crop)} ${(pl.hectares / total * 100).round()}%',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              ]),
          ]),
        ]),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  const _StatTile({required this.icon, required this.color, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: color)),
          ),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: AppColors.muted)),
        ]),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Detalyadong card ng bawat pananim
// ---------------------------------------------------------------------------

class _CropPlotCard extends StatelessWidget {
  final FarmPlot plot;
  final PlantingGuide? guide;
  final double totalHectares;
  final CropRecord? growingRecord;
  final CropRecord? lastHarvest;
  final VoidCallback? onTap;

  const _CropPlotCard({
    required this.plot,
    required this.guide,
    required this.totalHectares,
    required this.growingRecord,
    required this.lastHarvest,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final color = AppColors.forCrop(plot.crop);
    final growing = growingRecord != null;
    final percent = totalHectares > 0 ? (plot.hectares / totalHectares * 100).round() : 0;
    final g = guide;

    return GlassCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 84,
                height: 84,
                child: g != null
                    ? CropImage(guide: g)
                    : Container(color: color.withValues(alpha: 0.15), child: Icon(Icons.eco_rounded, color: color, size: 36)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t.cropLabel(plot.crop), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
                const SizedBox(height: 2),
                Text('${plot.hectares} ${t.hectares} • ${t.farmShare(percent.toString())}',
                    style: const TextStyle(color: AppColors.muted, fontSize: 12.5)),
                const SizedBox(height: 8),
                Wrap(spacing: 6, runSpacing: 6, children: [
                  Pill(
                    growing ? t.plotGrowing : t.plotHarvested,
                    growing ? AppColors.fern : AppColors.soil,
                    icon: growing ? Icons.spa_rounded : Icons.inventory_2_rounded,
                  ),
                  if (g != null)
                    Builder(builder: (_) {
                      final st = g.statusFor(DateTime.now().month);
                      return Pill(
                        '${t.farmThisMonth}: ${t.plantStatusLabel(st)}',
                        plantStatusColor(st),
                        icon: plantStatusIcon(st),
                      );
                    }),
                ]),
              ]),
            ),
            if (onTap != null)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(Icons.chevron_right_rounded, color: AppColors.muted),
              ),
          ]),
          const SizedBox(height: 12),
          if (growing)
            _GrowthSection(crop: plot.crop, record: growingRecord!, locale: locale)
          else if (lastHarvest != null)
            _HarvestSection(record: lastHarvest!, hectares: plot.hectares),
          if (g != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.mint, borderRadius: BorderRadius.circular(12)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.lightbulb_rounded, size: 18, color: AppColors.soil),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(t.cropTip(plot.crop), style: const TextStyle(fontSize: 12.5, height: 1.35)),
                ),
              ]),
            ),
          ],
        ]),
      ),
    );
  }
}

/// Para sa lumalaking pananim: araw ng paglaki, progress at inaasahang ani.
class _GrowthSection extends StatelessWidget {
  final String crop;
  final CropRecord record;
  final String locale;
  const _GrowthSection({required this.crop, required this.record, required this.locale});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final days = DateTime.now().difference(record.datePlanted).inDays.clamp(0, 100000);
    final range = _harvestDays[crop];
    final mmd = DateFormat.MMMd(locale);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _InfoRow(icon: Icons.event_rounded, text: t.plantedOn(record.datePlanted)),
      if (range != null) ...[
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: Text(t.farmDaysGrown(days, range.$2),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
          ),
          Text('${(days / range.$2 * 100).clamp(0, 100).round()}%',
              style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.leaf)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: (days / range.$2).clamp(0.0, 1.0),
            minHeight: 9,
            backgroundColor: AppColors.mint,
            color: days >= range.$1 ? AppColors.leaf : AppColors.fern,
          ),
        ),
        const SizedBox(height: 8),
        _InfoRow(
          icon: Icons.agriculture_rounded,
          text: t.farmExpectedHarvest(
            '${mmd.format(record.datePlanted.add(Duration(days: range.$1)))} - ${mmd.format(record.datePlanted.add(Duration(days: range.$2)))}',
          ),
        ),
        if (days >= range.$1) ...[
          const SizedBox(height: 8),
          Pill(t.farmReadySoon, AppColors.leaf, icon: Icons.check_circle_rounded),
        ],
      ],
    ]);
  }
}

/// Para sa naaning pananim: petsa ng ani at dami ng ani.
class _HarvestSection extends StatelessWidget {
  final CropRecord record;
  final double hectares;
  const _HarvestSection({required this.record, required this.hectares});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final nf = NumberFormat('#,###');
    final perHa = hectares > 0 ? record.yieldKg / hectares : 0.0;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _InfoRow(icon: Icons.event_available_rounded, text: t.harvestedOn(record.dateHarvested!)),
      const SizedBox(height: 6),
      _InfoRow(icon: Icons.scale_rounded, text: '${t.farmLastHarvest}: ${nf.format(record.yieldKg)} kg'),
      if (perHa > 0) ...[
        const SizedBox(height: 6),
        _InfoRow(icon: Icons.stacked_bar_chart_rounded, text: t.farmYieldPerHa(nf.format(perHa))),
      ],
    ]);
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 16, color: AppColors.soil),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 13, height: 1.3))),
    ]);
  }
}

// ---------------------------------------------------------------------------
// Kasaysayan
// ---------------------------------------------------------------------------

class _CropHistoryList extends StatelessWidget {
  final List<CropRecord> records;
  const _CropHistoryList({required this.records});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SectionTitle(icon: Icons.history_rounded, text: t.cropHistory),
          ...records.map((r) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              r.isHarvested ? Icons.check_circle : Icons.grass,
              color: r.isHarvested ? AppColors.leaf : AppColors.soil,
              size: 28,
            ),
            title: Text(t.cropLabel(r.crop), style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text(
              '${t.plantedOn(r.datePlanted)}\n'
                  '${r.isHarvested ? t.harvestedOn(r.dateHarvested!) : t.stillGrowing}',
            ),
            isThreeLine: true,
            trailing: Text(
              r.isHarvested ? '${NumberFormat('#,###').format(r.yieldKg)} kg' : '-',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          )),
        ]),
      ),
    );
  }
}