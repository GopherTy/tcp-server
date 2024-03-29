#!/bin/bash
#Program:
#       golang build scripts
#
#Email:
#       zuiwuchang@gmail.com
DirRoot=`cd $(dirname $BASH_SOURCE) && pwd`
Target=server
TestItems=(
)
function check(){
	if [ "$1" != 0 ] ;then
		exit $1
	fi
}
function mkDir(){
	mkdir -p "$1"
	check $?
}

function newFile(){
	echo "$2" > "$1"
	check $?
}
function writeFile(){
	echo "$2" >> "$1"
	check $?
}
function createGoVersion(){
	mkDir "$DirRoot/version"
	filename="$DirRoot/version/version.go"
	package=version


	tag=`git describe`
	if [ "$tag" == '' ];then
		tag="[unknown tag]"
	fi

	commit=`git rev-parse HEAD`
	if [ "$commit" == '' ];then
		commit="[unknow commit]"
	fi
	
	date=`date +'%Y-%m-%d %H:%M:%S'`

	echo $tag $commit
	echo $date

	newFile $filename	"package $package"
	writeFile $filename	''
	writeFile $filename	'// Tag git tag'
	writeFile $filename	"const Tag = \`$tag\`"
	writeFile $filename	'// Commit git commit'
	writeFile $filename	"const Commit = \`$commit\`"
	writeFile $filename	'// Date build datetime'
	writeFile $filename	"const Date = \`$date\`"
}

function DisplayHelp(){
	echo "help                       : display help"
	echo "l/linux   [r/d] [t/tar]    : build for linux"
	echo "d/darwin  [r/d] [t/tar]    : build for darwin"
	echo "w/windows [r/d] [t/tar]    : build for windows"
	echo "t/test                     : run go test"
}
case $1 in
	l|linux)
		export GOOS=linux

		createGoVersion
		if [[ $2 == d ]]; then
			Target="$Target"d
			echo go build -o "$DirRoot/bin/$Target"
			cd "$DirRoot" && go build -o "$DirRoot/bin/$Target"
		else
			echo go build -ldflags "-s -w" -o "$DirRoot/bin/$Target"
			cd "$DirRoot" && go build -ldflags "-s -w" -o "$DirRoot/bin/$Target"
		fi
		check $?

		if [[ $3 == tar || $3 == t ]]; then
			dst=linux.amd64.tar.gz
			if [[ $GOARCH == 386 ]];then
				dst=linux.386.tar.gz
			fi
			cd "$DirRoot/bin" && tar -zcvf $dst "$Target"
		fi
	;;

	d|darwin)
		export GOOS=darwin

		createGoVersion
		if [[ $2 == d ]]; then
			Target="$Target"d
			echo go build -o "$DirRoot/bin/$Target"
			cd "$DirRoot" && go build -o "$DirRoot/bin/$Target"
		else
			echo go build -ldflags "-s -w" -o "$DirRoot/bin/$Target"
			cd "$DirRoot" && go build -ldflags "-s -w" -o "$DirRoot/bin/$Target"
		fi
		check $?

		if [[ $3 == tar || $3 == t ]]; then
			dst=darwin.amd64.tar.gz
			if [[ $GOARCH == 386 ]];then
				dst=darwin.386.tar.gz
			fi
			cd "$DirRoot/bin" && tar -zcvf $dst "$Target"
		fi
	;;

	w|windows)
		export GOOS=windows

		createGoVersion
		if [[ $2 == d ]]; then
			Target="$Target"d
			echo go build -o "$DirRoot/bin/$Target.exe"
			cd "$DirRoot" && go build -o "$DirRoot/bin/$Target.exe"
		else
			echo go build -ldflags "-s -w" -o "$DirRoot/bin/$Target.exe"
			cd "$DirRoot" && go build -ldflags "-s -w" -o "$DirRoot/bin/$Target.exe"
		fi
		check $?

		if [[ $3 == tar || $3 == t ]]; then
			dst=windows.amd64.tar.gz
			if [[ $GOARCH == 386 ]];then
				dst=windows.386.tar.gz
			fi
			cd "$DirRoot/bin" && tar -zcvf $dst "$Target.exe"
		fi
	;;

	t|test)
		for i in ${!TestItems[@]}
		do
			cd "$DirRoot/${TestItems[i]}" && go test
		done
	;;

	*)
		DisplayHelp
	;;
esac