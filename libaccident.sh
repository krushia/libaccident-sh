#!/bin/sh
# kate: encoding utf-8; byte-order-mark off;
#
# libaccident.sh - libaccident for POSIXy shell scripts
#  IN DEVELOPMENT - UNUSABLE
#
# This is a library for making somewhat portable scripts.
#  It attempts to use bash and zsh extensions where possible
#  Otherwise falls back to POSIX default capabilities
#
# The secondary purpose of this library is to serve as an example
#  of how to do various things in scripts, as many of the functions
#  just pass arguments to another command.
#
#
# When referencing standards, openest onea go first.
#  IETF, W3C, etc
#
# Terminology used in libaccident
#
#  DIRECTORY
#   A URL or PATH to a directory
#  FILE
#   A URL or PATH to a regular file
#  PORT
#  INTEGER
#   A whole number
#  CHAR
#  FILENAME
#   The name of a regular file, usually the last part of a FILE
#  PATH
#   Location to a filesystem entity as accepted by operating system
#  URL
#   URI that points to the location of a FILE or  or CONTENT
#  HOST
#   HOSTNAME or ADDRESS
#  HOSTNAME
#   Textual name of a machine which must be converted to ADDRESS via resolver
#  ADDRESS
#
#
# Rules for naming functions
#  1. In classless languages, functions begin with 'la'
#  2. Following 'la', a lowercase identifier may be added
#    i = internal
#  3. The function is then named in CamelCase
#    CamelCase shall override normal case used in printed text"
#      "Print banana" --> laPrintBanana
#      "Run BASIC code" --> laRunBasicCode
#    If the language is case-insensitive, CamelCase shall be used regardless
#    If the language allows only one type of case, spelling shall remain same
#  4. Names must only contain a-z
#    + = p
#
#  5. The first TBD characters must be unique
#  6. The first
#  7. The following verbs have special meaning
#    Display = Show to human in human readable format
#    Print =
#    Ask = Request input from a human
#    Get = Get one string of data from a computer
#    List = Get many strings of data from a computer. Separated by newlines.
#    Return =
#  Is<object>
#
# Rules for naming global variables
#  1. All global variables begin with "la_"
#  2. The remainder of the variable is named in UPPER_CASE
#  3. Names may only contain A-Z (and underscore)

laInitialize() {
	if [ $ZSH_VERSION ]; then
		la_SHELL_TYPE='zsh'
	elif [ $BASH_VERSION ]; then
		la_SHELL_TYPE='bash'
	else
		la_SHELL_TYPE='unknown'
	fi

	# comment for development version
	# la_RELEASE=0

	# script version
	la_VERSION="development, cksum: $(cksum $0)"

	# script name
	la_NAME='libaccident'

	# long name
	la_LONG_NAME='libaccident-sh'

	# script filename
	la_FILENAME="$la_NAME.sh"

	# script called as
	la_CALLNAME="$0"

	# COMMENT
	declare -a la_FUNCTIONS

	# used as a pointer to array elements
	la_FUNCTION_INDEX=0

	# define color codes if tput is around
	if hash "tput" 2>/dev/null; then
		la_SGR0=$(tput sgr0)
		local bold=$(tput bold)
		local dim=$(tput dim)
		la_DIM_BLACK="$la_SGR0$dim$(tput setaf 0)"
		la_DIM_RED="$la_SGR0$dim$(tput setaf 1)"
		la_DIM_GREEN="$la_SGR0$dim$(tput setaf 2)"
		la_DIM_YELLOW="$la_SGR0$dim$(tput setaf 3)"
		la_DIM_BLUE="$la_SGR0$dim$(tput setaf 4)"
		la_DIM_MAGENTA="$la_SGR0$dim$(tput setaf 5)"
		la_DIM_CYAN="$la_SGR0$dim$(tput setaf 6)"
		la_DIM_WHITE="$la_SGR0$dim$(tput setaf 7)"
		la_BOLD_BLACK="$la_SGR0$bold$(tput setaf 0)"
		la_BOLD_RED="$la_SGR0$bold$(tput setaf 1)"
		la_BOLD_GREEN="$la_SGR0$bold$(tput setaf 2)"
		la_BOLD_YELLOW="$la_SGR0$bold$(tput setaf 3)"
		la_BOLD_BLUE="$la_SGR0$bold$(tput setaf 4)"
		la_BOLD_MAGENTA="$la_SGR0$bold$(tput setaf 5)"
		la_BOLD_CYAN="$la_SGR0$bold$(tput setaf 6)"
		la_BOLD_WHITE="$la_SGR0$bold$(tput setaf 7)"
		if [ $la_RELEASE ]; then
			la_VERSION_COLOR=$la_BOLD_WHITE
		else
			la_VERSION_COLOR=$la_BOLD_YELLOW
		fi
	fi

	la_TITLE="some script-foo using libaccident"

	if $la_OPTIONS; then
		echo WUT
	fi
}

laUnload() {
	# TODO: add terminal color vars
	unset -v la_SHELL_TYPE
	unset -v la_RELEASE
	unset -v la_VERSION
	unset -v la_NAME
	unset -v la_LONG_NAME
	unset -v la_FILENAME
	unset -v la_CALLNAME
	unset -v la_FUNCTIONS
	unset -v la_FUNCTION_INDEX
	unset -v la_TITLE
	unset -v la_OPTIONS
	unset -v la_OPT_DEBUG
	return 0
}

############################################################################
##### INTERNAL FUNCTIONS
############################################################################
# lai*() are functions meant for use within libaccident itself, and are
#  subject to change across minor versions and with little or no notice.

laiDefineFunction() {
	local f
	local i
	local o
	local d
	case $# in
		2 )
		# function, description
		local f=$1
		local d=$2
		;;
		4 )
		# function, input, output, description
		local f=$1
		local i=$2
		local o=$3
		local d=$4
		;;
	esac
	la_FUNCTIONS[$la_FUNCTION_INDEX]="\n${la_BOLD_WHITE}${f} ${la_BOLD_BLUE}${i}${la_SGR0}\n${d}"
	la_FUNCTION_INDEX=$(expr $la_FUNCTION_INDEX + 1)
}


laiDefineCollection() {
	return 0
}

laiDefineFunction 'laGetLastStack' '' 'OUT:text' 'Prints location of last command. Example output: /usr/lib/libaccident.sh:109'
laGetLastStack() {
	# no debug because debug uses this function
	if [ $la_SHELL_TYPE = "bash" ]; then
		echo -e "${BASH_SOURCE[1]}:${BASH_LINENO[1]}:"
	elif [ $la_SHELL_TYPE = "zsh" ]; then
		echo -e "${funcfiletrace[2]}:"
	else
		echo -e " Unsupported shell - cannot trace:"
	fi
}

