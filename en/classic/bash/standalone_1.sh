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
		sudo --non-interactive $SOUNDPLAYER_MUSIC_QUIZ /home/umen/.GameScript/Sounds/default/Music/quiz_1.mp3 || $SOUNDPLAYER_MUSIC_QUIZ /home/umen/.GameScript/Sounds/default/Music/quiz_1.mp3 &>/dev/null &
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
1) { echo -n 1 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; [ -d "$HOME/House" ] && echo "Unexpected error, ${HOME}/House already exists on your system! Delete this $HOME/House folder and restart this script." && exit; restore=$(expr $restore + 1) ;&
2) { echo -n 2 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; mkdir $HOME/.GameScript_bash1 &> /dev/null; restore=$(expr $restore + 1) ;&
3) { echo -n 3 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; cd $HOME/; restore=$(expr $restore + 1) ;&
4) { echo -n 4 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "Hello everyone and welcome to the first chapter named 'bash'."; restore=$(expr $restore + 1) ;&
5) { echo -n 5 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "Before learning about our first command, we need to understand the logic behind the organisation of files and folders in Unix-like operating systems, like Linux."; restore=$(expr $restore + 1) ;&
6) { echo -n 6 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "Let's start to talk about 'directories', also known as 'folders'."; restore=$(expr $restore + 1) ;&
7) { echo -n 7 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; real_tree_1; restore=$(expr $restore + 1) ;&
8) { echo -n 8 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "You can picture the organization of files and folders as a tree."; restore=$(expr $restore + 1) ;&
9) { echo -n 9 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "In this tree, the folders are shown in sky blue."; restore=$(expr $restore + 1) ;&
10) { echo -n 10 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "At the bottom of the tree you have the symbol ${code}/${reset} which represents the ${voc}root directory${reset}."; restore=$(expr $restore + 1) ;&
11) { echo -n 11 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "It is a special folder that will contain ALL the other folders of the system."; restore=$(expr $restore + 1) ;&
12) { echo -n 12 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; real_tree_2; restore=$(expr $restore + 1) ;&
13) { echo -n 13 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "In this tree, everytime you see a new branch, it represents a new folder."; restore=$(expr $restore + 1) ;&
14) { echo -n 14 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "This passage to another branch can also be seen in their names with the appearance of an additional symbol '/'."; restore=$(expr $restore + 1) ;&
15) { echo -n 15 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "For example, ${code}/home/${reset} represent the folder 'home' in the ${voc}root directory${reset}."; restore=$(expr $restore + 1) ;&
16) { echo -n 16 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "${code}/home/user/${reset} represent the directory 'user', which is the directory 'home', which is himself in the ${voc}root directory${reset}."; restore=$(expr $restore + 1) ;&
17) { echo -n 17 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "And so on, like for example : ${code}/home/user/Images/${reset}"; restore=$(expr $restore + 1) ;&
18) { echo -n 18 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "In this case, 'Images' is in 'user', 'user' is in 'home' and 'home' is in '/'."; restore=$(expr $restore + 1) ;&
19) { echo -n 19 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "But be careful, having a '/' at the end of the last folder isn't mandatory."; restore=$(expr $restore + 1) ;&
20) { echo -n 20 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "It means that ${learn}/home/user/${reset} is equivalent to ${learn}/home/user${reset}."; restore=$(expr $restore + 1) ;&
21) { echo -n 21 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "Also, ${learn}/home/${reset} and ${learn}/home${reset} are equivalent."; restore=$(expr $restore + 1) ;&
22) { echo -n 22 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; real_tree_3; restore=$(expr $restore + 1) ;&
23) { echo -n 23 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "Now let's talk about the files, here in my tree they are in green. In my example, files are 'leaves'. They are connected to a branch, or even sometimes to the trunk itsef."; restore=$(expr $restore + 1) ;&
24) { echo -n 24 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "These files belong to a folder. But here, we have some problems: in red, we can see files that can't exist..."; restore=$(expr $restore + 1) ;&
25) { echo -n 25 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "${codeError}file1${reset} can't exist because there is already a file with the same name ${codeFile}file1${reset} in the same directory. Here the root directory (/file1)"; restore=$(expr $restore + 1) ;&
26) { echo -n 26 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "But above, ${codeFile}file1${reset} can exist because even if the file name is the same, they are not directly in the same folder."; restore=$(expr $restore + 1) ;&
27) { echo -n 27 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "The elements in a Unix-like operating system should have a unique reference : here ${learn}/file1${reset} and ${learn}/home/file1${reset} are not in conflit."; restore=$(expr $restore + 1) ;&
28) { echo -n 28 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "The file ${codeError}/home${reset} can't exist either, because there is already a folder ${code}/home/${reset} using the same name in the same place."; restore=$(expr $restore + 1) ;&
29) { echo -n 29 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "For these files to exist, we must give them different names."; restore=$(expr $restore + 1) ;&
30) { echo -n 30 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; real_tree_4; restore=$(expr $restore + 1) ;&
31) { echo -n 31 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "Here we just have to call the second file 'file2'."; restore=$(expr $restore + 1) ;&
32) { echo -n 32 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "For ${codeError}home${reset}, we need to give another name that won't be a problem like 'Home'."; restore=$(expr $restore + 1) ;&
33) { echo -n 33 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "Yes ! On Unix, uppercase letters are important. 'Home' and 'home' are two differents names."; restore=$(expr $restore + 1) ;&
34) { echo -n 34 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "When the uppercase letters are considered different from the lowercase letters, we say that the computer system is ${voc}case sensitive${reset}."; restore=$(expr $restore + 1) ;&
35) { echo -n 35 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "Indeed, Unix-like Operating Systems are ${voc}case sensitive${reset}. It means that 'home', 'Home', 'hOme', 'hoMe', 'homE', 'HoMe', 'hOmE', 'HOme', 'hoME', 'HomE', 'hOMe', 'HOME', etc... are all different and valid names !"; restore=$(expr $restore + 1) ;&
36) { echo -n 36 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; tree_1; restore=$(expr $restore + 1) ;&
37) { echo -n 37 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "It is also possible to represent the folders this way."; restore=$(expr $restore + 1) ;&
38) { echo -n 38 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; tree_2; restore=$(expr $restore + 1) ;&
39) { echo -n 39 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "And here is the same example with files. Identical to the tree above."; restore=$(expr $restore + 1) ;&
40) { echo -n 40 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; tree_3; restore=$(expr $restore + 1) ;&
41) { echo -n 41 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "But the structure can also be understood without the tree-like format."; restore=$(expr $restore + 1) ;&
42) { echo -n 42 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "If all of this isn't obvious for you now, don't worry."; restore=$(expr $restore + 1) ;&
43) { echo -n 43 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "Now that you understand the logic, with time and repetition it will soon be easy for you."; restore=$(expr $restore + 1) ;&
44) { echo -n 44 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "This kind of line, which start with the ${voc}root directory${reset} '/' is called the ${voc}absolute path${reset} of a folder or a file."; restore=$(expr $restore + 1) ;&
45) { echo -n 45 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "It represents with precision the targeted file or folder."; restore=$(expr $restore + 1) ;&
46) { echo -n 46 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "Here, it is impossible to have two identical lines."; restore=$(expr $restore + 1) ;&
47) { echo -n 47 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "This ${voc}absolute path${reset} is the most important concept of the command line."; restore=$(expr $restore + 1) ;&
48) { echo -n 48 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "Now we can see our first command !"; restore=$(expr $restore + 1) ;&
49) { echo -n 49 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "Let's start by creating a new folder with the command ${learn}mkdir${reset} (mkdir comes from ${learn}M${reset}a${learn}K${reset}e ${learn}DIR${reset}ectory)."; restore=$(expr $restore + 1) ;&
50) { echo -n 50 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "You just have to type 'mkdir', followed by a space and a name for your folder."; restore=$(expr $restore + 1) ;&
51) { echo -n 51 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk_not_press_key justumen "Now let's create the folder 'House' with : ${learn}mkdir House${reset} and confirm the command by pressing the Return key."; restore=$(expr $restore + 1) ;&
52) { echo -n 52 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; answer_run "mkdir House" justumen "Non"; restore=$(expr $restore + 1) ;&
53) { echo -n 53 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk_not_press_key justumen "Let's now display the folders and files with a simple ${learn}ls${reset} (ls comes from ${learn}L${reset}i${learn}S${reset}t)."; restore=$(expr $restore + 1) ;&
54) { echo -n 54 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; answer_run "ls" justumen "Non"; restore=$(expr $restore + 1) ;&
55) { echo -n 55 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "You should see the folder you've created."; restore=$(expr $restore + 1) ;&
56) { echo -n 56 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "Now we can go inside that folder with the command ${learn}cd${reset} (cd comes from ${learn}C${reset}hange ${learn}D${reset}irectory)."; restore=$(expr $restore + 1) ;&
57) { echo -n 57 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk_not_press_key justumen "To do that, we just have to do ${code}cd${reset}, followed by the name of folder, in our case : ${learn}cd House${reset}."; restore=$(expr $restore + 1) ;&
58) { echo -n 58 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; answer_run "cd House" justumen "Non"; restore=$(expr $restore + 1) ;&
59) { echo -n 59 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk_not_press_key justumen "Now let's display the files and folders again with a simple : ${learn}ls${reset}."; restore=$(expr $restore + 1) ;&
60) { echo -n 60 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; answer_run "ls" justumen "Non"; restore=$(expr $restore + 1) ;&
61) { echo -n 61 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "Here the directory 'House' is empty, it's normal since you've just created it."; restore=$(expr $restore + 1) ;&
62) { echo -n 62 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "But what about the ${voc}absolute path${reset} I talked about before ?"; restore=$(expr $restore + 1) ;&
63) { echo -n 63 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "In fact, a terminal is always running in a folder, and can 'move' in the system tree."; restore=$(expr $restore + 1) ;&
64) { echo -n 64 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "It's exactly what you did with the command ${learn}cd House${reset}, you moved the terminal in the folder 'House'."; restore=$(expr $restore + 1) ;&
65) { echo -n 65 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk_not_press_key justumen "To know in which directory your terminal is right now, you just have to type ${learn}pwd${reset} (pwd comes from ${learn}P${reset}rint ${learn}W${reset}orking ${learn}D${reset}irectory)."; restore=$(expr $restore + 1) ;&
66) { echo -n 66 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; answer_run "pwd" justumen "Non"; restore=$(expr $restore + 1) ;&
67) { echo -n 67 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "The result you see here is the ${voc}absolute path${reset} of the folder you are currently in."; restore=$(expr $restore + 1) ;&
68) { echo -n 68 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "This folder where you are has a special name : it's your ${voc}working directory${reset}, also called ${voc}current directory${reset}."; restore=$(expr $restore + 1) ;&
69) { echo -n 69 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "Like I said before, it is not mandatory to put a '/' for the last folder, that's why you can see here ${learn}$(pwd)${reset} without a '/' at the end."; restore=$(expr $restore + 1) ;&
70) { echo -n 70 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "So here you have 4 fundamental Unix commands : ${learn}pwd${reset}, ${learn}ls${reset}, ${learn}cd${reset} and ${learn}mkdir${reset}."; restore=$(expr $restore + 1) ;&
71) { echo -n 71 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "${learn}pwd${reset} and ${learn}ls${reset} are very safe to use, because they just display informations."; restore=$(expr $restore + 1) ;&
72) { echo -n 72 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "So don't hesitate to use them extensively, as soon as you are in a terminal."; restore=$(expr $restore + 1) ;&
73) { echo -n 73 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "${learn}pwd${reset}, to know what is your ${voc}current directory${reset}."; restore=$(expr $restore + 1) ;&
74) { echo -n 74 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "And ${learn}ls${reset}, to display the content of your ${voc}current directory${reset}."; restore=$(expr $restore + 1) ;&
75) { echo -n 75 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk_not_press_key justumen "Now let's create a new folder 'Room' in our ${voc}current directory${reset} with : ${learn}mkdir Room${reset}"; restore=$(expr $restore + 1) ;&
76) { echo -n 76 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; answer_run "mkdir Room" justumen "Non"; restore=$(expr $restore + 1) ;&
77) { echo -n 77 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk_not_press_key justumen "Let's change our ${voc}current directory${reset} with : ${learn}cd Room${reset}"; restore=$(expr $restore + 1) ;&
78) { echo -n 78 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; answer_run "cd Room" justumen "Non"; restore=$(expr $restore + 1) ;&
79) { echo -n 79 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk_not_press_key justumen "Now, try the command to display the absolute path of your ${voc}current directory${reset} !"; restore=$(expr $restore + 1) ;&
80) { echo -n 80 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; answer_run "pwd" justumen "Non"; restore=$(expr $restore + 1) ;&
81) { echo -n 81 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk_not_press_key justumen "Awesome, now let's display the elements of your ${voc}current directory${reset} !"; restore=$(expr $restore + 1) ;&
82) { echo -n 82 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; answer_run "ls" justumen "Non"; restore=$(expr $restore + 1) ;&
83) { echo -n 83 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "Here the folder is empty, but you already understand two important commands : ${learn}pwd${reset} et ${learn}ls${reset}."; restore=$(expr $restore + 1) ;&
84) { echo -n 84 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "The commands ${learn}cd${reset} and ${learn}mkdir${reset} are more complex."; restore=$(expr $restore + 1) ;&
85) { echo -n 85 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "They need a target or a name, like for example : ${learn}mkdir Room${reset}."; restore=$(expr $restore + 1) ;&
86) { echo -n 86 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "This 'target' is called an ${voc}argument${reset} !"; restore=$(expr $restore + 1) ;&
87) { echo -n 87 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "But it's also possible to use commands with multiple ${voc}arguments${reset}."; restore=$(expr $restore + 1) ;&
88) { echo -n 88 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "You just have to part them with spaces."; restore=$(expr $restore + 1) ;&
89) { echo -n 89 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk_not_press_key justumen "Create the folders 'bed', 'closet' and 'desk' with a single command : ${learn}mkdir bed closet desk${reset}"; restore=$(expr $restore + 1) ;&
90) { echo -n 90 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; answer_run "mkdir bed closet desk" justumen "Non"; restore=$(expr $restore + 1) ;&
91) { echo -n 91 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk_not_press_key justumen "Display the elements of the ${voc}current directory${reset}."; restore=$(expr $restore + 1) ;&
92) { echo -n 92 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; answer_run "ls" justumen "Non"; restore=$(expr $restore + 1) ;&
93) { echo -n 93 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk_not_press_key justumen "Now to delete these folders, you can do : ${learn}rmdir bed closet desk${reset}. (rmdir comes from ${learn}R${reset}e${learn}M${reset}ove ${learn}DIR${reset}ectory)"; restore=$(expr $restore + 1) ;&
94) { echo -n 94 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; answer_run "rmdir bed closet desk" justumen "Non"; restore=$(expr $restore + 1) ;&
95) { echo -n 95 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "${learn}rmdir${reset} is a rather innoffensive command, because it will refuse to delete a folder if it isn't empty."; restore=$(expr $restore + 1) ;&
96) { echo -n 96 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "That can prevent accidents. If for example, you did ${learn}rmdir /home${reset} by mistake."; restore=$(expr $restore + 1) ;&
97) { echo -n 97 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "${learn}rm${reset} is the command to delete files. (rm comes from ${learn}R${reset}e${learn}M${reset}ove)"; restore=$(expr $restore + 1) ;&
98) { echo -n 98 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; touch virus0 virus1 virus2 virus3 virus4; restore=$(expr $restore + 1) ;&
99) { echo -n 99 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "Just like ${learn}mkdir${reset}, you need to give it in ${voc}argument${reset} the name of the file you want to target, for example : ${learn}rm test${reset}."; restore=$(expr $restore + 1) ;&
100) { echo -n 100 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk_not_press_key justumen "Something strange just happened... Display the content of your ${voc}working directory${reset}."; restore=$(expr $restore + 1) ;&
101) { echo -n 101 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; answer_run "ls" justumen "Non"; restore=$(expr $restore + 1) ;&
102) { echo -n 102 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk_not_press_key justumen "${code}rmdir${reset} deleted the folders successfully. But these files have nothing to do here, delete the file 'virus1' with ${learn}rm virus0${reset}"; restore=$(expr $restore + 1) ;&
103) { echo -n 103 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; answer_run "rm virus0" justumen "Non"; restore=$(expr $restore + 1) ;&
104) { echo -n 104 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk_not_press_key justumen "Display again the elements of the ${voc}current directory${reset}, to see if 'virus0' is still there."; restore=$(expr $restore + 1) ;&
105) { echo -n 105 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; answer_run "ls" justumen "Non"; restore=$(expr $restore + 1) ;&
106) { echo -n 106 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "Awesome, 'virus0' doesn't exist anymore."; restore=$(expr $restore + 1) ;&
107) { echo -n 107 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "But be careful with ${learn}rm${reset}, it is a very dangerous command and shouldn't take it lightly."; restore=$(expr $restore + 1) ;&
108) { echo -n 108 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "The files are deleted, they won't go in a recyclebin, so be careful."; restore=$(expr $restore + 1) ;&
109) { echo -n 109 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "A mistake using command line can be unforgiving."; restore=$(expr $restore + 1) ;&
110) { echo -n 110 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "A mispell or an unwanted ${voc}current directory${reset} can have severe consequences."; restore=$(expr $restore + 1) ;&
111) { echo -n 111 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "Before confirming a command, be sure of what you are doing."; restore=$(expr $restore + 1) ;&
112) { echo -n 112 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "Never hesitate to launch and relaunch ${learn}pwd${reset} and ${learn}ls${reset} to know what is your ${voc}current directory${reset} and check its content."; restore=$(expr $restore + 1) ;&
113) { echo -n 113 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "But for now we have more 'viruses' to delete. And we can remove them differently."; restore=$(expr $restore + 1) ;&
114) { echo -n 114 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "We can use their ${voc}absolute path${reset}."; restore=$(expr $restore + 1) ;&
115) { echo -n 115 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; cd ~/; restore=$(expr $restore + 1) ;&
116) { echo -n 116 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "When you did ${learn}rm virus0${reset}, you've asked for the deletion of the file 'virus0' in your ${voc}current directory${reset}."; restore=$(expr $restore + 1) ;&
117) { echo -n 117 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk_not_press_key justumen "I've just changed your current directory, display it now."; restore=$(expr $restore + 1) ;&
118) { echo -n 118 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; answer_run "pwd" justumen "Non"; restore=$(expr $restore + 1) ;&
119) { echo -n 119 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk_not_press_key justumen "Display the content of your ${voc}current directory${reset}."; restore=$(expr $restore + 1) ;&
120) { echo -n 120 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; answer_run "ls" justumen "Non"; restore=$(expr $restore + 1) ;&
121) { echo -n 121 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "The file 'virus1' still exists in the folder 'Room', but with your ${voc}current directory${reset}, you can't do ${learn}rm virus1${reset}."; restore=$(expr $restore + 1) ;&
122) { echo -n 122 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "Hopefully, you know the ${voc}absolute path${reset} of the file 'virus1' : ${learn}$HOME/House/Room/virus1${Reset}"; restore=$(expr $restore + 1) ;&
123) { echo -n 123 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "You can use its ${voc}absolute path${reset} as an argument. And this command will work regardless of your ${voc}current directory${reset} !"; restore=$(expr $restore + 1) ;&
124) { echo -n 124 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk_not_press_key justumen "Delete 'virus1' with : ${learn}rm $HOME/House/Room/virus1${reset}."; restore=$(expr $restore + 1) ;&
125) { echo -n 125 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; answer_run "rm $HOME/House/Room/virus1" justumen "Non"; restore=$(expr $restore + 1) ;&
126) { echo -n 126 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "Now, how can we check if the file was deleted ?"; restore=$(expr $restore + 1) ;&
127) { echo -n 127 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "When a command doesn't go as planned, it will display an error."; restore=$(expr $restore + 1) ;&
128) { echo -n 128 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk_not_press_key justumen "Try to delete the file 'virus1' again with its ${voc}absolute path${reset}."; restore=$(expr $restore + 1) ;&
129) { echo -n 129 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; answer_run "rm $HOME/House/Room/virus1" justumen "Non"; restore=$(expr $restore + 1) ;&
130) { echo -n 130 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "Here the command ${learn}rm${reset} is displaying an error because the file you want to delete doesn't exist."; restore=$(expr $restore + 1) ;&
131) { echo -n 131 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "We can also use the ${voc}absolute path${reset} of the folder 'Room' to display its content."; restore=$(expr $restore + 1) ;&
132) { echo -n 132 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "You already know the command ${learn}ls${reset}, to display the content of your ${voc}current directory${reset}."; restore=$(expr $restore + 1) ;&
133) { echo -n 133 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "Without ${voc}argument${reset}, with a simple ${learn}ls${reset}, the target folder will be the ${voc}current directory${reset}."; restore=$(expr $restore + 1) ;&
134) { echo -n 134 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "But it is also possible to give an ${voc}argument${reset} to ${learn}ls${reset}."; restore=$(expr $restore + 1) ;&
135) { echo -n 135 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "This ${voc}argument${reset} is the targetted folder, for example ${learn}ls /${reset} will display the content of the ${voc}root directory${reset}."; restore=$(expr $restore + 1) ;&
136) { echo -n 136 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk_not_press_key justumen "We can display the content of the folder 'Room' without having to move in this directory first, with : ${learn}ls $HOME/House/Room/${reset}."; restore=$(expr $restore + 1) ;&
137) { echo -n 137 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; answer_run "ls $HOME/House/Room/" justumen "Non"; restore=$(expr $restore + 1) ;&
138) { echo -n 138 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "Excellent, the file 'virus1' no longer exists."; restore=$(expr $restore + 1) ;&
139) { echo -n 139 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "Once again, I want to remind you that in an ${voc}absolute path${reset}, if the last character is '/', it's not mandatory."; restore=$(expr $restore + 1) ;&
140) { echo -n 140 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk_not_press_key justumen "So here the last '/' in ${learn}$HOME/House/Room/${reset} isn't mandatory. Test with this command : ${learn}ls $HOME/House/Room${reset}"; restore=$(expr $restore + 1) ;&
141) { echo -n 141 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; answer_run "ls $HOME/House/Room" justumen "Non"; restore=$(expr $restore + 1) ;&
142) { echo -n 142 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "No problem there, the result is identical for both commands : ${learn}ls $HOME/House/Room/${reset} and ${learn}ls $HOME/House/Room${reset}."; restore=$(expr $restore + 1) ;&
143) { echo -n 143 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "When you did ${learn}rm virus0${reset} for the first deletion, you used what's called the ${voc}relative path${reset}."; restore=$(expr $restore + 1) ;&
144) { echo -n 144 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "We say that this path is 'relative' because it depends on your ${voc}working directory${reset}."; restore=$(expr $restore + 1) ;&
145) { echo -n 145 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "Let's imagine two 'virus' files with ${voc}absolute path${reset} : ${learn}/virus${reset} and ${learn}/bin/virus${reset}."; restore=$(expr $restore + 1) ;&
146) { echo -n 146 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "If ${learn}pwd${reset} is displaying ${learn}$HOME${reset}. A ${learn}rm virus${reset} won't delete any of them, but would try to remove the file ${learn}$HOME/virus${reset}."; restore=$(expr $restore + 1) ;&
147) { echo -n 147 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; cd "$HOME"; restore=$(expr $restore + 1) ;&
148) { echo -n 148 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "This is why this ${voc}absolute path${reset} is very important. You can do ${learn}rm /virus${reset} or ${learn}rm /bin/virus${reset} and it will work whatever is your ${voc}current directory${reset}."; restore=$(expr $restore + 1) ;&
149) { echo -n 149 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk_not_press_key justumen "I just changed your ${voc}current directory${reset}, display it."; restore=$(expr $restore + 1) ;&
150) { echo -n 150 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; answer_run "pwd" justumen "Non"; restore=$(expr $restore + 1) ;&
151) { echo -n 151 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "To change your ${voc}current directory${reset}, you can use the command ${learn}cd${reset}."; restore=$(expr $restore + 1) ;&
152) { echo -n 152 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "To go back in the folder 'Room', you can use its ${voc}absolute path${reset} : ${learn}cd $HOME/House/Room/${reset}"; restore=$(expr $restore + 1) ;&
153) { echo -n 153 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "But you can also do the same thing using its ${voc}relative path${reset}."; restore=$(expr $restore + 1) ;&
154) { echo -n 154 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "You want to move in ${learn}$HOME/House/Room/${reset} and you already are in ${learn}$HOME${reset}."; restore=$(expr $restore + 1) ;&
155) { echo -n 155 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk_not_press_key justumen "It is therefore possible to move from where you are now with : ${learn}cd House/Room/${reset}. Go ahead, try it."; restore=$(expr $restore + 1) ;&
156) { echo -n 156 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; answer_run "cd House/Room/" justumen "Non"; restore=$(expr $restore + 1) ;&
157) { echo -n 157 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk_not_press_key justumen "Display the elements of your ${voc}working directory${reset}."; restore=$(expr $restore + 1) ;&
158) { echo -n 158 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; answer_run "ls" justumen "Non"; restore=$(expr $restore + 1) ;&
159) { echo -n 159 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk_not_press_key justumen "Here you can still se some 'virus' files. delete the file 'virus2' with its ${voc}relative path${reset}."; restore=$(expr $restore + 1) ;&
160) { echo -n 160 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; answer_run "rm virus2" justumen "Non"; restore=$(expr $restore + 1) ;&
161) { echo -n 161 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "Excellent!"; restore=$(expr $restore + 1) ;&
162) { echo -n 162 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "In the last example, we saw that ${learn}cd House/Room/${reset} is using a ${voc}relative path${reset}, but this path still contains several '/'."; restore=$(expr $restore + 1) ;&
163) { echo -n 163 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "So how can we know if a path is an ${voc}absolute path${reset} or a ${voc}relative path${reset} ?"; restore=$(expr $restore + 1) ;&
164) { echo -n 164 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "The ${voc}absolute path${reset} is in fact very easy to recognize !"; restore=$(expr $restore + 1) ;&
165) { echo -n 165 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "It always starts at the root directory, it means that the first character of an ${voc}absolute path${reset} is always a '/'."; restore=$(expr $restore + 1) ;&
166) { echo -n 166 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "There is also a very useful syntax for the ${voc}relative path${reset} : ${learn}..${reset}"; restore=$(expr $restore + 1) ;&
167) { echo -n 167 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "${learn}..${reset} represents in the tree the parent of your ${voc}current directory${reset}."; restore=$(expr $restore + 1) ;&
168) { echo -n 168 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "It is the vocabulary we will use to talk about this tree, they have child / parent relationships."; restore=$(expr $restore + 1) ;&
169) { echo -n 169 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "For example, for ${learn}/home/user/test/${reset}, the parent folder of 'test' is 'user' and the parent of 'user' is 'home'."; restore=$(expr $restore + 1) ;&
170) { echo -n 170 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "And of course 'test' is a child of 'user', and 'user' is a child of 'home'."; restore=$(expr $restore + 1) ;&
171) { echo -n 171 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "Targetting children in ${voc}argument${reset} with their ${voc}relative path${reset} is very simple, you just have to write the names of their successive parents."; restore=$(expr $restore + 1) ;&
172) { echo -n 172 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "Like for example with the command we used before : ${learn}cd House/Room/${reet}"; restore=$(expr $restore + 1) ;&
173) { echo -n 173 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "To target parents, it's a little more complicated. We have to use these ${learn}..${reset}."; restore=$(expr $restore + 1) ;&
174) { echo -n 174 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk_not_press_key justumen "Display the absolute path of you current directory."; restore=$(expr $restore + 1) ;&
175) { echo -n 175 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; answer_run "pwd" justumen "Non"; restore=$(expr $restore + 1) ;&
176) { echo -n 176 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "You already know the command to change your current directory : ${learn}cd${reset}."; restore=$(expr $restore + 1) ;&
177) { echo -n 177 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "Here we want to move in the parent folder. We are in ${learn}$HOME/House/Room/${reset} and we want to go in ${learn}$HOME/House/${reset}"; restore=$(expr $restore + 1) ;&
178) { echo -n 178 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk_not_press_key justumen "It is possible to go up one branch in the tree, or like i said before to move in the parent folder with : ${learn}cd ..${reset}"; restore=$(expr $restore + 1) ;&
179) { echo -n 179 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; answer_run "cd .." justumen "Non"; restore=$(expr $restore + 1) ;&
180) { echo -n 180 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk_not_press_key justumen "Display the absolute path of the current directory."; restore=$(expr $restore + 1) ;&
181) { echo -n 181 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; answer_run "pwd" justumen "Non"; restore=$(expr $restore + 1) ;&
182) { echo -n 182 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "I hope that the result of ${learn}pwd${reset} makes sense for you."; restore=$(expr $restore + 1) ;&
183) { echo -n 183 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk_not_press_key justumen "But we have two more viruses to get rid of, delete 'virus3' with its ${voc}relative path${reset}."; restore=$(expr $restore + 1) ;&
184) { echo -n 184 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; answer_run "rm Room/virus3" justumen "Non"; restore=$(expr $restore + 1) ;&
185) { echo -n 185 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk_not_press_key justumen "Good ! Now delete the file 'virus4' with its ${voc}absolute path${reset}."; restore=$(expr $restore + 1) ;&
186) { echo -n 186 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; answer_run "rm $HOME/House/Room/virus4" justumen "Non"; restore=$(expr $restore + 1) ;&
187) { echo -n 187 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; talk justumen "Amazing, you got it ! Try to confirm your knowledge with the quiz now."; restore=$(expr $restore + 1) ;&
188) { echo -n 188 > $HOME/.GameScript/restore_bash1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; } 2>/dev/null ; clean; restore=$(expr $restore + 1) ;&
esac
}
CLREOL=$'\x1B[K'

