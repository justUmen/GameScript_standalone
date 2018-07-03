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
function download_all_videos(){
	#~ echo "Downloading..."
	cd $VIDEO_LOCAL || exit
	i=4
	rm to_dl.wget 2> /dev/null
	echo "Downloading Videos..."
	while [ $i -le $LINES ]; do
		#~ ( wget -q $AUDIO_DL/$i.mp3 -O $AUDIO_LOCAL/$i.mp3 || rm $AUDIO_LOCAL/$i.mp3 ) &> /dev/null &
		echo "$VIDEO_DL/$i.mp3.mp4" >> to_dl.wget
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
function prepare_video(){
	VIDEO_LOCAL="$HOME/.GameScript/Video/$LANGUAGE/classic/$CHAPTER_NAME/$SPEAKER/c$CHAPTER_NUMBER"
	mkdir -p $AUDIO_LOCAL 2> /dev/null
	VIDEO_DL="https://raw.githubusercontent.com/justUmen/GameScript/master/$LANGUAGE/classic/$CHAPTER_NAME/Video/$SPEAKER/c$CHAPTER_NUMBER"
	VIDEOCMP=1
	if [ ! -f "$VIDEO_LOCAL/4.mp3.mp4" ]; then
		wget -q --spider http://google.com
		if [ $? -eq 0 ]; then
			download_all_videos
		else
			echo "Cannot download videos, no internet ?"
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

function new_video(){
	#~ $SOUNDPLAYER "$AUDIO_LOCAL/$restore.mp3" &> /dev/null &
	mpv "$VIDEO_LOCAL/$restore.mp3.mp4" &> /dev/null &
}

function talk(){
	if [[ $VIDEO == 0 ]]; then 
		if [[ $MUTE == 0 ]]; then 
			new_sound
		fi
	else
		new_video
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
	if [[ $VIDEO == 0 ]]; then 
		if [[ $MUTE == 0 ]]; then 
			new_sound
		fi
	else
		new_video
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
			0) if [[ $VIDEO == 0 ]]; then download_all_sounds; else download_all_videos; fi ;;
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
VIDEO=0
if [ "$1" == "VIDEO" ]; then
	VIDEO=1
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
1) echo -n 1 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; [ -d "$HOME/.GameScript_bash7" ] && echo "Erreur innatendu, ${HOME}/.GameScript_bash7 existe déjà sur votre système ! Supprimez ce dossier $HOME/.GameScript_bash7 et relancer ce script." && exit; restore=$(expr $restore + 1) ;&
2) echo -n 2 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; mkdir $HOME/.GameScript_bash7 2> /dev/null; restore=$(expr $restore + 1) ;&
3) echo -n 3 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; cd $HOME/.GameScript_bash7; restore=$(expr $restore + 1) ;&
4) echo -n 4 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "We have already seen in previous chapters how to use the ${code}>${reset} symbol."; restore=$(expr $restore + 1) ;&
5) echo -n 5 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "This symbol allows us to redirect the result of a command to a file, such as ${learn}ls> file${reset}."; restore=$(expr $restore + 1) ;&
6) echo -n 6 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "The file 'file' will be created if it does not exist and will contain the result of the command ${learn}ls${reset}."; restore=$(expr $restore + 1) ;&
7) echo -n 7 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "With the symbol ${code}>${reset} the result of the command to its left no longer appears in the terminal."; restore=$(expr $restore + 1) ;&
8) echo -n 8 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Start with this command with a typo: ${learn}lss> file${reset}"; restore=$(expr $restore + 1) ;&
9) echo -n 9 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "Lss> file" justumen "No"; restore=$(expr $restore + 1) ;&
10) echo -n 10 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Now display the contents of 'file'."; restore=$(expr $restore + 1) ;&
11) echo -n 11 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "cat file" justumen "No"; restore=$(expr $restore + 1) ;&
12) echo -n 12 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Here, the command ${learn}lss> file${reset} shows us an error in the terminal and the file 'file' is empty."; restore=$(expr $restore + 1) ;&
13) echo -n 13 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "One would have thought that with the ${learn}command lss> file${reset}, that the error message would be in the file 'file'."; restore=$(expr $restore + 1) ;&
14) echo -n 14 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; stdout; restore=$(expr $restore + 1) ;&
15) echo -n 15 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Well no ! When a command executes, there are ${voc}two${reset} independent output streams."; restore=$(expr $restore + 1) ;&
16) echo -n 16 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "The first stream is the one we have already redirected with the ${code}>${reset}, this is the ${voc}standard output${reset}. (in English stdout or standard output)"; restore=$(expr $restore + 1) ;&
17) echo -n 17 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; stderr; restore=$(expr $restore + 1) ;&
18) echo -n 18 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "The errors use another output stream, which is called the ${voc}output standard error${reset}. (stderr or standard error)"; restore=$(expr $restore + 1) ;&
19) echo -n 19 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Having two different streams, it is for example possible to redirect the results of one side, and the errors of the other."; restore=$(expr $restore + 1) ;&
20) echo -n 20 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "By default, without the use of redirects, a terminal displays both streams in the same place."; restore=$(expr $restore + 1) ;&
21) echo -n 21 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "To redirect the ${voc}standard output${reset}, use ${code}1>${reset}."; restore=$(expr $restore + 1) ;&
22) echo -n 22 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7;  stdout_2; restore=$(expr $restore + 1) ;&
23) echo -n 23 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "${code}>${reset} is actually an abbreviation for ${code}1>${reset}. Both are equivalent and redirect the ${voc}standard output${reset}."; restore=$(expr $restore + 1) ;&
24) echo -n 24 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Make a ${learn}pwd1> file${reset}"; restore=$(expr $restore + 1) ;&
25) echo -n 25 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "PWD1> file" justumen "No"; restore=$(expr $restore + 1) ;&
26) echo -n 26 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Here we have a problem because the terminal considers that the complete command is not ${code}pwd${reset}, but ${code}pwd1${reset}."; restore=$(expr $restore + 1) ;&
27) echo -n 27 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "We have already seen in chapter 3 that the ${learn}echo command b${reset} was equivalent to ${learn}echo a b${reset}."; restore=$(expr $restore + 1) ;&
28) echo -n 28 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "${code}echo${reset} considers that the first argument is 'a' and the second argument is 'b'."; restore=$(expr $restore + 1) ;&
29) echo -n 29 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "But this logic applies to all orders. It is actually possible to add spaces at will."; restore=$(expr $restore + 1) ;&
30) echo -n 30 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "For example, ${learn}ls -a${reset} is equivalent ${learn}ls -a${reset}."; restore=$(expr $restore + 1) ;&
31) echo -n 31 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "The '-a' option needs ${voc}of at least one${reset} space so that it can be interpreted as an option."; restore=$(expr $restore + 1) ;&
32) echo -n 32 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "So make a ${learn}ls-a${reset}"; restore=$(expr $restore + 1) ;&
33) echo -n 33 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "Ls -a" justumen "No"; restore=$(expr $restore + 1) ;&
34) echo -n 34 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Here ${learn}ls-a${reset} simply causes the launch of an unknown command with no option."; restore=$(expr $restore + 1) ;&
35) echo -n 35 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Sometimes this space is not necessary, as with the special symbols: ${code}>${reset}, ${code}&${reset}, ${code}|${reset}, etc ..."; restore=$(expr $restore + 1) ;&
36) echo -n 36 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "A special symbol will not be considered as belonging to the name of the command or file unless preceded by the escape character."; restore=$(expr $restore + 1) ;&
37) echo -n 37 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "But the command ${learn}pwd> file${reset} can be written ${learn}pwd> file${reset} or ${learn}pwd> file${reset} or ${learn } pwd> file${reset}, etc."; restore=$(expr $restore + 1) ;&
38) echo -n 38 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "That being said, let's go back to our problem with ${learn}pwd1> file${reset}."; restore=$(expr $restore + 1) ;&
39) echo -n 39 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Since the number '1' is not a special character, your terminal assumes that the complete command is ${learn}pwd1${reset}."; restore=$(expr $restore + 1) ;&
40) echo -n 40 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "It will be necessary here to separate ${code}1>${reset} from ${code}pwd${reset} by a space."; restore=$(expr $restore + 1) ;&
41) echo -n 41 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Make a ${learn}pwd 1> file${reset}"; restore=$(expr $restore + 1) ;&
42) echo -n 42 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "pwd 1> file" justumen "No"; restore=$(expr $restore + 1) ;&
43) echo -n 43 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "View the contents of the file."; restore=$(expr $restore + 1) ;&
44) echo -n 44 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "cat file" justumen "No"; restore=$(expr $restore + 1) ;&
45) echo -n 45 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "${learn}pwd 1> file${reset} is well equivalent to ${learn}pwd> file${reset}."; restore=$(expr $restore + 1) ;&
46) echo -n 46 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7;  stderr_2; restore=$(expr $restore + 1) ;&
47) echo -n 47 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "To redirect the ${voc}output standard error${reset}, it will simply use ${code}2>${reset}."; restore=$(expr $restore + 1) ;&
48) echo -n 48 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "So make a ${learn}pwd 2> error${reset}"; restore=$(expr $restore + 1) ;&
49) echo -n 49 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "pwd 2> error" justumen "No"; restore=$(expr $restore + 1) ;&
50) echo -n 50 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Here the result of the command is displayed in the terminal."; restore=$(expr $restore + 1) ;&
51) echo -n 51 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Normal since with this command we do not have a redirection of the standard output."; restore=$(expr $restore + 1) ;&
52) echo -n 52 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Now display the contents of the 'error' file."; restore=$(expr $restore + 1) ;&
53) echo -n 53 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "cat error" justumen "No"; restore=$(expr $restore + 1) ;&
54) echo -n 54 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "The file is empty because no message has been sent on the ${voc}standard error${reset} stream."; restore=$(expr $restore + 1) ;&
55) echo -n 55 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "But you may notice that the file has been created."; restore=$(expr $restore + 1) ;&
56) echo -n 56 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Now do the same command with a typo: ${learn}pwdd 2> error${reset}"; restore=$(expr $restore + 1) ;&
57) echo -n 57 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "pwdd 2> error" justumen "No"; restore=$(expr $restore + 1) ;&
58) echo -n 58 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Here nothing is displayed in the terminal."; restore=$(expr $restore + 1) ;&
59) echo -n 59 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Normal again, since nothing has been sent on the ${voc}${reset} standard output."; restore=$(expr $restore + 1) ;&
60) echo -n 60 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Display the contents of the 'error' file."; restore=$(expr $restore + 1) ;&
61) echo -n 61 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "cat error" justumen "No"; restore=$(expr $restore + 1) ;&
62) echo -n 62 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Here the error has been saved in the file."; restore=$(expr $restore + 1) ;&
63) echo -n 63 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Try to separate the results and errors of a command separately in two different files with: ${learn}pwd 1> out 2> err${reset}"; restore=$(expr $restore + 1) ;&
64) echo -n 64 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "pwd 1> out 2> err" justumen "No"; restore=$(expr $restore + 1) ;&
65) echo -n 65 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Display the contents of the 'err' file."; restore=$(expr $restore + 1) ;&
66) echo -n 66 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "cat err No" justumen ""; restore=$(expr $restore + 1) ;&
67) echo -n 67 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Since the command does not cause an error, 'err' is empty."; restore=$(expr $restore + 1) ;&
68) echo -n 68 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "To check if ${code}1>${reset} and ${code}2>${reset} can work at the same time, we will have to use a code that uses both streams."; restore=$(expr $restore + 1) ;&
69) echo -n 69 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "For example: ${learn}pwdd || pwd${reset}."; restore=$(expr $restore + 1) ;&
70) echo -n 70 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "${code}pwdd${reset} will return an error message. It will therefore use the standard error output. (Stderr)"; restore=$(expr $restore + 1) ;&
71) echo -n 71 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "${code}pwdd${reset} returning an error, the command ${code}pwd${reset} will launch and send its result to the standard output. (Stdout)"; restore=$(expr $restore + 1) ;&
72) echo -n 72 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "${code}1>${reset} is equivalent to ${code}>${reset}, and the equivalent of ${code}>>${reset} is simply ${code}1 >> ${ reset}."; restore=$(expr $restore + 1) ;&
73) echo -n 73 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Try doing: ${learn}pwdd || pwd 1 >> f 2 >> e${reset}"; restore=$(expr $restore + 1) ;&
74) echo -n 74 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "pwdd || pwd 1 >> f 2 >> e" justumen "No"; restore=$(expr $restore + 1) ;&
75) echo -n 75 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Here an error appears in the terminal, ${code}2 >>${reset} seems not to work ..."; restore=$(expr $restore + 1) ;&
76) echo -n 76 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "In fact, redirects are used with a command. Here ${code}pwdd || pwd${reset} is not a command!"; restore=$(expr $restore + 1) ;&
77) echo -n 77 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7;  stdout_stderr_1; restore=$(expr $restore + 1) ;&
78) echo -n 78 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "This is actually ${voc}two${reset} commands: ${code}pwdd${reset} and ${code}pwd${reset}."; restore=$(expr $restore + 1) ;&
79) echo -n 79 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "That is, ${learn}pwdd || pwd 1 >> f 2 >> e${reset} is also composed of ${voc}two${reset} commands."; restore=$(expr $restore + 1) ;&
80) echo -n 80 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "The first: ${code}pwdd${reset} and the second one: ${code}pwd 1 >> f 2 >> e${reset}."; restore=$(expr $restore + 1) ;&
81) echo -n 81 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "In this case, ${code}2 >> e${reset} will only redirect command errors ${code}pwd${reset}."; restore=$(expr $restore + 1) ;&
82) echo -n 82 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "It is therefore normal for the ${code}pwdd${reset} error to be displayed in the terminal."; restore=$(expr $restore + 1) ;&
83) echo -n 83 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "To redirect the results and the errors of the two commands, do: ${learn}pwdd 1 >> f 2 >> e || pwd 1 >> f 2 >> e${reset}"; restore=$(expr $restore + 1) ;&
84) echo -n 84 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "pwdd 1 >> f 2 >> e || pwd 1 >> f 2 >> e" justumen "No"; restore=$(expr $restore + 1) ;&
85) echo -n 85 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "You can also simply group the two commands so that they make ${voc}only${reset}, using the ${code}()${reset}."; restore=$(expr $restore + 1) ;&
86) echo -n 86 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7;  stdout_stderr_2; restore=$(expr $restore + 1) ;&
87) echo -n 87 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "For example, for ${code}(ls && lss) 2> e${reset}, the redirection ${code}2> e${reset} will be done on ${code}ls && lss${reset}, not just on ${code}${reset} loess."; restore=$(expr $restore + 1) ;&
88) echo -n 88 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "The space here between ${code})${reset} and ${code}2> e${reset} is not necessary because ${code})${reset} is a special character, so it separates without ambiguity redirection."; restore=$(expr $restore + 1) ;&
89) echo -n 89 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Do: ${learn}(pwdd || pwd) 1 >> f 2 >> e${reset}, the equivalent of the previous command: ${learn}pwdd 1 >> f 2 >> e || pwd 1 >> f 2 >> e${reset}."; restore=$(expr $restore + 1) ;&
90) echo -n 90 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "(pwdd || pwd) 1 >> f 2 >> e" justumen "No"; restore=$(expr $restore + 1) ;&
91) echo -n 91 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Display the contents of the 'e' file."; restore=$(expr $restore + 1) ;&
92) echo -n 92 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "cat e" justumen "No"; restore=$(expr $restore + 1) ;&
93) echo -n 93 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Here the second error has been added as a result of the error of the previous command."; restore=$(expr $restore + 1) ;&
94) echo -n 94 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "To better understand these ${code}()${reset}, let's take an example that we have already seen, do so: ${learn}cat FILE && echo GOOD || echo ERROR${reset}"; restore=$(expr $restore + 1) ;&
95) echo -n 95 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "cat FILE && echo GOOD || echo ERROR" justumen "No"; restore=$(expr $restore + 1) ;&
96) echo -n 96 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Here, if FILE does not exist in FILE, ${code}cat FILE${reset} will return an error, which will cause the launch of ${code}echo ERROR${reset}."; restore=$(expr $restore + 1) ;&
97) echo -n 97 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Now do a simple: ${learn}echo GOOD || echo ERROR${reset}"; restore=$(expr $restore + 1) ;&
98) echo -n 98 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "echo GOOD || echo ERROR" justumen "No"; restore=$(expr $restore + 1) ;&
99) echo -n 99 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Obviously here ERROR is not displayed. However the code is the same as in the previous command: ${learn}cat FILE && echo GOOD || echo ERROR${reset}."; restore=$(expr $restore + 1) ;&
100) echo -n 100 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "But in ${learn}cat FILE && echo GOOD || echo ERROR${reset}, ${code}echo ERROR${reset} will start because ${code}||${reset} does not combine with ${code}echo GOOD${reset} as in ${learn}echo GOOD || echo ERROR${reset}, but with ${code}cat FILE && echo GOOD${reset}."; restore=$(expr $restore + 1) ;&
101) echo -n 101 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Without the ${code}()${reset}, conditions simply read from left to right."; restore=$(expr $restore + 1) ;&
102) echo -n 102 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "${learn}cat FILE && echo GOOD || echo ERROR${reset} actually has a logical order equivalent to ${learn}(cat FILE && echo GOOD) || echo ERROR${reset}"; restore=$(expr $restore + 1) ;&
103) echo -n 103 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "As ${code}cat FILE && echo GOOD${reset} returns an error, ${code}echo ERROR${reset} will launch."; restore=$(expr $restore + 1) ;&
104) echo -n 104 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "So you can also change the reading direction of your conditions with ${code}()${reset}."; restore=$(expr $restore + 1) ;&
105) echo -n 105 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "For example, let's take the following code: ${learn}cd DOSSIER && (cat FILE || echo \ "FILE does not exist in FILE \") || echo \ "FILE does not exist \" ${ reset}"; restore=$(expr $restore + 1) ;&
106) echo -n 106 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "The ${code}()${reset} bind the ${code}command echo \ "FILE does not exist in FILE \"${reset} with ${code}cat FILE ${reset }."; restore=$(expr $restore + 1) ;&
107) echo -n 107 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Without ${code}()${reset}, ${code}echo \ "FILE does not exist in DOSSIER \"${reset} will launch if the command ${code}cd DOSSIER${reset} returns an error, which is not what we want."; restore=$(expr $restore + 1) ;&
108) echo -n 108 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "You can use these ${code}()${reset} to group your code."; restore=$(expr $restore + 1) ;&
109) echo -n 109 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Whether your goal is to change the execution logic of your commands, or as before to group the output streams."; restore=$(expr $restore + 1) ;&
110) echo -n 110 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "To redirect standard output, you must use ${code}>${reset} or ${code}1>${reset}."; restore=$(expr $restore + 1) ;&
111) echo -n 111 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "To redirect the error output, you must use ${code}2>${reset}."; restore=$(expr $restore + 1) ;&
112) echo -n 112 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "If you want to redirect both at once, you can use: ${code}&>${reset}."; restore=$(expr $restore + 1) ;&
113) echo -n 113 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Or of course ${code}& >>${reset} if you want to add the content at the end of a file."; restore=$(expr $restore + 1) ;&
114) echo -n 114 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Do: ${learn}pwd & >> f${reset}"; restore=$(expr $restore + 1) ;&
115) echo -n 115 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "& Pwd >> f" justumen "No"; restore=$(expr $restore + 1) ;&
116) echo -n 116 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "${code}& >>${reset} starts with a special character, so the space on the left is not needed, as opposed to ${code}1>${reset} or ${code}2>${reset} that we saw previously."; restore=$(expr $restore + 1) ;&
117) echo -n 117 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Do the same command with a typo: ${learn}pwdd & >> f${reset}"; restore=$(expr $restore + 1) ;&
118) echo -n 118 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run ">> PWDD & f" justumen "No"; restore=$(expr $restore + 1) ;&
119) echo -n 119 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "With this command, nothing is displayed in the terminal, so both redirections happen correctly."; restore=$(expr $restore + 1) ;&
120) echo -n 120 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "${code}& >>${reset} is well equivalent to the combination of ${code}1 >>${reset} and ${code}2 >>${reset}."; restore=$(expr $restore + 1) ;&
121) echo -n 121 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "But sometimes it's possible that a feed does not interest you at all."; restore=$(expr $restore + 1) ;&
122) echo -n 122 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "For this kind of case there is a special file, ${code}/ dev / null${reset}, that you can use with your redirects."; restore=$(expr $restore + 1) ;&
123) echo -n 123 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "${code}/ dev / null${reset} is an empty file that will always be empty."; restore=$(expr $restore + 1) ;&
124) echo -n 124 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Then display the contents of the non-existent file 'X', getting rid of error messages."; restore=$(expr $restore + 1) ;&
125) echo -n 125 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "cat X 2> / dev / null" justumen "No"; restore=$(expr $restore + 1) ;&
126) echo -n 126 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Display the contents of the file ${code}/ dev / null${reset}"; restore=$(expr $restore + 1) ;&
127) echo -n 127 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "cat / dev / null" justumen "No"; restore=$(expr $restore + 1) ;&
128) echo -n 128 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Indeed, despite this redirection, ${code}/ dev / null${reset} is always empty."; restore=$(expr $restore + 1) ;&
129) echo -n 129 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "If you want to get rid of both streams, just use ${code}&> / dev / null${reset}."; restore=$(expr $restore + 1) ;&
130) echo -n 130 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "You can also, if you want, redirect a feed to another feed....."; restore=$(expr $restore + 1) ;&
131) echo -n 131 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "${code}2> & 1${reset} will redirect the standard error output to standard output, and ${code}1> & 2${reset} will redirect the standard output to the standard error output."; restore=$(expr $restore + 1) ;&
132) echo -n 132 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Add at the end of the file '/tmp/pwd.log' the standard output of the command ${code}pwd${reset}, then group its standard error output with its standard output."; restore=$(expr $restore + 1) ;&
133) echo -n 133 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "pwd >> / tmp / pwd.log 2> & 1" justumen "No"; restore=$(expr $restore + 1) ;&
134) echo -n 134 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Display the contents of the file '/tmp/pwd.log'."; restore=$(expr $restore + 1) ;&
135) echo -n 135 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "cat /tmp/pwd.logissNo" justumen ""; restore=$(expr $restore + 1) ;&
136) echo -n 136 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Now, do it with a typo: ${learn}pwdd >> / tmp / pwd.log 2> & 1${reset}"; restore=$(expr $restore + 1) ;&
137) echo -n 137 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "pwdd >> / tmp / pwd.log 2> & 1" justumen "No"; restore=$(expr $restore + 1) ;&
138) echo -n 138 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Then redisplay the contents of '/tmp/pwd.log'."; restore=$(expr $restore + 1) ;&
139) echo -n 139 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "cat /tmp/pwd.logissNo" justumen ""; restore=$(expr $restore + 1) ;&
140) echo -n 140 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Here the error has been added, so ${code}2> & 1${reset} is clearly dependent on the ${code}>>${reset} of the standard output."; restore=$(expr $restore + 1) ;&
141) echo -n 141 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Be careful with this syntax, ${code}2> & 1${reset} means that: \ "The standard error output will use the same redirection as the standard output \"."; restore=$(expr $restore + 1) ;&
142) echo -n 142 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "${code}2> & 1${reset} will therefore fit if the standard output redirection is ${code}>${reset} or ${code}>>${reset}."; restore=$(expr $restore + 1) ;&
143) echo -n 143 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "To add to the end of a file, ${codeError} 2 >> & 1${reset} might come to mind but it's not a valid syntax."; restore=$(expr $restore + 1) ;&
144) echo -n 144 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "To summarize: to combine the flows of the same type of several commands, we must use the ${code}()${reset}."; restore=$(expr $restore + 1) ;&
145) echo -n 145 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "So make ${learn}(pwdd; pwd)${reset}"; restore=$(expr $restore + 1) ;&
146) echo -n 146 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "(PWDD; pwd)" justumen "No"; restore=$(expr $restore + 1) ;&
147) echo -n 147 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7;  stdout_stderr_3; restore=$(expr $restore + 1) ;&
148) echo -n 148 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Here the two standard outputs are grouped into a single standard output, that of the ${code}pwdd${reset} command was empty."; restore=$(expr $restore + 1) ;&
149) echo -n 149 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "The two standard error outputs are also grouped into one standard error output, that of the ${code}pwd${reset} command was empty."; restore=$(expr $restore + 1) ;&
150) echo -n 150 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "So now we have our code, which uses both stdout and stderr: ${learn}(pwdd; pwd)${reset}."; restore=$(expr $restore + 1) ;&
151) echo -n 151 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "But there are still two separate ${voc}${reset} streams for this command group: its standard output and its standard error output."; restore=$(expr $restore + 1) ;&
152) echo -n 152 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7;  stdout_stderr_4; restore=$(expr $restore + 1) ;&
153) echo -n 153 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "This schema represents ${code}(pwdd; pwd)${reset}: stdout and stderr are independent, so you can redirect them normally."; restore=$(expr $restore + 1) ;&
154) echo -n 154 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "For example ${code}(pwdd; pwd) >> results 2 >>${reset} errors, stdout will be sent to the 'result' file, and stderr to the 'errors' file."; restore=$(expr $restore + 1) ;&
155) echo -n 155 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7;  stdout_stderr_2in1; restore=$(expr $restore + 1) ;&
156) echo -n 156 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "This scheme represents ${code}(pwdd; pwd) 2> & 1${reset}, here the error output will be combined with the standard output."; restore=$(expr $restore + 1) ;&
157) echo -n 157 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "However, if you want to redirect the content to a file, you will have to do ${voc}before${reset} to redirect stderr with ${code}2> & 1${reset} because redirects are read from left to right."; restore=$(expr $restore + 1) ;&
158) echo -n 158 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "For example, ${code}(pwdd; pwd)> tmp 2> & 1${reset} do not have the same meaning as ${code}(pwdd; pwd) 2> & 1> tmp${reset}."; restore=$(expr $restore + 1) ;&
159) echo -n 159 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "The first will redirect stdout and stderr to the 'tmp' file, while the second will only redirect stdout to the 'tmp' file."; restore=$(expr $restore + 1) ;&
160) echo -n 160 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "For example, consider the silly but correct command with two standard output redirects ${code}(pwdd; pwd)> / dev / null 2> & 1 1> f${reset}."; restore=$(expr $restore + 1) ;&
161) echo -n 161 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "With redirections reading from left to right, stdout will end in the 'f' file while stderr will remain in '/ dev / null'."; restore=$(expr $restore + 1) ;&
162) echo -n 162 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7;  stdout_stderr_1in2; restore=$(expr $restore + 1) ;&
163) echo -n 163 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "This scheme represents ${code}(pwdd; pwd) 1> & 2${reset}, here the standard output will be combined with the standard error output."; restore=$(expr $restore + 1) ;&
164) echo -n 164 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7;  (pwdd; pwd) 2 >> test 1> & 2; restore=$(expr $restore + 1) ;&
165) echo -n 165 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "To get rid of these two streams, you could add ${code}&> / dev / null${reset}."; restore=$(expr $restore + 1) ;&
166) echo -n 166 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Do it then: ${learn}(pwdd; pwd) &> / dev / null${reset}"; restore=$(expr $restore + 1) ;&
167) echo -n 167 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "(PWDD; pwd) &> / dev / null" justumen "No"; restore=$(expr $restore + 1) ;&
168) echo -n 168 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "${code}&> / dev / null${reset} would be equivalent to: ${code}> / dev / null 2> & 1${reset}, or ${code}1> / dev / null 2> & 1${reset}, or ${code}2> / dev / null 1> & 2${reset}."; restore=$(expr $restore + 1) ;&
169) echo -n 169 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Now redirect the two streams to the 'F' file with: ${learn}(pwdd; pwd) &> F${reset}"; restore=$(expr $restore + 1) ;&
170) echo -n 170 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "(PWDD; pwd) &> " justumen " F No"; restore=$(expr $restore + 1) ;&
171) echo -n 171 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Then display the contents of file F."; restore=$(expr $restore + 1) ;&
172) echo -n 172 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "cat F" justumen "No"; restore=$(expr $restore + 1) ;&
173) echo -n 173 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "You can note here that the two streams were gathered before writing to the file, that is to say that despite the use of ${code}>${reset} instead of ${code}>> ${ reset}, the second line did not overwrite the first one."; restore=$(expr $restore + 1) ;&
174) echo -n 174 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Do it again: ${learn}(pwdd; pwd) &> F${reset}"; restore=$(expr $restore + 1) ;&
175) echo -n 175 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "(PWDD; pwd) &> " justumen " F No"; restore=$(expr $restore + 1) ;&
176) echo -n 176 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Then redisplay the contents of file F."; restore=$(expr $restore + 1) ;&
177) echo -n 177 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "cat F" justumen "No"; restore=$(expr $restore + 1) ;&
178) echo -n 178 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Here you have these two lines again, if you had used ${code}& >>${reset} instead of ${code}&>${reset} you would have here obviously four lines."; restore=$(expr $restore + 1) ;&
179) echo -n 179 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Finally, the ${code}command (pwdd; pwd) >> tmp 2> & 1${reset} is equivalent to the command: ${code}(pwdd; pwd) & >> tmp${reset}"; restore=$(expr $restore + 1) ;&
180) echo -n 180 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "I hope these redirects are now clear for you and good luck for the quiz."; restore=$(expr $restore + 1) ;&
181) echo -n 181 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; clean; restore=$(expr $restore + 1) ;&
esac
}
CLREOL=$'\x1B[K'