# prints debug info
# z = start library function debug
# f = start of function debug
# p = pause
# a = ask to continue
# c = execute command
laiDefineFunction 'laDebug' 'Prints debug info.'
laDebug() {
	if [ $la_OPT_DEBUG ]; then
		local debugparamsave=$1
		if laSearchString - $debugparamsave; then
			shift
			if [ $la_SHELL_TYPE = "bash" ]; then
				if laSearchString z $debugparamsave; then
					echo -e "\t${la_DIM_BLUE}[z]${BASH_SOURCE[0]}:${BASH_LINENO[0]}:   ${FUNCNAME[@]}\n\t   ${BASH_SOURCE[0]}:${BASH_LINENO[0]}:   ${BASH_LINENO[@]}$la_SGR0" 1>&2
				elif laSearchString f $debugparamsave; then
					echo -e "\t${la_DIM_MAGENTA}[f]${BASH_SOURCE[0]}:${BASH_LINENO[0]}:  ${FUNCNAME[@]}\n\t   ${BASH_SOURCE[0]}:${BASH_LINENO[0]}:  ${BASH_LINENO[@]}$la_SGR0" 1>&2
				else
					echo -e "\t${la_BOLD_CYAN}[*]${BASH_SOURCE[0]}:${BASH_LINENO[0]}: $la_DIM_CYAN$@$la_SGR0" 1>&2
				fi
			elif [ $la_SHELL_TYPE = "zsh" ]; then
				#echo $funcfiletrace[@] 1>&2
				#echo $funcsourcetrace[@] 1>&2
				#echo $funcstack[@] 1>&2
				#echo $functrace[@] 1>&2
				if laSearchString z $debugparamsave; then
					echo -e "\t${la_DIM_BLUE}[z]${funcfiletrace[1]}:   ${funcstack[@]}\n\t   ${funcfiletrace[1]}:   ${funcfiletrace[@]}$la_SGR0" 1>&2
				elif laSearchString f $debugparamsave; then
					echo -e "\t${la_DIM_MAGENTA}[f]${funcfiletrace[1]}:  ${funcstack[@]}\n\t   ${funcfiletrace[1]}:  ${funcfiletrace[@]}$la_SGR0" 1>&2
				else
					echo -e "\t${la_BOLD_CYAN}[*]${funcfiletrace[1]}: $la_DIM_CYAN$@$la_SGR0" 1>&2
				fi
			else
				if laSearchString z $debugparamsave; then
					echo -e "\t${la_DIM_BLUE}[z] Unsupported shell - cannot trace$la_SGR0" 1>&2
				elif laSearchString f $debugparamsave; then
					echo -e "\t${la_DIM_MAGENTA}[f] Unsupported shell - cannot trace$la_SGR0" 1>&2
				else
					echo -e "\t${la_BOLD_CYAN}[*] Unsupported shell - cannot trace: $la_DIM_CYAN$@$la_SGR0" 1>&2
				fi
			fi

			if laSearchString c $debugparamsave; then
				if laSearchString a $debugparamsave && [ ! $debugallowall ]; then
					if [ $la_SHELL_TYPE = "bash" ]; then
						echo -e "\t${la_BOLD_RED}[c]${BASH_SOURCE[0]}:${BASH_LINENO[0]}:    Run \`${la_DIM_RED}$@${la_BOLD_RED}'? (Yes/No/All/Kill)$la_SGR0" 1>&2 && read debugallow
					elif [ $la_SHELL_TYPE = "zsh" ]; then
						echo -e "\t${la_BOLD_RED}[c]${funcfiletrace[1]}:    Run \`${la_DIM_RED}$@${la_BOLD_RED}'? (Yes/No/All/Kill)$la_SGR0" 1>&2 && read debugallow
					else
						echo -e "\t${la_BOLD_RED}[c] Unsupported shell - cannot trace:    Run \`${la_DIM_RED}$@${la_BOLD_RED}'? (Yes/No/All/Kill)$la_SGR0" 1>&2 && read debugallow
					fi
					if [ $debugallow = "a" ]; then
						debugallowall=0
					fi
				fi

				if [ $debugallow = "y" ] || [ $debugallowall ]; then
					"$@" || :
				elif [ ! $debugallow = "n" ]; then
					laDie 'terminated by debug'
				fi
			fi

			if laSearchString p $debugparamsave && [ ! $debugcontinueall ]; then
				echo -e "\t${la_BOLD_YELLOW}[p]$(laGetLastStack)     Continue? (Yes/No/All)$la_SGR0" 1>&2 && read debugcontinue
				if [ $debugcontinue = "a" ]; then
					debugcontinueall=0
				fi

				if [ $debugcontinue = "y" ] || [ $debugcontinueall ]; then
					return 0
				else
					laDie 'terminated by debug'
				fi
			else
				return 0
			fi
		else
			# Note that this is is a copy of stuff above when not z or f
			if [ $la_SHELL_TYPE = "bash" ]; then
				echo -e "\t${la_BOLD_CYAN}[*]${BASH_SOURCE[0]}:${BASH_LINENO[0]}: $la_DIM_CYAN$@$la_SGR0" 1>&2
			elif [ $la_SHELL_TYPE = "zsh" ]; then
				echo -e "\t${la_BOLD_CYAN}[*]${funcfiletrace[1]}: $la_DIM_CYAN$@$la_SGR0" 1>&2
			else
				echo -e "\t${la_BOLD_CYAN}[*] Unsupported shell - cannot trace: $la_DIM_CYAN$@$la_SGR0" 1>&2
			fi
			return 0
		fi
	else
		return 1
	fi
}

la() {
	local command="$1"
}

############################################################################
##### DEVELOPER UTILITIES
############################################################################
# These functions are general tools for the script-foo developer, and not
#  meant to be used in a script. As such, they may change slightly or even
#  vanish across minor versions and with little to no notice.

