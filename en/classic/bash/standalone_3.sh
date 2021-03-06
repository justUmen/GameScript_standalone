#!/bin/bash
#SOME ADDED AND CHANGE IN CLI learn_cli.sh in CLASSIC
#sudo --non-interactive for usage of sound on docker (only root can use pulseaudio problem)
shopt -s expand_aliases
source ~/.bashrc

function pause_music(){
	#~ { sudo kill -SIGTSTP $1 || kill -SIGTSTP $1; } &> /dev/null
	kill -SIGTSTP $1 &> /dev/null
}
function start_quiz_music(){
	if [[ "$MUTE" == "0" ]]; then
		MUSIC_PID=$(ps -ef|grep "$SOUNDPLAYER_MUSIC"|grep Music|grep -v quiz|awk '{print $2}'|head -n 1)
		if [[ "$MUSIC_PID" != "" ]]; then
			pause_music $MUSIC_PID
		fi
		#~ { sudo --non-interactive $SOUNDPLAYER_MUSIC_QUIZ /home/umen/.GameScript/Sounds/default/Music/quiz_1.mp3 || $SOUNDPLAYER_MUSIC_QUIZ /home/umen/.GameScript/Sounds/default/Music/quiz_1.mp3; } &>/dev/null &
		$SOUNDPLAYER_MUSIC_QUIZ /home/umen/.GameScript/Sounds/default/Music/quiz_1.mp3 &>/dev/null &
	fi
}
function stop_quiz_music(){
	if [[ "$MUTE" == "0" ]]; then
		MUSIC_QUIZ_PID=$(ps -ef|grep "$SOUNDPLAYER_MUSIC_QUIZ"|grep quiz|awk '{print $2}'|head -n 1)
		if [[ "$MUSIC_QUIZ_PID" != "" ]]; then
			#~ { sudo kill $MUSIC_QUIZ_PID || kill $MUSIC_QUIZ_PID; } &> /dev/null
			kill $MUSIC_QUIZ_PID &> /dev/null
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
	#~ { sudo --non-interactive $SOUNDPLAYER "$AUDIO_LOCAL/$restore.mp3" || $SOUNDPLAYER "$AUDIO_LOCAL/$restore.mp3"; } &> /dev/null &
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
		fr) 
			#~ echo -e "Pour débloquer '$1 $2' sur rocketchat (https://rocket.bjornulf.org), ouvrez une conversation privée avec '@boti' et copiez/collez :\n\t\e[97;42mpassword$PASS\e[0m" ??? TMP NO MORE ROCKETCHAT...
			echo -e "Pour débloquer '$1 $2' sur discord (https://discord.gg/25eRgvD), ouvrez le channel '#mots-de-passe-boti' et copiez/collez :\n\t\e[97;42mpassword$PASS\e[0m (Mot de passe uniquement valide pour l'utilisateur : $PSEUDO - Si besoin, demandez @justumen pour faire correspondre votre pseudo Discord avec votre pseudo GameScript)"
			command -v xclip &> /dev/null && echo "Ce mot de passe a été copié automatiquement avec 'xclip'." || echo "[ Installez 'xclip' pour copier ce mot de passe automatiquement après un questionnaire. ]"
			;;
		en) #echo -e "To unlock '$1 $2' on rocketchat (https://rocket.bjornulf.org), open a private conversation with '@boti' and copy/paste :\n\t\e[97;42mpassword$PASS\e[0m"
			echo -e "To unlock '$1 $2' on discord (https://discord.gg/Dj47Tpf), open the channel '#passwords-boti' and copy/paste :\n\t\e[97;42mpassword$PASS\e[0m (Password only valid for the user : $PSEUDO - If needed, ask @justumen to change your nickname on the Discord to be the same as GameScript)"
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
1) { echo -n 1 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; [ -d "$HOME/.GameScript_bash3" ] && echo "Unexpected error, ${HOME}/.GameScript_bash3 already exists on your system! Delete this $HOME/.GameScript_bash3 folder and restart this script." && exit; restore=$(expr $restore + 1) ;&
2) { echo -n 2 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; mkdir $HOME/.GameScript_bash3 2> /dev/null; restore=$(expr $restore + 1) ;&
3) { echo -n 3 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; cd $HOME/.GameScript_bash3; restore=$(expr $restore + 1) ;&
4) { echo -n 4 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "In Chapter 2, we saw that the options can have two shapes, one short as in ${learn}ls -l${reset}, and the other long as in ${learn}ls --all${reset}."; restore=$(expr $restore + 1) ;&
5) { echo -n 5 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "If you have several options to pass to the same command, you can put them one after the other: ${learn}ls -a -w 1${reset}."; restore=$(expr $restore + 1) ;&
6) { echo -n 6 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk_not_press_key justumen "Try with this example: ${learn}ls -a -w 1${reset}"; restore=$(expr $restore + 1) ;&
7) { echo -n 7 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; answer_run "ls -a -w 1" justumen "No"; restore=$(expr $restore + 1) ;&
8) { echo -n 8 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "Of course you can use the long versions in the same way, or even mix them with short options."; restore=$(expr $restore + 1) ;&
9) { echo -n 9 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk_not_press_key justumen "Try doing the same thing with: ${learn}ls -a --width=1${reset}"; restore=$(expr $restore + 1) ;&
10) { echo -n 10 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; answer_run "ls -a --width=1" justumen "No"; restore=$(expr $restore + 1) ;&
11) { echo -n 11 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "But do not forget that the short options start with ${code}-${reset} and the long options start with ${code}--${reset}."; restore=$(expr $restore + 1) ;&
12) { echo -n 12 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "If you use short options, you can also group them with the same ${code}-${reset}."; restore=$(expr $restore + 1) ;&
13) { echo -n 13 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "For example to pass the option ${code}-a${reset} and the option ${code}-w 10${reset} to ${code}ls${reset}, you can type ${code}ls -aw 10${reset}"; restore=$(expr $restore + 1) ;&
14) { echo -n 14 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk_not_press_key justumen "Try this command: ${learn}ls -aw 10${reset}"; restore=$(expr $restore + 1) ;&
15) { echo -n 15 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; answer_run "ls -aw 10" justumen "No"; restore=$(expr $restore + 1) ;&
16) { echo -n 16 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "Be careful not to forget that there are two ${code}-${reset} before long options."; restore=$(expr $restore + 1) ;&
17) { echo -n 17 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "The ${learn}ls --all${reset} and ${learn}ls -al${reset} commands are not identical at all."; restore=$(expr $restore + 1) ;&
18) { echo -n 18 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "${learn}ls --all${reset} is identical to ${learn}ls -a${reset}."; restore=$(expr $restore + 1) ;&
19) { echo -n 19 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "But ${learn}ls -all${reset} is identical to ${learn}ls -a -l -l${reset}"; restore=$(expr $restore + 1) ;&
20) { echo -n 20 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk_not_press_key justumen "Now open the ${code}ls${reset} manual and look for the option to display its version number."; restore=$(expr $restore + 1) ;&
21) { echo -n 21 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; answer_run "man ls" justumen "No"; restore=$(expr $restore + 1) ;&
22) { echo -n 22 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk_not_press_key justumen "Display the version number of ${code}ls${reset}."; restore=$(expr $restore + 1) ;&
23) { echo -n 23 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; answer_run "ls --version" justumen "No"; restore=$(expr $restore + 1) ;&
24) { echo -n 24 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "Perfect !"; restore=$(expr $restore + 1) ;&
25) { echo -n 25 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "GameScript is currently displaying text in your device."; restore=$(expr $restore + 1) ;&
26) { echo -n 26 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "GameScript uses the same commands you are currently learning, but can you tell which one is used here to display these sentences?"; restore=$(expr $restore + 1) ;&
27) { echo -n 27 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "To display something in a terminal, you will need to use the ${code}echo${reset} command."; restore=$(expr $restore + 1) ;&
28) { echo -n 28 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "This command will simply return an echo of what you gave it as an argument."; restore=$(expr $restore + 1) ;&
29) { echo -n 29 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk_not_press_key justumen "Display the word 'hello' in your terminal with the command: ${learn}echo hello${reset}"; restore=$(expr $restore + 1) ;&
30) { echo -n 30 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; answer_run "echo hello" justumen "No"; restore=$(expr $restore + 1) ;&
31) { echo -n 31 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk_not_press_key justumen "The command ${code}echo${reset} can accept several arguments, you can test: ${learn}echo hello everyone${reset}"; restore=$(expr $restore + 1) ;&
32) { echo -n 32 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; answer_run "echo hello everyone" justumen "No"; restore=$(expr $restore + 1) ;&
33) { echo -n 33 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "Easy as pie !"; restore=$(expr $restore + 1) ;&
34) { echo -n 34 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "We've already seen that ${code}mkdir${reset} is used to create new folders."; restore=$(expr $restore + 1) ;&
35) { echo -n 35 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "But how do we create new files?"; restore=$(expr $restore + 1) ;&
36) { echo -n 36 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "Just imagine that you can use the command ${code}echo${reset}!"; restore=$(expr $restore + 1) ;&
37) { echo -n 37 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "When you use the ${code}echo${reset} command, the result will be displayed by default on your computer screen."; restore=$(expr $restore + 1) ;&
38) { echo -n 38 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "But it is also possible to ${voc}redirect${reset} this result elsewhere, for example to a text file."; restore=$(expr $restore + 1) ;&
39) { echo -n 39 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "You will need to use the ${code}>${reset} symbol. It represents a ${voc}redirection${reset} of the result."; restore=$(expr $restore + 1) ;&
40) { echo -n 40 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk_not_press_key justumen "Create the text file 'test' with the command: ${code}echo hello>test${reset}"; restore=$(expr $restore + 1) ;&
41) { echo -n 41 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; answer_run "echo hello>test" justumen "No"; restore=$(expr $restore + 1) ;&
42) { echo -n 42 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "When you use ${learn}echo hello>test${reset}, if the file 'test' does not exist, it will be created."; restore=$(expr $restore + 1) ;&
43) { echo -n 43 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk_not_press_key justumen "Display the elements of your working directory."; restore=$(expr $restore + 1) ;&
44) { echo -n 44 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; answer_run "ls" justumen "No"; restore=$(expr $restore + 1) ;&
45) { echo -n 45 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "Here you have not only created the text file 'test', but you also gave it a content."; restore=$(expr $restore + 1) ;&
46) { echo -n 46 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "In this case, the content will be the result of the command to the left of the ${code}>${reset} symbol."; restore=$(expr $restore + 1) ;&
47) { echo -n 47 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "To display the contents of this file, you will need to use the command ${code}cat${reset}."; restore=$(expr $restore + 1) ;&
48) { echo -n 48 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "Again, just give ${code}cat${reset} the argument to the name of the file, just as you would for ${code}rm${reset}."; restore=$(expr $restore + 1) ;&
49) { echo -n 49 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk_not_press_key justumen "Display the contents of the 'test' file with: ${learn}cat test${reset}"; restore=$(expr $restore + 1) ;&
50) { echo -n 50 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; answer_run "cat test" justumen "No"; restore=$(expr $restore + 1) ;&
51) { echo -n 51 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "The command ${code}cat${reset} has this name because it can be used to make a con${code}cat${reset}enation, which is basically putting chains of character end to end."; restore=$(expr $restore + 1) ;&
52) { echo -n 52 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "To concatenate, just put the files in argument one after the other."; restore=$(expr $restore + 1) ;&
53) { echo -n 53 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "It is also possible to use the same file several times."; restore=$(expr $restore + 1) ;&
54) { echo -n 54 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk_not_press_key justumen "Test the command: ${learn}cat test test${reset}"; restore=$(expr $restore + 1) ;&
55) { echo -n 55 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; answer_run "cat test test" justumen "No"; restore=$(expr $restore + 1) ;&
56) { echo -n 56 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "${code}cat test test${reset} simply displays the contents of the 'test' file twice."; restore=$(expr $restore + 1) ;&
57) { echo -n 57 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "Again: when you use ${code}>${reset}, if the file does not exist it will be created."; restore=$(expr $restore + 1) ;&
58) { echo -n 58 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "However, if the file already exists the content will be replaced."; restore=$(expr $restore + 1) ;&
59) { echo -n 59 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk_not_press_key justumen "Let's test the command: ${learn}echo goodbye>test${reset}"; restore=$(expr $restore + 1) ;&
60) { echo -n 60 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; answer_run "echo goodbye>test" justumen "No"; restore=$(expr $restore + 1) ;&
61) { echo -n 61 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk_not_press_key justumen "Now display the contents of the 'test' file."; restore=$(expr $restore + 1) ;&
62) { echo -n 62 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; answer_run "cat test" justumen "No"; restore=$(expr $restore + 1) ;&
63) { echo -n 63 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "Here the content has been replaced! The word 'hello' no longer exists."; restore=$(expr $restore + 1) ;&
64) { echo -n 64 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "Be mindful of ${code}>${reset}, because it can delete the contents of your files."; restore=$(expr $restore + 1) ;&
65) { echo -n 65 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "If you want ${voc}to add${reset} of new content to a file, you will need to use ${code}>>${reset}."; restore=$(expr $restore + 1) ;&
66) { echo -n 66 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "Likewise, if you use ${code}>>${reset}, if the file does not exist it will be created."; restore=$(expr $restore + 1) ;&
67) { echo -n 67 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "But if the file already exists, the new content will be added to the end of the file."; restore=$(expr $restore + 1) ;&
68) { echo -n 68 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk_not_press_key justumen "Test with: ${learn}echo hello>>test${reset}"; restore=$(expr $restore + 1) ;&
69) { echo -n 69 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; answer_run "echo hello>>test" justumen "No"; restore=$(expr $restore + 1) ;&
70) { echo -n 70 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk_not_press_key justumen "Then display the contents of the 'test' file."; restore=$(expr $restore + 1) ;&
71) { echo -n 71 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; answer_run "cat test" justumen "No"; restore=$(expr $restore + 1) ;&
72) { echo -n 72 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "Here the word 'hello' has been added at the end of the text file."; restore=$(expr $restore + 1) ;&
73) { echo -n 73 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "You can continue to use ${code}>>${reset} to add new content in the file."; restore=$(expr $restore + 1) ;&
74) { echo -n 74 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "But the redirects (${code}>${reset} and ${code}>>${reset}) are not limited to the command ${code}echo${reset}."; restore=$(expr $restore + 1) ;&
75) { echo -n 75 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "It can work with any command !"; restore=$(expr $restore + 1) ;&
76) { echo -n 76 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk_not_press_key justumen "For example, put the result of the ${learn}ls${reset} command at the end the 'test' file!"; restore=$(expr $restore + 1) ;&
77) { echo -n 77 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; answer_run "ls>>test" justumen "No test"; restore=$(expr $restore + 1) ;&
78) { echo -n 78 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk_not_press_key justumen "And display the file 'test'."; restore=$(expr $restore + 1) ;&
79) { echo -n 79 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; answer_run "cat test" justumen "No"; restore=$(expr $restore + 1) ;&
80) { echo -n 80 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "This is the ${voc}result${reset} of the command that will be redirected. Here ${learn}ls${reset} gives as result: 'test', because 'test' is the only element of the current directory."; restore=$(expr $restore + 1) ;&
81) { echo -n 81 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "If you want to add text, you will have to use ${code}>>${reset} in combination with the ${code}echo${reset} command."; restore=$(expr $restore + 1) ;&
82) { echo -n 82 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "If you want to add the word 'pwd' at the end of the file it will be necessary to use: ${learn}echo pwd>>test${reset}"; restore=$(expr $restore + 1) ;&
83) { echo -n 83 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk_not_press_key justumen "Add these three letters 'pwd' at the end of the 'test' file."; restore=$(expr $restore + 1) ;&
84) { echo -n 84 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; answer_run "echo pwd>>test" justumen "No"; restore=$(expr $restore + 1) ;&
85) { echo -n 85 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "So be careful not to confuse ${learn}pwd>>test${reset} with ${learn}echo pwd>>test${reset}."; restore=$(expr $restore + 1) ;&
86) { echo -n 86 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk_not_press_key justumen "Now let's add the ${voc}result${reset} of ${code}pwd${reset} at the end of the 'test' file."; restore=$(expr $restore + 1) ;&
87) { echo -n 87 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; answer_run "pwd>>test" justumen "No test"; restore=$(expr $restore + 1) ;&
88) { echo -n 88 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk_not_press_key justumen "And display the file 'test'."; restore=$(expr $restore + 1) ;&
89) { echo -n 89 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; answer_run "cat test" justumen "No"; restore=$(expr $restore + 1) ;&
90) { echo -n 90 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "Very good ! I hope the result does not surprise you."; restore=$(expr $restore + 1) ;&
91) { echo -n 91 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "Now let's go back to the ${code}echo${reset} command."; restore=$(expr $restore + 1) ;&
92) { echo -n 92 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "Some special characters are not easy to display."; restore=$(expr $restore + 1) ;&
93) { echo -n 93 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk_not_press_key justumen "Try to display the letter 'a' and the letter 'b', separated by two spaces with: ${learn}echo a  b${reset}"; restore=$(expr $restore + 1) ;&
94) { echo -n 94 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; answer_run "echo a  b" justumen "No"; restore=$(expr $restore + 1) ;&
95) { echo -n 95 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "The result is not what was expected ... There is only one space between a and b."; restore=$(expr $restore + 1) ;&
96) { echo -n 96 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "Here, ${code}echo${reset} considers that there are two arguments, the first argument 'a' and the second argument 'b'."; restore=$(expr $restore + 1) ;&
97) { echo -n 97 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "It therefore displays the two arguments separated by a space."; restore=$(expr $restore + 1) ;&
98) { echo -n 98 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "It is therefore sometimes useful to limit the number of arguments to one!"; restore=$(expr $restore + 1) ;&
99) { echo -n 99 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "But how to display this space so that the sequel is not considered as a new argument?"; restore=$(expr $restore + 1) ;&
100) { echo -n 100 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "It will be necessary to use what one calls in computer an ${voc}escape character${reset}."; restore=$(expr $restore + 1) ;&
101) { echo -n 101 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "Here it is the character ${code} \ ${reset}."; restore=$(expr $restore + 1) ;&
102) { echo -n 102 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "This escape character will affect ${voc}only${reset} the next character."; restore=$(expr $restore + 1) ;&
103) { echo -n 103 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "In our case, to represent a space with the command ${code}echo${reset} we can use ${code}\\ ${reset}."; restore=$(expr $restore + 1) ;&
104) { echo -n 104 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk_not_press_key justumen "Try this, with the escape character: ${learn}echo a \\ b${reset}"; restore=$(expr $restore + 1) ;&
105) { echo -n 105 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; answer_run "echo a \ b" justumen "No"; restore=$(expr $restore + 1) ;&
106) { echo -n 106 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "This time there are two spaces between 'a' and 'b', however there are always two arguments, the first is 'a' and the second is ' b'."; restore=$(expr $restore + 1) ;&
107) { echo -n 107 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "To have a single argument, delete this space after the 'a'."; restore=$(expr $restore + 1) ;&
108) { echo -n 108 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk_not_press_key justumen "Try with one argument: ${learn}echo a\\ b${reset}"; restore=$(expr $restore + 1) ;&
109) { echo -n 109 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; answer_run "echo a\ b" justumen "No"; restore=$(expr $restore + 1) ;&
110) { echo -n 110 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk_not_press_key justumen "Now, try to display a second space between a and b."; restore=$(expr $restore + 1) ;&
111) { echo -n 111 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; answer_run "echo a\ \ b" justumen "No"; restore=$(expr $restore + 1) ;&
112) { echo -n 112 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "This escape character is very useful for displaying characters that wouldn't show up otherwise."; restore=$(expr $restore + 1) ;&
113) { echo -n 113 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "For example, the ${learn}>${reset} symbol, which as you know, is also interpreted by your terminal as a special character."; restore=$(expr $restore + 1) ;&
114) { echo -n 114 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk_not_press_key justumen "Test this command: ${learn}echo x\\>y${reset}"; restore=$(expr $restore + 1) ;&
115) { echo -n 115 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; answer_run "echo x\>y" justumen "No"; restore=$(expr $restore + 1) ;&
116) { echo -n 116 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "Here, you can understand the ${voc} huge ${reset} difference between ${learn}echo x\>y${reset} and ${learn}echo x>y${reset} ."; restore=$(expr $restore + 1) ;&
117) { echo -n 117 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "${learn}echo x>y${reset} will create a new 'y' file with the content 'x'!"; restore=$(expr $restore + 1) ;&
118) { echo -n 118 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "${learn}echo x\\>y${reset} simply displays text in the terminal."; restore=$(expr $restore + 1) ;&
119) { echo -n 119 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "To display the symbol ${code} \ ${reset} with echo, just add it just after your escape character."; restore=$(expr $restore + 1) ;&
120) { echo -n 120 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk_not_press_key justumen "For example, try to display in your terminal: ${code}\\hello${reset}."; restore=$(expr $restore + 1) ;&
121) { echo -n 121 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; answer_run "echo \\\\hello" justumen "No"; restore=$(expr $restore + 1) ;&
122) { echo -n 122 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "In ${code} \\\\\\hello ${reset}, the first ${code} \ ${reset} is the escape character, but the second one is just the character that must be interpreted literally by your terminal."; restore=$(expr $restore + 1) ;&
123) { echo -n 123 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "To avoid having to use this ${code} \ ${reset} for each space or special characters, you can also use ${code}\"${reset}."; restore=$(expr $restore + 1) ;&
124) { echo -n 124 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "Two ${code}\"${reset} can act as a ${code}delimiter${reset} of arguments."; restore=$(expr $restore + 1) ;&
125) { echo -n 125 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "That is, ${learn}echo x\>y${reset} can be replaced by ${learn}echo \"x>y\"${reset}."; restore=$(expr $restore + 1) ;&
126) { echo -n 126 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "The content between the first ${code}\"${reset} and the second ${code}\"${reset} will be considered as a ${voc}single argument${reset} to the command ${code}echo${reset}."; restore=$(expr $restore + 1) ;&
127) { echo -n 127 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "As part of the argument, spaces will be treated and displayed as such."; restore=$(expr $restore + 1) ;&
128) { echo -n 128 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk_not_press_key justumen "Try doing: ${learn}echo \"X  X\"${reset}"; restore=$(expr $restore + 1) ;&
129) { echo -n 129 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; answer_run "echo \"X  X\"" justumen "No"; restore=$(expr $restore + 1) ;&
130) { echo -n 130 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "Here, the two spaces are displayed correctly."; restore=$(expr $restore + 1) ;&
131) { echo -n 131 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk_not_press_key justumen "You can also replace the ${code}\"${reset} by ${code}'${reset}. Do so with three spaces : ${learn}echo 'X   X'${reset}"; restore=$(expr $restore + 1) ;&
132) { echo -n 132 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; answer_run "echo 'X   X'" justumen "No"; restore=$(expr $restore + 1) ;&
133) { echo -n 133 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "If you have many ${code}'${reset} to display, I advise you to use the ${code}\"${reset} as the delimiter, and if you have lots of ${code}\"${reset} to display, I advise you to use ${code}'${reset} as the delimiter."; restore=$(expr $restore + 1) ;&
134) { echo -n 134 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "For example, even if the display is equivalent, ${learn}echo '\"Peter\" and \"Mary\"'${reset} is more readable than ${learn}echo \"\\\"Peter\\\" et \\\"Mary\\\"\"${reset}"; restore=$(expr $restore + 1) ;&
135) { echo -n 135 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "The ${voc}escape character${reset} ${code} \ ${reset} can also be used to display other special characters, such as line breaks or tabs."; restore=$(expr $restore + 1) ;&
136) { echo -n 136 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk_not_press_key justumen "Quickly look at this list in the command manual ${code}echo${reset}."; restore=$(expr $restore + 1) ;&
137) { echo -n 137 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; answer_run "man echo" justumen "No"; restore=$(expr $restore + 1) ;&
138) { echo -n 138 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "If you have read the manual correctly, you understand that it will only work if the ${code}-e${reset} option is present."; restore=$(expr $restore + 1) ;&
139) { echo -n 139 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "The letter 'n' is used with ${code} \ ${reset} to represent a new line, 'n' as ${code}n${reset} new line."; restore=$(expr $restore + 1) ;&
140) { echo -n 140 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk_not_press_key justumen "Display the letter 'a' then the letter 'b' on a new line using the ${code}'${reset} as delimiters."; restore=$(expr $restore + 1) ;&
141) { echo -n 141 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; answer_run "echo -e 'a\nb'" justumen "No"; restore=$(expr $restore + 1) ;&
142) { echo -n 142 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk_not_press_key justumen "Find the syntax for a tabulation in the ${code}echo${reset} command manual."; restore=$(expr $restore + 1) ;&
143) { echo -n 143 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; answer_run "man echo" justumen "No"; restore=$(expr $restore + 1) ;&
144) { echo -n 144 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk_not_press_key justumen "Using the ${code}'${reset}, display the letter 'a', followed by a tab, and then the letter 'b'."; restore=$(expr $restore + 1) ;&
145) { echo -n 145 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; answer_run "echo -e 'a\tb'" justumen "No"; restore=$(expr $restore + 1) ;&
146) { echo -n 146 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk_not_press_key justumen "Now instead of displaying the result in the terminal, put it in a file with named 'tab'."; restore=$(expr $restore + 1) ;&
147) { echo -n 147 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; answer_run "echo -e 'a\tb'>tab" justumen "No"; restore=$(expr $restore + 1) ;&
148) { echo -n 148 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk_not_press_key justumen "Display the contents of the 'tab' file."; restore=$(expr $restore + 1) ;&
149) { echo -n 149 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; answer_run "cat tab" justumen "No"; restore=$(expr $restore + 1) ;&
150) { echo -n 150 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk_not_press_key justumen "Now display the 'test' file with the 'tab' file in one command."; restore=$(expr $restore + 1) ;&
151) { echo -n 151 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; answer_run "cat test tab" justumen "No"; restore=$(expr $restore + 1) ;&
152) { echo -n 152 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk_not_press_key justumen "Now delete 'tab' and 'test' in one command."; restore=$(expr $restore + 1) ;&
153) { echo -n 153 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; answer_run "rm tab test" justumen "No"; restore=$(expr $restore + 1) ;&
154) { echo -n 154 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; talk justumen "Excellent! You are ready for the quiz."; restore=$(expr $restore + 1) ;&
155) { echo -n 155 > $HOME/.GameScript/restore_bash3; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; } 2>/dev/null ; clean; restore=$(expr $restore + 1) ;&
esac
}
function clean(){ #in enter_chapter
rm $HOME/.GameScript/restore_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
rm $HOME/.GameScript/restore_pwd_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
	rm $HOME/.GameScript_bash3/test 2> /dev/null
	rmdir $HOME/.GameScript_bash3 2> /dev/null
}

