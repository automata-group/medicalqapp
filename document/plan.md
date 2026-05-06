# خطة تطوير متكاملة لتطبيق Medical Question Bank

## 📱 **المرحلة الأولى: تطبيق المستخدم (User Mobile App)**

---

## **Module 1: Authentication & Onboarding**

### **نقاط النهاية (API Endpoints)**

```
POST   /api/v1/auth/register
POST   /api/v1/auth/login
POST   /api/v1/auth/logout
POST   /api/v1/auth/refresh-token
POST   /api/v1/auth/forgot-password
POST   /api/v1/auth/reset-password
POST   /api/v1/auth/verify-email
GET    /api/v1/auth/me
PUT    /api/v1/auth/profile
```

### **الشاشات المطلوبة**
1. **Splash Screen** - عرض لوجو التطبيق
2. **Welcome Screen** - مقدمة سريعة عن التطبيق
3. **Sign Up Screen**
   - البريد الإلكتروني
   - كلمة المرور
   - الاسم الكامل
   - رقم الهاتف (اختياري)
4. **Sign In Screen**
5. **Forgot Password Screen**
6. **Email Verification Screen**

---

## **Module 2: Specialty Selection & Profile Setup**

### **نقاط النهاية**

```
GET    /api/v1/specialties
GET    /api/v1/specialties/{id}
POST   /api/v1/user/specialties
GET    /api/v1/user/specialties
DELETE /api/v1/user/specialties/{id}
PUT    /api/v1/user/study-settings
GET    /api/v1/user/study-settings
```

### **الشاشات المطلوبة**
1. **Specialty Selection Screen**
   - عرض جميع التخصصات الطبية
   - اختيار متعدد
   - أيقونات مميزة لكل تخصص
2. **Study Plan Setup Screen**
   - تحديد تاريخ الاختبار
   - تحديد ساعات المذاكرة اليومية
   - تفعيل/تعطيل الإشعارات

---

## **Module 3: Home Dashboard**

### **نقاط النهاية**

```
GET    /api/v1/dashboard/overview
GET    /api/v1/dashboard/progress
GET    /api/v1/dashboard/stats/daily
GET    /api/v1/dashboard/stats/weekly
GET    /api/v1/dashboard/weak-areas
GET    /api/v1/dashboard/recent-activity
```

### **الشاشات المطلوبة**
1. **Home Dashboard Screen**
   - ملخص التقدم العام
   - نسبة إنجاز كل تخصص
   - عداد الأيام المتبقية للاختبار
   - إحصائيات سريعة (أسئلة محلولة، نسبة الصحيح)
   - زر بدء المذاكرة
   - زر بدء اختبار محاكي
   - شارات الإنجازات الأخيرة

---

## **Module 4: Question Practice Mode**

### **نقاط النهاية**

```
GET    /api/v1/questions/practice/next
POST   /api/v1/questions/{id}/answer
GET    /api/v1/questions/{id}/explanation
POST   /api/v1/questions/{id}/bookmark
DELETE /api/v1/questions/{id}/bookmark
GET    /api/v1/questions/bookmarked
POST   /api/v1/questions/{id}/report
GET    /api/v1/questions/practice/filters
```

### **الشاشات المطلوبة**
1. **Practice Settings Screen**
   - اختيار التخصص
   - اختيار عدد الأسئلة
   - فلتر (أسئلة جديدة، أسئلة مخطئة، عشوائي)
2. **Question Display Screen**
   - نص السؤال
   - صورة (إن وجدت)
   - 4 خيارات (A, B, C, D)
   - زر Bookmark
   - زر Report
   - عداد الوقت المستغرق
   - شريط تقدم (سؤال X من Y)
3. **Answer Result Screen**
   - عرض الإجابة الصحيحة/الخاطئة
   - الشرح العلمي
   - توضيح سبب خطأ الخيارات الأخرى
   - المراجع
   - زر السؤال التالي
4. **Report Question Screen**
   - نوع الخطأ (علمي، لغوي، إملائي، آخر)
   - حقل الوصف

---

## **Module 5: Mock Exam Mode**

### **نقاط النهاية**

```
POST   /api/v1/mock-exams/start
GET    /api/v1/mock-exams/{id}
GET    /api/v1/mock-exams/{id}/sections/{section_id}
POST   /api/v1/mock-exams/{id}/sections/{section_id}/answer
POST   /api/v1/mock-exams/{id}/sections/{section_id}/complete
POST   /api/v1/mock-exams/{id}/complete
GET    /api/v1/mock-exams/{id}/results
GET    /api/v1/mock-exams/{id}/review
GET    /api/v1/mock-exams/history
```

