# Nushell Environment Config File

def create_left_prompt [] {
    mut home = ""
    try {
        if $nu.os-info.name == "windows" {
            $home = $env.USERPROFILE
        } else {
            $home = $env.HOME
        }
    }

    let dir = ([
        ($env.PWD | str substring 0..($home | str length) | str replace $home "~"),
        ($env.PWD | str substring ($home | str length)..)
    ] | str join)

    let path_segment = if (is-admin) {
        $"(ansi red_bold)($dir)"
    } else {
        $"(ansi green_bold)($dir)"
    }

    $path_segment
}

def create_right_prompt [] {
    let time_segment = ([
        (ansi reset)
        (ansi magenta)
        (date now | format date '%m/%d/%Y %r')
    ] | str join)

    let last_exit_code = if ($env.LAST_EXIT_CODE != 0) {([
        (ansi rb)
        ($env.LAST_EXIT_CODE)
    ] | str join)
    } else { "" }

    ([$last_exit_code, (char space), $time_segment] | str join)
}

# Use nushell functions to define your right and left prompt
$env.PROMPT_COMMAND = {|| create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = {|| create_right_prompt }

# The prompt indicators are environmental variables that represent
# the state of the prompt
$env.PROMPT_INDICATOR = {|| "> " }
$env.PROMPT_INDICATOR_VI_INSERT = {|| ": " }
$env.PROMPT_INDICATOR_VI_NORMAL = {|| "> " }
$env.PROMPT_MULTILINE_INDICATOR = {|| "::: " }

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
$env.ENV_CONVERSIONS = {
  "PATH": {
    from_string: { |s| $s | split row (char esep) | path expand -n }
    to_string: { |v| $v | path expand -n | str join (char esep) }
  }
  "Path": {
    from_string: { |s| $s | split row (char esep) | path expand -n }
    to_string: { |v| $v | path expand -n | str join (char esep) }
  }
}

# Directories to search for scripts when calling source or use
#
# By default, <nushell-config-dir>/scripts is added
$env.NU_LIB_DIRS = [
    ($nu.config-path | path dirname | path join 'scripts')
]

# Directories to search for plugin binaries when calling register
#
# By default, <nushell-config-dir>/plugins is added
$env.NU_PLUGIN_DIRS = [
    ($nu.config-path | path dirname | path join 'plugins')
]

# To add entries to PATH (on Windows you might use Path), you can use the following pattern:
# $env.PATH = ($env.PATH | split row (char esep) | prepend '/some/path')

# Inherit the correct locale
$env.LANG = "en_GB.UTF-8"

if not (which fnm | is-empty) {
  ^fnm env --json | from json | load-env
  # Checking `Path` for Windows
  let path = if 'Path' in $env { $env.Path } else { $env.PATH }
  let node_path = if (sys).host.name == 'Windows' {
    $"($env.FNM_MULTISHELL_PATH)"
  } else {
    $"($env.FNM_MULTISHELL_PATH)/bin"
  }
  $env.PATH = ($path | prepend [ $node_path ])
}

# Add cargo to path
$env.PATH = ($env.PATH | append "~/.cargo/bin")
# Add local bin to path
$env.PATH = ($env.PATH | append "~/.local/bin" | append "~/.local/bin/custom")
# Add doom emacs to path
$env.PATH = ($env.PATH | append "~/.config/emacs/bin")
# $env.PATH = ($env.PATH | append "~/.emacs.d/bin")
# Ruby gems to path
# $env.PATH = ($env.PATH | append "/home/mizuuu/.rbenv/versions/2.6.6/bin")
# Add go binaries to path
$env.PATH = ($env.PATH | append "~/go/bin")
# Add haskell things to path
$env.PATH = ($env.PATH | append "~/.ghcup/bin")
# Bun
$env.BUN_INSTALL = $"($env.HOME)/.bun"
$env.PATH = ($env.PATH | append $"($env.BUN_INSTALL)/bin")

# starship
mkdir ~/.cache/starship
starship init nu | save -f ~/.cache/starship/init.nu

# zoxide
zoxide init nushell | save -f ~/.zoxide.nu
