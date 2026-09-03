import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:web_page/constants/app_colours.dart';

enum ChartMetric { weight, height }

class GrowthDataPoint {
  final double months;
  final double weightKg;
  final double heightCm;
  final String label;
  final String dateStr;
  final DateTime? date;
  final bool hasWeightRecorded;
  final bool hasHeightRecorded;
  final bool isRecorded;
  final GrowthDataPoint? previousPoint;

  GrowthDataPoint({
    required this.months,
    required this.weightKg,
    required this.heightCm,
    required this.label,
    required this.dateStr,
    this.date,
    this.hasWeightRecorded = true,
    this.hasHeightRecorded = true,
    this.isRecorded = true,
    this.previousPoint,
  });
}

class WhoGrowthStandard {
  /// Returns [3rd percentile, 50th percentile, 97th percentile] weight in kg for age in months
  static List<double> getWeightPercentiles(double months) {
    final points = [
      [0.0, 2.4, 3.3, 4.3],
      [1.5, 3.4, 4.5, 5.8],
      [3.0, 4.4, 5.8, 7.2],
      [6.0, 6.2, 7.9, 9.8],
      [9.0, 7.0, 8.9, 11.2],
      [12.0, 7.6, 9.6, 12.0],
      [18.0, 8.7, 10.9, 13.7],
      [24.0, 9.7, 12.2, 15.3],
      [36.0, 11.4, 14.3, 18.0],
      [48.0, 12.8, 16.3, 20.8],
      [60.0, 14.2, 18.3, 23.5],
    ];

    return _interpolate(months, points);
  }

  /// Returns [3rd percentile, 50th percentile, 97th percentile] height in cm for age in months
  static List<double> getHeightPercentiles(double months) {
    final points = [
      [0.0, 45.5, 50.0, 54.5],
      [1.5, 51.5, 56.0, 60.5],
      [3.0, 55.5, 60.5, 65.0],
      [6.0, 62.5, 67.5, 72.0],
      [9.0, 67.0, 72.0, 76.5],
      [12.0, 70.5, 75.7, 80.5],
      [18.0, 77.0, 82.3, 87.5],
      [24.0, 82.0, 87.8, 93.5],
      [36.0, 89.5, 96.1, 102.5],
      [48.0, 96.0, 103.3, 110.5],
      [60.0, 102.0, 110.0, 118.0],
    ];

    return _interpolate(months, points);
  }

  static List<double> _interpolate(double months, List<List<double>> table) {
    if (months <= table.first[0]) {
      return [table.first[1], table.first[2], table.first[3]];
    }
    if (months >= table.last[0]) {
      return [table.last[1], table.last[2], table.last[3]];
    }
    for (int i = 0; i < table.length - 1; i++) {
      if (months >= table[i][0] && months <= table[i + 1][0]) {
        double t = (months - table[i][0]) / (table[i + 1][0] - table[i][0]);
        double p3 = table[i][1] + t * (table[i + 1][1] - table[i][1]);
        double p50 = table[i][2] + t * (table[i + 1][2] - table[i][2]);
        double p97 = table[i][3] + t * (table[i + 1][3] - table[i][3]);
        return [p3, p50, p97];
      }
    }
    return [table.first[1], table.first[2], table.first[3]];
  }
}

class GrowthChartWidget extends StatefulWidget {
  final List<DocumentSnapshot> screeningsDocs;
  final Map<String, dynamic> childData;

  const GrowthChartWidget({
    super.key,
    required this.screeningsDocs,
    required this.childData,
  });

  @override
  State<GrowthChartWidget> createState() => _GrowthChartWidgetState();
}

class _GrowthChartWidgetState extends State<GrowthChartWidget> {
  ChartMetric _activeMetric = ChartMetric.weight;
  int? _selectedIndex;
  late List<GrowthDataPoint> _points;
  late double _maxMonths;

  @override
  void initState() {
    super.initState();
    _loadPoints();
  }

  @override
  void didUpdateWidget(covariant GrowthChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadPoints();
  }