### **الشاشات المطلوبة**
1. **Mock Exam Instructions Screen**
   - شرح نظام الاختبار
   - التحذيرات
   - زر "ابدأ الاختبار"
2. **Mock Exam Section Screen**
   - Section 1 أو Section 2
   - 210 سؤال لكل قسم
   - مؤقت 2 ساعة
   - عرض السؤال مع الخيارات
   - إمكانية وضع علامة للمراجعة
   - زر "إنهاء القسم"
3. **Section Break Screen**
   - راحة بين القسمين
   - ملخص القسم الأول
4. **Mock Exam Results Screen**
   - النتيجة النهائية (%)
   - عدد الإجابات الصحيحة/الخاطئة
   - الوقت المستغرق
5. **Detailed Analysis Screen**
   - رسم بياني للأداء حسب التخصص
   - متوسط الوقت لكل سؤال
   - أكثر تخصص استهلك وقتًا
   - نقاط الضعف
   - مقارنة مع المتوسط العام (Phase 2)
6. **Review Wrong Answers Screen**
   - عرض الأسئلة الخاطئة فقط
   - الإجابة الصحيحة + الشرح

---

## **Module 6: Progress & Statistics**

### **نقاط النهاية**

```
GET    /api/v1/progress/specialties
GET    /api/v1/progress/specialty/{id}/details
GET    /api/v1/stats/overall
GET    /api/v1/stats/daily-streak
GET    /api/v1/stats/time-analysis
GET    /api/v1/stats/performance-trends
```

### **الشاشات المطلوبة**
1. **Progress Overview Screen**
   - نسبة الإنجاز لكل تخصص
   - رسم دائري/شريطي
   - عدد الأسئلة المتبقية
2. **Specialty Detail Screen**
   - تفاصيل تقدم تخصص واحد
   - الأسئلة المحلولة/المتبقية
   - نسبة الصحيح
   - الوقت المستغرق

---

## **Module 7: Achievements & Streaks**

### **نقاط النهاية**

```
GET    /api/v1/achievements
GET    /api/v1/achievements/{id}
GET    /api/v1/user/achievements
GET    /api/v1/user/streaks
```

### **الشاشات المطلوبة**
1. **Achievements Screen**
   - عرض جميع الشارات
   - الشارات المكتسبة وغير المكتسبة
   - شروط الحصول على كل شارة
2. **Streak Tracker Screen**
   - عدد الأيام المتتالية
   - أطول سلسلة تحققت
   - تحفيز للمحافظة على الالتزام

---

## **Module 8: Bookmarks & Saved Questions**

### **نقاط النهاية**

```
GET    /api/v1/bookmarks
GET    /api/v1/bookmarks/{id}
DELETE /api/v1/bookmarks/{id}
PUT    /api/v1/bookmarks/{id}/notes
```

### **الشاشات المطلوبة**
1. **Bookmarks Screen**
   - قائمة الأسئلة المحفوظة
   - فلتر حسب التخصص
   - ملاحظات شخصية لكل سؤال
   - إمكانية بدء جلسة مذاكرة من المحفوظات

---

## **Module 9: Search & Filters**

### **نقاط النهاية**

```
GET    /api/v1/search/questions
POST   /api/v1/search/advanced
GET    /api/v1/search/history
```

### **الشاشات المطلوبة**
1. **Search Screen**
   - شريط البحث
   - فلاتر متقدمة:
     - حسب التخصص
     - أسئلة مخطئة فقط
     - أسئلة محفوظة فقط
     - كلمات مفتاحية
   - عرض نتائج البحث

---

## **Module 10: Notifications**

### **نقاط النهاية**

```
GET    /api/v1/notifications
GET    /api/v1/notifications/unread-count
PUT    /api/v1/notifications/{id}/read
PUT    /api/v1/notifications/read-all
DELETE /api/v1/notifications/{id}
PUT    /api/v1/notifications/settings
```

### **الشاشات المطلوبة**
1. **Notifications Screen**
   - قائمة الإشعارات
   - مقروءة/غير مقروءة
   - أنواع الإشعارات:
     - تذكير يومي
     - تحديثات محتوى
     - شارات جديدة
     - إشعارات نظامية

---

## **Module 11: Subscription & Payments**

### **نقاط النهاية**

