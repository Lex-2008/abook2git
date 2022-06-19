#!/bin/sh

get_principaluris() {
	# $1 - sqlite db file
	# outputs data to stdout
	sqlite3 "$1" "select distinct principaluri from addressbooks"
}

db2txt() {
	# $1 - sqlite db file
	# $2 - principaluri
	# outputs data to stdout
	sqlite3 "$1" "select carddata from cards where addressbookid in (select id from addressbooks where principaluri='$2')"
}

principaluri2filename() {
	# cuts 'principals/ from the beginning, adds .vcf at the end'
	echo "$1" | sed 's_principals/__;s_$_.vcf_'
}

main() {
	# $1 - file to check
	# $2 - backup file
	# $3 - date, format understood by git commit --date
	# should be executed inside git repo
	new="$1"
	old="$2"
	date="$3"
	get_principaluris "$new" | while read -r principaluri; do
		db2txt "$new" "$principaluri" >"$(principaluri2filename "$principaluri")"
	done
	maybegit "$date" "$(sqldiff --summary --table cards "$old" "$new")"

	rm "$old"
	ln "$new" "$old"
}

maybegit() {
	# $1 - date
	# $2 - message, optional
	date="$1"
	msg="${2:-update at $date}"
	test "$(git status --porcelain)" = "" && return
	git add --all
	git commit --date="$date" --message="$msg"
	git push
}

test "$#" -lt 3 && exit 2 # pass 3 args: new_file, bak_file, date
test -f "$2" -a "$1" -ef "$2" && exit 0
main "$1" "$2" "$3"
