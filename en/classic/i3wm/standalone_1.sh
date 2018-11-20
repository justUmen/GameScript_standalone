#!/bin/bash
#SOME ADDED AND CHANGE IN CLI learn_cli.sh in CLASSIC
shopt -s expand_aliases
source ~/.bashrc

function pause_music(){
	kill -SIGTSTP $1
}
function start_quiz_music(){
	if [[ "$MUTE" == "0" ]]; then
		MUSIC_PID=$(ps -ef|grep "$SOUNDPLAYER_MUSIC"|grep Music|grep -v quiz|awk '{print $2}'|head -n 1)
		if [[ "$MUSIC_PID" != "" ]]; then
			pause_music $MUSIC_PID
		fi
		$SOUNDPLAYER_MUSIC_QUIZ /home/umen/.GameScript/Sounds/default/Music/quiz_1.mp3 &>/dev/null &
	fi
}
function stop_quiz_music(){
	if [[ "$MUTE" == "0" ]]; then
		MUSIC_QUIZ_PID=$(ps -ef|grep "$SOUNDPLAYER_MUSIC_QUIZ"|grep quiz|awk '{print $2}'|head -n 1)
		if [[ "$MUSIC_QUIZ_PID" != "" ]]; then
			kill $MUSIC_QUIZ_PID
		fi
	fi
}
function download_all_sounds(){
	cd $AUDIO_LOCAL || exit
	i=4
	rm to_dl.wget 2> /dev/null
	echo "Downloading Audio..."
	while [ $i -le $LINES ]; do
		echo "$AUDIO_DL/$i.mp3" >> to_dl.wget
		i=`expr $i + 1`
	done
	cat to_dl.wget | xargs -n 1 -P 4 wget -q &
}
function download_all_videos(){
	cd $VIDEO_LOCAL || exit
	i=4
	rm to_dl.wget 2> /dev/null
	echo "Downloading Videos..."
	while [ $i -le $LINES ]; do
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
	if [ "$key" == 'e' ]; then
		exit
	fi
}

#TODO ???
function new_sound(){
	VOICE_PID=$(ps -f|grep "$SOUNDPLAYER"|grep -v grep|grep -v MUSIC|awk '{print $2}'|head -n 1)
	if [[ "$VOICE_PID" != "" ]]; then
		kill $VOICE_PID
	fi
	$SOUNDPLAYER "$AUDIO_LOCAL/$restore.mp3" &> /dev/null &
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
function how_to_leave_chapter(){
	echo ""
	case $LANGUAGE in
		fr) echo "Pour fermer ce chapitre, appuyez sur la touche 'e' quand vous voyez ces ... " ;;
		en) echo "To close this chapter, press the key 'e' when you see these '...'" ;;
	esac
	echo ""
}