```
GET    /api/v1/subscriptions/plans
GET    /api/v1/user/subscription
POST   /api/v1/subscriptions/subscribe
POST   /api/v1/subscriptions/cancel
POST   /api/v1/subscriptions/renew
POST   /api/v1/payments/process
GET    /api/v1/payments/history
POST   /api/v1/discount-codes/validate
POST   /api/v1/referrals/generate-code
GET    /api/v1/referrals/my-referrals
```

### **الشاشات المطلوبة**
1. **Subscription Plans Screen**
   - عرض الخطط (شهري، 6 أشهر، سنوي)
   - الأسعار والميزات
   - زر الاشتراك
2. **Payment Screen**
   - اختيار طريقة الدفع
   - حقل كود الخصم
   - تأكيد الدفع
3. **Payment Success/Failed Screen**
4. **Subscription Management Screen**
   - تفاصيل الاشتراك الحالي
   - تاريخ الانتهاء
   - إلغاء التجديد التلقائي
5. **Free Trial Screen**
   - عرض 15 سؤال مجاني لكل تخصص
   - تشجيع على الاشتراك
6. **Referral Screen**
   - كود الإحالة الخاص
   - قائمة الإحالات الناجحة
   - المكافآت المكتسبة

---

## **Module 12: Settings & Profile**

### **نقاط النهاية**

```
GET    /api/v1/user/profile
PUT    /api/v1/user/profile
PUT    /api/v1/user/change-password
PUT    /api/v1/user/notification-preferences
DELETE /api/v1/user/account
GET    /api/v1/app/version
```

### **الشاشات المطلوبة**
1. **Profile Screen**
   - الصورة الشخصية
   - الاسم والبريد
   - رقم الهاتف
2. **Settings Screen**
   - تعديل خطة المذاكرة
   - تعديل التخصصات
   - إعدادات الإشعارات
   - تغيير كلمة المرور
   - اللغة (مستقبلاً)
   - عن التطبيق
   - شروط الاستخدام
   - سياسة الخصوصية
   - تسجيل الخروج
   - حذف الحساب

---

## **Module 13: Offline Mode**

### **نقاط النهاية**

```
POST   /api/v1/offline/sync
GET    /api/v1/offline/download-questions
POST   /api/v1/offline/upload-answers
```

### **المتطلبات الفنية**
- تخزين محلي باستخدام SQLite/Realm
- مزامنة تلقائية عند الاتصال بالإنترنت
- إشعار المستخدم بحالة المزامنة

---

---

# 🖥️ **المرحلة الثانية: لوحة تحكم الأدمن (Admin Dashboard)**

---

## **Module 1: Admin Authentication**

### **نقاط النهاية**

```
POST   /api/v1/admin/auth/login
POST   /api/v1/admin/auth/logout
POST   /api/v1/admin/auth/refresh-token
GET    /api/v1/admin/auth/me
```

### **الشاشات المطلوبة**
1. **Admin Login Screen**
2. **Dashboard Home Screen**

---

## **Module 2: Question Management**

### **نقاط النهاية**

```
GET    /api/v1/admin/questions
GET    /api/v1/admin/questions/{id}
POST   /api/v1/admin/questions
PUT    /api/v1/admin/questions/{id}
DELETE /api/v1/admin/questions/{id}
PUT    /api/v1/admin/questions/{id}/reorder
POST   /api/v1/admin/questions/bulk-import
POST   /api/v1/admin/questions/{id}/ai-verify
GET    /api/v1/admin/questions/pending-verification
```

### **الشاشات المطلوبة**
1. **Questions List Screen**
   - جدول شامل بجميع الأسئلة
   - فلاتر (تخصص، حالة، صعوبة)
   - بحث نصي
   - أزرار (إضافة، تعديل، حذف)
   - ترتيب الأسئلة برقم
2. **Add/Edit Question Screen**
   - نص السؤال
   - رفع صورة
   - 4 خيارات + تحديد الصحيح
   - التخصص
   - الصعوبة
   - المصدر
   - الوقت المتوقع
   - مجاني/مدفوع
3. **Bulk Import Screen**
   - رفع ملف Excel/CSV
   - معاينة البيانات
   - تأكيد الاستيراد
4. **AI Verification Screen**
   - طلب تدقيق الذكاء الاصطناعي
   - عرض نتائج التدقيق
   - الموافقة/الرفض

---

## **Module 3: Explanation Management**

### **نقاط النهاية**

