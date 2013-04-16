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
# The following verbs have special meaning when used anywhere
#    Display = Show to human in human readable format
#    Print =
#    Ask = Request input from a human
#    Get = Get one string of data from a computer
#    List = Get many strings of data from a computer. Separated by newlines.
#    Return =
#
#
# Rules for naming functions
#
#  { ---
#   Names must only contain a-z. If the name includes a term whose grammatical
#    spelling normally includes non-alphabetic characters, these characters
#    should be replaced per the defacto alphabetic for that term. If no
#    defacto exists, replacements shall be made as follows:
#     a = @ at
#     b
#     c = : colon
#     d = . dot
#     e = = equal
#     f
#     g = > greater
#     h = # hash
#     i = ; sem(i)colon
#     j
#     k
#     l = < less
#     m = % modulus
#     n = - negative
#     o
#     p = + plus
#     q = " quote
#     r
#     s = * star
#     t = ~ tilde
#     u = _ underscore
#     v = | vertical
#     w = ? what
#     x
#     y
#     z
#
#  idfk = ` ! $ ^ & () [] {} \ ' , /
#
#     For currency symbols, use an uppercase character from the following table
#      if the context allows. Otherwise spell out the term verbatim.
#     C = ¢ cent
#     D = $ dollar
#     E = € euro
#     F = ₣ franc
#     G = ₵ ghana cedi
#     K = ₭ kip
#     L = £ lira or pound (lb)
#     N = ₦ naira
#     T = ₸ tenge
#     W = ₩ won
#     Y = ¥ yen
#
#  idfk = ₡ ₢ 
#
#  --- }
#
#  1. In classless languages, functions begin with 'la'
#
#  2. Following 'la', a lowercase identifier may be added
#      i = internal
#      t = test
#
#  { ---
#  The remainder is then named in CamelCase, disregarding english grammar
#     ( such that "Run BASIC code" --> laRunBasicCode )
#    If the language is case-insensitive, CamelCase shall be used regardless
#    If the language allows only one type of case, spelling shall remain same
#  --- }
#
#  3. The first CamelCase term shall follow the first of these rules that apply
#   a. If the function would be a method in an object-oriented language, then
#       the first argument of the function shall be of an la type, and the
#       first word in the CamelCase shall be the same. In the case of a type
#      	conversion, a reverse should be made and named appropriately.
#   b. If the function produces an la type but does not input an la type,
#      the second word shall be "From"
#  4. 
#
#  5. The first TBD characters must be unique
#
#
# Rules for naming global variables
#  1. All global variables begin with "la_"
#  2. If the variable can be deleted without consequence, 
#      the next part shall be "tmp"
#  3. The remainder of the variable is named in UPPER_CASE
#  4. Names may only contain A-Z (and underscore)
#
#
# Suggested reading for portable scripting
#  http://www.freebsd.org/doc/en_US.ISO8859-1/books/porters-handbook/dads-avoiding-linuxisms.html
#  https://wiki.ubuntu.com/DashAsBinSh
#
#
# TODO
#  laClipboardSearch - Searches any clipboard history for the text



# These functions operate on a PATH (not to be confused with URL).
#  Supported forms are as follows:
#  absolute
#   Accepted forms:
#    /PART[/PART]
#    ///PART/
#     PART must not 
#   Normalized to:
#    PATH
#     Where PATH is an absolute path, with leading / and trailing / if directory
#   Normalization examples (where /etc is directory and /etc/passwd is file):
#    /etc/ -> /etc
#    //etc/ -> UNDEFINED
#    /// -> /
#    //////////////// -> /
#    ////////etc//////
#    file://///127.0.0.1/////////etc////passwd -> file:///etc/passwd
#    file:etc/passwd -> file:///etc/passwd
# /usr/src/linux/.config
# ^^^^^^^^^^^^^^         DIRECTORY
#                ^^^^^^^ FILENAME
# ^^^^^^^^^^^^^^^^^^^^^^ PATH
# ^^^^^^^^^^^^^^^^^^^^^^ FILE



laInitialize() {
	# TODO: check if we already initialized, cuz this will clear la_FUNCTIONS
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
	# BUG: $0 isn't this script when sourcing and/or run like "bash ..."
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

	if [ $la_OPTIONS ]; then
		echo WUT
	fi
}

laUnload() {
	# TODO: use a wrapper for set that adds vars to a list for automagical nuke
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

	unset -v la_SGR0

	unset -v la_DIM_BLACK
	unset -v la_DIM_RED
	unset -v la_DIM_GREEN
	unset -v la_DIM_YELLOW
	unset -v la_DIM_BLUE
	unset -v la_DIM_MAGENTA
	unset -v la_DIM_CYAN
	unset -v la_DIM_WHITE
	unset -v la_BOLD_BLACK
	unset -v la_BOLD_RED
	unset -v la_BOLD_GREEN
	unset -v la_BOLD_YELLOW
	unset -v la_BOLD_BLUE
	unset -v la_BOLD_MAGENTA
	unset -v la_BOLD_CYAN
	unset -v la_BOLD_WHITE

	unset -v la_VERSION_COLOR
	return 0
}

############################################################################
##### INTERNAL FUNCTIONS
############################################################################
# lai*() are functions meant for use within libaccident itself, and are
#  subject to change across minor versions and with little or no notice.

laiDefineDatatype() {
	return 0
}

#  DIRECTORY
#   A URL or PATH to a directory
laiDefineDatatype 'DIRECTORY' 'URL PATH'
#  FILE
#   A URL or PATH to a regular file
laiDefineDatatype 'FILE' 'URL PATH'
#  PORT
laiDefineDatatype 'PORT' 'INTEGER'
#  INTEGER
#   A whole number
laiDefineDatatype 'INTEGER' ''
#  CHAR
#  FILENAME
#   The name of a regular file, usually the last part of a FILE
#   POSIX defines this as "Filename"
laiDefineDatatype 'FILENAME' ''
#  PATH
#   Location to a filesystem entity as accepted by operating system
#   POSIX defines this as "Pathname"
laiDefineDatatype 'PATH' ''
#  URL
#   URI that points to the location of a FILE or  or CONTENT
laiDefineDatatype 'URL' 'URI'
#  HOST
#   HOSTNAME or IP_ADDRESS
laiDefineDatatype 'HOST' 'HOSTNAME IP_ADDRESS'
#  HOSTNAME
#   Textual name of a machine which must be converted to IP_ADDRESS via resolver
laiDefineDatatype 'HOSTNAME' ''
#  IP_ADDRESS
laiDefineDatatype 'IP_ADDRESS' 'IP4_ADDRESS IP6_ADDRESS'
laiDefineDatatype 'IP4_ADDRESS' ''
laiDefineDatatype 'IP6_ADDRESS' ''

