import 'package:flutter/material.dart';

class AppStrings {
  final Locale locale;

  const AppStrings(this.locale);

  bool get isArabic => locale.languageCode == 'ar';

  // ============================================================
  // GENERAL
  // ============================================================

  String get cancel => isArabic ? 'إلغاء' : 'Cancel';

  String get save => isArabic ? 'حفظ' : 'Save';

  String get delete => isArabic ? 'حذف' : 'Delete';

  String get edit => isArabic ? 'تعديل' : 'Edit';

  String get skip => isArabic ? 'تخطي' : 'Skip';

  String get next => isArabic ? 'التالي' : 'Next';

  String get getStarted => isArabic ? 'ابدأ الآن 🚀' : 'Get Started 🚀';

  String get onboardingTitle1 =>
      isArabic ? 'ازرع عاداتك كحديقة رقمية 🌱' : 'Grow Habits Like a Garden 🌱';

  String get onboardingDesc1 => isArabic
      ? 'حوّل عاداتك اليومية لنباتات حية تنمو وتزدهر مع كل يوم تلتزم فيه بالاستمرارية.'
      : 'Transform your daily habits into virtual plants that grow and thrive every day you stay consistent.';

  String get onboardingTitle2 => isArabic
      ? 'حافظ على سلسلتك وتذكيراتك 🔥'
      : 'Build Streaks & Stay Consistent 🔥';

  String get onboardingDesc2 => isArabic
      ? 'تلقَّ تذكيرات ذكية في مواعيدك، واحفظ سلسلتك متواصلة دون انقطاع لتطوير نفسك.'
      : 'Receive smart timely reminders, protect your daily streaks, and celebrate every habit milestone.';

  String get onboardingTitle3 =>
      isArabic ? 'حديقتك بأسلوبك الخاص ☀️🌙' : 'Personalize Your Garden ☀️🌙';

  String get onboardingDesc3 => isArabic
      ? 'استمتع بالتحويل بين خلفيات النهار والليل ودعم كامل للنمط الداكن والمضيء.'
      : 'Switch between morning and night garden themes with seamless light and dark mode support.';

  // ============================================================
  // ACHIEVEMENTS / BADGES (20 BADGES)
  // ============================================================

  String get achievementsTitle => isArabic ? 'أوسمة الحديقة' : 'Garden Badges';

  String get achievementsSubtitle => isArabic
      ? 'استمر في التزامك لاكتساب جميع أوسمة الحديقة'
      : 'Keep your momentum to unlock all garden badges';

  String badgesUnlockedCount(int unlocked, int total) => isArabic
      ? '$unlocked من أصل $total مكتسبة 🏆'
      : '$unlocked of $total Unlocked 🏆';

  // 1
  String get badgeFirstHabit => isArabic ? 'أول بذرة ☘️' : 'First Seed ☘️';
  String get badgeFirstHabitDesc =>
      isArabic ? 'إنشاء أول عادة لك بحديقتك.' : 'Created your first habit.';

  // 2
  String get badgeFirstSprout =>
      isArabic ? 'البرعم الأول 🥇' : 'First Sprout 🥇';
  String get badgeFirstSproutDesc =>
      isArabic ? 'إكمال أول عادة لك بنجاح.' : 'Completed your first habit.';

  // 3
  String get badgePerfectDay => isArabic ? 'يوم المثالية ⭐' : 'Perfect Day ⭐';
  String get badgePerfectDayDesc => isArabic
      ? 'إكمال جميع عاداتك اليومية بالكامل اليوم.'
      : 'Completed all your habits today.';

  // 4
  String get badgeEarlyBird => isArabic ? 'الطائر المبكر 🌅' : 'Early Bird 🌅';
  String get badgeEarlyBirdDesc => isArabic
      ? 'إكمال عادة قبل الساعة 9 صباحاً.'
      : 'Completed a habit before 9:00 AM.';

  // 5
  String get badgeNightOwl => isArabic ? 'بومة الليل 🌙' : 'Night Owl 🌙';
  String get badgeNightOwlDesc => isArabic
      ? 'إكمال عادة بعد الساعة 9 مساءً.'
      : 'Completed a habit after 9:00 PM.';

