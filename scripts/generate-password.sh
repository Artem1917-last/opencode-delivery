#!/bin/bash
# ===========================================
# OpenCode Delivery — Password Generator
# Generates 14-char passwords for Basic Auth
# ===========================================

# Generate 14-char password using openssl
# Method: rand base64, remove special chars, truncate
generate_password() {
    openssl rand -base64 18 | tr -d '/+=' | head -c 14
}

# If argument provided, use it as username and generate password
if [ -n "$1" ]; then
    USERNAME="$1"
    PASSWORD=$(generate_password)
    echo "Username: $USERNAME"
    echo "Password: $PASSWORD"
    echo ""
    echo "HTPasswd format:"
    echo "${USERNAME}:{SHA}$(echo -n "$PASSWORD" | openssl dgst -sha1 -binary | openssl enc -base64)"
else
    # Just generate and display a password
    PASSWORD=$(generate_password)
    echo "$PASSWORD"
fi