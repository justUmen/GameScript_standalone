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
	mkdir -p $VIDEO_LOCAL 2> /dev/null
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
	VOICE_PID=$(ps -|grep "$SOUNDPLAYER"|grep -v grep|grep -v MUSIC|awk '{print $2}')
	#~ echo "VOICE_PID = $VOICE_PID"
	if [[ "$VOICE_PID" != "" ]]; then
		kill $VOICE_PID
	fi
	#~ pkill mplayer &> /dev/null
	#~ pkill mpg123 &> /dev/null
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
	#~ mpv "$VIDEO_LOCAL/$restore.mp3.mp4" &> /dev/null &
	ADD_PLAYLIST "$VIDEO_LOCAL/$restore.mp3.mp4"
	sleep 1
	PLAYLIST_NEXT #play next video
	#~ sleep 1
	LOOP_OFF
	sleep 1
	UNTIL_IDLE_IS_BACK
	#~ sleep 1
	#~ PLAYLIST_NEXT #play idle video
	#~ sleep 1
	LOOP_ON #After normal video is over, quickly put back LOOP
}

#~ PLAYLIST_NEXT #play next video
#~ LOOP_OFF
#~ UNTIL_IDLE_IS_BACK
#~ LOOP_ON


function talk(){
	if [[ $VIDEO == 0 ]]; then 
		if [[ $MUTE == 0 ]]; then 
			new_sound
		fi
	else
		new_video &
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
	while [ "$key" != "1" ] || [ "$key" != "2" ] || [ "$key" != "e" ]; do
		# echo ""
		#~ echo -e "\\e[0;100m 0) \\e[0m Télécharger audio en avance"
		echo -e "      \\e[0;100m 1) \\e[0m $1"
		echo -e "      \\e[0;100m 2) \\e[0m $2"
		echo -e "      \\e[0;100m e) \\e[0m $3"
		echo -en "      \\e[97;45m # \\e[0m"
		read key < /dev/tty
		case $key in
			0) 	if [[ $VIDEO == 0 ]]; then download_all_sounds; else download_all_videos; fi ;;
			1) 	case $LANGUAGE in
					fr) ANSWER_QUIZ_TEXT="$HOME/.GameScript/restore_$7$8 existe, continuer ou recommencer le cours du début ?"
						TEXT_CONTINUE="Continuer"
						TEXT_RESTART="Recommencer"
						TEXT_BACK="Retour"
					;;
					en) ANSWER_QUIZ_TEXT="$HOME/.GameScript/restore_$7$8 already exists, continue or start lecture from the beginning ?"
						TEXT_CONTINUE="Continue"
						TEXT_RESTART="Restart"
						TEXT_BACK="Back"
					;;
				esac
				if [ -f "$HOME/.GameScript/restore_$7$8" ];then
					echo "$ANSWER_QUIZ_TEXT"
					while [ "$choice" != "1" ] || [ "$choice" != "2" ] || [ "$choice" != "3" ]; do
						echo -e "      \\e[0;100m 1) \\e[0m $TEXT_CONTINUE"
						echo -e "      \\e[0;100m 2) \\e[0m $TEXT_RESTART"
						echo -e "      \\e[0;100m e) \\e[0m $TEXT_BACK"
						echo -en "      \\e[97;45m # \\e[0m"
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
			e) exit ;;
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
		case $LANGUAGE in
			fr) talk_not_press_key justumen "\\e[4;37mDésolé, réponse fausse ou trop longue. Je vous conseille de suivre / refaire le cours.\nSi vous pensez maitriser le contenu du cours, il y a surement un piège, relisez donc attentivement la question. :-)\nSi vous vous sentez vraiment bloqué, demandez de l'aide sur notre chat : https://rocket.bjornulf.org ou notre discord : https://discord.gg/25eRgvD\\e[0m"
				#enter_chapter $CHAPTER_NAME $CHAPTER_NUMBER
				exit ;;
			en) talk_not_press_key justumen "\\e[4;37mSorry answer wrong or too long. I recommend you to do / re-do the lecture :-)\nIf you think you already understand the content of the lecture, this question is probably a trap, read the question again carefully. :-)\nIf you feel stuck, ask for help in our chat : https://rocket.bjornulf.org or our discord : https://discord.gg/25eRgvD\\e[0m"
				#enter_chapter $CHAPTER_NAME $CHAPTER_NUMBER
				exit ;;
		esac
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
	case $LANGUAGE in
		fr) echo -e "Pour débloquer '$1 $2' sur rocketchat (https://rocket.bjornulf.org), ouvrez une conversation privée avec '@boti' et copiez/collez :\n\t\e[97;42mpassword$PASS\e[0m"
			echo -e "Pour débloquer '$1 $2' sur discord (https://discord.gg/25eRgvD), ouvrez le channel '#mots-de-passe-boti' et copiez/collez :\n\t\e[97;42mpassword$PASS\e[0m"
				;;
		en) echo -e "To unlock '$1 $2' on rocketchat (https://rocket.bjornulf.org), open a private conversation with '@boti' and copy/paste :\n\t\e[97;42mpassword$PASS\e[0m"
			echo -e "To unlock '$1 $2' on discord (https://discord.gg/25eRgvD), open the channel '#mots-de-passe-boti' and copy/paste :\n\t\e[97;42mpassword$PASS\e[0m"
				;;
	esac
	#AUTOMATICALLY DO THIS ?
	touch "$HOME/.GameScript/good_$1$2" 2> /dev/null
	mkdir $HOME/.GameScript/passwords/ 2> /dev/null
	echo -n "$PASS" > "$HOME/.GameScript/passwords/$1$2"
	press_key
	echo ""
	exit
}

