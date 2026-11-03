## NexlyDesk v0.1.1-alpha

<div dir="rtl">

- رفع خطای نصب ویندوز («Windows cannot find ...NexlyDesk.exe»): فایل اجرایی اکنون واقعاً NexlyDesk.exe است.
- شناسه (ID) و رمز همیشه کامل و چپ‌به‌راست نمایش داده می‌شوند (بدون بریدگی).
> **سرور موقت:** تا آماده شدن سرور داخلی Nexly در ایران، این نسخه **به‌طور موقت از سرورهای عمومی RustDesk** برای اتصال استفاده می‌کند. اگر این سرورها در دسترس نباشند (مثلاً به‌دلیل محدودیت اینترنت)، برنامه پیام «سرور NexlyDesk در دسترس نیست» نشان می‌دهد.
- این نسخه پیش از انتشار به‌صورت خودکار تست شده است: نصب، اجرا، نمایش شناسه، اتصال واقعی دو کلاینت ویندوز، و حذف نصب؛ و نصب/اجرا/حذف روی امولاتور اندروید.
- فایل‌ها بدون امضای دیجیتال هستند (هشدار SmartScreen / منبع ناشناس طبیعی است).

</div>

- Fix: Windows installer now installs `NexlyDesk.exe` (was `rustdesk.exe`, causing "Windows cannot find NexlyDesk.exe").
- ID and password always shown in full (LTR, auto-shrink, no ellipsis).
> **Temporary server:** until the Nexly in-Iran server is ready, this build **temporarily uses RustDesk's public servers** for connections (switch: `NEXLY_USE_PUBLIC_SERVERS` in `libs/hbb_common/src/config.rs`). If they are unreachable, the app shows a clear Persian message.
- Pre-release CI tests: Windows install/launch/ID/real 2-client session via public server/uninstall; Android emulator install/launch/no-crash/uninstall.
- Unsigned alpha builds. Fork of RustDesk, AGPL-3.0.
