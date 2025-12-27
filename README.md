# TeleDocker 🐳 [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![Status: Beta](https://img.shields.io/badge/Status-In_Development-orange?style=for-the-badge&logo=github)

![Version: 0.1.0-dev](https://img.shields.io/badge/Version-0.1.0_dev-blue?style=for-the-badge)

## The "It Works Everywhere" solution for Telegram Bots.

### Have you ever faced the "It works on my machine!" problem? You build a Telegram bot, and it runs perfectly, but when you move it to a server or another computer, everything breaks.
### TeleDocker solves this by providing a ready-to-use, lightweight Docker container specifically tailored for Python Telegram bots. No deep Docker knowledge required!
## ✨ Features

- ***Lightweight*** : Based on Debian 12 Slim to ensure minimal resource usage.

- ***Beginner Friendly*** : No need to write or understand complex Dockerfiles.

- ***Live Data Sync*** : A dedicated data directory for databases or persistent logs.

- ***Automatic Setup*** : A simple script builds the container and drops you directly into a root terminal.

## 📂 Project Structure

Place your project files in the root directory. Important: Do not modify the files inside the docker/ folder.
Plaintext

    TeleDocker/
    ├── data/               <-- 💾 Put your databases (SQLite, etc.) or persistent files here
    ├── docker/             <-- 🛠 Internal container files (Do not change)
    │    ├── run.sh         <-- The execution script
    │    └── Dockerfile     <-- The magic behind the container
    ├── .dockerignore       <-- Docker configuration
    └── (Your Files)        <-- 🐍 Put your bot files here (e.g., main.py, requirements.txt)

!WARNING Important: Do not change ***.dockerignore*** and any files inside the ***docker/*** folder. You should only add your own folders and files in the Root of the project or inside the data folder.

# 🚀 Getting Started
## 1. Installation

- #### Download ***TeleDocker.zip*** from the Releases page and extract it. You can rename the TeleDocker folder to anything you like.

## 2. Add Your Code

- #### Copy your bot files into the root directory (or any new folder you create).

- #### Move your database files into the data folder.

- #### Note: Update your code paths if necessary to match the new structure.

## 3. Run the Container

### Open your terminal in the project directory and run the following commands:

- #### Give execution permission:

```Bash
chmod +x ./docker/run.sh
```

- #### Run the script:

```Bash
./docker/run.sh
```

- #### The script will automatically build the image and open a root command line inside the container. Inside the container, your files are located at /project.
## 🛠 Usage inside the Container

### 🔄 File Synchronization Logic

#### TeleDocker handles your files in two distinct ways to balance performance and flexibility:

- #### Project Directory (/project/): All files and folders added to the root of TeleDocker are copied into the container.

    **Note**: If you edit these files while the container is running, changes will not be reflected until the container is restarted.

- #### Data Directory (/project/data/): This folder is mounted directly into the containe (./data is mounted to /project/data).

    **Live Sync**: Any changes made to files inside this folder (like SQLite databases or logs) are reflected instantly both inside and outside the container without needing a restart.

#### Once the terminal opens, you are inside the Debian environment. You can run your bot as usual:

```Bash
python3 your_bot_script.py
```

#### Any changes made to the data folder on your host machine will be immediately reflected inside the container.

<!-- # 🚀 Coming Soon (next version)

- #### ***settings.json*** file to easily customize container settings.

- #### Ability to ***mount custom folders*** using settings.json. -->


## 🗺️ Roadmap
- #### Support for `settings.json` for easy configuration.
- #### Custom volume mounting via settings.
- #### Auto-restart policy for bots.
- #### Support for other languages such as php, node.js and C++ (using g++ compiler)

<br>

# 👤 Developer

### Erfan Farizad

<!-- [![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](linkedin_link) -->
[![Twitter](https://img.shields.io/badge/follow-%23000000?style=for-the-badge&logo=x&logoColor=white)](https://x.com/ErfanFa23)
[![Telegram](https://img.shields.io/badge/Telegram-26A5E4?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/erfan_farizad_contact_bot)
[![Email](https://img.shields.io/badge/Email-D14836?style=for-the-badge&logo=gmail&logoColor=white)](mailto:erfanfarizad@gmail.com)

<br>

# 📝 License

### This project is licensed under the MIT License - see the LICENSE file for details.