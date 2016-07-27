# Enter a fixed directory

FIXED_DIRECTORY=/mnt/sda9/icenowy/grsec-real-build

if [ "$NO_ENTER_FIXED_DIR" != "1" ]; then
	mkdir -p "$FIXED_DIRECTORY"
	cd "$FIXED_DIRECTORY"
fi
