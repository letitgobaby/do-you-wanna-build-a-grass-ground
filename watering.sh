#!/bin/bash

# Initialize variables
COMMIT_FILE="commit_history.txt"
START_DATE="2020-01-01"
END_DATE=$(date +"%Y-%m-%d")



# Get terminal width
term_width=$(tput cols)

# Function to print centered text
print_centered() {
    text="$1"
    text_length=${#text}
    padding=$(( (term_width - text_length) / 2 ))
    printf "%*s%s%*s\n" $padding "" "$text" $padding ""
}

echo ""
print_centered "══════════════════════════════════════════════════════════════════════════════════════════════"
echo ""
print_centered "                    WARNING: PLEASE READ THE FOLLOWING!                      "
echo ""
print_centered "══════════════════════════════════════════════════════════════════════════════════════════════"
echo ""
print_centered "WARNING! This operation is irreversible. Please be sure you understand the   "
print_centered "This script creates fake commits in a Git repository.                       "
print_centered "Warning: This script modifies commit dates and force-pushes to the remote repository. "
print_centered "This action could cause history conflicts in collaborative projects, so caution is advised. "
echo ""
print_centered "It is strongly recommended to run this in a new repository."
echo ""
echo ""
print_centered "     Are you sure you want to continue? (Y : GoGetEmTiger, N : whatelse)     "
echo ""
print_centered "══════════════════════════════════════════════════════════════════════════════════════════════"



# Input 
read -r user_input

# Check user input
if [[ "$user_input" != "GoGetEmTiger" && "$user_input" != "GoGetEmTiger" ]]; then
    echo "Operation cancelled. If you want to proceed, please type 'GoGetEmTiger'."
    exit 1
fi


# Check if gshuf is installed
if ! command -v gshuf &> /dev/null; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "Installing coreutils..."
        brew install coreutils
        if [ $? -ne 0 ]; then
            echo "Failed to install coreutils. Please install the coreutils package manually."
            exit 1
        fi
    else
        echo "gshuf is not installed. Please install the coreutils package."
        exit 1
    fi
fi

# Validate the start date, if provided
if [ -z "$START_DATE" ]; then
    echo "No start date provided. Please set the START_DATE variable."
    exit 1
fi





# 1. Check if the current directory is a Git repository
if [ ! -d .git ]; then
    echo "This directory is not a Git repository. Please run this script in a Git repository."
    exit 1
fi

# 2. Check if the commit history file exists
has_commit_on_date() {
    local date="$1"
    git log --since="$date 00:00" --until="$date 23:59" --pretty=format:"%H" | grep -q .
}

# 3. Generate fake commits
generate_commits_for_day() {
    local current_date="$1"
    local day_of_week=$(date -j -f "%Y-%m-%d" "$current_date" +%u)
    if [ $? -ne 0 ]; then
        echo "Failed to get the day of the week for $current_date"
        exit 1
    fi
    local commit_count

    if [[ "$day_of_week" -gt 5 ]]; then
        commit_count=$((RANDOM % 3 + 3))  # 3~5
    else
        commit_count=$((RANDOM % 3 + 2))  # 2~4
    fi

    for ((i = 1; i <= commit_count; i++)); do
        generate_commit "$current_date"
    done
}

generate_commit() {
    local current_date="$1"
    local commit_message="FAKE COMMIT"
    local random_hour=$((RANDOM % 23))
    local random_minute=$((RANDOM % 59))
    local random_second=$((RANDOM % 59))
    local commit_time="$current_date $random_hour:$random_minute:$random_second"

    echo "[$current_date] $commit_message" >> $COMMIT_FILE
    git add $COMMIT_FILE
    GIT_AUTHOR_DATE="$commit_time" GIT_COMMITTER_DATE="$commit_time" git commit -m "$commit_message"
    if [ $? -ne 0 ]; then
        echo "Failed to create a commit on $commit_time"
        exit 1
    fi
}

current_date="$START_DATE"
while [[ "$current_date" < "$END_DATE" ]]; do
    if ! has_commit_on_date "$current_date"; then
        generate_commits_for_day "$current_date"
    fi
    current_date=$(date -j -v+1d -f "%Y-%m-%d" "$current_date" +"%Y-%m-%d")
    if [ $? -ne 0 ]; then
        echo "Failed to increment the date: $current_date"
        exit 1
    fi
done

# 4. Push the changes to the remote repository
if git remote | grep origin; then
    echo "A remote repository named 'origin' is found."
else
    echo "A remote repository named 'origin' is not found. Please add a remote repository named 'origin'."
    exit 1
fi

git push -u origin main
if [ $? -ne 0 ]; then
    echo "Failed to push the changes to the remote repository."
    exit 1
fi