function stderr(){
echo -e "$basic
%%%%%%%%%%%%%%%%%${CLREOL}
%               % stdout${CLREOL}
%      lss      %========>${CLREOL}
%               %${CLREOL}
%%%%%%%%%%%%%%%%%${CLREOL}
        |${CLREOL}
        |================> ${codeError}bash: lss: command not found${reset}${basic}${CLREOL}
         stderr${CLREOL}$reset"
}


function stderr_2(){
echo -e "$basic
%%%%%%%%%%%%%%%%%${CLREOL}
%               % stdout${CLREOL}
%      lss      %========>${CLREOL}
%               %${CLREOL}
%%%%%%%%%%%%%%%%%${CLREOL}
        |${CLREOL}
        |================> ${codeError}bash: lss: command not found${reset}${basic}${CLREOL}
         stderr ( ${code}2>${reset}${basic} )${CLREOL}$reset"
}


function stdout(){
echo -e "$basic
%%%%%%%%%%%%%%%%%${CLREOL}
%               % stdout${CLREOL}
%      pwd      %========> ${codeFile}$HOME/.GameScript_bash7${reset}${basic}${CLREOL}
%               %${CLREOL}
%%%%%%%%%%%%%%%%%${CLREOL}
        |${CLREOL}
        |================>${CLREOL}
         stderr${CLREOL}$reset"
}