laiDefineDatatype 'TSV_FILE' 'FILE'
laiDefineDatatype 'CSV_FILE' 'FILE'
laiDefineDatatype 'DIZ_FILE' 'FILE'
laiDefineDatatype '' ''
laiDefineDatatype 'AUDIO_FILE' 'FILE'



# TIME
#  Nanoseconds since POSIX epoch
laiDefineDatatype 'TIME' 'INTEGER'

laiDefineFunction() {
	# function
	local f
	# input
	local i
	# output
	local o
	# description
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
			local i="$2"
			local o="$3"
			local d=$4
		;;
		* )
			laDie "Something called laiDefineFunction with invalid number of arguments"
			return 1
		;;
	esac
	la_FUNCTIONS[$la_FUNCTION_INDEX]="\n${la_BOLD_WHITE}${f} ${la_BOLD_BLUE}${i}${la_SGR0}\n${d}"
	la_FUNCTION_INDEX=$(expr $la_FUNCTION_INDEX + 1)
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
##### GENERAL
############################################################################
#
# media-libs/libsoundtouch == soundstretch

if [ ]; then
___GENERAL___() {
	return 0
}
fi


############################################################################
##### AUDIO
############################################################################
#
# media-libs/libsoundtouch == soundstretch

if [ ]; then
___AUDIO___() {
	return 0
}
fi

laiDefineFunction 'laAudioBpm' '1:AUDIO_FILE' 'OUT:bpm' 'Prints the average tempo of the input audio in beats per minute. The algorithm is unspecified.'
laAudioBpm() {
	laDebug -z
	case $(laPickCommand bpmdetect soundstretch) in
		bpmdetect )
			bpmdetect -cp "$1" | awk '{ print $1 }'
		;;
		soundstretch )
			# TODO: CONVERT TO WAV FIRST
			soundstretch "$1" -bpm 2>&1 | grep 'Detected BPM rate' | awk '{ print $4 }'
		;;
	esac
}

laiDefineFunction 'laAudioChannels' '1:AUDIO_FILE' 'OUT:channels' 'Prints number of channels in AUDIO_FILE'
laAudioChannels() {
	laDebug -z
	case $(laPickCommand ecalength) in
		ecalength )
			ecalength -sf "$1" | awk -F, '{print $2}'
		;;
	esac
}

laiDefineFunction 'laAudioSamplerate' '1:AUDIO_FILE' 'OUT:hz' 'Prints number of samples per second in AUDIO_FILE'
laAudioSamplerate() {
	laDebug -z
	case $(laPickCommand ecalength) in
		ecalength )
			ecalength -sf "$1" | awk -F, '{print $2}'
		;;
	esac
}

############################################################################
##### FILE
############################################################################

if [ ]; then
___FILE___() {
	return 0
}
fi

laiDefineFunction 'laFileMimetype' '1:FILE' 'OUT:MIMETYPE' 'Finds the MIMETYPE of the given FILE using whatever is available on the system for mime databases'
laFileMimetype() {
	# WARNING: Commands may not output same text. In particular,
	#  application/x-foo and text/x-foo are commonly swapped around for scripts
	# This behavior stems from different mime databases. On Gentoo:
	#  file uses /usr/share/misc/magic.mgc
	#  xdg-mime uses /usr/share/mime/magic
	#  kmimetypefinder also uses /usr/share/mime/magic and stuffs (i think)
	# Other stuff with (limited) mime magic:
	#  gst-typefind-0.10
	laDebug -z
	case $(laPickCommand xdg-mime file kmimetypefinder) in
		xdg-mime )
			xdg-mime query filetype "$1"
		;;
		file )
			file -b --mime-type "$1"
		;;
		kmimetypefinder )
			kmimetypefinder "$1" | head -1
		;;
	esac
}


laiDefineFunction 'laFileMd5' '1:FILE' 'OUT:md5' 'Prints the md5 hash of FILE'
laFileMd5() {
	# WARNING: Collisions can be artificially created, so not for security
	laDebug -z
	case $(laPickCommand md5sum md5 openssl) in
		md5sum )
			# GNU coreutils
			md5sum "$1" | awk '{ print $1 }'
		;;
		md5 )
			# BSD
			#  TODO: Check historical availability of -q
			md5 -q "$1"
		;;
		openssl )
			#  TODO: Check historical availability of -r
			openssl md5 -r "$1" | awk '{ print $1 }'
		;;
	esac
}

laiDefineFunction 'laFileSha1' '1:FILE' 'OUT:sha1' 'Prints the sha1 hash of FILE'
laFileSha1() {
	laDebug -z
	case $(laPickCommand sha1sum shasum openssl) in
		sha1sum )
			# GNU coreutils
			sha1sum "$1" | awk '{ print $1 }'
		;;
		shasum )
			shasum -a 1 "$1"
		;;
		openssl )
			#  TODO: Check historical availability of -r
			openssl sha1 -r "$1" | awk '{ print $1 }'
		;;
	esac
}

laiDefineFunction 'laFileSha224' '1:FILE' 'OUT:sha224' 'Prints the sha224 hash of FILE'
laFileSha224() {
	laDebug -z
	case $(laPickCommand sha224sum shasum openssl) in
		sha224sum )
			# GNU coreutils
			sha224sum "$1" | awk '{ print $1 }'
		;;
		shasum )
			shasum -a 224 "$1"
		;;
		openssl )
			#  TODO: Check historical availability of -r
			openssl sha224 -r "$1" | awk '{ print $1 }'
		;;
	esac
}

laiDefineFunction 'laFileSha256' '1:FILE' 'OUT:sha256' 'Prints the sha256 hash of FILE'
laFileSha256() {
	laDebug -z
	case $(laPickCommand sha256sum shasum openssl) in
		sha256sum )
			# GNU coreutils
			sha256sum "$1" | awk '{ print $1 }'
		;;
		shasum )
			shasum -a 256 "$1"
		;;
		openssl )
			#  TODO: Check historical availability of -r
			openssl sha256 -r "$1" | awk '{ print $1 }'
		;;
	esac
}

