package sdrl

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strings"
import "core:time"

Logger :: struct {
	file_handle: ^os.File,
	filepath:    string,
}

Log_Level :: enum {
	DEBUG,
	INFO,
	WARN,
	ERROR,
}

init_logger :: proc(base_name: string) -> (Logger, bool) {
	// Create logs dir — .Exist is fine, we expect it after the first run
	dir_err := os.make_directory("./logs")
	if dir_err != nil && dir_err != os.General_Error.Exist {
		fmt.println("Failed to create logs directory:", dir_err)
		return {}, false
	}

	// rotate out stale logs - keep under the first write to prevent the
    // inconsistent crash on launch from trying to kill a .log file to early SSV
	rotate_logs(base_name, 2) // Rotate to 2 so new file makes 3 total

	now := time.now()
	year, month, day := time.date(now)
	hour, min, sec := time.clock_from_time(now)

	// nightmare string
	filename := fmt.aprintf(
		"./logs/%s_%d-%02d-%02d_%02d-%02d-%02d.log",
		base_name,
		year,
		int(month),
		day,
		hour,
		min,
		sec,
	)

	handle, open_err := os.open(
		filename,
		os.File_Flags{.Create, .Write},
		os.Permissions{.Read_User, .Write_User, .Read_Group, .Read_Other},
	)
	if open_err != nil {
		fmt.println("Failed to open log file:", open_err)
		return {}, false
	}

	os.write_string(handle, "\n=== SESSION START ===\n")
	os.flush(handle) // crash-critical line
	return Logger{file_handle = handle, filepath = filename}, true
}

init_logger_simple :: proc(filepath: string) -> (Logger, bool) {
	handle, open_err := os.open(
	filepath,
	os.File_Flags{.Create, .Write, .Trunc},
	os.Permissions{.Read_User, .Write_User, .Read_Group, .Read_Other},
	)
	if open_err != nil {
		return {}, false
	}

	os.write_string(handle, "=== SESSION START ===\n")
	os.flush(handle)

	return Logger{file_handle = handle, filepath = filepath}, true
}

cleanup_logger :: proc(logger: ^Logger) {
	if logger.file_handle == nil {
		return
	}
	log_to_file(logger, .INFO, "=== Session Ended ===")

	os.flush(logger.file_handle)
	os.close(logger.file_handle)
	logger.file_handle = nil
}

rotate_logs :: proc(base_name: string, keep_count: int) {
	dir_handle, open_err := os.open("./logs", os.File_Flags{.Read})
	if open_err != nil {
		return
	}
	defer os.close(dir_handle)

	file_infos, read_err := os.read_all_directory(dir_handle, context.allocator)
	if read_err != nil {
		return
	}
	defer delete(file_infos)

	matching_logs := make([dynamic]string, context.allocator)
	defer delete(matching_logs)

	pattern_prefix := fmt.tprintf("%s_", base_name)
	for info in file_infos {
		if strings.has_prefix(info.name, pattern_prefix) && strings.has_suffix(info.name, ".log") {
			append(&matching_logs, strings.clone(info.fullpath))
		}
	}

	if len(matching_logs) > keep_count {
		slice.sort(matching_logs[:])

		delete_count := len(matching_logs) - keep_count
		for i in 0 ..< delete_count {
			os.remove(matching_logs[i])
			delete(matching_logs[i])
		}
		for i in delete_count ..< len(matching_logs) {
			delete(matching_logs[i])
		}
	} else {
		for path in matching_logs {
			delete(path)
		}
	}

}

format_log_entry :: proc(level: Log_Level, message: string, timestamp: time.Time) -> string {
	level_str: string
	hour, min, sec := time.clock_from_time(timestamp)

	switch level {
	case .DEBUG:
		level_str = "DEBUG"
	case .INFO:
		level_str = "INFO "
	case .WARN:
		level_str = "WARN "
	case .ERROR:
		level_str = "ERROR"
	case:
		level_str = "?????"
	}

	return fmt.aprintf("[%02d:%02d:%02d] [%s] %s\n", hour, min, sec, level_str, message)
}


log_to_file :: proc(logger: ^Logger, level: Log_Level, message: string) {
	if logger.file_handle == nil {return}

	now := time.now()
	entry := format_log_entry(level, message, now)
	defer delete(entry)

	os.write_string(logger.file_handle, entry)

	// ERROR level: flush to disk immediately so we don't lose it on crash
	if level == .ERROR {
		os.flush(logger.file_handle)
	}
}
