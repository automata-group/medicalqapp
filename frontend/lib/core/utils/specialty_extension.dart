import 'package:frontend/core/l10n/generated/app_localizations.dart';
import '../../domain/entities/specialty.dart';

extension SpecialtyLocalization on Specialty {
  String getLocalizedName(AppLocalizations l10n) {
    return getSpecialtyLocalizedName(name, l10n);
  }
}

String getSpecialtyLocalizedName(String name, AppLocalizations l10n) {
  final cleanName = name.trim();
  final lower = cleanName.toLowerCase();

  if (lower.contains('ortho')) return l10n.orthodontics;
  if (lower.contains('endo')) return l10n.endodontics;
  if (lower.contains('prosth')) return l10n.prosthodontics;
  if (lower.contains('perio')) return l10n.periodontics;
  if (lower.contains('pediatric') || lower.contains('paediatric')) return l10n.pediatricDentistry;
  if (lower.contains('restor')) return l10n.restorative;
  if (lower.contains('surg')) return l10n.oralSurgery;
  if (lower.contains('steril') || lower.contains('infect')) return l10n.infectionControl;
  if (lower.contains('patholog') || lower.contains('oral med') || lower.contains('medicine')) return l10n.oralMedicine;
  if (lower.contains('ethic')) return l10n.dentalEthics;

  switch (cleanName) {
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
    case 'Restorative Dentistry':
      return l10n.restorative;
    case 'Dental Surgery':
    case 'Oral Surgery':
      return l10n.oralSurgery;
    case 'Sterilization and Infection Control':
    case 'Infection Control':
      return l10n.infectionControl;
    case 'Oral Medicine & Pathology':
    case 'Oral Medicine':
      return l10n.oralMedicine;
    case 'Dental Ethics':
    case 'dental ethics & professionalism':
    case 'Dental Ethics & Professionalism':
      return l10n.dentalEthics;
    default:
      return cleanName;
  }
}
