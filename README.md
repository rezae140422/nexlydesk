<div dir="rtl">

# NexlyDesk — نرم‌افزار دسترسی از راه دور

NexlyDesk نرم‌افزار کنترل و پشتیبانی از راه دور برند **Nexly** است؛ سریع، امن و طراحی‌شده برای کار در شرایط اینترنت محدود و تحریم.

## دانلود آخرین نسخه

| سیستم‌عامل | لینک مستقیم |
|---|---|
| ویندوز (۶۴ بیتی) | [NexlyDesk-windows-x64.exe](https://github.com/rezae140422/nexlydesk/releases/latest/download/NexlyDesk-windows-x64.exe) |
| اندروید (همهٔ پردازنده‌ها) | [NexlyDesk-android-universal.apk](https://github.com/rezae140422/nexlydesk/releases/latest/download/NexlyDesk-android-universal.apk) |


> **اتصال مستقیم با IP (بدون سرور):** تا آماده شدن سرور داخلی Nexly، اتصال از طریق نشانی IP انجام می‌شود. «دسترسی مستقیم با IP» (پورت 21118) به‌طور پیش‌فرض روشن است.
> 1. NexlyDesk را روی هر دو دستگاه نصب و اجرا کنید.
> 2. در دستگاه مقصد، نشانی IP آن را پیدا کنید (ویندوز: `ipconfig`؛ اندروید: تنظیمات Wi‑Fi) و رمز نمایش‌داده‌شده را یادداشت کنید.
> 3. در دستگاه کنترل‌کننده، نشانی IP (مثلاً `192.168.1.20`) را در کادر «Enter remote ID» بنویسید، «Connect» را بزنید و رمز را وارد کنید.
> 4. دو دستگاه باید در یک شبکه (LAN/VPN) باشند، یا پورت TCP 21118 دستگاه مقصد از بیرون در دسترس باشد.
> اتصال با «شناسه (ID)» فقط پس از راه‌اندازی سرور Nexly (پوشهٔ `server/`) ممکن می‌شود.

> نسخه‌های فعلی آزمایشی (alpha) و **بدون امضای دیجیتال** هستند؛ ممکن است ویندوز هشدار SmartScreen و اندروید هشدار «منبع ناشناس» نشان دهد.

## ویژگی‌ها
- رابط کاربری فارسی و راست‌به‌چپ با فونت وزیرمتن، تم تیره و روشن با هویت بصری Nexly
- بدون وابستگی به سرویس‌های خارجی: بررسی به‌روزرسانی، تله‌متری و سرورهای عمومی RustDesk غیرفعال شده‌اند
- قابل استفاده با سرور اختصاصی داخل کشور یا شبکهٔ داخلی سازمان، حتی هنگام قطع اینترنت بین‌الملل

## مجوز و منبع
این پروژه فورکی از [RustDesk](https://github.com/rustdesk/rustdesk) است و تحت مجوز **GNU AGPL-3.0** منتشر می‌شود (فایل [LICENCE](LICENCE) و [NOTICE](NOTICE)). از توسعه‌دهندگان RustDesk سپاسگزاریم.

</div>

---

# NexlyDesk — Remote Desktop

NexlyDesk is Nexly's remote control and support app: fast, secure, and built to keep working on restricted or sanctioned networks.

## Download (latest release)
- Windows x64: [NexlyDesk-windows-x64.exe](https://github.com/rezae140422/nexlydesk/releases/latest/download/NexlyDesk-windows-x64.exe)
- Android (universal): [NexlyDesk-android-universal.apk](https://github.com/rezae140422/nexlydesk/releases/latest/download/NexlyDesk-android-universal.apk)

Builds are currently unsigned alpha releases.

> **Direct IP connection (no server):** until the Nexly server is ready, connect by IP address. "Enable direct IP access" (TCP 21118) is on by default. Type the target's IP (e.g. `192.168.1.20`) into the remote ID box, click Connect and enter the password shown on the target. Both devices must be on the same LAN/VPN, or port 21118 must be reachable. Connecting by ID needs the Nexly server (see `server/`).

## Independence from foreign services
Update checks, the default RustDesk API/admin server, and public server defaults are disabled (`NEXLY_OFFLINE_MODE` in `libs/hbb_common/src/config.rs`). Point the client at your own self-hosted ID/relay server.

## Build
CI: `.github/workflows/nexlydesk-release.yml` (run manually or push a `v*` tag) builds the Windows exe and Android universal APK and attaches them to a GitHub Release.

## License
Fork of [RustDesk](https://github.com/rustdesk/rustdesk), licensed under **AGPL-3.0** — see [LICENCE](LICENCE) and [NOTICE](NOTICE).
