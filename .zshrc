# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="philips"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git rails3 git-flow debian)

source $ZSH/oh-my-zsh.sh
alias rspec='nocorrect rspec '

# Customize to your needs...

# Editor
export EDITOR="vim"

# Chruby
source /usr/local/share/chruby/chruby.sh
source /usr/local/share/chruby/auto.sh
chruby 1.9.3-p392-perf

# Tmuxinator
[[ -s $HOME/.tmuxinator/scripts/tmuxinator ]] && source $HOME/.tmuxinator/scripts/tmuxinator

# PSQL
export PGDATABASE=amoeba_development
export PGUSER=alex
export PGPORT=5435

# Rails
export RUBY_GC_MALLOC_LIMIT=60000000
export RUBY_FREE_MIN=200000

# Project
# alias amoeba="cd ~/projects/amoeba"
# alias cam="cd ~/projects/amoeba.cam"
# alias ws="cd ~/projects/amoeba.ws"
# alias igs="cd ~/projects/igs"
# alias igshk="cd ~/projects/igshk"
# alias sat="cd ~/projects/satellite"
# alias booking="cd ~/projects/booking"

p() {
  if [ -z "$1" ]
  then
    echo "No project input"
  else
    cd ~/projects/$1
  fi
}
_p() { _files -W ~/projects -/; }
compdef _p p

# Git
alias ga="git add ."
alias gs="git status"
alias gc="git commit"
alias gd="git diff"
alias gl="git log --graph --pretty=\"format:%C(yellow)%h%Cblue%d%Creset %s %C(green) %an, %ar%Creset\""
alias gb="git branch -a"
alias gst="git stash"
alias gstp="git stash pop"

# DB
alias fetch_db="scp amoeba:~/deploy/db_backups/amoeba-$(date +%Y)_$(date +%m)_$(date +%d)_0200 ~/projects/dbs/"
# alias restore_local_db="pg_restore -h localhost -p 5435 -U amoeba -d amoeba_development -c -O $1"
# alias restore_local_test_db="pg_restore -h localhost -p 5435 -U amoeba -d amoeba_test -c -O $1"
# alias restore_3620C_db="pg_restore -h 3620C -U amoeba -d amoeba -c -O $1"
# alias restore_live_data="pg_dump -c -h 3620C -p 5433 -U athenabest amoeba | psql"
restore_db () {
  echo -n "Which date? (yyyymmdd) "
  read INPUT
  d=$INPUT[0,4]_$INPUT[5,6]_$INPUT[7,8]
  scp A:~/db_backups/amoeba-$d"_0200" ~/documents
  pg_restore -h localhost -p 5435 -U amoeba -d amoeba_development -c -O ~/documents/amoeba-$d"_0200"
  rm ~/documents/amoeba-$d"_0200"
}

rld () {
  if [ -z "$1" ]
  then
    echo "No site input"
  else
    case $1 in
    "afs")
      pg_dump -c -h 3620C -p 5433 -T fund_prices -T snapshot_portfolios -T email_clients -w -U athenabest amoeba | psql
      pg_dump -c -h 3620C -p 5433 -s -t fund_prices -t snapshot_portfolios -t email_clients -w -U athenabest amoeba | psql
      ;;
    "scwm")
      ssh 7945A pg_dump -O -c -T fund_prices -T snapshot_portfolios -T email_clients -w -U abagile amoeba | psql
      ssh 7945A pg_dump -O -c -s -t fund_prices -t snapshot_portfolios -t email_clients -w -U abagile amoeba | psql
      ;;
    "gswm")
      ssh 7945A pg_dump -O -c -p 5433 -T fund_prices -T snapshot_portfolios -T email_clients -w -U abagile amoeba | psql
      ssh 7945A pg_dump -O -c -p 5433 -s -t fund_prices -t snapshot_portfolios -t email_clients -w -U abagile amoeba | psql
      ;;
    esac
  fi
}

alias sat_db="ssh 3620A pg_dump -O -c satellite | psql satellite"
alias revenue_import="rails runner \"Import::RevenueFile.perform('live')\""

