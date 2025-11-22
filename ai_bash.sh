#!/bin/bash

# --- CONFIGURATION ---
AI_MODEL="qwen2.5-coder:1.5b"

# Detect which shell profile to use (.zshrc if using Zsh, otherwise .bashrc)
if [ -n "$ZSH_VERSION" ]; then
    PROFILE_FILE="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    PROFILE_FILE="$HOME/.bashrc"
else
    # Fallback
    PROFILE_FILE="$HOME/.bashrc"
fi

echo "Target Profile: $PROFILE_FILE"

# 1. BACKUP EXISTING PROFILE
if [ -f "$PROFILE_FILE" ]; then
    cp "$PROFILE_FILE" "$PROFILE_FILE.bak"
    echo "Existing profile backed up to: $PROFILE_FILE.bak"
else
    touch "$PROFILE_FILE"
    echo "Created new profile file."
fi

# 2. DEFINE THE AI FUNCTIONS (Bash/Zsh syntax)
# We use 'cat <<EOF' to define the block of text to append.
PAYLOAD=$(cat <<EOF

# <--- TERMINAL AI START --->
export AI_MODEL="$AI_MODEL"

# Function: ACT (Generate and Execute)
act() {
    if [ -z "\$1" ]; then
        echo "Usage: act [task]"
        return
    fi
    
    # Join arguments into one string
    user_input="\$*"
    
    echo -e "\033[0;36m[AI] Working...\033[0m"
    
    # Prompt
    prompt="You are a Linux Terminal helper. Convert this request: '\$user_input' into a SINGLE line of Bash code. RULES: 1. No Markdown. 2. No explanations. 3. No delimiters. 4. If listing files, assume current directory."
    
    # Run Ollama
    cmd=\$(ollama run \$AI_MODEL "\$prompt")
    
    # Cleanup Output (remove markdown code blocks, backticks, and whitespace)
    cmd=\$(echo "\$cmd" | sed 's/\`\`\`bash//g' | sed 's/\`\`\`//g' | tr -d '\`' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    
    # Display Command
    echo -e "\033[0;32mCommand: \$cmd\033[0m"
    
    # Ask to Execute
    read -p "Execute? (y/n) " -n 1 -r
    echo    # Move to a new line
    if [[ \$REPLY =~ ^[Yy]$ ]]; then
        eval "\$cmd"
    fi
}

# Function: HTD (How To Do / Explain)
htd() {
    if [ -z "\$1" ]; then
        echo "Usage: htd [question]"
        return
    fi
    
    user_input="\$*"
    echo -e "\033[0;36m[AI] Thinking...\033[0m"
    
    prompt="You are a Linux expert. User question: '\$user_input'. Give 2 concise options with brief explanations."
    
    ollama run \$AI_MODEL "\$prompt"
}

echo -e "\033[0;90mAI Ready. Use: act [task] or htd [question]\033[0m"
# <--- TERMINAL AI END --->
EOF
)

# 3. APPEND TO PROFILE (If not already installed)
if grep -q "TERMINAL AI START" "$PROFILE_FILE"; then
    echo "It seems Terminal AI is already installed in $PROFILE_FILE."
    echo "Skipping append to avoid duplicates."
else
    echo "$PAYLOAD" >> "$PROFILE_FILE"
    echo "SUCCESS! Installation complete."
fi

# 4. RELOAD INSTRUCTIONS
echo -e "\033[0;33mPlease restart your terminal OR run:\033[0m source $PROFILE_FILE"