laiDefineFunction 'laGiveMeThePower' 'Prints information on portable shell scripting'
laGiveMeThePower() {
	cat <<-EOF
		${la_BOLD_WHITE}Useful links:$la_SGR0
		http://billharlan.com/pub/papers/Bourne_shell_idioms.html
		http://refspecs.linuxbase.org/
		http://www.unix.org/apis.html
		http://www.unix.org/version3/apis/cu.html

		${la_BOLD_WHITE}Did you know:$la_SGR0
		When displaying a URI, it is advised to enclose it in double quotes or angle brackets
		Variable names in all uppercase are reserved for POSIX-defined utilities. Your code MUST use lowercase in variable names.
		You should NEVER use echo. ALWAYS use printf.

		${la_BOLD_WHITE}Redirection:$la_SGR0
		Preferred:  Sloppy:
		<FILE       0<FILE
		            /dev/stdin<FILE
		FD<FILE     /dev/fd/FD<FILE
		>|FILE      >FILE
		            1>FILE
		            1>|FILE
		            /dev/stdout>FILE
		            /dev/stdout>|FILE
		FD>|FILE    FD>FILE
		&>FILE      >&FILE
		            >FILE 2>&1

		Practical redirection examples:
		Let command foo output o to stdout and e to stderr,
		Command:      1 2 \$f
		foo           o e
		foo >|\$f       e o
		foo

		${la_BOLD_WHITE}Bracket expansion:$la_SGR0
		[:alnum:]
		[:alpha:]
		[:blank:]
		[:cntrl:]
		[:digit:]
		[:graph:]
		[:lower:]
		[:print:]
		[:punct:]
		[:space:]
		[:upper:]
		[:xdigit:]



		${la_BOLD_WHITE}Pathname expansion:$la_SGR0
		* matches any series of char EXCEPT / or leading . in filename
		? matches any single char EXCEPT / or leading . in filename
		[ (bracket expansion) matches stuff EXCEPT / (and leading . is undefined)

		Need to add key to abbreviations and/or unabbreviated version
		${la_BOLD_WHITE}Positional parameters:$la_SGR0
		Starts at 1, indicates parameters passed to script if outside function, or to function if in function. May ONLY be changed with set and shift builtins. Note that \$N will fail if N>9. Use \${N}

		${la_BOLD_WHITE}Special parameters:$la_SGR0
		Note that these are PARAMETERS, and as such are prefixed with the $ character when used. These characters show up elsewhere in shellology (like globbing), which are UNRELATED. It is very important that you DO NOT CONFUSE contexts.
		*	All pos param starting from 1
		"*"	Same but all 1 word sep by 1st char of IFS if set, nothing if null, space if unset
		@	All pos param starting from 1
		"@"	Each param is a separate word. If used in word, 1st/last param start/end word
		#	Number of pos param
		?	Exit status of most recent foreground pipeline
		-	Option flags set on start by set or shell -i
		$	PID of the shell. In subshell \(\) it is PID of parent shell
		!	PID of most recent background command
		0	Name of shell script, unless not a script
		_	Absolute pathname of shell/script, gets chaotically useless after first read

		${la_BOLD_WHITE}Safe commands:$la_SGR0
		${la_BOLD_WHITE}Builtins:$la_SGR0
		break, colon, continue, dot, eval, exec, exit, export, readonly, return, set, shift, times, trap, unset
		${la_BOLD_WHITE}Utilities in POSIX:$la_SGR0


	EOF

	return 0
}

laiDefineFunction 'laColorDemo' 'Shows off terminal colors'
laColorDemo() {
	laDebug -z
	
}

laiDefineFunction 'laRtfm' 'Tries as hard as possible to get a manual page'
laRtfm() {
	laDebug -z
}

laiDefineFunction 'laGetRfcTitle' 'Returns the title of a RFC'
laGetRfcTitle() {
	laDebug -z
}

laiDefineFunction 'laGetRfcUrl' 'Returns a URL to a RFC. $1 is RFC, $2 is optional version'
laGetRfcUrl() {
	laDebug -z
}

laiDefineFunction 'laGetRfcText' 'Returns the text of a RFC. $1 is RFC, $2 is optional version'
laGetRfcText() {
	laDebug -z
}

laiDefineFunction 'laDie' '1:final_words' 'ERR:stuff' 'Prints the given message in blood red'
laDie() {
	echo "$la_DIM_RED""ERROR: $1""$la_SGR0" 1>&2
	exit 1
}

laiDefineFunction 'laGetUser' '' 'OUT:USERNAME' 'Prints the name of the controlling user'
laGetUser() {
	# TODO: Use id command
	laDebug -z
	case $(laPickCommand logname who) in
		logname )
		# NOTE: this is logged in user (not euid)
		# In Single UNIX Specification and Linux Standard Base
		# ... though fails in xterm on Gentoo
		if logname >/dev/null 2>&1; then
			echo $(logname)
			return 0
		fi
		;;
		who )
		# NOTE: this is logged in user (not euid). also same as who -m
		# Although `who am i' is POSIX, it often returns null on Gentoo
		# ... which is amusing, because "who" (no "am i") works
		echo $(who am i | awk '{print $1}')
		return 0
		;;
	esac
	if [ $USERNAME ]; then
		# Present in zsh
		laDebug 'Warning: laGetUser() exhausted all methods. Result may be wrong.'
		echo $USERNAME
		return 0
	fi
	laDie 'laGetUser() failed to find username.'
	return 1
}

laiDefineFunction 'laGetEffectiveUser' '' 'OUT:USERNAME' 'Prints the name of the effective user'
laGetEffectiveUser() {
	laDebug -z
	case $(laPickCommand id whoami) in
		id )
		id -nu
		return 0
		;;
		whoami )
		if whoami >/dev/null 2>&1; then
			echo $(whoami)
			return 0
		fi
		;;
	esac
	if [ $USER ]; then
		# NOTE: this is euid
		# Present in bash and zsh
		echo $USER
		return 0
	fi
	if [ $LOGNAME ]; then
		# NOTE: this is euid
		# Present in bash and zsh
		echo $LOGNAME
		return 0
	fi
	laDie 'laGetEffectiveUser() failed to find effective username.'
	return 1
}

laiDefineFunction 'laGetEuid' '' 'OUT:UID' 'Prints the effective user ID (EUID)'
laGetEuid() {
	laDebug -z
	case $(laPickCommand id) in
		id )
		id -u
		return 0
		;;
	esac
	if [ $EUID ]; then
		# Present in bash and zsh
		echo $EUID
		return 0
	fi
	laDie 'laGetEuid() failed to find EUID'
	return 1
}

laiDefineFunction 'laGetHome' '1:USERNAME' 'OUT:PATH' 'Prints the given users home directory. Uses controlling user if none specified'
laGetHome() {
	laDebug -z
	if [ -n "$1" ]; then
		local gethomeuser=$1
	else
		local gethomeuser=$(laGetUser)
	fi
	eval echo ~$gethomeuser
	return 0
}

############################################################################
##### STRING FUNCTIONS
############################################################################
# These functions all operate on one or more strings.
#  laGet*() input a single string and print something on stdout
#  la

laiDefineFunction 'laGetStringLength' 'Prints the length of the given string'
laGetStringLength() {
	if [ $la_SHELL_TYPE = "bash" ]; then
		for i in "$@"; do
	    	echo ${#i}
		done
	else
		echo -n "$@" | wc -c
	fi
	return 0
}

laiDefineFunction 'laSearchString' '1:what_to_find 2:string_to_search' '' 'Returns 0 if first string is found anywhere in second string.'
laSearchString() {
	# no debug because debug uses this function
	case $2 in
		*$1* )
		return 0
		;;
	esac
	return 1
}

laSplitString() {
	laDebug -z
	echo -n "$1" | awk -F"$2" '{ print $3 }'
}

laStartsWith() {
	laDebug -z
}

laEndsWith() {
	laDebug -z
}

laIsAlpha() {
	laDebug -z
}

laIsNumeric() {
	laDebug -z
}

laIsAlphaNumeric() {
	laDebug -z
}

laIsWhitespace() {
	laDebug -z
}

laContainsWhitespace() {
	laDebug -z
}

laiDefineFunction 'laToLower' '1:string' 'OUT:string' 'Turns all uppercase characters into lowercase'
laToLower() {
	laDebug -z
	echo $@ | tr [:upper:] [:lower:]
}

laiDefineFunction 'laToUpper' '1:string' 'OUT:string' 'Turns all lowercase characters into uppercase'
laToUpper() {
	laDebug -z
	echo $@ | tr [:lower:] [:upper:]
}

laiDefineFunction 'laArrayToList' 'Turns an array into a la list'
laArrayToList() {
	laDebug -z
	echo $@
}

laControlToSymbolic() {
	laDebug -z
	echo $@ | tr '\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040' '␀␁␂␃␄␅␆␇␈␉␊␋␌␍␎␏␐␑␒␓␔␕␖␗␘␙␚␛␜␝␞␟'
}

############################################################################
##### URL FUNCTIONS
############################################################################
# These functions operate on a URL (not to be confused with URI).
#  Supported schemes are as follows:
#  Scheme
#  file
#   Accepted forms:
#    file:/HOST/PATH
#    file:PATH
#     HOST is either localhost, 127.0.0.1, $(hostname), or an empty string
#     PATH is an absolute path with automagical / (/etc/passwd == etc/passwd)
#      Warning: if no trailing / given, a file will be chosen over a directory
#   Normalized to:
#    file://PATH
#     Where PATH is an absolute path, with leading / and trailing / if directory
#   Normalization examples (where /etc is directory and /etc/passwd is file):
#    file:/localhost/etc -> file:///etc/
#    file:/localhost//etc/ -> file:///etc/
#    file://///127.0.0.1/////////etc////passwd -> file:///etc/passwd
#    file:etc/passwd -> file:///etc/passwd
#
# ip_server = [user [ : password ] @ ] host [ : port]