laiDefineFunction 'laFileSha384' '1:FILE' 'OUT:sha384' 'Prints the sha384 hash of FILE'
laFileSha384() {
	laDebug -z
	case $(laPickCommand sha384sum shasum openssl) in
		sha384sum )
			# GNU coreutils
			sha384sum "$1" | awk '{ print $1 }'
		;;
		shasum )
			shasum -a 384 "$1"
		;;
		openssl )
			#  TODO: Check historical availability of -r
			openssl sha384 -r "$1" | awk '{ print $1 }'
		;;
	esac
}

laiDefineFunction 'laFileSha512' '1:FILE' 'OUT:sha512' 'Prints the sha512 hash of FILE'
laFileSha512() {
	laDebug -z
	case $(laPickCommand sha512sum shasum openssl) in
		sha512sum )
			# GNU coreutils
			sha512sum "$1" | awk '{ print $1 }'
		;;
		shasum )
			shasum -a 512 "$1"
		;;
		openssl )
			#  TODO: Check historical availability of -r
			openssl sha512 -r "$1" | awk '{ print $1 }'
		;;
	esac
}

# laFileIsReadableByUser
# laUser...
laFileIsReadableByUser() {
	laDebug -z
	case $# in
		1 )
			if [ -r "$1" ]; then
				return 0
			fi
			return 1
		;;
		2 )
			echo FIXME
		;;
	esac
}

laCanUserWriteFile() {
	laDebug -z
}

laCanUserExecuteFile() {
	laDebug -z
}



laiDefineFunction 'laFileOwningUsername' 'Prints the name of the user who owns specified file'
laFileOwningUsername() {
	laDebug -z
	ls -ld "$1" | awk '{print $3}'
}

laiDefineFunction 'laFileOwningGroupname' 'Prints the name of the group who owns specified file'
laFileOwningGroupname() {
	laDebug -z
	ls -ld "$1" | awk '{print $4}'
}

laiDefineFunction 'laFileSize' 'Prints the size, in bytes, of the specified file'
laFileSize() {
	laDebug -z
	ls -ld "$1" | awk '{print $5}'
}



############################################################################
##### GID FUNCTIONS
############################################################################

if [ ]; then
___GID___() {
	return 0
}
fi

# TODO: use id command for user/group stuff

laiDefineFunction 'laGidToGroup' 'Prints the name of the group with the given GID'
laGidToGroup() {
	laDebug -z
	grep -E '^.*'"$1"':' /etc/group | awk -F: '{ print $1 }'
	return 0
	return 1
}

############################################################################
##### GROUP FUNCTIONS
############################################################################

if [ ]; then
___GROUP___() {
	return 0
}
fi

laiDefineFunction 'laGroupToGid' 'Prints the GID of the given group name'
laGroupToGid() {
	laDebug -z
	grep -E '^'"$1"':' /etc/group | awk -F: '{ print $3 }'
	return 0
	return 1
}

############################################################################
##### HOSTNAME FUNCTIONS
############################################################################

if [ ]; then
___HOSTNAME___() {
	return 0
}
fi

laiDefineFunction 'laHostToIp' '1:HOST' 'OUT:IP' 'Resolves a HOST to IP'
laHostToIp() {
	# TODO:
	#  DNSSD (using tools and/or own client)
	#  automagically try to use dns server at default gateway
	#  CATCH FAILURES
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

############################################################################
##### MIMETYPE
############################################################################

if [ ]; then
___MIMETYPE___() {
	return 0
}
fi

laiDefineFunction 'laMimetypeToSourceCodeLanguage' 'asdf'
laMimetypeToSourceCodeLanguage() {
	laDebug -z
	case $1 in
		text/x-shellscript )
			printf 'sh'
		;;
	esac
}

laiDefineFunction 'laMimetypeToFileExtension' '1:MIMETYPE' 'OUT:extension' 'Converts a MIMETYPE to a file extension (does not include the dot) using whatever is available on the system for mime databases'
laMimetypeToFileExtension() {
	# TODO: add aliases
	# FIXME: do exact match (application/x-sh != application/x-shockwave-flash)
	laDebug -z
	if [ -f /etc/mime.types ]; then
		grep -m 1 -r '^'"$1" /etc/mime.types | awk '{print $2}' | awk '{print $1}'
	elif [ -f /usr/share/mime/globs ]; then
		grep -m 1 -r '^'"$1" /usr/share/mime/globs | awk -F: '{print $2}' | awk -F. '{print $2}'
	fi
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

if [ ]; then
___PACKAGE___() {
	return 0
}
fi

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
	elif laIsThisWebos; then
		# ipkg -V 0 search "$1" | awk '{ print $1 }'
		ipkg-opt -V 0 search "$1" | awk '{ print $1 }'
	fi
}

laiDefineFunction 'laPackageFilesOwnedBy' '1:PACKAGE' 'OUT:PATHS' 'Lists files owned by a package'
laPackageFilesOwnedBy() {
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

# laPackageListInstalled
laiDefineFunction 'laListInstalledPackages' '' 'OUT:PACKAGES' 'Lists packages installed on the system'
laListInstalledPackages() {
	laDebug -z
	if laIsThisGentooBased; then
		case $(laPickCommand qlist equery portageq eix) in
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
		# ipkg -V 0 list_installed | awk '{ print $1 }'
		ipkg-opt -V 0 list_installed | awk '{ print $1 }'
	fi
}

# 
laiDefineFunction 'laPackageListInstalledDependingOn' '1:PACKAGE' 'OUT:PACKAGES' 'Lists packages that are installed on the system and depend on the given package.'
laPackageListInstalledDependingOn() {
	laDebug -z
	local pkg="$1"
	if laIsThisGentooBased; then
		case $(laPickCommand qdepends equery eix) in
			qdepends )
			qdepends -CqN -Q "$pkg" 2>/dev/null
			;;
			equery )
			equery -Cq d "$pkg"
			;;
			eix )
			eix -I --only-names --deps "$pkg"
			;;
		esac
	fi
}
alias laListInstalledPackagesDependingOnPackage=laPackageListInstalledDependingOn

# 
laiDefineFunction 'laPackageIsDependedOn' '1:PACKAGE' '' 'Returns 0 if package is a dependency of any installed packages, otherwise 1.'
laPackageIsDependedOn() {
	laDebug -z
	local pkg="$1"
	if laIsThisGentooBased; then
		case $(laPickCommand eix) in
			eix )
			if eix -q -0 -I --deps "$pkg"; then
				return 0
			fi
			;;
		esac
	fi
	return 1
}
alias laIsPackageDependedOn=laPackageIsDependedOn


laPackageIsInstalled() {
	laDebug -z
}

