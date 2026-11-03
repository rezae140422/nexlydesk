# NexlyDesk server (hbbs + hbbr) — prepared, NOT deployed

<div dir="rtl">

این پوشه برای راه‌اندازی سرور شناسه/رله‌ی NexlyDesk روی یک VPS لینوکسی (ترجیحاً داخل ایران) آماده شده است. **هیچ چیزی به‌طور خودکار مستقر نمی‌شود.**

۱. ساخت باینری‌ها: `bash server/build.sh` (یا دریافت artifact از workflow «NexlyDesk Server Build»).
۲. نصب با یک دستور (روی سرور، با دسترسی root): `sudo bash server/install.sh` — برای شبکه‌های فیلترشده: `sudo bash server/install.sh --port443`
۳. خروجی اسکریپت نشانی سرور و «کلید عمومی» را نشان می‌دهد؛ این دو را در تنظیمات شبکهٔ برنامه وارد کنید یا برای ساخت نسخهٔ بعدی در `libs/hbb_common/src/config.rs` قرار دهید.

</div>

| Service | Default ports | With `--port443` |
|---|---|---|
| hbbs (ID / rendezvous) | TCP 21115, TCP+UDP 21116, TCP 21118 (ws) | TCP 442, TCP+UDP 443, TCP 445 |
| hbbr (relay) | TCP 21117, TCP 21119 (ws) | unchanged |

- systemd units: `nexlydesk-hbbs`, `nexlydesk-hbbr` (user `nexlydesk`, data in `/var/lib/nexlydesk`).
- Logs: `journalctl -u nexlydesk-hbbs -f`.
- Uninstall: `systemctl disable --now nexlydesk-hbbs nexlydesk-hbbr && rm /etc/systemd/system/nexlydesk-hb*.service /usr/local/bin/hbb[sr]`.
- Source: rustdesk-server (AGPL-3.0). No foreign service is contacted at runtime.
