# 🧠 Shell AI Assistant

In this repo you will find different script to turn your shell into an intelligent assistant using **Ollama** and local LLMs. This script integrates AI directly into PowerShell, enabling you to generate commands (`act`) or request explanations (`htd`) without leaving the command line.

# AI_Powershell

## ✨ Features

* **`act <request>`**: Translates natural language into PowerShell commands and executes them upon confirmation.
    * *Example:* `act list all PDF files in recursive folders`
* **`htd <question>`** (How To Do): Asks the AI for explanations and examples without executing code.
    * *Example:* `htd how do I check my IP address`
* **Zero Latency**: Uses the lightweight but powerful `qwen2.5-coder:1.5b` model locally.
* **Safe Execution**: Commands are sanitized (stripped of markdown/formatting) and require user confirmation (y/n) before running.

## 📋 Prerequisites

1.  **Install Ollama**: Download and install it from [ollama.com](https://ollama.com).
2.  **PowerShell**: Works with standard Windows PowerShell or PowerShell Core (pwsh).

## 🚀 Installation

1.  Download the `ai_powershell.ps1` script from this repository.
2.  Open a PowerShell terminal in the folder where you downloaded the file.
3.  Run the installation script (alternatively use explorer, navigate to the folder where the file was downloaded, right click and select "run with Powershell"):

```powershell

.\ai_powershell.ps1
```

‼️NB:
If you see an error regarding "Execution Policy", run this command instead to bypass the restriction temporarily:

```powershell
PowerShell -ExecutionPolicy Bypass -File .\ai_powershell.ps1
```

The script will automatically:

Check if Ollama is installed.

Download the required AI model (qwen2.5-coder:1.5b) if missing.

Backup your existing PowerShell profile.

Inject the AI functions into your profile.

🎮 Usage
Once installed, simply open a new terminal window.

Generate & Execute Commands
Use (`act`) to perform tasks quickly.

```powershell
act find all files larger than 1GB in D:
```
Output:
```
💡 Suggested Command:
Get-ChildItem D:\ -Recurse -File | Where-Object { $_.Length -gt 1GB }

Execute? (y/n)
```
Ask for Help
Use htd to learn how to do something:

```powershell
htd to kill a process by name
```

🛠️ Troubleshooting
"Ollama not found": Ensure Ollama is running in the background (look for the llama icon in your system tray).

Syntax Errors: If the AI generates bad code, try being more specific in your request.

Encoding Issues: The script automatically sets the output to UTF-8 to handle emojis and special characters correctly.