laiDefineFunction 'laPackageCategory' '1:PACKAGE' 'OUT:PACKAGE_CATEGORY' 'Prints the category a package belongs to'
laPackageCategory() {
	laDebug -z
	local pkg="$1"
	if laIsThisGentooBased; then
		case $(laPickCommand qatom equery) in
			qatom )
			qatom $(portageq match / "$pkg") | awk '{print $1}'
			;;
			equery )
			equery -Cq l --format='$category' "$pkg"
			;;
		esac
	fi
}
alias laGetPackageCategory=laPackageCategory

# laPackageToName
laiDefineFunction 'laPackageName' '1:PACKAGE' 'OUT:PACKAGE_NAME' 'Prints the name of a package'
laPackageName() {
	laDebug -z
	local pkg="$1"
	if laIsThisGentooBased; then
		case $(laPickCommand qatom equery) in
			qatom )
			qatom $(portageq match / "$pkg") | awk '{print $2}'
			;;
			equery )
			equery -Cq l --format='$name' "$pkg"
			;;
		esac
	fi
}
alias laGetPackageName=laPackageName

laPackagesAvailable() {
	laDebug -z
}


laiDefineFunction 'laPackageDescription' '1:PACKAGE' 'OUT:description' 'Prints a description of the package'
laPackageDescription() {
	laDebug -z
	if laIsThisGentooBased; then
		case $(laPickCommand equery) in
			equery )
			# NOTE: this prints extended description, not short one. Not always available.
			equery -Cq m -d "$1"
			;;
		esac
	fi
}
alias laGetPackageDescription=laPackageDescription

laiDefineFunction 'laPackageHomepage' '1:PACKAGE' 'OUT:URL' 'Prints the homepage of the package (if specified by packager)'
laPackageHomepage() {
	laDebug -z
	if laIsThisGentooBased; then
		case $(laPickCommand equery) in
			equery )
			equery -Cq m "$1" | grep -e '^Homepage' | awk '{print $2}'
			;;
		esac
	fi
}
alias laGetPackageHomepage=laPackageHomepage

laiDefineFunction 'laPackageInstallerFile' '1:PACKAGE' 'OUT:FILE' 'Prints the location of a the deb/ebuild/ipk/rpm/etc for a package. Note that the format of PACKAGE should include specific version information, as only one result is returned. If no version is specified, a currently installed version will be used. Otherwise the bahavior is undefined.'
laPackageInstallerFile() {
	laDebug -z
	
}

laPackageAvailableVersions() {
	laDebug -z
}

laPackageInstalledVersions() {
	laDebug -z
}

laPackageOptions() {
	laDebug -z
}

laPackageDisplayInfo() {
	laDebug -z
	local pkg="$1"
	echo ${la_BOLD_GREEN}$(laGetPackageCategory "$pkg")${la_SGR0}"/"${la_BOLD_GREEN}$(laGetPackageName "$pkg")${la_SGR0}
	echo -e "\t"${la_DIM_GREEN}"Available versions:  "${la_SGR0}
	echo -e "\t"${la_DIM_GREEN}"Homepage:            "${la_SGR0}$(laGetPackageHomepage "$pkg")
	echo -e "\t"${la_DIM_GREEN}"Description:         "${la_SGR0}$(laGetPackageDescription "$pkg")
}

############################################################################
##### PATH FUNCTIONS
############################################################################

if [ ]; then
___PATH___() {
	return 0
}
fi

laiDefineFunction 'laPathNormalize' 'Inputs a less-than-perfect PATH as a string, cleans it up and spits it out as an absolute path. If the input is a relative path, it is interpreted with the contents of $PWD'
laPathNormalize() {
	laDebug -z
	echo CODE ME
}

laiDefineFunction 'laPathIsAbsolute' '1:PATH' '' 'Returns 0 if PATH is absolute'
laPathIsAbsolute() {
	laDebug -z
	echo CODE ME
}

laiDefineFunction 'laPathIsRelative' '1:PATH' '' 'Returns 0 if PATH is relative'
laPathIsRelative() {
	laDebug -z
	echo CODE ME
}

laiDefineFunction 'laPathFromHome' '1:USERNAME' 'OUT:PATH' 'Prints the given users home directory. Uses controlling user if none specified'
laPathFromHome() {
	laDebug -z
	if [ -n "$1" ]; then
		local gethomeuser=$1
	else
		# TODO: Check for $HOME first
		local gethomeuser=$(laUserFromLogin)
	fi
	eval echo ~$gethomeuser
	return 0
}

laiDefineFunction 'laPathToUrl' 'Transforms a local path into a file:// URI'
laPathToUrl() {
	laDebug -z
	echo 'file://'$(laUrlEscape "$1")
	return 0
}

laiDefineFunction 'laPathToUrl' 'Transforms a local path into a file:// URI'
laPathToUrl() {
	laDebug -z
	echo 'file://'$(laUrlEscape "$1")
	return 0
}

############################################################################
##### PID FUNCTIONS
############################################################################

if [ ]; then
___PID___() {
	return 0
}
fi

laiDefineFunction 'laPidsAccessingPath' '1:PATH' 'OUT:PIDs' 'If PATH is a regular file, list the PID of each process that has that file open. If PATH is a DIRECTORY or a mount point, every file within is checked.'
laPidsAccessingPath() {
	laDebug -z
	fuser "$1" 2>/dev/null | awk -v b="$2" '{ print index($0, b) }'
}

############################################################################
##### RANDOM
############################################################################

if [ ]; then
___RANDOM___() {
	return 0
}
fi

laiDefineFunction 'laRandomInteger' '1:INTEGER 2:INTEGER' 'OUT:INTEGER' 'Prints a random integer between those specified. Or, if only one argument is given, prints a random integer between 0 and the argument.'
laRandomInteger() {
	# TODO FINIDH ME
	# FIXME HANDLE NEGATIVES
	case $# in
		1 )
			if [ $(echo "0<$1" | bc) = '1' ]; then
				local min=0
				local range=$1
			else
				local min=$1
				local range=$(echo "$1-$2" | bc)
			fi
		;;
		2 )
			if [ $(echo "$1<$2" | bc) = '1' ]; then
				local min=$1
				local range=$(echo "$2-$1" | bc)
			else
				local min=$2
				local range=$(echo "$1-$2" | bc)
			fi
		;;
		* )
			laDie 'Arguments to laRandomInteger() suck'
			return 1
		;;
	esac
	# $RANDOM isn't POSIX, but its easy to use
	case $(laPickCommand bash zsh ksh) in
		bash )
			local ra=$(bash -c 'printf $RANDOM')
			local rb=$(bash -c 'printf $RANDOM')
			if [ "$ra" -eq "$rb" ]; then
				laDie 'bash $RANDOM is not random'
			fi
			if [ $(echo "$max>32767" | bc) = '1' ]; then
				laDie 'FIXME (cannot handle numbers greater than 32767)'
			fi
		;;
	esac
	printf awk 'BEGIN { srand(); printf("%f\n",rand()*32757)  }'
	return 1
}

