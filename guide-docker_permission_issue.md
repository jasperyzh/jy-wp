You're observing a common issue with Docker containers: file permission mismatches between the host system and container users. Here's why this happens and best practices to address it:
Why Docker Files Have Different Permissions
Container User vs Host User: In WordPress Docker containers, files are typically owned by www-data (UID 33) inside the container. This is the web server user.
Volume Mapping: When we map volumes in docker-compose.yml, Docker preserves file ownership from inside the container. So files created in the container keep their www-data ownership when viewed from the host.
UID Mismatch: The www-data user inside the container (UID 33) is different from your host user matsu, so you don't have write permissions to these files from the host.
Best Practices to Handle This
Option 1: Use Docker commands to modify files (Most Secure)
Apply to functions.ph...
Run
Option 2: Modify container's startup to match UIDs (Best for development teams)
Create a custom Dockerfile:
Apply to functions.ph...
Option 3: Temporarily change permissions of specific directories (Quick solution, but less secure)
Apply to functions.ph...
Run
Option 4: Add your user to the www-data group (Balanced approach)
Apply to functions.ph...
Run
For your immediate situation, let's use Option 1 to copy the functions.php file to the container: