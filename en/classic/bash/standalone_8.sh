#!/bin/bash
#SOME ADDED AND CHANGE IN CLI learn_cli.sh in CLASSIC
shopt -s expand_aliases
source ~/.bashrc
#Needed ?
#~ source ~/.GameScript/config

function pause_music(){
	#~ echo "PAUSE MUSIC"
	kill -SIGTSTP $1
}
function unpause_music(){
	#~ echo "UNPAUSE MUSIC"
	kill -SIGCONT $1	
	QUIZ_MUSIC_PID=$(ps -f|grep "mplayer"|grep Music|grep quiz|awk '{print $2}'|head -n 1)
	if [[ "QUIZ_$MUSIC_PID" != "" ]]; then
		kill $QUIZ_MUSIC_PID
	fi
}
function stop_quiz_music(){
	QUIZ_MUSIC_PID=$(ps -f|grep "mplayer"|grep Music|grep quiz|awk '{print $2}'|head -n 1)
	if [[ "$QUIZ_MUSIC_PID" != "" ]]; then
		kill $QUIZ_MUSIC_PID
	fi
}
function start_quiz_music(){
	if [[ "$MUTE" == "0" ]]; then
		MUSIC_PID=$(ps -f|grep "mplayer"|grep Music|awk '{print $2}'|head -n 1)
		if [[ "$MUSIC_PID" != "" ]]; then
			pause_music $MUSIC_PID
		fi
		mplayer -ss 4 /home/umen/.GameScript/Sounds/default/Music/quiz_1.m4a &>/dev/null &
		#-ss 4 for mortal kombat
	fi
	#??? change with $SOUNDPLAYER OR SMT
}

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
	if [[ "$MUTE" != 1 ]] && [[ "$VOICE" != "0" ]];then
		if [ ! -f "$AUDIO_LOCAL/4.mp3" ]; then
			wget -q --spider http://google.com
			if [ $? -eq 0 ]; then
				download_all_sounds
			else
				echo "Cannot download audio, no internet ?"
			fi
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
	VOICE_PID=$(ps -f|grep "$SOUNDPLAYER"|grep -v grep|grep -v MUSIC|awk '{print $2}'|head -n 1)
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
	VIDEO_PID=$(ps -ef|grep "mpv --really-quiet --input-ipc-server=/tmp/southpark"|grep -v grep|awk '{print $2}'|head -n 1)
	if [[ "$VIDEO_PID" == "" ]]; then
		rm /tmp/southpark
		mpv --really-quiet --input-ipc-server=/tmp/southpark --no-config --include=~/.GameScript/mpv_config --loop=no $VIDEO_LOCAL/$restore.mp3.mp4 &
		sleep 2
		VIDEO_PID=$(ps -ef|grep "mpv --really-quiet --input-ipc-server=/tmp/southpark"|grep -v grep|awk '{print $2}'|head -n 1)
		while [[ "$VIDEO_PID" == "" ]]; do
			VIDEO_PID=$(ps -ef|grep "mpv --really-quiet --input-ipc-server=/tmp/southpark"|grep -v grep|awk '{print $2}'|head -n 1)
			sleep 1
		done
		echo "{ \"command\": [\"loadfile\", \"$HOME/.GameScript/10FPS_idle.mp4\", \"append\"] }" | socat - /tmp/southpark &> /dev/null
		echo "{ \"command\": [\"loadfile\", \"$HOME/.GameScript/10FPS_idle.mp4\", \"append\"] }" | socat - /tmp/southpark &> /dev/null
		echo "{ \"command\": [\"loadfile\", \"$HOME/.GameScript/10FPS_idle.mp4\", \"append\"] }" | socat - /tmp/southpark &> /dev/null
		echo "{ \"command\": [\"loadfile\", \"$HOME/.GameScript/10FPS_idle.mp4\", \"append\"] }" | socat - /tmp/southpark &> /dev/null
		echo "{ \"command\": [\"loadfile\", \"$HOME/.GameScript/10FPS_idle.mp4\", \"append\"] }" | socat - /tmp/southpark &> /dev/null
	else
		echo "{ \"command\": [\"loadfile\", \"$VIDEO_LOCAL/$restore.mp3.mp4\", \"replace\"] }" | socat - /tmp/southpark &> /dev/null
		echo "{ \"command\": [\"loadfile\", \"$HOME/.GameScript/10FPS_idle.mp4\", \"append\"] }" | socat - /tmp/southpark &> /dev/null
		echo "{ \"command\": [\"loadfile\", \"$HOME/.GameScript/10FPS_idle.mp4\", \"append\"] }" | socat - /tmp/southpark &> /dev/null
		echo "{ \"command\": [\"loadfile\", \"$HOME/.GameScript/10FPS_idle.mp4\", \"append\"] }" | socat - /tmp/southpark &> /dev/null
		echo "{ \"command\": [\"loadfile\", \"$HOME/.GameScript/10FPS_idle.mp4\", \"append\"] }" | socat - /tmp/southpark &> /dev/null
	fi
}
function new_videoOLD(){
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
							e) exit ;;
						esac
					done
				fi
				start_lecture 1
				start_quiz
				;;
			2) 	start_quiz ;;
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
1) echo -n 1 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; [ -d "$HOME/.GameScript_bash8" ] && echo "Unexpected error, ${HOME}/.GameScript_bash8 already exists on your system! Delete this $HOME/.GameScript_bash8 folder and restart this script." && exit; restore=$(expr $restore + 1) ;&
2) echo -n 2 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; mkdir $HOME/.GameScript_bash8 2> /dev/null; restore=$(expr $restore + 1) ;&
3) echo -n 3 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; cd $HOME/.GameScript_bash8; restore=$(expr $restore + 1) ;&
4) echo -n 4 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; echo -e "Joseph\\nemail:joseph@bjornulf.org\\nCarla\\nemail:carla@bjornulf.org\\nCharlie\\nemail:charlie@bjornulf.org\\nAkemail\\nemail:akemail@bjornulf.org\\nBob\\nemail:bob@bjornulf.org\\nAlbert\\nemail:albert@bjornulf.org\\nJessica\\nemail:jessica@bjornulf.org\\nCarla\\nemail:carla@bjornulf.org" > $HOME/.GameScript_bash8/LIST; restore=$(expr $restore + 1) ;&
5) echo -n 5 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Let's start by creating our environment for this chapter."; restore=$(expr $restore + 1) ;&
6) echo -n 6 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk_not_press_key justumen "Create the file 'test' with: ${learn}echo goodbye> test${reset}"; restore=$(expr $restore + 1) ;&
7) echo -n 7 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; answer_run "echo goodbye> test" justumen "No"; restore=$(expr $restore + 1) ;&
8) echo -n 8 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "We will now use the ${code}wc${reset} command to get additional information about the contents of this file."; restore=$(expr $restore + 1) ;&
9) echo -n 9 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk_not_press_key justumen "So make ${learn}wc test${reset}"; restore=$(expr $restore + 1) ;&
10) echo -n 10 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; answer_run "wc test" justumen "No"; restore=$(expr $restore + 1) ;&
11) echo -n 11 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Here we have three numbers, the first represents the number of ${voc}lines${reset} of the file: ${code}1${reset} 2 10 test"; restore=$(expr $restore + 1) ;&
12) echo -n 12 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "The second is the number of ${voc}words${reset} in the file: 1 ${code}2${reset} 10 test"; restore=$(expr $restore + 1) ;&
13) echo -n 13 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "The third represents the number of ${voc}characters${reset} in the file: 1 2 ${code}10${reset} test"; restore=$(expr $restore + 1) ;&
14) echo -n 14 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk_not_press_key justumen "Display the contents of this 'test' file."; restore=$(expr $restore + 1) ;&
15) echo -n 15 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; answer_run "cat test" justumen "No"; restore=$(expr $restore + 1) ;&
16) echo -n 16 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "We have in this file ${code}1${reset} line and ${code}2${reset} words: 'au' and 'review'."; restore=$(expr $restore + 1) ;&
17) echo -n 17 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "${code}wc${reset} also informs us that this file is composed of 10 characters."; restore=$(expr $restore + 1) ;&
18) echo -n 18 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "The first word 'au' is composed of two characters, 'a' and 'u'."; restore=$(expr $restore + 1) ;&
19) echo -n 19 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "The second word 'review' is composed of six characters, which adds to the two previous ones, makes eight."; restore=$(expr $restore + 1) ;&
20) echo -n 20 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "The space separating the two words is also a character, which brings us to nine."; restore=$(expr $restore + 1) ;&
21) echo -n 21 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "The tenth character is actually the line that we saw in chapter 3: that we can represent with '\' + 'n'."; restore=$(expr $restore + 1) ;&
22) echo -n 22 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "I remind you that the command ${code}echo${reset} automatically adds a new line at the end, unless the -n option is present."; restore=$(expr $restore + 1) ;&
23) echo -n 23 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Let's see what we've done so far: ${code}echo goodbye> test${reset} to create the file 'test' and ${code}wc test${reset} to parse this file."; restore=$(expr $restore + 1) ;&
24) echo -n 24 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "The command ${voc}wc${reset} takes as argument the file you want to parse."; restore=$(expr $restore + 1) ;&
25) echo -n 25 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "But you do not have to create this 'test' file if you do not need it."; restore=$(expr $restore + 1) ;&
26) echo -n 26 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "In the previous chapters, we saw that we could redirect the ${voc}standard output${reset} to a file with ${code}>${reset} or ${code}1>${reset}."; restore=$(expr $restore + 1) ;&
27) echo -n 27 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "But it is also possible to redirect the standard output not to a file but to ${voc}another${reset} command with the symbol ${code}|${reset}, also called 'pipe' or pipe ."; restore=$(expr $restore + 1) ;&
28) echo -n 28 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "${voc}wc${reset} is, like so many commands, also able to read ${voc}standard output${reset}."; restore=$(expr $restore + 1) ;&
29) echo -n 29 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk_not_press_key justumen "Do: ${learn}echo goodbye | wc${reset}"; restore=$(expr $restore + 1) ;&
30) echo -n 30 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; answer_run "echo goodbye | wc" justumen "No"; restore=$(expr $restore + 1) ;&
31) echo -n 31 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Here with ${code}|${reset}, the result is the same, except that the filename is not displayed because there is no file."; restore=$(expr $restore + 1) ;&
32) echo -n 32 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "The 'pipe' is one of the most powerful concepts of the command line."; restore=$(expr $restore + 1) ;&
33) echo -n 33 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "With ${code}|${reset}, a command can send its standard output to a second command, which can then send its own standard output to a third command, and so on."; restore=$(expr $restore + 1) ;&
34) echo -n 34 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk_not_press_key justumen "I just prepared a file 'LIST' for you, so display the contents of this file."; restore=$(expr $restore + 1) ;&
35) echo -n 35 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; answer_run "cat LIST" justumen "No"; restore=$(expr $restore + 1) ;&
36) echo -n 36 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Here you have a list of names and emails, but imagine that only emails interest you."; restore=$(expr $restore + 1) ;&
37) echo -n 37 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "To detect the presence of a keyword in a line, you will have to use the command ${code}grep${reset}."; restore=$(expr $restore + 1) ;&
38) echo -n 38 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Of course, ${code}grep${reset} is able to read on a ${voc}standard output${reset}, so you can use it in combination with ${code}|${reset}."; restore=$(expr $restore + 1) ;&
39) echo -n 39 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk_not_press_key justumen "Show only the lines of the file that contain the word 'email' with: ${learn}cat LIST | grep email${reset}"; restore=$(expr $restore + 1) ;&
40) echo -n 40 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; answer_run "cat LIST | grep email" justumen "No"; restore=$(expr $restore + 1) ;&
41) echo -n 41 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Here the choice of the keyword 'email' is personal, and you must be careful that this choice is wise."; restore=$(expr $restore + 1) ;&
42) echo -n 42 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "${code}grep email${reset} will be problematic if one of the names is 'email', or contains the word 'email', like 'Ak ${voc}email${reset}'."; restore=$(expr $restore + 1) ;&
43) echo -n 43 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk_not_press_key justumen "To detect emails in a more reliable way, you can use the presence of '@', so do: ${learn}cat LIST | grep @${reset}"; restore=$(expr $restore + 1) ;&
44) echo -n 44 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; answer_run "cat LIST | grep @" justumen "No"; restore=$(expr $restore + 1) ;&
45) echo -n 45 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "So you have here in your standard output only email addresses."; restore=$(expr $restore + 1) ;&
46) echo -n 46 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk_not_press_key justumen "Now use your last standard output to create the 'EMAILS' file which will contain all the emails of the LIST file by doing: ${learn}cat LIST | grep @> EMAILS${reset}"; restore=$(expr $restore + 1) ;&
47) echo -n 47 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; answer_run "cat LIST | grep @> EMAILS" justumen "No"; restore=$(expr $restore + 1) ;&
48) echo -n 48 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "${code}grep @${reset} will show all lines that contain at least one '@'."; restore=$(expr $restore + 1) ;&
49) echo -n 49 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "To do the opposite, you must add ${code}grep @${reset} the -v option."; restore=$(expr $restore + 1) ;&
50) echo -n 50 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk_not_press_key justumen "Display all lines that do not contain ${voc}not${reset} '@' with: ${learn}cat LIST | grep -v @${reset}"; restore=$(expr $restore + 1) ;&
51) echo -n 51 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; answer_run "cat LIST | grep -v @" justumen "No"; restore=$(expr $restore + 1) ;&
52) echo -n 52 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Before saving this list to a file, we want to alphabetically sort these names with the command ${learn}sort${reset}."; restore=$(expr $restore + 1) ;&
53) echo -n 53 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk_not_press_key justumen "For that, just continue using the standard output and the ${code}|${reset}, do: ${learn}cat LIST | grep -v @ | sort${reset}"; restore=$(expr $restore + 1) ;&
54) echo -n 54 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; answer_run "cat LIST | grep -v @ | output" justumen "No"; restore=$(expr $restore + 1) ;&
55) echo -n 55 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Here the name 'Carla' appears clearly twice."; restore=$(expr $restore + 1) ;&
56) echo -n 56 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "To eliminate the following identical names, you must use the command ${learn}uniq${reset}."; restore=$(expr $restore + 1) ;&
57) echo -n 57 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk_not_press_key justumen "Let's continue to chain the pipes, do so: ${learn}cat LIST | grep -v @ | sort | uniq${reset}"; restore=$(expr $restore + 1) ;&
58) echo -n 58 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; answer_run "cat LIST | grep -v @ | sort | only No" justumen ""; restore=$(expr $restore + 1) ;&
59) echo -n 59 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Here our result is perfect, so you could redirect the last standard output to create a 'NAMES' file."; restore=$(expr $restore + 1) ;&
60) echo -n 60 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "On bash, he always has more than one way to do the same thing."; restore=$(expr $restore + 1) ;&
61) echo -n 61 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "We used the following code: ${code}cat LIST | grep -v @ | sort | uniq${reset}"; restore=$(expr $restore + 1) ;&
62) echo -n 62 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Here ${code}grep${reset} will use the standard output of the previous command, but like ${code}wc${reset}, ${code}grep${reset} also accepts a file."; restore=$(expr $restore + 1) ;&
63) echo -n 63 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "So you could just as well not use the command ${code}cat${reset}, doing directly: ${code}grep -v @ LIST | sort | only${reset}"; restore=$(expr $restore + 1) ;&
64) echo -n 64 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "The command ${code}only${reset} can also be removed, because ${code}sort${reset} also has an option that can remove duplicates: -u."; restore=$(expr $restore + 1) ;&
65) echo -n 65 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk_not_press_key justumen "Try this new command: ${learn}grep -v @ STL | sort -u${reset}"; restore=$(expr $restore + 1) ;&
66) echo -n 66 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; answer_run "grep -v @ LIST | sort -u" justumen "No"; restore=$(expr $restore + 1) ;&
67) echo -n 67 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "${learn}grep -v @ LIST | sort -u${reset} gives the same result as ${learn}cat LIST | grep -v @ | sort | only${reset}."; restore=$(expr $restore + 1) ;&
68) echo -n 68 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "The important thing is not so much your writing style, but a good understanding of all the features offered to you by bash."; restore=$(expr $restore + 1) ;&
69) echo -n 69 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "For now with GameScript, I impose a minimal style of writing, but over time you will probably develop a different style, which will not be less valid than the one I share here with you."; restore=$(expr $restore + 1) ;&
70) echo -n 70 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Whether it's about using spaces for presentation, or the logic behind your code."; restore=$(expr $restore + 1) ;&
71) echo -n 71 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Now I will give you some clarifications on the previous orders."; restore=$(expr $restore + 1) ;&
72) echo -n 72 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "To display only the number of rows, you could have used ${code}wc${reset} with the -l option."; restore=$(expr $restore + 1) ;&
73) echo -n 73 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk_not_press_key justumen "Try: ${learn}echo goodbye | wc -l${reset}"; restore=$(expr $restore + 1) ;&
74) echo -n 74 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; answer_run "echo goodbye | wc -l" justumen "No"; restore=$(expr $restore + 1) ;&
75) echo -n 75 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "To be precise, ${code}wc${reset} does not actually count the number of lines, but rather the number of newlines."; restore=$(expr $restore + 1) ;&
76) echo -n 76 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk_not_press_key justumen "Try doing: ${learn}echo -n goodbye | wc -l${reset}"; restore=$(expr $restore + 1) ;&
77) echo -n 77 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; answer_run "echo -n goodbye | wc -l" justumen "No"; restore=$(expr $restore + 1) ;&
78) echo -n 78 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Here the result is obviously not 0 line, but 0 new line ('\' + 'n'), since we do not have the new line with the -n option."; restore=$(expr $restore + 1) ;&
79) echo -n 79 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "In a Unix-like system, it's a ${voc}convention${reset} to have a line break at the end of a text file."; restore=$(expr $restore + 1) ;&
80) echo -n 80 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "We saw that ${code}|${reset} was used to redirect the standard output to another command."; restore=$(expr $restore + 1) ;&
81) echo -n 81 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "But it is also possible to redirect the standard error output at the same time, using ${code}| &${reset}."; restore=$(expr $restore + 1) ;&
82) echo -n 82 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk_not_press_key justumen "For example: ${learn}cat X | & grep cat${reset}"; restore=$(expr $restore + 1) ;&
83) echo -n 83 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; answer_run "cat X | & grep cat" justumen "No"; restore=$(expr $restore + 1) ;&
84) echo -n 84 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk_not_press_key justumen "And the opposite: ${learn}cat X | & grep -v cat${reset}"; restore=$(expr $restore + 1) ;&
85) echo -n 85 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; answer_run "cat X | & grep -v cat" justumen "No"; restore=$(expr $restore + 1) ;&
86) echo -n 86 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "${code}| &${reset} is actually equivalent to ${code}2> & 1 |${reset}."; restore=$(expr $restore + 1) ;&
87) echo -n 87 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "This makes ${code}(pwdd; pwd) 2> & 1 | wc -l${reset} equivalent to ${code}(pwdd; pwd) | & wc -l${reset}."; restore=$(expr $restore + 1) ;&
88) echo -n 88 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Of course, be careful not to confuse ${code}|${reset} and ${code}| &${reset} with ${code}||${reset}!"; restore=$(expr $restore + 1) ;&
89) echo -n 89 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "In chapter 7 we saw how to use standard output (stdout) and standard error output (stderr)."; restore=$(expr $restore + 1) ;&
90) echo -n 90 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8;  std_1; restore=$(expr $restore + 1) ;&
91) echo -n 91 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "But some commands can also receive information about their ${voc}standard input${reset} (stdin for standard input)."; restore=$(expr $restore + 1) ;&
92) echo -n 92 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Very often, commands that can use their ${voc}standard input${reset} if no other means are specified."; restore=$(expr $restore + 1) ;&
93) echo -n 93 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "If you visit the ${code}grep${reset} or ${code}cat${reset} manual, you'll see that's their case."; restore=$(expr $restore + 1) ;&
94) echo -n 94 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "This ${voc}standard entry${reset} will be your keyboard by default!"; restore=$(expr $restore + 1) ;&
95) echo -n 95 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "To end this transmission, it will send the signal EOT by doing simultaneously on your keyboard ${voc}ctrl + d${reset}."; restore=$(expr $restore + 1) ;&
96) echo -n 96 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "For example, you can use ${code}cat${reset} as a text editor if you do not give it an argument."; restore=$(expr $restore + 1) ;&
97) echo -n 97 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk_not_press_key justumen "Then make ${learn}cat> new${reset}, type a few lines, then when you are on a new empty ${voc}line${reset}, make ${voc}ctrl + d${reset} with your keyboard."; restore=$(expr $restore + 1) ;&
98) echo -n 98 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; answer_run "Cat> No new " justumen ""; restore=$(expr $restore + 1) ;&
99) echo -n 99 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk_not_press_key justumen "Display the new file now."; restore=$(expr $restore + 1) ;&
100) echo -n 100 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; answer_run "cat new" justumen "No"; restore=$(expr $restore + 1) ;&
101) echo -n 101 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "I repeat this ${voc}standard input${reset} will default your keyboard."; restore=$(expr $restore + 1) ;&
102) echo -n 102 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8;  std_2; restore=$(expr $restore + 1) ;&
103) echo -n 103 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "But you can also change it easily with the ${code}<${reset} symbol."; restore=$(expr $restore + 1) ;&
104) echo -n 104 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk_not_press_key justumen "So, do ${learn}wc <new${reset}"; restore=$(expr $restore + 1) ;&
105) echo -n 105 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; answer_run "Toilet <new" justumen "No"; restore=$(expr $restore + 1) ;&
106) echo -n 106 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk_not_press_key justumen "Do also: ${learn}wc new${reset}"; restore=$(expr $restore + 1) ;&
107) echo -n 107 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; answer_run "wc new" justumen "No"; restore=$(expr $restore + 1) ;&
108) echo -n 108 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "${code}wc${reset} is both able to read standard input or a given file as argument."; restore=$(expr $restore + 1) ;&
109) echo -n 109 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "The only difference between these two commands is the absence of the file name with the use of ${code}<${reset}, normal since there is no 'file' for reading."; restore=$(expr $restore + 1) ;&
110) echo -n 110 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "The content is read directly from the ${code}wc${reset} standard entry."; restore=$(expr $restore + 1) ;&
111) echo -n 111 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Some commands need you to specify that you want to use standard input."; restore=$(expr $restore + 1) ;&
112) echo -n 112 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "For that it will be necessary to use a ${code}-${reset} in argument."; restore=$(expr $restore + 1) ;&
113) echo -n 113 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "But all other commands that can use standard input, also accept this ${code}-${reset} as an argument, even if it is not necessary."; restore=$(expr $restore + 1) ;&
114) echo -n 114 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "The previous command ${code}cat> new${reset} is equivalent to ${code}cat -> new${reset}."; restore=$(expr $restore + 1) ;&
115) echo -n 115 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk_not_press_key justumen "So, do ${learn}wc - <new${reset}"; restore=$(expr $restore + 1) ;&
116) echo -n 116 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; answer_run "wc - <new" justumen "No"; restore=$(expr $restore + 1) ;&
117) echo -n 117 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Here the file name becomes - but the result of ${code}wc${reset} remains the same."; restore=$(expr $restore + 1) ;&
118) echo -n 118 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "${code}wc - <new${reset}, ${code}wc <new${reset} and ${code}wc new${reset} give the same result but the logic to arrive at this result is different."; restore=$(expr $restore + 1) ;&
119) echo -n 119 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "As for the display of these commands, it is simply a standard output, so you can obviously redirect it normally."; restore=$(expr $restore + 1) ;&
120) echo -n 120 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk_not_press_key justumen "So, do ${learn}wc - <new> wcnew${reset}"; restore=$(expr $restore + 1) ;&
121) echo -n 121 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; answer_run "wc - <new> wcnew" justumen "No"; restore=$(expr $restore + 1) ;&
122) echo -n 122 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk_not_press_key justumen "View the content of 'wcnew'."; restore=$(expr $restore + 1) ;&
123) echo -n 123 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; answer_run "cat wcnew" justumen "No"; restore=$(expr $restore + 1) ;&
124) echo -n 124 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "The command ${code}grep${reset} takes two arguments with this syntax: grep <MOTCLEF> <FILE>."; restore=$(expr $restore + 1) ;&
125) echo -n 125 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "${code}grep${reset}, used without a second argument, will use, like ${code}wc${reset}, its standard input."; restore=$(expr $restore + 1) ;&
126) echo -n 126 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "But we have already used ${code}grep${reset} without a second argument with ${code}grep @${reset} in our previous command: ${learn}cat LIST | grep @${reset}."; restore=$(expr $restore + 1) ;&
127) echo -n 127 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "The standard input is actually exactly what ${code}|${reset} uses."; restore=$(expr $restore + 1) ;&
128) echo -n 128 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8;  std_3; restore=$(expr $restore + 1) ;&
129) echo -n 129 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Here you have a visual representation of the command: ${learn}cat LIST | grep @${reset}"; restore=$(expr $restore + 1) ;&
130) echo -n 130 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "${code}|${reset} allows you to redirect the standard output of one command, or command group, to the standard input of another command."; restore=$(expr $restore + 1) ;&
131) echo -n 131 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8;  std_4; restore=$(expr $restore + 1) ;&
132) echo -n 132 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "${code}| &${reset} allows to use stdout ${voc}and${reset} stderr, like here in ${learn}cat X | & grep cat${reset}."; restore=$(expr $restore + 1) ;&
133) echo -n 133 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Again, for some commands it will be necessary explicitly to request the use of the standard input with the symbol ${code}-${reset}."; restore=$(expr $restore + 1) ;&
134) echo -n 134 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "${learn}cat LIST grep @${reset} is actually equivalent to ${learn}cat LIST | grep @ -${reset}."; restore=$(expr $restore + 1) ;&
135) echo -n 135 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "So you now know how to manipulate the standard input (stdin) and the two outputs of your commands (stdout and stderr)."; restore=$(expr $restore + 1) ;&
136) echo -n 136 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "You should be ready for the questionnaire!"; restore=$(expr $restore + 1) ;&
137) echo -n 137 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; clean; restore=$(expr $restore + 1) ;&
esac
}
CLREOL=$'\x1B[K'

