
# Set prompt to new line and use $ symbol
$GitPromptSettings.DefaultPromptSuffix = '`n$(''$'' * ($nestedPromptLevel + 1)) '
$GitPromptSettings.EnableWindowTitle = " "
$GitPromptSettings.DefaultPromptAbbreviateHomeDirectory=$true
$GitPromptSettings.DefaultPromptPrefix = '[$env:username@$(hostname)] '

Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete -ErrorAction SilentlyContinue