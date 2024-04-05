#!/bin/bash

# Check if mediainfo is installed
if ! command -v mediainfo &> /dev/null; then
    echo "Error: mediainfo is not installed. Please install it first."
    exit 1
fi

    # Define the supports function
    viewer_video_mediainfo_supports() {
        # Check if the file is a video file
        case "$1" in
            *.mkv|*.mp4|*.avi|*.mov)
                return 0 # Supported
                ;;
            *)
                return 1 # Not supported
                ;;
        esac
    }

    # Define the process function
    viewer_video_mediainfo_process() {
        # Output header
        batpipe_header "Media Information: $2"

        # Run mediainfo and output the result
        mediainfo "$1"

        # Output separator
        batpipe_subheader
    }

# Append the viewer's name to $BATPIPE_VIEWERS array
BATPIPE_VIEWERS+=('video_mediainfo')
