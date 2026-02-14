import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import 'result_controller.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ResultController controller = Get.put(ResultController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Get.offAllNamed(AppRoutes.home),
          child: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Color(0xFF2C3E50),
          ),
        ),
        title: const Text(
          'Scan Result',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.share_outlined,
              color: Color(0xFF2C3E50),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF2ECC71),
            ),
          );
        }

        final product = controller.product.value!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Authenticity Card ──
              _buildAuthenticityCard(product, controller),

              const SizedBox(height: 16),

              // ── Nutrition Score Card ──
              _buildNutritionScoreCard(product, controller),

              const SizedBox(height: 16),

              // ── Nutrient Breakdown ──
              _buildNutrientBreakdown(product, controller),

              const SizedBox(height: 16),

              // ── Health Warnings ──
              _buildHealthWarnings(product, controller),

              const SizedBox(height: 16),

              // ── Alternatives Button ──
              if (product.nutritionScore < 5)
                _buildAlternativesButton(),

              const SizedBox(height: 24),

              // ── Scan Again Button ──
              GestureDetector(
                onTap: () => Get.offNamed(AppRoutes.scan),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2ECC71),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      'Scan Another Product',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  // ── Authenticity Card ──
  Widget _buildAuthenticityCard(dynamic product, ResultController controller) {
    final authColor = controller.getAuthColor(product.authenticityStatus);
    final authIcon = controller.getAuthIcon(product.authenticityStatus);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Banner
          Container(
  width: double.infinity,
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: authColor.withOpacity(0.1),
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: authColor.withOpacity(0.3)),
  ),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(authIcon, color: authColor, size: 32),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.authenticityStatus,
              style: TextStyle(
                color: authColor,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              product.authenticityStatus == 'AUTHENTIC'
                  ? 'This product appears to be genuine'
                  : product.authenticityStatus == 'SUSPICIOUS'
                      ? 'Some details could not be verified'
                      : 'This product may be counterfeit!',
              style: TextStyle(
                color: authColor.withOpacity(0.8),
                fontSize: 13,
                height: 1.4,
              ),
              softWrap: true,
            ),
          ],
        ),
      ),
    ],
  ),
),

          const SizedBox(height: 16),

          // Product Details
          Text(
            product.productName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            product.brand,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7F8C8D),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF0F0F0)),
          const SizedBox(height: 12),

          // Verification Details
          _buildVerifyRow(
            'FSSAI Number',
            product.fssaiNumber,
            product.authenticityStatus != 'FAKE',
          ),
          const SizedBox(height: 10),
          _buildVerifyRow(
            'Brand Name',
            product.brand,
            product.authenticityStatus != 'FAKE',
          ),
          const SizedBox(height: 10),
          _buildVerifyRow(
            'Logo',
            product.authenticityStatus == 'AUTHENTIC'
                ? 'Verified'
                : 'Not Verified',
            product.authenticityStatus == 'AUTHENTIC',
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyRow(String label, String value, bool isValid) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF7F8C8D),
          ),
        ),
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                isValid
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                color: isValid
                    ? const Color(0xFF2ECC71)
                    : const Color(0xFFE74C3C),
                size: 18,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Nutrition Score Card ──
  Widget _buildNutritionScoreCard(
      dynamic product, ResultController controller) {
    final scoreColor = controller.getScoreColor(product.nutritionScore);
    final scoreLabel = controller.getScoreLabel(product.nutritionScore);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Score Circle
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scoreColor.withOpacity(0.12),
              border: Border.all(color: scoreColor, width: 3),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  product.nutritionScore.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: scoreColor,
                  ),
                ),
                Text(
                  '/ 10',
                  style: TextStyle(
                    fontSize: 12,
                    color: scoreColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nutrition Score',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: scoreColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    scoreLabel,
                    style: TextStyle(
                      color: scoreColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  product.nutritionScore >= 7
                      ? 'This product has good nutritional value'
                      : product.nutritionScore >= 4
                          ? 'Consume this product in moderation'
                          : 'Consider healthier alternatives',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7F8C8D),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Nutrient Breakdown ──
  Widget _buildNutrientBreakdown(
      dynamic product, ResultController controller) {
    final nutrients = product.nutrients as Map<String, dynamic>;

    final displayNutrients = [
      {'key': 'calories', 'label': 'Calories', 'unit': 'kcal', 'max': 500.0},
      {'key': 'protein', 'label': 'Protein', 'unit': 'g', 'max': 30.0},
      {
        'key': 'carbohydrates',
        'label': 'Carbohydrates',
        'unit': 'g',
        'max': 100.0
      },
      {'key': 'sugar', 'label': 'Sugar', 'unit': 'g', 'max': 30.0},
      {'key': 'fat', 'label': 'Total Fat', 'unit': 'g', 'max': 30.0},
      {
        'key': 'saturatedFat',
        'label': 'Saturated Fat',
        'unit': 'g',
        'max': 15.0
      },
      {'key': 'sodium', 'label': 'Sodium', 'unit': 'mg', 'max': 1000.0},
      {'key': 'fiber', 'label': 'Fiber', 'unit': 'g', 'max': 10.0},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nutrition Breakdown',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Per 100g serving',
            style: TextStyle(fontSize: 12, color: Color(0xFF7F8C8D)),
          ),
          const SizedBox(height: 16),
          ...displayNutrients.map((n) {
            final value =
                (nutrients[n['key']] as num?)?.toDouble() ?? 0.0;
            final max = n['max'] as double;
            final progress = (value / max).clamp(0.0, 1.0);
            final level = controller.getNutrientLevel(
                n['key'] as String, value);
            final color = controller.getNutrientColor(level);

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        n['label'] as String,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF2C3E50),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            '$value ${n['unit']}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          if (['sugar', 'sodium', 'fat', 'saturatedFat']
                              .contains(n['key'])) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                level,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: color,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: const Color(0xFFF0F0F0),
                      color: color,
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Health Warnings ──
  Widget _buildHealthWarnings(
      dynamic product, ResultController controller) {
    final nutrients = product.nutrients as Map<String, dynamic>;
    final warnings = <Map<String, dynamic>>[];

    final sodium = (nutrients['sodium'] as num?)?.toDouble() ?? 0;
    final sugar = (nutrients['sugar'] as num?)?.toDouble() ?? 0;
    final fat = (nutrients['fat'] as num?)?.toDouble() ?? 0;
    final saturatedFat =
        (nutrients['saturatedFat'] as num?)?.toDouble() ?? 0;

    if (sodium > 600) {
      warnings.add({
        'icon': Icons.water_drop_rounded,
        'color': const Color(0xFFE74C3C),
        'title': 'High Sodium',
        'desc': 'Not recommended for people with hypertension',
      });
    }
    if (sugar > 10) {
      warnings.add({
        'icon': Icons.icecream_rounded,
        'color': const Color(0xFFF39C12),
        'title': 'High Sugar',
        'desc': 'Not recommended for people with diabetes',
      });
    }
    if (fat > 17) {
      warnings.add({
        'icon': Icons.monitor_weight_rounded,
        'color': const Color(0xFFE74C3C),
        'title': 'High Fat',
        'desc': 'Not recommended for people managing obesity',
      });
    }
    if (saturatedFat > 5) {
      warnings.add({
        'icon': Icons.favorite_rounded,
        'color': const Color(0xFFE74C3C),
        'title': 'High Saturated Fat',
        'desc': 'Not recommended for people with heart disease',
      });
    }

    if (warnings.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF2ECC71).withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: const Color(0xFF2ECC71).withOpacity(0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.thumb_up_rounded, color: Color(0xFF2ECC71)),
            SizedBox(width: 12),
            Text(
              'No major health warnings for\nthis product!',
              style: TextStyle(
                color: Color(0xFF27AE60),
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '⚠️ Health Warnings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 14),
          ...warnings.map((w) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: (w['color'] as Color).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        w['icon'] as IconData,
                        color: w['color'] as Color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            w['title'] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          Text(
                            w['desc'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF7F8C8D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ── Alternatives Button ──
  Widget _buildAlternativesButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.swap_horiz_rounded,
                  color: Colors.white, size: 22),
              SizedBox(width: 10),
              Text(
                'See Healthier Alternatives',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}