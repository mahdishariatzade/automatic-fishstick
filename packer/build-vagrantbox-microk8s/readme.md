# راهنمای اجرای پروژه ساخت VagrantBox با MicroK8s

این راهنما مراحل آماده‌سازی و اجرای پروژه ساخت VagrantBox با MicroK8s را به صورت گام‌به‌گام توضیح می‌دهد.

---

## پیش‌نیازها

- نصب بودن ابزارهای زیر روی سیستم:
  - [Packer](https://www.packer.io/downloads)
  - [Vagrant](https://www.vagrantup.com/downloads)
  - [VirtualBox](https://www.virtualbox.org/wiki/Downloads) یا سایر Providerهای مورد نیاز
  - دسترسی به اینترنت برای دانلود فایل‌ها و وابستگی‌ها

---

## مراحل اجرا

### ۱. دریافت Playbook نصب MicroK8s

ابتدا فایل playbook مربوط به نصب MicroK8s را دانلود کنید:

```bash
curl -L https://raw.githubusercontent.com/mahdishariatzade/automatic-fishstick/refs/heads/main/ansible/playbooks/kubernetes/microk8s-install.yml -o playbook.yml
```

### ۲. مقداردهی اولیه پروژه با Packer

در مسیر پروژه، دستور زیر را اجرا کنید تا Packer آماده‌سازی اولیه را انجام دهد:

```bash
packer init .
```

### ۳. ساخت VagrantBox با متغیرهای دلخواه

برای ساخت VagrantBox، دستور زیر را اجرا کنید. مقادیر متغیرها را بر اساس نیاز خود تنظیم نمایید:

```bash
packer build \
  -var "version=1.XX" \
  -var "box_tag=YOUR_BOX_TAG" \
  -var "source_path=YOUR_SOURCE_PATH" \
  -var "hcp_client_id=YOUR_CLIENT_ID" \
  -var "hcp_client_secret=YOUR_CLIENT_SECRET" \
  .
```

- مقدار version را با نسخه مورد نظر جایگزین کنید.
- مقدار box_tag را با تگ دلخواه برای باکس جایگزین کنید.
- مقدار source_path را با مسیر منبع مورد نظر جایگزین کنید.
- مقادیر hcp_client_id و hcp_client_secret را در صورت نیاز وارد نمایید.

---

## نکات تکمیلی

- در صورت نیاز به تغییر تنظیمات، فایل‌های Packer و Vagrant را مطابق نیاز خود ویرایش کنید.
- برای اطلاعات بیشتر درباره هر یک از ابزارها، به مستندات رسمی آن‌ها مراجعه نمایید.

---

## منابع

- [مستندات Packer](https://www.packer.io/docs)
- [مستندات Vagrant](https://www.vagrantup.com/docs)
- [مستندات MicroK8s](https://microk8s.io/docs)

---

در صورت بروز هرگونه مشکل یا سوال، می‌توانید Issue جدیدی در مخزن گیت‌هاب پروژه ثبت کنید.