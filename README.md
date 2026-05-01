# terminal-welcome

Your name in big letters, your face in dots, live weather — every time you open a terminal.

![terminal-welcome preview](https://raw.githubusercontent.com/ell-0/terminal-welcome/main/docs/preview-terminal.png)

<br>

## Install

Paste this into your terminal and press Enter:


```bash
git clone https://github.com/ell-0/terminal-welcome.git && cd terminal-welcome && bash install.sh
```

![what you get](https://raw.githubusercontent.com/ell-0/terminal-welcome/main/docs/wyg-prev-terminal.png)

<br>

## During install you will be asked

- **Your name** — shown in large letters at the top
- **Your city** — used to fetch live weather (e.g. London, Tokyo, New York)
- **Temperature unit** — Celsius or Fahrenheit
- **Your photo** — drag and drop any photo into the terminal window, or press Enter to use the default
- **Portrait color** — the color of your photo on the left
- **Text color** — the color of your name heading

<br>

## After install

Open a new terminal tab. That's it.

<br>

---

<br>

## Want to change something?

| What | Command |
|------|---------|
| Change your photo | `bash ~/.config/terminal-welcome/install.sh --change-photo` |
| Change name, city, or colors | `nano ~/.config/terminal-welcome/welcome.sh` |
| Uninstall completely | `bash ~/.config/terminal-welcome/install.sh --uninstall` |

<br>

## Color options

Enter the code when the installer asks, or paste it into your config file next to `PORTRAIT_COLOR` or `ACCENT_COLOR`.

| Color | Code |
|-------|------|
| White | `97` |
| Pink *(default)* | `38;5;218` |
| Cyan | `96` |
| Green | `92` |
| Yellow | `33` |
| Orange | `38;5;208` |
| Purple | `38;5;183` |

<br>

## Troubleshooting

**The dashboard doesn't show up when I open a new tab**

Close the terminal completely and reopen it. If it still doesn't appear, run `source ~/.zshrc` in your terminal and open a new tab.

**Weather shows — instead of a temperature**

Check your city name in the config file: `nano ~/.config/terminal-welcome/welcome.sh`. The city must match what [wttr.in](https://wttr.in) recognizes — try typing the city name there to check. Multi-word cities work fine (e.g. `New York`).

**I see "figlet: command not found"**

Run `brew install figlet` in your terminal, then open a new tab.

**My photo didn't convert or looks blank**

Use a JPEG or PNG file. Very small images may not convert well — a portrait photo at least 400px wide gives the best result. You can swap your photo any time by running `bash ~/.config/terminal-welcome/install.sh --change-photo`.

<br>

---

MIT License