function stdout_2(){
echo -e "$basic
%%%%%%%%%%%%%%%%%${CLREOL}
%               % stdout ( ${code}1>${reset}${basic} / ${code}>${reset}${basic} )${CLREOL}
%      pwd      %========> ${codeFile}$HOME/.GameScript_bash7${reset}${basic}${CLREOL}
%               %${CLREOL}
%%%%%%%%%%%%%%%%%${CLREOL}
        |${CLREOL}
        |================>${CLREOL}
         stderr${CLREOL}$reset"
}


function stdout_stderr_1(){
echo -e "$basic
%%%%%%%%%%%%%%%%%${CLREOL}
%               % stdout ( ${code}1>${reset}${basic} )${CLREOL}
%     pwdd      %========>${CLREOL}
%               %${CLREOL}
%%%%%%%%%%%%%%%%%${CLREOL}
        |${CLREOL}
        |================> ${codeError}bash: pwdd: command not found${reset}${basic}${CLREOL}
         stderr ( ${code}2>${reset}${basic} )${CLREOL}
${CLREOL}
%%%%%%%%%%%%%%%%%${CLREOL}
%               % stdout ( ${code}1>${reset}${basic} )${CLREOL}
%      pwd      %========> ${codeFile}$HOME/.GameScript_bash7${reset}${basic}${CLREOL}
%               %${CLREOL}
%%%%%%%%%%%%%%%%%${CLREOL}
        |${CLREOL}
        |================>${CLREOL}
         stderr ( ${code}2>${reset}${basic} )${CLREOL}$reset"
}

