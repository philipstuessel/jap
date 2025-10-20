<p align="center">
<img src="https://japzsh.com/plugin/images/jap-logo.png" width="25%" />
</p>

# JAP – Modular Terminal Automation Framework

<p align="center">
  <a href="https://japzsh.com/docs">
    <img src="https://img.shields.io/badge/📖%20Docs-japzsh.com/docs-blue?style=for-the-badge" alt="Docs">
  </a>
  <a href="https://japzsh.com/plugins/">
    <img src="https://img.shields.io/badge/🌐%20Plugins-japzsh.com/plugins-green?style=for-the-badge" alt="Plugins">
  </a>
  <a href="https://github.com/topics/japzsh">
    <img src="https://img.shields.io/badge/💻%20GitHub%20Topic-japzsh-blue?style=for-the-badge" alt="GitHub Topic">
  </a>
</p>

JAP is a modular terminal framework that was created because I needed a flexible and expandable system for my own workflow.
The goal was to automate recurring tasks, standardize the working environment, and at the same time keep it open for individual extensions.

## Motivation
I created JAP because no existing tool offered me the freedom and structure I wanted. \
I wanted a terminal plugin system that:
- works according to my ideas,
- is easy to expand,
- speeds up my daily workflow, and
- runs smoothly both locally and on servers (Linux).

Over time, more and more features and small automations were added.
At some point, I had to decide: Do I turn JAP into a large, monolithic tool - or do I break it down into modular components? \
I opted for the modular approach.

## Installation:

```shell
cd ~ && zsh -c "$(curl -fsSL https://raw.githubusercontent.com/philipstuessel/jap/main/install.zsh)"
```
</br>

| Method    | Command                                                                                           |
| :-------- | :------------------------------------------------------------------------------------------------ |
| **curl**  | `zsh -c "$(curl -fsSL https://raw.githubusercontent.com/philipstuessel/jap/main/install.zsh)"` |
| **wget**  | `zsh -c "$(wget -O- https://raw.githubusercontent.com/philipstuessel/jap/main/install.zsh)"`   |
| **fetch** | `zsh -c "$(fetch -o -https://raw.githubusercontent.com/philipstuessel/jap/main/install.zsh)"` |

</br>

## Usage
After installation, JAP can be used directly via the terminal:
```shell
jap <command>
```

## help me:
```shell
jap help
```
list all commands