function start_quiz(){
  start_quiz_music
  echo ""
  echo -e "\e[15;44m Bash 'Bourne Again SHell' : Quiz Chapter 3 \e[0m"
  echo -e "- The answer should be as short as possible, a good answer adding uneeded characters will be considered as wrong."
  echo -e "Example : If the answer is 'ls'. The answers 'ls .', 'ls ./' and 'ls ././' won't work."
  answer_text_fr "What is the short version of 'ls -a -l' ?" "ls -al"
  answer_text_fr "How to add the word 'no' at the end of the file 'yes' ?" "echo no>>yes"
  answer_text_fr "How to replace the content of the file 'test' by the word 'example' ?" "echo example>test"
  answer_text_fr "How to display the content of the file 'test' ?" "cat test"
  answer_text_fr "On bash, what is the escape character ?" "\\"
  answer_text_fr "How to display in a terminal : a>b" "echo a\>b"
  answer_text_fr "Which letter need to be used after the escape character to represent a new line ?" "n"
  answer_text_fr "Display, without using the escape character the sentence : I'll be there" "echo \"I'll be there\""
  answer_text_fr "Display 3 quotation marks (\"), without using the escape character." "echo '\"\"\"'"
  unlock "bash" "3" "2452" "93a3"
}


CHAPTER_NAME="bash"
CHAPTER_NUMBER="3"
LANGUAGE="en"
SPEAKER="m1"

LINES=154
#~ if [ "$1" == "VIDEO" ]; then
	#~ prepare_video
#~ else
	#~ if [ ! "$1" == "MUTE" ]; then
		#~ prepare_audio
	#~ fi
#~ fi

enter_chapter $CHAPTER_NAME $CHAPTER_NUMBER
