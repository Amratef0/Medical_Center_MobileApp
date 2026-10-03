# MCSOS Mobile (Flutter)

موبايل ابليكيشن فلاتر لنظام MCSOS، بيستخدم نفس الـ APIs بتاعة الباك اند (NestJS)
اللي الويب سايت (React) شغالة عليه، ونفس فكرة الستايل (dark theme + أزرق + Cairo font).

State management: **Cubit** بس (من `flutter_bloc`)، مفيش Bloc events خالص.

---

## 1) الأول: جهّز بيئتك (مرة واحدة بس)

انت عندك Flutter 3.47.2 و Android SDK 36 و JDK 25 مركبين فعلا، فمش محتاج تغيّر
أي فيرشن. الخطوات دي بس عشان تولّد فولدرات android/ios اللي مش موجودة في السورس كود
(لأنها اتبنت من غير Flutter SDK فعليا على جهازي، فمبعتهالكش).

```bash
# 1. فك الضغط عن الزip وادخل الفولدر
cd mcsos_mobile

# 2. نزّل كل الـ packages بتاعة pubspec.yaml
flutter pub get

# 3. مهم جدا: ولّد فولدرات android/ios (مش موجودة في الزip)
#    الأمر ده بياخد pubspec.yaml و lib/ الموجودين ويضيف بس البلاتفورم فولدرز،
#    مش هيمسح أو يعدل أي كود موجود.
flutter create . --platforms=android --org com.mcsos

# 4. اتأكد إن كل حاجة تمام
flutter doctor -v
```

### لو ظهرت مشكلة "Android license status"
```bash
flutter doctor --android-licenses
```
واضغط `y` على كل حاجة، أو من Android Studio: Settings > Languages & Frameworks > Android SDK > SDK Tools > وافق على الـ licenses من هناك.

### لو حصلت مشكلة Gradle / AGP / Kotlin / Java 25 بعد `flutter create`
الأمر `flutter create` بيولّد ملفات Gradle متوافقة مع فيرشن الفلاتر بتاعك (3.47.2) تلقائيا،
فمن المفروض تكون متوافقة مع JDK 25 من غير أي تعديل. لو لسه حصلت مشكلة:

```bash
flutter clean
flutter pub get
cd android
./gradlew --version   # شوف الـ Gradle/AGP/JVM بيقرا JDK ايه
cd ..
flutter run -v
```

لو قالك JDK غير متوافق مع AGP، ممكن تحدد جافا تحديدا للـ Gradle في
`android/gradle.properties`:
```properties
org.gradle.java.home=C:/Program Files/Java/jdk-25
```
(غيّر المسار على حسب فين الـ JDK متركب عندك بالظبط).

---

## 1.5) إعدادات Android اللي اتأكد إنها شغالة عندك (JDK 21 + Gradle 8.14.5)

جربت وشغال بالظبط على **Pixel 9 Pro emulator**. المشكلة كانت إن `flutter create` بيولّد
مشروع Gradle مش متوافق مع JDK 25، فالحل اللي شغال:

**1. خلّي Flutter يستخدم JDK 21 بدل 25** (لازم يكون عندك JDK 21 مركب، عندك أصلا في
`C:\Program Files\Eclipse Adoptium`):
```powershell
Get-ChildItem "C:\Program Files\Eclipse Adoptium" -Directory
flutter config --jdk-dir="C:\Program Files\Eclipse Adoptium\jdk-21.0.12.101-hotspot"
```

**2. في `android/gradle/wrapper/gradle-wrapper.properties`** غيّر السطر بتاع
`distributionUrl` لـ:
```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.14.5-bin.zip
```

**3. في `android/build.gradle.kts`** (اللي في روت فولدر android، مش اللي جوه app/)
غيّر الـ plugins block لـ:
```kotlin
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // NOTE: مثبتة على AGP 8.11.x / Kotlin 2.2.x قصدا.
    // AGP 9.x ("built-in Kotlin") هي اللي flutter create بيحطها افتراضيا في Flutter 3.47،
    // بس شوية plugins (زي file_picker) لسه بتقفل تحتها، وAGP 9 متأكد منها لحد JDK 17/21 بس، مش 25.
    // 8.11.x كومبو مجرّب وشغال كويس مع JDK 17/21.
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
}
```

