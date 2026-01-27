import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/news_location.dart';
import '../models/filter_selection.dart';

class NewsFilterBottomSheet extends StatefulWidget {
  final FilterSelection initialSelection;
  final Function(FilterSelection) onApplyFilters;

  const NewsFilterBottomSheet({
    super.key,
    required this.initialSelection,
    required this.onApplyFilters,
  });

  @override
  State<NewsFilterBottomSheet> createState() => _NewsFilterBottomSheetState();

  /// Show the filter bottom sheet
  static Future<FilterSelection?> show(
    BuildContext context, {
    required FilterSelection initialSelection,
  }) {
    return showModalBottomSheet<FilterSelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NewsFilterBottomSheet(
        initialSelection: initialSelection,
        onApplyFilters: (selection) => Navigator.of(context).pop(selection),
      ),
    );
  }
}

class _NewsFilterBottomSheetState extends State<NewsFilterBottomSheet>
    with TickerProviderStateMixin {
  late FilterSelection _currentSelection;
  late AnimationController _tierAnimationController;
  late Animation<double> _tierAnimation;

  // Continent colors for visual coding
  static const Map<Continent, Color> _continentColors = {
    Continent.africa: Colors.orange,
    Continent.europe: Colors.blue,
    Continent.asia: Colors.green,
    Continent.northAmerica: Colors.red,
    Continent.southAmerica: Colors.purple,
    Continent.oceania: Colors.teal,
  };

  // Continent emojis
  static const Map<Continent, String> _continentEmojis = {
    Continent.africa: '🌍',
    Continent.europe: '🇪🇺',
    Continent.asia: '🌏',
    Continent.northAmerica: '🌎',
    Continent.southAmerica: '🌎',
    Continent.oceania: '🏝️',
  };

  @override
  void initState() {
    super.initState();
    _currentSelection = widget.initialSelection;
    
    _tierAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _tierAnimation = CurvedAnimation(
      parent: _tierAnimationController,
      curve: Curves.easeInOut,
    );

    if (_currentSelection.selectedContinent != null) {
      _tierAnimationController.forward();
    }
  }

  @override
  void dispose() {
    _tierAnimationController.dispose();
    super.dispose();
  }

  void _updateSelection(FilterSelection newSelection) {
    setState(() {
      _currentSelection = newSelection;
    });
    
    // Trigger haptic feedback
    HapticFeedback.lightImpact();
    
    // Animate tier expansion/collapse
    if (newSelection.selectedContinent != null && _tierAnimationController.value == 0) {
      _tierAnimationController.forward();
    } else if (newSelection.selectedContinent == null && _tierAnimationController.value == 1) {
      _tierAnimationController.reverse();
    }
  }

  void _resetFilters() {
    HapticFeedback.mediumImpact();
    _updateSelection(const FilterSelection());
  }

  void _applyFilters() {
    HapticFeedback.selectionClick();
    widget.onApplyFilters(_currentSelection);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);

    return Container(
      height: screenHeight * 0.7,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.filter_list,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Filter News Sources',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_currentSelection.hasActiveFilters)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_currentSelection.activeFilterCount}',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Filter content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tier 1: Continent Selection
                  _buildTier1ContinentSelection(theme),
                  
                  // Tier 2: Country Selection
                  AnimatedBuilder(
                    animation: _tierAnimation,
                    builder: (context, child) {
                      return SizeTransition(
                        sizeFactor: _tierAnimation,
                        child: _buildTier2CountrySelection(theme),
                      );
                    },
                  ),
                  
                  // Tier 3: News Source Selection
                  AnimatedBuilder(
                    animation: _tierAnimation,
                    builder: (context, child) {
                      return SizeTransition(
                        sizeFactor: _tierAnimation,
                        child: _buildTier3SourceSelection(theme),
                      );
                    },
                  ),
                  
                  // Statistics
                  if (_currentSelection.hasActiveFilters)
                    _buildStatistics(theme),
                  
                  const SizedBox(height: 100), // Bottom padding for action bar
                ],
              ),
            ),
          ),
          
          // Bottom action bar
          _buildBottomActionBar(theme),
        ],
      ),
    );
  }

  Widget _buildTier1ContinentSelection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            '1. Select Continent',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: Continent.values.length + 1, // +1 for "Global"
            itemBuilder: (context, index) {
              if (index == 0) {
                // Global option
                final isSelected = _currentSelection.selectedContinent == null;
                return _buildContinentChip(
                  label: 'Global',
                  emoji: '🌍',
                  color: Colors.grey,
                  isSelected: isSelected,
                  onTap: () {
                    _updateSelection(_currentSelection.copyWith(
                      selectedContinent: null,
                      selectedCountries: [],
                      selectedSources: [],
                    ));
                  },
                );
              }

              final continent = Continent.values[index - 1];
              final isSelected = _currentSelection.selectedContinent == continent;
              
              return _buildContinentChip(
                label: continent.displayName,
                emoji: _continentEmojis[continent] ?? '🌍',
                color: _continentColors[continent] ?? Colors.grey,
                isSelected: isSelected,
                onTap: () {
                  _updateSelection(_currentSelection.copyWith(
                    selectedContinent: continent,
                    selectedCountries: [],
                    selectedSources: [],
                  ));
                },
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildContinentChip({
    required String label,
    required String emoji,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Material(
        color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? color : Colors.grey.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? color : null,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTier2CountrySelection(ThemeData theme) {
    if (_currentSelection.selectedContinent == null) {
      return const SizedBox.shrink();
    }

    final countries = WorldNews.getCountriesForContinent(_currentSelection.selectedContinent!);
    final continentColor = _continentColors[_currentSelection.selectedContinent!] ?? Colors.grey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Text(
                '2. Select Countries',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  final allSelected = _currentSelection.selectedCountries.length == countries.length;
                  _updateSelection(_currentSelection.copyWith(
                    selectedCountries: allSelected ? [] : countries,
                  ));
                },
                child: Text(
                  _currentSelection.selectedCountries.length == countries.length 
                    ? 'Deselect All' 
                    : 'Select All',
                ),
              ),
            ],
          ),
        ),
        
        // All [Continent] option
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: _buildCountryChip(
            label: 'All ${_currentSelection.selectedContinent!.displayName}',
            flagEmoji: _continentEmojis[_currentSelection.selectedContinent!] ?? '🌍',
            color: continentColor,
            isSelected: _currentSelection.selectedCountries.length == countries.length,
            onTap: () {
              final allSelected = _currentSelection.selectedCountries.length == countries.length;
              _updateSelection(_currentSelection.copyWith(
                selectedCountries: allSelected ? [] : countries,
              ));
            },
          ),
        ),
        
        // Individual countries
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: countries.map((country) {
            final isSelected = _currentSelection.selectedCountries.contains(country);
            return _buildCountryChip(
              label: country.name,
              flagEmoji: country.flagEmoji,
              color: continentColor,
              isSelected: isSelected,
              onTap: () {
                final updatedCountries = List<Country>.from(_currentSelection.selectedCountries);
                if (isSelected) {
                  updatedCountries.remove(country);
                } else {
                  updatedCountries.add(country);
                }
                _updateSelection(_currentSelection.copyWith(
                  selectedCountries: updatedCountries,
                ));
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCountryChip({
    required String label,
    required String flagEmoji,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? color : Colors.grey.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(flagEmoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : null,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTier3SourceSelection(ThemeData theme) {
    if (_currentSelection.selectedContinent == null && _currentSelection.selectedCountries.isEmpty) {
      return const SizedBox.shrink();
    }

    List<NewsSource> availableSources = [];
    
    // Get sources based on selections
    if (_currentSelection.selectedCountries.isNotEmpty) {
      for (final country in _currentSelection.selectedCountries) {
        availableSources.addAll(WorldNews.getSourcesForCountry(country.code));
      }
    } else if (_currentSelection.selectedContinent != null) {
      availableSources = WorldNews.getSourcesForContinent(_currentSelection.selectedContinent!);
    }

    // Add international sources (create a new modifiable list)
    final List<NewsSource> allSources = List.from(availableSources);
    allSources.addAll(WorldNews.internationalSources);

    // Remove duplicates
    availableSources = allSources.toSet().toList();

    if (availableSources.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Text(
                '3. Select News Sources',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  final allSelected = _currentSelection.selectedSources.length == availableSources.length;
                  _updateSelection(_currentSelection.copyWith(
                    selectedSources: allSelected ? [] : availableSources,
                  ));
                },
                child: Text(
                  _currentSelection.selectedSources.length == availableSources.length 
                    ? 'Deselect All' 
                    : 'Select All',
                ),
              ),
            ],
          ),
        ),
        
        // Sources list
        ...availableSources.map((source) {
          final isSelected = _currentSelection.selectedSources.contains(source);
          return _buildSourceTile(
            source: source,
            isSelected: isSelected,
            theme: theme,
            onTap: () {
              final updatedSources = List<NewsSource>.from(_currentSelection.selectedSources);
              if (isSelected) {
                updatedSources.remove(source);
              } else {
                updatedSources.add(source);
              }
              _updateSelection(_currentSelection.copyWith(
                selectedSources: updatedSources,
              ));
            },
          );
        }).toList(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSourceTile({
    required NewsSource source,
    required bool isSelected,
    required ThemeData theme,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isSelected ? source.badgeColor.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected 
                  ? source.badgeColor 
                  : theme.dividerColor.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Source icon/badge
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: source.badgeColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.article,
                    color: source.badgeColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Source details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        source.name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      if (source.countryCode != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              WorldNews.getCountryByCode(source.countryCode!)?.flagEmoji ?? '',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              WorldNews.getCountryByCode(source.countryCode!)?.name ?? '',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.hintColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Checkbox
                Checkbox(
                  value: isSelected,
                  onChanged: (_) => onTap(),
                  activeColor: source.badgeColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatistics(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Filter Statistics',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                label: 'Sources',
                value: '${_currentSelection.selectedSources.length}',
                theme: theme,
              ),
              _buildStatItem(
                label: 'Countries',
                value: '${_currentSelection.selectedCountries.length}',
                theme: theme,
              ),
              _buildStatItem(
                label: 'Est. Articles',
                value: '${_currentSelection.estimatedArticles}',
                theme: theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.hintColor,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Reset button
            Expanded(
              child: OutlinedButton(
                onPressed: _currentSelection.hasActiveFilters ? _resetFilters : null,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: theme.colorScheme.outline,
                  ),
                ),
                child: const Text('Reset Filters'),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Apply button
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Apply Filters'),
                    if (_currentSelection.hasActiveFilters) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onPrimary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${_currentSelection.activeFilterCount}',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}