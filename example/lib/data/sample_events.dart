import 'package:nepali_calendar_plus/nepali_calendar_plus.dart';

/// Custom model class for event details
/// Used as additional information in CalendarEvent
class Events {
  const Events({
    required this.title,
    required this.description,
    required this.additionalInfo,
    required this.eventType,
  });

  final String title;
  final String description;
  final String additionalInfo;
  final String eventType;
}

// Nepali Calendar Events for BS Year 2083 (Baishakh 2083 - Chaitra 2083)
// Corresponds to approx. April 14, 2026 - April 13, 2027 (AD)

final List<CalendarEvent<Events>> eventList = [
  // ----------------------------- BAISHAKH -----------------------------
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 1, day: 1),
    isHoliday: true,
    additionalInfo: Events(
      title: "मेष सङ्क्रान्ति / नयाँ वर्ष / बिस्का जात्रा",
      description: "Mesh Sankranti, Nepali New Year 2083, Biska Jatra.",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 1, day: 18),
    isHoliday: true,
    additionalInfo: Events(
      title: "बुद्ध जयन्ती / उभौली पर्व / अन्तर्राष्ट्रिय श्रमिक दिवस",
      description:
          "Buddha Jayanti, Ubhauli Parwa, Chandeshwari Jatra, Chandi Purnima, Gorakhnath Jayanti, Kurma Jayanti, International Labour Day.",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),

  // ------------------------------- JESTHA ------------------------------
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 2, day: 14),
    isHoliday: false,
    additionalInfo: Events(
      title: "बकर ईद / प्रदोष व्रत",
      description: "Bakar Eid (holiday for Muslim community), Pradosh Vrata.",
      additionalInfo: "Community holiday",
      eventType: "notHoliday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 2, day: 15),
    isHoliday: true,
    additionalInfo: Events(
      title: "गणतन्त्र दिवस / अन्तर्राष्ट्रिय सगरमाथा दिवस",
      description: "Republic Day, International Everest Day.",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),

  // -------------------------------- ASHAR -------------------------------
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 3, day: 6),
    isHoliday: false,
    additionalInfo: Events(
      title: "भोटो जात्रा / सिठी नाखा / अन्तर्राष्ट्रिय शरणार्थी दिवस",
      description: "Bhoto Jatra, Sithi Nakha, Kumar Sasthi, World Refugee Day.",
      additionalInfo: "Cultural & religious event",
      eventType: "notHoliday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 3, day: 32),
    isHoliday: false,
    additionalInfo: Events(
      title: "आर्थिक वर्ष २०८२/८३ को समापन",
      description:
          "Closing of fiscal year 2082/83; government offices finalise accounts.",
      additionalInfo: "Fiscal year-end closing",
      eventType: "notHoliday",
    ),
  ),

  // ------------------------------ SHRAWAN -------------------------------
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 4, day: 1),
    isHoliday: false,
    additionalInfo: Events(
      title: "नयाँ आर्थिक वर्ष २०८३/८४ सुरु",
      description: "Start of Nepal's new fiscal year, 2083/84.",
      additionalInfo: "New fiscal year begins",
      eventType: "notHoliday",
    ),
  ),

  // ------------------------------- BHADRA -------------------------------
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 5, day: 12),
    isHoliday: true,
    additionalInfo: Events(
      title: "जनै पूर्णिमा / रक्षाबन्धन / क्वाँटी खाने दिन",
      description:
          "Janai Purnima, Raksha Bandhan, Purnima Vrata, Kwati Khane Din, Rishi Tarpani, Sanskrit Diwas.",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 5, day: 13),
    isHoliday: true,
    additionalInfo: Events(
      title: "गाईजात्रा",
      description: "Gaijatra, International Day Against Nuclear Tests.",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 5, day: 19),
    isHoliday: true,
    additionalInfo: Events(
      title: "श्री कृष्ण जन्माष्टमी / गौरा पर्व",
      description:
          "Shree Krishna Janmashtami, Gaura Parva, Gorakhkali Puja, Durwashtami.",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 5, day: 29),
    isHoliday: true,
    additionalInfo: Events(
      title: "हरितालिका तीज",
      description:
          "Haritalika Teej, Ganesh Chaturthi Vrata, Rashtriya Dharmasabha Diwas, Rashtriya Bal Diwas.",
      additionalInfo: "Public holiday (women)",
      eventType: "holiday",
    ),
  ),

  // ------------------------------- ASHWIN -------------------------------
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 6, day: 3),
    isHoliday: true,
    additionalInfo: Events(
      title: "संविधान दिवस",
      description:
          "Sambidhan Diwas (Constitution Day), Radha Janmotsav, Gorakhkali Puja.",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 6, day: 9),
    isHoliday: false,
    additionalInfo: Events(
      title: "इन्द्रजात्रा",
      description:
          "Indra Jaatra, Ananta Chaturdashi Vrata, World Pharmacists Day.",
      additionalInfo: "Cultural & religious event",
      eventType: "notHoliday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 6, day: 18),
    isHoliday: false,
    additionalInfo: Events(
      title: "नवमी श्राद्ध / जितिया पर्व",
      description: "Nawami Shraddha, Jitiya Parva, World Animal Day.",
      additionalInfo: "Cultural & religious event",
      eventType: "notHoliday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 6, day: 25),
    isHoliday: true,
    additionalInfo: Events(
      title: "घटस्थापना",
      description: "Ghatasthapana Vrata, Navaratra Arambha (start of Dashain).",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 6, day: 31),
    isHoliday: true,
    additionalInfo: Events(
      title: "फूलपाती",
      description:
          "Fulpati, Dashain Holiday begins, International Day for the Eradication of Poverty.",
      additionalInfo: "Public holiday (Dashain)",
      eventType: "holiday",
    ),
  ),

  // ------------------------------- KARTIK -------------------------------
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 7, day: 1),
    isHoliday: true,
    additionalInfo: Events(
      title: "महाअष्टमी व्रत / कालरात्री",
      description:
          "Tula Sankranti, Maha Ashtami Vrata, Kalratri, Gorakhkali Puja.",
      additionalInfo: "Public holiday (Dashain)",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 7, day: 2),
    isHoliday: true,
    additionalInfo: Events(
      title: "दशैं बिदा",
      description: "Dashain Holiday.",
      additionalInfo: "Public holiday (Dashain)",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 7, day: 3),
    isHoliday: true,
    additionalInfo: Events(
      title: "महानवमी व्रत",
      description: "Maha Nawami Vrata.",
      additionalInfo: "Public holiday (Dashain)",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 7, day: 4),
    isHoliday: true,
    additionalInfo: Events(
      title: "विजया दशमी",
      description: "Bijaya Dashami, Devi Bisharjan.",
      additionalInfo: "Public holiday (Dashain)",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 7, day: 5),
    isHoliday: true,
    additionalInfo: Events(
      title: "पापाङ्कुशा एकादशी व्रत",
      description: "Papakunsa Ekadashi Vrata.",
      additionalInfo: "Public holiday (Dashain)",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 7, day: 6),
    isHoliday: true,
    additionalInfo: Events(
      title: "दशैं बिदा / प्रदोष व्रत",
      description:
          "Dashain Holiday, Pradosh Vrata (Duwadashi, last day of Dashain holidays).",
      additionalInfo: "Public holiday (Dashain)",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 7, day: 22),
    isHoliday: true,
    additionalInfo: Events(
      title: "लक्ष्मी पूजा / कुकुर तिहार",
      description:
          "Laxmi Pooja, Laxmi Prasad Devkota Janma Jayanti, Kukur Tihar, Narak Chaturdashi, Sukha Ratri, World Radiography Day.",
      additionalInfo: "Public holiday (Tihar)",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 7, day: 23),
    isHoliday: true,
    additionalInfo: Events(
      title: "तिहार बिदा / गाई पूजा",
      description: "Tihar Holiday, Gai Puja, World Freedom Day.",
      additionalInfo: "Public holiday (Tihar)",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 7, day: 24),
    isHoliday: true,
    additionalInfo: Events(
      title: "गोवर्धन पूजा / म्ह पूजा / नेपाल सम्बत १९४७",
      description:
          "Gobardan Puja, Mha Puja, Hali Tihar, Nepal Sambat 1147 Starts, Goru Puja, World Science Day for Peace and Development.",
      additionalInfo: "Public holiday (Tihar)",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 7, day: 25),
    isHoliday: true,
    additionalInfo: Events(
      title: "भाइटीका",
      description: "Bhai Tika, Kija Pooja, Falgunanda Jayanti.",
      additionalInfo: "Public holiday (Tihar)",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 7, day: 26),
    isHoliday: false,
    additionalInfo: Events(
      title: "तिहार बिदा",
      description: "Tihar Holiday, World Pneumonia Day.",
      additionalInfo: "Regional/office holiday",
      eventType: "notHoliday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 7, day: 29),
    isHoliday: true,
    additionalInfo: Events(
      title: "छठ पर्व",
      description: "Chhath Parva.",
      additionalInfo: "Public holiday (Terai region)",
      eventType: "holiday",
    ),
  ),

  // ------------------------------- MANGSIR -------------------------------
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 8, day: 8),
    isHoliday: false,
    additionalInfo: Events(
      title: "गुरु नानक जयन्ती / निम्बार्काचार्य जयन्ती",
      description:
          "Kartik Snan Samapti, Chaturmas Vrata Samapti, Guru Nanak Jayanti, Nimbarkacharya Jayanti, Sakimana Punhi.",
      additionalInfo: "Cultural & religious event",
      eventType: "notHoliday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 8, day: 17),
    isHoliday: false,
    additionalInfo: Events(
      title: "अन्तर्राष्ट्रिय अपाङ्ग दिवस",
      description:
          "International Day of Persons with Disabilities (only for specially-abled employees).",
      additionalInfo: "Special capacity employees only",
      eventType: "notHoliday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 8, day: 18),
    isHoliday: false,
    additionalInfo: Events(
      title: "उभौली पर्व / उत्पत्तिका एकादशी व्रत",
      description: "Udhauli Parva, Utpatika Ekadashi Vrata.",
      additionalInfo: "Cultural & religious event",
      eventType: "notHoliday",
    ),
  ),

  // -------------------------------- PAUSH --------------------------------
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 9, day: 9),
    isHoliday: false,
    additionalInfo: Events(
      title: "धन्य पूर्णिमा / यःमरी पुन्हि / ज्यापु दिवस",
      description: "Dhanya Purnima, Udhauli Parva, Yomari Punhi, Jyapu Diwas.",
      additionalInfo: "Cultural & religious event",
      eventType: "notHoliday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 9, day: 10),
    isHoliday: true,
    additionalInfo: Events(
      title: "क्रिसमस डे",
      description: "Christmas Day celebration.",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 9, day: 15),
    isHoliday: true,
    additionalInfo: Events(
      title: "तमु ल्होसार / लेखनाथ जयन्ती",
      description: "Tamu Lhosar, Poet Shiromani Lekhnath Jayanti.",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 9, day: 27),
    isHoliday: false,
    additionalInfo: Events(
      title: "पृथ्वी जयन्ती / राष्ट्रिय एकता दिवस",
      description: "Prithvi Jayanti, National Unity Day.",
      additionalInfo: "National observance",
      eventType: "notHoliday",
    ),
  ),

  // -------------------------------- MAGH ---------------------------------
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 10, day: 1),
    isHoliday: true,
    additionalInfo: Events(
      title: "माघे सङ्क्रान्ति",
      description: "Makar Sankranti, Ghyu-Chaku Khane Din, Uttarayan begins.",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 10, day: 16),
    isHoliday: true,
    additionalInfo: Events(
      title: "शहीद दिवस",
      description: "Martyrs' Day (Sahid Diwas).",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 10, day: 24),
    isHoliday: true,
    additionalInfo: Events(
      title: "सोनाम ल्होछार",
      description: "Sonam Lhochhar.",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 10, day: 28),
    isHoliday: false,
    additionalInfo: Events(
      title: "वसन्तपञ्चमी / सरस्वती पूजा",
      description:
          "Basant Panchami and Saraswati Puja (holiday for educational institutions only).",
      additionalInfo: "Educational institutions holiday",
      eventType: "notHoliday",
    ),
  ),

  // ------------------------------- FALGUN --------------------------------
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 11, day: 7),
    isHoliday: true,
    additionalInfo: Events(
      title: "प्रजातन्त्र दिवस",
      description: "Prajatantra Diwas (Democracy Day) / Election Day.",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 11, day: 22),
    isHoliday: true,
    additionalInfo: Events(
      title: "महाशिवरात्री",
      description: "Maha Shivaratri, Nepali Army Day, Silachahre Puja.",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 11, day: 24),
    isHoliday: false,
    additionalInfo: Events(
      title: "अन्तर्राष्ट्रिय महिला दिवस",
      description: "International Women's Day.",
      additionalInfo: "Special holiday for women employees",
      eventType: "notHoliday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 11, day: 25),
    isHoliday: true,
    additionalInfo: Events(
      title: "ग्याल्पो ल्होसार",
      description: "Gyalpo Lhosar.",
      additionalInfo: "Public holiday",
      eventType: "holiday",
    ),
  ),

  // ------------------------------- CHAITRA --------------------------------
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 12, day: 7),
    isHoliday: true,
    additionalInfo: Events(
      title: "फागु पूर्णिमा / होली",
      description: "Fagu Poornima / Holi, World Poetry Day.",
      additionalInfo: "Public holiday (Hill region)",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 12, day: 8),
    isHoliday: true,
    additionalInfo: Events(
      title: "फागु पूर्णिमा (तराई)",
      description: "Fagu Poornima (Terai), World Water Day.",
      additionalInfo: "Public holiday (Terai region)",
      eventType: "holiday",
    ),
  ),
  CalendarEvent(
    date: NepaliDateTime(year: 2083, month: 12, day: 23),
    isHoliday: false,
    additionalInfo: Events(
      title: "घोडेजात्रा",
      description: "Ghode Jaatra.",
      additionalInfo: "Cultural event (Kathmandu Valley)",
      eventType: "notHoliday",
    ),
  ),
];
