#!/bin/bash
#SOME ADDED AND CHANGE IN CLI learn_cli.sh in CLASSIC
#sudo --non-interactive for usage of sound on docker (only root can use pulseaudio problem)
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
		{ sudo --non-interactive $SOUNDPLAYER_MUSIC_QUIZ /home/umen/.GameScript/Sounds/default/Music/quiz_1.mp3 || $SOUNDPLAYER_MUSIC_QUIZ /home/umen/.GameScript/Sounds/default/Music/quiz_1.mp3; } &>/dev/null &
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
1) { echo -n 1 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Hello everyone, and welcome to the most boring subject ever."; restore=$(expr $restore + 1) ;&
2) { echo -n 2 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "I'm pretty sure you are going to hate me right away, but i decided to give you what you need and not what want."; restore=$(expr $restore + 1) ;&
3) { echo -n 3 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Skipping the basics and jumping into the exciting stuff would be a classic mistake."; restore=$(expr $restore + 1) ;&
4) { echo -n 4 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "But what am im gonna talk about here is very important and I dont think you know everything."; restore=$(expr $restore + 1) ;&
5) { echo -n 5 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Even if you think you do..."; restore=$(expr $restore + 1) ;&
6) { echo -n 6 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "I have seen a lot of people neglicting this, and ended up regreting it."; restore=$(expr $restore + 1) ;&
7) { echo -n 7 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Myself included..."; restore=$(expr $restore + 1) ;&
8) { echo -n 8 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "During your long-term relationship with your computer, you will create and control a lot of 'them' together."; restore=$(expr $restore + 1) ;&
9) { echo -n 9 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "And to bring the suspend to an end, I'm talking about : ${voc}files${reset} and ${voc}folders${reset}."; restore=$(expr $restore + 1) ;&
10) { echo -n 10 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "So in this chapter we will learn how we can create and manage them all."; restore=$(expr $restore + 1) ;&
11) { echo -n 11 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "So to summarize : There are two main types of elements that are stored and handled by your computer. : files and folders."; restore=$(expr $restore + 1) ;&
12) { echo -n 12 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Files represent the core of pretty much everything, they store the actual information or 'data'."; restore=$(expr $restore + 1) ;&
13) { echo -n 13 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "It can be whatever you want : text, image, video, pron, sound, program etc..."; restore=$(expr $restore + 1) ;&
14) { echo -n 14 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "And on the other end you have folders."; restore=$(expr $restore + 1) ;&
15) { echo -n 15 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Folders are just elements that you can use to organize your files."; restore=$(expr $restore + 1) ;&
16) { echo -n 16 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "You will sometimes see or hear the word "directory" instead of "folder"."; restore=$(expr $restore + 1) ;&
17) { echo -n 17 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "But there are no difference between these two words. Sometimes you will see one, sometimes the other."; restore=$(expr $restore + 1) ;&
18) { echo -n 18 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "The name 'folder' come from a very antique IRL object people were using to store multiple papers together."; restore=$(expr $restore + 1) ;&
19) { echo -n 19 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Before the screen was invented, text, like the sentence you are reading right now, was stored on a very thin piece of a dead tree."; restore=$(expr $restore + 1) ;&
20) { echo -n 20 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "This flattened body part was called 'paper'."; restore=$(expr $restore + 1) ;&
21) { echo -n 21 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "It's hard to imagine, but our ancestors used to murder trees, transform them into these thin flat sheets just for the purpose of storing words on the surface."; restore=$(expr $restore + 1) ;&
22) { echo -n 22 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "But that was a long time ago, well before being considered primitive and barbaric."; restore=$(expr $restore + 1) ;&
23) { echo -n 23 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Believe it or not, these papers with written text on them were called 'files'."; restore=$(expr $restore + 1) ;&
24) { echo -n 24 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Yes, exactly like the ones you have on your computer today."; restore=$(expr $restore + 1) ;&
25) { echo -n 25 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "So back to the folder. It is called a 'folder' because this paper being roughly double the size of a normal paper, you can litteraly 'fold' it and you can put several papers inside."; restore=$(expr $restore + 1) ;&
26) { echo -n 26 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "The files inside will go where the folder is going, and because of the fold at the bottom they won't fall off."; restore=$(expr $restore + 1) ;&
27) { echo -n 27 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; folder_unfold; restore=$(expr $restore + 1) ;&
28) { echo -n 28 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "I can't show you a real folder because they are of course all extinct, but I can show you this so you can visualize the concept. Here you can clearly see the fold."; restore=$(expr $restore + 1) ;&
29) { echo -n 29 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; folder_front; restore=$(expr $restore + 1) ;&
30) { echo -n 30 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "But from the side it will look like this, the part going above the rest is used for a label : the name of the folder for example."; restore=$(expr $restore + 1) ;&
31) { echo -n 31 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "The complexity of our ancestors organisation of files can get even worse than this !"; restore=$(expr $restore + 1) ;&
32) { echo -n 32 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "In this folder, you can also store another smaller folder, and in this folder you can store another folder."; restore=$(expr $restore + 1) ;&
33) { echo -n 33 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Like a russian folder system where the folders are getting smaller and smaller."; restore=$(expr $restore + 1) ;&
34) { echo -n 34 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Your computer is using the same concept !"; restore=$(expr $restore + 1) ;&
35) { echo -n 35 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "But computers dont have the limitations of the real world, because as we all know : the real world sucks and was made for suckers."; restore=$(expr $restore + 1) ;&
36) { echo -n 36 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "On a computer, unlike the real world, you can have an unlimited amount of directories inside each other."; restore=$(expr $restore + 1) ;&
37) { echo -n 37 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "So if you are NOT in control of what you are doing, it can get messy very quickly."; restore=$(expr $restore + 1) ;&
38) { echo -n 38 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "On a computer, ${voc}before${reset} creating a new file or a new directory, you need to think about 2 things :"; restore=$(expr $restore + 1) ;&
39) { echo -n 39 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "1 - A good location."; restore=$(expr $restore + 1) ;&
40) { echo -n 40 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "2 - A good name."; restore=$(expr $restore + 1) ;&
41) { echo -n 41 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "I will give you an example, and I will explain along the way all my decisions."; restore=$(expr $restore + 1) ;&
42) { echo -n 42 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Your main goal is being able to find back your files, even after a long period of time... So it's very important to find a suitable place for them."; restore=$(expr $restore + 1) ;&
43) { echo -n 43 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "If it is difficult for you to find something back on your own computer, you did it wrong. (aka : You suck.)"; restore=$(expr $restore + 1) ;&
44) { echo -n 44 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "You have to choose a methodology and stick to it."; restore=$(expr $restore + 1) ;&
45) { echo -n 45 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "If you already have some files and folder, dont be afraid to delete, or to reorganise them."; restore=$(expr $restore + 1) ;&
46) { echo -n 46 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "But the best tip i can give you to avoid wasting a lot of time, is to do it well from the start !"; restore=$(expr $restore + 1) ;&
47) { echo -n 47 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Im gonna give you the system that I'm using every day, and I invite you to use it as well... if you don't have something better."; restore=$(expr $restore + 1) ;&
48) { echo -n 48 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "In this example, I want to create and write a new shell script !"; restore=$(expr $restore + 1) ;&
49) { echo -n 49 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "If you dont know what a shell script is, its basicaly a simple text-based computer program !"; restore=$(expr $restore + 1) ;&
50) { echo -n 50 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "A text file that can do stuff if you give it to a shell like bash."; restore=$(expr $restore + 1) ;&
51) { echo -n 51 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "GameScript is itself a shell script, and yes it's just a text file being digested by bash."; restore=$(expr $restore + 1) ;&
52) { echo -n 52 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Anyway, before writing our new script, we need to create it !"; restore=$(expr $restore + 1) ;&
53) { echo -n 53 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "So first, we need to find a good location."; restore=$(expr $restore + 1) ;&
54) { echo -n 54 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Let's start on my user's directory. ( /home/justumen/ )"; restore=$(expr $restore + 1) ;&
55) { echo -n 55 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "But don't stop there and create the file '/home/justumen/script' ! It's the worst thing you can do."; restore=$(expr $restore + 1) ;&
56) { echo -n 56 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "And that's exactly what I don't want you to do."; restore=$(expr $restore + 1) ;&
57) { echo -n 57 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "This is what we will do : We will go inside a directory called "Sync". ( /home/justumen/Sync/ )"; restore=$(expr $restore + 1) ;&
58) { echo -n 58 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "This directory is the directory I am using to synchronize my files and directories accross all my machines."; restore=$(expr $restore + 1) ;&
59) { echo -n 59 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "If I'm downloading a big piece of data, a video for example, I dont want it to be in the Sync directory !"; restore=$(expr $restore + 1) ;&
60) { echo -n 60 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "It would be a waste of space and bandwidth, I'll put in "/home/justumen/Videos" or whatever else."; restore=$(expr $restore + 1) ;&
61) { echo -n 61 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "But in this case, let's say that we want to be able to use that new script on all our machines, so into the folder "Sync" we go."; restore=$(expr $restore + 1) ;&
62) { echo -n 62 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "This file will be a script, we will therefore go inside the "Script" directory. ( /home/justumen/Sync/Script/ )"; restore=$(expr $restore + 1) ;&
63) { echo -n 63 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Now I want the next directory to represent the type of the script."; restore=$(expr $restore + 1) ;&
64) { echo -n 64 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "If you just have a few scripts, I guess you can just create it right here."; restore=$(expr $restore + 1) ;&
65) { echo -n 65 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "But if the directory is already crowded, like mine currently is, you may have to organize your scripts by categories."; restore=$(expr $restore + 1) ;&
66) { echo -n 66 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "It depends on your taste and on how many files and directories you already have in there."; restore=$(expr $restore + 1) ;&
67) { echo -n 67 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Some people will organize them based on the programming language they are written in."; restore=$(expr $restore + 1) ;&
68) { echo -n 68 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "So inside their 'Script' directory, they will have directories like 'Python', 'Perl', 'Bash' etc..."; restore=$(expr $restore + 1) ;&
69) { echo -n 69 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "But personaly I'm more interested about what the script is doing, rather than the language I'm using to do it."; restore=$(expr $restore + 1) ;&
70) { echo -n 70 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "It's all about taste, there is no right or wrong way to do it.. but people organising them by languages are stupid because they are different."; restore=$(expr $restore + 1) ;&
71) { echo -n 71 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "So lets talk first about what i want our script to do, otherwise what I will say won't make any sense."; restore=$(expr $restore + 1) ;&
72) { echo -n 72 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Lets say, we want the script to make several queries to all the main search engines and return only the results that they all have in common."; restore=$(expr $restore + 1) ;&
73) { echo -n 73 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "This script will obviously have to crawl the web like a spider... on a web."; restore=$(expr $restore + 1) ;&
74) { echo -n 74 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "So if my computer is not connected to the internet, our script is totally useless."; restore=$(expr $restore + 1) ;&
75) { echo -n 75 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "And because we are smart, we already have a folder called "Web" ready for us to use. ( /home/justumen/Sync/Script/Web )"; restore=$(expr $restore + 1) ;&
76) { echo -n 76 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "If a script is in this folder, we know that it will not work offline."; restore=$(expr $restore + 1) ;&
77) { echo -n 77 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Once again... if you have a lot of stuff there : Create another directory."; restore=$(expr $restore + 1) ;&
78) { echo -n 78 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "This script is going to be 'search engine' related, so I'll go inside my "SearchEngine" folder. ( /home/justumen/Sync/Script/Web/SearchEngine )"; restore=$(expr $restore + 1) ;&
79) { echo -n 79 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "And that's it for the first step, I have finaly selected a good location for my file."; restore=$(expr $restore + 1) ;&
80) { echo -n 80 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "And because you are very smart, you probably noticed that I used some capital letters."; restore=$(expr $restore + 1) ;&
81) { echo -n 81 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Yes ! I recommend you to always use an uppercase letter for the first letter of a folder."; restore=$(expr $restore + 1) ;&
82) { echo -n 82 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "It Makes It Very Easy To see That 'Web' Is Indeed A Folder And Not A File."; restore=$(expr $restore + 1) ;&
83) { echo -n 83 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Note that on real Operating System, 'example' and 'Example' are two different names, a capital letter is just considered as a different letter."; restore=$(expr $restore + 1) ;&
84) { echo -n 84 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "When it is the case, the Operating System is called case-sensitive."; restore=$(expr $restore + 1) ;&
85) { echo -n 85 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "So if you read somehwere the sentence "the password is case-sensitive" it means that an uppercase 'A' and lowercase 'a' are considered to be different letters."; restore=$(expr $restore + 1) ;&
86) { echo -n 86 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Linux is a real Operating System, so remember : linux is case-sensitive."; restore=$(expr $restore + 1) ;&
87) { echo -n 87 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "The lame Broken Windows is for example a not real / not case-sensitive Operating System made for your grand mother to read her emails."; restore=$(expr $restore + 1) ;&
88) { echo -n 88 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "But you can also notice that this name I chose 'SearchEngine' contains two words but doesn't contain any spaces."; restore=$(expr $restore + 1) ;&
89) { echo -n 89 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "If you are using GameScript, you obviously don't want to be a basic computer user !"; restore=$(expr $restore + 1) ;&
90) { echo -n 90 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "And you are soon going to be a h4x0r one day, so you'll need to prepare to be admired for your l33t skillz."; restore=$(expr $restore + 1) ;&
91) { echo -n 91 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "So starting today, here is my advice : when you create a file or a directory, don't use any spaces in its name."; restore=$(expr $restore + 1) ;&
92) { echo -n 92 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Just never use spaces when naming or renaming a file."; restore=$(expr $restore + 1) ;&
93) { echo -n 93 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Of course, you shall not use spaces in your file's name."; restore=$(expr $restore + 1) ;&
94) { echo -n 94 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "And of course, putting spaces in names should be rewarded with a slap on the back of the head."; restore=$(expr $restore + 1) ;&
95) { echo -n 95 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "In many standards, shell included, spaces are already used to separate elements from each other."; restore=$(expr $restore + 1) ;&
96) { echo -n 96 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "If you use spaces in filenames, all the l33t commands you learned will dramaticaly fail and it will likely make you cry."; restore=$(expr $restore + 1) ;&
97) { echo -n 97 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "We will look at this later, but for now just remember : Spaces are not for you !"; restore=$(expr $restore + 1) ;&
98) { echo -n 98 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "So what should you use instead of spaces ?"; restore=$(expr $restore + 1) ;&
99) { echo -n 99 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Sometimes you need to separate two different words in your filename... And to solve this problem there is two methods."; restore=$(expr $restore + 1) ;&
100) { echo -n 100 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Some put a capital letter on the first letter of the next word, like I did with : 'SearchEngine'."; restore=$(expr $restore + 1) ;&
101) { echo -n 101 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Others would rather replace the spaces by underscores : 'Search_engine'."; restore=$(expr $restore + 1) ;&
102) { echo -n 102 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "I personnaly use the first option, a capital letter for directories : 'SearchEngine'."; restore=$(expr $restore + 1) ;&
103) { echo -n 103 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "But I use the second strategy for spaces in files : 'this_is_a_file'."; restore=$(expr $restore + 1) ;&
104) { echo -n 104 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "In our example, the element i want to create is a directory. So "SearchEngine" is what we will be using."; restore=$(expr $restore + 1) ;&
105) { echo -n 105 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "I currently only have a few scripts here, so I dont need more nested directories."; restore=$(expr $restore + 1) ;&
106) { echo -n 106 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "'/home/justumen/Sync/Script/Web/SearchEngine' : This succession of directories is called a ${voc}path${reset}."; restore=$(expr $restore + 1) ;&
107) { echo -n 107 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "So, to say what I said differently : before creating a new file, we need to find a folder with a good ${voc}path${reset} for it !"; restore=$(expr $restore + 1) ;&
108) { echo -n 108 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "And now we can finally focus on the second step, finding a good name for our file !"; restore=$(expr $restore + 1) ;&
109) { echo -n 109 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "The worst name is easy to find, something like 'file', 'this_file' or 'my_script' are indeed all very stupid choices."; restore=$(expr $restore + 1) ;&
110) { echo -n 110 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "A files and directories are uniquely identified by the combinaison of their name and their path."; restore=$(expr $restore + 1) ;&
111) { echo -n 111 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Remember, this means that two elements located in the same place can't have exactly the same name !"; restore=$(expr $restore + 1) ;&
112) { echo -n 112 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "So if you respect the rule I've talked about before and are on Linux, you can have a directory called "Example" and a file called "example" in the same place."; restore=$(expr $restore + 1) ;&
113) { echo -n 113 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "So what makes a name good ?"; restore=$(expr $restore + 1) ;&
114) { echo -n 114 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "The name need to be as short as possible but at the same time summarize the actual content of the file."; restore=$(expr $restore + 1) ;&
115) { echo -n 115 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "You should be able to understand what the file do or contains just by looking at the path of its folder and its name."; restore=$(expr $restore + 1) ;&
116) { echo -n 116 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "For example, if you need to open a script to understand what's inside : Its name is bad."; restore=$(expr $restore + 1) ;&
117) { echo -n 117 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Or its folder's path is bad."; restore=$(expr $restore + 1) ;&
118) { echo -n 118 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Or both..."; restore=$(expr $restore + 1) ;&
119) { echo -n 119 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Linux allow you to do whatever you want with your names, you dont have any obligations."; restore=$(expr $restore + 1) ;&
120) { echo -n 120 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "But you need to create your own limitations to stay effective in the long term."; restore=$(expr $restore + 1) ;&
121) { echo -n 121 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "For files you also have another trick that you can use : extensions !"; restore=$(expr $restore + 1) ;&
122) { echo -n 122 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "If a file contains some raw text about "bob", you want to call this file "bob.txt" or "bob.text""; restore=$(expr $restore + 1) ;&
123) { echo -n 123 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "For a jpeg picture of bob, you can use "bob.jpg" or "bob.jpeg"."; restore=$(expr $restore + 1) ;&
124) { echo -n 124 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "For a script you can for example use "bob.sh" or "bob.shell" or "bob.bash"."; restore=$(expr $restore + 1) ;&
125) { echo -n 125 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Once again, on linux you are free to do whatever you want. But don't abuse this freedom to do stupid things !"; restore=$(expr $restore + 1) ;&
126) { echo -n 126 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "You could for example rename the picture "bob.jpeg" into "bob.txt", but it will still be an image of bob..."; restore=$(expr $restore + 1) ;&
127) { echo -n 127 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "It will NOT 'transform' the file into a text file, it's just the same jpeg image with a stupid name."; restore=$(expr $restore + 1) ;&
128) { echo -n 128 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Like having a folder called "file.txt", it would just be very confusing."; restore=$(expr $restore + 1) ;&
129) { echo -n 129 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "I hope this is clear for everyone, just the name changed, the data and the type of data inside ${voc}doesn't${reset}."; restore=$(expr $restore + 1) ;&
130) { echo -n 130 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "So i recommend you to use extensions that match their type. .html for hypertext markup language, .js for javascript, .css for cascading stylesheet, .sh for shell scripts, and so on..."; restore=$(expr $restore + 1) ;&
131) { echo -n 131 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "So lets go back to our example : The script we want to create."; restore=$(expr $restore + 1) ;&
132) { echo -n 132 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "We already have a good path so now we want a good name."; restore=$(expr $restore + 1) ;&
133) { echo -n 133 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "In our example, based on what the script is supposed to do, a good name could be "common_results.sh"."; restore=$(expr $restore + 1) ;&
134) { echo -n 134 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "".sh" because it will be a shell script."; restore=$(expr $restore + 1) ;&
135) { echo -n 135 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen ""common_results" is not a good name by itself !!"; restore=$(expr $restore + 1) ;&
136) { echo -n 136 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "But Because of the path we have chosen, it actually is."; restore=$(expr $restore + 1) ;&
137) { echo -n 137 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Let's see the final result : "/home/justumen/Sync/Script/Web/SearchEngine/common_results.sh""; restore=$(expr $restore + 1) ;&
138) { echo -n 138 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "This line is pretty much self explanatory."; restore=$(expr $restore + 1) ;&
139) { echo -n 139 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "It will be available on all my machines, it is a script, it needs internet access, and it can give me the common results from the search engines."; restore=$(expr $restore + 1) ;&
140) { echo -n 140 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "That's it, we now need to write the script."; restore=$(expr $restore + 1) ;&
141) { echo -n 141 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Something we won't do..."; restore=$(expr $restore + 1) ;&
142) { echo -n 142 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "So to summarize, there is often more than one good answer for a problem."; restore=$(expr $restore + 1) ;&
143) { echo -n 143 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "I gave you some tips, but the way you create and manage everything is really up to you."; restore=$(expr $restore + 1) ;&
144) { echo -n 144 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "As long as you don't mind being called stupid of course."; restore=$(expr $restore + 1) ;&
145) { echo -n 145 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "But sometimes there is more than one good answer."; restore=$(expr $restore + 1) ;&
146) { echo -n 146 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Let's take an example : imagine you want to use 3 differents pictures of 3 different users inside a script."; restore=$(expr $restore + 1) ;&
147) { echo -n 147 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "A small picture, a normal picture and a big picture for let's say : rick, jerry and morty."; restore=$(expr $restore + 1) ;&
148) { echo -n 148 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "After having a good path and a good name for this script, you now need to think about how you want to store these images."; restore=$(expr $restore + 1) ;&
149) { echo -n 149 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "We can say that creating an 'Image' folder inside our script directory is a good idea !"; restore=$(expr $restore + 1) ;&
150) { echo -n 150 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "From there we have a choice, do we want to store them this way : './Image/Rick/big.jpeg' or this way : './Image/Big/rick.jpeg'."; restore=$(expr $restore + 1) ;&
151) { echo -n 151 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "There is no better answer, but it might depends on how you will use your images in your script."; restore=$(expr $restore + 1) ;&
152) { echo -n 152 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "When you organise you files and folders, the best thing to do is probably to imagine a third person going through you stuff."; restore=$(expr $restore + 1) ;&
153) { echo -n 153 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "This person should understand immediately how your system is organized."; restore=$(expr $restore + 1) ;&
154) { echo -n 154 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "I recently recovered some old files, from way back, when I was stupid."; restore=$(expr $restore + 1) ;&
155) { echo -n 155 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Most of them had names like 'example', 'lol', 'test.txt', 'image75.jpeg' and stuff like this."; restore=$(expr $restore + 1) ;&
156) { echo -n 156 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Some programs were called 'script.sh', or 'program.c' in a folder 'TMP' and similar horrible things."; restore=$(expr $restore + 1) ;&
157) { echo -n 157 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "And i had to open and read almost every file to understand what they were supposed to do."; restore=$(expr $restore + 1) ;&
158) { echo -n 158 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "It was a huge waste of time and energy !"; restore=$(expr $restore + 1) ;&
159) { echo -n 159 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "This "third person" that I was talking about, might you from the future. * mindblowing *"; restore=$(expr $restore + 1) ;&
160) { echo -n 160 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "So whatever you might end up doing, be smarter than me and dont underestimate organising your files and directories !"; restore=$(expr $restore + 1) ;&
161) { echo -n 161 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Congratulation for lasting until the end of this chapter."; restore=$(expr $restore + 1) ;&
162) { echo -n 162 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "But even if I'm already very proud of you for just being there, I can't give you any rewards before the quiz..."; restore=$(expr $restore + 1) ;&
esac
}
CLREOL=$'\x1B[K'

