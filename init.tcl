package require cmdline
package require 9pm::output
package provide 9pm::init 1.0

# Parse command line
set options {
    {c.arg "" "Configuration file"}
    {l.arg "./log" "Logging base path"}
    {d "" "Output debug info and write exp_internal logfile"}
}
array set int::cmdl [ ::cmdline::getoptions argv $options "Options:" ]

set log_base $int::cmdl(l)
file mkdir $log_base

set script_name [get_script_name]
file mkdir "$log_base/$script_name"

# Setup log paths, logfiles and create symlinks to last run
while TRUE {
    incr i
    set run_suffix [format {%04s} $i]

    if {![file isdirectory "$log_base/$script_name/$run_suffix"]} {
        file mkdir "$log_base/$script_name/$run_suffix"
        break
    }
}

# Create symlinks to latest
if {[file exists "$log_base/last"]} {
    file delete "$log_base/last"
}
exec ln -s -f "$script_name/$run_suffix" "$log_base/last"

if {[file exists "$log_base/$script_name/last"]} {
    file delete "$log_base/$script_name/last"
}
exec ln -s -f $run_suffix "$log_base/$script_name/last"

# Store the log path for later use
set int::log_base [get_full_path $log_base]
set int::log_script [get_full_path "$log_base/$script_name"]
set int::log_path [get_full_path "$log_base/$script_name/$run_suffix"]


# Debug on/off, generate exp_internal?
if {$int::cmdl(d)} {
    set int::print_debug TRUE
    exp_internal -f "$int::log_path/exp_internal.log" 0
} else {
    set int::print_debug FALSE
}

# Read config file
if {$int::cmdl(c) != ""} {
    output DEBUG "Using configuration: $int::cmdl(c)"
    set int::config [int::parse_config $int::cmdl(c)]
} else {
    output DEBUG "Running without configuration"
}