function enter_chapter(){
	#Usage : enter_chapter bash 1 1 (first 1 is chapter, next one is for case)
	echo ""
	case $LANGUAGE in
		fr) echo -e "      \e[97;44m - $1, Chapitre $2 \e[0m"
			answer_quiz "Cours" "Questionnaire" "Retour" "4" "5" "6" "$1" "$2" ;;
		en) echo -e "      \e[97;44m - $1, Chapter $2 \e[0m"
			answer_quiz "Lecture" "Quiz" "Back" "4" "5" "6" "$1" "$2" ;;
	esac
}










#VIDEO SOUTH PARK
function UNTIL_IDLE_IS_BACK(){
	OUT=$(echo '{ "command": ["get_property", "filename"] }' | socat - /tmp/southpark)
	#~ echo $OUT
	while [ "$OUT" != '{"data":"10FPS_idle.mp4","error":"success"}' ]; do
		OUT=$(echo '{ "command": ["get_property", "filename"] }' | socat - /tmp/southpark)
		sleep 1
	done
}
function PAUSE(){
	echo '{ "command": ["set_property", "pause", true] }' | socat - /tmp/southpark &> /dev/null
}
function UNPAUSE(){
	echo '{ "command": ["set_property", "pause", false] }' | socat - /tmp/southpark &> /dev/null
}
function LOOP_ON(){
	echo '{ "command": ["set_property", "loop", true] }' | socat - /tmp/southpark &> /dev/null
}
function LOOP_OFF(){
	echo '{ "command": ["set_property", "loop", false] }' | socat - /tmp/southpark &> /dev/null
}
function PLAYLIST_NEXT(){
	echo '{ "command": ["playlist-next"] }' | socat - /tmp/southpark &> /dev/null
}
function PLAYLIST_CLEAR(){
	echo '{ "command": ["playlist-clear"] }' | socat - /tmp/southpark &> /dev/null
}
function ADD_PLAYLIST(){
	echo "{ \"command\": [\"loadfile\", \"$1\", \"append\"] }" | socat - /tmp/southpark &> /dev/null
	sleep 0.5
	echo "{ \"command\": [\"loadfile\", \"$HOME/.GameScript/10FPS_idle.mp4\", \"append\"] }" | socat - /tmp/southpark &> /dev/null
}
function WAIT_FOR_USER(){
	echo -n "LINE = "
	read line
}

