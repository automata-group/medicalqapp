import 'package:frontend/core/l10n/generated/app_localizations.dart';
import '../../domain/entities/specialty.dart';

extension SpecialtyLocalization on Specialty {
  String getLocalizedName(AppLocalizations l10n) {
    switch (name) {
      case 'Orthodontics':
        return l10n.orthodontics;
      case 'Endodontics':
        return l10n.endodontics;
      case 'Prosthodontics':
        return l10n.prosthodontics;
      case 'Periodontics':
        return l10n.periodontics;
      case 'Pediatric Dentistry':
        return l10n.pediatricDentistry;
      case 'Restorative':
        return l10n.restorative;
      case 'Dental Surgery':
      case 'Oral Surgery':
        return l10n.oralSurgery;
      case 'Sterilization and Infection Control':
        return l10n.infectionControl;
      case 'Oral Medicine & Pathology':
        return l10n.oralMedicine;
      case 'Dental Ethics':
        return l10n.dentalEthics;
      default:
        return name;
    }
  }
}