function real_tree_1(){
echo -e "$basic
                                              .         ;${CLREOL}
                 .              .              ;%     ;;${CLREOL}
                   ,           ,                :;%  %;${CLREOL}
                    :         ;                   :;%;'     .,${CLREOL}
           ,.        %;     %;            ;        %;'    ,;${CLREOL}
             ;       ;%;  %%;        ,     %;    ;%;    ,%'${CLREOL}
              %;       %;%;      ,  ;       %;  ;%;   ,%;'%;%;;,.${CLREOL}
               ;%;      %;        ;%;        % ;%;  ,%;'${CLREOL}
                '%;.     ;%;     %;'         ';%%;.%;'${CLREOL}
                 ':;%.    ;%%. %@;        %; ;@%;%'${CLREOL}
                    ':%;.  :;bd%;          %;@%;'${CLREOL}
                      '@%:.  :;%.         ;@@%;'${CLREOL}
                        '@%.  ';@%.      ;@@%;${CLREOL}
                          '@%%. '@%%    ;@@%;${CLREOL}
                            ;@%. :@%%  %@@%;${CLREOL}
                             %@bd%%%bd%%:;${CLREOL}
                                #@%%%%%@@;${CLREOL}
                                %@@%%%@@;${CLREOL}
                                %@@@%(o);  . '${CLREOL}
                                %@@@o%@@(.,'${CLREOL}
                            '.. %@@@o%@@;${CLREOL}
                               ')@@@o%@@;${CLREOL}
                                %@@(o)@@;${CLREOL}
                               .%@@@@%@@;${CLREOL}
                               ;%@@@@%@@;.${CLREOL}
                              ;%@@@$code / $reset$basic@@@;.${CLREOL}
                         ...;%@@@@@@@@@@@@%..${CLREOL}$reset"
#~ restore=$(expr $restore + 1)
}


function real_tree_2(){
echo -e "$basic
                                              .         ;${CLREOL}
                 .              .              ;%     ;;${CLREOL}
                   ,           ,                :;%  %;${CLREOL}
                    :         ;                   :;%;'     .,${CLREOL}
           ,.        %;     %;            ;        %;'    ,;${CLREOL}
             ;       ;%;  %%;        ,     %;    ;%;    ,%'${CLREOL}
              %;       %;%;      ,  ;       %;  ;%;   ,%;'%;%;;,.$code /home/user/Images/ $reset$basic${CLREOL}
               ;%;      %;        ;%;        % ;%;  ,%;'${CLREOL}
                '%;.     ;%;     %;'         ';%%;.%;'${CLREOL}
                 ':;%.    ;%%. %@;        %; ;@%;%'$code /home/user/ $reset$basic${CLREOL}
                    ':%;.  :;bd%;          %;@%;'${CLREOL}
                      '@%:.  :;%.         ;@@%;'${CLREOL}
                        '@%.  ';@%.      ;@@%;${CLREOL}
                          '@%%. $code /var/ $reset$basic  ;@@%;${CLREOL}
                            ;@%. :@%%  %@@%;${CLREOL}
                       $code /bin/ $reset$basic%@bd%%%bd%%:;$code /home/ $reset$basic${CLREOL}
                                #@%%%%%@@;${CLREOL}
                                %@@%%%@@;${CLREOL}
                                %@@@%(o);  . '${CLREOL}
                                %@@@o%@@(.,'${CLREOL}
                            '.. %@@@o%@@;${CLREOL}
                               ')@@@o%@@;${CLREOL}
                                %@@(o)@@;${CLREOL}
                               .%@@@@%@@;${CLREOL}
                               ;%@@@@%@@;.${CLREOL}
                              ;%@@@$code / $reset$basic@@@;.${CLREOL}
                         ...;%@@@@@@@@@@@@%..${CLREOL}$reset"
#~ restore=$(expr $restore + 1)
}


function real_tree_3(){
echo -e "$basic
                                              .         ;${CLREOL}
                 .              .              ;%     ;;${CLREOL}
                   ,           ,                :;%  %;${CLREOL}
                    :         ;                   :;%;'     .,${CLREOL}
           ,.        %;     %;            ;        %;'    ,;${CLREOL}
             ;       ;%;  %%;        ,     %;    ;%;    ,%'${CLREOL}
              %;       %;%;      ,  ;       %;  ;%;   ,%;'%;%;;,.$code /home/user/Images/ $reset$basic${CLREOL}
               ;%;      %;        ;%;        % ;%;  ,%;'${CLREOL}
                '%;.     ;%;     %;'         ';%%;.%;'${CLREOL}
                 ':;%.    ;%%. %@;        %; ;@%;%'$code /home/user/ $reset$basic${CLREOL}
                    ':%;.  :;bd%;          %;@%;'${CLREOL}
                      '@%:.  :;%.         ;@@%;'${CLREOL}
                        '@%.  ';@%.      ;@@%;$codeFile /home/file1 $reset$basic${CLREOL}
                          '@%%. $code /var/ $reset$basic  ;@@%;${CLREOL}
                            ;@%. :@%%  %@@%;${CLREOL}
                       $code /bin/ $reset$basic%@bd%%%bd%%:;$code /home/ $reset$basic${CLREOL}
                                #@%%%%%@@;${CLREOL}
                                %@@%%%@@;${CLREOL}
                                %@@@%(o);  . '${CLREOL}
                                %@@@o%@@(.,'${CLREOL}
                            '.. %@@@o%@@;${CLREOL}
                               ')@@@o%@@;$codeError /home $reset$basic${CLREOL}
                                %@@(o)@@;$codeFile /file1 $reset$basic${CLREOL}
                               .%@@@@%@@;$codeError /file1 $reset$basic${CLREOL}
                               ;%@@@@%@@;.${CLREOL}
                              ;%@@@$code / $reset$basic@@@;.${CLREOL}
                         ...;%@@@@@@@@@@@@%..${CLREOL}$reset"
#~ restore=$(expr $restore + 1)
}
function real_tree_4(){
echo -e "$basic
                                              .         ;${CLREOL}
                 .              .              ;%     ;;${CLREOL}
                   ,           ,                :;%  %;${CLREOL}
                    :         ;                   :;%;'     .,${CLREOL}
           ,.        %;     %;            ;        %;'    ,;${CLREOL}
             ;       ;%;  %%;        ,     %;    ;%;    ,%'      $codeFile /home/user/Images/linux.jpeg $reset$basic${CLREOL}
              %;       %;%;      ,  ;       %;  ;%;   ,%;'%;%;;,.$code /home/user/Images/ $reset$basic${CLREOL}
               ;%;      %;        ;%;        % ;%;  ,%;'${CLREOL}
                '%;.     ;%;     %;'         ';%%;.%;'${CLREOL}
                 ':;%.    ;%%. %@;        %; ;@%;%'$code /home/user/ $reset$basic${CLREOL}
                    ':%;.  :;bd%;          %;@%;'${CLREOL}
                      '@%:.  :;%.         ;@@%;'${CLREOL}
                        '@%.  ';@%.      ;@@%;$codeFile /home/file1 $reset$basic${CLREOL}
                          '@%%. $code /var/ $reset$basic  ;@@%;${CLREOL}
                            ;@%. :@%%  %@@%;${CLREOL}
                       $code /bin/ $reset$basic%@bd%%%bd%%:;$code /home/ $reset$basic${CLREOL}
                                #@%%%%%@@;${CLREOL}
                                %@@%%%@@;${CLREOL}
                                %@@@%(o);  . '${CLREOL}
                                %@@@o%@@(.,'${CLREOL}
                            '.. %@@@o%@@;${CLREOL}
                               ')@@@o%@@;$codeFile /Home $reset$basic${CLREOL}
                                %@@(o)@@;$codeFile /file1 $reset$basic${CLREOL}
                               .%@@@@%@@;$codeFile /file2 $reset$basic${CLREOL}
                               ;%@@@@%@@;.${CLREOL}
                              ;%@@@$code / $reset$basic@@@;.${CLREOL}
                         ...;%@@@@@@@@@@@@%..${CLREOL}$reset"
#~ restore=$(expr $restore + 1)
}

function tree_1(){
echo -e "
$code / $reset$basic
|-- $code /home/ $reset$basic
|   |-- $code /home/user/ $reset$basic
|   |   |-- $code /home/user/Pictures/ $reset$basic
|-- $code /bin/ $reset$basic
|-- $code /var/ $reset"
#~ restore=$(expr $restore + 1)
}

function tree_2(){
echo -e "
$code / $reset$basic
|-- $code /home/ $reset$basic
|   |-- $code /home/user/ $reset$basic
|   |   |-- $code /home/user/Pictures/ $reset$basic
|   |   |   |-- $codeFile /home/user/Pictures/linux.jpeg $reset$basic
|   |-- $codeFile /home/file1 $reset$basic
|   |-- $codeFile /home/file2 $reset$basic
|-- $code /bin/ $reset$basic
|-- $code /var/ $reset$basic
|-- $codeFile /file1 $reset$basic
|-- $codeFile /file2 $reset$basic
|-- $codeFile /Home $reset"
#~ restore=$(expr $restore + 1)
}

function tree_3(){
echo -e "
$code / $reset$basic
$code /home/ $reset$basic
$code /home/user/ $reset$basic
$code /home/user/Pictures/ $reset$basic
$codeFile /home/user/Pictures/linux.jpeg $reset$basic
$codeFile /home/file1 $reset$basic
$codeFile /home/file2 $reset$basic
$code /bin/ $reset$basic
$code /var/ $reset$basic
$codeFile /file1 $reset$basic
$codeFile /file2 $reset$basic
$codeFile /Home $reset"
#~ restore=$(expr $restore + 1)
}
function clean(){ #in enter_chapter
rm $HOME/.GameScript/restore_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
rm $HOME/.GameScript/restore_pwd_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null						
	rm $HOME/House/Room/virus0 2> /dev/null
	rm $HOME/House/Room/virus1 2> /dev/null
	rm $HOME/House/Room/virus2 2> /dev/null
	rm $HOME/House/Room/virus3 2> /dev/null
	rm $HOME/House/Room/virus4 2> /dev/null
	rmdir $HOME/House/Room/bed 2> /dev/null
	rmdir $HOME/House/Room/closet 2> /dev/null
	rmdir $HOME/House/Room/desk 2> /dev/null
	rmdir $HOME/House/Room/ 2> /dev/null
	rmdir $HOME/House/ 2> /dev/null
	rmdir $HOME/.GameScript_bash1 2> /dev/null
}

function start_quiz(){
  start_quiz_music
  echo ""
  echo -e "\e[15;44m Bash 'Bourne Again SHell' : Quiz Chapter 1 \e[0m"
  echo -e "- The answer should be as short as possible, a good answer adding uneeded characters will be considered as wrong."
  echo -e "Example : If the answer is 'ls'. The answers 'ls .', 'ls ./' and 'ls ././' won't work." 
  answer_text_en "Which symbol is used to represent the root directory on Linux ?" "/"
  answer_text_fr "Which command should you use to display the current directory ?" "pwd"
  answer_text_fr "Which command displays the content of the root directory ?" "ls /"
  answer_text_fr "Which command changes the current directory of the terminal with its parent ?" "cd .."
  answer_text_fr "Which command displays the content of the current directory ?" "ls"
  answer_text_fr "Which command deletes the empty folder 'test' from the current directory ?" "rmdir test"
  answer_text_fr "By which symbol does an absolute path start with ?" "/"
  answer_text_fr "The relative path of a file is often shorter than its equivalent absolute path. (true/false)" "true"
  answer_text_fr "Which command can delete the file /home/test whatever your current directory is ?" "rm /home/test"
  unlock "bash" "1" "24d8" "f016"
}


CHAPTER_NAME="bash"
CHAPTER_NUMBER="1"
LANGUAGE="en"
SPEAKER="m1"

LINES=187
#~ if [ "$1" == "VIDEO" ]; then
	#~ prepare_video
#~ else
	#~ if [ ! "$1" == "MUTE" ]; then
		#~ prepare_audio
	#~ fi
#~ fi

enter_chapter $CHAPTER_NAME $CHAPTER_NUMBER
