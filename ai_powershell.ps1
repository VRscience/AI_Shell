# --- TERMINAL AI INSTALLER (Safe Version) ---
# 1. BACKUP EXISTING PROFILE IF EXISTS
if (Test-Path $PROFILE) {
    $BackupPath = "$PROFILE.bak"
    Copy-Item $PROFILE $BackupPath -Force
    Write-Host "Existing profile backed up to: $BackupPath" -ForegroundColor Gray
} else {
    # Create the file if it doesn't exist so we can write to it
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}

# 2. DEFINE CONTENT (Pure ASCII - No Emojis to prevent errors)
$NewContent = @'
$AI_Model = "qwen2.5-coder:1.5b"

function act {
    param([Parameter(ValueFromRemainingArguments=$true)]$args)
    
    if ($args.Count -eq 0) { Write-Host "Usage: act [task]"; return }
    $user_input = $args -join " "
    
    Write-Host "[AI] Working..." -ForegroundColor Cyan
    
    # Strict Prompt
    $prompt = "You are a PowerShell helper. Convert this request: '" + $user_input + "' into a SINGLE line of PowerShell code. RULES: 1. No Markdown. 2. No explanations. 3. No delimiters. 4. If listing files, assume current directory."
    
    # Run Ollama
    $result = ollama run $AI_Model $prompt
    
    # Cleanup
    if ($result -is [array]) { $cmd = $result -join " " } else { $cmd = [string]$result }
    $cmd = $cmd.Replace('```powershell', '').Replace('```', '').Replace('powershell', '').Trim()
    $cmd = $cmd.Trim('`', '"', "'")
    
    # Output
    Write-Host "Command: $cmd" -ForegroundColor Green
    
    # Execute
    $conf = Read-Host "Execute? (y/n)"
    if ($conf -eq 'y') {
        Invoke-Expression $cmd
    }
}

function htd {
    param([Parameter(ValueFromRemainingArguments=$true)]$args)
    
    if ($args.Count -eq 0) { Write-Host "Usage: htd [question]"; return }
    $user_input = $args -join " "
    
    Write-Host "[AI] Thinking..." -ForegroundColor Cyan
    $prompt = "You are a PowerShell expert. User question: '" + $user_input + "'. Give 2 concise options with brief explanations."
    
    ollama run $AI_Model $prompt
}

Write-Host "AI Ready. Use: act [task] or htd [question]" -ForegroundColor Gray
'@

# 3. WRITE FILE (Enforcing ASCII Encoding)
[System.IO.File]::WriteAllText($PROFILE, $NewContent, [System.Text.Encoding]::ASCII)

Write-Host "SUCCESS! Installation complete." -ForegroundColor Green
Write-Host "Please CLOSE this terminal and open a new one." -ForegroundColor Yellow