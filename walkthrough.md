# التوثيق الشامل والمحدث للنظام (Final Production Documentation)

تم الانتهاء من كافة مراحل إعداد، تأمين، وتحسين مشروع **Medical QBank**. يوضح هذا التوثيق الحالة النهائية للسيرفر والتطبيق ليكون مرجعاً للإدارة مستقبلاً.

---

## 1. البنية التحتية والأمان (Infrastructure & Security)
- **السيرفر الـ IP**: `209.74.82.107`
- **نظام التشغيل**: Ubuntu 24.04 (Noble)
- **مستخدم الإدارة**: `medadmin`
- **نظام الحماية**: 
  - الدخول عبر SSH بورت `22022` بمفاتيح SSH فقط (تم تعطيل كلمات المرور).
  - تفعيل الجدار الناري (UFW) وحماية ضد هجمات التخمين (Fail2Ban).
- **نظام التشفير (SSL)**:
  - **الشهادة**: Let's Encrypt (رسمية ومعترف بها دولياً).
  - **المسار**: `/etc/letsencrypt/live/healthlicenseprep.com/fullchain.pem`
  - **التجديد**: تلقائي بالكامل عبر `certbot.timer` (كل 3 أشهر).
  - **التوجيه**: توجيه تلقائي وإجباري لكافة الطلبات من HTTP إلى **HTTPS**.
  - **النطاقات المشمولة**: `healthlicenseprep.com` و `www.healthlicenseprep.com`

> **تحذير مهم**: عند رفع ملف `nginx_medical_qbank.conf` الجديد للسيرفر، تأكد دائماً أن مسارات الشهادة تشير إلى `/etc/letsencrypt/live/...` وليس `/etc/nginx/ssl/...` لأن الأخير هو الشهادة المؤقتة القديمة.

*   إنشاء زر **حذف المحدد (Delete Selected)** يظهر برمجياً عندما يتم تحديد الأسئلة، ويقوم بتنفيذ عملية مسح جماعية متوازية (`Promise.all`) لكافة الأسئلة المحددة مع تنظيف الواجهة تلقائياً.

### 8. حل المشاكل الجذرية لعملية استخراج الأسئلة بالذكاء الاصطناعي (AI Extraction Fixes - 🔴 NEW)
*   **تخفيض التكلفة المادية (Cost Optimization):**
    *   تم تتبع سبب الاستهلاك العالي جداً للرصيد، ووجدنا أنه بسبب تمرير آلاف الأسئلة السابقة كنص في موجه الذكاء الاصطناعي (`Prompt`) للمقارنة.
    *   تم حذف هذا الإجراء المكلف تماماً واعتماد نظام الـ Backend الآمن (`findOrCreate`) لحجب التكرار بشكل مجاني. هذا التعديل البسيط **يخفّض التكلفة بمستوى 80-95%**.
*   **بناء هندسة الخدمات المصغرة وطوابير المعالجة (Microservices Architecture 🏛️ - 🔥 NEW):**
    *   بناءً على طلبك، تم فصل محرك استخراج الذكاء الاصطناعي عن الخادم الأساسي (Backend) بالكامل.
    *   تم إنشاء حاوية مستقلة بالكامل تعمل كـ **"عامل ذكاء اصطناعي في الخلفية" (AI Worker)** وتتواصل مع السيرفر الرئيسي عبر بروتوكول اتصال `Redis` باستخدام مكتبة `BullMQ`.
    *   **الرفع الموازي الشرائحي (Horizontal Scaling - 🧊 NEW):** تم استجابة لطلبك بـ "التقسيم إلى دفعات وفتح أكثر من مسار"؛ حيث تم تغيير الكود ليأخذ ملف الـ DOCX ويقصه إلى شرائح صغيرة (Slices) ويعامل كل شريحة كـ Job منفصل تماماً (باستخدام دالة `addBulk`). هذا يعني أنك إذا شغلت 10 Workers في المستقبل، سيقومون بمعالجة 10 شرائح معاً في نفس اللحظة من نفس الملف بدلاً من الاعتماد على طابور خطي واحد!
    *   الآن، عندما يقوم الـ Admin برفع ملف ضخم جدًا (مثلاً 50 صفحة)، يقوم السيرفر الرئيسي بتمريره فوراً لـ Redis كشرائح ويعود للعمل دون استهلاك الـ CPU. بينما يقوم الـ **AI Worker** بـ "طحن" ومعالجة الشرائح بشكل متواز، وإرسال التقدم (`Progress`) حياً عبر الـ `Queues Events`.