**4. في `android/app/build.gradle.kts`** حدّث الـ `buildTypes`:
```kotlin
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("debug")
        isMinifyEnabled = true
        isShrinkResources = true
    }
}
```

بعد أي تعديل من دول اعمل:
```bash
flutter clean
flutter pub get
flutter run
```

> ملحوظة: لو عملت `flutter clean` أو حذفت فولدر `android/` وعملت `flutter create .` تاني،
> الإعدادات دي هترجع للـ defaults بتاعة Flutter وهتحتاج تكررها تاني من الخطوات فوق.

---

## 2) اربط الابليكيشن بالباك اند بتاعك

كل حاجة في مكان واحد: **`lib/core/constants/app_constants.dart`**

```dart
static const String baseUrl = 'http://10.0.2.2:3000/api/v1';
```

- شغال على **محاكي أندرويد (Android Emulator)** والباك اند شغال على نفس الكمبيوتر؟
  سيب `10.0.2.2` زي ما هي (دي بوابة خاصة بالمحاكي بس تودي على localhost بتاع الكمبيوتر)،
  وغيّر البورت `3000` لو الباك اند شغال على بورت تاني.
- شغال على **موبايل حقيقي** على نفس شبكة الواي فاي؟
  غيّرها لـ IP الكمبيوتر بتاعك، مثلا: `http://192.168.1.5:3000/api/v1`
  (تقدر تعرف الـ IP من `ipconfig` على ويندوز).
- الباك اند فيه CORS يسمح بالدومين ده؟ اتأكد إن `main.ts` عامل `app.enableCors()`
  ولو مقفول على دومين معيّن ضيف رابط الموبايل لو لازم.

بعد كل تعديل في الرابط، لازم `flutter run` تاني (hot reload لوحده مش هيكفي لتغييرات الكود ده أحيانا، فاعمل `r` أو أعد التشغيل لو مفيش استجابة).

---

## 3) شغّل الابليكيشن

```bash
flutter run
```
لو عندك أكتر من جهاز/محاكي متاح:
```bash
flutter devices
flutter run -d <device_id>
```

---

## 4) هيكل المشروع

```
lib/
  core/
    constants/app_constants.dart     -> رابط الباك اند + مفاتيح التخزين
    network/api_client.dart          -> Dio + إضافة التوكن + refresh تلقائي
    network/api_error.dart           -> تحويل أخطاء السيرفر لرسالة عربية
    network/list_response_parser.dart-> استخراج القائمة من الـ response (array أو {data,...})
    storage/token_storage.dart       -> حفظ التوكنز محليا (SharedPreferences)
    theme/                           -> ألوان وثيم الابليكيشن (نفس ستايل الموقع)
    utils/                           -> تنسيق تواريخ، ترجمة الـ enums، دايلوجات جاهزة
    widgets/                         -> ودجتس مشتركة (Loading/Error/Empty/Badge/Drawer...)
  models/        -> كلاس بسيط لكل entity (فيه fromJson بس)
  repositories/  -> كل ريبوزيتوري بيتكلم مع endpoint معين في الباك اند (Dio calls)
  cubits/        -> كل Cubit بيدير حالة شاشة أو مجموعة شاشات معينة
  screens/       -> الشاشات نفسها، مقسمة على فولدر لكل موديول
  routes/app_routes.dart -> كل أسماء الشاشات وإزاي تتفتح
  main.dart      -> نقطة البداية
```

### إزاي تضيف موديول جديد (لو عايز تزود حاجة)
اتبع نفس الباترن اللي موجود في أي موديول تاني، بالترتيب ده:
1. **Model**: `lib/models/xxx_model.dart` - كلاس فيه الحقول + `fromJson`.
2. **Repository**: `lib/repositories/xxx_repository.dart` - فيه دوال بتنادي `ApiClient().dio`.
3. **Cubit**: `lib/cubits/xxx_cubit.dart` - State class فيها status/data/error + Cubit بيستخدم الريبوزيتوري.
4. **Screen**: `lib/screens/xxx/xxx_list_screen.dart` - بتستخدم `BlocProvider` + `BlocBuilder`.
5. **Route**: ضيف السطر في `lib/routes/app_routes.dart`.
6. **Drawer**: ضيف تاب جديد في `lib/core/widgets/main_drawer.dart`.

