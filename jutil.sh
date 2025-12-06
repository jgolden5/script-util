#/bin/bash
#useful utilities by Jonathan Gurr to help with bash and other stuff

NL=$'\n'
#OVERWRITES
cd() {
 if [[ -d $1 ]] || [[ $1 == "" ]]; then
   builtin cd "$@"
   isDuplicate=false
	 if [[ "$(pwd)" == "${pathHistory[$pathIndex]}" ]]; then
		isDuplicate=true
	 elif [[ "$(pwd)" == "${pathHistory[$pathIndex + 1]}" ]]; then
		isDuplicate=true
		pathIndex=$((pathIndex+1))
	 fi
	 if [[ $isDuplicate == "false" ]]; then
		 if [[ $pathIndex -ne $((${#pathHistory[@]}-1)) ]]; then
			 pathHistory=("${pathHistory[@]:0:$(($pathIndex+1))}" "$(pwd)" "${pathHistory[@]:$(($pathIndex+1))}")
		 else
			 pathHistory+=( "$(pwd)" )
		 fi
		 pathIndex=$((pathIndex+1))
		 cdCount=$((cdCount+1))
	 fi
 fi
}

wc() {
  if [[ $1 == "-r" ]]; then
    local input
    input=$(cat)
    echo ${#input}
  else
    command wc "$@"
  fi
}

#GENERAL
doFuncNTimes() {
  func=$1
  n=$2
  if [[ $n -ge 0 ]]; then
    for i in $(seq $n); do
      $func
    done
  else
    echo "$n is less than 0, so no function is possible"
  fi
}

readOutLoud() {
	if [[ -f $1 ]]; then 
		echo "reading file $1..."
		cat $1 | say
	elif [[ -d $1 ]]; then
		echo "reading directory $1..."
		cat $1/* | say
	else
		echo "reading string $1..."
		say "$1"
	fi
}

believe() {
  if [[ "$1" ]]; then
    echo "Believe it is worth it to learn $1. Believe I CAN learn $1. Commit to put effort into learning $1."
    sleep 2
    read -p "Do you commit to putting effort into learning $1? " response
    if [[ $response =~ ^y ]]; then
      echo "Well..."
      sleep 1
      echo "You already believe that it's worth it to learn $1"
      sleep 2
      echo "You already believe that you CAN learn $1"
      sleep 2
      read -p "So let's learn $1 already! Answer this: What do you not understand that is relevant to the problem? " relevant
      echo "clearly understand the following = $relevant" | pbcopy
      echo "Ok, I've copied your next task to the clipboard. Paste it to your taskqueue when you're ready to get this problem solved!"
    else
      echo "Well shoot, come back when you believe in yourself!"
    fi
  else
    echo "Believe in something first please. Think of a tool you are struggling with or some aspect of a problem you are trying to figure out."
  fi
}

blocksToBytes() {
	blocks="${1//_/}"
	bytes=$(($blocks * 512))
	if [[ $bytes -ge 0 ]]; then
		if [[ $bytes -lt 1000 ]]; then
			bytes+="B"
		elif [[ $bytes -lt 1000000 ]]; then
			bytes="$(awk "BEGIN {print $bytes / 1000}")KB"
		elif [[ $bytes -lt 1000000000 ]]; then
			bytes="$(awk "BEGIN {print $bytes / 1000000}")MB"
		elif [[ $bytes -lt 1000000000000 ]]; then
			bytes="$(awk "BEGIN {print $bytes / 1000000000}")GB"
		elif [[ $bytes -lt 1000000000000000 ]]; then
			bytes="$(awk "BEGIN {print $bytes / 1000000000000}")TB"
		elif [[ $bytes -lt 1000000000000000000 ]]; then
			bytes="$(awk "BEGIN {print $bytes / 1000000000000000}")PB"
		elif [[ ${#bytes} -gt 16 ]]; then
			bytes="byte size is too big. Please keep it UNDER 100 quadrillion (17 digits), please."
		else
			bytes="byte size not recognized"
		fi
	elif [[ ${#bytes} -gt 16 ]]; then
		bytes="byte size is too big. Please keep it UNDER 100 quadrillion (17 digits), please."
	else 
		bytes="byte size must be at least zero, if you please."
	fi
	echo $bytes
}

current_problem() {
  next_problem=$(head -1 ~/ProgrammingStudies/reflection_log)
  if [[ $next_problem != "" ]]; then
    echo "$next_problem" | sed 's/.*: \(.*\)/\1/' 
  else
    echo "no current problem to solve yet"
  fi
}

reflection_highlights() {
  highlights=
  n=1
  while read line; do
    highlights+="$n - $line${NL}"
    (( n++ ))
  done < <(awk '/Highlights:/ {flag=1; next} /^\s*$/ {flag=0} flag' ~/ProgrammingStudies/reflection_log)
  highlights=$(echo "$highlights" | sed "s/$'\n'$'\n'/$'\n'/")
  if [[ "$1" ]]; then
    echo "$highlights" | window $1
  else
    echo "Reflection Log Highlights:"
    echo "$highlights"
  fi
}

reflection_highlights_highlights() {
  tldr=
  l=0
  n=1
  alphabet="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
  while read line; do
    if [[ "$line" =~ ":" ]]; then
      tldr+="$n - $line${NL}"
      (( n++ ))
      l=0
    elif [[ $line ]]; then
      tldr+="  ${alphabet:${l}:1} - $line${NL}"
      (( l++ ))
    fi
  done < <(cat ~/ProgrammingStudies/tldr_reflection_highlights | sed '1d')
  tldr=$(echo "$tldr" | sed "s/$'\n'$'\n'/$'\n'/")
  echo "Reflection Log Highlights (tldr):"
  echo "$tldr"
}

random_reflection_highlight() {
  reflection_highlights | shuf -n 1
}

alias bb='blocksToBytes'
alias now='current_problem'
alias openImage='$gio open'
alias r='readOutLoud'
alias rh='reflection_highlights'
alias rhh='reflection_highlights_highlights'

#GIT
export GITHUBPATH='https://github.com/jgolden5/' #to be used such as the following: 'git clone ${GITHUBPATH}example_project'

gl () {
  git --no-pager log -n ${lines:-20} --decorate --pretty=tformat:"%C(#fda63a) %h %Creset %<(25)%ci %C(auto)%d%Creset %s" "$@"
}

grb() { #git rebase head
  if [[ $# -eq 0 ]]; then
    git rebase -i HEAD~2
  else
    git rebase -i HEAD~$1
  fi
}

grn() {
  git commit --amend -m "$1"
  echo "$1" | pbcopy
}

gac() {
  local message=$*
  git add .
  git commit -m "$message"
  echo "$message" | pbcopy
}

gacp() {
  gac "$@"
  git push
}

grb() {
  git rebase -i HEAD~$1
}

gsq() {
  gac "."
  grb 2
}

gnum() {
  git rev-list --count HEAD
}

gday() {
  git log --date=short --pretty=format:'%ad' | sort | uniq -c
  echo "  $(gnum) total"
}

unset parse_git_branch
parse_git_branch() {
  local p=$PWD
  while [[ "$p" =~ / ]]; do
    if [ -d $p/.git ]; then
      local r=$(cat $p/.git/HEAD)
      if [[ "$r" =~ refs/heads ]]; then
        echo "$r" | sed -E 's/.*\/(.*)/ \[\1\]/'
      else
        git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ \[\1\]/'
      fi
      break
    fi
    p=${p%/*}
  done
}

list_git_projects() {
  find . -name .git -type d | sed 's/\.\/\(.*\)\/.git/\1/' | grep -v '.git'
  if [[ "$?" == 1 ]]; then
    echo "No git projects found in current working directory"
  fi
}

alias gs='git status'
alias gc='git checkout'
alias gu='git reset --hard && git clean -df'
alias gd='git diff'
alias gdh='git diff HEAD^'
alias gb='git branch'
alias gsw='git switch -'
alias gt='git tree'
alias lgp='list_git_projects'

#BASH
declare -a pathHistory=()
export LESS='-M'
pathIndex=-1
cdCount=0

column() {
  column="$1"
  awk '{ print $'"$column"' }'
}

exec 3<&0
window() {
  if [[ $# -eq 1 ]]; then
    n=$1
  else
    n=5
  fi
  line_number=1
  printf "\033c"
  COLOR='\033[30;107m'
  NC='\033[0m'
  while read -r line; do
    echo "$line"
    if [[ $(($line_number % $n)) -eq 0 ]]; then
			if [[ $n -gt 1 ]]; then
				echo -ne "${COLOR}lines "$(( $line_number - $n + 1 ))" - $line_number${NC} => type q to quit, any other command to continue"
			else 
				echo -ne "${COLOR}line $line_number${NC} => type q to quit, any other command to continue"
			fi
      read -n1 -s -r input <&3
      case $input in
        "q")
          echo;
          break;
          ;;
        *)
          printf "\033c"
          ;;
      esac
    fi
    line_number=$(($line_number + 1))
  done
}

sentencify() { #group each sentence in a text input into its own line and then sends that to stdout
  sed 's/\([\!\.\?]\) \([A-Z]\)/\1\n\2/g' | tr -s $'\n'
}

typea() {
	if [[ $(type -t "$1") == 'alias' ]]; then
		phrase="$(type $1)"
		alias="$(echo $phrase | sed 's/ .*//')"
		command="$(echo $phrase | sed "s/.*\`\(.*\)\'.*/\1/")"
		type $1
		type $command
	else
		echo "$1 is not an alias"
		type $1
	fi
}

get_open_file_descriptors() {
	echo "open file descriptors:"
	ls -l /dev/fd | grep -e "^c" -e "^p" | rev | cut -c 1
}

unset_custom_file_descriptors() {
	exec 3>&- 4>&- 5>&- 6>&- 7>&- 8>&- 9>&-
}

empty_file() {
	echo -n '' >"$1"
}

pd() { #cd to previous directory with unlimited steps (not just toggling from one to another like cd - )
  f() {
    for i in {1..$1}; do
      if [[ $pathIndex -gt 0 ]]; then
        pathIndex=$(($pathIndex - 1))
        currentPath="${pathHistory[$pathIndex]}"
        builtin cd $currentPath
      fi
    done
  }
	if [[ $# -gt 0 ]]; then
		doFuncNTimes f $1
	else
		f
	fi
  directory_path_history
}

nd() { #cd to next directory with unlimited steps (back to the directory I was in when I ran pd)
  f() {
    if [[ $pathIndex -lt $((${#pathHistory[@]} - 1)) ]]; then
      pathIndex=$(($pathIndex + 1))
      currentPath="${pathHistory[$pathIndex]}"
      builtin cd $currentPath
    fi
  }
	if [[ $# -gt 0 ]]; then
		doFuncNTimes f $1
	else
		f
	fi
  directory_path_history
}

rd() { #remove current directory in pathHistory
	currentPath="${pathHistory[$pathIndex]}"
	while true; do
		if [[ $1 == "-f" ]]; then #force remove dir
			yn='y'
		else
			read -p "Are you sure you want to remove directory $currentPath from path history? " yn
		fi
		case $yn in
			[Yy]* )
				unset pathHistory[$pathIndex]
				pathHistory=("${pathHistory[@]}") #reindex array, otherwise unset values still keep their previous indices
				echo "current path $currentPath was unset"
				echo "current path size = ${#pathHistory[@]}"
				if [[ $pathIndex -ge ${#pathHistory[@]} ]]; then
					pathIndex=$((--pathIndex))
					echo path index was decremented to $pathIndex
				fi
				currentPath="${pathHistory[$pathIndex]}"
				builtin cd $currentPath
				break
				;;
			[Nn]* )
				echo "ok then."
				break
				;;
			* )
				echo "Please answer yes or no."
				;;
		esac
	done
  directory_path_history
}

directory_path_history() {
	{
		if [[ ${#pathIndex} -lt 0 ]]; then
			echo pathHistory currently empty
		else
			for((i = 0; i < ${#pathHistory[@]}; i++)); do
				if [[ $i -eq $pathIndex ]]; then
					echo -n ${pathHistory[$i]}
					echo " <--"
				else
					echo ${pathHistory[$i]}
				fi
			done
		fi
	} | cat -n
}

swap_files() {
	if [[ $1 == '-f' ]]; then
		should_swap=true
		file1=$2
		file2=$3
	else
		file1="$1"
		file2="$2"
		echo "swap files $1 and $2?"
		read inp
		if [[ $inp == "y" || $inp == "yes" ]]; then
			should_swap=true
		else
			should_swap=false
		fi
	fi
	if [[ $file1 == $file2 ]]; then
		should_swap=false
	fi
	if [[ $should_swap == "true" ]]; then
		mv $file1 tmp
		mv $file2 $file1
		mv tmp $file2
		#echo "files $file1 and $file2 were successfully swapped"
	fi 
}

taskon() {
	current_task=$(cat ~/ProgrammingStudies/study-journal | grep -A 3 PARTITION | tail -1)
	if [[ "$(echo $current_task | wc -w)" -gt 10 ]]; then
		current_task=$(echo $current_task | tr -s ' ' | cut -d ' ' -f 1-10);
	fi
	export PS1="\[\033[1;33m\]$current_task\n\[\033[1;34m\]\d \A \[\033[0;35m\]\u \[\033[1;31m\]\W\[\033 \[\033[0m\] \$ "
}

reset_prompt() {
	beautify_prompt
}

recursive_grep() {
  grep -nri "$@"
}

project_line_count() {
  current_working_dir=$(pwd)
  if [[ -d "${current_working_dir}/$1" ]]; then
    project_dir="${current_working_dir}/$1"
  else
    project_dir='.'
  fi
  file_extensions=("html" "css" "js" "json" "ts" "java" "sh" "hs" "c" "cpp" "cc" "h" "py" "php" "rb" "go" "rs" "swift" "kt" "pl" "sql" "xml")
  total_project_line_count=0
  for extension in "${file_extensions[@]}"; do
    current_extension_line_count="$(find $project_dir -type f -name "*.${extension}" -exec cat {} + | wc -l | sed 's/ //g')"
    total_project_line_count="$(( total_project_line_count + current_extension_line_count ))"
    if [[ $current_extension_line_count -gt 0 ]]; then
      echo "$current_extension_line_count $extension lines found"
    fi
  done
  project_base_dir=$(basename "$project_dir")
  echo "Project \"$project_base_dir\" has $total_project_line_count total lines"
}

show_functions() {
  if [[ -f "$1" ]]; then
    grep "()" "$1" | sed 's/\(.*\)().*/\1/'
  fi
}

alias bd=pd
alias ef='empty_file'
alias fd=nd
alias gfd='get_open_file_descriptors'
alias h=directory_path_history
alias la='ls -a'
alias lg='ls -G'
alias ll='ls -l'
alias lla='ls -la'
alias plc='project_line_count'
alias rg='recursive_grep'
alias s='source'
alias sshr='ssh rancher@138.68.238.246'
alias sut='cd ~/script-util/'
alias sw='swap_files'
alias toff='reset_prompt'
alias ton='taskon'
alias ufd='unset_custom_file_descriptors'
alias up='cd ..'

#DOCKER
docker_alias_help() {
  cat /Users/jgolden1/script-util/jutil | grep -i "docker" | grep "alias " | grep -v "grep"
}

docker_images_and_ps() {
  echo "Images:"
  docker images
  echo
  echo "Containers:"
  docker ps -a
}

docker_rm_all() {
  all_containers=$(docker ps -a | sed '1p' | awk '{print $14}' | sed '/^$/d' )
  if [[ "$all_containers" ]]; then
    while read container; do
      echo "removing container $container"
      sleep 0.5
      docker rm -f "$container"
    done <<< "$all_containers"
  else
    echo "There are no containers to remove. See?"
    echo "Running docker ps -a..."
    docker ps -a
  fi
}

docker_exec_bash() {
  dir="$1"
  shift
  docker exec -it "$dir" bash -c "$@"
}

docker_exec_bash_bash() {
  dir="$1"
  shift
  docker exec -it "$dir" bash -c "/bin/bash"
}

docker_stop_all() {
  docker stop $(docker ps -q)
}

alias vd='vi Dockerfile'
alias da='docker_images_and_ps'
alias dall='docker images; docker ps -a'
alias db='docker build'
alias de="docker exec -it"
alias deb="docker_exec_bash"
alias debb="docker_exec_bash_bash"
alias dh='docker_alias_help'
alias di='docker image'
alias dis='docker images'
alias dcon='docker container'
alias dp='docker ps'
alias dpa='docker ps -a'
alias dr='docker run'
alias drm='docker rm'
alias drmf='docker rm -f'
alias drall='docker_rm_all'
alias dres='docker_reset'
alias ds='docker stop'
alias dsa="docker_stop_all"
alias dsallf="docker ps | sed '1d' | awk '{ print "'$NF'" }' | xargs -I {} docker stop {}"
alias dv='docker volume'
alias dvl='docker volume ls'

#NETWORK
google() {
  search=""
  for term in $@ ; do
    search="$search%20$term"
  done
  echo "$@" | pbcopy
  echo "Searched for $@ and copied it to clipboard"
  open "http://www.google.com/search?q=$search"
}

http() {
  #domain port urlPath
  #localhost:8888/
  fullPath=$1
  domain=${fullPath%%:*}
  temp=${fullPath%%/*}
  port=${temp#*:}
  url=/${fullPath#*/}
  echo -e "GET ${url:-/} HTTP/1.1\n" | nc -v -w 2 $domain $port;
  echo
}

tcp_show() {
  echo "Exposed TCP ports:"
  lsof -nP -iTCP -sTCP:LISTEN | awk -F: '{print $NF}' | grep 'LISTEN' | sed 's/\(.*\) (LISTEN)/\1/' | sort -n | uniq
}

alias g='google'
alias tcps=tcp_show
alias wg='w3m google.com'
alias ws='wireshark'
alias wsc='wireshark -i en0 -k'

#VIM
vim_or_neovim() {
  if [[ "$1" =~ \..sx ]] || [[ "$1" =~ .*ts ]] || [[ "$1" =~ .*geojson ]]; then #this accounts for react and TypeScript code, which are sometimes glitchy when rendering in vim, but they are no match for Treesitter
    nvim "$1"
  else
    vim "$1"
  fi
}

set -o vi
set show-mode-in-prompt on
set vi-ins-mode-string "insert"
set vi-cmd-mode-string "normal"
set nobackup #I don't totally understand this command, so if we end up still needing it, put it back in .profile

alias vb='vim ~/script-util/jutil.sh' #'b' because it's basically my version of ~/.bashrc
alias vc='vim ~/.vimrc'
alias vi='vim_or_neovim'
alias vp='vim ~/.profile'
alias vv='cd ~/vim-config/; vim vimrc.vim'
alias v='vim_or_neovim'

#NEOVIM
alias nv='nvim'
alias nvd='cd ~/.conf'

#JAVA
java_compile_source_and_delete() {
  if find . -name "src" -type d | grep -q .; then
    javac src/*.java && echo "java files sourced successfully" || echo "java files failed to source"
    java src/Main
    rm src/*.class
  else
    echo "directory src not found. Please enter a directory named src, and try again"
  fi
}

alias jj='java_compile_source_and_delete'

#GO
alias gr='go run'