#WORKING TEST CODE
#~ mpv --really-quiet --input-ipc-server=/tmp/southpark --playlist mpv_playlist.txt &
#~ sleep 2
#~ LOOP_ON #play idle
#~ while true; do
	#~ WAIT_FOR_USER
	
	#~ PLAYLIST_NEXT #play next video
	#~ echo "PLAY VIDEO"
	#~ LOOP_OFF
	
	#~ UNTIL_IDLE_IS_BACK
	#~ echo "BACK"
	
	#~ echo "PLAY IDLE"
	#~ LOOP_ON
#~ done

function start_lecture(){
restore=$1
case $1 in
1) echo -n 1 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; [ -d "$HOME/.GameScript_bash2" ] && echo "Unexpected error, ${HOME}/.GameScript_bash2 already exists on your system! Delete this $HOME/.GameScript_bash2 folder and restart this script." && exit; restore=$(expr $restore + 1) ;&
2) echo -n 2 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; mkdir $HOME/.GameScript_bash2 2> /dev/null; restore=$(expr $restore + 1) ;&
3) echo -n 3 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; cd $HOME/.GameScript_bash2; restore=$(expr $restore + 1) ;&
4) echo -n 4 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; touch $HOME/.GameScript_bash2/bOb; restore=$(expr $restore + 1) ;&
5) echo -n 5 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "In the last chapter, we saw the use of some commands and their arguments."; restore=$(expr $restore + 1) ;&
6) echo -n 6 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "The command ${learn}cd${reset}, for example, allows us to move in the directory of our choice."; restore=$(expr $restore + 1) ;&
7) echo -n 7 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "But we must give our choice in ${voc}argument${reset} of this command, for example ${learn}cd test${reset} to go in the 'test' folder."; restore=$(expr $restore + 1) ;&
8) echo -n 8 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "Or ${learn}mkdir test${reset} to create a directory that will be called 'test'."; restore=$(expr $restore + 1) ;&
9) echo -n 9 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "The syntax is: ${voc}<COMMAND> <ARGUMENT>${reset}."; restore=$(expr $restore + 1) ;&
10) echo -n 10 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "This ${voc}<ARGUMENT>${reset} can be a ${voc}relative path${reset}, like a folder in the ${voc}current directory${reset} with for example: ${learn}mkdir NewFolder${reset}"; restore=$(expr $restore + 1) ;&
11) echo -n 11 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "This ${voc}<ARGUMENT>${reset} can also be an ${voc}absolute path${reset}, like a file in the ${voc}root directory${reset} with for example: ${learn}rm /file${reset}"; restore=$(expr $restore + 1) ;&
12) echo -n 12 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "But do you remember the commands we have already seen?"; restore=$(expr $restore + 1) ;&
13) echo -n 13 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk_not_press_key justumen "Try to display items from your current directory."; restore=$(expr $restore + 1) ;&
14) echo -n 14 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; answer_run "ls" justumen "No"; restore=$(expr $restore + 1) ;&
15) echo -n 15 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk_not_press_key justumen "Now display the contents of your parent directory."; restore=$(expr $restore + 1) ;&
16) echo -n 16 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; answer_run "ls .." justumen "No"; restore=$(expr $restore + 1) ;&
17) echo -n 17 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "${code}..${reset} is the abbreviation of a directory, so it can also be written ${code}../${reset}"; restore=$(expr $restore + 1) ;&
18) echo -n 18 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk_not_press_key justumen "So test: ${learn}ls ../${reset}"; restore=$(expr $restore + 1) ;&
19) echo -n 19 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; answer_run "ls ../" justumen "No"; restore=$(expr $restore + 1) ;&
20) echo -n 20 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "The result of ${learn}ls ../${reset} is equivalent to the result of the previous command: ${learn}ls ..${reset}"; restore=$(expr $restore + 1) ;&
21) echo -n 21 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "${code}..${reset} being a directory, it can also have a parent, which can be targeted by ${code}../..${reset} or ${code}../ .. /${reset}."; restore=$(expr $restore + 1) ;&
22) echo -n 22 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "${code}../..${reset} therefore targets the grandparent of the current directory."; restore=$(expr $restore + 1) ;&
23) echo -n 23 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "${code}../../..${reset} targets its great grandparent, and so on."; restore=$(expr $restore + 1) ;&
24) echo -n 24 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "But there is another special name, which represents the current directory: this is the ${code}.${reset}."; restore=$(expr $restore + 1) ;&
25) echo -n 25 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "Since this is a folder, ${code}./${reset} is also a correct syntax."; restore=$(expr $restore + 1) ;&
26) echo -n 26 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "We have already seen that ${code}ls${reset} could have an argument, like ${learn}ls /${reset}."; restore=$(expr $restore + 1) ;&
27) echo -n 27 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk_not_press_key justumen "Give the current directory as an argument to ${code}ls${reset} with: ${learn}ls .${reset}"; restore=$(expr $restore + 1) ;&
28) echo -n 28 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; answer_run "ls ." justumen "No"; restore=$(expr $restore + 1) ;&
29) echo -n 29 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk_not_press_key justumen "And now make ${learn}ls ./${reset}"; restore=$(expr $restore + 1) ;&
30) echo -n 30 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; answer_run "ls ./" justumen "No"; restore=$(expr $restore + 1) ;&
31) echo -n 31 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "These two commands give the same result as a simple ${learn}ls${reset}."; restore=$(expr $restore + 1) ;&
32) echo -n 32 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "Without argument, the ${learn}ls${reset} command defaults to ${code}.${reset}."; restore=$(expr $restore + 1) ;&
33) echo -n 33 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk_not_press_key justumen "To delete this file 'bOb', you can for example type ${learn}rm ./bOb${reset}, go ahead."; restore=$(expr $restore + 1) ;&
34) echo -n 34 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; answer_run "rm ./bOb" justumen ""; restore=$(expr $restore + 1) ;&
35) echo -n 35 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "There is no error message, it means that the command worked well."; restore=$(expr $restore + 1) ;&
36) echo -n 36 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk_not_press_key justumen "Let's check the contents of the current directory."; restore=$(expr $restore + 1) ;&
37) echo -n 37 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; answer_run "ls" justumen "No"; restore=$(expr $restore + 1) ;&
38) echo -n 38 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk_not_press_key justumen "Perfect, it does not exist anymore. Now display the current directory path."; restore=$(expr $restore + 1) ;&
39) echo -n 39 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; answer_run "pwd" justumen "No"; restore=$(expr $restore + 1) ;&
40) echo -n 40 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "Be careful with this symbol ${code}.${reset}, here it has another meaning."; restore=$(expr $restore + 1) ;&
41) echo -n 41 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "This '.' in '.GameScript_bash2' does not refer to the current directory at all, that '.' is simply part of the file name."; restore=$(expr $restore + 1) ;&
42) echo -n 42 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "The full name of the folder is '.GameScript_bash2'."; restore=$(expr $restore + 1) ;&
43) echo -n 43 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk_not_press_key justumen "Now create a new 'child' folder in the current directory."; restore=$(expr $restore + 1) ;&
44) echo -n 44 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; answer_run "mkdir child" justumen "No"; restore=$(expr $restore + 1) ;&
45) echo -n 45 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk_not_press_key justumen "Move to this 'child' folder you just created."; restore=$(expr $restore + 1) ;&
46) echo -n 46 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; answer_run "cd child" justumen "No"; restore=$(expr $restore + 1) ;&
47) echo -n 47 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk_not_press_key justumen "Display the current directory path."; restore=$(expr $restore + 1) ;&
48) echo -n 48 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; answer_run "pwd" justumen "No"; restore=$(expr $restore + 1) ;&
49) echo -n 49 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk_not_press_key justumen "Now move to your grandparent directory using its relative path."; restore=$(expr $restore + 1) ;&
50) echo -n 50 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; answer_run "cd ../.." justumen "No"; restore=$(expr $restore + 1) ;&
51) echo -n 51 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk_not_press_key justumen "Redisplay the path of the current directory."; restore=$(expr $restore + 1) ;&
52) echo -n 52 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; answer_run "pwd" justumen "No"; restore=$(expr $restore + 1) ;&
53) echo -n 53 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "You are now in the directory where the '.GameScript_bash2' folder is located."; restore=$(expr $restore + 1) ;&
54) echo -n 54 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "But if you try to display the items in your current directory, you will not see it."; restore=$(expr $restore + 1) ;&
55) echo -n 55 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk_not_press_key justumen "Try to display it with: ${learn}ls${reset}."; restore=$(expr $restore + 1) ;&
56) echo -n 56 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; answer_run "ls" justumen "No"; restore=$(expr $restore + 1) ;&
57) echo -n 57 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "On a Unix-like operating system, such as Linux, if a file name or folder name begins with a ${code}.${reset}, this item will be ${voc}hidden${reset}."; restore=$(expr $restore + 1) ;&
58) echo -n 58 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "Here it is not in the ${learn}ls${reset} command result, though it does exist."; restore=$(expr $restore + 1) ;&
59) echo -n 59 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "So how can you show the hidden folder '.GameScript_bash2'?"; restore=$(expr $restore + 1) ;&
60) echo -n 60 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "Most commands have special arguments, which give more details to this command."; restore=$(expr $restore + 1) ;&
61) echo -n 61 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "These special arguments start with a ${code}-${reset} and are named ${voc}options${reset}."; restore=$(expr $restore + 1) ;&
62) echo -n 62 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk_not_press_key justumen "In order for ${learn}ls${reset} to also display${reset} ${voc}hidden elements, you will have to type ${learn}ls -a${reset}, go ahead."; restore=$(expr $restore + 1) ;&
63) echo -n 63 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; answer_run "ls -a" justumen "No"; restore=$(expr $restore + 1) ;&
64) echo -n 64 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "Here you should be able to see the ${code}.GameScript_bash2${reset} folder, but also many other hidden ${voc}items${reset}."; restore=$(expr $restore + 1) ;&
65) echo -n 65 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "Traditionally, these ${voc}${reset} options are placed before normal arguments."; restore=$(expr $restore + 1) ;&
66) echo -n 66 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "The syntax will be ${voc}<COMMAND> <OPTION> <ARGUMENT_NORMAL>${reset} as for example ${learn}ls -a /${reset}."; restore=$(expr $restore + 1) ;&
67) echo -n 67 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "Now how do we get back to this ${code}.GameScript_bash2${reset} folder ?"; restore=$(expr $restore + 1) ;&
68) echo -n 68 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "It is possible to return to this folder with a simple ${learn}cd .GameScript_bash2${reset}."; restore=$(expr $restore + 1) ;&
69) echo -n 69 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk_not_press_key justumen "But it is also possible to move in this directory with: ${learn}cd ./.GameScript_bash2${reset}, so try this command."; restore=$(expr $restore + 1) ;&
70) echo -n 70 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; answer_run "cd ./.GameScript_bash2" justumen "No"; restore=$(expr $restore + 1) ;&
71) echo -n 71 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "I hope the difference between these two ${code}.${reset} in this command is understandable to you."; restore=$(expr $restore + 1) ;&
72) echo -n 72 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "${code}.${reset} /. GameScript_bash2: This '.' represents the current directory."; restore=$(expr $restore + 1) ;&
73) echo -n 73 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "./${code}.${reset}GameScript_bash2: This '.' makes this file a hidden file."; restore=$(expr $restore + 1) ;&
74) echo -n 74 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk_not_press_key justumen "Redisplay items and ${voc}hidden${reset} items in your new current directory."; restore=$(expr $restore + 1) ;&
75) echo -n 75 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; answer_run "ls -a" justumen "No"; restore=$(expr $restore + 1) ;&
76) echo -n 76 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "You can see here the two special references we just saw: ${code}.${reset} and ${code}..${reset}"; restore=$(expr $restore + 1) ;&
77) echo -n 77 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "These two hidden folders, ${code}.${reset} and ${code}..${reset}, are present in all folders."; restore=$(expr $restore + 1) ;&
78) echo -n 78 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "Since we are talking about directories with special symbols, we can also talk about the ${code}~${reset}."; restore=$(expr $restore + 1) ;&
79) echo -n 79 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "The ${code}~${reset} represents the user's ${voc}home directory${reset}."; restore=$(expr $restore + 1) ;&
80) echo -n 80 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "Most often this directory is named after the user in the folder ${code}/ home /${reset}."; restore=$(expr $restore + 1) ;&
81) echo -n 81 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "In your case, ${code}~${reset} replaces this path: ${code}$HOME${reset}."; restore=$(expr $restore + 1) ;&
82) echo -n 82 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "You can obviously use this ${code}~${reset} as an argument with your commands."; restore=$(expr $restore + 1) ;&
83) echo -n 83 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk_not_press_key justumen "Go to this directory with ${learn}cd ~${reset}"; restore=$(expr $restore + 1) ;&
84) echo -n 84 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; answer_run "cd ~" justumen "No"; restore=$(expr $restore + 1) ;&
85) echo -n 85 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk_not_press_key justumen "Now check your new current directory."; restore=$(expr $restore + 1) ;&
86) echo -n 86 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; answer_run "pwd" justumen "No"; restore=$(expr $restore + 1) ;&
87) echo -n 87 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "${code}~${reset} replaces in your case this absolute path: ${code}$HOME${reset}"; restore=$(expr $restore + 1) ;&
88) echo -n 88 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "To target '.GameScript_bash2', you can use as a relative path ${code}.GameScript_bash2${reset} or ${code}./.GameScript_bash2${reset}"; restore=$(expr $restore + 1) ;&
89) echo -n 89 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "But, using ${code}~${reset}, you can also use a new absolute path: ${code}~/.GameScript_bash2${reset}"; restore=$(expr $restore + 1) ;&
90) echo -n 90 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk_not_press_key justumen "Delete the 'child' folder you created in '.GameScript_bash2' using its relative path."; restore=$(expr $restore + 1) ;&
91) echo -n 91 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; answer_run "rmdir .GameScript_bash2/child" justumen "No"; restore=$(expr $restore + 1) ;&
92) echo -n 92 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk_not_press_key justumen "Now go to the root directory."; restore=$(expr $restore + 1) ;&
93) echo -n 93 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; answer_run "cd /" justumen "No"; restore=$(expr $restore + 1) ;&
94) echo -n 94 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk_not_press_key justumen "Now delete the ${code}.GameScript_bash2${reset} folder using its absolute path and the symbol ${code}~${reset}!"; restore=$(expr $restore + 1) ;&
95) echo -n 95 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; answer_run "rmdir ~/.GameScript_bash2" justumen "No"; restore=$(expr $restore + 1) ;&
96) echo -n 96 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "Perfect !"; restore=$(expr $restore + 1) ;&
97) echo -n 97 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "Now let's go back to the commands and more precisely on their ${voc}options${reset}."; restore=$(expr $restore + 1) ;&
98) echo -n 98 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk_not_press_key justumen "List all items in the current directory with ${learn}ls -a${reset}."; restore=$(expr $restore + 1) ;&
99) echo -n 99 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; answer_run "ls -a" justumen "No"; restore=$(expr $restore + 1) ;&
100) echo -n 100 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "Some ${voc}options${reset} also have a long version, sometimes easier to remember, which starts with ${code}-${reset}."; restore=$(expr $restore + 1) ;&
101) echo -n 101 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "For example you can replace ${code}-a${reset} with ${code}--all${reset}."; restore=$(expr $restore + 1) ;&
102) echo -n 102 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk_not_press_key justumen "List all items of ${code}$HOME${reset} with ${learn}ls --all $HOME${reset}."; restore=$(expr $restore + 1) ;&
103) echo -n 103 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; answer_run "ls --all $HOME" justumen "No"; restore=$(expr $restore + 1) ;&
104) echo -n 104 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "The ${code}ls -a${reset} and ${code}ls --all${reset} commands are identical!"; restore=$(expr $restore + 1) ;&
105) echo -n 105 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "But how do we retain all options of all orders?"; restore=$(expr $restore + 1) ;&
106) echo -n 106 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "In fact you do not need to memorize them!"; restore=$(expr $restore + 1) ;&
107) echo -n 107 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "You can still access the ${voc}manual${reset} of a command with the command ${learn}man${reset}."; restore=$(expr $restore + 1) ;&
108) echo -n 108 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "To exit the manual, press 'q' on your keyboard, such as ${voc}q${reset}uit."; restore=$(expr $restore + 1) ;&
109) echo -n 109 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk_not_press_key justumen "Open the manual of the ls command with ${learn}man ls${reset}, quickly fly over its contents, and finally leave with the 'q' key."; restore=$(expr $restore + 1) ;&
110) echo -n 110 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; answer_run "man ls" justumen "No"; restore=$(expr $restore + 1) ;&
111) echo -n 111 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "If you forget some command options, you can still open its manual."; restore=$(expr $restore + 1) ;&
112) echo -n 112 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "If you ask a command-related question on a forum, you will probably get the answer: RTFM if the answer is in the manual."; restore=$(expr $restore + 1) ;&
113) echo -n 113 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "It is an acronym for 'Read The Fucking Manual'."; restore=$(expr $restore + 1) ;&
114) echo -n 114 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "Learning to read manuals is essential to be able to solve simple problems."; restore=$(expr $restore + 1) ;&
115) echo -n 115 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "With repetition you should remember the most important options, but you should always have the reflex to visit the manual before asking for help. The manual will always be there for you."; restore=$(expr $restore + 1) ;&
116) echo -n 116 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk_not_press_key justumen "Do it for ${code}rmdir${reset}, look quickly at the options available in the manual and quit with the 'q' key: ${learn}man rmdir${reset}"; restore=$(expr $restore + 1) ;&
117) echo -n 117 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; answer_run "man rmdir" justumen "No"; restore=$(expr $restore + 1) ;&
118) echo -n 118 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "Most commands have a ${code}--help${reset} option, which displays the help of the command. Sometimes it's just the content of the manual."; restore=$(expr $restore + 1) ;&
119) echo -n 119 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk_not_press_key justumen "Show rmdir help with ${learn}rmdir --help${reset}"; restore=$(expr $restore + 1) ;&
120) echo -n 120 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; answer_run "rmdir --help" justumen "No"; restore=$(expr $restore + 1) ;&
121) echo -n 121 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "Excellent, now let's see other options."; restore=$(expr $restore + 1) ;&
122) echo -n 122 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk_not_press_key justumen "First move to your root directory with the command ${learn}cd /${reset}"; restore=$(expr $restore + 1) ;&
123) echo -n 123 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; answer_run "cd /" justumen "No"; restore=$(expr $restore + 1) ;&
124) echo -n 124 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk_not_press_key justumen "Display the elements of the current directory."; restore=$(expr $restore + 1) ;&
125) echo -n 125 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; answer_run "ls" justumen "No"; restore=$(expr $restore + 1) ;&
126) echo -n 126 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "${learn}ls${reset} defaults to the full length of the terminal for display."; restore=$(expr $restore + 1) ;&
127) echo -n 127 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "But it is possible to limit its length with the option ${code}-w${reset}."; restore=$(expr $restore + 1) ;&
128) echo -n 128 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk_not_press_key justumen "Open the ${code}ls${reset} manual, read the details of the ${code}-w${reset} option, and exit the manual."; restore=$(expr $restore + 1) ;&
129) echo -n 129 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; answer_run "man ls" justumen "No"; restore=$(expr $restore + 1) ;&
130) echo -n 130 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "Some options, like here ${code}-w${reset}, must also have values."; restore=$(expr $restore + 1) ;&
131) echo -n 131 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "To use the ${code}-w${reset} option, you must give it a numeric value that matches the number of characters per line."; restore=$(expr $restore + 1) ;&
132) echo -n 132 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "If you limit this value to 1, for example, you can be sure that there will only be one file name per line."; restore=$(expr $restore + 1) ;&
133) echo -n 133 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk_not_press_key justumen "Try this command: ${learn}ls -w 1${reset}"; restore=$(expr $restore + 1) ;&
134) echo -n 134 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; answer_run "ls -w 1" justumen "No"; restore=$(expr $restore + 1) ;&
135) echo -n 135 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk_not_press_key justumen "Now try 100 as limit with: ${learn}ls -w 100${reset}"; restore=$(expr $restore + 1) ;&
136) echo -n 136 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; answer_run "ls -w 100" justumen "No"; restore=$(expr $restore + 1) ;&
137) echo -n 137 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "The long version of the options with value is sometimes different, with the use of the sign ${code}=${reset} instead of a space."; restore=$(expr $restore + 1) ;&
138) echo -n 138 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk_not_press_key justumen "Try using the long version with ${learn}ls --width=100${reset}"; restore=$(expr $restore + 1) ;&
139) echo -n 139 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; answer_run "ls --width=100" justumen "No"; restore=$(expr $restore + 1) ;&
140) echo -n 140 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "Again, there is no need to memorize all available options."; restore=$(expr $restore + 1) ;&
141) echo -n 141 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "You will have to learn how to use ${code}man${reset}."; restore=$(expr $restore + 1) ;&
142) echo -n 142 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; talk justumen "You are ready for the quiz! Go check your knowledge!"; restore=$(expr $restore + 1) ;&
143) echo -n 143 > $HOME/.GameScript/restore_bash2; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash2; clean; restore=$(expr $restore + 1) ;&
esac
}
function clean(){ #in enter_chapter
rm $HOME/.GameScript/restore_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
rm $HOME/.GameScript/restore_pwd_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
	rm $HOME/.GameScript_bash2/bOb 2> /dev/null
	rmdir $HOME/.GameScript_bash2/child 2> /dev/null
	rmdir $HOME/.GameScript_bash2 2> /dev/null
}

