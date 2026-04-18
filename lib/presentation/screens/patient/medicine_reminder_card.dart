import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pharma_app/core/themes/app_colors.dart';
import 'package:pharma_app/core/themes/app_text_styles.dart';
import 'package:pharma_app/presentation/widgets/common/app_buttons.dart';
import 'package:pharma_app/presentation/widgets/common/app_card.dart';
import 'package:pharma_app/presentation/widgets/common/icon_circle.dart';
import 'package:pharma_app/presentation/widgets/illustrations/medicine_illustration.dart';
import 'package:pharma_app/services/treatment_provider.dart';
import 'package:pharma_app/data/models/prise_planifiee.dart';

/// MedicineReminderCard - Card "Did you take your Medicine?"
class MedicineReminderCard extends StatefulWidget {
  final PrisePlanifiee prise;
  final VoidCallback? onEdit;

  const MedicineReminderCard({Key? key, required this.prise, this.onEdit})
    : super(key: key);

  @override
  State<MedicineReminderCard> createState() => _MedicineReminderCardState();
}

class _MedicineReminderCardState extends State<MedicineReminderCard> {
  late bool _isConfirmed;

  @override
  void initState() {
    super.initState();
    _isConfirmed = widget.prise.isConfirmed;
  }

  void _confirmMedicine() async {
    final treatmentProvider = Provider.of<TreatmentProvider>(
      context,
      listen: false,
    );

    // Animation
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );

    try {
      final success = await treatmentProvider.confirmerPrise(widget.prise);

      if (mounted) {
        Navigator.pop(context); // Fermer le loading

        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                treatmentProvider.error ?? 'Impossible de confirmer la prise.',
              ),
              backgroundColor: AppColors.danger,
            ),
          );
          return;
        }

        setState(() {
          _isConfirmed = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medicine confirmed! Keep it up!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Fermer le loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Gradient background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFD6ECFF), Color(0xFFF0F8FF), Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // Contenu
            Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.warning,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: AppColors.danger,
                        iconSize: 24,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Skip this dose?'),
                              content: const Text('Mark as skipped?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Skip'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Question
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Did you take',
                        style: AppTextStyles.questionText,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'your Medicine?',
                        style: AppTextStyles.questionText,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Illustration (dynamique selon le type)
                      Container(
                        height: 200,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        decoration: BoxDecoration(
                          color: AppColors.primaryPale,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Center(
                          child: MedicineIllustration(
                            medicinType: widget.prise.type,
                            height: 180,
                            width: 180,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bas: Info + Boutons
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  child: Container(
                    color: AppColors.surface,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Medicine name
                        Text(
                          widget.prise.medicamentNom,
                          style: AppTextStyles.medicName,
                        ),
                        const SizedBox(height: 20),

                        // Info Row 1: Heure
                        Row(
                          children: [
                            IconCircle(icon: Icons.calendar_today, size: 40),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Scheduled for ${widget.prise.heurePrevue}, Wednesday',
                                    style: AppTextStyles.fieldValue,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Info Row 2: Dosage
                        Row(
                          children: [
                            IconCircle(icon: Icons.description, size: 40),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${widget.prise.dosage}, ${widget.prise.type}',
                                style: AppTextStyles.fieldValue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Boutons
                        if (!_isConfirmed)
                          Row(
                            children: [
                              Expanded(
                                child: PrimaryButton(
                                  label: 'Take',
                                  onPressed: _confirmMedicine,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: AppColors.editBlue,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(14),
                                    ),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: widget.onEdit,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(14),
                                      ),
                                      splashColor: Colors.white.withOpacity(
                                        0.2,
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Edit',
                                          style: AppTextStyles.buttonPrimary
                                              .copyWith(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primaryPale,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(14),
                              ),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Confirmed at ${widget.prise.heureReelle ?? 'Now'}',
                                    style: AppTextStyles.fieldValue.copyWith(
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget pour afficher une liste de reminders en Card
class MedicineRemindersListView extends StatelessWidget {
  final List<PrisePlanifiee> prises;
  final Function(PrisePlanifiee) onCardTap;

  const MedicineRemindersListView({
    Key? key,
    required this.prises,
    required this.onCardTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (prises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: AppColors.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text('No medicines today', style: AppTextStyles.fieldLabel),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: prises.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final prise = prises[index];
        return GestureDetector(
          onTap: () => onCardTap(prise),
          child: AppCard(
            onTap: () => onCardTap(prise),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prise.medicamentNom,
                            style: AppTextStyles.cardTitle,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${prise.heurePrevue} • ${prise.dosage}',
                            style: AppTextStyles.fieldLabel,
                          ),
                        ],
                      ),
                    ),
                    if (prise.isConfirmed)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 24,
                      )
                    else if (prise.isMissed)
                      const Icon(
                        Icons.cancel,
                        color: AppColors.danger,
                        size: 24,
                      )
                    else
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.warning,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


