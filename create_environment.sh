#!/usr/bin/bash
#In order to cancel/or exit the script when an error is entered, let's use the set command. 

set -e 

#Here I create a variable in which the name of the user is going to be stored by prompting the user to enter his/her name.
#Then this variable will be used to name the folder where tools for the app to work will be located! 

read -p "Hello, enter your name please " NAME

mkdir submission_reminder_$NAME

#Now , I am creating the different component(folders) of the app, and coping each main files into their correspondant folders. 

mkdir submission_reminder_$NAME/app
mkdir submission_reminder_$NAME/modules
mkdir submission_reminder_$NAME/assets
mkdir submission_reminder_$NAME/config

#Coping files is actually not the best way of doing this, since it copies files that are locally located which will not be the case in someone's laptop! 
#Instead, lets create this file directly inside this script!

cd submission_reminder_$NAME

#Populating "reminder.sh"

cat << 'EOF_REMINDER' > app/reminder.sh
#!/usr/bin/bash
echo "This is the reminder app running"
# Source environment variables and helper functions
source ./config/config.env
source ./modules/functions.sh
# Path to the submissions file
submissions_file="./assets/submissions.txt"
# Print remaining time and run the reminder function
echo "Assignment: $ASSIGNMENT"
echo "Days remaining to submit: $DAYS_REMAINING days"
echo "--------------------------------------------"
check_submissions $submissions_file
EOF_REMINDER

#Populating "functions.sh"

cat << 'EQF_FUNCTIONS' > modules/functions.sh
#!/usr/bin/bash
# Function to read submissions file and output students who have not submitted
function check_submissions {
    local submissions_file=$1
    echo "Checking submissions in $submissions_file"

    # Skip the header and iterate through the lines
    while IFS=, read -r student assignment status; do
        # Remove leading and trailing whitespace
        student=$(echo "$student" | xargs)
        assignment=$(echo "$assignment" | xargs)
        status=$(echo "$status" | xargs)

        # Check if assignment matches and status is 'not submitted'
        if [[ "$assignment" == "$ASSIGNMENT" && "$status" == "not submitted" ]]; then
            echo "Reminder: $student has not submitted the $ASSIGNMENT assignment!"
        fi
    done < <(tail -n +2 "$submissions_file") # Skip the header
}

EQF_FUNCTIONS


#Populating "submissions.txt"

cat << EQF_SUBMISSIONS > assets/submissions.txt
student, assignment, submission status
Chinemerem, Shell Navigation, not submitted
Chiagoziem, Git, submitted
Divine, Shell Navigation, not submitted
Anissa, Shell Basics, submitted
EQF_SUBMISSIONS

#Populating "config.env"

cat << EQF_CONFIG > config/config.env
# This is the config file
ASSIGNMENT="Shell Navigation"
DAYS_REMAINING=2
EQF_CONFIG

cd ..

#Here I am appending 10+ more students records to submissions.txt so that we can test the application better! 
echo "Ayo, Git, submitted" >> submission_reminder_$NAME/assets/submissions.txt
echo "Aseye, Shell Basics, not submitted" >> submission_reminder_$NAME/assets/submissions.txt
echo "David, Shell Navigation, not submitted" >> submission_reminder_$NAME/assets/submissions.txt
echo "Annick, Git, submitted" >> submission_reminder_$NAME/assets/submissions.txt
echo "Teejay, Shell Basics, not submitted" >> submission_reminder_$NAME/assets/submissions.txt
echo "Grace, Emacs, not submitted" >> submission_reminder_$NAME/assets/submissions.txt
echo "Chisom, vi, submitted" >> submission_reminder_$NAME/assets/submissions.txt
echo "Annet, vi, submitted" >> submission_reminder_$NAME/assets/submissions.txt
echo "Bekey, Git, not submitted" >> submission_reminder_$NAME/assets/submissions.txt
echo "Alvin, Shell Navigation, submitted" >> submission_reminder_$NAME/assets/submissions.txt
echo "Theodora, Shell Basics, not submitted" >> submission_reminder_$NAME/assets/submissions.txt
echo "Franck, Shell Navigation, not submitted" >> submission_reminder_$NAME/assets/submissions.txt
echo "Ayobamidele, Git, not submitted" >> submission_reminder_$NAME/assets/submissions.txt

#now we are implementing the startup.script. This script just starts up the reminder app when executed
cat <<EOF > submission_reminder_$NAME/startup.sh
#!/bin/bash
#We are using "source" for config.env and functions.sh becouse it reads and executes the content of a file in the current shell session.
source ./config/config.env
source ./modules/functions.sh
#And here we use "bash" since we want it to run in a new subshell.
bash ./app/reminder.sh
EOF

#To make all the files executable, we are using this command:
find submission_reminder_$NAME -type f -name "*.sh" -exec chmod +x {} \;

