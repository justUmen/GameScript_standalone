#!/bin/bash
#SOME ADDED AND CHANGE IN CLI learn_cli.sh in CLASSIC
shopt -s expand_aliases
source ~/.bashrc

function download_all_sounds(){
	#~ echo "Downloading..."
	cd $AUDIO_LOCAL || exit
	i=4
	rm to_dl.wget 2> /dev/null
	echo "Downloading Audio..."
	while [ $i -le $LINES ]; do
		#~ ( wget -q $AUDIO_DL/$i.mp3 -O $AUDIO_LOCAL/$i.mp3 || rm $AUDIO_LOCAL/$i.mp3 ) &> /dev/null &
		echo "$AUDIO_DL/$i.mp3" >> to_dl.wget
		i=`expr $i + 1`
	done
	cat to_dl.wget | xargs -n 1 -P 4 wget -q &
}

function prepare_audio(){
	AUDIO_LOCAL="$HOME/.GameScript/Audio/$LANGUAGE/classic/$CHAPTER_NAME/$SPEAKER/c$CHAPTER_NUMBER"
	mkdir -p $AUDIO_LOCAL 2> /dev/null
	AUDIO_DL="https://raw.githubusercontent.com/justUmen/GameScript/master/$LANGUAGE/classic/$CHAPTER_NAME/Audio/$SPEAKER/c$CHAPTER_NUMBER"
	AUDIOCMP=1
	if [ ! -f "$AUDIO_LOCAL/4.mp3" ]; then
		wget -q --spider http://google.com
		if [ $? -eq 0 ]; then
			download_all_sounds
		else
			echo "Cannot download audio, no internet ?"
		fi
	fi
}

function encode_b64(){
	echo -n "$2$1$3" | base64
}

function press_key(){
	echo -en "\e[0;33m...\e[0m"
	read -s -n1 key < /dev/tty
	#OBSOLETE ?
	#~ if [ "$key" == 'q' ] || [ "$key" == 'e' ]; then
		#~ pkill mpg123  > /dev/null 2>&1
		#~ echo -e "\e[0m "
		#~ exit 1
	#~ fi
	#~ if [ "$key" == 'r' ]; then
		#~ pkill mpg123  > /dev/null 2>&1
		#~ normal_line $restore
	#~ fi
	#~ pkill mpg123
	#~ pkill mplayer > /dev/null 2>&1
}

#TODO ???
function new_sound(){
	pkill mplayer &> /dev/null
	pkill mpg123 &> /dev/null
	$SOUNDPLAYER "$AUDIO_LOCAL/$restore.mp3" &> /dev/null &
	#~ if [[ ! -f "$AUDIO_DL/`expr $restore + 1`.mp3" ]];then
		#~ ( wget $AUDIO_DL/`expr $restore + 1`.mp3 -O $AUDIO_LOCAL/`expr $restore + 1`.mp3 || rm $AUDIO_LOCAL/`expr $restore + 1`.mp3 ) &> /dev/null &
		#~ ( wget -nc $AUDIO_DL/`expr $restore + 1`.mp3 -O $AUDIO_LOCAL/`expr $restore + 1`.mp3 || ( rm $AUDIO_LOCAL/`expr $restore + 1`.mp3 ; wget -nc $AUDIO_DL/`expr $restore + 2`.mp3 -O $AUDIO_LOCAL/`expr $restore + 2`.mp3 || $AUDIO_LOCAL/`expr $restore + 2`.mp3 ) ) &> /dev/null & #download next one, or the one after if it doesn't exist
	#~ fi
	#~ if [[ ! -f "$AUDIO_DL/`expr $restore + 2`.mp3" ]];then
		#~ ( wget $AUDIO_DL/`expr $restore + 2`.mp3 -O $AUDIO_LOCAL/`expr $restore + 2`.mp3 || rm $AUDIO_LOCAL/`expr $restore + 2`.mp3 ) &> /dev/null &
	#~ fi
}
function talk(){
	if [[ $MUTE == 0 ]]; then 
		new_sound
	fi
	echo -e "($restore)\e[0;32m $1\e[0m - $2"

	#??? test delay avoid past read input
	read -s -t 1 -n 10000 discard

	#~ sleep 1
	#~ while read -r -t 0; do read -r; done
	
	#~ sleep 0.5
	#~ read -s -e -t 0.1 #flush stdin ?

	press_key
}
function talk_not_press_key(){
	if [[ $MUTE == 0 ]]; then 
		new_sound
	fi
	echo -e "($restore)\e[0;32m $1\e[0m - $2"
}
function talk_not_press_key_ANSWER(){
	echo -en "($restore)\e[0;32m $1\e[0m - "
	echo -ne "\\e[4;37m"
	echo -nE "$2"
	echo -e "\\e[0m"
}

