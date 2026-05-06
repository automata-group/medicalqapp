import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/specialty.dart';
import '../../domain/repositories/specialty_repository.dart';

class SpecialtyProvider extends ChangeNotifier {
  final SpecialtyRepository specialtyRepository;
  final SharedPreferences prefs;

  SpecialtyProvider({required this.specialtyRepository, required this.prefs}) {
    _loadFromCache();
  }

  List<Specialty> _specialties = [];
  List<Specialty> get specialties => _specialties;

  final Set<int> _selectedSpecialtyIds = {};
  Set<int> get selectedSpecialtyIds => _selectedSpecialtyIds;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _loadFromCache() {
    try {
      final specialtiesJson = prefs.getString('cached_specialties');
      final selectedIdsJson = prefs.getString('cached_selected_specialty_ids');

      if (specialtiesJson != null) {
        final List<dynamic> decoded = json.decode(specialtiesJson);
        _specialties = decoded.map((e) => Specialty.fromJson(e)).toList();
        debugPrint('Specialty Cache: ${_specialties.length} items loaded');
      }
      if (selectedIdsJson != null) {
        final List<dynamic> decoded = json.decode(selectedIdsJson);
        _selectedSpecialtyIds.addAll(decoded.cast<int>());
        debugPrint('Specialty Cache: ${_selectedSpecialtyIds.length} IDs selected');
      }
      if (_specialties.isNotEmpty || _selectedSpecialtyIds.isNotEmpty) {
        Future.microtask(() => notifyListeners());
      }
    } catch (e) {
      debugPrint('Error loading specialty cache: $e');
    }
  }

  void _saveToCache() {
    try {
      prefs.setString('cached_specialties', 
          json.encode(_specialties.map((e) => e.toJson()).toList()));
      prefs.setString('cached_selected_specialty_ids', 
          json.encode(_selectedSpecialtyIds.toList()));
      debugPrint('Specialty Cache: Saved to local storage');
    } catch (e) {
      debugPrint('Error saving specialty cache: $e');
    }
  }

  Future<void> loadUserSpecialties() async {
    final hasNoData = _selectedSpecialtyIds.isEmpty;
    if (hasNoData) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final userSpecialtyIds = await specialtyRepository.getUserSpecialties();
      // Only update if we actually got a response (even if empty, 
      // but ensure it didn't throw before we reach here)
      _selectedSpecialtyIds.clear();
      _selectedSpecialtyIds.addAll(userSpecialtyIds);
      _saveToCache();
    } catch (e) {
      debugPrint('Specialty Load User Error: $e');
      // If network fails, we keep the cached _selectedSpecialtyIds
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSpecialties() async {
    final hasNoData = _specialties.isEmpty;
    if (hasNoData) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final data = await specialtyRepository.getSpecialties();
      if (data.isNotEmpty) {
        _specialties = data;
        _saveToCache();
      }
    } catch (e) {
      debugPrint('Specialty Load All Error: $e');
      // Keep old cache if load fails
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleSpecialty(int id) {
    if (_selectedSpecialtyIds.contains(id)) {
      _selectedSpecialtyIds.remove(id);
    } else {
      _selectedSpecialtyIds.add(id);
    }
    notifyListeners();
    _saveToCache();
  }

  bool isSelected(int id) => _selectedSpecialtyIds.contains(id);

  Future<bool> saveInterests() async {
    _isLoading = true;
    notifyListeners();

    try {
      await specialtyRepository
          .saveUserInterests(_selectedSpecialtyIds.toList());
      _saveToCache();
      return true;
    } catch (e) {
      debugPrint('Error saving user interests: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
