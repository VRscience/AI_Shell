# --- TERMINAL AI INSTALLER (Windows PowerShell) ---

# 1. Configuration
$AI_Model = "qwen2.5-coder:1.5b"
$ProfilePath = $PROFILE

# Helper function for colored output
function Print-Msg ($msg, $color) { Write-Host "$msg" -ForegroundColor $color }

Clear-Host
Print-Msg "🚀 Starting Terminal AI Installation..." "Cyan"
Print-Msg "---------------------------------------" "DarkGray"

# 2. Prerequisite Check: Ollama
if (-not (Get-Command "ollama" -ErrorAction SilentlyContinue)) {
    Print-Msg "❌ Error: Ollama is not installed." "Red"
    Print-Msg "👉 Please download it first from: https://ollama.com" "Yellow"
    exit
}
Print-Msg "✅ Ollama detected." "Green"

# 3. AI Model Check
Print-Msg "⏳ Checking AI Model ($AI_Model)..." "Cyan"
$models = ollama list
if ($models -notmatch $AI_Model) {
    Print-Msg "⚠️  Model not found. Downloading (this may take a few minutes)..." "Yellow"
    ollama pull $AI_Model
    if ($LASTEXITCODE -ne 0) {
        Print-Msg "❌ Error downloading the model. Check your internet connection." "Red"
        exit
    }
}
Print-Msg "✅ Model $AI_Model is ready." "Green"

# 4. Preparing the Payload (The code to inject)
$Payload = @"

# --- TERMINAL AI START ---
# AI Configuration
`$AI_Model = "$AI_Model"
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Function 1: ACT (Generate & Execute)
function act {
    if (`$args.Count -eq 0) {
        Write-Host "⚠️  Missing action." -ForegroundColor Yellow
        return
    }
    `$user_input = `$args -join " "
    Write-Host "🤖 Processing with `$AI_Model..." -ForegroundColor Cyan
    
    # Strict Prompt for Code Generation
    `$prompt = "You are a PowerShell Expert. The user wants: " + `$user_input + ". RULES: 1. Return ONLY the raw code line. NO Markdown. NO explanations. 2. Do NOT wrap code in quotes or pipes. 3. Use -Include for multiple extensions. 4. Add -ErrorAction SilentlyContinue."
    
    `$raw_output = ollama run `$AI_Model `$prompt
    
    # Convert Array to String if necessary
    if (`$raw_output -is [array]) { `$cmd = `$raw_output -join " " } else { `$cmd = [string]`$raw_output }

    # Aggressive Cleanup (Remove Markdown, 'powershell' text, pipes, backticks)
    `$cmd = `$cmd.Replace('```powershell', '').Replace('```', '').Replace('powershell', '')
    `$cmd = `$cmd.Trim(' ', '``', '|', '"', "'")
    `$cmd = `$cmd -split "`n" | Select-Object -First 1

    if ([string]::IsNullOrWhiteSpace(`$cmd)) { Write-Host "❌ Error: AI returned empty output." -ForegroundColor Red; return }

    Write-Host "`n💡 Suggested Command:" -ForegroundColor Green
    Write-Host `$cmd -ForegroundColor White
    
    if (Read-Host "`nExecute? (y/n)" -eq 'y') { 
        try { Invoke-Expression `$cmd } catch { Write-Host "❌ Failed: `$_" -ForegroundColor Red }
    }
}

# Function 2: HTD (How To Do - Explain)
function htd {
    if (`$args.Count -eq 0) { Write-Host "⚠️  Missing question."; return }
    `$user_input = `$args -join " "
    Write-Host "📚 Searching..." -ForegroundColor Cyan
    `$prompt = "You are a PowerShell expert. User asks: " + `$user_input + ". Provide 2 options with brief English explanation."
    ollama run `$AI_Model `$prompt
}

# Auto-Startup: Greeting and Menu
Clear-Host
`$greeting = ollama run `$AI_Model "Greet user `$env:USERNAME in English. Professional, concise (max 1 sentence). No markdown."
if (`$greeting -is [array]) { `$greeting = `$greeting -join " " }

Write-Host "`n`$greeting" -ForegroundColor Cyan
Write-Host "------------------------------------------------" -ForegroundColor DarkGray
Write-Host " 🧠 Active Model: `$AI_Model" -ForegroundColor Magenta
Write-Host "    🔹 act <action> -> Generate & Execute" -ForegroundColor Yellow
Write-Host "    🔹 htd <ask>    -> Explain how-to" -ForegroundColor Yellow
Write-Host "------------------------------------------------`n" -ForegroundColor DarkGray
# --- TERMINAL AI END ---
"@

# 5. Injecting into Profile
Print-Msg "📝 Updating PowerShell Profile..." "Cyan"

# Create profile if it doesn't exist
if (-not (Test-Path $ProfilePath)) {
    New-Item -Type File -Path $ProfilePath -Force | Out-Null
}

# Backup existing profile
$BackupName = "$ProfilePath.bak_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
Copy-Item $ProfilePath $BackupName
Print-Msg "📦 Backup created ($BackupName)" "Gray"

# Append the payload
Add-Content -Path $ProfilePath -Value $Payload

Print-Msg "✅ Installation complete!" "Green"
Print-Msg "🔄 Reloading profile now..." "Cyan"

# Reload Profile
. $PROFILE