function answer_quiz(){
	#$7 = bash, from enter_chapter
	# echo " ---> $7 <--- "
	key="9"
	while [ "$key" != "1" ] || [ "$key" != "2" ] || [ "$key" != "3" ]; do
		# echo ""
		#~ echo -e "\\e[0;100m 0) \\e[0m Télécharger audio en avance"
		echo -e "\\e[0;100m 1) \\e[0m $1"
		echo -e "\\e[0;100m 2) \\e[0m $2"
		echo -e "\\e[0;100m 3) \\e[0m $3"
		echo -en "\\e[97;45m # \\e[0m"
		read key < /dev/tty
		case $key in
			0) download_all_sounds ;;
			1) 	if [ -f "$HOME/.GameScript/restore_$7$8" ];then
					echo "$HOME/.GameScript/restore_$7$8 existe, continuer ou recommencer le cours du début ?"
					while [ "$choice" != "1" ] || [ "$choice" != "2" ] || [ "$choice" != "3" ]; do
						echo -e "\\e[0;100m 1) \\e[0m Continuer"
						echo -e "\\e[0;100m 2) \\e[0m Recommencer"
						echo -e "\\e[0;100m 3) \\e[0m Retour"
						echo -en "\\e[97;45m # \\e[0m"
						read choice < /dev/tty
						case $choice in
							1)  cd `cat "$HOME/.GameScript/restore_pwd_$CHAPTER_NAME$CHAPTER_NUMBER"`
								start_lecture `cat "$HOME/.GameScript/restore_$CHAPTER_NAME$CHAPTER_NUMBER"`
								start_quiz
								;;
							2) 	clean
								start_lecture 1
								start_quiz
								;;
							3) exit ;;
						esac
					done
				fi
				start_lecture 1
				start_quiz
				;;
			2) start_quiz ;;
			3) exit ;;
		esac
	done
}

QUIZ_NUMBER=1
function answer_text_fr(){
	echo ""
	echo "($QUIZ_NUMBER) > $1"
	#~ echo -en "\\e[97;45m # \\e[0m"
	read -e -r -p $'\e[97;45m # \e[0m' USER_CODE < /dev/tty
	if [ ! "$USER_CODE" == "$2" ]; then
		talk_not_press_key justumen "\\e[4;37mDésolé, réponse fausse ou trop longue. Je vous conseille de suivre / refaire le cours.\nSi vous pensez maitriser le contenu du cours, il y a surement un piège, relisez donc attentivement la question. :-)\nSi vous vous sentez vraiment bloqué, demandez de l'aide sur notre chat : https://rocket.bjornulf.org\\e[0m"
		#enter_chapter $CHAPTER_NAME $CHAPTER_NUMBER
		exit
	else
		talk_not_press_key justumen "Correct !"
		QUIZ_NUMBER=`expr $QUIZ_NUMBER + 1`
	fi
}
function answer_run(){
	#~ echo -en "\\e[97;45m # \\e[0m"
	read -e -r -p $'\e[97;45m # \e[0m' USER_CODE < /dev/tty
	while [ ! "$USER_CODE" == "$1" ]; do
		if [ ! "$USER_CODE" == "" ]; then
			talk_not_press_key_ANSWER "$2" "$1"
		fi
		#~ echo -en "\\e[97;45m # \\e[0m"
		read -e -r -p $'\e[97;45m # \e[0m' USER_CODE < /dev/tty
	done
	if [ ! "$1" == "" ];then
		echo -e "\e[1m"
		printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
		#Quick solve for bash10 pb "alias a1='ls -a /var'" ???
		#~ case $1 in
			#~ a1) eval ls -a /var ;;
			#~ alias) alias ;;
			#~ *) eval "$1" ;;
		#~ esac
		eval "$1"
		printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
		echo -e "\\e[0m"
	fi
}
function start_dots(){
	echo -en "\e[0;33m...\e[0m"
}

function title(){
	echo -e "\e[1m"
	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
	echo "$1"
	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
	echo -e "\\e[0m"
}

black_on_green='\e[30;48;5;82m'
black_on_lightblue='\e[30;48;5;81m'
black_on_red='\e[41m'
On_Black='\e[97;40m'
reset='\e[0m'

basic=$On_Black
code=$black_on_lightblue
codeFile=$black_on_green
codeError=$black_on_red

#UNDERLINE
#~ voc='\e[1m'
voc='\e[4;37m'
#BLUE
learn='\e[40;38;5;10m'

MUTE=0
if [ "$1" == "MUTE" ]; then
	MUTE=1
fi
command -v mplayer &> /dev/null && SOUNDPLAYER="mplayer -af volume=10" || SOUNDPLAYER="mpg123 --scale 100000";