```
GET    /api/v1/admin/explanations/{question_id}
POST   /api/v1/admin/explanations
PUT    /api/v1/admin/explanations/{id}
POST   /api/v1/admin/explanations/ai-generate
```

### **الشاشات المطلوبة**
1. **Explanation Editor Screen**
   - شرح الإجابة الصحيحة
   - شرح سبب خطأ الخيارات الأخرى
   - المراجع
   - زر "توليد بالذكاء الاصطناعي"
   - معاينة

---

## **Module 4: Specialty Management**

### **نقاط النهاية**

```
GET    /api/v1/admin/specialties
GET    /api/v1/admin/specialties/{id}
POST   /api/v1/admin/specialties
PUT    /api/v1/admin/specialties/{id}
DELETE /api/v1/admin/specialties/{id}
PUT    /api/v1/admin/specialties/reorder
```

### **الشاشات المطلوبة**
1. **Specialties Management Screen**
   - قائمة التخصصات
   - إضافة تخصص جديد
   - تعديل/حذف
   - رفع أيقونة
   - ترتيب العرض
   - تفعيل/تعطيل

---

## **Module 5: Reports Management**

### **نقاط النهاية**

```
GET    /api/v1/admin/reports
GET    /api/v1/admin/reports/{id}
PUT    /api/v1/admin/reports/{id}/status
PUT    /api/v1/admin/reports/{id}/resolve
GET    /api/v1/admin/reports/statistics
```

### **الشاشات المطلوبة**
1. **Reports Dashboard Screen**
   - قائمة البلاغات
   - فلتر (نوع الخطأ، الحالة)
   - عداد البلاغات الجديدة
2. **Report Detail Screen**
   - تفاصيل البلاغ
   - السؤال المرتبط
   - وصف المستخدم
   - حالة المعالجة (pending, under review, resolved, rejected)
   - حقل ملاحظات المشرف
   - زر "حل المشكلة"

---

## **Module 6: User Management**

### **نقاط النهاية**

```
GET    /api/v1/admin/users
GET    /api/v1/admin/users/{id}
PUT    /api/v1/admin/users/{id}
PUT    /api/v1/admin/users/{id}/subscription
PUT    /api/v1/admin/users/{id}/status
GET    /api/v1/admin/users/{id}/activity
GET    /api/v1/admin/users/statistics
```

### **الشاشات المطلوبة**
1. **Users List Screen**
   - جدول المستخدمين
   - فلاتر (نوع الاشتراك، الحالة)
   - بحث
2. **User Detail Screen**
   - المعلومات الشخصية
   - الاشتراك الحالي
   - إحصائيات الأداء
   - سجل الأنشطة
   - تفعيل/تعطيل الحساب

---

## **Module 7: Subscription Plans Management**

### **نقاط النهاية**

```
GET    /api/v1/admin/subscription-plans
GET    /api/v1/admin/subscription-plans/{id}
POST   /api/v1/admin/subscription-plans
PUT    /api/v1/admin/subscription-plans/{id}
DELETE /api/v1/admin/subscription-plans/{id}
```

### **الشاشات المطلوبة**
1. **Subscription Plans Screen**
   - قائمة الخطط
   - إضافة/تعديل خطة
   - السعر والمدة
   - الميزات
   - تفعيل/تعطيل

---

## **Module 8: Discount Codes Management**

### **نقاط النهاية**

```
GET    /api/v1/admin/discount-codes
POST   /api/v1/admin/discount-codes
PUT    /api/v1/admin/discount-codes/{id}
DELETE /api/v1/admin/discount-codes/{id}
GET    /api/v1/admin/discount-codes/{id}/usage
```

### **الشاشات المطلوبة**
1. **Discount Codes Screen**
   - قائمة الأكواد
   - إضافة كود جديد
   - نوع الخصم (نسبة، مبلغ ثابت)
   - الحد الأقصى للاستخدام
   - تاريخ الصلاحية
   - إحصائيات الاستخدام

---

## **Module 9: Payments & Revenue**

### **نقاط النهاية**

```
GET    /api/v1/admin/payments
GET    /api/v1/admin/payments/{id}
GET    /api/v1/admin/payments/statistics
GET    /api/v1/admin/revenue/daily
GET    /api/v1/admin/revenue/monthly
GET    /api/v1/admin/revenue/export
```

### **الشاشات المطلوبة**
1. **Payments Dashboard Screen**
   - سجل المدفوعات
   - فلاتر (الحالة، التاريخ)
   - إحصائيات الإيرادات
   - رسوم بيانية

