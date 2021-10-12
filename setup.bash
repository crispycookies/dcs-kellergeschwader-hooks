DCSDIR="${USERPROFILE}/Saved Games/DCS.openbeta_server/Scripts"

for f in $(find ./ -type f -name "*.lua"); do
    cp -f "$PWD/$f" "$DCSDIR/$f"
done