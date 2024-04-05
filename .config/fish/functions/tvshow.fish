#!/usr/bin/env fish

function tvshow --description "Parse tvshows location and start mpv" \
    --argument-names location

    set i 1
    if test -z "$location"
        set location "/run/media/narnaud/disk/TV Shows/"
    end

    cd $location
    set folders */
    for folder in $folders
        set total (count $folder/*/*.nfo)
        set watched (count (cat $folder/*/*.nfo | grep "<watched>true"))
        echo "$i - $watched/$total - $folder"
        set i (math $i + 1)
    end

    set choice (read)
    if test -n "$choice"
      mpv $folders[$choice]/**/*.{mkv,mp4,avi}
    end
    cd -
end
