#!/usr/bin/bash

# As we did for the create_environement.sh, this will exit immediately if a command exits.
set -e

# First, I prompt the user for the name they used when creating the environment. This is necessary to locate the correct 'submission_reminder_{yourName}' directory.
read -p "Please enter the name you used when creating the application environment (e.g., Hervé): " ENV_USER_NAME

# This assumes this script is run from the same directory where 'create_environment.sh' created the app folder.
MAIN_APP_DIR="submission_reminder_${ENV_USER_NAME}"

# Check if the main application directory exists. If not, inform the user and exit.
if [ ! -d "$MAIN_APP_DIR" ]; then
    echo "Error: The application directory '$MAIN_APP_DIR' was not found."
    echo "Please ensure you run this script from the same location where 'create_environment.sh' created your app."
    exit 1
fi

# The config.env file is inside the 'config' subdirectory within the main app directory.
CONFIG_FILE="${MAIN_APP_DIR}/config/config.env"

# Check if the config.env file actually exists at the constructed path.
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: The configuration file '$CONFIG_FILE' was not found."
    echo "Please ensure the environment was set up correctly by 'create_environment.sh'."
    exit 1
fi

#Prompt for New Assignment Name
read -p "Hello, what is the new assignment name: " ASSIGNMENT_NAME

# --- Update the ASSIGNMENT value in config/config.env ---
# 'sed -i' edits the file in-place.
# '2s' means apply the substitution command to the second line of the file.
# '^ASSIGNMENT=.*' is the regular expression to find:
#   '^' matches the start of the line.
#   'ASSIGNMENT=' matches the literal text "ASSIGNMENT=".
#   '.*' matches any character ('.') zero or more times ('*').
# 'ASSIGNMENT=\"${ASSIGNMENT_NAME}\"' is the replacement text:
#   It sets the line to "ASSIGNMENT=" followed by your new assignment name.
#   Double quotes around '${ASSIGNMENT_NAME}' are important! They ensure that
#   if your assignment name has spaces (e.g., "Lab Report 1"), it's treated
#   as a single value in the config file.
sed -i "2s|^ASSIGNMENT=.*|ASSIGNMENT=\"${ASSIGNMENT_NAME}\"|" "$CONFIG_FILE"

#Another message to confirm 
echo "Success! The 'ASSIGNMENT' in '$CONFIG_FILE' has been updated to: $ASSIGNMENT_NAME"

# --- Run startup.sh ---
# The task requires rerunning startup.sh to check non-submission status with the new assignment.
# We need to change into the main application directory to run startup.sh correctly,
# as startup.sh might rely on being executed from there.
echo "Now running startup.sh to check student submission status for '$ASSIGNMENT_NAME'..."
cd "$MAIN_APP_DIR" && "./startup.sh"

echo "Script finished."
