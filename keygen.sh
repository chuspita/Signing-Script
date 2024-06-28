#!/bin/bash

# Define the subject line
subject='/C=US/ST=California/L=Mountain View/O=Android/OU=Android/CN=Android/emailAddress=android@android.com'

# Print the subject line
echo "Using Subject Line:"
echo "$subject"

# Clear the terminal
clear

# Remove existing Android certs if they exist
if [ -d "$HOME/.android-certs" ]; then
    rm -rf "$HOME/.android-certs"
    echo "Old Android certificates removed."
fi

# Create keys directory
mkdir -p "$HOME/.android-certs"

# Create keys
echo "Press ENTER TWICE to skip password (about 10-15 enter hits total). Cannot use a password for inline signing!"
for x in bluetooth media networkstack nfc platform releasekey sdk_sandbox shared testkey verifiedboot; do 
    ./development/tools/make_key "$HOME/.android-certs/$x" "$subject"
    if [ $? -ne 0 ]; then
        echo "Error creating key for $x"
    fi
done

# Create keys.mk file
cat <<EOF > "$HOME/.android-certs/keys.mk"
PRODUCT_DEFAULT_DEV_CERTIFICATE := $HOME/.android-certs/releasekey
EOF

# Create BUILD.bazel file
cat <<EOF > "$HOME/.android-certs/BUILD.bazel"
filegroup(
    name = "android_certificate_directory",
    srcs = glob([
        "*.pk8",
        "*.pem",
    ]),
    visibility = ["//visibility:public"],
)
EOF

echo "Done! Now build as usual. If builds aren't being signed, add '-include $HOME/.android-certs/keys.mk' to your device mk file"
echo "Make copies of your ~/.android-certs folder as it contains your keys!"
sleep 3