laiDefineFunction 'laNormalizeUrl' 'Inputs a less-than-perfect URL as a string, cleans it up and spits it out. Mostly follows advice in URI(7) Linux man-page. Note that some schemes (like info) are handled differently based on detection of Gnome/KDE dominant systems'
laNormalizeUrl() {
	laDebug -z
	local scheme=$(laUrlScheme "$1")
	case $scheme in
		http )
		return 0
		;;
	esac
}

laiDefineFunction 'laNormalizeAndCheckUrl' 'Like laNormalizeUrl, but also makes sure it exists.'
laNormalizeAndCheckUrl() {
	laDebug -z
}

laEscapeUrl() {
	# Originally stolen from Bo Ørsted Andresen's wgetpaste
	# debug start # this borks the sed below
	sed -e 's|%|%25|g' -e 's|&|%26|g' -e 's|+|%2b|g' -e 's| |+|g' "$@" || die "sed failed"
}

laUnescapeUrl() {
	# debug start # this borks the sed below
	sed -e 's|%25|%|g' -e 's|&|%26|g' -e 's|+|%2b|g' -e 's| |+|g' "$@" || die "sed failed"
}

laMountUrl() {
	laDebug -z
}

laUrlCouldBeMountable() {
	laDebug -z
}

laiDefineFunction 'laUrlScheme' 'Prints the scheme portion of a URL'
laUrlScheme() {
	# called by: laNormalizeUrl
	# executes: awk
	laDebug -z
	echo "$1" | awk -F: '{ print $1 }'
	# non-awk
	# echo "$1" | grep :// | sed -e's,^\(.*://\).*,\1,g'
}

laUrlUsername() {
	laDebug -z
	# extract the scheme
	local scheme="$(echo $1 | grep :// | sed -e's,^\(.*://\).*,\1,g')"

	# remove the protocol -- updated
	local url=$(echo $1 | sed -e s,$scheme,,g)

	# extract the user (if any)
	local user="$(echo $url | grep @ | cut -d@ -f1)"

	# extract the host -- updated
	local host=$(echo $url | sed -e s,$user@,,g | cut -d/ -f1)

	# extract the path (if any)
	path="$(echo $url | grep / | cut -d/ -f2-)"
}

laUrlPassword() {
	laDebug -z
}

laUrlPort() {
	laDebug -z
}

laUrlHost() {
	laDebug -z
}

laiDefineFunction 'laSplitUrl' 'Returns an array in the form SCHEME USER PASSWORD HOST PORT DIRECTORY OBJECT FRAGMENT'
laSplitUrl() {
	laDebug -z
}

laUrlIsDirectory() {
	laDebug -z
}

laUrlIsContent() {
	laDebug -z
}

laiDefineFunction 'laPathToUrl' 'Transforms a local path into a file:// URI'
laPathToUrl() {
	laDebug -z
	echo 'file://'$(laEscapeUrl "$1")
	return 0
}

laUrlToPath() {
	laDebug -z
	local url=$(laNormalizeUrl "$1")
}

laiDefineFunction 'laDoesUrlExist' 'Returns 0 if specified URL is accessable'
laDoesUrlExist() {
	laDebug -z
	if hash "curl" 2>/dev/null; then
		local getCommand='curl -fsI'
	elif hash "wget" 2>/dev/null; then
		local getCommand='wget -q --spider'
	else
		laDie "laDoesUrlExist() failed to find a supported downloader."
		return 1
	fi
	return $($getCommand $1)
}

laiDefineFunction 'laDownload' '1:URL 2:PATH' '' 'Downloads URL in first parameter to location in second parameter. Returns 0 upon success'
laDownload() {
	laDebug -z
	if hash "curl" 2>/dev/null; then
		local getCommand="curl -o $2 $1"
	elif hash "wget" 2>/dev/null; then
		local getCommand="wget -O $2 $1"
	else
		laDie "laDownload() failed to find a supported downloader."
		return 1
	fi
	return $($getCommand)
}

laiDefineFunction 'laPing' '1:HOST' '' 'Accepts a HOST and returns 0 if reachable, 1 if not'
laPing() {
	if ping -c 1 "$1" >/dev/null 2>&1; then
		return 0
	else
		return 1
	fi
}


############################################################################
##### GEOSPATIAL FUNCTIONS
############################################################################


############################################################################
##### LANGUAGE FUNCTIONS
############################################################################


############################################################################
##### TABLE FUNCTIONS
############################################################################
# CSV
#  Document content as specified in RFC 4180
# TSV
#  Document content as specified in http://www.iana.org/assignments/media-types/text/tab-separated-values

############################################################################
##### JSON FUNCTIONS
############################################################################
# https://github.com/dominictarr/JSON.sh/blob/master/JSON.sh

############################################################################
##### XML FUNCTIONS
############################################################################


############################################################################
##### INI FUNCTIONS
############################################################################


############################################################################
#####  FUNCTIONS
############################################################################


############################################################################
##### COMMAND EXECUTION FUNCTIONS
############################################################################

laiDefineFunction 'laPickCommands' 'Takes an ordered list of commands, and prints with invalid commands removed. Returns 0 if result has at least one item, 1 if empty.'
laPickCommands() {
	laDebug -z
	local valid=()
	for i in $@; do
		if hash "$i" 2>/dev/null; then
			valid+=("$i")
		fi
	done
	if [ ! $valid ]; then
		return 1
	fi
	echo ${valid[*]}
	return 0
}

laPickCommand() {
	laDebug -z
	for i in $@; do
		if hash "$i" 2>/dev/null; then
			echo "$i"
			return 0
		fi
	done
	return 1
}

############################################################################
##### HTML FUNCTIONS
############################################################################


laiDefineFunction 'laTextToHtml' 'IN:tacos' 'OUT:html 1:FILE' 'Converts plain text to HTML, with no styling. Use this to generate your website and you shall be loved forever'
laTextToHtml() {
	laDebug -z
	case $(laPickCommand dialog kdialog Xdialog) in
		dialog )
		dialog --title "$la_TITLE" --insecure --passwordbox "$1" 0 0
		return 0
		;;
		kdialog )
		kdialog --title "$la_TITLE" --password "$1"
		return 0
		;;
		Xdialog )
		Xdialog --title "$la_TITLE" --password --inputbox "$1" 0 0
		return 0
		;;
	esac
}

############################################################################
##### HMI FUNCTIONS
############################################################################
#
# sgr standout underline reverse blink dim bold invis protect altcharset

# TODO: FINISH
laPickDialogCommand() {
	laDebug -z
	if [ $KDE_FULL_SESSION ]; then
		local tryorder=(kdialog Xdialog xmessage gtkdialog dialog)
	fi
}

laiDefineFunction 'laAskPassword' 'Asks user for a password, using the string in $1. Prints to stdout.'
laAskPassword() {
	laDebug -z
	case $(laPickCommand dialog kdialog Xdialog) in
		dialog )
		dialog --title "$la_TITLE" --insecure --passwordbox "$1" 0 0
		return 0
		;;
		kdialog )
		kdialog --title "$la_TITLE" --password "$1"
		return 0
		;;
		Xdialog )
		Xdialog --title "$la_TITLE" --password --inputbox "$1" 0 0
		return 0
		;;
	esac
}

