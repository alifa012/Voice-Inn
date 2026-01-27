import '../models/news_location.dart';

/// Represents the current filter selections
class FilterSelection {
  final Continent? selectedContinent;
  final List<Country> selectedCountries;
  final List<NewsSource> selectedSources;

  const FilterSelection({
    this.selectedContinent,
    this.selectedCountries = const [],
    this.selectedSources = const [],
  });

  /// Create a copy with updated selections
  FilterSelection copyWith({
    Continent? selectedContinent,
    List<Country>? selectedCountries,
    List<NewsSource>? selectedSources,
  }) {
    return FilterSelection(
      selectedContinent: selectedContinent ?? this.selectedContinent,
      selectedCountries: selectedCountries ?? this.selectedCountries,
      selectedSources: selectedSources ?? this.selectedSources,
    );
  }

  /// Clear all selections
  FilterSelection clear() {
    return const FilterSelection();
  }

  /// Check if any filters are active
  bool get hasActiveFilters {
    return selectedContinent != null || 
           selectedCountries.isNotEmpty || 
           selectedSources.isNotEmpty;
  }

  /// Get total number of active filters
  int get activeFilterCount {
    int count = 0;
    if (selectedContinent != null) count++;
    count += selectedCountries.length;
    count += selectedSources.length;
    return count;
  }

  /// Get estimated number of articles
  int get estimatedArticles {
    if (selectedSources.isEmpty) {
      return 50; // Default estimate
    }
    return selectedSources.length * 15; // Estimate 15 articles per source
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterSelection &&
          runtimeType == other.runtimeType &&
          selectedContinent == other.selectedContinent &&
          _listEquals(selectedCountries, other.selectedCountries) &&
          _listEquals(selectedSources, other.selectedSources);

  @override
  int get hashCode =>
      selectedContinent.hashCode ^
      selectedCountries.hashCode ^
      selectedSources.hashCode;

  bool _listEquals<T>(List<T> list1, List<T> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  @override
  String toString() {
    return 'FilterSelection(continent: $selectedContinent, '
           'countries: ${selectedCountries.length}, '
           'sources: ${selectedSources.length})';
  }
}