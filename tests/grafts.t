#!/usr/bin/env cram

  $ PATH=$TESTDIR/..:$PATH

  $ n=0
  $ create_hg() {
  >   echo $1 > $1
  >   hg add $1
  >   [ "$2" = "--no-commit" ] || hg commit -q -m ${2:-$1} -u nobody -d "$n 0"
  >   n=$(expr $n + 1)
  > }

  $ ng=0
  $ create_git() {
  >   echo $1 > $1
  >   git add $1
  >   GIT_COMMITTER_DATE="@$ng +0000" GIT_AUTHOR_DATE="@$ng +0000" git commit -q -m ${2:-$1}
  >   ng=$(expr $ng + 1)
  > }

  $ export GIT_COMMITTER_NAME=nobody
  $ export GIT_COMMITTER_EMAIL=
  $ export GIT_AUTHOR_NAME=nobody
  $ export GIT_AUTHOR_EMAIL=

Create a mercurial repository.

  $ hg init hgrepo
  $ HGREPO=$(pwd)/hgrepo
  $ cd hgrepo
  $ for f in a b c; do create_hg $f --no-commit; done
  $ for f in d e f; do create_hg $f; done
  $ hg up -q -r 1
  $ create_hg g
  $ hg merge -q
  $ create_hg g merge 2>/dev/null

  $ hg log -G --template '{node} {branch} {desc}'
  @    bc15c20fd6a3a1fdd70f67f278b4374c6d5e3ed2 default merge
  |\
  | o  299c5a9b90df6fdd0dc2b3716a114545a6536394 default g
  | |
  o |  aa7250354ccc66f3c4b8d068fc00e5c1b0d8a838 default f
  |/
  o  695eafa9c5b95e82f2ebc39f9fb63fd2470862e8 default e
  |
  o  3d1f6f97e0be2f7faab7c8e2b3fe7dd139f492a2 default d
  
  $ cd ..

  $ git init -q -b main gitrepo
  $ cd gitrepo
  $ for f in a b c d e f; do create_git $f; done
  $ git checkout -q HEAD~
  $ create_git g
  $ git merge -q main --no-commit 2>/dev/null
  $ create_git g merge
  $ git checkout -q main
  $ git merge -q HEAD@{1}

  $ git log --oneline --graph
  *   4b7ce9d merge
  |\  
  | * d06f423 f
  * | 778db95 g
  |/  
  * 0a4d857 e
  * 5ba3548 d
  * a4b51d3 c
  * 13020e5 b
  * 78bbecb a

  $ git -c cinnabar.graft=true fetch -q hg::$HGREPO
  $ git log --oneline --graph --notes=cinnabar
  *   4b7ce9d merge
  |\  Notes (cinnabar):
  | |     changeset bc15c20fd6a3a1fdd70f67f278b4374c6d5e3ed2
  | |     manifest cd78cfd51d7278235f744c257dd402f6a118bc9b
  | |     patch 58,59,
  | | 
  | * d06f423 f
  | | Notes (cinnabar):
  | |     changeset aa7250354ccc66f3c4b8d068fc00e5c1b0d8a838
  | |     manifest 488092b4bec54565c630cdf953d5945e1a4993a0
  | |     files f
  | |     patch 56,57,
  | | 
  * | 778db95 g
  |/  Notes (cinnabar):
  |       changeset 299c5a9b90df6fdd0dc2b3716a114545a6536394
  |       manifest 3fb79d9a3901d9812a56e2fdfe3049d0b6c2f83a
  |       files g
  |       patch 56,57,
  |   
  * 0a4d857 e
  | Notes (cinnabar):
  |     changeset 695eafa9c5b95e82f2ebc39f9fb63fd2470862e8
  |     manifest 251ee6379d69fc281a21ff9890c4d4cb46c30336
  |     files e
  |     patch 56,57,
  | 
  * 5ba3548 d
  * a4b51d3 c
  * 13020e5 b
  * 78bbecb a

  $ git for-each-ref refs/cinnabar/replace
  c580451755f958f4ee1468e21633521d089710ac commit\trefs/cinnabar/replace/5ba3548eb05496c9f53b043260476fe94bd25172 (esc)
  $ git log --oneline --graph --notes=cinnabar c580451755f958f4ee1468e21633521d089710ac
  * c580451 d
    Notes (cinnabar):
        changeset 3d1f6f97e0be2f7faab7c8e2b3fe7dd139f492a2
        manifest 9c601042bb6720fc7b4364539cae4716791e5fda
        files a
        b
        c
        d
    