  void _loadPoints() {
    _points = _buildPoints();
    if (_points.isNotEmpty) {
      _selectedIndex = _points.length - 1;
      double maxP = _points.map((p) => p.months).reduce(max);
      _maxMonths = max(24.0, (maxP > 36 ? 60.0 : (maxP > 24 ? 36.0 : 24.0)));
    } else {
      _maxMonths = 24.0;
    }
  }

  List<GrowthDataPoint> _buildPoints() {
    List<GrowthDataPoint> rawList = [];

    final ageGroupMonths = <String, double>{
      'Birth (Newborn, Pre-Discharge)': 0.0,
      'At Birth': 0.0,
      '3 - 5 Days': 0.1,
      '1 Month': 1.0,
      '6 Weeks': 1.5,
      '10 Weeks': 2.5,
      '14 Weeks': 3.5,
      '6 Months': 6.0,
      '9 Months': 9.0,
      '12 Months (1 Year)': 12.0,
      '12 Months': 12.0,
      '15 Months': 15.0,
      '18 Months': 18.0,
      '16-24 Months': 18.0,
      '24 Months (2 Years)': 24.0,
      '2 Years': 24.0,
      '30 Months (2.5 Years)': 30.0,
      '3 Years': 36.0,
      '4 Years': 48.0,
      '5 Years': 60.0,
    };

    if (widget.screeningsDocs.isNotEmpty) {
      for (final doc in widget.screeningsDocs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) continue;

        String ageGroup = data['ageGroup'] ?? 'Screening';
        double m = ageGroupMonths[ageGroup] ?? 0.0;

        DateTime? dt;
        String dateStr = '';
        if (data['screeningDate'] is Timestamp) {
          dt = (data['screeningDate'] as Timestamp).toDate();
          dateStr = '${dt.day}/${dt.month}/${dt.year}';
        }

        double? w = (data['weight'] as num?)?.toDouble();
        double? h = (data['height'] as num?)?.toDouble();

        // Extract from results if top-level fields are absent
        if ((w == null || h == null) && data['results'] is List) {
          final results = data['results'] as List;
          for (final item in results) {
            if (item is Map) {
              final title = (item['title'] as String? ?? '').toLowerCase();
              final valStr = item['value'] as String? ?? '';
              final match = RegExp(r'([0-9]+(?:\.[0-9]+)?)').firstMatch(valStr);
              if (match != null) {
                final valNum = double.tryParse(match.group(1)!);
                if (valNum != null && valNum > 0) {
                  if (w == null && (title.contains('weight') || title.contains('wt'))) {
                    w = valNum;
                  } else if (h == null && (title.contains('length') || title.contains('height'))) {
                    h = valNum;
                  }
                }
              }
            }
          }
        }

        final bool hasWeight = (w != null && w > 0);
        final bool hasHeight = (h != null && h > 0);

        rawList.add(GrowthDataPoint(
          months: m,
          weightKg: w ?? 0.0,
          heightCm: h ?? 0.0,
          label: ageGroup,
          dateStr: dateStr,
          date: dt,
          hasWeightRecorded: hasWeight,
          hasHeightRecorded: hasHeight,
          isRecorded: true,
        ));
      }
    }

    // Sort chronologically by date if available, then by months
    rawList.sort((a, b) {
      if (a.date != null && b.date != null) {
        final cmp = a.date!.compareTo(b.date!);
        if (cmp != 0) return cmp;
      }
      return a.months.compareTo(b.months);
    });

    // Ensure baseline birth point if missing
    if (rawList.isEmpty || rawList.first.months > 0) {
      final bW = WhoGrowthStandard.getWeightPercentiles(0)[1];
      final bH = WhoGrowthStandard.getHeightPercentiles(0)[1];
      rawList.insert(
        0,
        GrowthDataPoint(
          months: 0.0,
          weightKg: bW,
          heightCm: bH,
          label: 'At Birth (Standard)',
          dateStr: 'Baseline',
          hasWeightRecorded: false,
          hasHeightRecorded: false,
          isRecorded: false,
        ),
      );
    }

    // Process list to fill missing unrecorded values from previous points and link previousPoint
    List<GrowthDataPoint> processedList = [];
    GrowthDataPoint? lastRecordedWeightPoint;
    GrowthDataPoint? lastRecordedHeightPoint;