############################################################################
##### STRING FUNCTIONS
############################################################################
# These functions all operate on one or more strings.
#  laGet*() input a single string and print something on stdout
#  la

if [ ]; then
___STRING___() {
	return 0
}
fi

laiDefineFunction 'laStringLength' 'Prints the length of the given string'
laStringLength() {
	if [ $la_SHELL_TYPE = "bash" ]; then
		for i in "$@"; do
	    	echo ${#i}
		done
	else
		echo -n "$@" | wc -c
	fi
	return 0
}
alias laGetStringLength=laStringLength

# laString
laiDefineFunction 'laStringIndex' '1:string_to_search 2:what_to_find' 'OUT:position' 'Prints the offset (starting from 1) where substring is first found in string'
laStringIndex() {
	laDebug -z
	printf "$1" | awk -v b="$2" '{ print index($0, b) }'
}


# laStringInString
laiDefineFunction 'laStringIn' '1:what_to_find 2:string_to_search' '' 'Returns 0 if first string is found anywhere in second string.'
laStringIn() {
	# no debug because debug uses this function
	case $2 in
		*$1* )
		return 0
		;;
	esac
	return 1
}
alias laSearchString=laStringIn

laiDefineFunction 'laStringContains' '1:string_to_search 2:what_to_find' '' 'Returns 0 if first string contains second string.'
laStringContains() {
	# no debug because debug uses this function
	case $1 in
		*$2* )
		return 0
		;;
	esac
	return 1
}

laiDefineFunction 'laStringSplit' '1:STRING 2:delimiter' 'OUT:array' 'Splits a string at each occurance of delimiter, and prints the resulting array'
laStringSplit() {
	laDebug -z
	printf "$1" | tr "$2" "$IFS"
}
alias laSplitString=laStringSplit

laiDefineFunction 'laStringPartition' '1:STRING 2:delimiter' 'OUT:array' 'Splits a string at the first occurance of delimiter, and prints the part before, the delimiter, and the part after'
laStringPartition() {
	# TODO: CODE ME
	laDebug -z
	local dsize=$(laGetStringLength "$2")
	local dloc=$(laStringIndex "$1" "$2")
	local asdf
	printf "$1" | echo FAIL
}
alias laPartitionString=laStringPartition

laiDefineFunction 'laStringStartsWith' '1:string_to_search 2:what_to_find' '' 'Returns 0 if the string starts with the substring'
laStringStartsWith() {
	laDebug -z
	if [ $(laStringIndex "$1" "$2") -eq 1 ]; then
		return 0
	fi
	return 1
}
alias laStartsWith=laStringStartsWith

laiDefineFunction 'laStringEndsWith' '1:string_to_search 2:what_to_find' '' 'Returns 0 if the string ends with the substring'
laStringEndsWith() {
	laDebug -z
	case $1 in
		*$2 )
		return 0
		;;
	esac
	return 1
}
alias laEndsWith=laStringEndsWith


laiDefineFunction 'laStringIsAlpha' '1:string' '' 'Returns 0 if the input string contains only alphabetic characters (letters)'
laStringIsAlpha() {
	laDebug -z
	if [ -z $(printf "$@" | tr -d "[:alpha:]") ]; then
		return 0
	fi
	return 1
}


laiDefineFunction 'laStringIsNumeric' '1:string' '' 'Returns 0 if the input string contains only numeric characters (numbers)'
laStringIsNumeric() {
	laDebug -z
	if [ -z $(printf "$@" | tr -d "[:digit:]") ]; then
		return 0
	fi
	return 1
}

laiDefineFunction 'laStringIsAlphaNumeric' '1:string' '' 'Returns 0 if the input string contains only alphanumeric characters (letters and/or numbers)'
laStringIsAlphaNumeric() {
	laDebug -z
	if [ -z $(printf "$@" | tr -d "[:alnum:]") ]; then
		return 0
	fi
	return 1
}


laiDefineFunction 'laStringIsWhitespace' '1:string' '' 'Returns 0 if the input string contains only whitespace characters'
laStringIsWhitespace() {
	laDebug -z
	if [ -z $(printf "$@" | tr -d "[:space:]") ]; then
		return 0
	fi
	return 1
}

laiDefineFunction 'laStringToLower' '1:string' 'OUT:string' 'Turns all uppercase characters into lowercase'
laStringToLower() {
	laDebug -z
	printf "$@" | tr [:upper:] [:lower:]
}
alias laToLower=laStringToLower

laiDefineFunction 'laStringToUpper' '1:string' 'OUT:string' 'Turns all lowercase characters into uppercase'
laStringToUpper() {
	laDebug -z
	printf "$@" | tr [:lower:] [:upper:]
}
alias laToUpper=laStringToUpper

laiDefineFunction 'laStringRot13' '1:string' 'OUT:string' 'Advances each alphabetic character in the input string by 13 places (in the 26 letter alphabet).'
laStringRot13() {
	# Credit to http://rosettacode.org/wiki/Rot-13#UNIX_Shell
	laDebug -z
	printf "$@" | tr '[a-m][n-z][A-M][N-Z]' '[n-z][a-m][N-Z][A-M]'
}

############################################################################
##### TERM FUNCTIONS
############################################################################
#

if [ ]; then
___TERM___() {
	return 0
}
fi

laiDefineFunction 'laTermColors' '' 'OUT:colors' 'Get the number of colors the terminal supports'
laTermColors() {
	# TODO: add infocmp
	laDebug -z
	case $(laPickCommand tput) in
		tput )
			tput colors
			return 0
		;;
	esac
	return 1
}

laiDefineFunction 'laTermColumns' '' 'OUT:columns' 'Get the width of the terminal in characters'
laTermColumns() {
	# TODO: add infocmp
	laDebug -z
	# SUS tells us that $COLUMNS specifies the user's PREFERRED width, and
	#  if set, we (a conforming application) should respect it regardless of
	#  the values in $TERM or elsewhere (including the actual terminal width)
	if [ $COLUMNS ]; then
		echo $COLUMNS
		return 0
	fi
	case $(laPickCommand tput) in
		tput )
			tput cols
			return 0
		;;
	esac
	return 1
}

