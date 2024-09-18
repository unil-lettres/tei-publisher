#!/busybox/sh

# Copy the files from the host autodeploy folder to the exists db autodeploy folder.
# These files are packages that will be automatically installed upon starting existdb server.
if find "/src/autodeploy" -maxdepth 1 -type f ! -name ".*" | read; then
    echo "Copying packages from host to autodeploy..."
    cp -v /src/autodeploy/* /exist/autodeploy
fi

# Start the main process
exec "$@"