function stdout_stderr_2(){
echo -e "$basic
%%%%%%%%%%%%%%%%%${CLREOL}
%               % stdout ( ${code}1>${reset}${basic} )${CLREOL}
%   (ls&&lss)   %========> ${codeFile}e  error  f  file  err  out${reset}${basic}${CLREOL}
%               %${CLREOL}
%%%%%%%%%%%%%%%%%${CLREOL}
        |${CLREOL}
        |================> ${codeError}bash: lss: command not found${reset}${basic}${CLREOL}
         stderr ( ${code}2>${reset}${basic} )${CLREOL}$reset"
}

function stdout_stderr_3(){
echo -e "$basic
%%%%%%%%%%%%%%%%%${CLREOL}
%               % stdout   ${codeFile}${reset}${basic} ( pwdd )${CLREOL}
%  (pwdd;pwd)   %========> ${codeFile}$HOME/.GameScript_bash7${reset}${basic} ( pwd )${CLREOL}
%               %${CLREOL}
%%%%%%%%%%%%%%%%%${CLREOL}
        |                  ${codeError}bash: pwdd: command not found${reset}${basic} ( pwdd )${CLREOL}
        |================> ${codeError}${reset}${basic} ( pwd )${CLREOL}
         stderr${CLREOL}$reset"
}