function std_1(){
echo -e "$basic${CLREOL}
            %%%%%%%%%%%%%%%%%${CLREOL}
            %               %${CLREOL}
==========> %    COMMAND    %========>${CLREOL}
      stdin %               % stdout ( 1> / > )${CLREOL}
            %%%%%%%%%%%%%%%%%${CLREOL}
                  |${CLREOL}
                  |================>${CLREOL}
                   stderr ( 2> )${CLREOL}$reset"
}


function std_2(){
echo -e "$basic
            %%%%%%%%%%%%%%%%%${CLREOL}
            %               %${CLREOL}
==========> %    COMMAND    %========>${CLREOL}
stdin ( ${code}<${reset}${basic} ) %               % stdout ( 1> / > )${CLREOL}
            %%%%%%%%%%%%%%%%%${CLREOL}
                  |${CLREOL}
                  |================>${CLREOL}
                   stderr ( 2> )${CLREOL}$reset"
}



function std_3(){
echo -e "$basic
%%%%%%%%%%%%%%%%%           %%%%%%%%%%%%%%%%%${CLREOL}
%               %     stdin %               %${CLREOL}
%   cat LIST    %===(${code}|${reset}${basic})===> %     grep @    %========> ...${CLREOL}
%               % stdout    %               % stdout${CLREOL}
%%%%%%%%%%%%%%%%%           %%%%%%%%%%%%%%%%%${CLREOL}
        |                           |${CLREOL}
        |=================>         |================>${CLREOL}
         stderr                      stderr${CLREOL}$reset"
}


