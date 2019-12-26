#!/bin/bash
#SOME ADDED AND CHANGE IN CLI learn_cli.sh in CLASSIC
#sudo --non-interactive for usage of sound on docker (only root can use pulseaudio problem)
shopt -s expand_aliases
source ~/.bashrc

function pause_music(){
	{ sudo kill -SIGTSTP $1 || kill -SIGTSTP $1; } &> /dev/null
}
function start_quiz_music(){
	if [[ "$MUTE" == "0" ]]; then
		MUSIC_PID=$(ps -ef|grep "$SOUNDPLAYER_MUSIC"|grep Music|grep -v quiz|awk '{print $2}'|head -n 1)
		if [[ "$MUSIC_PID" != "" ]]; then
			pause_music $MUSIC_PID
		fi
		{ sudo --non-interactive $SOUNDPLAYER_MUSIC_QUIZ /home/umen/.GameScript/Sounds/default/Music/quiz_1.mp3 || $SOUNDPLAYER_MUSIC_QUIZ /home/umen/.GameScript/Sounds/default/Music/quiz_1.mp3; } &>/dev/null &
	fi
}
function stop_quiz_music(){
	if [[ "$MUTE" == "0" ]]; then
		MUSIC_QUIZ_PID=$(ps -ef|grep "$SOUNDPLAYER_MUSIC_QUIZ"|grep quiz|awk '{print $2}'|head -n 1)
		if [[ "$MUSIC_QUIZ_PID" != "" ]]; then
			{ sudo kill $MUSIC_QUIZ_PID || kill $MUSIC_QUIZ_PID; } &> /dev/null
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
	#~ $SOUNDPLAYER "$AUDIO_LOCAL/$restore.mp3" &> /dev/null &
	{ sudo --non-interactive $SOUNDPLAYER "$AUDIO_LOCAL/$restore.mp3" || $SOUNDPLAYER "$AUDIO_LOCAL/$restore.mp3"; } &> /dev/null &
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
				how_to_leave_chapter
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
	command -v xclip &> /dev/null && echo "password$PASS" | xclip -i -selection clipboard
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
1) { echo -n 1 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; [ -d "$HOME/.GameScript_bash4" ] && echo "Unexpected error, ${HOME}/.GameScript_bash4 already exists on your system! Delete this $HOME/.GameScript_bash4 folder and restart this script." && exit; restore=$(expr $restore + 1) ;&
2) { echo -n 2 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; mkdir $HOME/.GameScript_bash4 2> /dev/null; restore=$(expr $restore + 1) ;&
3) { echo -n 3 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; cd $HOME/.GameScript_bash4; restore=$(expr $restore + 1) ;&
4) { echo -n 4 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "In the previous chapter, we saw together how to create and edit text files."; restore=$(expr $restore + 1) ;&
5) { echo -n 5 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "Here we will continue with other types of controls."; restore=$(expr $restore + 1) ;&
6) { echo -n 6 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk_not_press_key justumen "Let's start by creating a new file 'test' with as content the word 'hello'."; restore=$(expr $restore + 1) ;&
7) { echo -n 7 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; answer_run "echo hello>test" justumen "No"; restore=$(expr $restore + 1) ;&
8) { echo -n 8 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk_not_press_key justumen "Create a new folder named 'DIR'."; restore=$(expr $restore + 1) ;&
9) { echo -n 9 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; answer_run "mkdir DIR" justumen "No"; restore=$(expr $restore + 1) ;&
10) { echo -n 10 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk_not_press_key justumen "Display the elements of the current directory."; restore=$(expr $restore + 1) ;&
11) { echo -n 11 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; answer_run "ls" justumen "No"; restore=$(expr $restore + 1) ;&
12) { echo -n 12 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "To move a file you will have to use the command ${code}mv${reset}."; restore=$(expr $restore + 1) ;&
13) { echo -n 13 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "As a reminder : 'm' and 'v' are the consonants of the word 'move'."; restore=$(expr $restore + 1) ;&
14) { echo -n 14 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk_not_press_key justumen "Move this 'test' file to the DIR folder with the command: ${learn}mv test DIR${reset}"; restore=$(expr $restore + 1) ;&
15) { echo -n 15 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; answer_run "mv test DIR" justumen "No"; restore=$(expr $restore + 1) ;&
16) { echo -n 16 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk_not_press_key justumen "Display the elements of the folder 'DIR'."; restore=$(expr $restore + 1) ;&
17) { echo -n 17 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; answer_run "ls DIR" justumen "No"; restore=$(expr $restore + 1) ;&
18) { echo -n 18 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk_not_press_key justumen "Move your terminal inside the 'DIR' folder."; restore=$(expr $restore + 1) ;&
19) { echo -n 19 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; answer_run "cd DIR" justumen "No"; restore=$(expr $restore + 1) ;&
20) { echo -n 20 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk_not_press_key justumen "Display the absolute path of the current directory."; restore=$(expr $restore + 1) ;&
21) { echo -n 21 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; answer_run "pwd" justumen "No"; restore=$(expr $restore + 1) ;&
22) { echo -n 22 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk_not_press_key justumen "Display the elements of the current directory."; restore=$(expr $restore + 1) ;&
23) { echo -n 23 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; answer_run "ls" justumen "No"; restore=$(expr $restore + 1) ;&
24) { echo -n 24 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "You moved the file 'test' in the directory 'DIR' with this command: ${learn}mv test DIR${reset}"; restore=$(expr $restore + 1) ;&
25) { echo -n 25 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "In this example, our first argument is a file and the second is a folder."; restore=$(expr $restore + 1) ;&
26) { echo -n 26 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "Since the second argument is a file, the command could have been: ${learn}mv test DIR/${reset}"; restore=$(expr $restore + 1) ;&
27) { echo -n 27 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "This version is much more readable than the first."; restore=$(expr $restore + 1) ;&
28) { echo -n 28 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "But you should be careful, because ${code}mv${reset} can have either files or folders as arguments."; restore=$(expr $restore + 1) ;&
29) { echo -n 29 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "If the first argument is a file and the second is not a folder, the command will act differently : this time the first argument will be ${voc}renamed${reset}."; restore=$(expr $restore + 1) ;&
30) { echo -n 30 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "Be careful to understand your environment, you should know what are the files and folders in your current location."; restore=$(expr $restore + 1) ;&
31) { echo -n 31 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "In your current directory you still have this file 'test'."; restore=$(expr $restore + 1) ;&
32) { echo -n 32 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk_not_press_key justumen "Use this command to rename 'test' to 'test2' : ${learn}mv test test2${reset}"; restore=$(expr $restore + 1) ;&
33) { echo -n 33 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; answer_run "mv test test2" justumen "No"; restore=$(expr $restore + 1) ;&
34) { echo -n 34 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk_not_press_key justumen "Display the elements of the current directory."; restore=$(expr $restore + 1) ;&
35) { echo -n 35 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; answer_run "ls" justumen "No"; restore=$(expr $restore + 1) ;&
36) { echo -n 36 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk_not_press_key justumen "Display the contents of the file 'test2'."; restore=$(expr $restore + 1) ;&
37) { echo -n 37 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; answer_run "cat test2" justumen "No"; restore=$(expr $restore + 1) ;&
38) { echo -n 38 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "The content is always the same, only the name of the file has changed."; restore=$(expr $restore + 1) ;&
39) { echo -n 39 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk_not_press_key justumen "Now create a new folder named: 'DOS'."; restore=$(expr $restore + 1) ;&
40) { echo -n 40 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; answer_run "mkdir DOS" justumen "No"; restore=$(expr $restore + 1) ;&
41) { echo -n 41 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "I repeat, ${code}mv${reset} can have files or folders as arguments."; restore=$(expr $restore + 1) ;&
42) { echo -n 42 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "If the first argument is a folder, and the second one does not exist, then ${code}mv${reset} will just rename the folder given as the first argument."; restore=$(expr $restore + 1) ;&
43) { echo -n 43 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk_not_press_key justumen "Rename the folder 'DOS' in 'DOS2'."; restore=$(expr $restore + 1) ;&
44) { echo -n 44 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; answer_run "mv DOS DOS2" justumen "No"; restore=$(expr $restore + 1) ;&
45) { echo -n 45 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk_not_press_key justumen "And display the elements of the current directory."; restore=$(expr $restore + 1) ;&
46) { echo -n 46 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; answer_run "ls" justumen "No"; restore=$(expr $restore + 1) ;&
47) { echo -n 47 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "So be careful with the command ${code}mv${reset}, it can have two different roles : move and rename."; restore=$(expr $restore + 1) ;&
48) { echo -n 48 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "${code}mv${reset} can also do both in one command !"; restore=$(expr $restore + 1) ;&
49) { echo -n 49 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk_not_press_key justumen "Move 'test2' to the 'DOS2' folder and rename it to 'test3' with : ${learn}mv test2 DOS2 / test3${reset}"; restore=$(expr $restore + 1) ;&
50) { echo -n 50 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; answer_run "mv test2 DOS2/test3" justumen "No"; restore=$(expr $restore + 1) ;&
51) { echo -n 51 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk_not_press_key justumen "Display the elements of the DOS2 directory."; restore=$(expr $restore + 1) ;&
52) { echo -n 52 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; answer_run "ls DOS2" justumen "No"; restore=$(expr $restore + 1) ;&
53) { echo -n 53 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "The file 'test2' has been moved to DOS2 and renamed to 'test3'."; restore=$(expr $restore + 1) ;&
54) { echo -n 54 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk_not_press_key justumen "Display the content of this 'test3' file."; restore=$(expr $restore + 1) ;&
55) { echo -n 55 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; answer_run "cat DOS2/test3" justumen "No"; restore=$(expr $restore + 1) ;&
56) { echo -n 56 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "The content is obviously still the same."; restore=$(expr $restore + 1) ;&
57) { echo -n 57 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "If you try add the text 'everyone' after this file like we did before, this word will be added on a separate line."; restore=$(expr $restore + 1) ;&
58) { echo -n 58 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "Because when you use ${code}echo${reset}, it will automaticaly add a new empty line at the end."; restore=$(expr $restore + 1) ;&
59) { echo -n 59 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "If you do not want this new empty line, you will have to use the ${learn}-n${reset} option of the ${code}echo${reset} command."; restore=$(expr $restore + 1) ;&
60) { echo -n 60 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk_not_press_key justumen "Replace the contents of the file 'test3' with 'hello', but without this new empty line."; restore=$(expr $restore + 1) ;&
61) { echo -n 61 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; answer_run "echo -n hello>DOS2/test3" justumen "No"; restore=$(expr $restore + 1) ;&
62) { echo -n 62 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk_not_press_key justumen "Now add the text 'everyone' to this file 'test3', using ${learn}\"${reset}."; restore=$(expr $restore + 1) ;&
63) { echo -n 63 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; answer_run "echo \"everyone\">>DOS2/test3" justumen "No"; restore=$(expr $restore + 1) ;&
64) { echo -n 64 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk_not_press_key justumen "And finally, display the content of 'test3'."; restore=$(expr $restore + 1) ;&
65) { echo -n 65 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; answer_run "cat DOS2/test3" justumen "No"; restore=$(expr $restore + 1) ;&
66) { echo -n 66 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "And here it is : hello everyone!"; restore=$(expr $restore + 1) ;&
67) { echo -n 67 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "When a command doesn't do exactly what you want it to do, visit its manual !"; restore=$(expr $restore + 1) ;&
68) { echo -n 68 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "It is very likely that a simple option is the answer to your problem."; restore=$(expr $restore + 1) ;&
69) { echo -n 69 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "${code}mv${reset} uses two arguments, the first is ${voc}<SOURCE>${reset} and the second is ${voc}<DESTINATION>${reset}."; restore=$(expr $restore + 1) ;&
70) { echo -n 70 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "And the syntax as we have already seen is : ${code}mv <SOURCE> <DESTINATION>${reset}"; restore=$(expr $restore + 1) ;&
71) { echo -n 71 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "${voc}<SOURCE>${reset} and ${voc}<DESTINATION>${reset} should be replaced by the desired files or folders."; restore=$(expr $restore + 1) ;&
72) { echo -n 72 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "When a commands has two arguments, most of the time this logic (${code}<COMMAND> <SOURCE> <DESTINATION>${reset}) applies."; restore=$(expr $restore + 1) ;&
73) { echo -n 73 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "The first argument of the command is the ${voc}source${reset}, the second is the ${voc}destination${reset}."; restore=$(expr $restore + 1) ;&
74) { echo -n 74 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "To ${voc}copy${reset} or ${voc}duplicate${reset} a file, you will have to use the command ${code}cp${reset}."; restore=$(expr $restore + 1) ;&
75) { echo -n 75 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "Its behavior is roughly the same as ${code}mv${reset}, except that the ${voc}<SOURCE>${reset} file will not be deleted."; restore=$(expr $restore + 1) ;&
76) { echo -n 76 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk_not_press_key justumen "Display the elements of the current directory."; restore=$(expr $restore + 1) ;&
77) { echo -n 77 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; answer_run "ls" justumen "No"; restore=$(expr $restore + 1) ;&
78) { echo -n 78 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk_not_press_key justumen "Copy the file 'test3' in your current directory."; restore=$(expr $restore + 1) ;&
79) { echo -n 79 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; answer_run "cp DOS2/test3 ." justumen "No"; restore=$(expr $restore + 1) ;&
80) { echo -n 80 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "And here we have our first practical use of ${code}.${reset}, which I remind you represents the current directory."; restore=$(expr $restore + 1) ;&
81) { echo -n 81 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk_not_press_key justumen "List the elements of the current directory again."; restore=$(expr $restore + 1) ;&
82) { echo -n 82 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; answer_run "ls" justumen "No"; restore=$(expr $restore + 1) ;&
83) { echo -n 83 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "Again ${code}.${reset} being a folder, you can also use ${code}./${reset} instead."; restore=$(expr $restore + 1) ;&
84) { echo -n 84 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk_not_press_key justumen "Now test this command: ${learn}cp DOS2/test3 .new${reset}"; restore=$(expr $restore + 1) ;&
85) { echo -n 85 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; answer_run "cp DOS2/test3 .new" justumen "No"; restore=$(expr $restore + 1) ;&
86) { echo -n 86 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk_not_press_key justumen "Then list the elements of the current directory."; restore=$(expr $restore + 1) ;&
87) { echo -n 87 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; answer_run "ls" justumen "No"; restore=$(expr $restore + 1) ;&
88) { echo -n 88 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "This result shouldn't be strange for you."; restore=$(expr $restore + 1) ;&
89) { echo -n 89 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "Again, ${code}.new${reset} and ${code}./new${reset} represent two different things."; restore=$(expr $restore + 1) ;&
90) { echo -n 90 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "${code}.new${reset} is obviously a hidden file, because it starts with a dot."; restore=$(expr $restore + 1) ;&
91) { echo -n 91 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk_not_press_key justumen "List the hidden files in the current directory to find it."; restore=$(expr $restore + 1) ;&
92) { echo -n 92 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; answer_run "ls -a" justumen "No"; restore=$(expr $restore + 1) ;&
93) { echo -n 93 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "If you want to copy the file 'test3' and rename this copy to 'new' in the current directory, the command would be: ${learn}cp DOS2/test3 ./new${reset}."; restore=$(expr $restore + 1) ;&
94) { echo -n 94 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "Here the ${learn}cp command DOS2/test3 .new${reset} is identical to ${learn}cp DOS2/test3 ./.new${reset}."; restore=$(expr $restore + 1) ;&
95) { echo -n 95 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "It is also possible to have several commands on a single line, you just have to separate them by ${code};${reset}."; restore=$(expr $restore + 1) ;&
96) { echo -n 96 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk_not_press_key justumen "Try showing 'a', then another line 'b'. With two commands and a ${code};${reset}."; restore=$(expr $restore + 1) ;&
97) { echo -n 97 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; answer_run "echo a;echo b" justumen "No"; restore=$(expr $restore + 1) ;&
98) { echo -n 98 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk_not_press_key justumen "Now, try to move to the DOS folder and create a NEW folder inside."; restore=$(expr $restore + 1) ;&
99) { echo -n 99 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; answer_run "cd DOS;mkdir NEW" justumen "No"; restore=$(expr $restore + 1) ;&
100) { echo -n 100 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk_not_press_key justumen "List the items in your current directory."; restore=$(expr $restore + 1) ;&
101) { echo -n 101 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; answer_run "ls" justumen "No"; restore=$(expr $restore + 1) ;&
102) { echo -n 102 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "With ${code};${reset}, whatever the result of the first command is, the second one will be launched."; restore=$(expr $restore + 1) ;&
103) { echo -n 103 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "Here the folder 'DOS' did not exist, however the command ${learn}mkdir NEW${reset} was started in ${code}.${reset}."; restore=$(expr $restore + 1) ;&
104) { echo -n 104 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "The ${code};${reset} gives no control over the status of previous commands."; restore=$(expr $restore + 1) ;&
105) { echo -n 105 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "But you can also create conditions before moving on to the next command."; restore=$(expr $restore + 1) ;&
106) { echo -n 106 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "If you want the second command to run only if the first command was successful, you can use ${code}&&${reset} instead of ${code};${reset}."; restore=$(expr $restore + 1) ;&
107) { echo -n 107 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk_not_press_key justumen "First remove this NEW folder, which we mistakenly created in the wrong directory."; restore=$(expr $restore + 1) ;&
108) { echo -n 108 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; answer_run "rmdir NEW" justumen "No"; restore=$(expr $restore + 1) ;&
109) { echo -n 109 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk_not_press_key justumen "Now, to create a NEW folder in DOS, try: ${learn}cd DOS&&mkdir NEW${reset}"; restore=$(expr $restore + 1) ;&
110) { echo -n 110 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; answer_run "cd DOS&&mkdir NEW" justumen "No"; restore=$(expr $restore + 1) ;&
111) { echo -n 111 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk_not_press_key justumen "List the items in your current directory."; restore=$(expr $restore + 1) ;&
112) { echo -n 112 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; answer_run "ls" justumen "No"; restore=$(expr $restore + 1) ;&
113) { echo -n 113 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "Because the command ${learn}cd DOS${reset} returned an error, ${code}&&${reset} has blocked the execution of the next command."; restore=$(expr $restore + 1) ;&
114) { echo -n 114 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "This technique is especially important if you use destructive ${voc}commands${reset}, like ${code}rm${reset}, or ${code}echo${reset} with ${code}>${ reset}."; restore=$(expr $restore + 1) ;&
115) { echo -n 115 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "If you do not take precautions, you may accidentally delete an important file !"; restore=$(expr $restore + 1) ;&
116) { echo -n 116 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "You can use ${code};${reset} and ${code}&&${reset} with all the commands you already know."; restore=$(expr $restore + 1) ;&
117) { echo -n 117 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "But there is another syntax : ${code}||${reset}, which is the opposite of ${code}&&${reset}."; restore=$(expr $restore + 1) ;&
118) { echo -n 118 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "That is, the next command will only start if the previous command fails."; restore=$(expr $restore + 1) ;&
119) { echo -n 119 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk_not_press_key justumen "Try with a typo the command: ${learn}lss||echo test${reset}"; restore=$(expr $restore + 1) ;&
120) { echo -n 120 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; answer_run "lss||echo test" justumen "No"; restore=$(expr $restore + 1) ;&
121) { echo -n 121 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk_not_press_key justumen "Try the same command, this time with ${code}&&${reset}: ${learn}lss&&echo test${reset}"; restore=$(expr $restore + 1) ;&
122) { echo -n 122 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; answer_run "lss&&echo test" justumen "No"; restore=$(expr $restore + 1) ;&
123) { echo -n 123 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "But it is also possible to have both conditions on one line."; restore=$(expr $restore + 1) ;&
124) { echo -n 124 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk_not_press_key justumen "Try this command: ${learn}cd DOS&&echo SUCCESS||echo ERROR${reset}"; restore=$(expr $restore + 1) ;&
125) { echo -n 125 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; answer_run "cd DOS&&echo SUCCESS||echo ERROR" justumen "No"; restore=$(expr $restore + 1) ;&
126) { echo -n 126 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "If you already know how to program, this command can be seen as an if/else programming condition."; restore=$(expr $restore + 1) ;&
127) { echo -n 127 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk_not_press_key justumen "Here the folder 'DOS' does not exist, so use DOS2 with this command: ${learn}cd DOS2&&ls||pwd${reset}"; restore=$(expr $restore + 1) ;&
128) { echo -n 128 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; answer_run "cd DOS2&&ls||pwd" justumen "No"; restore=$(expr $restore + 1) ;&
129) { echo -n 129 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "Because the 'DOS2' folder exists, the ${learn}pwd${reset} command will not be executed."; restore=$(expr $restore + 1) ;&
130) { echo -n 130 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; talk justumen "You are ready for the questionnaire!"; restore=$(expr $restore + 1) ;&
131) { echo -n 131 > $HOME/.GameScript/restore_bash4; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; } 2>/dev/null ; clean; restore=$(expr $restore + 1) ;&
esac
}
function clean(){ #in enter_chapter
rm $HOME/.GameScript/restore_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
rm $HOME/.GameScript/restore_pwd_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
	rm $HOME/.GameScript_bash4/test 2> /dev/null
	rm $HOME/.GameScript_bash4/DIR/.new 2> /dev/null
	rm $HOME/.GameScript_bash4/DIR/test 2> /dev/null
	rm $HOME/.GameScript_bash4/DIR/test3 2> /dev/null
	rm $HOME/.GameScript_bash4/DIR/test2 2> /dev/null
	rm $HOME/.GameScript_bash4/DIR/DOS2/test3 2> /dev/null
	rmdir $HOME/.GameScript_bash4/DIR/NEW 2> /dev/null
	rmdir $HOME/.GameScript_bash4/DIR/DOS2 2> /dev/null
	rmdir $HOME/.GameScript_bash4/DIR 2> /dev/null
	rmdir $HOME/.GameScript_bash4 2> /dev/null
}

