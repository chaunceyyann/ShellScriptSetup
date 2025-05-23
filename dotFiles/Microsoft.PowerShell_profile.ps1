function prompt {
    function Add-Segment {
        param (
            [int]$bg,
            [int]$fg,
            [string]$text,
            [string]$icon = "",
            [int]$nextBg = 0
        )
        $sep = ""
        $start = "`e[48;5;${bg};38;5;${fg}m"
        $end = "`e[48;5;${nextBg};38;5;${bg}m$sep"
        return "$start $icon$text $end"
    }
  
    $reset = "`e[0m"
  
    # Time
    $time = (Get-Date).ToString("hh:mmtt")
    $timeSegment = Add-Segment -bg 240 -fg 15 -text " $time " -icon "" -nextBg 28
  
    # Decide next segment color based on whether Git exists
    $gitExists = git rev-parse --is-inside-work-tree 2>$null
    $nextBg = if ($gitExists) { 27 } else { 33 }
  
    # Python venv
    $pythonSegment = ""
    if ($env:VIRTUAL_ENV) {
        $venv = Split-Path -Leaf $env:VIRTUAL_ENV
        $pythonSegment = Add-Segment -bg 28 -fg 15 -text " $venv " -icon "🐍" -nextBg $nextBg
    }
  
    # Conda env
    $condaSegment = ""
    if ($env:CONDA_DEFAULT_ENV -and !$env:VIRTUAL_ENV) {
        $condaSegment = Add-Segment -bg 28 -fg 15 -text " $($env:CONDA_DEFAULT_ENV) " -icon "🧪" -nextBg $nextBg
    }
  
    # Git segment (if present)
    $gitSegment = ""
    if ($gitExists) {
        $branch = git rev-parse --abbrev-ref HEAD 2>$null
        $dirty = if (git status --porcelain 2>$null) { " *" } else { "" }
        $gitSegment = Add-Segment -bg 27 -fg 15 -text " $branch$dirty " -icon "" -nextBg 33
    }
  
    # Current dir
    $cwd = Split-Path -Leaf (Get-Location)
    $cwdSegment = Add-Segment -bg 33 -fg 0 -text " $cwd " -icon "" -nextBg 0
  
    # Final prompt
    "$timeSegment$pythonSegment$condaSegment$gitSegment$cwdSegment$reset`n❯ "
  }
  