# Server
# alias amoeba_server="RAILS_RELATIVE_URL_ROOT='/amoeba' RAILS_ENV='development' bundle exec unicorn -c /home/alex.au/projects/amoeba/config/unicorn.rb -D $*"
# alias cam_server="RAILS_RELATIVE_URL_ROOT='/cam' RAILS_ENV='development' bundle exec unicorn -c /home/alex.au/projects/amoeba.cam/config/unicorn.rb -D $*"
# alias ws_server="RAILS_RELATIVE_URL_ROOT='/ws' RAILS_ENV='development' bundle exec unicorn -c /home/alex.au/projects/amoeba.ws/config/unicorn.rb -D $*"
# alias satellite_server_start="RAILS_RELATIVE_URL_ROOT='/satellite' RAILS_ENV='development' bundle exec unicorn -c /home/alex.au/projects/satellite/config/unicorn.rb -D $*"
# alias igshk_server="RAILS_RELATIVE_URL_ROOT='/ail_rails' RAILS_ENV='development' bundle exec unicorn -c /home/alex.au/projects/igshk/config/unicorn.rb -D $*"
alias booking_server="RAILS_RELATIVE_URL_ROOT='/booking' rails server -p 5000 -d"

ds() {
  if [ -f "./tmp/pids/unicorn.pid" ]
  then
    kill `cat ./tmp/pids/unicorn.pid`
    echo "Server is brought to down"
  else
    echo "Server is not up"
  fi
}

us() {
  current_directory=`pwd | sed 's!.*/!!'`
  case $current_directory in
    amoeba.cam)
      root=cam
      ;;
    amoeba.ws)
      root=ws
      ;;
    igshk)
      root=ail_rails
      ;;
    *)
      root=$current_directory
  esac
  RAILS_RELATIVE_URL_ROOT=/$root RAILS_ENV=development bundle exec unicorn -c `pwd`/config/unicorn.rb -D $*
  echo "Server is brought to up"
}

alias rs="ds && us"

ss() {
  if [ -z "$1" ]
  then
    echo "No site input"
  else
    echo "Switching amoeba to $1"
    ds
    rld $1
    thor setup:site $1
    us
  fi
}

# Deployment
hotfiz() {
  echo "You prepare the deployment? (Y/N) "
  read prepare

  if [[ $prepare =~ "y|Y|yes|Yes" ]]; then
    echo "Old hotfix branch (number only): "
    read OLD_VERSION
    OLD_HOTFIX="hotfix/$OLD_VERSION"
    echo "New hotfix branch (number only): "
    read NEW_VERSION
    NEW_HOTFIX="hotfix/$NEW_VERSION"

    git pull --rebase
    git checkout master
    git pull
    git merge --no-ff $OLD_HOTFIX
    ./script/bump-version
    git add lib/VERSION
    git commit -m "Bump version to $OLD_VERSION"
    git tag $OLD_VERSION
    git branch $NEW_HOTFIX
    git branch -d $OLD_HOTFIX
    git checkout $NEW_HOTFIX
    clear
    git branch -a
    git log -10 --pretty=format:"%s" --graph

    echo "Push to remote? (Y/N) "
    read push
    if [[ $push =~ "y|Y|yes|Yes" ]]; then
      git push -u origin $NEW_HOTFIX
      git push origin :$OLD_HOTFIX
      git push
      git push --tags
    fi
  else
    echo "Old hotfix branch (number only): "
    read OLD_VERSION
    OLD_HOTFIX="hotfix/$OLD_VERSION"
    echo "New hotfix branch (number only): "
    read NEW_VERSION
    NEW_HOTFIX="hotfix/$NEW_VERSION"

    git stash save 'Temp. storage for hotfiz'
    git checkout master
    git pull
    git branch -t $NEW_HOTFIX origin/$NEW_HOTFIX
    git branch -d $OLD_HOTFIX
    git remote prune origin
    git checkout $NEW_HOTFIX
    # git stash pop
    clear
    git branch -a
    git log -10 --pretty=format:"%s"  --graph
  fi

  echo -n "Done!"
}
