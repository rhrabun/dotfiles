
backup() {
    notes_dir="$HOME/Library/Group Containers/group.com.apple.notes"
    backup_dir="$HOME/Documents/iNotesBackup/$(date +%F)/"
    if [ -d $backup_dir ]; then
      echo "Directory $backup_dir already exists. Exiting"
      exit 1
    fi

    mkdir -p $backup_dir
    cp -r "$notes_dir" "$backup_dir"
}

backup