function std_4(){
echo -e "$basic
%%%%%%%%%%%%%%%%%${CLREOL}
%               % stdout${CLREOL}
%     cat X     %=====|           %%%%%%%%%%%%%%%%%${CLREOL}
%               %     |     stdin %               %${CLREOL}
%%%%%%%%%%%%%%%%%     |===(${code}|&${reset}${basic})==> %    grep cat   %========> ...${CLREOL}
        |             |           %               % stdout${CLREOL}
        |=============|           %%%%%%%%%%%%%%%%%${CLREOL}
         stderr                           |${CLREOL}
                                          |================>${CLREOL}
	                                       stderr${CLREOL}$reset"
}

#~ function stdout_stderr_2in1_1in2(){
#~ echo -e "$basic
#~ %%%%%%%%%%%%%%%%%${CLREOL}
#~ %               % stdout + stdout${CLREOL}
#~ %  (pwdd;pwd)   %========> $HOME/.GameScript_bash7${CLREOL}
#~ %               %   |      bash: pwdd: command not found${CLREOL}
#~ %%%%%%%%%%%%%%%%%   |${CLREOL}
        #~ |           | ( 2>&1 )${CLREOL}
        #~ |===========|${CLREOL}
         #~ stderr${CLREOL}
 #~ ${CLREOL}