---

## **Module 10: Content Updates Management**

### **نقاط النهاية**

```
GET    /api/v1/admin/content-updates
POST   /api/v1/admin/content-updates
GET    /api/v1/admin/content-updates/{id}
DELETE /api/v1/admin/content-updates/{id}
POST   /api/v1/admin/content-updates/notify-users
```

### **الشاشات المطلوبة**
1. **Content Updates Screen**
   - سجل التحديثات
   - إضافة تحديث جديد
   - إرسال إشعار للمستخدمين

---

## **Module 11: Notification Management**

### **نقاط النهاية**

```
GET    /api/v1/admin/notification-templates
POST   /api/v1/admin/notification-templates
PUT    /api/v1/admin/notification-templates/{id}
POST   /api/v1/admin/notifications/send
POST   /api/v1/admin/notifications/broadcast
GET    /api/v1/admin/notifications/history
```

### **الشاشات المطلوبة**
1. **Notification Templates Screen**
   - قائمة القوالب
   - إضافة/تعديل قالب
2. **Send Notification Screen**
   - اختيار المستخدمين
   - كتابة الرسالة
   - جدولة الإرسال
   - إرسال فوري

---

## **Module 12: Analytics & Statistics**

### **نقاط النهاية**

```
GET    /api/v1/admin/analytics/overview
GET    /api/v1/admin/analytics/users
GET    /api/v1/admin/analytics/questions
GET    /api/v1/admin/analytics/mock-exams
GET    /api/v1/admin/analytics/performance
GET    /api/v1/admin/analytics/export
```

### **الشاشات المطلوبة**
1. **Analytics Dashboard Screen**
   - عدد المستخدمين النشطين
   - الأسئلة المحلولة
   - الاختبارات المحاكية
   - معدلات النجاح
   - رسوم بيانية تفاعلية

---

## **Module 13: Admin Management**

### **نقاط النهاية**

```
GET    /api/v1/admin/admins
POST   /api/v1/admin/admins
PUT    /api/v1/admin/admins/{id}
DELETE /api/v1/admin/admins/{id}
GET    /api/v1/admin/activity-log
```

### **الشاشات المطلوبة**
1. **Admins Management Screen**
   - قائمة المشرفين
   - إضافة مشرف جديد
   - الأدوار والصلاحيات
   - سجل الأنشطة

---

## **Module 14: Settings & Configuration**

### **نقاط النهاية**

```
GET    /api/v1/admin/settings
PUT    /api/v1/admin/settings
GET    /api/v1/admin/ai-config
PUT    /api/v1/admin/ai-config
```

### **الشاشات المطلوبة**
1. **System Settings Screen**
   - إعدادات عامة
   - إعدادات الذكاء الاصطناعي
   - إعدادات الإشعارات
   - إعدادات الدفع

---

---

# 📊 **ملخص التقنيات والأدوات المقترحة**

## **Backend**
- **Framework**: Node.js + Express.js أو Django + Django REST Framework
- **Database**: MySQL 8.0+ (كما في الـ Schema)
- **ORM**: Sequelize (Node.js) 
- **Authentication**: JWT (JSON Web Tokens)
- **AI Integration**: OpenAI API / Gemini API
- **Payment Gateway**: ميسر (للسوق السعودي)
- **File Storage**: AWS S3 أو Google Cloud Storage
- **Background Jobs**: Bull Queue (Node.js) 

## **Mobile App**
- **Framework**: Flutter (iOS + Android)
- **State Management**: Provider / Riverpod / Bloc
- **Local Database**: SQLite / Hive / Realm
- **Offline Sync**: WorkManager / Background Fetch
- **Push Notifications**: Firebase Cloud Messaging (FCM)

## **Admin Dashboard**
- **Framework**: React.js + Material-UI أو Next.js
- **Charts**: Chart.js / Recharts / ApexCharts
- **Tables**: React Table / AG Grid




# 📝 **ملاحظات نهائية**

1. **الأمان**: تطبيق HTTPS، تشفير البيانات الحساسة، حماية من SQL Injection
2. **الأداء**: Caching (Redis)، Pagination، Lazy Loading
3. **التوسع**: Microservices Architecture مستقبلاً
4. **الاختبار**: Unit Tests، Integration Tests، End-to-End Tests
5. **التوثيق**: Swagger/OpenAPI للـ API Documentation

---

ه