function stdout_stderr_4(){
echo -e "$basic
%%%%%%%%%%%%%%%%%${CLREOL}
%               % stdout${CLREOL}
%  (pwdd;pwd)   %========> ${codeFile}$HOME/.GameScript_bash7${reset}${basic}${CLREOL}
%               %${CLREOL}
%%%%%%%%%%%%%%%%%${CLREOL}
        |${CLREOL}
        |================> ${codeError}bash: pwdd: command not found${reset}${basic}${CLREOL}
         stderr${CLREOL}$reset"
}

function stdout_stderr_2in1(){
echo -e "$basic
%%%%%%%%%%%%%%%%%${CLREOL}
%               % stdout + stderr${CLREOL}
%  (pwdd;pwd)   %========> ${codeFile}$HOME/.GameScript_bash7${reset}${basic}${CLREOL}
%               %   |      ${codeError}bash: pwdd: command not found${reset}${basic}${CLREOL}
%%%%%%%%%%%%%%%%%   |${CLREOL}
        |           | ( ${code}2>&1${reset}${basic} )${CLREOL}
        |===========|${CLREOL}
         stderr${CLREOL}$reset"
}

function stdout_stderr_1in2(){
echo -e "$basic
%%%%%%%%%%%%%%%%%${CLREOL}
%               %${CLREOL}
%  (pwdd;pwd)   %===|${CLREOL}
%               %   | ( ${code}1>&2${reset}${basic} )${CLREOL}
%%%%%%%%%%%%%%%%%   |${CLREOL}
        |           |      ${codeFile}$HOME/.GameScript_bash7${reset}${basic}${CLREOL}
        |================> ${codeError}bash: pwdd: command not found${reset}${basic}${CLREOL}
         stderr + stdout${CLREOL}$reset"
}



