# 🖥️ Server Performance Status Script

A lightweight Bash script to monitor key system metrics including CPU, memory, disk usage, and top resource-consuming processes. Ideal for sysadmins, DevOps engineers, or anyone needing quick insights into server health.

---

## 📦 Features

- ✅ Root privilege check
- 📊 CPU usage (via `top`)
- 🧠 Memory usage (via `free`)
- 💾 Disk usage (via `df`)
- 🔍 Top 5 processes by CPU and memory
- 🧮 Safe percentage calculations using `bc`

---

## 🚀 Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/simonbarrios/Server-Performance-Status-Script.git
cd Server-Performance-Status-Script
```

### 2. Make the Script Executable

```bash
chmod +x server_status.sh
```

### 3. Run the Script with Root Privileges

```bash
sudo ./server_status.sh
```

> ⚠️ The script must be run as root to access full system metrics. If not, it will exit with an error.

---

## 📋 Output Overview

The script prints a structured report with:

1. **Total CPU Usage** – Calculated as `100 - idle %`
2. **Memory Usage** – Total, used, free (in MB) and usage percentage
3. **Disk Usage** – Size, used, free, and usage percentage for `/`
4. **Top 5 CPU-consuming processes**
5. **Top 5 memory-consuming processes**

---

## 🛠️ Dependencies

- `bash`
- `bc`
- `top`
- `free`
- `df`
- `ps`

These are typically available by default on most Linux distributions.

---

## 📌 Notes

- Designed for Linux systems.
- Disk usage focuses on the root filesystem (`/`). You can modify `DISK_PATH` in the script to target other mount points.
- Output is printed to the terminal; no logs are saved by default.