  // 6
  String get badge3DaySpark => isArabic ? 'شرارة البداية 🔥' : '3-Day Spark 🔥';
  String get badge3DaySparkDesc => isArabic
      ? 'الحفاظ على عادة لـ 3 أيام متواصلة.'
      : 'Achieved a 3-day habit streak.';

  // 7
  String get badgeStreakMaster =>
      isArabic ? 'خبير السلسلة ⚡' : 'Streak Master ⚡';
  String get badgeStreakMasterDesc => isArabic
      ? 'الحفاظ على عادة لمدة 7 أيام متواصلة.'
      : 'Maintained a 7-day habit streak.';

  // 8
  String get badge2WeekWarrior =>
      isArabic ? 'محارب الأسبوعين 🏅' : '2-Week Warrior 🏅';
  String get badge2WeekWarriorDesc => isArabic
      ? 'الحفاظ على عادة لمدة 14 يوماً متواصلة.'
      : 'Maintained a 14-day habit streak.';

  // 9
  String get badgeMultiTasker =>
      isArabic ? 'بستاني نشط 🌿' : 'Active Gardener 🌿';
  String get badgeMultiTaskerDesc => isArabic
      ? 'إدارة 3 عادات أو أكثر بحديقتك.'
      : 'Active in 3 or more habits.';

  // 10
  String get badgeReminderSet =>
      isArabic ? 'المنبه الذكي 🔔' : 'Smart Reminder 🔔';
  String get badgeReminderSetDesc => isArabic
      ? 'تفعيل التذكيرات اليومية لأحد عاداتك.'
      : 'Set a daily reminder for a habit.';

  // 11
  String get badgeWeeklyHero =>
      isArabic ? 'بطل الأسبوع 🗓️' : 'Weekly Hero 🗓️';
  String get badgeWeeklyHeroDesc => isArabic
      ? 'التزام بالعادة كل يوم في الأسبوع الماضي.'
      : 'Completed habits every day this week.';

  // 12
  String get badgeCollector =>
      isArabic ? 'جامع العادات 💎' : 'Habit Collector 💎';
  String get badgeCollectorDesc => isArabic
      ? 'إدارة 5 عادات أو أكثر بحديقتك.'
      : 'Active in 5 or more habits.';

  // 13
  String get badgeFirstBloom => isArabic ? 'أول زهرة 🌸' : 'First Bloom 🌸';
  String get badgeFirstBloomDesc => isArabic
      ? 'تنمية نبتة لمرحلة الازدهار.'
      : 'Grown a plant to Blooming stage.';

  // 14
  String get badgeThrivingGarden =>
      isArabic ? 'الحديقة المزدهرة 🌳' : 'Thriving Garden 🌳';
  String get badgeThrivingGardenDesc => isArabic
      ? 'تنمية 3 نباتات لمرحلة متقدمة.'
      : 'Grown 3 plants to advanced stage.';

  // 15
  String get badgeUnstoppable =>
      isArabic ? 'البطل الخارق 🚀' : 'Unstoppable 🚀';
  String get badgeUnstoppableDesc => isArabic
      ? 'الوصول لسلسلة 30 يوماً متواصلة.'
      : 'Achieved a 30-day habit streak.';

  // 16
  String get badgeCentury => isArabic ? 'مئوية العادات 💯' : 'Habit Century 💯';
  String get badgeCenturyDesc => isArabic
      ? 'إكمال 100 إنجاز عادة إجمالاً في السجل.'
      : 'Completed 100 total habit check-ins.';

  // 17
  String get badge60DayTitan =>
      isArabic ? 'عملاق الـ 60 يوماً 👑' : '60-Day Titan 👑';
  String get badge60DayTitanDesc => isArabic
      ? 'الوصول لسلسلة 60 يوماً متواصلة.'
      : 'Achieved a 60-day habit streak.';

  // 18
  String get badgeMasterGardener =>
      isArabic ? 'كبير البستانيين 🌟' : '100-Day Master 🌟';
  String get badgeMasterGardenerDesc => isArabic
      ? 'الوصول لسلسلة 100 يوم متواصلة.'
      : 'Achieved a 100-day habit streak.';

  // 19
  String get badgeLegend => isArabic ? 'أسطورة العادات 🔮' : 'Habit Legend 🔮';
  String get badgeLegendDesc => isArabic
      ? 'إكمال 500 إنجاز عادة إجمالاً في السجل.'
      : 'Completed 500 total habit check-ins.';