function clean(){ #in enter_chapter
rm $HOME/.GameScript/restore_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
rm $HOME/.GameScript/restore_pwd_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
	rm $HOME/.GameScript_bash7/file 2> /dev/null
	rm $HOME/.GameScript_bash7/error 2> /dev/null
	rm $HOME/.GameScript_bash7/e 2> /dev/null
	rm $HOME/.GameScript_bash7/f 2> /dev/null
	rm $HOME/.GameScript_bash7/out 2> /dev/null
	rm $HOME/.GameScript_bash7/err 2> /dev/null
	rm $HOME/.GameScript_bash7/F 2> /dev/null
	rm /tmp/pwd.log 2> /dev/null
	rmdir $HOME/.GameScript_bash7 2> /dev/null
}

function start_quiz(){
  echo ""
  echo -e "\e[15;5;44m Bash 'Bourne Again SHell' : Questionnaire du chapitre 7 \e[0m"
  echo -e "- La réponse doit être la plus courte possible, une commande valide mais ajoutant des caractères inutiles ne fonctionnera pas."
  echo -e "Exemple : si la réponse est 'ls'. Les réponses 'ls .', 'ls ./' et 'ls ././' seront considérées comme fausses."
  answer_text_fr "Comment afficher le contenu du fichier 'cat' en se débarassant de tous les messages d'erreur potentiels ?" "cat cat 2>/dev/null"
  answer_text_fr "Comment executer deux commandes : 'mkdir A' et 'touch B' et regrouper leurs flux de même type ? (erreur et sortie standard)" "(mkdir A;touch B)"
  answer_text_fr "La commande 'pwdd&>/dev/null' est équivalente à la commande 'pwdd 2>&1 >/dev/null'. (vrai/faux)" "faux"
  answer_text_fr "Le fichier ERROR étant créé par la commande 'cat x 2>ERROR', comment afficher son contenu sur la sortie standard ?" "cat ERROR"
  answer_text_fr "Comment afficher le contenu du fichier 'LOG' sur la sortie erreur standard ?" "cat LOG 1>&2"
  answer_text_fr "Comment rediriger la sortie standard et la sortie erreur standard de la commande 'mkdir TEST' dans le fichier /var/mkdir" "mkdir TEST&>/var/mkdir"
  answer_text_fr "Sans utiliser '&>>', comment ajouter à la fin du fichier '/tmp/pwd.log' la sortie standard de la commande 'pwd', puis regroupez sa sortie erreur standard avec sa sortie standard ?" "pwd>>/tmp/pwd.log 2>&1"
  unlock "bash" "7" "1109" "ff12"
}


CHAPTER_NAME="bash"
CHAPTER_NUMBER="7"
LANGUAGE="fr"
SPEAKER="m1"

LINES=180
if [ ! "$1" == "MUTE" ]; then prepare_audio; fi

enter_chapter $CHAPTER_NAME $CHAPTER_NUMBER