laiDefineFunction 'laTermLines' '' 'OUT:lines' 'Get the height of the terminal in characters'
laTermLines() {
	# TODO: add infocmp
	laDebug -z
	if [ $LINES ]; then
		echo $LINES
		return 0
	fi
	case $(laPickCommand tput) in
		tput )
			tput lines
			return 0
		;;
	esac
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
#
# Notes on the date utility
#  Where is the code:
#   FreeBsd <http://svnweb.freebsd.org/base/head/bin/date/date.c?view=markup>
#           <http://svnweb.freebsd.org/base/head/lib/libc/stdtime/strftime.c?view=markup>
#   Busybox <http://git.busybox.net/busybox/tree/coreutils/date.c>
#   Gnu <http://git.savannah.gnu.org/cgit/coreutils.git/tree/src/date.c>
#
#  Examples
#   When output isn't reliable, no example is given.
#   Examples are for PDT timezone
#   All numbers are decimal, and examples are for:
#    13 hours, 21 minutes, 0 seconds into Saturday, October 26, 1985 Pacific
# Unix
#  Bsd
#   Gnu
# U    %a 'Sat'         Locale's abbreviated weekday name.
# U    %A 'Saturday'    Locale's full weekday name.
# U    %b 'Oct'         Locale's abbreviated month name.
# U    %B 'October'     Locale's full month name.
# U    %c               Locale's appropriate date and time representation.
# U    %C '19'          Century (truncated year/100) [00,99].
# U    %d '26'          Day of the month, zero padded [01,31].
# U    %D '10/26/85'    Date in the format mm/dd/yy.
# U    %e '26'          Day of the month, space padded [ 1,31].
#  BG  %F '1985-10-26'  Full date; same as %Y-%m-%d
#  BG  %g '85'          Last two digits of year of ISO week number (see %G)
#  BG  %G '1985'        Year of ISO week number (see %V); useful only with %V
# U    %h 'Oct'         A synonym for %b
# U    %H '13'          Hour (24-hour clock) [00,23].
# U    %I '01'          Hour (12-hour clock) [01,12].
# U    %j '299'         Day of the year [001,366].
#  BG  %k '13'          Hour, space padded ( 0..23)
#  BG  %l ' 1'          Hour, space padded ( 1..12)
# U    %m '10'          Month as a decimal number [01,12].
# U    %M '21'          Minute as a decimal number [00,59].
# U    %n               A <newline>.
#   G  %N '000000000'   Nanoseconds (000000000..999999999)
# U    %p 'PM'          Locale's equivalent of either AM or PM.
#   G  %P 'pm'          Like %p, but lower case
# U    %r '01:21:00 PM' In the POSIX locale, same as %I:%M:%S %p
#  BG  %R '13:21'       24-hour hour and minute; same as %H:%M
#  BG  %s '499206060'   Seconds since the Epoch (1970-01-01 00:00:00 UTC)
# U    %S '00'          Seconds as a decimal number [00,60].
# U    %t               A <tab>.
# U    %T '13:21:00'    24-hour clock time [00,23] in the format HH:MM:SS
# U    %u '6'           Weekday as a decimal number [1,7] (1=Monday).
# U    %U '42'          Week (Sun-start) [00,53]. 00 starts at day 1.
#  B   %v '26-Oct-1985' Same as %e-%b-%Y
# U    %V '43'          ISO week (Mon-start) [01,53]. 01 must contain %u=3
# U    %w '6'           Weekday as a decimal number [0,6] (0=Sunday).
# U    %W '42'          Week (Mon-start) [00,53]. 00 starts at first Mon of year
# U    %x               Locale's appropriate date representation.
# U    %X               Locale's appropriate time representation.
# U    %y '85'          Year within century [00,99].
# U    %Y '1985'        Year with century
#  BG  %z               +hhmm numeric time zone (e.g., -0400)
#   G  %:z              +hh:mm numeric time zone (e.g., -04:00)
#   G  %::z             +hh:mm:ss numeric time zone (e.g., -04:00:00)
#   G  %:::z            tz with : to necessary precision (e.g., -04, +05:30)
# U    %Z               Timezone name, or blank if no timezone is determinable.
# U    %%               A <percent-sign> character.

if [ ]; then
___TIME___() {
	return 0
}
fi

laiDefineFunction 'laTime' '' 'OUT:TIME' 'Prints calendar time in libaccidents preferred format (nanoseconds since the Epoch)'
laTime() {
	laDebug -z

	# Both %s and %N are gnuisms
	local t="$(date +%s%N)"
	if laStringIsNumeric "$t"; then
		printf '%s' "$t"
		return 0
	fi
	# TODO: insert fail detect here

	# Heap of creative ways to get precise time if date command isn't gnuistic
	# TODO: normalize output when you decide if things should return \n or not
	case $(laPickCommand zsh python perl tclsh php lua gawk) in
		zsh )
			# zsh accurate to the nanosecond
			zsh -c 'zmodload zsh/datetime; for secs nsecs in $epochtime; do echo ${secs}${nsecs}; done'
		;;
		python )
			# python accurate to the nanosecond
			python -c 'import time; print int(time.time()*1000000000)'
		;;
		perl )
			# perl accuracy is pseudorandom
			perl -e 'use Time::HiRes qw(gettimeofday); printf("%.0f",gettimeofday()*1000000000);'
			# below line is more accurate but implodes into aids on some boxes
			#perl -e 'use Time::HiRes qw(gettimeofday); print int(gettimeofday()*1000000000);'
		;;
		tclsh )
			# tcl accurate to the microsecond
			echo 'puts [clock microseconds]000' | tclsh
		;;
		php )
			# php accurate to the microsecond
			# TODO: try making it more accurate by nuking true and make aids
			php -r 'print (int) microtime(true)*1000000000;'
		;;
		lua )
			# lua accurate to the second
			lua -e 'print(string.format("%d", os.time()*1000000000))'
		;;
		gawk )
			# gawk accurate to the second
			gawk 'BEGIN { print strftime("%s")*1000000000 }'
		;;
	esac
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
	# Sat, 13 Oct 1985 13:21:00 
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


laTimeToIsoWeek() {
	laDebug -z
}

laTimeToMonth() {
	laDebug -z
}

laTimeToYear() {
	laDebug -z
}