laiDefineFunction 'laAskString' 'Asks user for a string, using the string in $1. Prints to stdout.'
laAskString() {
	laDebug -z
	case $(laPickCommand dialog kdialog Xdialog) in
		dialog )
		dialog --title "$la_TITLE" --inputbox "$1" 0 0
		return 0
		;;
		kdialog )
		kdialog --title "$la_TITLE" --inputbox "$1"
		return 0
		;;
		Xdialog )
		Xdialog --title "$la_TITLE" --inputbox "$1" 0 0
		return 0
		;;
	esac
}

laiDefineFunction 'laAskDate' 'Asks user for a date, using the string in $1. Prints to stdout.'
laAskDate() {
	# TODO: normalize date formats
	laDebug -z
	case $(laPickCommand dialog kdialog) in
		dialog )
		dialog --title "$la_TITLE" --calendar "$1" 0 0 0 0 0
		return 0
		;;
		kdialog )
		kdialog --title "$la_TITLE" --calendar "$1"
		return 0
		;;
	esac
}

laiDefineFunction 'laGetTermColors' '' 'OUT:colors' 'Get the number of colors the terminal supports'
laGetTermColors() {
	laDebug -z
	case $(laPickCommand tput) in
		tput )
		tput colors
		return 0
		;;
	esac
	return 1
}

laiDefineFunction 'laGetTermColumns' '' 'OUT:columns' 'Get the width of the terminal in characters'
laGetTermColumns() {
	laDebug -z
	case $(laPickCommand tput) in
		tput )
		tput cols
		return 0
		;;
	esac
	if [ $COLUMNS ]; then
		echo $COLUMNS
		return 0
	fi
	return 1
}

laiDefineFunction 'laGetTermLines' '' 'OUT:lines' 'Get the height of the terminal in characters'
laGetTermLines() {
	laDebug -z
	case $(laPickCommand tput) in
		tput )
		tput lines
		return 0
		;;
	esac
	if [ $LINES ]; then
		echo $LINES
		return 0
	fi
	return 1
}

laiDefineFunction 'laTermStandout' '' 'OUT:code' 'Output control code to enter standout mode'
laTermStandout() {
	case $(laPickCommand tput) in
		tput )
		tput smso
		return 0
		;;
	esac
}

laiDefineFunction 'laTermUnStandout' '' 'OUT:code' 'Output control code to exit standout mode'
laTermUnStandout() {
	case $(laPickCommand tput) in
		tput )
		tput rmso
		return 0
		;;
	esac
}

laiDefineFunction 'laTermUnderline' '' 'OUT:code' 'Output control code to enter underline mode'
laTermUnderline() {
	case $(laPickCommand tput) in
		tput )
		tput smul
		return 0
		;;
	esac
}

laiDefineFunction 'laTermUnUnderline' '' 'OUT:code' 'Output control code to exit underline mode'
laTermUnUnderline() {
	case $(laPickCommand tput) in
		tput )
		tput rmul
		return 0
		;;
	esac
}

laiDefineFunction 'laTermReverse' '' 'OUT:code' 'Output reverse control code'
laTermReverse() {
	case $(laPickCommand tput) in
		tput )
		tput rev
		return 0
		;;
	esac
}

laiDefineFunction 'laTermBlink' '' 'OUT:code' 'Output control code to enter blink mode'
laTermBlink() {
	case $(laPickCommand tput) in
		tput )
		tput blink
		return 0
		;;
	esac
}

# NOTE: There is no UnBlink

laiDefineFunction 'laTermDim' '' 'OUT:code' 'Output dim control code'
laTermDim() {
	case $(laPickCommand tput) in
		tput )
		tput dim
		return 0
		;;
	esac
}

laiDefineFunction 'laTermBold' '' 'OUT:code' 'Output bold control code'
laTermBold() {
	case $(laPickCommand tput) in
		tput )
		tput bold
		return 0
		;;
	esac
}

laiDefineFunction 'laTermSecure' '' 'OUT:code' 'Output control code to enter secure (invis) mode. In this mode characters are not shown (useful for password entry)'
laTermSecure() {
	case $(laPickCommand tput) in
		tput )
		tput invis
		return 0
		;;
	esac
}

laiDefineFunction 'laTermProtect' '' 'OUT:code' 'Output control code to enter protected mode'
laTermProtect() {
	case $(laPickCommand tput) in
		tput )
		tput prot
		return 0
		;;
	esac
}

laiDefineFunction 'laTermAltcharset' '' 'OUT:code' 'Output altcharset control code'
laTermAltcharset() {
	case $(laPickCommand tput) in
		tput )
		tput altcharset
		return 0
		;;
	esac
}

laiDefineFunction 'laTermItalic' '' 'OUT:code' 'Output control code to enter italic mode'
laTermItalic() {
	case $(laPickCommand tput) in
		tput )
		tput sitm
		return 0
		;;
	esac
}

laiDefineFunction 'laTermUnItalic' '' 'OUT:code' 'Output control code to exit italic mode'
laTermUnItalic() {
	case $(laPickCommand tput) in
		tput )
		tput ritm
		return 0
		;;
	esac
}

laBeginPretty() {
	laDebug -z
	
}

############################################################################
##### DATE/TIME FUNCTIONS
############################################################################
# The term "Time' refers to any string that contains calendar time in one
#  of the following formats (searched in order)
# 1. milliseconds since 1970-01-01 00:00:00 UTC
# A. YYYYMMDDHHMM
# B. YYMMDDHHMM
# C. YYYY-MM-DD-HHMM
# D. YY-MM-DD-HHMM
# E. YYYY-MM-DD
# F. YY-MM-DD

laGetTime() {
	laDebug -z
}

laCouldBeTimestamp() {
	laDebug -z
}

laiDefineFunction 'laTimeToUnixSeconds' 'Prints representation of given time as seconds since 1970-01-01 00:00:00 UTC. Uses current time if none is given.'
laTimeToUnixSeconds() {
	laDebug -z
	if [ -n "$1" ]; then
		if date -d \'$@\' +%s 2>/dev/null; then
			return 0
		fi
	else
		if date +%s 2>/dev/null; then
			return 0
		fi
	fi
	return 1
}

laiDefineFunction 'laTimeToUnixMilliseconds' 'Prints representation of given time as milliseconds since 1970-01-01 00:00:00 UTC. Uses current time if none is given.'
laTimeToUnixMilliseconds() {
	laDebug -z
	if [ -n "$1" ]; then
		if date -d \'$@\' +%s 2>/dev/null; then
			return 0
		fi
	else
		if date +%s 2>/dev/null; then
			return 0
		fi
	fi
	return 1
}

laTimeToRfc2822() {
	laDebug -z
}

laTimeToRfc3339Date() {
	laDebug -z
}

laTimeToRfc3339Seconds() {
	laDebug -z
}

laTimeToRfc3339Nanoseconds() {
	laDebug -z
}

laTimeToYear() {
	laDebug -z
}

laGetLocalUtcOffset() {
	laDebug -z
}

############################################################################
##### MATH FUNCTIONS
############################################################################

laAsciiCharToDec() {
	laDebug -z
}

laDecToAsciiChar() {
	laDebug -z
}