---

## 5) الموديولز الموجودة دلوقتي

| الموديول | شاشة List | إضافة | تعديل | حذف | ملاحظات |
|---|---|---|---|---|---|
| المرضى (Patients) | ✅ | ✅ | ✅ | ✅ | فيها تفاصيل كاملة + جلسات/خطط علاج/باقات/تاريخ طبي/مستندات طبية |
| الأطباء (Doctors) | ✅ | ✅ | ✅ | ✅ | + شاشة مواعيد عمل الدكتور (Availability) |
| الجلسات (Sessions) | ✅ فيها فلترة بالحالة | ✅ | ✅ تحديث الحالة (حضر/غاب/إلغاء) بالضغط على الجلسة | ✅ | |
| الجدولة (Scheduling/Slots) | ✅ | ✅ | ✅ حجز/إلغاء حجز مباشرة | ✅ | |
| خطط العلاج (Treatment Plans) | ✅ | ✅ (bottom sheet) | - | ✅ | |
| الباقات (Packages) | ✅ | ✅ (bottom sheet) | - | ✅ | ✅ تخصيص باقة لمريض من واجهة الباقات مباشرة |
| المالية (Finance) | ✅ (تابين: مدفوعات/فواتير) | ✅ دفعة | تمييز فاتورة "مدفوعة" | - | |
| المتابعات (Follow-ups) | ✅ | - (تتضاف من نظام تلقائي في الباك اند غالبا) | تغيير الحالة | ✅ | |
| قائمة الانتظار (Waitlist) | ✅ | ✅ | - | ✅ | |
| المستخدمون (Users) | ✅ | ✅ | - | ✅ | للأدمن بس |
| التقارير (Reporting) | ✅ تقرير اليوم | - | - | - | |
| الملف الشخصي (Profile) | ✅ | - | - | تسجيل خروج | |
| المستندات الطبية / التاريخ الطبي | ✅ جوه شاشة تفاصيل المريض | ✅ | ✅ (التاريخ الطبي بس، المستندات إضافة/حذف بس) | ✅ | |

### حاجات لسه مش موجودة (اختيارية)
- **Light mode** (الابليكيشن Dark theme بس)
- `flutter test` هيشتغل تمام دلوقتي (اتصلح `test/widget_test.dart` ليستخدم `McsosApp` بدل `MyApp` الافتراضي)

---

## 6) ملاحظات مهمة قبل ما تجرب

- كل أسماء الـ endpoints والحقول (زي `first_name`, `session_date`, ...) طلعتها بنفسي
  من كود الباك اند بتاعك (entities + controllers)، يعني المفروض تبقى متطابقة تماما.
  لو أي endpoint اتغيّر في الباك اند بعد كده، غيّره في ملف الـ Repository بتاعه بس
  (كل موديول له ريبوزيتوري لوحده، الملفات صغيرة وسهلة).
- شكل الـ pagination مختلف شوية بين موديول وموديول في الباك اند بتاعك (بعضها بيرجع
  `{ data, total, page, limit }` وبعضها array عادي)، فعملت دالة `extractListData()`
  بتتعامل مع الحالتين تلقائيا.
- الابليكيشن كله Dark theme بس (زي أغلب الداشبوردز)، مفيش وضع نهاري (Light mode) -
  لو عايزه سهل تضيفه بس هيحتاج شغل إضافي على الـ theme.
- تسجيل الدخول بيحفظ التوكنز في `SharedPreferences`، ولو التوكن انتهى بيحاول يعمل
  refresh تلقائي زي بالظبط اللي بيحصل في الفرونت إند بتاعك (axios interceptor).

---

## 7) لو حصلت مشكلة في الاتصال بالـ API
- تأكد إن الباك اند شغال (`npm run start:dev` في فولدر `mcsos-backend`).
- تأكد إن `baseUrl` في `app_constants.dart` صحيح (شوف قسم 2 فوق).
- شغّل الطلب بنفسك من Postman/Insomnia بنفس الرابط عشان تتأكد إن الباك اند بيرد.
- شوف الـ logs في نفس الترمينال اللي شغال فيه `flutter run` هتلاقي رسالة الخطأ
  بالتفصيل (Dio بيطبع الطلب اللي فشل).
