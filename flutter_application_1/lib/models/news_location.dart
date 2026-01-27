import 'package:flutter/material.dart';

/// Enum representing global continents
enum Continent {
  africa,
  europe,
  asia,
  northAmerica,
  southAmerica,
  oceania,
}

/// Extension for continent display names
extension ContinentExtension on Continent {
  String get displayName {
    switch (this) {
      case Continent.africa:
        return 'Africa';
      case Continent.europe:
        return 'Europe';
      case Continent.asia:
        return 'Asia';
      case Continent.northAmerica:
        return 'North America';
      case Continent.southAmerica:
        return 'South America';
      case Continent.oceania:
        return 'Oceania';
    }
  }
}

/// Represents a country with geographic and metadata information
class Country {
  final String code; // ISO 2-letter code
  final String name;
  final Continent continent;
  final List<String> mainCities;
  final String flagEmoji;

  const Country({
    required this.code,
    required this.name,
    required this.continent,
    required this.mainCities,
    required this.flagEmoji,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Country && runtimeType == other.runtimeType && code == other.code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => '$flagEmoji $name';
}

/// Represents a news source with geographic and API information
class NewsSource {
  final String id;
  final String name;
  final String? countryCode; // null for international sources
  final Continent? primaryContinent;
  final String apiType; // 'newsapi', 'rss', 'gnews', 'custom'
  final String? apiUrl;
  final Color badgeColor;

  const NewsSource({
    required this.id,
    required this.name,
    this.countryCode,
    this.primaryContinent,
    required this.apiType,
    this.apiUrl,
    required this.badgeColor,
  });

  bool get isInternational => countryCode == null;
  bool get hasApiUrl => apiUrl != null && apiUrl!.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewsSource && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => name;
}

/// Static data repository for global news sources and countries
class WorldNews {
  WorldNews._(); // Private constructor to prevent instantiation

  // =============================================================================
  // COUNTRIES BY CONTINENT
  // =============================================================================

  static const Map<Continent, List<Country>> countriesByContinent = {
    Continent.africa: [
      Country(
        code: 'ke',
        name: 'Kenya',
        continent: Continent.africa,
        mainCities: ['Nairobi', 'Mombasa', 'Kisumu', 'Nakuru', 'Eldoret'],
        flagEmoji: '🇰🇪',
      ),
      Country(
        code: 'ng',
        name: 'Nigeria',
        continent: Continent.africa,
        mainCities: ['Lagos', 'Abuja', 'Kano', 'Ibadan', 'Port Harcourt'],
        flagEmoji: '🇳🇬',
      ),
      Country(
        code: 'za',
        name: 'South Africa',
        continent: Continent.africa,
        mainCities: ['Cape Town', 'Johannesburg', 'Durban', 'Pretoria'],
        flagEmoji: '🇿🇦',
      ),
      Country(
        code: 'eg',
        name: 'Egypt',
        continent: Continent.africa,
        mainCities: ['Cairo', 'Alexandria', 'Giza', 'Luxor'],
        flagEmoji: '🇪🇬',
      ),
      Country(
        code: 'gh',
        name: 'Ghana',
        continent: Continent.africa,
        mainCities: ['Accra', 'Kumasi', 'Tamale', 'Takoradi'],
        flagEmoji: '🇬🇭',
      ),
      Country(
        code: 'tz',
        name: 'Tanzania',
        continent: Continent.africa,
        mainCities: ['Dar es Salaam', 'Dodoma', 'Mwanza', 'Arusha'],
        flagEmoji: '🇹🇿',
      ),
      Country(
        code: 'et',
        name: 'Ethiopia',
        continent: Continent.africa,
        mainCities: ['Addis Ababa', 'Dire Dawa', 'Mekelle', 'Bahir Dar'],
        flagEmoji: '🇪🇹',
      ),
      Country(
        code: 'gh',
        name: 'Ghana',
        continent: Continent.africa,
        mainCities: ['Accra', 'Kumasi', 'Tamale', 'Cape Coast'],
        flagEmoji: '🇬🇭',
      ),
      Country(
        code: 'eg',
        name: 'Egypt',
        continent: Continent.africa,
        mainCities: ['Cairo', 'Alexandria', 'Giza', 'Port Said'],
        flagEmoji: '🇪🇬',
      ),
    ],
    Continent.europe: [
      Country(
        code: 'gb',
        name: 'United Kingdom',
        continent: Continent.europe,
        mainCities: ['London', 'Manchester', 'Birmingham', 'Glasgow', 'Liverpool'],
        flagEmoji: '🇬🇧',
      ),
      Country(
        code: 'fr',
        name: 'France',
        continent: Continent.europe,
        mainCities: ['Paris', 'Marseille', 'Lyon', 'Toulouse', 'Nice'],
        flagEmoji: '🇫🇷',
      ),
      Country(
        code: 'de',
        name: 'Germany',
        continent: Continent.europe,
        mainCities: ['Berlin', 'Munich', 'Hamburg', 'Cologne', 'Frankfurt'],
        flagEmoji: '🇩🇪',
      ),
      Country(
        code: 'no',
        name: 'Norway',
        continent: Continent.europe,
        mainCities: ['Oslo', 'Bergen', 'Stavanger', 'Trondheim'],
        flagEmoji: '🇳🇴',
      ),
      Country(
        code: 'se',
        name: 'Sweden',
        continent: Continent.europe,
        mainCities: ['Stockholm', 'Gothenburg', 'Malmö', 'Uppsala'],
        flagEmoji: '🇸🇪',
      ),
      Country(
        code: 'it',
        name: 'Italy',
        continent: Continent.europe,
        mainCities: ['Rome', 'Milan', 'Naples', 'Turin', 'Florence'],
        flagEmoji: '🇮🇹',
      ),
      Country(
        code: 'es',
        name: 'Spain',
        continent: Continent.europe,
        mainCities: ['Madrid', 'Barcelona', 'Valencia', 'Seville', 'Bilbao'],
        flagEmoji: '🇪🇸',
      ),
    ],
    Continent.asia: [
      Country(
        code: 'in',
        name: 'India',
        continent: Continent.asia,
        mainCities: ['Mumbai', 'Delhi', 'Bangalore', 'Hyderabad', 'Chennai'],
        flagEmoji: '🇮🇳',
      ),
      Country(
        code: 'cn',
        name: 'China',
        continent: Continent.asia,
        mainCities: ['Beijing', 'Shanghai', 'Guangzhou', 'Shenzhen', 'Tianjin'],
        flagEmoji: '🇨🇳',
      ),
      Country(
        code: 'jp',
        name: 'Japan',
        continent: Continent.asia,
        mainCities: ['Tokyo', 'Osaka', 'Yokohama', 'Nagoya', 'Kyoto'],
        flagEmoji: '🇯🇵',
      ),
      Country(
        code: 'ae',
        name: 'United Arab Emirates',
        continent: Continent.asia,
        mainCities: ['Dubai', 'Abu Dhabi', 'Sharjah', 'Ajman'],
        flagEmoji: '🇦🇪',
      ),
      Country(
        code: 'sg',
        name: 'Singapore',
        continent: Continent.asia,
        mainCities: ['Singapore'],
        flagEmoji: '🇸🇬',
      ),
      Country(
        code: 'kr',
        name: 'South Korea',
        continent: Continent.asia,
        mainCities: ['Seoul', 'Busan', 'Incheon', 'Daegu', 'Daejeon'],
        flagEmoji: '🇰🇷',
      ),
    ],
    Continent.northAmerica: [
      Country(
        code: 'us',
        name: 'United States',
        continent: Continent.northAmerica,
        mainCities: ['New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix'],
        flagEmoji: '🇺🇸',
      ),
      Country(
        code: 'ca',
        name: 'Canada',
        continent: Continent.northAmerica,
        mainCities: ['Toronto', 'Montreal', 'Vancouver', 'Calgary', 'Ottawa'],
        flagEmoji: '🇨🇦',
      ),
      Country(
        code: 'mx',
        name: 'Mexico',
        continent: Continent.northAmerica,
        mainCities: ['Mexico City', 'Guadalajara', 'Monterrey', 'Puebla'],
        flagEmoji: '🇲🇽',
      ),
    ],
    Continent.southAmerica: [
      Country(
        code: 'br',
        name: 'Brazil',
        continent: Continent.southAmerica,
        mainCities: ['São Paulo', 'Rio de Janeiro', 'Brasília', 'Salvador'],
        flagEmoji: '🇧🇷',
      ),
      Country(
        code: 'ar',
        name: 'Argentina',
        continent: Continent.southAmerica,
        mainCities: ['Buenos Aires', 'Córdoba', 'Rosario', 'Mendoza'],
        flagEmoji: '🇦🇷',
      ),
      Country(
        code: 'co',
        name: 'Colombia',
        continent: Continent.southAmerica,
        mainCities: ['Bogotá', 'Medellín', 'Cali', 'Barranquilla'],
        flagEmoji: '🇨🇴',
      ),
    ],
    Continent.oceania: [
      Country(
        code: 'au',
        name: 'Australia',
        continent: Continent.oceania,
        mainCities: ['Sydney', 'Melbourne', 'Brisbane', 'Perth', 'Adelaide'],
        flagEmoji: '🇦🇺',
      ),
      Country(
        code: 'nz',
        name: 'New Zealand',
        continent: Continent.oceania,
        mainCities: ['Auckland', 'Wellington', 'Christchurch', 'Hamilton'],
        flagEmoji: '🇳🇿',
      ),
    ],
  };

  // =============================================================================
  // NEWS SOURCES BY CONTINENT
  // =============================================================================

  static const Map<Continent, List<NewsSource>> sourcesByContinent = {
    Continent.africa: [
      NewsSource(
        id: 'bbc-africa',
        name: 'BBC Africa',
        primaryContinent: Continent.africa,
        apiType: 'rss',
        apiUrl: 'https://feeds.bbci.co.uk/news/world/africa/rss.xml',
        badgeColor: Colors.red,
      ),
      NewsSource(
        id: 'daily-nation-kenya',
        name: 'Daily Nation Kenya',
        countryCode: 'ke',
        primaryContinent: Continent.africa,
        apiType: 'gnews',
        badgeColor: Colors.blue,
      ),
      NewsSource(
        id: 'standard-digital-kenya',
        name: 'Standard Digital Kenya',
        countryCode: 'ke',
        primaryContinent: Continent.africa,
        apiType: 'rss',
        apiUrl: 'https://standardmedia.co.ke/rss/headlines.xml',
        badgeColor: Colors.green,
      ),
      NewsSource(
        id: 'tuko-news-kenya',
        name: 'Tuko News Kenya',
        countryCode: 'ke',
        primaryContinent: Continent.africa,
        apiType: 'gnews',
        badgeColor: Colors.purple,
      ),
      NewsSource(
        id: 'citizen-digital-kenya',
        name: 'Citizen Digital Kenya',
        countryCode: 'ke',
        primaryContinent: Continent.africa,
        apiType: 'newsdata',
        badgeColor: Colors.indigo,
      ),
      NewsSource(
        id: 'ktn-news-kenya',
        name: 'KTN News Kenya',
        countryCode: 'ke',
        primaryContinent: Continent.africa,
        apiType: 'gnews',
        badgeColor: Colors.teal,
      ),
      NewsSource(
        id: 'ntv-kenya',
        name: 'NTV Kenya',
        countryCode: 'ke',
        primaryContinent: Continent.africa,
        apiType: 'newsdata',
        badgeColor: Colors.cyan,
      ),
      NewsSource(
        id: 'capital-news-kenya',
        name: 'Capital News Kenya',
        countryCode: 'ke',
        primaryContinent: Continent.africa,
        apiType: 'rss',
        apiUrl: 'https://www.capitalfm.co.ke/news/feed/',
        badgeColor: Colors.amber,
      ),
      NewsSource(
        id: 'punch-nigeria',
        name: 'Punch Nigeria',
        countryCode: 'ng',
        primaryContinent: Continent.africa,
        apiType: 'newsdata',
        badgeColor: Colors.orange,
      ),
      NewsSource(
        id: 'news24-south-africa',
        name: 'News24 South Africa',
        countryCode: 'za',
        primaryContinent: Continent.africa,
        apiType: 'newsdata',
        badgeColor: Colors.purple,
      ),
      
      // KENYA - Additional Sources
      NewsSource(
        id: 'daily-nation-ke',
        name: 'Daily Nation',
        countryCode: 'ke',
        primaryContinent: Continent.africa,
        apiType: 'rss',
        apiUrl: 'https://nation.africa/kenya/rss',
        badgeColor: Colors.blue,
      ),
      NewsSource(
        id: 'the-standard-ke',
        name: 'The Standard',
        countryCode: 'ke',
        primaryContinent: Continent.africa,
        apiType: 'rss',
        apiUrl: 'https://www.standardmedia.co.ke/rss/headlines.xml',
        badgeColor: Colors.red,
      ),
      NewsSource(
        id: 'business-daily-africa-ke',
        name: 'Business Daily Africa',
        countryCode: 'ke',
        primaryContinent: Continent.africa,
        apiType: 'rss',
        apiUrl: 'https://www.businessdailyafrica.com/bd/feeds/rss/latest',
        badgeColor: Colors.green,
      ),
      
      // NIGERIA - Additional Sources
      NewsSource(
        id: 'punch-ng',
        name: 'Punch Newspapers',
        countryCode: 'ng',
        primaryContinent: Continent.africa,
        apiType: 'rss',
        apiUrl: 'https://punchng.com/feed/',
        badgeColor: Colors.red,
      ),
      NewsSource(
        id: 'vanguard-ng',
        name: 'Vanguard',
        countryCode: 'ng',
        primaryContinent: Continent.africa,
        apiType: 'rss',
        apiUrl: 'https://www.vanguardngr.com/feed/',
        badgeColor: Colors.blue,
      ),
      NewsSource(
        id: 'premium-times-ng',
        name: 'Premium Times',
        countryCode: 'ng',
        primaryContinent: Continent.africa,
        apiType: 'rss',
        apiUrl: 'https://www.premiumtimesng.com/feed/',
        badgeColor: Colors.orange,
      ),
      NewsSource(
        id: 'channels-tv-ng',
        name: 'Channels TV',
        countryCode: 'ng',
        primaryContinent: Continent.africa,
        apiType: 'rss',
        apiUrl: 'https://www.channelstv.com/feed/',
        badgeColor: Colors.green,
      ),
      NewsSource(
        id: 'thecable-ng',
        name: 'TheCable',
        countryCode: 'ng',
        primaryContinent: Continent.africa,
        apiType: 'rss',
        apiUrl: 'https://www.thecable.ng/feed',
        badgeColor: Colors.teal,
      ),
      
      // SOUTH AFRICA - Additional Sources
      NewsSource(
        id: 'news24-za',
        name: 'News24',
        countryCode: 'za',
        primaryContinent: Continent.africa,
        apiType: 'rss',
        apiUrl: 'https://feeds.24.com/articles/news24/topstories/rss',
        badgeColor: Colors.blue,
      ),
      NewsSource(
        id: 'iol-za',
        name: 'IOL',
        countryCode: 'za',
        primaryContinent: Continent.africa,
        apiType: 'rss',
        apiUrl: 'https://www.iol.co.za/cmlink/1.730285',
        badgeColor: Colors.orange,
      ),
      NewsSource(
        id: 'timeslive-za',
        name: 'TimesLive',
        countryCode: 'za',
        primaryContinent: Continent.africa,
        apiType: 'rss',
        apiUrl: 'https://www.timeslive.co.za/rss/',
        badgeColor: Colors.red,
      ),
      NewsSource(
        id: 'daily-maverick-za',
        name: 'Daily Maverick',
        countryCode: 'za',
        primaryContinent: Continent.africa,
        apiType: 'rss',
        apiUrl: 'https://www.dailymaverick.co.za/dmrss/',
        badgeColor: Colors.purple,
      ),
      
      // GHANA
      NewsSource(
        id: 'ghanaweb-gh',
        name: 'GhanaWeb',
        countryCode: 'gh',
        primaryContinent: Continent.africa,
        apiType: 'rss',
        apiUrl: 'https://www.ghanaweb.com/GhanaHomePage/rss/news.xml',
        badgeColor: Colors.green,
      ),
      NewsSource(
        id: 'myjoyonline-gh',
        name: 'MyJoyOnline',
        countryCode: 'gh',
        primaryContinent: Continent.africa,
        apiType: 'rss',
        apiUrl: 'https://www.myjoyonline.com/feed/',
        badgeColor: Colors.orange,
      ),
      NewsSource(
        id: 'graphic-online-gh',
        name: 'Graphic Online',
        countryCode: 'gh',
        primaryContinent: Continent.africa,
        apiType: 'rss',
        apiUrl: 'https://www.graphic.com.gh/rss/news.xml',
        badgeColor: Colors.blue,
      ),
      
      // ETHIOPIA
      NewsSource(
        id: 'addis-standard-et',
        name: 'Addis Standard',
        countryCode: 'et',
        primaryContinent: Continent.africa,
        apiType: 'rss',
        apiUrl: 'https://addisstandard.com/feed/',
        badgeColor: Colors.green,
      ),
      NewsSource(
        id: 'ena-et',
        name: 'Ethiopian News Agency',
        countryCode: 'et',
        primaryContinent: Continent.africa,
        apiType: 'rss',
        apiUrl: 'https://www.ena.et/en/feed',
        badgeColor: Colors.red,
      ),
      
      // EGYPT
      NewsSource(
        id: 'egypt-today-eg',
        name: 'Egypt Today',
        countryCode: 'eg',
        primaryContinent: Continent.africa,
        apiType: 'rss',
        apiUrl: 'https://www.egypttoday.com/RSS',
        badgeColor: Colors.orange,
      ),
      NewsSource(
        id: 'ahram-online-eg',
        name: 'Ahram Online',
        countryCode: 'eg',
        primaryContinent: Continent.africa,
        apiType: 'rss',
        apiUrl: 'http://english.ahram.org.eg/rss.aspx',
        badgeColor: Colors.blue,
      ),
      
      // PAN-AFRICAN SOURCES
      NewsSource(
        id: 'africa-news',
        name: 'Africa News',
        countryCode: null,
        primaryContinent: Continent.africa,
        apiType: 'rss',
        apiUrl: 'https://www.africanews.com/api/rss/',
        badgeColor: Colors.orange,
      ),
      NewsSource(
        id: 'the-africa-report',
        name: 'The Africa Report',
        countryCode: null,
        primaryContinent: Continent.africa,
        apiType: 'rss',
        apiUrl: 'https://www.theafricareport.com/feed/',
        badgeColor: Colors.purple,
      ),
    ],
    Continent.europe: [
      NewsSource(
        id: 'bbc-news',
        name: 'BBC News',
        countryCode: 'gb',
        primaryContinent: Continent.europe,
        apiType: 'newsapi',
        badgeColor: Colors.red,
      ),
      NewsSource(
        id: 'le-figaro',
        name: 'Le Figaro',
        countryCode: 'fr',
        primaryContinent: Continent.europe,
        apiType: 'newsapi',
        badgeColor: Colors.blue,
      ),
      NewsSource(
        id: 'der-spiegel',
        name: 'Der Spiegel',
        countryCode: 'de',
        primaryContinent: Continent.europe,
        apiType: 'newsapi',
        badgeColor: Colors.red,
      ),
      NewsSource(
        id: 'nrk',
        name: 'NRK',
        countryCode: 'no',
        primaryContinent: Continent.europe,
        apiType: 'rss',
        apiUrl: 'https://www.nrk.no/toppsaker.rss',
        badgeColor: Colors.blue,
      ),
      NewsSource(
        id: 'la-gazzetta-dello-sport',
        name: 'La Gazzetta dello Sport',
        countryCode: 'it',
        primaryContinent: Continent.europe,
        apiType: 'newsapi',
        badgeColor: Colors.pink,
      ),
    ],
    Continent.asia: [
      NewsSource(
        id: 'times-of-india',
        name: 'Times of India',
        countryCode: 'in',
        primaryContinent: Continent.asia,
        apiType: 'newsapi',
        badgeColor: Colors.orange,
      ),
      NewsSource(
        id: 'south-china-morning-post',
        name: 'South China Morning Post',
        countryCode: 'cn',
        primaryContinent: Continent.asia,
        apiType: 'newsapi',
        badgeColor: Colors.red,
      ),
      NewsSource(
        id: 'japan-times',
        name: 'Japan Times',
        countryCode: 'jp',
        primaryContinent: Continent.asia,
        apiType: 'newsdata',
        badgeColor: Colors.red,
      ),
      NewsSource(
        id: 'gulf-news',
        name: 'Gulf News',
        countryCode: 'ae',
        primaryContinent: Continent.asia,
        apiType: 'gnews',
        badgeColor: Colors.blue,
      ),
      NewsSource(
        id: 'strait-times',
        name: 'Strait Times',
        countryCode: 'sg',
        primaryContinent: Continent.asia,
        apiType: 'gnews',
        badgeColor: Colors.purple,
      ),
    ],
    Continent.northAmerica: [
      NewsSource(
        id: 'cnn',
        name: 'CNN',
        countryCode: 'us',
        primaryContinent: Continent.northAmerica,
        apiType: 'newsapi',
        badgeColor: Colors.red,
      ),
      NewsSource(
        id: 'fox-news',
        name: 'Fox News',
        countryCode: 'us',
        primaryContinent: Continent.northAmerica,
        apiType: 'newsapi',
        badgeColor: Colors.blue,
      ),
      NewsSource(
        id: 'cbc-news',
        name: 'CBC News',
        countryCode: 'ca',
        primaryContinent: Continent.northAmerica,
        apiType: 'rss',
        apiUrl: 'https://www.cbc.ca/cmlink/rss-topstories',
        badgeColor: Colors.red,
      ),
      NewsSource(
        id: 'reuters',
        name: 'Reuters',
        countryCode: 'us',
        primaryContinent: Continent.northAmerica,
        apiType: 'newsapi',
        badgeColor: Colors.orange,
      ),
    ],
    Continent.southAmerica: [
      NewsSource(
        id: 'globo',
        name: 'O Globo',
        countryCode: 'br',
        primaryContinent: Continent.southAmerica,
        apiType: 'rss',
        apiUrl: 'https://oglobo.globo.com/rss.xml',
        badgeColor: Colors.blue,
      ),
      NewsSource(
        id: 'clarin',
        name: 'Clarín',
        countryCode: 'ar',
        primaryContinent: Continent.southAmerica,
        apiType: 'rss',
        apiUrl: 'https://www.clarin.com/rss/',
        badgeColor: Colors.red,
      ),
      NewsSource(
        id: 'el-tiempo',
        name: 'El Tiempo',
        countryCode: 'co',
        primaryContinent: Continent.southAmerica,
        apiType: 'rss',
        apiUrl: 'https://www.eltiempo.com/rss.xml',
        badgeColor: Colors.green,
      ),
    ],
    Continent.oceania: [
      NewsSource(
        id: 'abc-news-au',
        name: 'ABC News Australia',
        countryCode: 'au',
        primaryContinent: Continent.oceania,
        apiType: 'newsapi',
        badgeColor: Colors.red,
      ),
      NewsSource(
        id: 'the-sydney-morning-herald',
        name: 'Sydney Morning Herald',
        countryCode: 'au',
        primaryContinent: Continent.oceania,
        apiType: 'newsapi',
        badgeColor: Colors.blue,
      ),
      NewsSource(
        id: 'nz-herald',
        name: 'NZ Herald',
        countryCode: 'nz',
        primaryContinent: Continent.oceania,
        apiType: 'rss',
        apiUrl: 'https://www.nzherald.co.nz/rss/',
        badgeColor: Colors.green,
      ),
    ],
  };

  // =============================================================================
  // INTERNATIONAL NEWS SOURCES
  // =============================================================================

  static const List<NewsSource> internationalSources = [
    NewsSource(
      id: 'al-jazeera-english',
      name: 'Al Jazeera English',
      apiType: 'gnews', // Switch from RSS to GNews
      badgeColor: Colors.green,
    ),
    NewsSource(
      id: 'reuters-international',
      name: 'Reuters International',
      apiType: 'gnews', // Switch from NewsAPI to GNews
      badgeColor: Colors.orange,
    ),
    NewsSource(
      id: 'associated-press',
      name: 'Associated Press',
      apiType: 'newsdata', // Switch from NewsAPI to NewsData
      badgeColor: Colors.red,
    ),
    NewsSource(
      id: 'bbc-world',
      name: 'BBC World',
      apiType: 'gnews', // Switch from RSS to GNews
      badgeColor: Colors.red,
    ),
    NewsSource(
      id: 'guardian-international',
      name: 'The Guardian',
      apiType: 'gnews', // Add new GNews source
      badgeColor: Colors.green,
    ),
    NewsSource(
      id: 'financial-times',
      name: 'Financial Times',
      apiType: 'newsdata', // Add new NewsData source
      badgeColor: Colors.pink,
    ),
  ];

  // =============================================================================
  // HELPER METHODS
  // =============================================================================

  /// Get all countries as a flat list
  static List<Country> get allCountries {
    return countriesByContinent.values.expand((countries) => countries).toList();
  }

  /// Get all news sources as a flat list
  static List<NewsSource> get allSources {
    final continental = sourcesByContinent.values.expand((sources) => sources);
    return [...continental, ...internationalSources];
  }

  /// Find a country by its ISO code
  static Country? getCountryByCode(String code) {
    return allCountries.cast<Country?>().firstWhere(
          (country) => country?.code.toLowerCase() == code.toLowerCase(),
          orElse: () => null,
        );
  }

  /// Find a news source by its ID
  static NewsSource? getSourceById(String id) {
    return allSources.cast<NewsSource?>().firstWhere(
          (source) => source?.id == id,
          orElse: () => null,
        );
  }

  /// Get news sources for a specific continent
  static List<NewsSource> getSourcesForContinent(Continent continent) {
    return sourcesByContinent[continent] ?? [];
  }

  /// Get news sources for a specific country
  static List<NewsSource> getSourcesForCountry(String countryCode) {
    return allSources
        .where((source) => source.countryCode?.toLowerCase() == countryCode.toLowerCase())
        .toList();
  }

  /// Get countries for a specific continent
  static List<Country> getCountriesForContinent(Continent continent) {
    return countriesByContinent[continent] ?? [];
  }
}