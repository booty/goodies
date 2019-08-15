# Slicker `git checkout`
#
# ~~ Usage ~~
#
# 1. Install fzf via `brew install fzf` or your package manager of choice
# 2. You probably want to copy this to ~/.bashrc or ~/.zshrc, or (better yet) load this file from your .bashrc/.zshrc
# 3. `gco` will list the 30 most recently-active commits
# 4. `gco foo` will list all branches matching "foo"
# 5. If `gco foo` returns only a single result, we skip the list and
#    check it out.
#
#  Particularly Useful for branches named after issue numbers.
#
#  `gco 123` will take you right to "jr-my-long-branch-name-cw-123"
#  assuming you don't have any other branches w/ "123" in them

function gco() {
  local branches branch

  # Be a solid bro and point them in the right direction
  # if fzf not installed
  if ! [ -x "$(command -v fzf)" ]; then
    echo "fzf not installed. See https://github.com/junegunn/fzf for info or simply \`brew install fzf\`"
    return 1
  fi

  # If no search term supplied, list them
  if [ -z "$1" ]; then
    branches=$(git for-each-ref --count=30 --sort=-committerdate refs/heads/ --format="%(refname:short)") &&
    branch=$(echo "$branches" | fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
    git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
    return 0
  fi

  # If search term supplied...
  branches=$(git branch | ag $1 | fzf --filter="$1" --no-sort | sed -e 's/^[ \s\*]*//')
  if [ -z "$branches" ]; then
    # No matches!
    return 1
  elif [ $(wc -l <<< "$branches") -eq 1 ]; then
    # There was only one match, so let's jump to it
    git checkout $branches
  else
    # There were multiple matches; list them
    git checkout $(git branch | ag $1 | fzf)
  fi
}