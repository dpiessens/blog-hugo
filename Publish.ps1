Param ([string]$message = $null)

If ([string]::IsNullOrEmpty($message)) {
    $message = "Rebuilding site $([DateTime]::Now)"
}

Write-Host 'Deploying site to public...'
Write-Host "Commit Message: $message"

# Build the project.
& hugo # if using a theme, replace by `hugo -t <yourtheme>`

# Go To Public folder
pushd public
# Add changes to git.
git add -A

git commit -m "$message"

# Push source and build repos.
git push origin master

# Come Back
popd