#OBSOLETE ?
#~ restore=2 #first line of LIST_4GEN should be environment test (test ~/House)
restore=1
function new_game_or_restore(){
	#restore, 1 new game, otherwise x in file PERSONAL_PROGRESS
	restore=1
	if [ -e "~/PERSONAL_PROGRESS" ]; then
		restore=`cat ~/PERSONAL_PROGRESS`
	else
		echo -n "1" > ~/PERSONAL_PROGRESS
	fi
	if [ "$1" ];then
		restore=`expr $1 - 1`
		echo -n "$1" > ~/PERSONAL_PROGRESS
	fi
}

#~ function normal_line(){
	#~ restore=$1
	#~ play_mp3 "$restore"
	#~ print_line "$line"
	#~ press_key
#~ }

function play_mp3(){
	if [ -e "sounds/$1.mp3" ];then
		mpg123 "sounds/$1.mp3" > /dev/null 2>&1 &
	fi
}
function event(){
	echo -e "\\e[0;100m $1\\e[0m"
	press_key
	#~ restore=$(expr $restore + 1)
}







function unlock(){
	#Usage : unlock "bash" "1" "24d8" "f016"
	PSEUDO=`cat "$HOME/.GameScript/username"`
	PASS=`encode_b64 $PSEUDO "$3" "$4"`
	talk_not_press_key justumen "Pour débloquer '$1 $2' sur le chat, ouvrez une conversation privée avec '@boti' et copiez/collez :\n\t\e[97;42mpassword$PASS\e[0m"
	touch "$HOME/.GameScript/good_$1$2" 2> /dev/null
	mkdir $HOME/.GameScript/passwords/ 2> /dev/null
	echo -n "$PASS" > "$HOME/.GameScript/passwords/$1$2"
	exit
}