  // 20
  String get badgeForestCreator =>
      isArabic ? 'صانع الغابة 🪴' : 'Forest Creator 🪴';
  String get badgeForestCreatorDesc => isArabic
      ? 'تنمية 5 نباتات لمرحلة اكتمال النمو.'
      : 'Grown 5 plants to Fully Grown stage.';

  String get unlocked => isArabic ? 'مكتسب 🏆' : 'Unlocked 🏆';

  String get locked => isArabic ? 'مغلق 🔒' : 'Locked 🔒';

  // ============================================================
  // NAVIGATION
  // ============================================================

  String get home => isArabic ? 'الرئيسية' : 'Home';

  String get habits => isArabic ? 'العادات' : 'Habits';

  String get garden => isArabic ? 'الحديقة' : 'Garden';

  String get progress => isArabic ? 'التقدم' : 'Progress';

  String get profile => isArabic ? 'حسابي' : 'Profile';

  String get filterAll => isArabic ? 'الكل' : 'All';

  String get filterPending => isArabic ? 'المتبقية' : 'Pending';

  String get filterCompleted => isArabic ? 'المكتملة' : 'Completed';

  String get motivationalTip => isArabic
      ? 'الخطوات اليومية المستمرة تبني نتائج عظيمة 🌱'
      : 'Small daily actions build great results 🌱';

  // ============================================================
  // APP
  // ============================================================

  String get appName => 'Digital Habit Garden';

  String get appTagline => isArabic
      ? 'ازرع عاداتك، وطوّر نفسك.'
      : 'Grow your habits, grow yourself.';

  // ============================================================
  // HOME
  // ============================================================

  String get goodMorning => isArabic ? 'صباح الخير' : 'Good Morning';

  String get goodAfternoon => isArabic ? 'مساء الخير' : 'Good Afternoon';

  String get goodEvening => isArabic ? 'مساء الخير' : 'Good Evening';

  String get homeSubtitle => isArabic
      ? 'الخطوات الصغيرة اليوم تصنع حديقة أقوى غدًا.'
      : 'Small steps today create a stronger garden tomorrow.';

  String get todaysProgress => isArabic ? 'تقدم اليوم' : "Today's Progress";

  String get startFirstHabitToday =>
      isArabic ? 'ابدأ أول عادة لك اليوم.' : 'Start your first habit today.';

  String get allHabitsCompleted =>
      isArabic ? 'لقد أكملت كل عادات اليوم!' : 'All habits completed today!';

  String get keepGoing => isArabic
      ? 'استمر، أنت تقوم بعمل رائع.'
      : "Keep going, you're doing great.";

  String habitsCompleted(int completed, int total) => isArabic
      ? '$completed من $total عادة مكتملة'
      : '$completed of $total habits completed';

  String get todaysHabits => isArabic ? 'عادات اليوم' : "Today's Habits";

  String get takeCare => isArabic
      ? 'اعتنِ بنباتاتك من خلال إكمال عاداتك.'
      : 'Take care of your plants by completing your habits.';

  String get add => isArabic ? 'إضافة' : 'Add';

  String get keepGrowing => isArabic ? 'استمر في النمو' : 'Keep growing';

  String get completedHabitHelps => isArabic
      ? 'كل عادة مكتملة تساعد حديقتك على النمو.'
      : 'Every completed habit helps your garden grow.';

  String get yourGardenWaiting =>
      isArabic ? 'حديقتك في انتظارك' : 'Your garden is waiting';

  String get createFirstHabit => isArabic
      ? 'أنشئ أول عادة وابدأ في تنمية حديقتك الرقمية.'
      : 'Create your first habit and start growing your digital garden.';

  String get createYourFirstHabit =>
      isArabic ? 'أنشئ أول عادة لك' : 'Create Your First Habit';

  String streak(int days) => isArabic ? 'سلسلة $days يوم' : '$days day streak';

  // ============================================================
  // HABITS
  // ============================================================

  String get myHabits => isArabic ? 'عاداتي' : 'My Habits';

  String get noHabits => isArabic
      ? 'لا توجد عادات حتى الآن 🌱\nأنشئ أول عادة لك!'
      : 'No habits yet 🌱\nCreate your first habit!';

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

  String get gardenEmptyDescription => isArabic
      ? 'أكمل عاداتك لزراعة حديقتك الصغيرة الأولى.'
      : 'Complete habits to plant your first little garden.';

