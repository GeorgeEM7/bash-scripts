#!/bin/bash

# Default mainRepoPath
mainRepoPath="/home/geoem/George/dev/repos/odoosh"
defaultCommitMessage="Add/Modify"

# Parse flags
while getopts ":os" opt; do
  case ${opt} in
    o )
      mainRepoPath="/home/geoem/George/dev/repos/odoosh"
      ;;
    s )
      mainRepoPath="/home/geoem/George/dev/repos/servers"
      ;;
    \? )
      echo "Invalid option: -$OPTARG" 1>&2
      exit 1
      ;;
    : )
      echo "Invalid option: -$OPTARG requires an argument" 1>&2
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))

# Check if at least three arguments are provided
if [ "$#" -lt 3 ]; then
  echo "Usage: $0 [-o|-s] <path-to-directory> <partial-repo-name> <branch-name> [<commit-message>]"
  exit 1
fi

# Assign arguments to variables
directoryPath=$1
partialRepoName=$2
branchName=$3
commitMessage=${4:-$defaultCommitMessage}

# Find repositories matching the partial name
repoPaths=($(find "$mainRepoPath" -maxdepth 1 -type d -name "*$partialRepoName*" -print))

# Check if multiple repositories were found
if [ ${#repoPaths[@]} -eq 0 ]; then
  echo "No repository found matching partial name '$partialRepoName'. Exiting."
  exit 1
elif [ ${#repoPaths[@]} -gt 1 ]; then
  echo "Multiple repositories found matching '$partialRepoName':"
  for i in "${!repoPaths[@]}"; do
    echo "$((i + 1)). ${repoPaths[$i]}"
  done
  read -p "Select the repository number (1-${#repoPaths[@]}): " repoIndex
  if [ "$repoIndex" -lt 1 ] || [ "$repoIndex" -gt ${#repoPaths[@]} ]; then
    echo "Invalid selection. Exiting."
    exit 1
  fi
  repoPath="${repoPaths[$((repoIndex - 1))]}"
else
  repoPath="${repoPaths[0]}"
fi

# Move to the repository path
cd "$repoPath" || { echo "Failed to navigate to repository path $repoPath. Exiting."; exit 1; }

# Attempt to switch to the specified branch
echo "Attempting to switch to branch '$branchName'"
if git checkout "$branchName"; then
  echo "Switched to branch '$branchName'"
else
  echo "Failed to switch to branch '$branchName'. Pulling latest changes from the default branch."
  git pull

  # Retry switching to the branch after pulling
  if git checkout "$branchName"; then
    echo "Switched to branch '$branchName' after pulling."
  else
    echo "Branch '$branchName' still does not exist locally after pulling. Exiting."
    exit 1
  fi
fi

# Pull the latest changes from the specified branch
echo "Pulling the latest changes from remote branch '$branchName'"
git pull origin "$branchName"

# Check if the directory to copy exists
if [ ! -d "$directoryPath" ]; then
  echo "Directory $directoryPath does not exist. Exiting."
  exit 1
fi

# Path to the target directory within the repo
targetDirPath="$repoPath/$(basename $directoryPath)"

# Remove the old directory if it exists
if [ -d "$targetDirPath" ]; then
  echo "Removing old directory $targetDirPath"
  rm -rf "$targetDirPath"
fi

# Copy the new directory to the repository
echo "Copying new directory to $repoPath"
cp -r "$directoryPath" "$repoPath"

# Add all changes
git add .

# Commit with the provided or default message
git commit -m "$commitMessage"

# Check if commit was successful
if [ $? -ne 0 ]; then
  echo "git commit failed. Exiting."
  exit 1
fi

# Push the changes
git push origin "$branchName"

# Check if push was successful
if [ $? -ne 0 ]; then
  echo "git push failed. Exiting."
  exit 1
fi

echo "Changes successfully pushed to branch '$branchName'."
