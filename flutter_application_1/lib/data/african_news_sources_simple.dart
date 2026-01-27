import 'package:flutter/material.dart';
import '../models/news_location.dart';

class AfricanNewsSourcesSimple {
  /// Get additional African news sources to add to the main sources
  static List<NewsSource> getAfricanSources() {
    return [
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
    ];
  }
}