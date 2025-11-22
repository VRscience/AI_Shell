# --- TERMINAL AI INSTALLER (Universal Language Support) ---

# 1. Configuration
$AI_Model = "qwen2.5-coder:1.5b"
$ProfilePath = $PROFILE

function Print-Msg ($msg, $color) { Write-Host "$msg" -ForegroundColor $color }

Clear-Host
Print-Msg "🚀 Starting Universal Terminal AI Installation..." "Cyan"
Print-Msg "-------------------------------------------------" "DarkGray"

# 2. Checks
if (-not (Get-Command "ollama" -ErrorAction SilentlyContinue)) {
    Print-Msg "❌ Error: Ollama not found." "Red"; exit
}

Print-Msg "⏳ Checking AI Model ($AI_Model)..." "Cyan"
$models = ollama list
if ($models -notmatch $AI_Model) {
    Print-Msg "⚠️  Downloading model..." "Yellow"
    ollama pull $AI_Model
}
Print-Msg "✅ Model Ready." "Green"

# 3. Payload (The Injection Code)
$Payload = @"

# --- TERMINAL AI START ---
`$AI_Model = "$AI_Model"
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Function 1: ACT (Multilingual Code Generator)
function act {
    if (`$args.Count -eq 0) { Write-Host "⚠️  Missing action."; return }
    `$user_input = `$args -join " "
    Write-Host "🤖 Processing (`$AI_Model)..." -ForegroundColor Cyan
    
    # NEW PROMPT: Language Agnostic
    # We instruct the AI to process ANY language but output ONLY code.
    `$prompt = "You are a Polyglot PowerShell Expert. The user will ask for a command in their preferred language (English, Italian, Spanish, etc.). " +
              "YOUR TASK: Interpret the user intent: '" + `$user_input + "' and output the PowerShell code. " +
              "RULES: 1. Return ONLY the raw code line. 2. NO Markdown. 3. Do NOT wrap code in quotes/pipes. 4. Use -Include for multiple exts."
    
    `$raw_output = ollama run `$AI_Model `$prompt
    
    # Cleanup & Formatting
    if (`$raw_output -is [array]) { `$cmd = `$raw_output -join " " } else { `$cmd = [string]`$raw_output }
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

# Function 2: HTD (Multilingual Explainer)
function htd {
    if (`$args.Count -eq 0) { Write-Host "⚠️  Missing question."; return }
    `$user_input = `$args -join " "
    Write-Host "📚 Searching..." -ForegroundColor Cyan
    
    # NEW PROMPT: Detect Language
    # We instruct the AI to reply IN THE SAME LANGUAGE as the input.
    `$prompt = "You are a PowerShell expert. User Question: '" + `$user_input + "'. " +
              "TASK: Provide 2 options. For each option write: 1) The command. 2) A brief explanation. " +
              "IMPORTANT: Write the explanation IN THE SAME LANGUAGE used by the user in the question."
    
    ollama run `$AI_Model `$prompt
}

# Auto-Startup
Clear-Host
# Greeting is kept generic/English as it's system text, but user can query in any language
Write-Host "`n🤖 Terminal AI Online ($AI_Model)" -ForegroundColor Cyan
Write-Host "------------------------------------------------" -ForegroundColor DarkGray
Write-Host "    🔹 act <text>   -> Generate Code (Any Language)" -ForegroundColor Yellow
Write-Host "    🔹 htd <text>   -> Explain (Same Language)" -ForegroundColor Yellow
Write-Host "------------------------------------------------`n" -ForegroundColor DarkGray
# --- TERMINAL AI END ---
"@

# 4. Installation
Print-Msg "📝 Updating Profile..." "Cyan"
if (-not (Test-Path $ProfilePath)) { New-Item -Type File -Path $ProfilePath -Force | Out-Null }
$BackupName = "$ProfilePath.bak_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
Copy-Item $ProfilePath $BackupName
Add-Content -Path $ProfilePath -Value $Payload

Print-Msg "✅ Universal Support Installed!" "Green"
. $PROFILE