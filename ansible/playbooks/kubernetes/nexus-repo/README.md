# Nexus Repository Deployment on Kubernetes

این playbook برای deploy کردن Sonatype Nexus Repository در محیط Kubernetes طراحی شده است.

## پیش‌نیازها

- Kubernetes cluster که در حال اجرا باشد
- kubectl که به cluster متصل باشد
- Ansible 2.9+ با collection های `kubernetes.core`
- Python 3 با package های `kubernetes` و `PyYAML`

## نصب Ansible Collections

```bash
ansible-galaxy collection install kubernetes.core
```

## نصب Python Dependencies

```bash
pip3 install kubernetes PyYAML
```

## تنظیمات

1. فایل `vars.yml` را ویرایش کنید و مقادیر زیر را بر اساس نیاز خود تغییر دهید:
   - `nexus_hostname`: دامنه یا hostname برای دسترسی به Nexus
   - `nexus_namespace`: namespace در Kubernetes
   - `nexus_storage_size`: اندازه storage برای داده‌های Nexus
   - `nexus_storage_class`: storage class مورد استفاده

2. تنظیمات Traefik IngressRoute (پیش‌فرض):
   ```yaml
   nexus_hostname: 'nexus.yourdomain.com'
   nexus_tls_secret: 'nexus-tls-secret'
   nexus_enable_https_redirect: true  # HTTP to HTTPS redirect
   ```

3. برای تنظیم منابع سیستم (Resource Limits):
   ```yaml
   nexus_memory_request: '1Gi'
   nexus_memory_limit: '2Gi'
   nexus_cpu_request: '500m'
   nexus_cpu_limit: '1000m'
   ```

## اجرای Playbook

```bash
# اجرای بر روی localhost
ansible-playbook -i localhost, -c local playbook.yml

# یا اجرای بر روی remote host
ansible-playbook -i inventory playbook.yml
```

## دسترسی به Nexus Repository

پس از اجرای موفق playbook:

1. **دسترسی وب**: `https://nexus.example.com` (یا hostname که تنظیم کرده‌اید)

2. **اطلاعات ورود پیش‌فرض**:
   - Username: `admin`
   - Password: برای دریافت رمز عبور اولیه:
   ```bash
   kubectl exec -n nexus deployment/nexus-repository -- cat /nexus-data/admin.password
   ```

## ویژگی‌های Playbook

- ✅ ایجاد Namespace جداگانه
- ✅ تنظیم PersistentVolumeClaim برای ذخیره‌سازی داده‌ها
- ✅ Deploy کردن Nexus با تنظیمات resource limits
- ✅ ایجاد Service برای دسترسی internal
- ✅ تنظیم Traefik IngressRoute با SSL/TLS
- ✅ Health check و monitoring
- ✅ انتظار برای آماده شدن deployment

## ویژگی‌های Traefik

این playbook از Traefik IngressRoute با قابلیت‌های زیر استفاده می‌کند:

- **SSL/TLS Termination**: پشتیبانی از HTTPS با certificate
- **HTTP to HTTPS Redirect**: تبدیل خودکار HTTP به HTTPS
- **Custom Headers**: اضافه کردن header های امنیتی
- **Middleware Support**: استفاده از Traefik middleware ها

### Middleware های تعریف شده:

1. **nexus-headers**: اضافه کردن header های امنیتی
2. **redirect-to-https**: تبدیل HTTP به HTTPS

### Docker Registry

برای فعال کردن Nexus به عنوان یک Docker Registry، مراحل زیر را دنبال کنید:

1.  در فایل `vars.yml`، گزینه‌ها را فعال کنید:
    ```yaml
    nexus_enable_docker_repository: true
    nexus_docker_registry_port: 8082
    nexus_docker_registry_host: 'docker.yourdomain.com'
    ```

2.  Playbook یک `IngressRouteTCP` برای شما ایجاد می‌کند. این Ingress از نوع `TLS Passthrough` است، یعنی خود Nexus مسئول مدیریت Certificate خواهد بود.

3.  پس از اجرای playbook، باید در وب UI یک Docker (hosted) repository ایجاد کنید و در تنظیمات آن، پورت HTTPS را روی `{{ nexus_docker_registry_port }}` تنظیم کنید.

4.  برای `docker login`، به یک Certificate معتبر برای دامنه `docker.yourdomain.com` نیاز دارید.

## تنظیمات اضافی

### استفاده از Storage Class خاص

```yaml
nexus_storage_class: 'ssd-storage'  # یا نام storage class مورد نظر
```

### تنظیم Service Type

```yaml
nexus_service_type: 'LoadBalancer'  # برای دسترسی مستقیم از خارج
```

## عیب‌یابی

### بررسی وضعیت deployment:
```bash
kubectl get pods -n nexus
kubectl get services -n nexus
kubectl get ingressroute -n nexus
kubectl get middlewares -n nexus
```

### مشاهده logs:
```bash
kubectl logs -n nexus deployment/nexus-repository -f
```

### بررسی storage:
```bash
kubectl get pvc -n nexus
```

## حذف Nexus Repository

```bash
kubectl delete namespace nexus
```

**توجه**: این عمل تمام داده‌های Nexus را حذف می‌کند.

## پشتیبانی

- مستندات رسمی Nexus: https://help.sonatype.com/repomanager3
- Docker Image: https://hub.docker.com/r/sonatype/nexus3 