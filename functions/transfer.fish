function transfer -d "Upload file(s) and get a shareable link to them"
  if ! test -n "$argv" # not empty
    echo "Usage: " (status --current-filename) "<file(s)-to-share>"
    return 1
  end
  for arg in $argv
      if ! test -e $arg; and ! test -d $arg
          echo "File or directory doesn't exist [$arg]"
          return 1
      end
  end

  if test (count $argv) -eq "1"; and ! test -d $argv[1]
      set file_to_send $argv[1]
  else
      echo "Creating archive with [" (count $argv) "] files/directories]"
      set file_to_send /tmp/to_send.tar
      tar cf $file_to_send $argv
  end

  set tmpfile (mktemp -t transferXXX);

  if tty -s
      set basefile (basename "$file_to_send" | sed -e 's/[^a-zA-Z0-9._-]/-/g')
      curl --progress-bar --upload-file "$file_to_send" "https://transfer.sh/$basefile" >> $tmpfile
  else
      curl --progress-bar --upload-file "-" "https://transfer.sh/$file_to_send" >> $tmpfile
  end

  command cat $tmpfile
  rm -f $tmpfile
end