function start_quiz(){
  echo ""
  echo -e "\e[15;44m Bash 'Bourne Again SHell' : Quiz Chapter 2 \e[0m"
  echo -e "- The answer should be as short as possible, a good answer adding uneeded characters will be considered as wrong."
  echo -e "Example : If the answer is 'ls'. The answers 'ls .', 'ls ./' and 'ls ././' won't work."
  answer_text_fr "What's the symbol that represents the user's home directory ?" "~"
  answer_text_fr "Which symbol is at the beginning of a hidden file's name ?" "."
  answer_text_fr "Which symbol is at the beginning of a hidden folder's name ?" "."
  answer_text_fr "How do you move to the grandparent directory ?" "cd ../.."
  answer_text_fr "Which symbol represents the current directory ?" "."
  answer_text_fr "How do you display the manual of the rm command ?" "man rm"
  answer_text_fr "By which symbol do short commands options start ?" "-"
  answer_text_fr "By which symbol do long commands options start ?" "--"
  unlock "bash" "2" "246e" "1f13"
}

CHAPTER_NAME="bash"
CHAPTER_NUMBER="2"
LANGUAGE="en"
SPEAKER="m1"

LINES=142
if [ "$1" == "VIDEO" ]; then
	prepare_video
else
	if [ ! "$1" == "MUTE" ]; then
		prepare_audio
	fi
fi

enter_chapter $CHAPTER_NAME $CHAPTER_NUMBER
