
; delete(soft with -d) all merged braches except develop and master
::gitdelmer::branches=$(git branch --merged | grep -v '{^}* develop$' | grep -v '{^}  master$'); [ -n "$branches" ] && echo "$branches" | xargs git branch -d
::gitdev::git checkout develop
::gitprune::git remote prune github
::gitpull::git pull --all
::wslu::wsl -d ubuntu
::gitpr::gh pr create -f
; branches=$(git branch --merged | grep -v '^* develop$' | grep -v '^  master$'); [ -n "$branches" ] && echo "$branches" | xargs git branch -d
; branches=$(git branch --merged | grep -v '^* develop$' | grep -v '^  master$'); [ -n "$branches" ] && echo "$branches" | xargs