  String get yourGarden => isArabic ? 'حديقتك' : 'Your Garden';

  String get gardenGrowDescription => isArabic
      ? 'كل عادة تكملها تساعد حديقتك على النمو.'
      : 'Every habit you complete helps your garden grow.';

  String plantsGrowing(int count) =>
      isArabic ? '$count نباتات نامية' : '$count plants growing';

  String get yourPlants => isArabic ? 'نباتاتك' : 'Your Plants';

  String growingCount(int count) =>
      isArabic ? '$count نامية' : '$count growing';

  String stageStreak(String stage, int streak) =>
      isArabic ? '$stage • سلسلة $streak يوم' : '$stage • $streak day streak';

  String get gardenStyle => isArabic ? 'نمط الحديقة' : 'Garden Style';

  String get chooseGardenAtmosphere =>
      isArabic ? 'اختر أجواء حديقتك.' : 'Choose the atmosphere of your garden.';

  String get classicGarden =>
      isArabic ? 'الحديقة الكلاسيكية' : 'Classic Garden';

  String get freshGreenGarden =>
      isArabic ? 'حديقة خضراء منعشة' : 'Fresh green garden';

  String get nightGarden => isArabic ? 'الحديقة الليلية' : 'Night Garden';

  String get calmGardenAtNight =>
      isArabic ? 'حديقة هادئة في الليل' : 'A calm garden at night';

  String get desertGarden => isArabic ? 'الحديقة الصحراوية' : 'Desert Garden';

  String get warmSandyLandscape =>
      isArabic ? 'منظر رملي دافئ' : 'Warm sandy landscape';

  String get couldNotCreateGardenImage =>
      isArabic ? 'تعذر إنشاء صورة الحديقة.' : 'Could not create garden image.';

  // ============================================================
  // PROGRESS
  // ============================================================

  String get myProgress => isArabic ? 'تقدمي' : 'My Progress';

  String get yourProgress => isArabic ? 'تقدمك 🌱' : 'Your Progress 🌱';

  String get progressSubtitle => isArabic
      ? 'شاهد كيف تنمو عاداتك مع مرور الوقت.'
      : 'See how your habits are growing over time.';

  String get bestStreak => isArabic ? 'أفضل سلسلة' : 'Best Streak';

  String bestStreakDays(int days) => isArabic ? '$days يوم' : '$days days';

  String get completed => isArabic ? 'مكتمل' : 'Completed';

  String get weeklyActivity => isArabic ? 'النشاط الأسبوعي' : 'Weekly Activity';

  String get thisWeek => isArabic ? 'هذا الأسبوع' : 'This Week';

  String weeklyCheckins(int count) =>
      isArabic ? '$count عمليات إكمال' : '$count completed check-ins';

  String get bestDay => isArabic ? 'أفضل يوم' : 'Best day';

  String bestDayValue(String day, int count) =>
      isArabic ? '$day • $count مكتملة' : '$day • $count completed';

  String get habitPerformance =>
      isArabic ? 'أداء العادات' : 'Habit Performance';

  String get noProgressYet => isArabic ? 'لا يوجد تقدم بعد' : 'No progress yet';

  String get startBuildingProgress => isArabic
      ? 'أنشئ أول عادة وابدأ في بناء تقدمك.'
      : 'Create your first habit and start building your progress.';

  String get last7Days => isArabic ? 'آخر 7 أيام' : 'Last 7 days';

  String percent(int value) => '$value%';

  // ============================================================
  // HABIT DETAILS
  // ============================================================

  String get habitDetails => isArabic ? 'تفاصيل العادة' : 'Habit Details';

  String get plantGrowth => isArabic ? 'نمو النبات' : 'Plant Growth';

  String get currentStreak => isArabic ? 'السلسلة الحالية' : 'Current Streak';

  String get completedToday => isArabic ? 'مكتمل اليوم' : 'Completed today';

  String get notCompletedYet => isArabic ? 'لم يكتمل بعد' : 'Not completed yet';

  String get streakSafe =>
      isArabic ? 'أحسنت! سلسلتك بأمان.' : 'Great job! Your streak is safe.';

  String get completeToKeepGrowing => isArabic
      ? 'أكمل هذه العادة للاستمرار في النمو.'
      : 'Complete this habit to keep growing.';

