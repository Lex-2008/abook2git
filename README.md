abook2git
=========

> A script to backup Baikal addressbook to git

**Reason**: if you store your addressbook on a [self-hosted Baïkal server][b]
(meaning you have access to its db.sqlite file),
you might want to save all contacts (vcards) to plaintext files and put them in git.

It will help in case you accidentally delete 50 less-frequently-used contacts from it,
and realise it only half a year later (happened to me).

Alternatively, you can use a WebDAV-interface access to the addressbook,
and with help of something like [davfs][] access all your contacts as plain files.
Then you don't need this script and can just copy them to a git repo,
`git add`, `git commit`, and `git push`!
(check `maybegit` function in the script file for exact set of commands)

[b]: https://sabre.io/baikal/
[davfs]: https://savannah.nongnu.org/projects/davfs2

Requirements
------------

* Self-hosted Baïkal server (so you have access to its db.sqlite file)

* A working backup system (so you have a copy of the above file, which _inode number_ changes every time there is a change) -
simplest it just to use `rsync` to copy that file somewhere

* A private git repo (github gives you few for free)

* `sqlite3` and `sqldiff` utilities -
while script might be adapted to work without the second one,
I haven't done so yet.

Installation
------------

1. clone this repo (or just take the [abook2git.sh][] file)

2. _On the same partition_ where you have your backup version of db.sqlite file,
find a place to keep its hardlink (it will be used to check for changes).

3. clone or init a private repo somewhere

[abook2git.sh]: abook2git.sh

Usage
-----

After your normal backup procedure (which includes rsync'ing db.sqlite from Baikal server to a backup place),
`cd` into directory with your private repo, and run:

	path/to/abook2git.sh path/to/rsynced/db.sqlite path/to/its/hardlink "$(date +"%F %T")"

How it works
------------

To quickly check if there were any changes in the database,
this script checks if the hardlink is still in place
(first two arguments to the script point to the same file).
This script relies on rsync (or other utility) to detect change in the database and break the hardlink.

After that, it exports all contacts into *.vcf files (one file per user),
and commits them to git, using output of `sqldiff --summary` as the commit message.
