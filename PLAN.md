# NexlyDesk — برنامهٔ MVP (نام موقت)

> فورک RustDesk تحت AGPL-3.0 · فقط محلی (`/workspace/nexly/nexlydesk`) · هیچ مخزن یا push یا هزینه‌ای انجام نشده است.
> **نام محصول در یک ثابت مرکزی است:** `BRAND_PRODUCT_NAME` و میزبان پیش‌فرض `BRAND_DEFAULT_SERVER` در `libs/hbb_common/src/config.rs` (هر دو مخزن). با تغییر همین دو مقدار نام/سرور عوض می‌شود.

## دامنهٔ MVP
ویندوز و اندروید؛ کنترل صفحه، انتقال فایل، کلیپ‌بورد، اتصال روی پورت ۴۴۳، سرورهای اختصاصی (hbbs/hbbr). پخش اندروید با APK مستقیم.

## پیشرفت امروز (۱۳ آبان ۱۴۰۵)
- کلون کامل (با تاریخچه) `rustdesk` (۱۱۶۲۲ کامیت) و `rustdesk-server` به همراه زیرماژول `hbb_common`؛ remote با نام `upstream` و push غیرفعال (`DISABLED`).
- شاخهٔ `nexlydesk` در هر دو مخزن و در زیرماژول‌ها؛ LICENCE/LICENSE حفظ و فایل NOTICE با اعتبار RustDesk افزوده شد.
- ثابت‌های مرکزی برند: `APP_NAME` ← `BRAND_PRODUCT_NAME="NexlyDesk"`، `RENDEZVOUS_SERVERS` ← `nexlydesk.local`. `RS_PUB_KEY` فعلاً بالادستی است (TODO).
- ساخت hbbs/hbbr/rustdesk-utils برای لینوکس موفق؛ تست دود: پورت‌های 21115–21119 باز شدند و کلید ed25519 ساخته شد.

## نقاط برندسازی شناسایی‌شده
- Rust: `libs/hbb_common/src/config.rs` (APP_NAME، ORG=`com.carriez`، RENDEZVOUS_SERVERS، RS_PUB_KEY، پورت‌ها)، `Cargo.toml` (description، ProductName، FileDescription، نام باینری)، `src/common.rs`، `src/lang.rs`، `src/platform/windows.rs`.
- آیکون‌ها: `res/` (icon.ico، icon.png، اندازه‌های PNG، logo.svg، tray-icon.ico، design.svg) و آیکون‌های Flutter/اندروید (`flutter/android/app/src/main/res`).
- اندروید: `AndroidManifest.xml` (برچسب «RustDesk» و «RustDesk Input»)، applicationId در `build.gradle`.
- فارسی/RTL: ترجمهٔ `src/lang/fa.rs` موجود است (نیاز به بازبینی)؛ در Flutter حدود ۳۲ مورد مرتبط با جهت متن (مثلاً `file_manager_page.dart`، `remote_toolbar.dart`) باید برای RTL و فونت فارسی (وزیرمتن) بررسی شود.

## نیازهای ساخت کلاینت
- **ویندوز:** Rust پایدار، Flutter 3.24.5، vcpkg (commit مشخص در CI) با libvpx/libyuv/opus/aom، LLVM، Visual Studio Build Tools — عملاً روی ماشین ویندوز یا GitHub Actions (`windows-latest`).
- **اندروید:** Flutter، Android SDK، NDK r28c، cargo-ndk، vcpkg برای arm64/armv7 — روی لینوکس ممکن ولی سنگین (چند ده گیگ و چند ساعت).
- **پیشنهاد:** پس از ساخت مخزن، از workflowهای موجود `.github/workflows/flutter-build.yml` (رایگان برای مخزن پابلیک) استفاده شود.

## موانع
- مخزن نهایی و نام نهایی هنوز تعیین نشده؛ CI بدون مخزن ممکن نیست.
- آینهٔ apt روی کامپیوتر خطای 500 داد؛ ساخت با libssl و libsodium موجود سیستم انجام شد.
- گواهی امضای ویندوز (تحریم) و سرور/دامنهٔ واقعی برای پورت ۴۴۳ تعیین نشده است.

## برنامهٔ هفتگی (۱۰ هفته)
| هفته | کار |
|---|---|
| ۱ | راه‌اندازی فورک، برند مرکزی، ساخت سرور (✅ بخش عمده)، CI ساخت ویندوز/اندروید |
| ۲ | برندسازی کامل (نام، آیکون، ORG، applicationId)، کلید سرور اختصاصی |
| ۳ | پشتیبانی ۴۴۳: relay/rendezvous از طریق WebSocket/TLS پشت nginx |
| ۴ | ساخت ویندوز پایدار و نصب‌کننده؛ تست کنترل صفحه |
| ۵ | ساخت APK اندروید و تست کنترل/اشتراک صفحه |
| ۶ | انتقال فایل و کلیپ‌بورد روی هر دو پلتفرم |
| ۷ | رابط فارسی، RTL و فونت؛ بازبینی ترجمه |
| ۸ | استقرار سرور آزمایشی، امنیت، رمزنگاری کلید |
| ۹ | تست میدانی روی شبکه‌های ایران، رفع اشکال |
| ۱۰ | بستهٔ نهایی MVP، مستندات، تحویل |

## تصمیم‌های باقی‌مانده (آقای لطفی)
1. نام نهایی محصول (فعلاً NexlyDesk).
2. نام و ساخت مخزن پابلیک در گیت‌هاب rezae140422.
3. سرور و دامنهٔ واقعی (داخل ایران) و هزینهٔ آن.
4. گواهی امضای ویندوز.
5. مدل درآمد و بررسی حقوقی AGPL.

## برنامهٔ فردا
برندسازی Cargo.toml/اندروید/آیکون‌های موقت؛ آماده‌سازی تنظیم پورت ۴۴۳ برای سرور؛ آماده کردن workflow CI برای زمانی که مخزن ساخته شد.

## استقلال از سرویس خارجی
- ثابت `NEXLY_OFFLINE_MODE = true` در `libs/hbb_common/src/config.rs`.
- بررسی به‌روزرسانی (`api.rustdesk.com/version/latest`) در `check_software_update` و `do_check_software_update` غیرفعال است.
- بازگشت پیش‌فرض به `admin.rustdesk.com` برای API حذف شد (رشتهٔ خالی برمی‌گردد).
- سرور پیش‌فرض `BRAND_DEFAULT_SERVER` (فعلاً `nexlydesk.local`) به‌جای سرورهای عمومی RustDesk؛ باید با سرور hbbs داخل ایران جایگزین شود و `RS_PUB_KEY` هم با کلید همان سرور عوض شود (هنوز کلید RustDesk است — کار باز).
- لینک مستندات خارجی (`LINK_DOCS_HOME`) و لینک دانلود rustdesk.com در صفحهٔ اتصال موبایل خنثی شد.
- زیرماژول `hbb_common` داخل مخزن vendor شد تا build به مخزن خارجی وابسته نباشد.
- نام برنامه ≠ «RustDesk» است، پس برنامه در حالت custom client اجرا می‌شود (بدون بنر/به‌روزرسانی رسمی RustDesk).
- فونت وزیرمتن داخل برنامه bundle شده؛ هیچ فونتی از اینترنت دریافت نمی‌شود.
- باقی‌مانده: لینک‌های rustdesk.com در صفحات تنظیمات/درباره (فقط نمایشی، بدون درخواست خودکار) و بخش CI که موتور Flutter سفارشی را از گیت‌هاب RustDesk دانلود می‌کند (فقط هنگام build).