function start_quiz(){
  start_quiz_music
  echo ""
  echo -e "\e[15;44m Bash 'Bourne Again SHell' : Quiz Chapter 4 \e[0m"
  echo -e "- The answer should be as short as possible, a good answer adding uneeded characters will be considered as wrong."
  echo -e "Example : If the answer is 'ls'. The answers 'ls .', 'ls ./' and 'ls ././' won't work."
  answer_text_fr "What is the command to move files and folders ?" "mv"
  answer_text_fr "What is the command to rename files and folders ?" "mv"
  answer_text_fr "How to rename a file called 'yes' in your current directory 'no' and move it in your parent directory ?" "mv yes ../no"
  answer_text_fr "How to copy in your current directory a file with the absolute path '/root/file' ?" "cp /root/file ."
  answer_text_fr "How to copy the hidden file '.file' in your parent directory and rename it into a non hidden file 'file' in the folder '/root' ?" "cp ../.file /root/file"
  answer_text_fr "Which symbol have to be used to separate two commands if they are on the same line ?" ";"
  answer_text_fr "How to execute the command 'rm file' only if the previous command 'cd /root' is a success ?" "cd /root&&rm file"
  answer_text_fr "How to display 'good' if the command 'cd /root' is a success, and 'bad' otherwise ?" "cd /root&&echo good||echo bad"
  unlock "bash" "4" "a9d1" "21af"
}


CHAPTER_NAME="bash"
CHAPTER_NUMBER="4"
LANGUAGE="en"
SPEAKER="m1"

LINES=130
#~ if [ "$1" == "VIDEO" ]; then
	#~ prepare_video
#~ else
	#~ if [ ! "$1" == "MUTE" ]; then
		#~ prepare_audio
	#~ fi
#~ fi

enter_chapter $CHAPTER_NAME $CHAPTER_NUMBER
