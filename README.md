# Production-Grade LEMP Platform

A production-style LEMP (Linux, Nginx, PHP-FPM, MariaDB) platform built
to demonstrate **Linux administration, application deployment,
monitoring, automation, failure recovery, and SRE/DevOps practices**.

The project is intentionally designed around operational scenarios:
service failures, health checks, automated recovery, idempotent
deployments, monitoring alerts, evidence collection, and repeatable
Ansible automation.

------------------------------------------------------------------------

## 📌 Project Overview

This project simulates a small production web platform running on Linux.

The platform contains:

-   **Nginx** as the web server and reverse/front-end web layer
-   **PHP 8.3-FPM** for PHP application execution
-   **MariaDB** as the application database
-   **Bash** scripts for health checks, service recovery, and log/disk
    analysis
-   **Ansible** for service management, deployment, verification, and
    automated recovery
-   **Monitoring alert scripts** for CPU, memory, disk, service
    availability, and load conditions
-   **Failure labs** to simulate production-style failures and validate
    recovery procedures
-   **Evidence logs** to demonstrate test results and operational
    activities

------------------------------------------------------------------------

## 🏗️ Architecture

``` text
                    ┌──────────────────────────┐
                    │       Linux Host         │
                    │      Ubuntu Linux        │
                    └────────────┬─────────────┘
                                 │
                                 ▼
                    ┌──────────────────────────┐
                    │         Nginx            │
                    │       Port 80             │
                    └────────────┬─────────────┘
                                 │
                                 ▼
                    ┌──────────────────────────┐
                    │       PHP 8.3-FPM        │
                    │   Unix PHP-FPM Socket    │
                    └────────────┬─────────────┘
                                 │
                                 ▼
                    ┌──────────────────────────┐
                    │        PHP App            │
                    │   /srv/veriqta-portal    │
                    └────────────┬─────────────┘
                                 │
                                 ▼
                    ┌──────────────────────────┐
                    │         MariaDB           │
                    │       Application DB      │
                    └──────────────────────────┘


        ┌───────────────────────────────────────────────┐
        │             Automation Layer                 │
        │                                               │
        │  Bash Scripts          Ansible Playbooks      │
        │  ├─ Health Check       ├─ Verify             │
        │  ├─ Recovery           ├─ Manage             │
        │  └─ Log Cleanup        ├─ Deploy             │
        │                        └─ Recover            │
        └───────────────────────────────────────────────┘
```

### Application URL

``` text
http://portal.veriqta.test/
```

### Health Endpoint

``` text
http://portal.veriqta.test/health.php
```

Expected response:

``` json
{"status":"healthy","database":"reachable"}
```

------------------------------------------------------------------------

## 🛠️ Technology Stack

  Category               Technology
  ---------------------- ------------------------------
  Operating System       Ubuntu Linux
  Web Server             Nginx
  Application Runtime    PHP 8.3-FPM
  Database               MariaDB
  Automation             Ansible
  Scripting              Bash
  Monitoring             Alert/health-check scripts
  Configuration          Nginx, systemd, Ansible YAML
  Version Control        Git
  Application Protocol   HTTP
  Architecture Style     Production-style LEMP

------------------------------------------------------------------------

## 📁 Project Structure

``` text
production-lemp-platform/
│
├── application/
│   ├── public/
│   │   ├── health.php
│   │   └── index.php
│   └── src/
│       └── database.php
│
├── automation/
│   └── ansible/
│       ├── inventory/
│       │   ├── group_vars/
│       │   │   └── lemp.yml
│       │   └── hosts.ini
│       │
│       ├── playbooks/
│       │   ├── deploy_lemp.yml
│       │   ├── manage_lemp.yml
│       │   ├── recover_lemp.yml
│       │   └── verify_lemp.yml
│       │
│       └── roles/
│
├── backups/
│
├── config/
│
├── docs/
│
├── evidence/
│   ├── health-check/
│   │   ├── health_check.log
│   │   └── service_recovery.log
│   └── log-cleanup/
│       └── log_cleanup.log
│
├── failure-labs/
│
├── runbooks/
│
├── screenshots/
│
├── scripts/
│   ├── health_check.sh
│   ├── service_recovery.sh
│   ├── log_cleanup.sh
│   ├── check_php_fpm.sh
│   ├── check_mariadb.sh
│   └── check_load.sh
│
└── tests/
```

