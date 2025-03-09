# Lethal Company Save File Creator

![image](https://github.com/user-attachments/assets/18160bf7-e4f2-4c3e-bbeb-8d1cdbcbbb3b)

Welcome to the Lethal Company Save File Creator! This tool allows fans of the game "Lethal Company" to craft and customize their save files to start their gameplay in any desired configuration. Players can set up custom run variables, manage in-game finances, and tailor available ship items to their preference.

## Features

### Downloading Save Files
- Navigate through a list of pre-configured save files.
- Download desired configurations straight to your system.

### Creating Custom Save Files
Logged-in users can craft custom settings including but not limited to:
- **Run Details**:
  - **Moon**: Specify which moon the ship will start on.
  - **Random Seed**: Define a unique seed for the game’s run.
  - **Deadline Time**: Set the remaining days till the quota deadline (e.g., 3240 for 3 days).
  - **Quotas Passed**: The number of successful quota targets hit.
- **Profit Settings**:
  - **Group Credits**: Current total of credits in the bank.
  - **Profit Quota**: Required credits for the next threshold.
  - **Quota Fulfilled**: Credits obtained towards the current quota.
- **Ship Items**:
  - Customize tools such as lights, shovels, walkie talkies, stun grenades, and more for your in-game use.

### Usage Instructions
1. Choose a save file and click the download button.
2. The file will save typically with a name akin to the save's title.
3. Transfer this file to the game save directory (For Windows: `%USERPROFILE%\AppData\LocalLow\ZeekerssRBLX\Lethal Company`).
4. Replace an existing game file (e.g., `LCSaveFile1`) with your downloaded file.

## Development

The project was originally developed over a weekend as a proof of concept which consisted of several Ruby scripts. Due to positive feedback and potential, it was expanded into a full-fledged Rails application.

### Dependencies

- Rails 7
- Ruby 3.2.1
- PostgreSQL

### Docker image

Image is published on build time and tagged, these can be found at [GitHub Packages](https://github.com/lasagnapizza/lethal-company-save-editor/pkgs/container/lethal-company-save-editor).

```shell
docker pull ghcr.io/lasagnapizza/lethal-company-save-editor:latest
```

### To install

Clone this respository:

```shell
git clone https://github.com/lasagnapizza/lethal-company-save-editor.git
```

Assuming you have Ruby and PostgreSQL up and running.

Install dependencies:

```shell
bundle install
```

Setup the database:

```
rails db:prepare
```

Run the web server:

```shell
rails s
```

Visit the app at http://localhost:3000


## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