function answer_quiz(){
	#$7 = bash, from enter_chapter
	# echo " ---> $7 <--- "
	echo -e "      \\e[0;100m 1) \\e[0m $1"
	echo -e "      \\e[0;100m 2) \\e[0m $2"
	echo -e "      \\e[0;100m e) \\e[0m $3"
	key="9"
	while [ "$key" != "1" ] && [ "$key" != "2" ] && [ "$key" != "e" ]; do
		echo -en "      \\e[97;45m # \\e[0m"	
		read key < /dev/tty
	done
		# echo ""
		#~ echo -e "\\e[0;100m 0) \\e[0m Télécharger audio en avance"
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
					echo -e "      \\e[0;100m 1) \\e[0m $TEXT_CONTINUE"
					echo -e "      \\e[0;100m 2) \\e[0m $TEXT_RESTART"
					echo -e "      \\e[0;100m e) \\e[0m $TEXT_BACK"
					choice="x"
					while [ "$choice" != "1" ] && [ "$choice" != "2" ] && [ "$choice" != "e" ]; do
						echo -en "      \\e[97;45m # \\e[0m"
						read choice < /dev/tty
					done
						case $choice in
							1)  cd `cat "$HOME/.GameScript/restore_pwd_$CHAPTER_NAME$CHAPTER_NUMBER"`
								how_to_leave_chapter
								start_lecture `cat "$HOME/.GameScript/restore_$CHAPTER_NAME$CHAPTER_NUMBER"`
								start_quiz
								;;
							2) 	clean
								how_to_leave_chapter
								start_lecture 1
								start_quiz
								;;
							e) exit ;;
						esac
					#~ done
				fi
				start_lecture 1
				start_quiz
				;;
			2) 	start_quiz ;;
			e) exit ;;
		esac
	#~ done
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
				press_key
				stop_quiz_music
				#enter_chapter $CHAPTER_NAME $CHAPTER_NUMBER
				exit ;;
			en) talk_not_press_key justumen "\\e[4;37mSorry answer wrong or too long. I recommend you to do / re-do the lecture :-)\nIf you think you already understand the content of the lecture, this question is probably a trap, read the question again carefully. :-)\nIf you feel stuck, ask for help on our discord : https://discord.gg/Dj47Tpf\\e[0m"
				#enter_chapter $CHAPTER_NAME $CHAPTER_NUMBER
				press_key
				stop_quiz_music
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
#~ command -v mplayer &> /dev/null && SOUNDPLAYER="mplayer -af volume=10" || SOUNDPLAYER="mpg123 --scale 100000";
#SET in gamescript.sh too (need to be similar)
command -v mplayer &> /dev/null && SOUNDPLAYER="mplayer -volume 100" || SOUNDPLAYER="mpg123";
command -v mplayer &> /dev/null && SOUNDPLAYER_MUSIC="mplayer -volume 35" || SOUNDPLAYER_MUSIC="mpg123 --scale 11445"
command -v mplayer &> /dev/null && SOUNDPLAYER_MUSIC_QUIZ="mplayer -volume 50" || SOUNDPLAYER_MUSIC_QUIZ="mpg123"

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
	echo ""
	case $LANGUAGE in
		fr) echo -e "Pour débloquer '$1 $2' sur rocketchat (https://rocket.bjornulf.org), ouvrez une conversation privée avec '@boti' et copiez/collez :\n\t\e[97;42mpassword$PASS\e[0m"
			echo -e "Pour débloquer '$1 $2' sur discord (https://discord.gg/25eRgvD), ouvrez le channel '#mots-de-passe-boti' et copiez/collez :\n\t\e[97;42mpassword$PASS\e[0m"
			command -v xclip &> /dev/null && echo "Ce mot de passe a été copié automatiquement avec 'xclip'." || echo "[ Installez 'xclip' pour copier ce mot de passe automatiquement après un questionnaire. ]"
			;;
		en) #echo -e "To unlock '$1 $2' on rocketchat (https://rocket.bjornulf.org), open a private conversation with '@boti' and copy/paste :\n\t\e[97;42mpassword$PASS\e[0m"
			echo -e "To unlock '$1 $2' on discord (https://discord.gg/Dj47Tpf), open the channel '#passwords-boti' and copy/paste :\n\t\e[97;42mpassword$PASS\e[0m"
			command -v xclip &> /dev/null && echo "This password was automaticaly copied with 'xclip'." || echo "[ Install 'xclip' to copy this password automaticaly after a quiz. ]"
			;;
	esac
	command -v xclip &> /dev/null && echo "$PASS" | xclip -i -selection clipboard
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
1) echo -n 1 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; command -v xterm >/dev/null 2>&1 || { echo "Veuillez installer les dépendances requises. Faites en tant qu'administrateur : apt-get install i3 i3status surf mousepad leafpad pcmanfm jq feh wmctrl xdotool xterm galculator" >&2; rm $HOME/.GameScript/restore_i3wm1; exit 3; }; restore=$(expr $restore + 1) ;&
2) echo -n 2 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; command -v i3 >/dev/null 2>&1 || { echo "Veuillez installer les dépendances requises. Faites en tant qu'administrateur : apt-get install i3 i3status surf mousepad leafpad pcmanfm jq feh wmctrl xdotool xterm galculator" >&2; rm $HOME/.GameScript/restore_i3wm1; exit 3; }; restore=$(expr $restore + 1) ;&
3) echo -n 3 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; command -v i3status >/dev/null 2>&1 || { echo "Veuillez installer les dépendances requises. Faites en tant qu'administrateur : apt-get install i3 i3status surf mousepad leafpad pcmanfm jq feh wmctrl xdotool xterm galculator" >&2; rm $HOME/.GameScript/restore_i3wm1; exit 3; }; restore=$(expr $restore + 1) ;&
4) echo -n 4 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; command -v surf >/dev/null 2>&1 || { echo "Veuillez installer les dépendances requises. Faites en tant qu'administrateur : apt-get install i3 i3status surf mousepad leafpad pcmanfm jq feh wmctrl xdotool xterm galculator" >&2; rm $HOME/.GameScript/restore_i3wm1; exit 3; }; restore=$(expr $restore + 1) ;&
5) echo -n 5 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; command -v mousepad  >/dev/null 2>&1 || { echo "Veuillez installer les dépendances requises. Faites en tant qu'administrateur : apt-get install i3 i3status surf mousepad leafpad pcmanfm jq feh wmctrl xdotool xterm galculator" >&2; rm $HOME/.GameScript/restore_i3wm1; exit 3; }; restore=$(expr $restore + 1) ;&
6) echo -n 6 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; command -v leafpad >/dev/null 2>&1 || { echo "Veuillez installer les dépendances requises. Faites en tant qu'administrateur : apt-get install i3 i3status surf mousepad leafpad pcmanfm jq feh wmctrl xdotool xterm galculator" >&2; rm $HOME/.GameScript/restore_i3wm1; exit 3; }; restore=$(expr $restore + 1) ;&
7) echo -n 7 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; command -v pcmanfm >/dev/null 2>&1 || { echo "Veuillez installer les dépendances requises. Faites en tant qu'administrateur : apt-get install i3 i3status surf mousepad leafpad pcmanfm jq feh wmctrl xdotool xterm galculator" >&2; rm $HOME/.GameScript/restore_i3wm1; exit 3; }; restore=$(expr $restore + 1) ;&
8) echo -n 8 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; command -v jq >/dev/null 2>&1 || { echo "Veuillez installer les dépendances requises. Faites en tant qu'administrateur : apt-get install i3 i3status surf mousepad leafpad pcmanfm jq feh wmctrl xdotool xterm galculator" >&2; rm $HOME/.GameScript/restore_i3wm1; exit 3; }; restore=$(expr $restore + 1) ;&
9) echo -n 9 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; command -v feh >/dev/null 2>&1 || { echo "Veuillez installer les dépendances requises. Faites en tant qu'administrateur : apt-get install i3 i3status surf mousepad leafpad pcmanfm jq feh wmctrl xdotool xterm galculator" >&2; rm $HOME/.GameScript/restore_i3wm1; exit 3; }; restore=$(expr $restore + 1) ;&
10) echo -n 10 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; command -v wmctrl >/dev/null 2>&1 || { echo "Veuillez installer les dépendances requises. Faites en tant qu'administrateur : apt-get install i3 i3status surf mousepad leafpad pcmanfm jq feh wmctrl xdotool xterm galculator" >&2; rm $HOME/.GameScript/restore_i3wm1; exit 3; }; restore=$(expr $restore + 1) ;&
11) echo -n 11 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; command -v xdotool >/dev/null 2>&1 || { echo "Veuillez installer les dépendances requises. Faites en tant qu'administrateur : apt-get install i3 i3status surf mousepad leafpad pcmanfm jq feh wmctrl xdotool xterm galculator" >&2; rm $HOME/.GameScript/restore_i3wm1; exit 3; }; restore=$(expr $restore + 1) ;&
12) echo -n 12 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; command -v galculator >/dev/null 2>&1 || { echo "Veuillez installer les dépendances requises. Faites en tant qu'administrateur : apt-get install i3 i3status surf mousepad leafpad pcmanfm jq feh wmctrl xdotool xterm galculator" >&2; rm $HOME/.GameScript/restore_i3wm1; exit 3; }; restore=$(expr $restore + 1) ;&
13) echo -n 13 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; mkdir ~/.config 2>/dev/null; restore=$(expr $restore + 1) ;&
14) echo -n 14 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; mkdir ~/.config/i3 2>/dev/null; restore=$(expr $restore + 1) ;&
15) echo -n 15 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; [ -f "$HOME/.config/i3/config_GS_backup" ] && [ ! -f "$HOME/.GameScript/i3wm_1_installed" ] && echo "$HOME/.config/i3/config_GS_backup existe déjà sur votre système, veuillez le renommer ou le supprimer pour continuer." && exit; restore=$(expr $restore + 1) ;&
16) echo -n 16 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; [ -f "$HOME/.i3/config_GS_backup" ] && [ ! -f "$HOME/.GameScript/i3wm_1_installed" ] && echo "$HOME/.i3/config_GS_backup existe déjà sur votre système, veuillez le renommer ou le supprimer pour continuer." && exit; restore=$(expr $restore + 1) ;&
17) echo -n 17 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; if [ -f "$HOME/.config/i3/config" ] || [ -f "$HOME/.i3/config" ]; then read -p "GameScript is using a personnalised configuration file, your current i3 configuration file will be renamed "config_GS_backup", do you want to continue ? [Y]es/[N]o : " -n 1 -r ; echo ; if [[ ! $REPLY =~ ^[Yy]$ ]]; then exit ; fi ; fi; restore=$(expr $restore + 1) ;&
18) echo -n 18 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; if [ ! -f "$HOME/.GameScript/i3wm_1_installed" ]; then [ -f "$HOME/.config/i3/config" ] && mv $HOME/.config/i3/config $HOME/.config/i3/config_GS_backup && echo "Your configuration file $HOME/.config/i3/config wast renamed into $HOME/.config/i3/config_GS_backup"; [ -f "$HOME/.i3/config" ] && mv $HOME/.i3/config $HOME/.i3/config_GS_backup && echo "Your configuration file $HOME/.i3/config was renamed into $HOME/.i3/config_GS_backup"; touch $HOME/.GameScript/i3wm_1_installed;wget https://raw.githubusercontent.com/justUmen/GameScript/master/fr/classic/i3wm/_1/config -O ~/.config/i3/config &> /dev/null; rm $HOME/.GameScript/restore_i3wm1; echo "INSTALLATION SUCCESSFULL : Please close your current window manager and launch i3 normally : Disconnect and select i3 in your DIsplay Manager (lightdm, gdm, xdm...) GameScript will be there to welcome you. :-)"; pkill -f gamescript.sh; exit; fi; restore=$(expr $restore + 1) ;&
19) echo -n 19 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; mkdir $HOME/.GameScript_i3wm_1 &> /dev/null; restore=$(expr $restore + 1) ;&
20) echo -n 20 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; cd $HOME/.GameScript_i3wm_1; restore=$(expr $restore + 1) ;&
21) echo -n 21 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; gamescript_window=$(xdotool getwindowfocus); restore=$(expr $restore + 1) ;&
22) echo -n 22 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "In a ${voc}Window Manager${reset} (wm), you need to learn how to control two things : the ${voc}Workspaces${reset}) and the ${voc}Windows${reset}."; restore=$(expr $restore + 1) ;&
23) echo -n 23 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Let's start with the ${voc}Workspaces${reset}. Here I'm going to give you my own configurations, but you can change them afterwards if you want to."; restore=$(expr $restore + 1) ;&
24) echo -n 24 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "You can have several workspaces, and each of them can have its own settings and a particular objective in mind."; restore=$(expr $restore + 1) ;&
25) echo -n 25 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "If you look at the bottom left side of your screen, you should see the number 1 in a square."; restore=$(expr $restore + 1) ;&
26) echo -n 26 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "This '1' is the number/name of the workspace you are currently in."; restore=$(expr $restore + 1) ;&
27) echo -n 27 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "For now, this workspace only contains the window of the terminal that launched GameScript."; restore=$(expr $restore + 1) ;&
28) echo -n 28 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "The window manager i3 (i3wm) is based on keyboard bindings in order to work."; restore=$(expr $restore + 1) ;&
29) echo -n 29 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "There are all customizable, but I will give you some that I advise you to keep."; restore=$(expr $restore + 1) ;&
30) echo -n 30 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "You can go from one workspace to another with the key 'Super', sometimes named by some neophytes : "Windows Key"."; restore=$(expr $restore + 1) ;&
31) echo -n 31 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "You need to keep holding the key "Super" et press the number of the workspace you want to go to."; restore=$(expr $restore + 1) ;&
32) echo -n 32 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "GameScript is now in workspace 1, remember this because if you want to continue to interact with GameScript, you will have to do 'Super + 1'."; restore=$(expr $restore + 1) ;&
33) echo -n 33 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Now, move inside workspace 2 with 'Super + 2', check out the workspace list on the bottom left of your screen, and do 'Super + 1' to come back on GameScript."; restore=$(expr $restore + 1) ;&
34) echo -n 34 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 2 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
35) echo -n 35 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ ! `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
36) echo -n 36 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Now that you are back in workspace 1, you can see that workspace 2 is not longer displayed in the list on the bottom left."; restore=$(expr $restore + 1) ;&
37) echo -n 37 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "But when you were in workspace 2, workspace 1 was visible in this list."; restore=$(expr $restore + 1) ;&
38) echo -n 38 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "In fact, i3 will automatically get rid of any workspaces, if they don't contain a window."; restore=$(expr $restore + 1) ;&
39) echo -n 39 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Workspace 2 being empty, it will no longer be listed here."; restore=$(expr $restore + 1) ;&
40) echo -n 40 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "The workspace 1 however, will be listed because it contains the window of GameScript."; restore=$(expr $restore + 1) ;&
41) echo -n 41 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "I advise you to use keyboard shortcuts for all the programs that you use often."; restore=$(expr $restore + 1) ;&
42) echo -n 42 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "For exemple, to open a new terminal, you need to use the shortcut 'Super + Return'."; restore=$(expr $restore + 1) ;&
43) echo -n 43 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "We will start by creating a new window on workspace 2."; restore=$(expr $restore + 1) ;&
44) echo -n 44 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Move inside workspace 2 with 'SUper + 2', open a new terminal in this workspace with 'Super + Return', and come back on GameScript with 'Super + 1'."; restore=$(expr $restore + 1) ;&
45) echo -n 45 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 2 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
46) echo -n 46 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ ! `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
47) echo -n 47 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Back in workspace 1, you can see that workspace 2 is this time listed, because it is no longer empty."; restore=$(expr $restore + 1) ;&
48) echo -n 48 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "You can also use your mouse et click on the name of workspace you want to go to."; restore=$(expr $restore + 1) ;&
49) echo -n 49 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Use you r mouse and the list of workspaces to go to workspace 2, close this terminal et come back on GameScript by using only your mouse."; restore=$(expr $restore + 1) ;&
50) echo -n 50 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 2 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
51) echo -n 51 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ ! `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
52) echo -n 52 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Look now the blue bar on top of your screen : it contains the title of the window where GameScript is running."; restore=$(expr $restore + 1) ;&
53) echo -n 53 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Of course, it is possible to have several windows on the same workspace."; restore=$(expr $restore + 1) ;&
54) echo -n 54 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; i3-msg 'exec xterm' &>/dev/null; while [ `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done; i3-msg focus left; restore=$(expr $restore + 1) ;&
55) echo -n 55 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "I've just opened a new terminal in your workspace, you should now see two different tabs on the top of your screen."; restore=$(expr $restore + 1) ;&
56) echo -n 56 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Each tab represents a window, the one on the left is the title of the GameScript window."; restore=$(expr $restore + 1) ;&
57) echo -n 57 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "The windows are displayed in these tabs from left to right, from the oldest to the more recent."; restore=$(expr $restore + 1) ;&
58) echo -n 58 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Each new window will be added on the far right of the already existing tabs."; restore=$(expr $restore + 1) ;&
59) echo -n 59 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "The terminal running GameScript was open first, it will therefore stay on the far left."; restore=$(expr $restore + 1) ;&
60) echo -n 60 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Click on the tab of the second window to display it, et come back on GameScript by clicking on the first tab."; restore=$(expr $restore + 1) ;&
61) echo -n 61 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done;sleep 1;while [ ! `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
62) echo -n 62 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Of course, I advise you to use your keyboard to do this, you can simply use 'Super + left/right arrow'."; restore=$(expr $restore + 1) ;&
63) echo -n 63 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Do it now, try 'Super + left arrow' to go on the second window et come back on GameScript with 'Super + right arrow'."; restore=$(expr $restore + 1) ;&
64) echo -n 64 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done;sleep 1;while [ ! `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
65) echo -n 65 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "WHen you go on a window, we say that this window is the ${voc}focus${reset}."; restore=$(expr $restore + 1) ;&
66) echo -n 66 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "It means that all keyboard shortcuts are going to be sent to the focused window."; restore=$(expr $restore + 1) ;&
67) echo -n 67 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "For example, to close a window, the key binding is 'Super + Shift + q', but be careful not to close GameScript by mistake."; restore=$(expr $restore + 1) ;&
68) echo -n 68 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Change the focus with 'Super + right arrow', and close the second terminal I opened before with 'Super + Shift + q'."; restore=$(expr $restore + 1) ;&
69) echo -n 69 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; gamescript_window=$(xdotool getwindowfocus); restore=$(expr $restore + 1) ;&
70) echo -n 70 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
71) echo -n 71 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; to_close=$(xdotool getwindowfocus); restore=$(expr $restore + 1) ;&
72) echo -n 72 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `xdotool search --class ""|grep "^$to_close$"` ];do sleep .5; done; restore=$(expr $restore + 1) ;&
73) echo -n 73 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ ! `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
74) echo -n 74 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Now, open a new terminal with 'Super + Return', you will see that the focus changes immediately for this newly opened window, you will then have to come back manually on GameScript."; restore=$(expr $restore + 1) ;&
75) echo -n 75 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
76) echo -n 76 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `xdotool getwindowfocus` != $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
77) echo -n 77 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "There are 3 types of layouts available in i3."; restore=$(expr $restore + 1) ;&
78) echo -n 78 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Here, the windows are ${voc}tabbed${reset}, but they can also be ${voc}stacked${reset}, where the title of the windows will fill the whole screen."; restore=$(expr $restore + 1) ;&
79) echo -n 79 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "But to go from one window to the other with this stacked layout, you will have to use 'Super + up/down arrows', instead of left and right arrows."; restore=$(expr $restore + 1) ;&
80) echo -n 80 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Try this layout now with 'Super + s', and toggle between the two windows with 'Super + up/down arrows'."; restore=$(expr $restore + 1) ;&
81) echo -n 81 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
82) echo -n 82 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `xdotool getwindowfocus` != $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
83) echo -n 83 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Now go back to the tabbed layout with 'Super + w'."; restore=$(expr $restore + 1) ;&
84) echo -n 84 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "And finally you have a third layout, a tiling layout where all your windows are going to be displayed on the workspace, in an optimized manner."; restore=$(expr $restore + 1) ;&
85) echo -n 85 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Try this layout with 'Super + e'."; restore=$(expr $restore + 1) ;&
86) echo -n 86 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "You can then continue to use 'Super + e' to toggle between horizontal display and vertical display."; restore=$(expr $restore + 1) ;&
87) echo -n 87 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Use 'Super + e' until you have the new terminal below GameScript."; restore=$(expr $restore + 1) ;&
88) echo -n 88 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Here, even if both windows are visible on the screen, only one of them has the focus."; restore=$(expr $restore + 1) ;&
89) echo -n 89 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Here the focused window has its title bar and its border in blue."; restore=$(expr $restore + 1) ;&
90) echo -n 90 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Using the same method you can switch focus with 'Super + arrows'."; restore=$(expr $restore + 1) ;&
91) echo -n 91 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Give the focus to the bottom window, launch the command ${learn}ls${reset} inside and give the focus back to GameScript."; restore=$(expr $restore + 1) ;&
92) echo -n 92 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
93) echo -n 93 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `xdotool getwindowfocus` != $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
94) echo -n 94 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "You can notice that with this kind of layout, it is also possible to change the focused window with your mouse cursor."; restore=$(expr $restore + 1) ;&
95) echo -n 95 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Also, note that only the movement of your cursor can trigger it, you don't have to click."; restore=$(expr $restore + 1) ;&
96) echo -n 96 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Try to switch focus between the two windows now by using your mouse."; restore=$(expr $restore + 1) ;&
97) echo -n 97 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
98) echo -n 98 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `xdotool getwindowfocus` != $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
99) echo -n 99 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Of course, like everything you do in i3, I recommend you to use your mouse as less as possible, and use your keyboard instead."; restore=$(expr $restore + 1) ;&
100) echo -n 100 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Be careful, after this sentence, GameScript will vanish... And you will have to find if to continue."; restore=$(expr $restore + 1) ;&
101) echo -n 101 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; i3-msg 'move window to workspace 5' &>/dev/null; restore=$(expr $restore + 1) ;&
102) echo -n 102 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 5 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
103) echo -n 103 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Congratulations, you were able to find GameScript back in workspace 5."; restore=$(expr $restore + 1) ;&
104) echo -n 104 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "You already know how to go from one workspace to another, but it is also possible to move your windows in another workspace."; restore=$(expr $restore + 1) ;&
105) echo -n 105 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Put back GameScript in workspace 1 with 'Super + Shift + 1', and go back to workspace 1 to continue."; restore=$(expr $restore + 1) ;&
106) echo -n 106 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 1 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
107) echo -n 107 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ ! `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
108) echo -n 108 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "You can notice that the GameScript window is now below the other one. It is because GameScript is now the newest window on this workspace."; restore=$(expr $restore + 1) ;&
109) echo -n 109 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "If layout was tabbed, GameScript would be the last tab on the right."; restore=$(expr $restore + 1) ;&
110) echo -n 110 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Having multiples workspaces is very useful to organise with windows according to your will."; restore=$(expr $restore + 1) ;&
111) echo -n 111 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Personnaly, I use workspace 1 for my primary terminal, that I want be operational quickly."; restore=$(expr $restore + 1) ;&
112) echo -n 112 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "I use workspace 2 for my text editors."; restore=$(expr $restore + 1) ;&
113) echo -n 113 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "I use workspace 3 for my web browsers and other web-oriented windows."; restore=$(expr $restore + 1) ;&
114) echo -n 114 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "I use workspace 4 for my file managers."; restore=$(expr $restore + 1) ;&
115) echo -n 115 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "And I use workspace 5 for everything social : email, our rocketchat, our discord, etc..."; restore=$(expr $restore + 1) ;&
116) echo -n 116 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Organizing your windows by theme enables you to find them back very quickly, even if you have a lot of them."; restore=$(expr $restore + 1) ;&
117) echo -n 117 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; gamescript_window=$(xdotool getwindowfocus); restore=$(expr $restore + 1) ;&
118) echo -n 118 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Close the window above to continue."; restore=$(expr $restore + 1) ;&
119) echo -n 119 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
120) echo -n 120 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; to_close=$(xdotool getwindowfocus); restore=$(expr $restore + 1) ;&
121) echo -n 121 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `xdotool search --class ""|grep "^$to_close$"` ];do sleep .5; done; restore=$(expr $restore + 1) ;&
122) echo -n 122 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ ! `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
123) echo -n 123 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; echo -e "<html>\\n\\t<head>\\n\\t\\t<link rel="stylesheet" href="style.css">\\n\\t</head>\\n\\t<body>\\n\\t\\t<h1>GameScript</h1>\\n\\t\\t<div>good morning</div>\\n\\t</body>\\n</html>" > ~/.GameScript_i3wm_1/index.html; restore=$(expr $restore + 1) ;&
124) echo -n 124 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; echo -e "h1{color:red;}" > ~/.GameScript_i3wm_1/style.css; restore=$(expr $restore + 1) ;&
125) echo -n 125 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; i3-msg exec leafpad ~/.GameScript_i3wm_1/index.html &>/dev/null; restore=$(expr $restore + 1) ;&
126) echo -n 126 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; i3-msg exec surf ~/.GameScript_i3wm_1/index.html &>/dev/null; restore=$(expr $restore + 1) ;&
127) echo -n 127 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; i3-msg exec pcmanfm ~/.GameScript_i3wm_1/ &>/dev/null; restore=$(expr $restore + 1) ;&
128) echo -n 128 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "I've just prepared for you a full example, with a single window per workspace."; restore=$(expr $restore + 1) ;&
129) echo -n 129 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "This example is using my owns configurations, but you will be free to have your own later on, depending on which programs you use often."; restore=$(expr $restore + 1) ;&
130) echo -n 130 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Workspace 2 has a file 'index.html; opened in a text ditor (leafpad), visit this workspace and come back to GameScript."; restore=$(expr $restore + 1) ;&
131) echo -n 131 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 2 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
132) echo -n 132 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 1 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
133) echo -n 133 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ ! `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
134) echo -n 134 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Workspace 3 has the same html file opened in a web browser (surf), visit this workspace and come back to GameScript."; restore=$(expr $restore + 1) ;&
135) echo -n 135 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 3 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
136) echo -n 136 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 1 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
137) echo -n 137 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ ! `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
138) echo -n 138 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "And finally, workspace 4 has a file manager (pcmanfm) opened in the folde that contains our html file. Visit this workspace and come back to GameScript."; restore=$(expr $restore + 1) ;&
139) echo -n 139 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 4 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
140) echo -n 140 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 1 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
141) echo -n 141 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ ! `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
142) echo -n 142 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "So instead of having 4 different windows, we have here 4 workspaces, and each of them contains a window."; restore=$(expr $restore + 1) ;&
143) echo -n 143 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Change the text 'good morning' on the html file by 'good evening' on workspace 2, save the file et come back on GameScript."; restore=$(expr $restore + 1) ;&
144) echo -n 144 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 2 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
145) echo -n 145 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 1 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
146) echo -n 146 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Display the changes by refreshing the web browser (key F5) on workspace 3 and come back on GameScript."; restore=$(expr $restore + 1) ;&
147) echo -n 147 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 3 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
148) echo -n 148 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 1 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
149) echo -n 149 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Go on workspace 4 and open the file 'style.css' with leafpad by doing : right clic on the file, open with, and select Leafpad. And come back on GameScript."; restore=$(expr $restore + 1) ;&
150) echo -n 150 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 4 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
151) echo -n 151 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 1 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
152) echo -n 152 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "You probably noticed that leafpad didn't open on workspace 4, but in workspace 2 !"; restore=$(expr $restore + 1) ;&
153) echo -n 153 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "It is because I configured your i3 to do that."; restore=$(expr $restore + 1) ;&
154) echo -n 154 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "By the way, your workspace 2 should now be red in the list of workspaces."; restore=$(expr $restore + 1) ;&
155) echo -n 155 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "This red means that a new window was opened in this workspace, and this color will stay red until this new window receive the focus."; restore=$(expr $restore + 1) ;&
156) echo -n 156 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "In the file 'style.css', change the color 'red' by 'blue', save the file, check the changes with F5 on your web browser and come back on GameScript."; restore=$(expr $restore + 1) ;&
157) echo -n 157 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 2 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
158) echo -n 158 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 3 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
159) echo -n 159 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 1 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
160) echo -n 160 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "With i3, it is possible to define in which workspace you want a program to open."; restore=$(expr $restore + 1) ;&
161) echo -n 161 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "'leafpad' being a text editor, we want it to open on workspace 2 by default."; restore=$(expr $restore + 1) ;&
162) echo -n 162 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "This must be set in i3 configuration file : ${code}$HOME/.config/i3/config${reset}"; restore=$(expr $restore + 1) ;&
163) echo -n 163 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "To always open 'leafpad' in workspace 2, I added in your configuration file the line : ${code}assign [class=\"Leafpad\"] workspace 2${reset}"; restore=$(expr $restore + 1) ;&
164) echo -n 164 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Try to do the same thing with 'mousepad', another text editor : ${learn}echo 'assign [class=\"Mousepad\"] workspace 2'>>~/.config/i3/config${reset}"; restore=$(expr $restore + 1) ;&
165) echo -n 165 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; answer_run "echo 'assign [class=\"Mousepad\"] workspace 2'>>~/.config/i3/config" justumen ""; restore=$(expr $restore + 1) ;&
166) echo -n 166 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Now launch 'mousepad', detach it to the current terminal and ignore its errors with : ${learn}mousepad&>/dev/null&${reset}"; restore=$(expr $restore + 1) ;&
167) echo -n 167 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; answer_run "mousepad&>/dev/null&" justumen ""; restore=$(expr $restore + 1) ;&
168) echo -n 168 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "You can notice that 'mousepad' opened in workspace 1, which is not what was expected."; restore=$(expr $restore + 1) ;&
169) echo -n 169 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "For our modifications to be in effect, we need to ${voc}reload${reset} the configuration file with : 'Super + Shift + c', do it before moving on."; restore=$(expr $restore + 1) ;&
170) echo -n 170 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "After doing 'Super + Shift + c', you shoudl see the i3 interface blinking for an instant."; restore=$(expr $restore + 1) ;&
171) echo -n 171 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "But our 'mousepad' window is still in workspace 1, because 'assign' will affect only newly created windows."; restore=$(expr $restore + 1) ;&
172) echo -n 172 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Close this 'mousepad' window before continuing."; restore=$(expr $restore + 1) ;&
173) echo -n 173 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "From now on, all the instances of 'mousepad' will be sent to workspace 2."; restore=$(expr $restore + 1) ;&
174) echo -n 174 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Launch mouse pad again with : ${learn}mousepad&>/dev/null&${reset}"; restore=$(expr $restore + 1) ;&
175) echo -n 175 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; answer_run "mousepad&>/dev/null&" justumen ""; restore=$(expr $restore + 1) ;&
176) echo -n 176 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "You are still in workspace 1 now, but you should see workspace 2 in red."; restore=$(expr $restore + 1) ;&
177) echo -n 177 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Find and close this 'mousepad' window before continuing."; restore=$(expr $restore + 1) ;&
178) echo -n 178 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 2 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
179) echo -n 179 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 1 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
180) echo -n 180 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Open now 'galculator' with ${learn}galculator&>/dev/null&${reset} and come back on GameScript."; restore=$(expr $restore + 1) ;&
181) echo -n 181 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; answer_run "galculator&>/dev/null&" justumen ""; restore=$(expr $restore + 1) ;&
182) echo -n 182 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "On can notice that this window will fill half of your screen, which is not ideal for this type of window..."; restore=$(expr $restore + 1) ;&
183) echo -n 183 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "In this kind of situation, you can use a specific mode called ${voc}floating${reset}, that you can activate/deactivate with 'Super + Shift + Spacebar'."; restore=$(expr $restore + 1) ;&
184) echo -n 184 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "After having 'focus' the calculator, use this keybind on it to make it independant from the others."; restore=$(expr $restore + 1) ;&
185) echo -n 185 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "You can notice that on i3, a floating window is always on on top of the others, even if the focus is on another window !"; restore=$(expr $restore + 1) ;&
186) echo -n 186 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "But this change is temporary : it will only affect this instance of galculator."; restore=$(expr $restore + 1) ;&
187) echo -n 187 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "For 'galculator' to always be in floating more, we need once again to edit the configuration file."; restore=$(expr $restore + 1) ;&
188) echo -n 188 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "The code ${code}assign [class=\"Leafpad\"] workspace 2${reset} that we already saw, is targetting all instances of leafpad by using the argument ${code}class${reset} which should be equal to ${code}Leafpad${reset}."; restore=$(expr $restore + 1) ;&
189) echo -n 189 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "To know the ${voc}class${reset} of a specific window, you can use the command : ${code}xprop${reset}"; restore=$(expr $restore + 1) ;&
190) echo -n 190 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Launch the command ${learn}xprop${reset}, your mouse cursor will turn into a cross, and click on the terminal where GameScript is running."; restore=$(expr $restore + 1) ;&
191) echo -n 191 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; answer_run "xprop" justumen ""; restore=$(expr $restore + 1) ;&
192) echo -n 192 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "The name of the 'class' of the window who have targetted is the second name of the line starting with 'WM_CLASS'."; restore=$(expr $restore + 1) ;&
193) echo -n 193 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "If you are only interested in this line, you can use ${code}grep${reset}."; restore=$(expr $restore + 1) ;&
194) echo -n 194 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Do ${learn}xprop|grep CLASS${reset} et click on the calculator to find its 'class'."; restore=$(expr $restore + 1) ;&
195) echo -n 195 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; answer_run "xprop|grep CLASS" justumen ""; restore=$(expr $restore + 1) ;&
196) echo -n 196 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "The result should be : ${code}WM_CLASS(STRING) = \"galculator\", \"Galculator\"${reset}"; restore=$(expr $restore + 1) ;&
197) echo -n 197 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "The ${code}class${reset} is here the second string : ${code}\"Galculator\"${reset}"; restore=$(expr $restore + 1) ;&
198) echo -n 198 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "If you want all windows with the class ${code}Galculator${reset} to be in floating mode, you will have to add in the configuration file : ${code}for_window [class=\"Galculator\"] floating enable${reset}"; restore=$(expr $restore + 1) ;&
199) echo -n 199 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "If you want your floating window to be displayed on all workspaces, you will have to use the code : ${code}sticky enable${reset}"; restore=$(expr $restore + 1) ;&
200) echo -n 200 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "${code}for_window${reset} accepts several parameters, that you can separate with commas."; restore=$(expr $restore + 1) ;&
201) echo -n 201 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "For the 'class' ${code}Galculator${reset} to be in floating mode and stay on all workspaces, you need to have : ${code}for_window [class=\"Galculator\"] floating enable, sticky enable${reset}"; restore=$(expr $restore + 1) ;&
202) echo -n 202 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Close the calculator and do : ${code}echo 'for_window [class=\"Galculator\"] floating enable, sticky enable'>>~/.config/i3/config${reset}"; restore=$(expr $restore + 1) ;&
203) echo -n 203 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; answer_run "echo 'for_window [class=\"Galculator\"] floating enable, sticky enable'>>~/.config/i3/config" justumen ""; restore=$(expr $restore + 1) ;&
204) echo -n 204 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Display the two last lines of you configuration file with : ${learn}tail -n 2 ~/.config/i3/config${reset}"; restore=$(expr $restore + 1) ;&
205) echo -n 205 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; answer_run "tail -n 2 ~/.config/i3/config" justumen ""; restore=$(expr $restore + 1) ;&
206) echo -n 206 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Of course, don't forget to reload you configuration file with 'Super + Shift + c'"; restore=$(expr $restore + 1) ;&
207) echo -n 207 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "After reloading your configuration, launch galculator with : ${learn}galculator&>/dev/null&${reset}"; restore=$(expr $restore + 1) ;&
208) echo -n 208 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; answer_run "galculator&>/dev/null&" justumen ""; restore=$(expr $restore + 1) ;&
209) echo -n 209 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Here you can see that the calculator is now in floating mode because of the ${code}floating enable${reset} part."; restore=$(expr $restore + 1) ;&
210) echo -n 210 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "But if you try to cahnge workspace, you will see that because of ${code}sticky enable${reset}, the window will follow you."; restore=$(expr $restore + 1) ;&
211) echo -n 211 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Move in workspace 5 and come back to GameScript."; restore=$(expr $restore + 1) ;&
212) echo -n 212 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 5 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
213) echo -n 213 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 1 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
214) echo -n 214 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "You can note that the 'sticky' mode will only work for floating windows."; restore=$(expr $restore + 1) ;&
215) echo -n 215 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Also, if you want to move this floating window, you can hold the key 'Super' and the left button of you mouse."; restore=$(expr $restore + 1) ;&
216) echo -n 216 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Try to move around the calculator this way, by holding the key 'Super', ou don't need to click on the title bar."; restore=$(expr $restore + 1) ;&
217) echo -n 217 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "But it isn't very practical to always launch your applications from a terminal."; restore=$(expr $restore + 1) ;&
218) echo -n 218 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "This is why an ${voc}application launcher${reset} / ${voc}run dialog${reset} is a very important tool in i3 !"; restore=$(expr $restore + 1) ;&
219) echo -n 219 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "We will create our first customized keybind for our run dialog."; restore=$(expr $restore + 1) ;&
220) echo -n 220 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "To create a new keyboard bind, we need to use ${code}bindsym${reset}."; restore=$(expr $restore + 1) ;&
221) echo -n 221 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "In this example we will use the program ${code}rofi${reset}, and more precisely the command ${code}rofi -show run${reset} and the key combinaison 'Alt + F2'."; restore=$(expr $restore + 1) ;&
222) echo -n 222 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "In the i3 configuration file, if you want to launch a command, you will have to preceed it with the keyword ${code}exec${reset}."; restore=$(expr $restore + 1) ;&
223) echo -n 223 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "For i3, the key 'Alt' is ${code}mod1${reset}, and the key 'Super' is ${code}mod4${reset}. The configuration code shoudl therefore be : ${code}bindsym mod1+F2 exec rofi -show run${reset}"; restore=$(expr $restore + 1) ;&
224) echo -n 224 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Add this code at the end of your configuration file with : ${learn}echo 'bindsym mod1+F2 exec rofi -show run'>>~/.config/i3/config${reset}"; restore=$(expr $restore + 1) ;&
225) echo -n 225 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; answer_run "echo 'bindsym mod1+F2 exec rofi -show run'>>~/.config/i3/config" justumen ""; restore=$(expr $restore + 1) ;&
226) echo -n 226 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "And finaly, reload your configuration with 'Super + Shift + c'."; restore=$(expr $restore + 1) ;&
227) echo -n 227 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Now do 'Alt + F2' to launch ${code}rofi -show run${reset}, and execute 'galculator' with it."; restore=$(expr $restore + 1) ;&
228) echo -n 228 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "So here we have 3 basic examples for the 3 most basic i3 configurations : ${code}assign${reset}, ${code}for_window${reset} et ${code}bindsym${reset}."; restore=$(expr $restore + 1) ;&
229) echo -n 229 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "As a syntax reminder, display the 3 lines we added in this chapter with : ${learn}tail -n 3 ~/.config/i3/config${reset}"; restore=$(expr $restore + 1) ;&
230) echo -n 230 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; answer_run "tail -n 3 ~/.config/i3/config" justumen ""; restore=$(expr $restore + 1) ;&
231) echo -n 231 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "${code}assign${reset} is used to link some windows with a specific workspace."; restore=$(expr $restore + 1) ;&
232) echo -n 232 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "${code}for_window${reset} is used to give a special configuration to some windows."; restore=$(expr $restore + 1) ;&
233) echo -n 233 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "And finally ${code}bindsym${reset} is used to launch other commands with a combinaison of keys."; restore=$(expr $restore + 1) ;&
234) echo -n 234 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "You can now close the calculators."; restore=$(expr $restore + 1) ;&
235) echo -n 235 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Of course, all keybinds you have used are customizables."; restore=$(expr $restore + 1) ;&
236) echo -n 236 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "For example, to reload the configuration file, you need to do : 'Super+Shift+c'."; restore=$(expr $restore + 1) ;&
237) echo -n 237 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "But this code can also be changed like all the others in your configuration file. Do : ${learn}grep reload ~/.config/i3/config${reset}"; restore=$(expr $restore + 1) ;&
238) echo -n 238 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; answer_run "grep reload ~/.config/i3/config" justumen ""; restore=$(expr $restore + 1) ;&
239) echo -n 239 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Here you should see the 'bindsym' responsible for this event, but you can freely change it if you want."; restore=$(expr $restore + 1) ;&
240) echo -n 240 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "For example, to see the line responsible for exiting i3, do : ${learn}grep exit ~/.config/i3/config${reset}"; restore=$(expr $restore + 1) ;&
241) echo -n 241 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; answer_run "grep exit ~/.config/i3/config" justumen ""; restore=$(expr $restore + 1) ;&
242) echo -n 242 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Check this code in action by doing 'Super + Shift + e' : you will receive a message asking you confimation. Click on the cross to cancel."; restore=$(expr $restore + 1) ;&
243) echo -n 243 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "ANd if for example, you want to start 'nm-applet' automaticaly when i3 starts, you just have to add in your configuration : ${code}exec nm-applet${reset}."; restore=$(expr $restore + 1) ;&
244) echo -n 244 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "'nm-applet' is a graphical interface that is able to handle networks connections of 'NetworkManger'. (Install with the packet 'network-manager-applet' on Arch and 'network-manager-gnome' on Debian)"; restore=$(expr $restore + 1) ;&
245) echo -n 245 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "The use of the keyboard for everything can be strange for you, but trust me, you won't be able to do without soon !"; restore=$(expr $restore + 1) ;&
246) echo -n 246 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; i3-msg exec 'mousepad ~/.config/i3/config'; restore=$(expr $restore + 1) ;&
247) echo -n 247 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Before closing this chapter, I've just opened for you the configuration file of i3 in workspace 2."; restore=$(expr $restore + 1) ;&
248) echo -n 248 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "To avoid 'GameScript i3wm' to start when i3 is starting, remove the first line with the 'exec' code."; restore=$(expr $restore + 1) ;&
249) echo -n 249 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "That is it for now, in the next chapter we will see how we can manage our windows and layouts with high precision."; restore=$(expr $restore + 1) ;&
250) echo -n 250 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "You are ready for the quiz !"; restore=$(expr $restore + 1) ;&
251) echo -n 251 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; clean; restore=$(expr $restore + 1) ;&
esac
}
function clean(){ #in enter_chapter
rm $HOME/.GameScript/restore_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
rm $HOME/.GameScript/restore_pwd_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
rmdir $HOME/.GameScript_i3wm_1
}