#~ %%%%%%%%%%%%%%%%%${CLREOL}
#~ %               %${CLREOL}
#~ %  (pwdd;pwd)   %===|${CLREOL}
#~ %               %   | ( 1>&2 )${CLREOL}
#~ %%%%%%%%%%%%%%%%%   |${CLREOL}
        #~ |           |      $HOME/.GameScript_bash7${CLREOL}
        #~ |================> bash: pwdd: command not found${CLREOL}
         #~ stderr + stdout${CLREOL}$reset"
#~ }
function clean(){ #in enter_chapter
rm $HOME/.GameScript/restore_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
rm $HOME/.GameScript/restore_pwd_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
	rm $HOME/.GameScript_bash8/LIST 2> /dev/null
	rm $HOME/.GameScript_bash8/test 2> /dev/null
	rm $HOME/.GameScript_bash8/EMAILS 2> /dev/null
	rm $HOME/.GameScript_bash8/new 2> /dev/null
	rm $HOME/.GameScript_bash8/wcnew 2> /dev/null
	rmdir $HOME/.GameScript_bash8 2> /dev/null
}

function start_quiz(){
  echo ""
  echo -e "\e[15;44m Bash 'Bourne Again SHell' : Quiz Chapter 8 \e[0m"
  echo -e "- The answer should be as short as possible, a good answer adding uneeded characters will be considered as wrong."
  echo -e "Example : If the answer is 'ls'. The answers 'ls .', 'ls ./' and 'ls ././' won't work."
  answer_text_fr "Comment afficher les lignes du fichier 'message' qui contiennent au moins une lettre 'a' ?" "grep a message"
  answer_text_fr "En utilisant l'entrée standard, comment afficher toutes les lignes du fichier 'grep' qui contiennent le mot 'cat' ?" "cat grep|grep cat"
  answer_text_fr "En utilisant 'cat', comment envoyer à la sortie standard le contenu classé par ordre aphabétique du fichier 'noms' ?" "cat noms|sort"
  answer_text_fr "Sans utiliser 'cat' et des options de commande, comment afficher le contenu du fichier 'list' sans ses lignes en double ?" "sort list|uniq"
  answer_text_fr "Sans utiliser d'argument de commande, comment envoyer le contenu du fichier 'wc1' à la commande 'wc', puis écrire le résultat dans 'wc2' ?" "wc<wc1>wc2"
  answer_text_fr "Comment rediriger la sortie standard et la sortie erreur standard de la commande 'cat x' vers la commande 'grep cat' ?" "cat x|&grep cat"
  answer_text_fr "Quel est le symbole qui peut préciser l'utilisation de l'entrée standard dans une commande ?" "-"
  unlock "bash" "8" "88ab" "44d5"
}


CHAPTER_NAME="bash"
CHAPTER_NUMBER="8"
LANGUAGE="fr"
SPEAKER="m1"

LINES=136
if [ "$1" == "VIDEO" ]; then
	prepare_video
else
	if [ ! "$1" == "MUTE" ]; then
		prepare_audio
	fi
fi

enter_chapter $CHAPTER_NAME $CHAPTER_NUMBER