    for (int i = 0; i < rawList.length; i++) {
      final current = rawList[i];

      double w = current.weightKg;
      if (!current.hasWeightRecorded) {
        if (lastRecordedWeightPoint != null) {
          w = lastRecordedWeightPoint.weightKg;
        } else {
          w = WhoGrowthStandard.getWeightPercentiles(current.months)[1];
        }
      }

      double h = current.heightCm;
      if (!current.hasHeightRecorded) {
        if (lastRecordedHeightPoint != null) {
          h = lastRecordedHeightPoint.heightCm;
        } else {
          h = WhoGrowthStandard.getHeightPercentiles(current.months)[1];
        }
      }

      // Link previous point for comparison (most recent preceding point)
      GrowthDataPoint? prevPt = processedList.isNotEmpty ? processedList.last : null;

      final updatedPt = GrowthDataPoint(
        months: current.months,
        weightKg: w,
        heightCm: h,
        label: current.label,
        dateStr: current.dateStr,
        date: current.date,
        hasWeightRecorded: current.hasWeightRecorded,
        hasHeightRecorded: current.hasHeightRecorded,
        isRecorded: current.isRecorded,
        previousPoint: prevPt,
      );

      if (current.hasWeightRecorded) {
        lastRecordedWeightPoint = updatedPt;
      }
      if (current.hasHeightRecorded) {
        lastRecordedHeightPoint = updatedPt;
      }

      processedList.add(updatedPt);
    }