function start_quiz(){
  start_quiz_music
  echo ""
  echo -e "\e[15;5;44m i3wm 'i3 Window Manager' : Questionnaire du chapitre 1 \e[0m"
  echo -e "- The answer should be as short as possible, a good answer adding uneeded characters will be considered as wrong."
  echo -e "Example : If the answer is 'ls'. The answers 'ls .', 'ls ./' and 'ls ././' won't work."
  answer_text_fr "What is the key 'UNKNOWN' in this sentence : To exit i3, do Super + Shift + UNKNOWN" "e"
  answer_text_fr "'Super + Shift + Return' is opening a new terminal (true/false)" "false"
  answer_text_fr "The floating windows are always above the others. (true/false)" "true"
  answer_text_fr "To have leafpad as a floating window, you need to use the configuration (true/false) : assign [class=\"Leafpad\"] floating enable" "false"
  answer_text_fr "What is the code to have the script '/this/script.sh' starting when i3 is launching ?" "exec /this/script.sh"
  answer_text_fr "What is the keyword responsible for the creation of new key bindings in the i3 configuration file ?" "bindsym"
  answer_text_fr "What is the code you need to add to have for the shortcut 'Alt + o' to execute the script '/this/script.sh' ?" "bindsym mod1+o exec /this/script"
  answer_text_fr "Justumen likes i3wm. (true/false)" "true"
  
  if [ -x "$(command -v feh)" ]; then
	  wget "https://github.com/justUmen/WallpaperGenerator/raw/master/Wallpaper/en/i3wm_1/`xrandr | grep ' connected' | sed 's/.*primary //' | sed 's/+.*//'`.jpg" -O ~/.GameScript/i3wm_1_wallpaper.jpg &>/dev/null
	  feh --bg-scale ~/.GameScript/i3wm_1_wallpaper.jpg

	  echo -e "I just changed your wallpaper with a cheatsheet of what we've learned in this chapter. (Command : 'feh --bg-scale ~/.GameScript/i3wm_1_wallpaper.jpg')"
	  echo -e "You can now go on an empty workspace for a quick reminder. :-)"
	  echo -e "If you want this wallpaper to be used every time you start i3, add the line : 'exec feh --bg-scale ~/.GameScript/i3wm_1_wallpaper.jpg' to your configuration file."

	  echo -e "If you can't see the wallpaper, it's probably because your screen resolution isn't supported, please contact me so I can add it to the list."
	  echo -e "To see the available resolutions, you can visit : https://github.com/justUmen/WallpaperGenerator/tree/master/Wallpaper/en/i3wm_1"
	  echo -e "To know you current screen resolution, you can use the command : 'xrandr'"
  else
	  echo -e "To see the available wallpapers, you can visit : https://github.com/justUmen/WallpaperGenerator/tree/master/Wallpaper/en/i3wm_1"
  fi
  
  unlock "i3wm" "1" "99ac" "871f"
 }


CHAPTER_NAME="i3wm"
CHAPTER_NUMBER="1"
LANGUAGE="en"
SPEAKER="m1"

LINES=249
#~ if [ "$1" == "VIDEO" ]; then
	#~ prepare_video
#~ else
	#~ if [ ! "$1" == "MUTE" ]; then
		#~ prepare_audio
	#~ fi
#~ fi

enter_chapter $CHAPTER_NAME $CHAPTER_NUMBER