  String get activityHistory => isArabic ? 'سجل النشاط' : 'Activity History';

  String get notCompleted => isArabic ? 'غير مكتمل' : 'Not completed';

  String get currentMonth => isArabic ? 'هذا الشهر' : 'This month';

  // ============================================================
  // CREATE / EDIT HABIT
  // ============================================================

  String get createHabit => isArabic ? 'إنشاء عادة' : 'Create Habit';

  String get editHabit => isArabic ? 'تعديل العادة' : 'Edit Habit';

  String get updateYourHabit =>
      isArabic ? 'حدّث تفاصيل عادتك ✏️' : 'Update your habit ✏️';

  String get createNewHabit =>
      isArabic ? 'أنشئ عادة جديدة 🌱' : 'Create a new habit 🌱';

  String get keepDetailsUpdated => isArabic
      ? 'حافظ على تفاصيل عادتك محدثة.'
      : 'Keep your habit details up to date.';

  String get buildHabit => isArabic
      ? 'ابنِ عادة وشاهد حديقتك تنمو.'
      : 'Build a habit and watch your garden grow.';

  String get habitName => isArabic ? 'اسم العادة' : 'Habit Name';

  String get habitNameExample =>
      isArabic ? 'مثال: قراءة 20 دقيقة' : 'e.g. Read 20 Minutes';

  String get pleaseEnterHabitName =>
      isArabic ? 'من فضلك أدخل اسم العادة' : 'Please enter a habit name';

  String get description => isArabic ? 'الوصف' : 'Description';

  String get describeHabit =>
      isArabic ? 'صف عادتك...' : 'Describe your habit...';

  String get chooseYourPlant => isArabic ? 'اختر نباتك' : 'Choose your plant';

  String get newPlantsUnlock => isArabic
      ? 'تُفتح نباتات جديدة مع نمو سلسلتك.'
      : 'New plants unlock as your streak grows.';

  // ============================================================
  // REMINDERS
  // ============================================================

  String get reminder => isArabic ? 'التذكير' : 'Reminder';

  String get dailyReminder => isArabic ? 'تذكير يومي' : 'Daily Reminder';

  String get habitReminder => isArabic ? 'تذكير العادة' : 'Habit reminder';

  String get noReminderSet => isArabic ? 'لم يتم ضبط تذكير' : 'No reminder set';

  String changeReminderTime(String time) =>
      isArabic ? 'تغيير الوقت: $time' : 'Change time: $time';

  String get alwaysAvailable => isArabic ? 'متاح دائمًا' : 'Always available';

  String get couldNotScheduleReminder =>
      isArabic ? 'تعذر جدولة التذكير.' : 'Could not schedule reminder.';

  String couldNotScheduleReminderWithError(String error) => isArabic
      ? 'تعذر جدولة التذكير: $error'
      : 'Could not schedule reminder: $error';

  String couldNotDisableReminderWithError(String error) => isArabic
      ? 'تعذر إيقاف التذكير: $error'
      : 'Could not disable reminder: $error';

  String get saveChanges => isArabic ? 'حفظ التغييرات' : 'Save Changes';

  String reminderAt(String time) =>
      isArabic ? 'كل يوم الساعة $time' : 'Every day at $time';

  String get reminderEnabled => isArabic
      ? 'ستتلقى تذكيرًا كل يوم.'
      : 'You will receive a reminder every day.';

  String get reminderDisabled => isArabic
      ? 'تذكيرات العادات اليومية متوقفة.'
      : 'Daily habit reminders are turned off.';

  String get reminderTime => isArabic ? 'وقت التذكير' : 'Reminder Time';

  String get chooseReminderTime =>
      isArabic ? 'اختر وقت التذكير' : 'Choose when you want to be reminded';

  String get localNotificationsInfo => isArabic
      ? 'يتم جدولة الإشعارات محليًا على جهازك. لا تحتاج إلى اتصال بالإنترنت.'
      : 'Notifications are scheduled locally on your device. No internet connection is required.';

  // ============================================================
  // PLANTS
  // ============================================================

  String plantName(String name) {
    if (!isArabic) {
      return name;
    }

    switch (name) {
      case 'Flower':
        return 'زهرة';

      case 'Sunflower':
        return 'دوار الشمس';

      case 'Tree':
        return 'شجرة';

      case 'Cactus':
        return 'صبار';

      default:
        return name;
    }
  }