    return processedList;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Metric Switcher & Legend Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Toggle Buttons
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  _metricBtn(
                    metric: ChartMetric.weight,
                    label: 'Weight (kg)',
                    icon: Icons.scale_outlined,
                  ),
                  const SizedBox(width: 4),
                  _metricBtn(
                    metric: ChartMetric.height,
                    label: 'Height (cm)',
                    icon: Icons.straighten_outlined,
                  ),
                ],
              ),
            ),
            // Recorded count badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: 5),
                  Text(
                    '${widget.screeningsDocs.length} Logged',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Visual Legend Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _legendItem(
                color: AppColors.primary,
                label: "Child Growth Track",
                isLine: true,
              ),
              _legendItem(
                color: AppColors.success,
                label: "WHO 50th% Median",
                isLine: true,
              ),
              _legendItem(
                color: AppColors.success.withOpacity(0.25),
                label: "WHO Healthy Band (3rd-97th%)",
                isLine: false,
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Chart Interactive Canvas
        Container(
          height: 230,
          width: double.infinity,
          padding: const EdgeInsets.only(top: 8, bottom: 8, right: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                onHover: (event) => _handleHoverOrTap(event.localPosition, constraints.maxWidth, constraints.maxHeight),
                child: GestureDetector(
                  onTapDown: (details) => _handleHoverOrTap(details.localPosition, constraints.maxWidth, constraints.maxHeight),
                  onPanUpdate: (details) => _handleHoverOrTap(details.localPosition, constraints.maxWidth, constraints.maxHeight),
                  child: CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: GrowthChartPainter(
                      metric: _activeMetric,
                      points: _points,
                      selectedIndex: _selectedIndex,
                      maxMonths: _maxMonths,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // Interactive Visit Selector Chips
        _buildVisitChips(),

        const SizedBox(height: 10),

        // Selected Point Info Card
        if (_selectedIndex != null && _selectedIndex! < _points.length)
          _buildPointDetailCard(_points[_selectedIndex!]),
      ],
    );
  }

  Widget _buildVisitChips() {
    if (_points.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recorded Visits (Tap to select point):',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.mutedText,
          ),
        ),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_points.length, (index) {
              final pt = _points[index];
              final isSelected = _selectedIndex == index;
              final isRecorded = pt.isRecorded;

              String displayLabel = pt.label;
              if (pt.dateStr.isNotEmpty) {
                displayLabel = pt.dateStr == 'Baseline'
                    ? '${pt.label} (Baseline)'
                    : '${pt.label} (${pt.dateStr})';
              }

              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : (isRecorded ? AppColors.primary.withOpacity(0.08) : Colors.grey.shade100),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : (isRecorded ? AppColors.primary.withOpacity(0.3) : AppColors.border),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (index == _points.length - 1 && isRecorded) ...[
                          const Icon(Icons.stars_rounded, size: 12, color: Colors.amber),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          displayLabel,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : (isRecorded ? AppColors.primary : AppColors.mutedText),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  void _handleHoverOrTap(Offset localPosition, double width, double height) {
    final double leftMargin = 48.0;
    final double rightMargin = 16.0;
    final double topMargin = 22.0;
    final double bottomMargin = 28.0;

    final double chartW = width - leftMargin - rightMargin;
    final double chartH = height - topMargin - bottomMargin;

    if (chartW <= 0 || chartH <= 0 || _points.isEmpty) return;

    final bool isWeight = _activeMetric == ChartMetric.weight;
    final double minY = isWeight ? 0.0 : 30.0;

    double maxValInPoints = 0.0;
    if (_points.isNotEmpty) {
      maxValInPoints = _points
          .map((p) => isWeight ? p.weightKg : p.heightCm)
          .reduce(max);
    }
    final double defaultMaxY = isWeight ? 22.0 : 120.0;
    final double maxY = max(defaultMaxY, maxValInPoints * 1.15);

    double dx(double m) => leftMargin + (m / _maxMonths) * chartW;
    double dy(double v) =>
        topMargin + chartH - ((v - minY) / (maxY - minY)) * chartH;

    int nearestIdx = -1;
    double minDistance = double.infinity;

    for (int i = 0; i < _points.length; i++) {
      final val = isWeight ? _points[i].weightKg : _points[i].heightCm;
      final px = dx(_points[i].months);
      final py = dy(val);

      final dist = sqrt(pow(localPosition.dx - px, 2) + pow(localPosition.dy - py, 2));
      if (dist < minDistance && dist < 45.0) {
        minDistance = dist;
        nearestIdx = i;
      }
    }

    if (nearestIdx != -1 && nearestIdx != _selectedIndex) {
      setState(() {
        _selectedIndex = nearestIdx;
      });
    }
  }

  Widget _metricBtn({
    required ChartMetric metric,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _activeMetric == metric;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeMetric = metric;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : AppColors.mutedText,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem({
    required Color color,
    required String label,
    required bool isLine,
  }) {
    return Row(
      children: [
        if (isLine)
          Container(
            width: 14,
            height: 3,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          )
        else
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: AppColors.success.withOpacity(0.5)),
            ),
          ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.mutedText,
          ),
        ),
      ],
    );
  }

  Widget _buildPointDetailCard(GrowthDataPoint pt) {
    final isWeight = _activeMetric == ChartMetric.weight;
    final double currentVal = isWeight ? pt.weightKg : pt.heightCm;
    final bool hasRecorded = isWeight ? pt.hasWeightRecorded : pt.hasHeightRecorded;

    final valStr = isWeight
        ? '${currentVal.toStringAsFixed(1)} kg'
        : '${currentVal.toStringAsFixed(0)} cm';
    final whoRef = isWeight
        ? WhoGrowthStandard.getWeightPercentiles(pt.months)
        : WhoGrowthStandard.getHeightPercentiles(pt.months);

    final double p50 = whoRef[1];

    String status = 'Normal Band (50th percentile WHO Standard)';
    Color statusColor = AppColors.success;
    if (currentVal < whoRef[0]) {
      status = 'Below 3rd Percentile (Underweight/Low height)';
      statusColor = AppColors.warning;
    } else if (currentVal > whoRef[2]) {
      status = 'Above 97th Percentile (Above standard)';
      statusColor = AppColors.warning;
    }

    final prevPt = pt.previousPoint;
    double? prevVal;
    double? diff;
    if (prevPt != null) {
      prevVal = isWeight ? prevPt.weightKg : prevPt.heightCm;
      diff = currentVal - prevVal;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isWeight ? Icons.scale_rounded : Icons.straighten_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${pt.label}${pt.dateStr.isNotEmpty ? ' • ${pt.dateStr}' : ''}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.text,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          valStr,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    if (!hasRecorded && pt.isRecorded) ...[
                      const SizedBox(height: 2),
                      Text(
                        '(${isWeight ? "Weight" : "Height"} not recorded in this visit; showing carried value)',
                        style: TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // COMPARISON WITH OLD / PREVIOUS VISIT
          if (prevPt != null && prevVal != null && diff != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(
                    diff >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                    size: 16,
                    color: diff >= 0 ? AppColors.success : AppColors.danger,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Old Visit (${prevPt.label}${prevPt.dateStr.isNotEmpty ? ' • ${prevPt.dateStr}' : ''}): ${prevVal.toStringAsFixed(isWeight ? 1 : 0)} ${isWeight ? "kg" : "cm"}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: (diff >= 0 ? AppColors.success : AppColors.danger).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${diff >= 0 ? "+" : ""}${diff.toStringAsFixed(isWeight ? 1 : 0)} ${isWeight ? "kg" : "cm"}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: diff >= 0 ? AppColors.success : AppColors.danger,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.check_circle_outline_rounded, size: 13, color: statusColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '$status (WHO Median: ${p50.toStringAsFixed(1)}${isWeight ? "kg" : "cm"})',
                  style: TextStyle(
                    fontSize: 11,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GrowthChartPainter extends CustomPainter {
  final ChartMetric metric;
  final List<GrowthDataPoint> points;
  final int? selectedIndex;
  final double maxMonths;

  GrowthChartPainter({
    required this.metric,
    required this.points,
    this.selectedIndex,
    required this.maxMonths,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double leftMargin = 48.0;
    final double rightMargin = 16.0;
    final double topMargin = 22.0;
    final double bottomMargin = 28.0;

    final double chartW = size.width - leftMargin - rightMargin;
    final double chartH = size.height - topMargin - bottomMargin;

    final bool isWeight = metric == ChartMetric.weight;
    final double minY = isWeight ? 0.0 : 30.0;

    double maxValInPoints = 0.0;
    if (points.isNotEmpty) {
      maxValInPoints = points
          .map((p) => isWeight ? p.weightKg : p.heightCm)
          .reduce(max);
    }
    final double defaultMaxY = isWeight ? 22.0 : 120.0;
    final double maxY = max(defaultMaxY, maxValInPoints * 1.15);

    double dx(double m) => leftMargin + (m / maxMonths) * chartW;
    double dy(double v) =>
        topMargin + chartH - ((v - minY) / (maxY - minY)) * chartH;

    // 1. Grid lines & Y Axis Labels
    final int yTicksCount = 4;
    final Paint gridPaint = Paint()
      ..color = AppColors.border.withOpacity(0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i <= yTicksCount; i++) {
      double val = minY + (maxY - minY) * (i / yTicksCount);
      double y = dy(val);

      canvas.drawLine(
          Offset(leftMargin, y), Offset(size.width - rightMargin, y), gridPaint);

      final labelStr = isWeight
          ? '${val >= 100 ? val.toInt() : val.toStringAsFixed(val % 1 == 0 ? 0 : 1)}kg'
          : '${val.toInt()}cm';

      final tp = TextPainter(
        text: TextSpan(
          text: labelStr,
          style: const TextStyle(
            color: AppColors.mutedText,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftMargin - tp.width - 4, y - tp.height / 2));
    }

    // 2. X Axis Milestone Ticks & Labels
    final List<double> xMilestones = [0, 6, 12, 18, 24, 36, 48, 60];
    final Paint dashGridPaint = Paint()
      ..color = AppColors.border.withOpacity(0.3)
      ..strokeWidth = 1.0;

    for (final m in xMilestones) {
      if (m > maxMonths) continue;
      double x = dx(m);

      canvas.drawLine(Offset(x, topMargin),
          Offset(x, size.height - bottomMargin), dashGridPaint);

      String label = m == 0 ? 'Birth' : '${m.toInt()}m';
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: AppColors.mutedText,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - bottomMargin + 6));
    }

    // 3. WHO Percentile Curves & Shaded Corridor (3rd to 97th)
    final Path path97 = Path();
    final Path path50 = Path();
    final Path path3 = Path();

    final int samples = 50;
    for (int i = 0; i <= samples; i++) {
      double m = (i / samples) * maxMonths;
      List<double> percentiles = isWeight
          ? WhoGrowthStandard.getWeightPercentiles(m)
          : WhoGrowthStandard.getHeightPercentiles(m);

      double x = dx(m);
      double y3 = dy(percentiles[0]);
      double y50 = dy(percentiles[1]);
      double y97 = dy(percentiles[2]);

      if (i == 0) {
        path97.moveTo(x, y97);
        path50.moveTo(x, y50);
        path3.moveTo(x, y3);
      } else {
        path97.lineTo(x, y97);
        path50.lineTo(x, y50);
        path3.lineTo(x, y3);
      }
    }

    // Corridor polygon fill (97th percentile down to 3rd percentile)
    final Path corridorPath = Path.from(path97);
    for (int i = samples; i >= 0; i--) {
      double m = (i / samples) * maxMonths;
      List<double> percentiles = isWeight
          ? WhoGrowthStandard.getWeightPercentiles(m)
          : WhoGrowthStandard.getHeightPercentiles(m);
      double x = dx(m);
      double y3 = dy(percentiles[0]);
      corridorPath.lineTo(x, y3);
    }
    corridorPath.close();

    final Paint corridorPaint = Paint()
      ..color = AppColors.success.withOpacity(0.08)
      ..style = PaintingStyle.fill;
    canvas.drawPath(corridorPath, corridorPaint);

    final Paint boundaryLinePaint = Paint()
      ..color = AppColors.success.withOpacity(0.35)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path97, boundaryLinePaint);
    canvas.drawPath(path3, boundaryLinePaint);

    final Paint medianPaint = Paint()
      ..color = AppColors.success.withOpacity(0.85)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path50, medianPaint);

    // 4. Child's Growth Line & Points
    if (points.isNotEmpty) {
      final Path childPath = Path();
      for (int i = 0; i < points.length; i++) {
        double val = isWeight ? points[i].weightKg : points[i].heightCm;
        double x = dx(points[i].months);
        double y = dy(val);

        if (i == 0) {
          childPath.moveTo(x, y);
        } else {
          double prevX = dx(points[i - 1].months);
          double prevVal =
              isWeight ? points[i - 1].weightKg : points[i - 1].heightCm;
          double prevY = dy(prevVal);

          double controlX1 = prevX + (x - prevX) / 2;
          double controlY1 = prevY;
          double controlX2 = prevX + (x - prevX) / 2;
          double controlY2 = y;
          childPath.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
        }
      }

      // Fill area under child line
      final Path fillPath = Path.from(childPath);
      fillPath.lineTo(dx(points.last.months), dy(minY));
      fillPath.lineTo(dx(points.first.months), dy(minY));
      fillPath.close();

      final Paint childFillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withOpacity(0.25),
            AppColors.primary.withOpacity(0.0),
          ],
        ).createShader(Rect.fromLTWH(0, topMargin, size.width, chartH));
      canvas.drawPath(fillPath, childFillPaint);

      final Paint childLinePaint = Paint()
        ..color = AppColors.primary
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawPath(childPath, childLinePaint);

      // Find latest recorded visit index
      int latestRecordedIndex = -1;
      for (int i = points.length - 1; i >= 0; i--) {
        if (points[i].isRecorded) {
          latestRecordedIndex = i;
          break;
        }
      }

      // Draw Points
      for (int i = 0; i < points.length; i++) {
        double val = isWeight ? points[i].weightKg : points[i].heightCm;
        double x = dx(points[i].months);
        double y = dy(val);

        bool isSelected = selectedIndex == i;
        bool isLatestRecorded = (i == latestRecordedIndex);

        if (isSelected) {
          final Paint guidePaint = Paint()
            ..color = AppColors.primary.withOpacity(0.4)
            ..strokeWidth = 1.0
            ..style = PaintingStyle.stroke;

          canvas.drawLine(Offset(leftMargin, y), Offset(x, y), guidePaint);
          canvas.drawLine(
              Offset(x, y), Offset(x, size.height - bottomMargin), guidePaint);

          canvas.drawCircle(Offset(x, y), 10.0,
              Paint()..color = AppColors.primary.withOpacity(0.25));
          canvas.drawCircle(
              Offset(x, y), 6.0, Paint()..color = AppColors.primary);
          canvas.drawCircle(
              Offset(x, y), 2.5, Paint()..color = Colors.white);
        } else {
          canvas.drawCircle(Offset(x, y), 6.0,
              Paint()..color = AppColors.primary.withOpacity(0.3));
          canvas.drawCircle(
              Offset(x, y), 4.0, Paint()..color = AppColors.primary);
          canvas.drawCircle(
              Offset(x, y), 1.5, Paint()..color = Colors.white);
        }

        // Draw "Recent Visit" badge on top of the latest recorded visit dot
        if (isLatestRecorded) {
          final TextSpan recentSpan = const TextSpan(
            text: 'Recent Visit',
            style: TextStyle(
              color: Colors.white,
              fontSize: 8.5,
              fontWeight: FontWeight.bold,
            ),
          );

          final TextPainter recentTp = TextPainter(
            text: recentSpan,
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
          )..layout();

          final double badgeW = recentTp.width + 10.0;
          final double badgeH = recentTp.height + 4.0;
          final double badgeX = (x - badgeW / 2).clamp(leftMargin, size.width - rightMargin - badgeW);
          final double badgeY = (y - badgeH - 12.0).clamp(topMargin, size.height - bottomMargin);

          // Draw pill background
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(badgeX, badgeY, badgeW, badgeH),
              const Radius.circular(10.0),
            ),
            Paint()..color = AppColors.primary,
          );

          // Draw small downward triangle pointing to dot
          final Path triPath = Path();
          triPath.moveTo(x - 3, badgeY + badgeH);
          triPath.lineTo(x + 3, badgeY + badgeH);
          triPath.lineTo(x, badgeY + badgeH + 3.5);
          triPath.close();
          canvas.drawPath(triPath, Paint()..color = AppColors.primary);

          recentTp.paint(canvas, Offset(badgeX + 5.0, badgeY + 2.0));
        }
      }

      // Draw Interactive Hover Floating Tooltip (Compact Basic Info)
      if (selectedIndex != null &&
          selectedIndex! >= 0 &&
          selectedIndex! < points.length) {
        final pt = points[selectedIndex!];
        double val = isWeight ? pt.weightKg : pt.heightCm;
        double x = dx(pt.months);
        double y = dy(val);

        final valStr = isWeight
            ? '${pt.weightKg.toStringAsFixed(1)} kg'
            : '${pt.heightCm.toStringAsFixed(0)} cm';
        final titleText =
            pt.dateStr.isNotEmpty ? '${pt.label} (${pt.dateStr})' : pt.label;
        final bool isLatest = (selectedIndex == latestRecordedIndex);

        final TextSpan span = TextSpan(
          children: [
            if (isLatest)
              const TextSpan(
                text: 'Recent Visit\n',
                style: TextStyle(
                  color: Color(0xFFFFD54F),
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            TextSpan(
              text: '$titleText\n',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: valStr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );

        final TextPainter tp = TextPainter(
          text: span,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        )..layout();

        final double tooltipW = tp.width + 16.0;
        final double tooltipH = tp.height + 10.0;

        double tooltipX = x - tooltipW / 2;
        tooltipX =
            tooltipX.clamp(leftMargin, size.width - rightMargin - tooltipW);

        double tooltipY = y - tooltipH - 12.0;
        if (tooltipY < topMargin) {
          tooltipY = y + 12.0;
        }

        final RRect tooltipRRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(tooltipX, tooltipY, tooltipW, tooltipH),
          const Radius.circular(8.0),
        );

        canvas.drawRRect(
          tooltipRRect.shift(const Offset(0, 2)),
          Paint()..color = Colors.black.withOpacity(0.25),
        );
        canvas.drawRRect(
          tooltipRRect,
          Paint()..color = AppColors.primaryDark,
        );

        tp.paint(
          canvas,
          Offset(tooltipX + 8.0, tooltipY + 5.0),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant GrowthChartPainter oldDelegate) {
    return oldDelegate.metric != metric ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.points != points ||
        oldDelegate.maxMonths != maxMonths;
  }
}
