readonly SCRIPT_DIR="$HOME/linux_p2"
readonly BACKUP_DIR="$SCRIPT_DIR/backup"
readonly OLD_BACKUP_DIR="$SCRIPT_DIR/old_backup"
readonly LOG_DIR="$SCRIPT_DIR/log"
readonly LOG_FILE="$LOG_DIR/backup.log"
readonly ERROR_LOG_FILE="$LOG_DIR/err_backup.log"
readonly CURRENT_DATE=$(date +%Y-%m-%d)
readonly TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')


log_info() {
    echo "[$TIMESTAMP] INFO: $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo "[$TIMESTAMP] ERROR: $1" | tee -a "$ERROR_LOG_FILE" >&2
}

ensure_directories() {
    local dirs=("$BACKUP_DIR" "$OLD_BACKUP_DIR" "$LOG_DIR")
    for dir in "${dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir" || {
                log_error "Failed to create directory: $dir"
                exit 1
            }
            log_info "Directory created: $dir"
        fi
    done
}

archive_files() {
    log_info "Starting file archiving process"
    
    # Check if source directory exists
    if [[ ! -d "$SCRIPT_DIR" ]]; then
        log_error "Source directory does not exist: $SCRIPT_DIR"
        exit 1
    fi
    
    local archived_count=0
    
    # For loop for processing .txt files
    for file in "$SCRIPT_DIR"/*.txt; do
        # Check if the file exists (protection against the case when there are no .txt files)
        if [[ ! -f "$file" ]]; then
            log_info "No .txt files found in $SCRIPT_DIR"
            continue
        fi
        
        # Get file name without path
        local filename=$(basename "$file")
        local archive_name="${filename}_${CURRENT_DATE}.tar.gz"
        local archive_path="$BACKUP_DIR/$archive_name"
        
        # Display file name
        log_info "Processing file: $filename"
        
        # Archive file
        if tar -czf "$archive_path" -C "$SCRIPT_DIR" "$filename" 2>>"$ERROR_LOG_FILE"; then
            log_info "Archive created successfully: $archive_name"
            ((archived_count++))
        else
            # System error is already written to error log, adding only context
            log_info "Skipped file due to archiving error: $filename"
        fi
    done
    
    log_info "Archiving process completed. Archives created: $archived_count"
}

manage_old_backups() {
    log_info "Starting checking old backups (older than 3 minutes)"
    
    if [[ ! -d "$BACKUP_DIR" ]]; then
        log_info "Backup directory does not exist, skipping cleanup"
        return 0
    fi
    
    local moved_count=0
    
    # Find files older than 3 minutes and move them
    while IFS= read -r -d '' archive; do
        if [[ -f "$archive" ]]; then
            local archive_name=$(basename "$archive")
            local destination="$OLD_BACKUP_DIR/$archive_name"
            
            if mv "$archive" "$destination" 2>>"$ERROR_LOG_FILE"; then
                log_info "Moved old backup: $archive_name"
                ((moved_count++))
            else
                log_info "Error moving archive: $archive_name"
            fi
        fi
    done < <(find "$BACKUP_DIR" -name "*.tar.gz" -type f -mmin +3 -print0 2>>"$ERROR_LOG_FILE")
    
    log_info "Processing old backups completed. Files moved: $moved_count"
}

main() {
    log_info "=== Running backup script ==="
    
    # Checking and creating necessary directories
    ensure_directories
    
    # Archiving files
    archive_files
    
    # Managing old backups
    manage_old_backups
    
    log_info "=== Backup script completed successfully ==="
}

main