function enter_chapter(){
	#Usage : enter_chapter bash 1 1 (first 1 is chapter, next one is for case)
	echo ""
	echo -e "\e[97;44m - $1, Chapitre $2 \e[0m"
	answer_quiz "Cours" "Questionnaire" "Retour" "4" "5" "6" "$1" "$2"
}
function start_lecture(){
restore=$1
case $1 in
1) echo -n 1 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; [ -d "$HOME/.GameScript_bash6" ] && echo "Erreur innatendu, ${HOME}/.GameScript_bash6 existe déjà sur votre système ! Supprimez ce dossier $HOME/.GameScript_bash6 et relancer ce script." && exit; restore=$(expr $restore + 1) ;&
2) echo -n 2 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; mkdir $HOME/.GameScript_bash6 2> /dev/null; restore=$(expr $restore + 1) ;&
3) echo -n 3 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; cd $HOME/.GameScript_bash6; restore=$(expr $restore + 1) ;&
4) echo -n 4 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; echo "xxxxxx">intrus;echo "contenu f">f;chmod 222 f;echo "contenu f1">f1;chmod 000 f1;echo "contenu f10">f10;chmod 010 f10;echo "contenu f2">f2;chmod 444 f2;echo "contenu f3">f3;chmod 400 f3;echo "contenu f4">f4;chmod 455 f4;echo "contenu f50">f50;chmod 111 f50; restore=$(expr $restore + 1) ;&
5) echo -n 5 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk_not_press_key justumen "Let's start by evaluating our situation with a: ${learn}ls -l${reset}"; restore=$(expr $restore + 1) ;&
6) echo -n 6 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; answer_run "ls -l" justumen "No"; restore=$(expr $restore + 1) ;&
7) echo -n 7 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "We have here some problems of permission to settle ..."; restore=$(expr $restore + 1) ;&
8) echo -n 8 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "We want to add the right of reading and writing for the owner on all elements of the current directory."; restore=$(expr $restore + 1) ;&
9) echo -n 9 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "It is possible to put all the names one after the other with ${code}chmod${reset}."; restore=$(expr $restore + 1) ;&
10) echo -n 10 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk_not_press_key justumen "Do it for 'f1' and 'f2', then redisplay the new permissions if the command is successful."; restore=$(expr $restore + 1) ;&
11) echo -n 11 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; answer_run "chmod u + rw f1 f2 && ls -l" justumen "No"; restore=$(expr $restore + 1) ;&
12) echo -n 12 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "Typing all the filenames is especially boring, especially if you have a large number of files to change."; restore=$(expr $restore + 1) ;&
13) echo -n 13 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "In this chapter we will add new special characters to our arsenal!"; restore=$(expr $restore + 1) ;&
14) echo -n 14 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "The first one we will see is: ${code}*${reset}"; restore=$(expr $restore + 1) ;&
15) echo -n 15 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "${code}*${reset} is a very powerful symbol, it's called a ${voc}wildcard${reset}."; restore=$(expr $restore + 1) ;&
16) echo -n 16 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "${code}*${reset} can be used to replace all items in a directory."; restore=$(expr $restore + 1) ;&
17) echo -n 17 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "That is, instead of having to type all the names one after the other, you just have to put a ${code}*${reset} instead."; restore=$(expr $restore + 1) ;&
18) echo -n 18 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk_not_press_key justumen "Then add the right to read and write for the owner on all items in the current directory, then redisplay the new permissions if the command is a success."; restore=$(expr $restore + 1) ;&
19) echo -n 19 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; answer_run "chmod u + rw * && ls -l" justumen "No"; restore=$(expr $restore + 1) ;&
20) echo -n 20 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "If ${code}*${reset} is used alone, the directory in question is of course the current directory: ${code}*${reset} = ${code}./*${reset}"; restore=$(expr $restore + 1) ;&
21) echo -n 21 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "But ${code}*${reset} can be used with any path, for example: ${code}/ *${reset} represents all the elements of the root directory."; restore=$(expr $restore + 1) ;&
22) echo -n 22 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "Here we have finally solved all our permissions problems in one command!"; restore=$(expr $restore + 1) ;&
23) echo -n 23 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "But ${code}*${reset} can also be used with other commands."; restore=$(expr $restore + 1) ;&
24) echo -n 24 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk_not_press_key justumen "Display the contents of all the files in the current directory one after the other."; restore=$(expr $restore + 1) ;&
25) echo -n 25 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; answer_run "cat *" justumen "No"; restore=$(expr $restore + 1) ;&
26) echo -n 26 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "The display order is ${voc}alphabetic${reset}, exactly like the result of ${code}ls${reset}."; restore=$(expr $restore + 1) ;&
27) echo -n 27 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "Note that 'f10' is placed before 'f2' because the default display is ${voc}and${reset} instead of ${voc}numeric${reset}."; restore=$(expr $restore + 1) ;&
28) echo -n 28 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "If you are interested in digital signage, you could easily find the ${code}-v${reset} option in the ${code}ls${reset} manual."; restore=$(expr $restore + 1) ;&
29) echo -n 29 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "${code}*${reset} can therefore represent all the elements of a directory."; restore=$(expr $restore + 1) ;&
30) echo -n 30 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "But what exactly does she do to have this effect?"; restore=$(expr $restore + 1) ;&
31) echo -n 31 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "${code}*${reset} can actually replace any string."; restore=$(expr $restore + 1) ;&
32) echo -n 32 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "If it is used alone, it represents all the files that have any name ..."; restore=$(expr $restore + 1) ;&
33) echo -n 33 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "But it is also possible to limit what it represents by adding characters."; restore=$(expr $restore + 1) ;&
34) echo -n 34 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk_not_press_key justumen "For example, you can display all items in the current directory that start with an 'f' with: ${learn}ls f *${reset}"; restore=$(expr $restore + 1) ;&
35) echo -n 35 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; answer_run "ls f *" justumen "No"; restore=$(expr $restore + 1) ;&
36) echo -n 36 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "Here the 'intruder' file is not present because its name does not start with an 'f'."; restore=$(expr $restore + 1) ;&
37) echo -n 37 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk_not_press_key justumen "Display all the elements of the current directory that end with a 0 with: ${learn}ls * 0${reset}"; restore=$(expr $restore + 1) ;&
38) echo -n 38 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; answer_run "ls * 0" justumen "No"; restore=$(expr $restore + 1) ;&
39) echo -n 39 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "The command ${code}ls${reset} also accepts several arguments, so you can cumulate the syntaxes."; restore=$(expr $restore + 1) ;&
40) echo -n 40 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk_not_press_key justumen "For example, try listing the permissions of all items in the current directory that end with either 0 or s."; restore=$(expr $restore + 1) ;&
41) echo -n 41 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; answer_run "ls -l * 0 * s" justumen "No"; restore=$(expr $restore + 1) ;&
42) echo -n 42 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk_not_press_key justumen "Now list all the permissions of items in the current directory that begin with 'i' and end with 's'."; restore=$(expr $restore + 1) ;&
43) echo -n 43 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; answer_run "ls -l i * s" justumen "No"; restore=$(expr $restore + 1) ;&
44) echo -n 44 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "With ${code}i * s${reset}, only the 'intruder' file fits into the selection criteria."; restore=$(expr $restore + 1) ;&
45) echo -n 45 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "In the case of this 'intruder' file, ${code}*${reset} will replace the string 'ntru'."; restore=$(expr $restore + 1) ;&
46) echo -n 46 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "If you need finer targeting, you can use another ${void} $ wildcard {reset}: ${code}?${reset}."; restore=$(expr $restore + 1) ;&
47) echo -n 47 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "${code}?${reset} only replaces ${voc}with a${reset} single character!"; restore=$(expr $restore + 1) ;&
48) echo -n 48 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk_not_press_key justumen "Try this command: ${learn}ls -l f?${reset}"; restore=$(expr $restore + 1) ;&
49) echo -n 49 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; answer_run "ls -l f?" justumen "No"; restore=$(expr $restore + 1) ;&
50) echo -n 50 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "Here 'f10' and 'f50' are not displayed because there are two characters after the letter f."; restore=$(expr $restore + 1) ;&
51) echo -n 51 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk_not_press_key justumen "Display these two files, doing: ${learn}ls -l f?${reset}"; restore=$(expr $restore + 1) ;&
52) echo -n 52 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; answer_run "ls -l f" justumen "No"; restore=$(expr $restore + 1) ;&
53) echo -n 53 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk_not_press_key justumen "But what about the 'f' file? So, show its permissions."; restore=$(expr $restore + 1) ;&
54) echo -n 54 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; answer_run "ls -l f" justumen "No"; restore=$(expr $restore + 1) ;&
55) echo -n 55 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "The file 'f' does exist, but did not show up in our last commands with ${code}?${reset} ..."; restore=$(expr $restore + 1) ;&
56) echo -n 56 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "${code}?${reset} replaces exactly ${code}a${reset} character, no more, no less."; restore=$(expr $restore + 1) ;&
57) echo -n 57 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk_not_press_key justumen "Try with: ls ${learn}f *${reset}"; restore=$(expr $restore + 1) ;&
58) echo -n 58 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; answer_run "ls f *" justumen "No"; restore=$(expr $restore + 1) ;&
59) echo -n 59 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "Here, even if there are no characters after f, the file 'f' is displayed."; restore=$(expr $restore + 1) ;&
60) echo -n 60 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "This is simply because ${code}*${reset} can also represent an empty string!"; restore=$(expr $restore + 1) ;&
61) echo -n 61 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk_not_press_key justumen "To view the permissions of all files with a name of a letter, you can use: ${learn}ls -l?${reset}"; restore=$(expr $restore + 1) ;&
62) echo -n 62 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; answer_run "ls -l?" justumen "No"; restore=$(expr $restore + 1) ;&
63) echo -n 63 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "Here 'f' is our only file with a name of a letter."; restore=$(expr $restore + 1) ;&
64) echo -n 64 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "So be careful when you use these ${voc}wildcards${reset}, especially with ${voc}destructive commands${reset}!"; restore=$(expr $restore + 1) ;&
65) echo -n 65 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "A command like ${learn}rm *${reset} can have serious consequences."; restore=$(expr $restore + 1) ;&
66) echo -n 66 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk_not_press_key justumen "Now that these two new symbols are acquired, display the contents of the 'f' file."; restore=$(expr $restore + 1) ;&
67) echo -n 67 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; answer_run "cat f" justumen "No"; restore=$(expr $restore + 1) ;&
68) echo -n 68 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "When you use the command ${code}cat${reset} you are actually displaying the ${voc}data${reset} of the file 'f'. (data in English)"; restore=$(expr $restore + 1) ;&
69) echo -n 69 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk_not_press_key justumen "Now display the results of ${learn}ls -l f${reset}."; restore=$(expr $restore + 1) ;&
70) echo -n 70 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; answer_run "ls -l f" justumen "No"; restore=$(expr $restore + 1) ;&
71) echo -n 71 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "The information displayed here is the ${voc}metadata${reset} of the 'f' file. (metadata in English)"; restore=$(expr $restore + 1) ;&
72) echo -n 72 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "${voc}${reset} metadata is information about data!"; restore=$(expr $restore + 1) ;&
73) echo -n 73 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "${learn}ls -l${reset} gives you ${voc}${reset} metadata."; restore=$(expr $restore + 1) ;&
74) echo -n 74 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "Let's take this example: -rw ------- 1 umen team 10 Feb 20 16:16 f"; restore=$(expr $restore + 1) ;&
75) echo -n 75 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "In this display, there are actually 7 columns."; restore=$(expr $restore + 1) ;&
76) echo -n 76 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "${codeFile} -rw -------${reset} 1 umen team 10 Feb 20 16:16 f: You already know the first column, it's about the type of the element and its permissions."; restore=$(expr $restore + 1) ;&
77) echo -n 77 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "-rw ------- ${codeFile} 1${reset} umen team 10 Feb 20 16:16 f: The second column is a number that counts the number of links or directories in an element."; restore=$(expr $restore + 1) ;&
78) echo -n 78 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "But we will return to this number in another chapter, ignore it for the moment."; restore=$(expr $restore + 1) ;&
79) echo -n 79 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "-rw ------- 1 ${codeFile} umen${reset} team 10 Feb 20 16:16 f: The third column is the name of the owner."; restore=$(expr $restore + 1) ;&
80) echo -n 80 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "-rw ------- 1 umen ${codeFile} team${reset} 10 Feb 20 16:16 f: The fourth column is the name of the group."; restore=$(expr $restore + 1) ;&
81) echo -n 81 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "-rw ------- 1 umen team ${codeFile} 10${reset} Feb 20 16:16 f: The fifth column is the ${voc}size${reset} in ${voc}byte ${ reset} of the file. (octect = byte in English)"; restore=$(expr $restore + 1) ;&
82) echo -n 82 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "Reminder: a byte is equal to 8 bits. And a bit can only have two values, 0 or 1."; restore=$(expr $restore + 1) ;&
83) echo -n 83 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "This file of 10 bytes is therefore 80 bits!"; restore=$(expr $restore + 1) ;&
84) echo -n 84 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "For information, the content of our 'f' file is equal in binary to this: 01100011 01101111 01101110 01110100 01100101 01101110 01110101 00100000 01100110 00001010"; restore=$(expr $restore + 1) ;&
85) echo -n 85 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "-rw ------- 1 umen team $ 10 {codeFile} Feb 20 16: 16${reset} f: The sixth column is the date when the file was last modified."; restore=$(expr $restore + 1) ;&
86) echo -n 86 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "-rw ------- 1 umen team 10 Feb 20 16:16 ${codeFile} f${reset}: And the last column is just the name of the file."; restore=$(expr $restore + 1) ;&
87) echo -n 87 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "In the previous chapter, you already used the ${code}touch${reset} command to create a file."; restore=$(expr $restore + 1) ;&
88) echo -n 88 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "Indeed, with ${code}touch${reset}, if the file given as an argument does not exist, it will be created."; restore=$(expr $restore + 1) ;&
89) echo -n 89 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "But the primary purpose of this command is to change this last-modified metadata. -rw ------- 1 umen team $ 10 {codeFile} Feb 20 16: 16${reset} f"; restore=$(expr $restore + 1) ;&
90) echo -n 90 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk_not_press_key justumen "To refresh the last modified date of 'f': ${learn}touch f${reset}"; restore=$(expr $restore + 1) ;&
91) echo -n 91 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; answer_run "touch f" justumen "No"; restore=$(expr $restore + 1) ;&
92) echo -n 92 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk_not_press_key justumen "Do it now: ${learn}ls -l${reset}"; restore=$(expr $restore + 1) ;&
93) echo -n 93 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; answer_run "ls -l" justumen "No"; restore=$(expr $restore + 1) ;&
94) echo -n 94 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "The last modified date of 'f' is actually the most recent."; restore=$(expr $restore + 1) ;&
95) echo -n 95 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk_not_press_key justumen "To display the current date just run the command: ${learn}date${reset}"; restore=$(expr $restore + 1) ;&
96) echo -n 96 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; answer_run "" justumen " Date Not"; restore=$(expr $restore + 1) ;&
97) echo -n 97 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "The command ${code}touch${reset} has had its effect."; restore=$(expr $restore + 1) ;&
98) echo -n 98 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk_not_press_key justumen "Now display the contents of the 'intruder' file."; restore=$(expr $restore + 1) ;&
99) echo -n 99 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; answer_run "intruder cat" justumen "No"; restore=$(expr $restore + 1) ;&
100) echo -n 100 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk_not_press_key justumen "Finally run: ${learn}ls -l intruder${reset}"; restore=$(expr $restore + 1) ;&
101) echo -n 101 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; answer_run "ls -l intruder" justumen "No"; restore=$(expr $restore + 1) ;&
102) echo -n 102 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "The date here has not changed, despite the ${code}cat${reset} command on this file."; restore=$(expr $restore + 1) ;&
103) echo -n 103 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "Without further options, ${learn}ls -l${reset} displays the last date of ${voc}change${reset}, not the last${reset} ${voc}date."; restore=$(expr $restore + 1) ;&
104) echo -n 104 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "And of course, ${code}cat${reset} just displays the file without modifying it, so the date does not change."; restore=$(expr $restore + 1) ;&
105) echo -n 105 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "And now let's get back to permissions, especially on the ${code}chmod${reset} command."; restore=$(expr $restore + 1) ;&
106) echo -n 106 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "We have already seen how to use ${code}chmod${reset} with letters: r, w, x, u, g, o."; restore=$(expr $restore + 1) ;&
107) echo -n 107 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "But it is also possible to use ${code}chmod${reset} with 3 digits!"; restore=$(expr $restore + 1) ;&
108) echo -n 108 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "Each letter has a numeric value, the letter 'r' will be 4, 'w' will be 2 and 'x' will be 1."; restore=$(expr $restore + 1) ;&
109) echo -n 109 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "It will then be necessary to add the permissions, 'rw-' will be 4 + 2 = ${voc}6${reset}, 'rx' will be 4 + 1 = ${voc}5${reset}, 'r - 'will be ${voc}4${reset},' rwx 'will be 4 + 2 + 1 = ${voc}7${reset},' --- 'will of course be ${voc}0 ${reset }, etc ..."; restore=$(expr $restore + 1) ;&
110) echo -n 110 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "You must use three of these sums for the owner, the group, and the others, respectively."; restore=$(expr $restore + 1) ;&
111) echo -n 111 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "For example, on the file 'test', to give all rights to the owner but none to the rest, it will make ${learn}chmod 700 test${reset}"; restore=$(expr $restore + 1) ;&
112) echo -n 112 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "${codeFile} 7${reset} 00 gives all the permissions to the owner: ${codeFile} rwx${reset}"; restore=$(expr $restore + 1) ;&
113) echo -n 113 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "7 ${codeFile} 0${reset} 0 gives no permission to the group: ${codeFile} ---${reset}"; restore=$(expr $restore + 1) ;&
114) echo -n 114 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "70 ${codeFile} 0${reset} gives no permission to others: ${codeFile} ---${reset}"; restore=$(expr $restore + 1) ;&
115) echo -n 115 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "${codeFile} $ 700 {reset} is equivalent to ${codeFile} rwx ------${reset}."; restore=$(expr $restore + 1) ;&
116) echo -n 116 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk_not_press_key justumen "Give the rights rw-r - r-- to all elements of two letters in the current directory, using chmod and its digits."; restore=$(expr $restore + 1) ;&
117) echo -n 117 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; answer_run "chmod 644 ??" justumen "No"; restore=$(expr $restore + 1) ;&
118) echo -n 118 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk_not_press_key justumen "Let's see the result with: ${learn}ls -l${reset}"; restore=$(expr $restore + 1) ;&
119) echo -n 119 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; answer_run "ls -l" justumen "No"; restore=$(expr $restore + 1) ;&
120) echo -n 120 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "You may have noticed that the command ${learn}chmod 644 ??${reset} has no equivalent with letters."; restore=$(expr $restore + 1) ;&
121) echo -n 121 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "Or rather it takes several orders to have the same effect."; restore=$(expr $restore + 1) ;&
122) echo -n 122 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "It will first reset all the permissions to 0 with ${learn}chmod ugo-rwx $${reset}."; restore=$(expr $restore + 1) ;&
123) echo -n 123 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "Then ${learn}chmod ugo + r${reset} to do the equivalent of ${learn}chmod 444 ??${reset}."; restore=$(expr $restore + 1) ;&
124) echo -n 124 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "Then you have to turn ${code}$ 444 {reset} into ${code}$ 644 {reset} with ${learn}chmod u + w${reset}."; restore=$(expr $restore + 1) ;&
125) echo -n 125 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "However the opposite is not possible at all, ${code}u + w${reset} has no numerical equivalent, because the result will depend on the previous permissions."; restore=$(expr $restore + 1) ;&
126) echo -n 126 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "The two methods are not equivalent!"; restore=$(expr $restore + 1) ;&
127) echo -n 127 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "It will be up to you to choose which method you want to use, depending on your situation."; restore=$(expr $restore + 1) ;&
128) echo -n 128 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "And to finish with the basics on permissions, let's see how to change ownership and group."; restore=$(expr $restore + 1) ;&
129) echo -n 129 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "The command to use will be: ${code}chown${reset}, abbreviation of: ${code}ch${reset} angel ${code}own${reset} er."; restore=$(expr $restore + 1) ;&
130) echo -n 130 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk_not_press_key justumen "To put ${voc}root${reset} as the owner of the 'f' file you can simply type: ${learn}chown root f${reset}"; restore=$(expr $restore + 1) ;&
131) echo -n 131 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; answer_run "chown root f" justumen "No"; restore=$(expr $restore + 1) ;&
132) echo -n 132 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "Here this command does not work! This is again a permission problem, but it is not the same type."; restore=$(expr $restore + 1) ;&
133) echo -n 133 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "For security reasons, some commands can only be used by the administrator user: ${voc}root${reset}."; restore=$(expr $restore + 1) ;&
134) echo -n 134 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "${code}chown${reset} is one of them, it's a command that only ${voc}root${reset} can use!"; restore=$(expr $restore + 1) ;&
135) echo -n 135 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "But I will not ask you for your password ${voc}root${reset} in GameScript."; restore=$(expr $restore + 1) ;&
136) echo -n 136 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "I invite you to test this command ${code}chown${reset} later, in root, by yourself in another terminal!"; restore=$(expr $restore + 1) ;&
137) echo -n 137 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "To login in ${code}root${reset} you can do: ${learn}su root${reset}. Your password will then be asked and you will have your terminal in ${code}root${reset}."; restore=$(expr $restore + 1) ;&
138) echo -n 138 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "To test if you are ${voc}root${reset} you can use the command: ${learn}whoami${reset}."; restore=$(expr $restore + 1) ;&
139) echo -n 139 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "If you want to change the ${voc}group${reset} you have to use the symbol ${code}:${reset}, like ${learn}chown: familyEinstein f${reset}."; restore=$(expr $restore + 1) ;&
140) echo -n 140 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "And of course you can change both at the same time, such as ${learn}chown albert: Einstein family f${reset}."; restore=$(expr $restore + 1) ;&
141) echo -n 141 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "Be careful, however, of all the commands you run in ${voc}root${reset}!"; restore=$(expr $restore + 1) ;&
142) echo -n 142 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "${voc}root${reset} has ALL permissions for ALL items!"; restore=$(expr $restore + 1) ;&
143) echo -n 143 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "${voc}root${reset} is not only able to delete all your files, but it also has the power to make your system unusable!"; restore=$(expr $restore + 1) ;&
144) echo -n 144 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "A clumsy command in ${voc}root${reset}, or a malicious script in ${voc}root${reset} can have devastating effects."; restore=$(expr $restore + 1) ;&
145) echo -n 145 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "You now master everything you need to analyze and control your permissions."; restore=$(expr $restore + 1) ;&
146) echo -n 146 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "Good luck for the quiz!"; restore=$(expr $restore + 1) ;&
147) echo -n 147 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; clean; restore=$(expr $restore + 1) ;&
esac
}
function clean(){ #in enter_chapter
rm $HOME/.GameScript/restore_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
rm $HOME/.GameScript/restore_pwd_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
	chmod -R 744 $HOME/.GameScript_bash6 2> /dev/null
	rm $HOME/.GameScript_bash6/f 2> /dev/null
	rm $HOME/.GameScript_bash6/f1 2> /dev/null
	rm $HOME/.GameScript_bash6/f2 2> /dev/null
	rm $HOME/.GameScript_bash6/f3 2> /dev/null
	rm $HOME/.GameScript_bash6/f4 2> /dev/null
	rm $HOME/.GameScript_bash6/f10 2> /dev/null
	rm $HOME/.GameScript_bash6/f50 2> /dev/null
	rm $HOME/.GameScript_bash6/intrus 2> /dev/null
	rmdir $HOME/.GameScript_bash6 2> /dev/null
}