laUtfCharToDec() {
	laDebug -z
}

laDecToUtfChar() {
	laDebug -z
}

laIsNumberOfBase() {
	laDebug -z
}

laIsIntegerOfBase() {
	laDebug -z
}

laAbs() {
	# Same as Python abs(x)
	# Return the absolute value of a number. The argument may be a plain or long integer or a floating point number. If the argument is a complex number, its magnitude is returned.
	laDebug -z
	local a=$1
	echo "$a" | sed s/-//
}

laBin() {
	# Same as Python bin(x)
	# Convert an integer number to a binary string.
	laDebug -z
	echo 'ibase=10;obase=2;'"$1" | bc
}

laCmp() {
	# Same as Python cmp(x, y)¶
	# Compare the two objects x and y and return an integer according to the outcome. The return value is negative if x < y, zero if x == y and strictly positive if x > y.
	laDebug -z
	if [ $1 < $2 ]; then
		return -1
	elif [ $1 -eq $2 ]; then
		return 0
	elif [ $1 > $2 ]; then
		return 1
	fi
}

laHex() {
	# Same as Python hex(x)
	# Convert an integer number to a hexadecimal string.
	laDebug -z
	echo 'ibase=10;obase=16;'"$1" | bc
}

laOct() {
	# Same as Python oct(x)
	# Convert an integer number to an octal string.
	laDebug -z
	echo 'ibase=10;obase=8;'"$1" | bc
}

laiDefineFunction 'laIsPrime' 'Returns 0 if the given integer is prime'
laIsPrime() {
	laDebug -z
	if ! laIsOdd $1; then
		return 1
	fi
	if [ $1 -lt 0 ]; then
		# 13 was pulled out my ass
		local e=$(expr -$1 / 13 + 1)
	else
		local e=$(expr $1 / 13 + 1)
	fi
	local i=3
	while [ $e -gt $i ]; do
		laDebug "i is $i"
		if [ $(expr $1 % $i) -eq 0 ]; then
			laDebug "$1 was factored by $i"
			return 1
		fi
		 i=$(expr $i + 2)
	done
	return 0
}

laiDefineFunction 'laIsOdd' 'Returns 0 if the given integer is odd'
laIsOdd() {
	laDebug -z
	#local i=0
	local i=$(expr $1 % 2)
	if [ $i -ne 0 ]; then
		return 0
	fi
	return 1
}

laiDefineFunction 'laIsEven' 'Returns 0 if the given integer is even'
laIsEven() {
	laDebug -z
	#local i=0
	local i=$(expr $1 % 2)
	if [ $i -eq 0 ]; then
		return 0
	fi
	return 1
}

laiDefineFunction 'laSqrt' 'Prints the square root of the given number'
laSqrt() {
	laDebug -z
	echo "sqrt( $1 )" | bc
}




laPastebinFile() {
	laDebug -z
}

laPastebinContent() {
	laDebug -z
}

laFileCouldBeCompressed() {
	laDebug -z
}

laUncompressFile() {
	laDebug -z
}

laCompressFiles() {
	laDebug -z
}

############################################################################
##### OS FUNCTIONS
############################################################################

laiDefineFunction 'laGnuStat' 'Portable replacement for GNU coreutils stat -c FORMAT FILE command'
laStat() {
	laDebug -z
	local fmt="$1"
	local file="$2"
	case $fmt in
		%a )
		#  Access rights in octal
		laPermToOctal $(ls -ld "$file" | awk '{print $1}')
		;;
		%A )
		#  Access rights in human readable form
		ls -ld "$file" | awk '{print $1}'
		;;
		# %b
		#  Number of blocks allocated (see %B)
		# %B
		#  The size in bytes of each block reported by %b
		# %C
		#  SELinux security context string
		# %d
		#  Device number in decimal
		# %D
		#  Device number in hex
		# %f
		#  Raw mode in hex
		# %F
		#  File type
		%g )
		#  Group ID of owner
		laUserToUid $(ls -ld "$file" | awk '{print $4}')
		;;
		%G )
		#  Group name of owner
		ls -ld "$file" | awk '{print $4}'
		;;
		# %h
		#  Number of hard links
		%i )
		#  Inode number
		ls -i "$file" | awk '{print $1}'
		;;
		# %n
		#  File name
		# %N
		#  Quoted file name with dereference if symbolic link
		# %o
		#  I/O block size
		# %s
		#  Total size, in bytes
		# %t
		#  Major device type in hex
		# %T
		#  Minor device type in hex
		%u )
		#  User ID of owner
		laUserToUid $(ls -ld "$file" | awk '{print $3}')
		;;
		%U )
		#  User name of owner
		ls -ld "$file" | awk '{print $3}'
		;;
		# %x
		#  Time of last access
		# %X
		#  Time of last access as seconds since Epoch
		# %y
		#  Time of last modification
		# %Y
		#  Time of last modification as seconds since Epoch
		# %z
		#  Time of last change
		# %Z
		#  Time of last change as seconds since Epoch
	esac

}

laiDefineFunction 'laGnuWhich' 'Portable replacement for the GNU which command'
laGnuWhich() {
	laDebug -z
	command -v $@
}

laiDefineFunction 'laPermToOctal' 'Convert a human readable file permission string like -rwxr-xr-- to octal'
laPermToOctal() {
	# TODO: Make sure this works across BSD too
	# TODO: Find out where this came from and give credit
	laDebug -z
	local a=$(echo "$1" | cut -c4,7,10 | tr xstST- 011110)
	local b=$(echo "$1" | cut -c2-10 | tr rwsxtST- 11111000)
	echo "obase=8;ibase=2;${a}${b}" | bc
}

laCanUserReadFile() {
	laDebug -z
}

laCanUserWriteFile() {
	laDebug -z
}

laCanUserExecuteFile() {
	laDebug -z
}

laIsUserInGroup() {
	laDebug -z
}

laOctalToPerm() {
	laDebug -z
}

laiDefineFunction 'laGetFileOwner' 'Prints the name of the user who owns specified file'
laGetFileOwner() {
	laDebug -z
	ls -ld "$file" | awk '{print $3}'
}

laiDefineFunction 'laGetFileGroup' 'Prints the name of the group who owns specified file'
laGetFileGroup() {
	laDebug -z
	ls -ld "$file" | awk '{print $4}'
}

# TODO: use id command for user/group stuff

laiDefineFunction 'laUserToUid' 'Prints the UID of the given user name'
laUserToUid() {
	laDebug -z
	grep -E '^'"$1"':' /etc/passwd | awk -F: '{ print $3 }'
	return 0
	return 1
}

laiDefineFunction 'laUidToUser' '1:UID' 'OUT:USER' 'Prints the name of the user with the given UID'
laUidToUser() {
	laDebug -z
	grep -E '^.*'"$1"':' /etc/passwd | awk -F: '{ print $1 }'
	return 0
	return 1
}

laiDefineFunction 'laGroupToGid' 'Prints the GID of the given group name'
laGroupToGid() {
	laDebug -z
	grep -E '^'"$1"':' /etc/group | awk -F: '{ print $3 }'
	return 0
	return 1
}

laiDefineFunction 'laGidToGroup' 'Prints the name of the group with the given GID'
laGidToGroup() {
	laDebug -z
	grep -E '^.*'"$1"':' /etc/group | awk -F: '{ print $1 }'
	return 0
	return 1
}