laiDefineFunction 'laTimeIsLeapYear' '1:TIME' '' 'Return 0 if the year in which the given TIME resides is a leap year. A leap year has a February 29th.'
laTimeIsLeapYear() {
	case $(laPickCommand tput) in
		tput )
			tput ritm
			return 0
		;;
	esac
}

laGetLocalUtcOffset() {
	laDebug -z
}

############################################################################
##### UID FUNCTIONS
############################################################################

if [ ]; then
___UID___() {
	return 0
}
fi

laiDefineFunction 'laUidFromEuid' '' 'OUT:UID' 'Prints the effective user ID (EUID)'
laUidFromEuid() {
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
	laDie 'laUidFromEuid() failed to find EUID'
	return 1
}

laiDefineFunction 'laUidToUser' '1:UID' 'OUT:USER' 'Prints the name of the user with the given UID'
laUidToUser() {
	laDebug -z
	grep -E '^.*'"$1"':' /etc/passwd | awk -F: '{ print $1 }'
	return 0
	return 1
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
#  fish
#  ftp
#  http
#  scp
#  sftp
#
#
#  ssh
#  telnet
#  mailto
#  man
#  info
#  whatis
#  news
#  ldap
#  gopher
#  
#
# ip_server = [user [ : password ] @ ] host [ : port]

if [ ]; then
___URL___() {
	return 0
}
fi

laiDefineFunction 'laUrlNormalize' 'Inputs a less-than-perfect URL as a string, cleans it up and spits it out. Mostly follows advice in URI(7) Linux man-page. Note that some schemes (like info) are handled differently based on detection of Gnome/KDE dominant systems'
laUrlNormalize() {
	laDebug -z
	local scheme=$(laUrlScheme "$1")
	case $scheme in
		http )
		return 0
		;;
	esac
}

laiDefineFunction 'laUrlNormalizeAndCheck' 'Like laUrlNormalize, but also makes sure it exists.'
laUrlNormalizeAndCheck() {
	laDebug -z
}

laUrlEscape() {
	# Originally stolen from Bo Ørsted Andresen's wgetpaste
	# debug start # this borks the sed below
	sed -e 's|%|%25|g' -e 's|&|%26|g' -e 's|+|%2b|g' -e 's| |+|g' "$@" || die "sed failed"
}

laUrlUnescape() {
	# debug start # this borks the sed below
	sed -e 's|%25|%|g' -e 's|&|%26|g' -e 's|+|%2b|g' -e 's| |+|g' "$@" || die "sed failed"
}

laUrlMount() {
	laDebug -z
}

laUrlCouldBeMountable() {
	laDebug -z
}

laiDefineFunction 'laUrlScheme' 'Prints the scheme portion of a URL'
laUrlScheme() {
	# called by: laUrlNormalize
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

laiDefineFunction 'laUrlSplit' 'Returns an array in the form SCHEME USER PASSWORD HOST PORT DIRECTORY OBJECT FRAGMENT'
laUrlSplit() {
	laDebug -z
}

laUrlIsDirectory() {
	laDebug -z
}

laUrlIsContent() {
	laDebug -z
}

laUrlToPath() {
	laDebug -z
	local url=$(laUrlNormalize "$1")
}

laiDefineFunction 'laUrlExists' 'Returns 0 if specified URL is accessable'
laUrlExists() {
	laDebug -z
	if hash "curl" 2>/dev/null; then
		local getCommand='curl -fsI'
	elif hash "wget" 2>/dev/null; then
		local getCommand='wget -q --spider'
	else
		laDie "laUrlExists() failed to find a supported downloader."
		return 1
	fi
	return $($getCommand $1)
}

laiDefineFunction 'laUrlDownload' '1:URL 2:PATH' '' 'Downloads URL in first parameter to location in second parameter. Returns 0 upon success'
laUrlDownload() {
	laDebug -z
	case $(laPickCommand curl wget) in
		curl )
			curl -o "$2" "$1" && return 0
		;;
		wget )
			wget -O "$2" "$1" && return 0
		;;
		* )
			laDie "laUrlDownload() failed to find a supported downloader."
			return 1
		;;
	esac
	return 1
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
##### USERNAME FUNCTIONS
############################################################################

if [ ]; then
___USERNAME___() {
	return 0
}
fi

laiDefineFunction 'laUserFromLogin' '' 'OUT:USERNAME' 'Prints the name of the controlling user'
laUserFromLogin() {
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
		laDebug 'Warning: laUserFromLogin() exhausted all methods. Result may be wrong.'
		echo $USERNAME
		return 0
	fi
	laDie 'laUserFromLogin() failed to find username.'
	return 1
}

laiDefineFunction 'laUserFromEffective' '' 'OUT:USERNAME' 'Prints the name of the effective user'
laUserFromEffective() {
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
	laDie 'laUserFromEffective() failed to find effective username.'
	return 1
}

laiDefineFunction 'laUserToUid' '1:USERNAME' 'OUT:UID' 'Prints the UID of the given user name'
laUserToUid() {
	laDebug -z
	id -u "$1"
	# Alternate for linux
	# grep -E '^'"$1"':' /etc/passwd | awk -F: '{ print $3 }'
}