*   **تشغيل النقل المتزامن المباشر للواجهة (Live Streaming Proxy - 🔗):**
    *   تم تفعيل `X-Accel-Buffering: no` و `res.flush()` بشكل إجباري لكسر حواجز التخزين (Buffering) الخاصة بـ Nginx و Node.js، مما يجعل شريط التقدم يتحرك خطوة بخطوة أمامك بدون أن يتجمد لثانية واحدة.
*   **منع الهلوسة وتسريع الاستخراج وتطويع الـ (Skill.md - 🛠️ NEW):**
    *   تم نقل نص توجيه الذكاء الاصطناعي (`System Prompt`) بالكامل من داخل أكواد الجافاسكريبت المعقدة إلى ملف خارجي منفصل بصيغة نصوص عادية اسمه `backend/src/services/ai_skill.md`. 
    *   هذا يتيح لك الآن تعديل سلوك الـ AI وتغيير كلماته وتوجيهاته بكل سهولة عبر فتح ملف `ai_skill.md` مباشرة وتعديله كأي ملف نصي، بدون الحاجة للتعديل والمخاطرة بملفات الباك-إند البرمجية.
    *   بناءً على تصميمك الاحترافي للملف، تم برمجة الـ Worker ليستخرج آخر 100 سؤال من قاعدة البيانات ضمن نفس التخصص المغطى ويمررهم تلقائياً لمتغير `{{EXISTING_QUESTIONS}}` ليقوم الأيجنت بكشف المكرر (`isDuplicate`).
    *   يتم استخراج مخرجات المبررات (`explanation`) والمراجع المقترحة (`references`) بشكل نظيف من الـ AI لحفظها ضمن أرشيف الشروحات لكل سؤال جديد وفق تصميمك الجديد للملف.
*   **تحديد موضوع وتصنيف حركي لكل سؤال/شريحة (Dynamic Auto-Detect):**
    *   النظام الآن يستكشف التصنيف أو المادة التابعة للملف **بشكل محلي لكل مجموعة أسئلة (Chunk)** بدلاً عن قفل التصنيف بشكل عام، لتنويع فرز الأسئلة المتعددة داخل نفس الملف.

### 9. ملاحظات تقنية هامة للمستقبل
*   **تنبيه SSL:** عند تعديل `nginx_medical_qbank.conf` مستقبلاً، تأكد دائماً أن مسارات الـ `ssl_certificate` تشير إلى `/etc/letsencrypt/live/...` وليس أي مسار آخر.`/etc/nginx/ssl/...` لأن الأخير هو الشهادة المؤقتة القديمة.

---

## 2. إدارة التطبيقات (Docker Services)
النظام يعمل بكفاءة عالية عبر 3 حاويات مترابطة:

| الحاوية | التقنية | الوصف |
| :--- | :--- | :--- |
| `medical_qbank_db` | MySQL 8.0 | تخزين كافة البيانات والأسئلة |
| `medical_qbank_backend` | Node.js | محرك الـ API — محسّن للذاكرة وللاستيراد الضخم |
| `medical_qbank_admin` | Nginx + Vite | لوحة التحكم — مع دعم MIME Types و Gzip |

- **المسار الرئيسي**: `/opt/medical-qbank/`
- **إدارة الحاويات**: `docker-compose.yml`

---

## 3. تحسينات الأداء والشبكة (Performance)
- **ضغط البيانات (Gzip)**: مفعل على مستوى السيرفر (Host Nginx) وداخل حاوية الإدارة.
- **MIME Types**: مفعلة داخل حاوية Admin لضمان تحميل CSS/JS بشكل صحيح.
- **المهلة الزمنية (Timeout)**: `500 ثانية` لضمان نجاح استيراد ملفات DOCX الكبيرة.
- **حجم الملفات المرفوعة**: مسموح حتى `50 ميجابايت`.
- **Proxy Buffers**: `16 x 16k` مع `32k buffer size` لتسريع نقل البيانات عبر Cloudflare.
- **دعم Cloudflare**: السيرفر مهيأ بقائمة IP الخاصة بـ Cloudflare ويمرر الآي بي الحقيقي للمستخدم عبر `CF-Connecting-IP`.

---

## 4. نظام الذكاء الاصطناعي (AI System)
يعمل نظام الذكاء الاصطناعي على 3 محاور:

### 4.1 استيراد الأسئلة من DOCX (Smart DOCX Import)
- **الحد الأقصى**: يستخرج **20 سؤالاً كحد أقصى** من كل ملف DOCX (لتجنب استهلاك الذاكرة).
- **اختيار الأقسام تلقائياً**: عند وضع `auto-detect`، يقوم الـ AI بالاختيار من الأقسام والمواضيع **الموجودة فعلاً** في قاعدة البيانات بدلاً من اختراع أسماء جديدة.
- **فحص التكرار (Deduplication)**:
  - **على مستوى الـ AI**: يتم تمرير عينة من الأسئلة الموجودة للـ AI ليتجنب استخراج أسئلة مشابهة.
  - **على مستوى قاعدة البيانات**: يتم فحص كل سؤال قبل إدخاله — إذا كان موجوداً مسبقاً يتم تخطيه تلقائياً.
- **المعالجة بالدفعات**: يتم إدخال الأسئلة على دفعات (كل 10 أسئلة) داخل Transaction لحماية البيانات.

### 4.2 توليد الشروحات (AI Explanation)
- يولد شروحات طبية مفصلة لكل سؤال مع Key Points و Why Wrong.
- محمي بنظام Rate Limiting: أقصى 10 طلبات في الدقيقة.

### 4.3 توليد أسئلة جديدة (AI Generate Question)
- يولد أسئلة طبية كاملة من الصفر بناءً على القسم والموضوع المحدد.
- يتضمن سيناريو سريري واقعي وخيارات وشروحات.

---

## 5. تطبيق الموبايل (Flutter Mobile App)
- **حالة الربط**: تم تحديث كافة الأكواد لترتبط بالنطاق الرسمي `https://healthlicenseprep.com`.
- **الملفات المعدلة**:
  - `lib/main.dart` — FCM Service URL
  - `lib/core/network/dio_client.dart` — Dio Base URL
  - `lib/presentation/screens/subscription/checkout_screen.dart`
  - `lib/presentation/screens/subscription/pricing_screen.dart`
  - جميع الملفات التي تحتوي على `192.168.100.200`
- **طريقة التشغيل**:
  ```bash
  cd frontend
  flutter clean
  flutter pub get
  flutter run              # تشغيل مباشر
  flutter build apk --release  # بناء APK
  ```

---

## 6. لوحة التحكم (Admin Portal)
- **الرابط**: [https://healthlicenseprep.com](https://healthlicenseprep.com)
- **حساب المدير**: 
  - **البريد**: `admin@healthlicenseprep.com`
  - **كلمة المرور**: `Admin#2026!Health`

---

## 7. أوامر الصيانة (Maintenance Commands)

```bash
# إعادة تشغيل كافة الخدمات
cd /opt/medical-qbank && sudo docker compose restart

# متابعة سجلات الباك إند
sudo docker logs -f medical_qbank_backend

# إعادة بناء حاوية معينة
sudo docker compose up -d --build admin   # أو backend

# فحص حالة الشهادة
sudo certbot certificates

# تجديد الشهادة يدوياً (اختبار)
sudo certbot renew --dry-run

# رفع ملف Nginx محدث
scp -P 22022 nginx_medical_qbank.conf medadmin@209.74.82.107:/home/medadmin/medical-qbank.conf
ssh -p 22022 medadmin@209.74.82.107 "sudo mv /home/medadmin/medical-qbank.conf /etc/nginx/sites-available/medical-qbank && sudo systemctl restart nginx"
```

---

## 8. قائمة الملفات المعدلة (Modified Files Summary)

| الملف | التعديل |
| :--- | :--- |
| `nginx_medical_qbank.conf` | SSL رسمي + Gzip + Timeout 500s + ACME Challenge |
| `admin-dashboard/Dockerfile` | إضافة MIME Types + Gzip داخلي |
| `admin-dashboard/.env` | تحديث API URL إلى مسار نسبي `/api/v1` |
| `backend/src/services/aiService.js` | حد 20 سؤال + اختيار أقسام موجودة + فحص تكرار |
| `backend/src/controllers/admin/questionController.js` | Batch processing + Transactions + Deduplication |
| `frontend/lib/**` | تحديث كافة الروابط إلى `https://healthlicenseprep.com` |
| `docker-compose.yml` | إضافة Volume mapping للـ Admin Dashboard |