laDevicePathResidesOn() {
	laDebug -z
}

laPathIsOnLocalFilesystem() {
	laDebug -z
}

laPathIsOnRemoteFilesystem() {
	laDebug -z
}

laPathIsOnPseudoFilesystem() {
	laDebug -z
}

laIsDeviceMounted() {
	laDebug -z
}

laiDefineFunction 'laHostToIp' '1:HOST' 'OUT:IP' 'Resolves a HOST to IP'
laHostToIp() {
	# Kudos to Chris Down via <http://unix.stackexchange.com/a/20793>
	laDebug -z
	local host="$1"
	case $(laPickCommand dig host nslookup) in
		dig )
		dig +short "$host" | awk 'NR > 1 { exit } ; 1'
		# another way to do it
		#dig "$host" | awk '/^;; ANSWER SECTION:$/ { getline ; print $5 ; exit }'
		return 0
		;;
		host )
		host "$host" | awk '/^[[:alnum:].-]+ has address/ { print $4 ; exit }'
		return 0
		;;
		nslookup )
		nslookup "$host" | awk '/^Address: / { print $2 ; exit }'
		return 0
		;;
	esac
	return 1
}

laIpToHost() {
	laDebug -z
}

############################################################################
##### EMAIL FUNCTIONS
############################################################################


laObsfucateEmailAddress() {
	laDebug -z
}

laUnobsfucateEmailAddress() {
	laDebug -z
}

laCouldBeEmailAddress() {
	laDebug -z
}

laCouldBeIpAddress() {
	laDebug -z
}


############################################################################
##### IRC FUNCTIONS
############################################################################


laiDefineFunction 'laConnectToIrc' '1:ADDRESS 2:PORT 3:IRC_NICK 4:IRC_PASS 5:IRC_SESSION' 'OUT:IRC_SESSION' 'Connects to IRC.'
laConnectToIrc() {
	laDebug -z
}

laiDefineFunction 'laDisonnectFromIrc' '1:IRC_SESSION' '' 'Disconnects an active IRC session'
laDisonnectFromIrc() {
	laDebug -z
}

laiDefineFunction 'laJoinIrcChannel' '1:IRC_SESSION 2:IRC_CHANNEL'
laJoinIrcChannel() {
	laDebug -z
}

# some kinda irc script function


############################################################################
##### SYS FUNCTIONS
############################################################################


laiDefineFunction 'laIsThisLinux' 'Returns 0 if operating system is Linux'
laIsThisLinux() {
	laDebug -z
	if [ $(uname) = "Linux" ]; then
		return 0
	fi
	return 1
}

laIsThisBsd() {
	laDebug -z
}

laIsThisFreeBsd() {
	laDebug -z
}

laIsThisWindows() {
	laDebug -z
}

laIsThisFuntoo() {
	laDebug -z
}

laiDefineFunction 'laIsThisGentooBased' 'Returns 0 if distro is Gentooy'
laIsThisGentooBased() {
	laDebug -z
	if [ -f /etc/gentoo-release ]; then
		return 0
	fi
	return 1
}

laIsThisGentooProper() {
	laDebug -z
	if [ -f /etc/gentoo-release ]; then
		return 0
	fi
	return 1
}

laIsThisWebos() {
	laDebug -z
}

laIsUserlandGnu() {
	laDebug -z
}

laIsUserlandBusybox() {
	laDebug -z
}

laIsUserlandGnu() {
	laDebug -z
}

laGetSysCpuCount() {
	laDebug -z
}

laGetSysRamBytes() {
	laDebug -z
}

laiDefineFunction 'laGetLinCpuGovenor' 'Prints the govenor used for the given CPU, or the first CPU if none specified.'
laGetLinCpuGovenor() {
	laDebug -z
	if [ -z $1 ]; then
		local id='0'
	else
		local id=$1
	fi
	cat $(laGetSysfsPath)/devices/system/cpu/cpu${id}/cpufreq/scaling_governor
}

laiDefineFunction 'laSetLinCpuGovenor' 'Sets the govenor ($1) used for the given CPU ($2), or the first CPU if none specified.'
laSetLinCpuGovenor() {
	laDebug -z
	if [ -z $2 ]; then
		local id='0'
	else
		local id=$2
	fi
	echo "$1" > $(laGetSysfsPath)/devices/system/cpu/cpu${id}/cpufreq/scaling_governor
}

laiDefineFunction 'laGetLinBogomips' 'Prints the sum of all CPU bogomips'
laGetLinBogomips() {
	laDebug -z
	local s=0
	for i in $(grep bogomips $(laGetProcfsPath)/cpuinfo | awk '{print $3}'); do
		s=$(echo "$i"'+'"$s" | bc)
	done
	echo $s
}

laiDefineFunction 'laGetProcfsPath' 'Prints the path of a procfs mount'
laGetProcfsPath() {
	# TODO: Is this reliable and should we use /proc/mounts
	laDebug -z
	grep -m1 -e '^proc' /etc/mtab | awk '{print $2}'
}

laiDefineFunction 'laGetSysfsPath' 'Prints the path of a sysfs mount'
laGetSysfsPath() {
	# TODO: Is this reliable and should we use /proc/mounts
	laDebug -z
	grep -m1 -e '^sysfs' /etc/mtab | awk '{print $2}'
}

############################################################################
##### PACKAGE MANAGEMENT FUNCTIONS
############################################################################
# PACKAGE
# ARCH
#####

# Gentoo
#
# portageq
#  package sys-apps/portage
#  Unknown stability
#  
# q*
#  package app-portage/portage-utils
#  Compiled, so should work
#  The options -C (no color) and -q (quiet) should always be used
#
# equery
#  package app-portage/gentoolkit
#  Written in Python, so won't work if Python broken
#  The options -C (no color) and -q (quiet) should always be used
#
# eix
#  package app-portage/eix
#  Uses own cache, and known to break on bleeding edge portage (incl. Funtoo)
#  USE AS A LAST RESORT
#
# euse
#  package app-portage/gentoolkit
#  SEE MANPAGE FOR LIMITATIONS
#  Output is pretty unparsable
#
# PACKAGE_CATEGORY
# PACKAGE_NAME
# PACKAGE_VERSION
# PACKAGE_SLOT

laiDefineFunction 'laUpdateRepoCache' '' '' 'Updates the local cache of available repository contents'
laUpdateRepoCache() {
	laDebug -z
	if laIsThisGentooBased; then
		emerge --sync
		layman -S
		eix-update
	elif laIsThisWebos; then
		ipkg-opt update
	fi
}

laiDefineFunction 'laGetPackageOwningFile' '1:PATH' 'OUT:PACKAGE' 'Print package that file belongs to'
laGetPackageOwningFile() {
	laDebug -z
	if laIsThisGentooBased; then
		case $(laPickCommand qfile equery) in
			qfile )
			qfile -Cq "$1" 2>/dev/null
			;;
			equery )
			equery -Cq b -n "$1"
			;;
		esac
	fi
}

laiDefineFunction 'laListFilesOwnedByPackage' '1:PACKAGE' 'OUT:PATHS' 'Lists files owned by a package'
laListFilesOwnedByPackage() {
	laDebug -z
	if laIsThisGentooBased; then
		case $(laPickCommand qlist equery) in
			qlist )
			qlist -Cq "$1" 2>/dev/null
			;;
			equery )
			equery -Cq f "$1"
			;;
		esac
	elif laIsThisWebos; then
		# ipkg -V 0 files "$1" | grep -e '^/'
		ipkg-opt -V 0 files "$1" | grep -e '^/'
	fi
}

