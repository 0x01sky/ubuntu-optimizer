# Ubuntu Debloating Script
- A Debloating script to make Ubuntu great again by removing snaps, snapd and unwanted telemtry that we never wanted !

### Disclaimer:

- Use with serious caution ! While this script was designed to be safe, removing system packages such as snapd may carries an inherent risk.

  *  **Backup your system and create snapshots:** It is highly recommended to create a system backup or a snapshot (if using a virtual machine) before running this debloater.
  
  *  **Review package lists:** Before running the script or any script on the internet, i strongly advise you to review everything in the script to understand exactly what will be removed.
  
  *  **No guarantees:** I cannot guarantee that removing certain packages won't affect specific functionalities you rely on, especially if you have unique software requirements or custom configurations.
  
  *  **Bloatware is something subjective:** What one user considers "bloatware" another might find it essential for the system to work.


## Installation
- Method 1: (Installing and Running the script directly)
```bash
wget https://raw.githubusercontent.com/0x01sky/ubuntu-optimizer/main/src/debloat.sh
chmod +x debloat.sh
sudo ./debloat.sh  # requires super user priveleges
```
- Method 2:
```bash
git clone https://github.com/0x01sky/ubuntu-optimizer
cd ubuntu-optimizer && chmod +x debloat.sh
sudo ./debloat.sh
```

### Contributing or Reporting Possible Bugs
For any potential issues in the script open an issue !
