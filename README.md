# Post Fedora Script 42

Post Fedora Script 42 is a shell script designed to automate the installation of essential applications and tools on a fresh Fedora 42 installation. It streamlines the setup process, saving time and ensuring consistency.

⚠️ **Use at your own risk.** This script is provided as-is, with no warranties or guarantees. See the [Disclaimer](#disclaimer) below for full details.

---

## Features

- **Automated Installation** – Installs commonly used packages and tools.
- **Flathub Integration** – Adds the Flathub repository for broader application availability.
- **Manual Instructions** – Provides optional post-install notes and recommendations.

---

## Prerequisites

- Fedora 42 (fresh installation recommended)
- Active internet connection
- Sudo privileges

---
## Disclaimer

This project is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose, and noninfringement. In no event shall the author(s) be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from or in connection with the script or the use or other dealings in the software.

This script is a personal project and is **not affiliated with or endorsed by the Fedora Project**

---

## getting the code

1. **Clone the Repository**
   ```bash
   git clone https://github.com/darrenoshan/pfs_42.git && \
   cd pfs_42
   ```

2. **Review the Script**
   It's highly recommended to inspect the script before running it:
   ```bash
   less run.sh
   ```


## If you accept the [Disclaimer](#disclaimer)

   ```bash
    sudo bash <(curl -Ls https://raw.githubusercontent.com/darrenoshan/pfs_42/main/run.sh)
   ```


## Contributing

Pull requests are welcome. If you have suggestions for improvements or additional features, feel free to open an issue or contribute via fork and PR.

---

## License

This project is licensed under the [MIT License](LICENSE).