function start_quiz(){
  echo ""
  echo -e "\e[15;5;44m Bash 'Bourne Again SHell' : Questionnaire du chapitre 6 \e[0m"
  echo -e "- La réponse doit être la plus courte possible, une commande valide mais ajoutant des caractères inutiles ne fonctionnera pas."
  echo -e "Exemple : si la réponse est 'ls'. Les réponses 'ls .', 'ls ./' et 'ls ././' seront considérées comme fausses."
  answer_text_fr "Dans terminal root, comment définir 'albert' comme propriétaire et 'familleEinstein' comme groupe au fichier 'test' du répertoire courant ?" "chown albert:familleEinstein test"
  answer_text_fr "Quelle commande affiche les éléments du répertoire courant par ordre alphabétique ?" "ls"
  answer_text_fr "Quelle commande affiche les métadonnées des éléments du répertoire courant ?" "ls -l"
  answer_text_fr "Comment afficher tous les éléments du répertoire courant dont le nom commence par 'x' ?" "ls x*"
  answer_text_fr "Comment supprimer tous les éléments du répertoire courant ayant un nom de 2 lettres ?" "rm ??"
  answer_text_fr "Comment déplacer tous les éléments du répertoire courant qui finissent par '.html' dans le répertoire parent de votre répertoire parent ?" "mv *.html ../.."
  answer_text_fr "Comment donner au fichier 'test' les permissions : --x-----x ?" "chmod 101 test"
  answer_text_fr "Comment donner au fichier 'test' les permissions : rwxr-x-wx ?" "chmod 753 test"
  unlock "bash" "6" "8239" "df22"
}


CHAPTER_NAME="bash"
CHAPTER_NUMBER="6"
LANGUAGE="fr"
SPEAKER="m1"

LINES=146
if [ ! "$1" == "MUTE" ]; then prepare_audio; fi

enter_chapter $CHAPTER_NAME $CHAPTER_NUMBER