import 'package:flutter/material.dart';

class AppStrings {
  final Locale locale;

  const AppStrings(this.locale);

  bool get isArabic => locale.languageCode == 'ar';

  // ============================================================
  // COMMON
  // ============================================================

  String get cancel => isArabic ? 'إلغاء' : 'Cancel';

  String get save => isArabic ? 'حفظ' : 'Save';

  String get delete => isArabic ? 'حذف' : 'Delete';

  String get edit => isArabic ? 'تعديل' : 'Edit';

  // ============================================================
  // NAVIGATION
  // ============================================================

  String get home => isArabic ? 'الرئيسية' : 'Home';

  String get habits => isArabic ? 'العادات' : 'Habits';

  String get garden => isArabic ? 'الحديقة' : 'Garden';

  String get progress => isArabic ? 'التقدم' : 'Progress';

  String get profile => isArabic ? 'الملف الشخصي' : 'Profile';

  // ============================================================
  // HOME
  // ============================================================

  String get goodMorning => isArabic ? 'صباح الخير 🌱' : 'Good Morning 🌱';

  String get growYourHabits => isArabic
      ? 'ازرع عاداتك، وطوّر حديقتك.'
      : 'Grow your habits, grow your garden.';

  String get todaysProgress => isArabic ? 'تقدم اليوم' : "Today's Progress";

  String get todaysHabits => isArabic ? 'عادات اليوم' : "Today's Habits";

  String get addHabit => isArabic ? 'إضافة عادة' : 'Add Habit';

  String get createHabit => isArabic ? 'إنشاء عادة' : 'Create Habit';

  String get gardenIsWaiting =>
      isArabic ? 'حديقتك في انتظارك!' : 'Your garden is waiting!';

  String get createFirstHabit => isArabic
      ? 'أنشئ أول عادة لك وابدأ في النمو.'
      : 'Create your first habit to start growing.';

  // ============================================================
  // HABITS
  // ============================================================

  String get myHabits => isArabic ? 'عاداتي' : 'My Habits';

  String get noHabits => isArabic
      ? 'لا توجد عادات حتى الآن 🌱\nأنشئ أول عادة لك!'
      : 'No habits yet 🌱\nCreate your first habit!';

  String streak(int days) =>
      isArabic ? '🔥 سلسلة $days يوم' : '🔥 $days day streak';

  String get deleteHabit => isArabic ? 'حذف العادة؟' : 'Delete Habit?';

  String deleteHabitMessage(String name) => isArabic
      ? 'هل أنت متأكد أنك تريد حذف "$name"؟'
      : 'Are you sure you want to delete "$name"?';

  // ============================================================
  // GARDEN
  // ============================================================

  String get myGarden => isArabic ? 'حديقتي' : 'My Garden';

  String get shareGarden => isArabic ? 'مشاركة الحديقة' : 'Share Garden';

  String get customizeGarden => isArabic ? 'تخصيص الحديقة' : 'Customize Garden';

  String get gardenWaiting =>
      isArabic ? 'حديقتك في انتظارك' : 'Your garden is waiting';

  // ============================================================
  // PROFILE
  // ============================================================

  String get profileTitle => isArabic ? 'الملف الشخصي' : 'Profile';

  String get habitGardener => isArabic ? 'بستاني العادات' : 'Habit Gardener';

  String get growingBetterHabits =>
      isArabic ? 'نبني عادات أفضل كل يوم' : 'Growing better habits every day';

  String get tapPhoto =>
      isArabic ? 'اضغط على الصورة لتغييرها' : 'Tap your photo to change it';

  String get editProfile => isArabic ? 'تعديل الملف الشخصي' : 'Edit Profile';

  String get changePhoto => isArabic ? 'تغيير الصورة' : 'Change Photo';

  String get habitsCount => isArabic ? 'العادات' : 'Habits';

  String get today => isArabic ? 'اليوم' : 'Today';

  String get bestStreak => isArabic ? 'أفضل سلسلة' : 'Best Streak';

  // ============================================================
  // PROFILE STATS
  // ============================================================

  String get overview => isArabic ? 'نظرة عامة' : 'Overview';

  String get totalCompleted =>
      isArabic ? 'إجمالي الإنجازات' : 'Total completed';

  String get growingPlants => isArabic ? 'النباتات النامية' : 'Growing plants';

  String get days => isArabic ? 'يوم' : 'days';

  String get times => isArabic ? 'مرات' : 'times';

  // ============================================================
  // PREFERENCES
  // ============================================================

  String get preferences => isArabic ? 'التفضيلات' : 'Preferences';

  String get notifications => isArabic ? 'الإشعارات' : 'Notifications';

  String get dailyHabitReminders =>
      isArabic ? 'تذكيرات العادات اليومية' : 'Daily habit reminders';

  String get settings => isArabic ? 'الإعدادات' : 'Settings';

  String get appPreferences =>
      isArabic ? 'إدارة تفضيلات التطبيق' : 'Manage app preferences';

  String get appearance => isArabic ? 'المظهر' : 'Appearance';

  String get chooseAppearance =>
      isArabic ? 'اختر مظهر التطبيق' : 'Choose how the app looks';

  String get language => isArabic ? 'اللغة' : 'Language';

  String get chooseLanguage =>
      isArabic ? 'اختر لغة التطبيق' : 'Choose your app language';

  String get light => isArabic ? 'فاتح' : 'Light';

  String get dark => isArabic ? 'داكن' : 'Dark';

  String get system => isArabic ? 'تلقائي' : 'System';

  String get english => 'English';

  String get arabic => 'العربية';

  // ============================================================
  // EDIT PROFILE
  // ============================================================

  String get yourName => isArabic ? 'اسمك' : 'Your name';

  String get enterYourName => isArabic ? 'أدخل اسمك' : 'Enter your name';

  String get pleaseEnterName =>
      isArabic ? 'من فضلك أدخل اسمك.' : 'Please enter your name.';

  // ============================================================
  // APP
  // ============================================================

  String get appName => 'Digital Habit Garden';

  String get appTagline => isArabic
      ? 'ازرع عاداتك، وطوّر نفسك.'
      : 'Grow your habits, grow yourself.';
}

class AppStringsScope extends InheritedWidget {
  final AppStrings strings;

  const AppStringsScope({
    super.key,
    required this.strings,
    required super.child,
  });

  static AppStrings of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppStringsScope>()!
        .strings;
  }

  @override
  bool updateShouldNotify(AppStringsScope oldWidget) {
    return strings.locale != oldWidget.strings.locale;
  }
}
