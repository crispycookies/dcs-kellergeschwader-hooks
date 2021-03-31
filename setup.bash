DCSDIR="${USERPROFILE}/Saved Games/DCS.openbeta/Scripts"

for f in $(find ./ -type f -name "*.lua"); do
    cp -f "$PWD/$f" "$DCSDIR/$f"
done