laUserIsInGroup() {
	laDebug -z
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
##### FILE_ID.DIZ FUNCTIONS
############################################################################
# The spec is at <http://www.textfiles.com/computers/fileid.txt>





############################################################################
#####  FUNCTIONS
############################################################################


############################################################################
##### COMMAND EXECUTION FUNCTIONS
############################################################################

# laiDefineFunction 'laGetCommandVersion' '1:PATH' '' 'Checks a utility command for its version identifier'
# laGetCommandVersion() {
# 	laDebug -z
# 	local vertemp
# 	case "$1" in
# 		gst-discoverer )
# 		gst-feedback )
# 		gst-inspect )
# 		gst-launch )
# 		gst-typefind )
# 		gst-visualise )
# 		gst-xmlinspect )
# 		gst-xmllaunch )
# 			"$1" --version
# 		;;
# 		wget )
# 			local vertemp=$(wget)
# 			asdf
# 			wget --version | head -1 | awk '{ print $3 }'
# 		;;
# 		* )
# 			laDie "laUrlDownload() failed to find a supported downloader."
# 			return 1
# 		;;
# 	esac
# 	return 1
# }

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

laiDefineFunction 'laPickCommand' '*:COMMANDS' 'OUT:COMMAND' 'Takes an ordered list of commands, and prints the first one that is valid.'
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

laiDefineFunction 'laDie' '1:final_words' 'ERR:stuff' 'Prints the given message in blood red'
laDie() {
	echo "$la_DIM_RED""ERROR: $1""$la_SGR0" 1>&2
	exit 1
}

laReturn() {
	laDebug -z
	return $1
}

laPage() {
	laDebug -z
	if [ -x "$PAGER" ]; then
		echo FAIL
	fi
}


############################################################################
##### HTML FUNCTIONS
############################################################################
#

if [ ]; then
___HTML___() {
	return 0
}
fi

#laiDefineFunction 'laTextToHtml' 'IN:tacos' 'OUT:html 1:FILE' 'Converts plain text to HTML, with no styling. Use this to generate your website and you shall be loved forever'

laiDefineFunction 'laHtmlTitle' '1:FILE' 'OUT:title' 'Prints the title of a HTML page. Uses the first <title> tag found.'
laHtmlTitle() {
	# TODO: Accept stdin
	# TODO: Use generic laDownload or something that also accepts PATH
	# TODO: Test with page having multiple titles
	laDebug -z
	curl -sf "$1" | awk -vRS="</title>" '/<title>/{gsub(/.*<title>|\n+/,"");print;exit}'
}

############################################################################
##### HMI FUNCTIONS
############################################################################
#
# sgr standout underline reverse blink dim bold invis protect altcharset

laiDefineFunction 'laShellIsInteractive' '' '' 'Returns 0 if the shell is interactive, 1 if not'
laShellIsInteractive() {
	laDebug -z
	laStringContains "$-" i
}

# TODO: FINISH
laPickDialogCommand() {
	laDebug -z
	if [ $KDE_FULL_SESSION ]; then
		local tryorder=(kdialog Xdialog xmessage gtkdialog dialog zenity)
	fi
}

laiDefineFunction 'laDbusSessionMethod' '1:destination 2:object-path 3:method 4+:arguments' 'OUT:stuff' 'Calls a session DBUS method'
laHostToIp() {
	# TODO:
	#  Error/sanity checks
	laDebug -z
	local destination="$1"
	local objectpath="$2"
	local method="$3"
	shift 3
	case $(laPickCommand dbus-send qdbus gdbus) in
		dbus-send )
			for p in $@; do
				echo FAIL
			done
			dbus-send --session --print-reply=literal --dest="$1" "$2"."$3" 
			return 0
		;;
		qdbus )
			qdbus --session "$destination" "$objectpath" "$method" /modules/kwalletd org.kde.KWallet.isOpen kdewallet
			host "$host" | awk '/^[[:alnum:].-]+ has address/ { print $4 ; exit }'
			return 0
		;;
		gdbus )
			echo FAIL
			return 0
		;;
	esac
	return 1
}

laiDefineFunction 'laGetKwalletStuff' '1:HOST' 'OUT:IP' 'Resolves a HOST to IP'
laHostToIp() {
	# TODO:
	#  DNSSD (using tools and/or own client)
	#  automagically try to use dns server at default gateway
	# Kudos to Chris Down via <http://unix.stackexchange.com/a/20793>
	laDebug -z
	local host="$1"
	case $(laPickCommand dbus-send qdbus) in
		dbus-send )
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


############################################################################
##### MATH FUNCTIONS
############################################################################
# TODO:
#  Support bc, dc, and calc

if [ ]; then
___MATH___() {
	return 0
}
fi

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
	# Same as Python cmp(x, y)
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
	local file="$1"
	case $(laPickCommand wgetpaste) in
		wgetpaste )
			wgetpaste "$file"
			return 0
		;;
	esac
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
laGnuStat() {
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
			laFileOwningGroupname "$file"
		;;
		%h )
			#  Number of hard links
			ls -ld "$file" | awk '{print $2}'
		;;
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
		%s )
			#  Total size, in bytes
			laFileSize "$file"
		;;
		# %t
		#  Major device type in hex
		# %T
		#  Minor device type in hex
		%u )
			#  User ID of owner
			laUserToUid $(laFileOwningUsername "$file")
		;;
		%U )
			#  User name of owner
			laFileOwningUsername "$file"
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


laiDefineFunction 'laGnuWhich' 'Portable replacement for the GNU coreutils which command'
laGnuWhich() {
	# BUG: Does not handle builtins or aliases properly
	laDebug -z
	command -v $@
}

laiDefineFunction 'laZshWhich' 'Portable replacement for the zsh builtin which command'
laZshWhich() {
	# BUG: Does not handle builtins or aliases properly
	laDebug -z
	command -v $@
}

laiDefineFunction 'laZshWhence' 'Portable replacement for the zsh builtin whence command'
laZshWhence() {
	# BUG: Does not handle builtins or aliases properly
	laDebug -z
	command -v $@
}

# laConvertPermToOctal
laiDefineFunction 'laPermToOctal' 'Convert a human readable file permission string like -rwxr-xr-- to octal'
laPermToOctal() {
	# TODO: Make sure this works across BSD too
	# TODO: Find out where this came from and give credit
	laDebug -z
	local a=$(echo "$1" | cut -c4,7,10 | tr xstST- 011110)
	local b=$(echo "$1" | cut -c2-10 | tr rwsxtST- 11111000)
	echo "obase=8;ibase=2;${a}${b}" | bc
}

laOctalToPerm() {
	laDebug -z
	# TODO: CODE ME
	echo "obase=2;ibase=8;${1}" | bc
}


laiDefineFunction 'la' 'Portable replacement for the GNU which command'
laGnuWhich() {
	laDebug -z
	command -v $@
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


laIpToHost() {
	laDebug -z
}




############################################################################
##### SYS FUNCTIONS
############################################################################
# Linux
#  REQUIRED READING /usr/src/linux/Documentation/sysfs-rules.txt

laiDefineFunction 'laGetProcfsPath' 'Prints the path of a procfs mount'
laGetProcfsPath() {
	# TODO: Is this reliable and should we use /proc/mounts
	laDebug -z
	grep -m1 -e '^proc' /etc/mtab | awk '{print $2}'
}

laiDefineFunction 'laGetSysfsPath' 'Prints the path of a sysfs mount'
laGetSysfsPath() {
	# TODO: Check existance of /sys/ first. According to sysfs-rules.txt
	#        we should NOT try to look elsewhere. if it isn't at /sys, it
	#        is a BROKEN distro.
	# TODO: Is this reliable and should we use /proc/mounts
	laDebug -z
	grep -m1 -e '^sysfs' /etc/mtab | awk '{print $2}'
}

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
		$(printf ${la_FUNCTIONS[*]})
	EOF
	return 0
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