------------------------------------------------------------------------

# ⚙️ Automation

## Bash Automation

### 1. Health Check

`health_check.sh` checks:

-   Nginx status
-   PHP-FPM status
-   MariaDB status
-   Root filesystem usage
-   Memory usage
-   CPU load
-   Application HTTP response

Run:

``` bash
./scripts/health_check.sh
```

A healthy system returns:

``` text
FINAL STATUS: HEALTHY
```

and exit code:

``` text
0
```

------------------------------------------------------------------------

### 2. Automated Service Recovery

`service_recovery.sh` checks the core services and attempts to restart a
service when it is not running.

Run:

``` bash
./scripts/service_recovery.sh
```

The script also verifies that the application responds after recovery.

------------------------------------------------------------------------

### 3. Log and Disk Cleanup

`log_cleanup.sh` provides operational disk and log analysis.

It checks:

-   Root filesystem usage
-   Nginx logs
-   MariaDB logs
-   PHP logs
-   Large log files
-   Project evidence size
-   Old compressed logs

Run:

``` bash
./scripts/log_cleanup.sh
```

------------------------------------------------------------------------

# 🤖 Ansible Automation

The project uses Ansible to make common operational tasks repeatable.

## Inventory

The current environment uses a local Ansible target:

``` ini
[lemp]
localhost ansible_connection=local
```

Variables are stored in:

``` text
automation/ansible/inventory/group_vars/lemp.yml
```

------------------------------------------------------------------------

## Verify Platform

Checks:

-   Nginx
-   PHP-FPM
-   MariaDB
-   Application HTTP response

Run:

``` bash
ansible-playbook \
-i automation/ansible/inventory/hosts.ini \
automation/ansible/playbooks/verify_lemp.yml
```

------------------------------------------------------------------------

## Manage Services

Ensures the core services are enabled and running.

Run:

``` bash
ansible-playbook \
-i automation/ansible/inventory/hosts.ini \
automation/ansible/playbooks/manage_lemp.yml
```

------------------------------------------------------------------------

## Deploy Application

Deploys the application from the repository into:

``` text
/srv/veriqta-portal
```

Run:

``` bash
ansible-playbook \
-i automation/ansible/inventory/hosts.ini \
automation/ansible/playbooks/deploy_lemp.yml
```

The deployment is designed to be **idempotent**.

A repeat deployment produced:

``` text
ok=5
changed=0
failed=0
```

------------------------------------------------------------------------

## Automated Failure Recovery

The recovery playbook ensures:

-   Nginx is running
-   PHP-FPM is running
-   MariaDB is running
-   Application returns HTTP 200

Run:

``` bash
ansible-playbook \
-i automation/ansible/inventory/hosts.ini \
automation/ansible/playbooks/recover_lemp.yml
```

------------------------------------------------------------------------

# 🚨 Monitoring and Alerts

The project includes alert checks for:

-   High CPU
-   High Memory
-   High Disk
-   Server Down
-   Nginx Down
-   PHP-FPM Down
-   MariaDB Down
-   High Load Average

Examples of service alert checks:

``` bash
./scripts/check_php_fpm.sh
```

``` bash
./scripts/check_mariadb.sh
```

``` bash
./scripts/check_load.sh
```

Alert scripts use exit codes to represent health:

``` text
0 = Healthy
2 = Alert/Critical
```

This makes them suitable for integration with monitoring or automation
systems.

------------------------------------------------------------------------

# 🧪 Failure Labs

The project includes **12 completed failure labs** covering
production-style failure scenarios.

The purpose of the labs is not only to create failures, but to practice:

1.  Detecting the problem
2.  Identifying the affected component
3.  Checking logs and service status
4.  Performing recovery
5.  Validating the application
6.  Recording evidence

This approach reflects an SRE-style incident response workflow.

------------------------------------------------------------------------

# 🔄 Failure Recovery Example

One of the final validation tests intentionally stopped Nginx:

``` bash
sudo systemctl stop nginx
```

The application became unavailable:

``` text
curl: (7) Failed to connect
```

The Ansible recovery playbook was then executed:

``` bash
ansible-playbook \
-i automation/ansible/inventory/hosts.ini \
automation/ansible/playbooks/recover_lemp.yml
```

Ansible reported:

``` text
Nginx recovery: True
PHP-FPM recovery: False
MariaDB recovery: False
Application: HTTP 200
```

Independent verification confirmed:

``` text
active
```

and:

``` json
{"status":"healthy","database":"reachable"}
```

This demonstrates:

``` text
Failure
  ↓
Detection
  ↓
Automated Recovery
  ↓
Service Validation
  ↓
Application Validation
```

------------------------------------------------------------------------

# 📊 Final Testing Results

The platform has been tested end-to-end.

  Test                           Result
  ------------------------------ -------------
  Nginx service                  ✅ PASS
  PHP-FPM service                ✅ PASS
  MariaDB service                ✅ PASS
  Application HTTP response      ✅ PASS
  Database health check          ✅ PASS
  Bash health check              ✅ PASS
  Bash service recovery          ✅ PASS
  Log/disk analysis              ✅ PASS
  Ansible verification           ✅ PASS
  Ansible service management     ✅ PASS
  Ansible deployment             ✅ PASS
  Deployment idempotency         ✅ PASS
  Ansible failure recovery       ✅ PASS
  PHP-FPM failure detection      ✅ PASS
  MariaDB failure detection      ✅ PASS
  Load alert healthy condition   ✅ PASS
  12 failure labs                ✅ COMPLETE

------------------------------------------------------------------------

# 🩺 Application Health Check

Run:

``` bash
curl -s http://portal.veriqta.test/health.php
```

Expected:

``` json
{"status":"healthy","database":"reachable"}
```

This verifies both application availability and database connectivity.

------------------------------------------------------------------------

# 🔐 Operational Practices Demonstrated

This project demonstrates practical SRE/DevOps concepts:

-   Linux service management
-   systemd troubleshooting
-   Nginx configuration
-   PHP-FPM troubleshooting
-   MariaDB availability checks
-   Application health checks
-   Disk and memory monitoring
-   Load monitoring
-   Bash automation
-   Ansible automation
-   Idempotent configuration management
-   Automated service recovery
-   Failure simulation
-   Incident-style troubleshooting
-   Recovery validation
-   Operational evidence collection
-   Backup before deployment
-   Runbook-oriented operations

------------------------------------------------------------------------

# 📚 Useful Commands

### Check services

``` bash
systemctl status nginx
systemctl status php8.3-fpm
systemctl status mariadb
```

### Check application

``` bash
curl -I http://portal.veriqta.test/
```

### Check application health

``` bash
curl -s http://portal.veriqta.test/health.php
```

### Check disk

``` bash
df -h /
```

### Check memory

``` bash
free -h
```

### Check load

``` bash
uptime
```

### Run health check

``` bash
./scripts/health_check.sh
```

### Run Ansible verification

``` bash
ansible-playbook \
-i automation/ansible/inventory/hosts.ini \
automation/ansible/playbooks/verify_lemp.yml
```

------------------------------------------------------------------------

# 🎯 Project Goals

The main goals of this project are to demonstrate how a DevOps/SRE
engineer can:

-   Operate a Linux-based web application
-   Automate repetitive operational tasks
-   Detect infrastructure and service failures
-   Recover failed services automatically
-   Deploy applications consistently
-   Validate deployments
-   Design idempotent automation
-   Monitor system health
-   Document operational procedures
-   Test failure scenarios before production incidents occur

------------------------------------------------------------------------

# 🚀 Future Improvements

Potential future improvements include:

-   Prometheus integration
-   Grafana dashboards
-   Alertmanager notification routing
-   Centralized logging
-   Docker containerization
-   Kubernetes deployment
-   Terraform-based infrastructure
-   AWS deployment
-   CI/CD pipeline
-   Automated GitHub Actions testing
-   Secrets management
-   TLS/HTTPS automation
-   Multi-server Ansible inventory

These are intentionally listed as future enhancements rather than
claiming they are already implemented.

------------------------------------------------------------------------

# 👨‍💻 Author

**Om Girish Gaddapwar**

Linux / DevOps / SRE-focused engineer

Core interests:

-   Linux Administration
-   DevOps
-   Site Reliability Engineering
-   Automation
-   Cloud Infrastructure
-   Monitoring
-   Production Support

------------------------------------------------------------------------

## ⭐ Project Highlights

> **Production-style LEMP platform with automated deployment,
> monitoring, failure simulation, and service recovery using Bash and
> Ansible.**

The project focuses on demonstrating not only how to deploy an
application, but also how to **operate, monitor, troubleshoot, recover,
and validate it like a production system**.
