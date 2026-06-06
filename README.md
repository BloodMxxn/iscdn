# 🚀 ISCDN - CDN IP Range Checker

A simple Bash script to check if an IP belongs to **Cloudflare** or **ArvanCloud** CDN.

[![Bash](https://img.shields.io/badge/Bash-4.0%2B-4EAA25?style=flat&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Cloudflare](https://img.shields.io/badge/Cloudflare-F38020?style=flat&logo=cloudflare&logoColor=white)](https://www.cloudflare.com/)
[![ArvanCloud](https://img.shields.io/badge/ArvanCloud-0077B6?style=flat&logo=cloud&logoColor=white)](https://www.arvancloud.ir/)

---

## 📦 Installation

```bash
git clone https://github.com/BloodMxxn/iscdn.git
cd iscdn
chmod +x iscdn.sh
```

Or install system-wide:

```bash
sudo cp iscdn.sh /usr/local/bin/iscdn
```

---

## 📖 Usage

```bash
./iscdn.sh <IP_ADDRESS>    # Check an IP
./iscdn.sh --refresh, -r   # Update CDN ranges
./iscdn.sh --help, -h      # Show help
```

### Examples

```bash
$ ./iscdn.sh 173.245.48.1
✅ IP 173.245.48.1 belongs to CDN

$ ./iscdn.sh 1.2.3.4
❌ IP 1.2.3.4 does NOT belong to CDN
```

---

## 📝 Requirements

- Bash 4.0+
- curl (for --refresh)

## 🤝 Contributing

Contributions are welcome!

- 🐛 **Report bugs** – Open an issue
- 💡 **Suggest features** – Open an issue
- 🔧 **Submit PRs** – Fork the repo and create a pull request
