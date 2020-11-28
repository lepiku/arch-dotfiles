#PROMPT="%(?:%{$fg__bold_boldbold[green]%}➜ :%{$fg_bold[red]%}➜ )"
#PROMPT+='%{$fg[cyan]%}$(shrink_path -l -t)%{$reset_color%} $(git_prompt_info)'
PROMPT='%{$fg_bold[cyan]%}$(shrink_path -l -t) $(git_prompt_info)'
PROMPT+="%(?:%{$fg_bold[green]%}:%{$fg_bold[red]%})→ %{$reset_color%}"

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%})%{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"