laiDefineFunction 'laListInstalledPackages' '' 'OUT:PACKAGES' 'Lists packages installed on the system'
laListInstalledPackages() {
	laDebug -z
	if laIsThisGentooBased; then
		case $(laPickCommand qlist equery eix) in
			qlist )
			qlist -CqI
			;;
			equery )
			equery -Cq l --format='$cp' '*'
			;;
			portageq )
			portageq match / ''
			;;
			eix )
			eix -I --only-names
			;;
		esac
	elif laIsThisWebos; then
		ipkg-opt -V 0 list_installed
	fi
}

laIsPackageInstalled() {
	laDebug -z
}

laiDefineFunction 'laGetPackageCategory' '1:PACKAGE' 'OUT:PACKAGE_CATEGORY' 'Prints the category a package belongs to'
laGetPackageCategory() {
	laDebug -z
	local pkg="$1"
	if laIsThisGentooBased; then
		case $(laPickCommand qatom) in
			qatom )
			qatom $(portageq match / "$pkg") | awk '{print $1}'
			;;
		esac
	fi
}

laiDefineFunction 'laGetPackageName' '1:PACKAGE' 'OUT:PACKAGE_NAME' 'Prints the name of a package'
laGetPackageName() {
	laDebug -z
	local pkg="$1"
	if laIsThisGentooBased; then
		case $(laPickCommand qatom) in
			qatom )
			qatom $(portageq match / "$pkg") | awk '{print $2}'
			;;
		esac
	fi
}

laListAvailablePackages() {
	laDebug -z
}

laiDefineFunction 'laGetPackageDescription' '1:PACKAGE' 'OUT:description' 'Prints a description of the package'
laGetPackageDescription() {
	laDebug -z
	if laIsThisGentooBased; then
		case $(laPickCommand equery) in
			equery )
			equery -Cq m -d "$1"
			;;
		esac
	fi
}

laGetPackageHomepage() {
	laDebug -z
}

laListAvailablePackageVersions() {
	laDebug -z
}

laListInstalledPackageVersions() {
	laDebug -z
}

laListPackageOptions() {
	laDebug -z
}

laDisplayPackageInfo() {
	laDebug -z
	local pkg="$1"
	echo ${la_BOLD_GREEN}$(laGetPackageCategory "$pkg")${la_SGR0}"/"${la_BOLD_GREEN}$(laGetPackageName "$pkg")${la_SGR0}
	echo -e "\t"${la_DIM_GREEN}"Available versions:  "${la_SGR0}
	echo -e "\t"${la_DIM_GREEN}"Homepage:            "${la_SGR0}$(laGetPackageHomepage "$pkg")
	echo -e "\t"${la_DIM_GREEN}"Description:         "${la_SGR0}$(laGetPackageDescription "$pkg")
}

# happy help
laUsage() {
	laDebug -f
	local anti="kenru"
	local spam="shia"

	cat <<-EOF
		$la_BOLD_CYAN$la_NAME$la_DIM_CYAN ($la_LONG_NAME)$la_VERSION_COLOR $version
		$la_SGR0 An abominable collection of various shell functions for your sourcing pleasure.
		 For support, contact $la_BOLD_BLUE$la_NAME@$anti$spam$junk.com$la_SGR0

		${la_BOLD_WHITE}Usage:$la_SGR0 source $la_CALLNAME [options]

		${la_BOLD_WHITE}Options:$la_SGR0
		  -h, --help                    show this help
		      --version                 show version information

		      --debug                   print some script debug info
		      --trace                   clobber your screen with an ugly stack trace

		${la_BOLD_WHITE}Functions:$la_SGR0
		$(echo -ne ${la_FUNCTIONS[*]})
	EOF
	return 0
}

laiSelfTestPositionals() {
	# Function MUST be called EXACTLY as follows
	# laiSelfTestPositionals a "a" 'a' "a a" 'a a'
	# variable naming:
	#  c = combined declare/assign
	#  i = independent declare/assign
	#   q = " quote
	#    d = $ dollar
	#     b = { bracket
	#      S = * star
	#      A = @ at
	#       b = } bracket
	#        q = " quote
	local cdS=$*
	local cqdSq="$*"
	local cdbSb=${*}
	local cqdbSbq="${*}"
	local cdA=$@
	local cqdAq="$@"
	local cdbAb=${@}
	local cqdbAbq="${@}"
	if [ $# -ne 5 ]; then
		laDie FAIL
	elif [ $1 != a ]; then
		laDie FAIL
	elif [ $2 != a ]; then
		laDie FAIL
	elif [ $3 != a ]; then
		laDie FAIL
	elif [ $4 != 'a a' ]; then
		laDie FAIL
	elif [ $5 != 'a a' ]; then
		laDie FAIL
	elif [ ${1} != a ]; then
		laDie FAIL
	elif [ ${2} != a ]; then
		laDie FAIL
	elif [ ${3} != a ]; then
		laDie FAIL
	elif [ ${4} != 'a a' ]; then
		laDie FAIL
	elif [ ${5} != 'a a' ]; then
		laDie FAIL
	fi
}

laSelfTest() {
	echo "Initiating self test..."
	echo "${la_DIM_BLACK}BLACK"
	echo "${la_DIM_RED}RED"
	echo "${la_DIM_GREEN}GREEN"
	echo "${la_DIM_YELLOW}YELLOW"
	echo "${la_DIM_BLUE}BLUE"
	echo "${la_DIM_MAGENTA}MAGENTA"
	echo "${la_DIM_CYAN}CYAN"
	echo "${la_DIM_WHITE}WHITE"

	local c=0
	while [ $c -ne 8 ]; do
		echo "$(tput setaf $c )Hai" # ${c} $(tput dim) hai ${c} $(tput bold ) HAI ${c} $(tput sgr0)"
		c=$(expr $c + 1)
	done

	local paramsave=${*}
	laDebug -z
	laiSelfTestPositionals a "a" 'a' "a a" 'a a'
}

if [ "$(basename $0)" == "libaccident.sh" ]; then
	laInitialize
	### read cli options
	while [ -n "$1" ]; do
		((args=1))
		case "$1" in
			--trace )
			if [ $la_SHELL_TYPE = "bash" ]; then
				export PS4='${la_DIM_YELLOW}+${BASH_SOURCE}:${LINENO}:${FUNCNAME[0]}:${la_SGR0} '
			elif [ $la_SHELL_TYPE = "zsh" ]; then
				export PS4='${la_DIM_YELLOW}+${funcfiletrace}:${funcstack[1]}:${la_SGR0} '
			fi
			set -x
			;;
			--debug )
			la_OPT_DEBUG=0
			;;
			-h | --help )
			laUsage && exit 0
			;;
			--version )
			echo "$la_BOLD_CYAN$la_NAME$la_DIM_CYAN ($la_LONG_NAME) ${la_VERSION_COLOR}${la_VERSION}${la_SGR0}" && exit 0
			;;
			* )
			laDie "$0: unrecognized option \`$1'"
			;;
		esac
		shift $args
	done

	# Debug output to spew before running main code
	if [ $la_OPT_DEBUG ]; then
		laDebug "Detected shell as $la_SHELL_TYPE"
	fi
fi

#laSelfTest
#laGiveMeThePower
