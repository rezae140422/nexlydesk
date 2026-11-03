## NexlyDesk v0.1.1-alpha

<div dir="rtl">

- رفع خطای نصب ویندوز («Windows cannot find ...NexlyDesk.exe»): فایل اجرایی اکنون واقعاً NexlyDesk.exe است.
- شناسه (ID) و رمز همیشه کامل و چپ‌به‌راست نمایش داده می‌شوند (بدون بریدگی).
> **اتصال مستقیم با IP (بدون سرور):** تا آماده شدن سرور داخلی Nexly، اتصال از طریق نشانی IP انجام می‌شود. «دسترسی مستقیم با IP» (پورت 21118) به‌طور پیش‌فرض روشن است.
> 1. NexlyDesk را روی هر دو دستگاه نصب و اجرا کنید.
> 2. در دستگاه مقصد، نشانی IP آن را پیدا کنید (ویندوز: `ipconfig`؛ اندروید: تنظیمات Wi‑Fi) و رمز نمایش‌داده‌شده را یادداشت کنید.
> 3. در دستگاه کنترل‌کننده، نشانی IP (مثلاً `192.168.1.20`) را در کادر «Enter remote ID» بنویسید، «Connect» را بزنید و رمز را وارد کنید.
> 4. دو دستگاه باید در یک شبکه (LAN/VPN) باشند، یا پورت TCP 21118 دستگاه مقصد از بیرون در دسترس باشد.
> اتصال با «شناسه (ID)» فقط پس از راه‌اندازی سرور Nexly (پوشهٔ `server/`) ممکن می‌شود.
- این نسخه پیش از انتشار به‌صورت خودکار تست شده است: نصب، اجرا، نمایش شناسه، اتصال واقعی با IP مستقیم، و حذف نصب؛ و نصب/اجرا/حذف روی امولاتور اندروید.
- فایل‌ها بدون امضای دیجیتال هستند (هشدار SmartScreen / منبع ناشناس طبیعی است).

</div>

- Fix: Windows installer now installs `NexlyDesk.exe` (was `rustdesk.exe`, causing "Windows cannot find NexlyDesk.exe").
- ID and password always shown in full (LTR, auto-shrink, no ellipsis).
> **Direct IP connection (no server):** until the Nexly server is ready, connect by IP address. "Enable direct IP access" (TCP 21118) is on by default. Type the target's IP (e.g. `192.168.1.20`) into the remote ID box, click Connect and enter the password shown on the target. Both devices must be on the same LAN/VPN, or port 21118 must be reachable. Connecting by ID needs the Nexly server (see `server/`).
- Pre-release CI tests: Windows install/launch/ID/real direct-IP session/uninstall; Android emulator install/launch/no-crash/uninstall.
- Unsigned alpha builds. Fork of RustDesk, AGPL-3.0.