function folder_unfold(){
echo -e "$basic${CLREOL}$reset"
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
###Creating and using files and folders is very trivial and you shouldn't waste your time learning about it. (true / false)
###A picture is a .... ? (directory / file)
###Before creating a new element, i need to find a good : (computer / teacher / location / name )
##Folder's name
###What is the worst name for a directory : "my directory", "my_directory", "mydirectory","Mydirectory"
###What is the best name for a directory : "my directory", "my_directory", "mydirectory","Mydirectory"
###What is the name of a succession of directories like this one : "/this/is/a/stupid/example/for/a/"
###Is linux case sensitive ? (y / n)
###Is windows case sensitive ? (y / n)
###If my OS is case sensitive, can i create a file called "BOB.jpg" if i already have a file in the same directory called "bob.jpg" ?
###The file "bob.jpg" is always an image. (y/n)
###What is the best name for a shell script (program) that will list all current users : "code.sh", "my_script.sh", "list_users.txt", "list_users.sh", "users.sh", "list_users", "ListUsers", "this_shell_script_will_list_all_the_users.sh"
###Which filename is the best ? "MyFile", "Myfile" "my_file", "my file"
###Which character is used to separate directorys with other elements ?

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



#FOR WALLPAPER GENERATOR
<span style="color:red">Two main types of elements : Files and Folders</span>
<span style="color:red">files = store data</span>
<span style="color:red">folders = organize your files</span>