  String stageName(String name) {
    if (!isArabic) {
      return name;
    }

    switch (name) {
      case 'Seed':
        return 'بذرة';

      case 'Sprout':
        return 'برعم';

      case 'Young Plant':
        return 'نبتة صغيرة';

      case 'Growing':
        return 'نامٍ';

      case 'Strong Plant':
        return 'نبات قوي';

      case 'Mature':
        return 'مكتمل';

      case 'Blooming':
        return 'مزهر';

      case 'Fully Grown':
        return 'مكتمل النمو';

      case 'Mature Plant':
        return 'نبات مكتمل';

      default:
        return name;
    }
  }

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

  String get changeName => isArabic ? 'تغيير الاسم' : 'Change Name';

  String get updateDisplayName =>
      isArabic ? 'تحديث اسم العرض' : 'Update your display name';

  String get changePhoto => isArabic ? 'تغيير الصورة' : 'Change Photo';

  String get chooseProfilePicture =>
      isArabic ? 'اختر صورة شخصية جديدة' : 'Choose a new profile picture';

  String get habitsCount => isArabic ? 'العادات' : 'Habits';

  String get today => isArabic ? 'اليوم' : 'Today';

  String get totalCompleted =>
      isArabic ? 'إجمالي الإنجازات' : 'Total completed';

  String get growingPlants => isArabic ? 'النباتات النامية' : 'Growing plants';

  String get overview => isArabic ? 'نظرة عامة' : 'Overview';

  String get preferences => isArabic ? 'التفضيلات' : 'Preferences';

  String get notifications => isArabic ? 'الإشعارات' : 'Notifications';

  String get dailyHabitReminders =>
      isArabic ? 'تذكيرات العادات اليومية' : 'Daily habit reminders';

  String get settings => isArabic ? 'الإعدادات' : 'Settings';

  String get appPreferences =>
      isArabic ? 'إدارة تفضيلات التطبيق' : 'Manage app preferences';

  String get appearance => isArabic ? 'المظهر' : 'Appearance';

  String get language => isArabic ? 'اللغة' : 'Language';

  String get light => isArabic ? 'فاتح' : 'Light';

  String get dark => isArabic ? 'داكن' : 'Dark';

  String get system => isArabic ? 'تلقائي' : 'System';

  String get english => 'English';

  String get arabic => 'العربية';

  String get yourName => isArabic ? 'اسمك' : 'Your name';

  String get enterYourName => isArabic ? 'أدخل اسمك' : 'Enter your name';

  String get pleaseEnterName =>
      isArabic ? 'من فضلك أدخل اسمك.' : 'Please enter your name.';

  String get couldNotSelectImage =>
      isArabic ? 'تعذر اختيار الصورة.' : 'Could not select the image.';

  // ============================================================
  // NOTIFICATION SETTINGS
  // ============================================================

  String get notificationsTitle => isArabic ? 'الإشعارات' : 'Notifications';

  String get stayOnTrack => isArabic ? 'حافظ على تقدمك 🌱' : 'Stay on track 🌱';

  String get notificationDescription => isArabic
      ? 'احصل على تذكير لطيف كل يوم لإكمال عاداتك والحفاظ على نمو حديقتك.'
      : 'Get a gentle reminder every day to complete your habits and keep your garden growing.';

  // ============================================================
  // DATE / TIME
  // ============================================================

  String dayName(int weekday) {
    const en = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    const ar = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];

    if (weekday < 1 || weekday > 7) {
      return '';
    }

    return (isArabic ? ar : en)[weekday - 1];
  }

  String monthName(int month) {
    const en = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    const ar = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    if (month < 1 || month > 12) {
      return '';
    }

    return (isArabic ? ar : en)[month - 1];
  }
}

// ============================================================================
// APP STRINGS SCOPE
// ============================================================================

class AppStringsScope extends InheritedWidget {
  final AppStrings strings;

  const AppStringsScope({
    super.key,
    required this.strings,
    required super.child,
  });

  static AppStrings of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<AppStringsScope>()
            ?.strings ??
        const AppStrings(Locale('en'));
  }

  @override
  bool updateShouldNotify(AppStringsScope oldWidget) {
    return strings.locale != oldWidget.strings.locale;
  }
}
