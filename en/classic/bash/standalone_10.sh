#!/bin/bash
#SOME ADDED AND CHANGE IN CLI learn_cli.sh in CLASSIC
shopt -s expand_aliases
source ~/.bashrc

function pause_music(){
	kill -SIGTSTP $1
}
function unpause_music(){
	kill -SIGCONT $1	
	QUIZ_MUSIC_PID=$(ps -f|grep "mplayer"|grep Music|grep quiz|awk '{print $2}'|head -n 1)
	if [[ "QUIZ_$MUSIC_PID" != "" ]]; then
		kill $QUIZ_MUSIC_PID
	fi
}
function start_quiz_music(){
	MUSIC_PID=$(ps -f|grep "mplayer"|grep Music|awk '{print $2}'|head -n 1)
	if [[ "$MUSIC_PID" != "" ]]; then
		pause_music $MUSIC_PID
	fi
	mplayer /home/umen/.GameScript/Sounds/$SOUND_FAMILY/Music/quiz1.mp3 &>/dev/null &
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
								start_quiz_music
								start_quiz
								;;
							2) 	clean
								start_lecture 1
								start_quiz_music
								start_quiz
								;;
							3) exit ;;
						esac
					done
				fi
#HERE ?
MUSIC_PID=$(ps -f|grep "mplayer"|grep Music|grep -v quiz|awk '{print $2}'|head -n 1)
if [[ "$MUSIC_PID" != "" ]]; then
	unpause_music $MUSIC_PID
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
1) echo -n 1 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; [ -d "$HOME/.GameScript_bash10" ] && echo "Erreur innatendu, ${HOME}/.GameScript_bash10 existe déjà sur votre système ! Supprimez ce dossier $HOME/.GameScript_bash10 et relancer ce script." && exit; restore=$(expr $restore + 1) ;&
2) echo -n 2 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; mkdir $HOME/.GameScript_bash10 2> /dev/null; restore=$(expr $restore + 1) ;&
3) echo -n 3 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; cd $HOME/.GameScript_bash10;ls /var/log/*.log|head -n 5 > ~/.GameScript_bash10/LOG;cat ~/.bashrc|grep '^[^#]*alias '>~/.GameScript_bash10/.MYALIAS;source ~/.GameScript_bash10/.MYALIAS 2> /dev/null; restore=$(expr $restore + 1) ;&
4) echo -n 4 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "In the last chapter we saw how to create and manipulate variables."; restore=$(expr $restore + 1) ;&
5) echo -n 5 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "But variables are also able to store bash commands."; restore=$(expr $restore + 1) ;&
6) echo -n 6 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen " So create a variable 'cmd' that will contain $ {code} ls -a / var $ {reset} using $ {code} '$ {reset}."; restore=$(expr $restore + 1) ;&
7) echo -n 7 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run " cmd = 'ls -a / var' " justumen " No"; restore=$(expr $restore + 1) ;&
8) echo -n 8 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen " Do now: $ {learn} cmd $ {reset}."; restore=$(expr $restore + 1) ;&
9) echo -n 9 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run " Cmd " justumen " No"; restore=$(expr $restore + 1) ;&
10) echo -n 10 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Here we have an error. Of course since 'cmd' is a $ {voc} variable $ {reset} and has never been a command."; restore=$(expr $restore + 1) ;&
11) echo -n 11 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "However, you can use this variable as a command."; restore=$(expr $restore + 1) ;&
12) echo -n 12 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen " But for that, it will use the \ $, so do: $ {learn} \ $ cmd $ {reset}."; restore=$(expr $restore + 1) ;&
13) echo -n 13 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run " \ $ cmd " justumen " No"; restore=$(expr $restore + 1) ;&
14) echo -n 14 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "But to launch GameScript just type 'gamescript' in your terminal."; restore=$(expr $restore + 1) ;&
15) echo -n 15 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "If the GameScript code was in a variable, you would have to type '\ $ gamescript'."; restore=$(expr $restore + 1) ;&
16) echo -n 16 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "So we can imagine that 'gamescript' is maybe a script that is in one of the folders of the environment variable 'PATH'."; restore=$(expr $restore + 1) ;&
17) echo -n 17 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Well not at all ... but that could have been the case."; restore=$(expr $restore + 1) ;&
18) echo -n 18 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "GameScript actually uses a $ {voc} alias $ {reset}, a specialized variable type for commands."; restore=$(expr $restore + 1) ;&
19) echo -n 19 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "A $ {voc} alias $ {reset} is not a program but simply a command or command group."; restore=$(expr $restore + 1) ;&
20) echo -n 20 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "The syntax is similar to the classical variables, it will be enough to add the key word 'alias' before the creation of the alias."; restore=$(expr $restore + 1) ;&
21) echo -n 21 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen " Let's create our first alias with: $ {learn} alias a1 = 'ls -a / var' $ {reset}."; restore=$(expr $restore + 1) ;&
22) echo -n 22 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run " alias a1 = 'ls -a / var' " justumen " No"; restore=$(expr $restore + 1) ;&
23) echo -n 23 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen " Then simply run your alias with: $ {learn} a1 $ {reset}."; restore=$(expr $restore + 1) ;&
24) echo -n 24 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run " A1 " justumen " No"; restore=$(expr $restore + 1) ;&
25) echo -n 25 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Here $ {code} a1 $ {reset} just replaces $ {code} ls -a / var $ {reset}, but you can create much more complex aliases."; restore=$(expr $restore + 1) ;&
26) echo -n 26 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen " Display a list of all your aliases by simply doing $ {learn} alias $ {reset}."; restore=$(expr $restore + 1) ;&
27) echo -n 27 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run " Alias ​​" justumen " No"; restore=$(expr $restore + 1) ;&
28) echo -n 28 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "I repeat, 'gamescript' is in your environment an alias."; restore=$(expr $restore + 1) ;&
29) echo -n 29 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen " Show only the gamescript alias with: $ {learn} alias gamescript $ {reset}."; restore=$(expr $restore + 1) ;&
30) echo -n 30 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run " alias gamescript " justumen " No"; restore=$(expr $restore + 1) ;&
31) echo -n 31 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "When you launch 'gamescript', this is the code that is actually executed."; restore=$(expr $restore + 1) ;&
32) echo -n 32 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "$ {code} wget $ {reset} downloads the latest version of GameScript and then executes it on your machine."; restore=$(expr $restore + 1) ;&
33) echo -n 33 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "The 'bash' command is exactly like the 'date' command in the previous chapter, it's actually a file."; restore=$(expr $restore + 1) ;&
34) echo -n 34 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen " To know the absolute path of this file 'bash', do: $ {learn} type bash $ {reset}."; restore=$(expr $restore + 1) ;&
35) echo -n 35 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run " bash type " justumen " No"; restore=$(expr $restore + 1) ;&
36) echo -n 36 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "You may have understood it, but 'gamescript', using just 'bash' and not '/ bin / bash', will only work if the '/ bin' folder is in your 'PATH' variable."; restore=$(expr $restore + 1) ;&
37) echo -n 37 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "The '/ bin' directory has some of the most important $ {voc} bin $ {reset} areas in your system."; restore=$(expr $restore + 1) ;&
38) echo -n 38 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Using 'bash' instead of '/ bin / bash' seems reasonable in this alias, because '/ bin' should be present in the 'PATH' environment variable of all correctly configured systems."; restore=$(expr $restore + 1) ;&
39) echo -n 39 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen " See more details on this file '/ bin / bash' with: $ {learn} wc / bin / bash $ {reset}."; restore=$(expr $restore + 1) ;&
40) echo -n 40 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run " wc / bin / bash " justumen " No"; restore=$(expr $restore + 1) ;&
41) echo -n 41 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "This file is particularly large, so I do not recommend displaying it with the command $ {code} cat $ {reset}."; restore=$(expr $restore + 1) ;&
42) echo -n 42 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "On the other hand, we can safely use our 'PAGER'."; restore=$(expr $restore + 1) ;&
43) echo -n 43 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "'PAGER' is another environment variable that defines which program will be used for file playback."; restore=$(expr $restore + 1) ;&
44) echo -n 44 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen " To know the value of 'PAGER', do: $ {learn} echo \ $ PAGER $ {reset}."; restore=$(expr $restore + 1) ;&
45) echo -n 45 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run " echo \ $ PAGER " justumen " No"; restore=$(expr $restore + 1) ;&
46) echo -n 46 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Most of the time this 'PAGER' will be the $ {code} less $ {reset} command, but it's a customizable variable, so you may have something else."; restore=$(expr $restore + 1) ;&
47) echo -n 47 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "When you visit the manual of a command, you can navigate from top to bottom with your keyboard and even your mouse."; restore=$(expr $restore + 1) ;&
48) echo -n 48 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "The $ {code} man $ {reset} command actually uses your 'PAGER'. It's the $ {code} less $ {reset} command that gives your textbooks this interactive interface."; restore=$(expr $restore + 1) ;&
49) echo -n 49 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "When you exit the manual with the 'q' key, you actually exit the interface provided by $ {code} less $ {reset}."; restore=$(expr $restore + 1) ;&
50) echo -n 50 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "And you can use the $ {code} less $ {reset} command to navigate to the file of your choice."; restore=$(expr $restore + 1) ;&
51) echo -n 51 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen " Look very quickly the contents of the file '/ bin / bash' with $ {learn} less / bin / bash $ {reset}, then quit with the key 'q'."; restore=$(expr $restore + 1) ;&
52) echo -n 52 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run " less / bin / bash " justumen " No"; restore=$(expr $restore + 1) ;&
53) echo -n 53 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Here the file is unreadable because it is actually a file $ {voc} binary $ {reset}."; restore=$(expr $restore + 1) ;&
54) echo -n 54 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "$ {code} less $ {reset} considers any open file as a text file, so what it displays here simply does not make sense."; restore=$(expr $restore + 1) ;&
55) echo -n 55 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "If 'less' is the value of your 'PAGER' environment variable, of course you could have done $ {learn} \ $ PAGER / bin / bash $ {reset}."; restore=$(expr $restore + 1) ;&
56) echo -n 56 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen " Let's now create the alias 'pager' with: $ {learn} alias pager = \ $ PAGER $ {reset}."; restore=$(expr $restore + 1) ;&
57) echo -n 57 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run " alias pager = \ $ PAGER " justumen " No"; restore=$(expr $restore + 1) ;&
58) echo -n 58 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen " Now use this new alias with '/ bin / bash', then exit with the 'q' key."; restore=$(expr $restore + 1) ;&
59) echo -n 59 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run " pager / bin / bash " justumen " No"; restore=$(expr $restore + 1) ;&
60) echo -n 60 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "So we've seen how to create and manipulate variables and aliases, but remember that these variables and aliases will only be available in the bash session you are currently using."; restore=$(expr $restore + 1) ;&
61) echo -n 61 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Now let's talk about a very particular variable: $ {code} \ $? $ {Reset}"; restore=$(expr $restore + 1) ;&
62) echo -n 62 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "$ {code} \ $? $ {reset} contains a number between 0 and 255, which is the return value of your last order. (English $ {voc} exit status $ {reset})"; restore=$(expr $restore + 1) ;&
63) echo -n 63 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen " Do: $ {learn} pwd; echo \ $? $ {Reset}"; restore=$(expr $restore + 1) ;&
64) echo -n 64 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run " pwd; echo \ $? " justumen " No"; restore=$(expr $restore + 1) ;&
65) echo -n 65 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Here the return value is 0. This means that the command has not encountered any problem."; restore=$(expr $restore + 1) ;&
66) echo -n 66 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen " Now do $ {learn} pwdd; echo \ $? $ {Reset}"; restore=$(expr $restore + 1) ;&
67) echo -n 67 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run " pwdd; echo \ $? " justumen " No"; restore=$(expr $restore + 1) ;&
68) echo -n 68 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Here the return value is 127. This means that the command $ {codeError} pwdd $ {reset} does not exist."; restore=$(expr $restore + 1) ;&
69) echo -n 69 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen " Do: $ {learn} lss; echo \ $? $ {Reset}"; restore=$(expr $restore + 1) ;&
70) echo -n 70 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run " lss; echo \ $? " justumen " No"; restore=$(expr $restore + 1) ;&
71) echo -n 71 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Here the return value is still 127. This means that the command $ {codeError} lss $ {reset} does not exist."; restore=$(expr $restore + 1) ;&
72) echo -n 72 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen " Now do: $ {learn} cat x; echo \ $? $ {Reset}"; restore=$(expr $restore + 1) ;&
73) echo -n 73 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run " cat x; echo \ $? " justumen " No"; restore=$(expr $restore + 1) ;&
74) echo -n 74 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Here the return value is not 0, which means that the command has encountered an error."; restore=$(expr $restore + 1) ;&
75) echo -n 75 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "However the value is not the same as for 'pwdd' and 'lss' because the type of error is different."; restore=$(expr $restore + 1) ;&
76) echo -n 76 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "The command $ {code} cat $ {reset} exists but it is the file given as an argument that does not exist."; restore=$(expr $restore + 1) ;&
77) echo -n 77 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "You have already used this variable $ {code} \ $? $ {Reset} without knowing it."; restore=$(expr $restore + 1) ;&
78) echo -n 78 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "$ {code} || $ {reset} and $ {code} && $ {reset} use the variable $ {code} \ $? $ {reset} to define the execution of other commands."; restore=$(expr $restore + 1) ;&
79) echo -n 79 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "$ {code} && $ {reset} will issue the next command if $ {code} \ $? $ {reset} equals 0."; restore=$(expr $restore + 1) ;&
80) echo -n 80 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "And $ {code} || $ {reset} will issue the next command if $ {code} \ $? $ {Reset} does not equal 0."; restore=$(expr $restore + 1) ;&
81) echo -n 81 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "This variable will change in value for each new command, but it can be saved in another variable."; restore=$(expr $restore + 1) ;&
82) echo -n 82 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen " Try saving the return value of $ {code} ls -O $ {reset} with: $ {learn} ls -O; VAL = \ $? $ {Reset}"; restore=$(expr $restore + 1) ;&
83) echo -n 83 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run " ls -O; VAL = \ $? " justumen " No"; restore=$(expr $restore + 1) ;&
84) echo -n 84 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen " Display the value of the variable 'VAL'."; restore=$(expr $restore + 1) ;&
85) echo -n 85 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run " echo \ $ VAL " justumen " No"; restore=$(expr $restore + 1) ;&
86) echo -n 86 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "This number is again different, because here the error comes from the use of an unknown option."; restore=$(expr $restore + 1) ;&
87) echo -n 87 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "For $ {code} alias $ {reset}, you may also be using aliases without knowing it."; restore=$(expr $restore + 1) ;&
88) echo -n 88 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "These aliases can replace a command by using the same name."; restore=$(expr $restore + 1) ;&
89) echo -n 89 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen " Do: $ {learn} type ls $ {reset}."; restore=$(expr $restore + 1) ;&
90) echo -n 90 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run " type ls " justumen " No"; restore=$(expr $restore + 1) ;&
91) echo -n 91 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Here, you probably have an alias to the command: $ {code} ls --color = auto $ {reset}."; restore=$(expr $restore + 1) ;&
92) echo -n 92 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "An alias will override the 'PATH' variable, so you should not see '/ bin / ls' here."; restore=$(expr $restore + 1) ;&
93) echo -n 93 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen " Display all the possible interpretations of the command $ {code} ls $ {reset} with: $ {learn} type -a ls $ {reset}."; restore=$(expr $restore + 1) ;&
94) echo -n 94 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run " type -a ls " justumen " No"; restore=$(expr $restore + 1) ;&
95) echo -n 95 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "If you have the alias $ {code} ls --color = auto $ {reset} in the first line and $ {code} / bin / ls $ {reset} in the second line, a simple $ {code} ls $ { reset} will actually become $ {code} / bin / ls --color = auto $ {reset}"; restore=$(expr $restore + 1) ;&
96) echo -n 96 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "To go back to the variables, do you know that they can also store the $ {voc} result $ {reset} of a command."; restore=$(expr $restore + 1) ;&
97) echo -n 97 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "It will be necessary to use the $ {code} \ $$ {reset} and the $ {code} () $ {reset}"; restore=$(expr $restore + 1) ;&
98) echo -n 98 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen " For example, to store the result of the command $ {code} pwd $ {reset} in the variable 'var', do: $ {learn} var = \ $ (pwd) $ {reset}"; restore=$(expr $restore + 1) ;&
99) echo -n 99 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run " \ var = $ (pwd) " justumen " No"; restore=$(expr $restore + 1) ;&
100) echo -n 100 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen " Now to check, do: $ {learn} echo \ $ var; pwd $ {reset}."; restore=$(expr $restore + 1) ;&
101) echo -n 101 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run " echo \ $ var; pwd " justumen " No"; restore=$(expr $restore + 1) ;&
102) echo -n 102 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "You can also do the same thing using $ {code} \ `\` $ {reset}."; restore=$(expr $restore + 1) ;&
103) echo -n 103 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen " Try for example: $ {learn} var = \ `ls /var/log/*.log\`${reset}"; restore=$(expr $restore + 1) ;&
104) echo -n 104 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run " var = \ `ls /var/log/*.log\`` No" justumen ""; restore=$(expr $restore + 1) ;&
105) echo -n 105 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen " Then display the contents of the variable 'var'."; restore=$(expr $restore + 1) ;&
106) echo -n 106 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run " echo \ $ var " justumen " No"; restore=$(expr $restore + 1) ;&
107) echo -n 107 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "You can note here that using $ {code} \ $ () $ {reset} and $ {code} `` $ {reset} replace placeholders with spaces."; restore=$(expr $restore + 1) ;&
108) echo -n 108 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "We have already seen $ {learn} cat $ {reset} to display the contents of a file, but there are two other useful commands for displaying the contents of files."; restore=$(expr $restore + 1) ;&
109) echo -n 109 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "These are $ {code} head $ {reset} and $ {code} tail $ {reset}, which display the first 10 and last 10 lines of a file, respectively."; restore=$(expr $restore + 1) ;&
110) echo -n 110 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "The variable 'var' contains a list of files, so you can use this variable as a command argument."; restore=$(expr $restore + 1) ;&
111) echo -n 111 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen " For example, display the last 10 lines of all files in the variable 'var'."; restore=$(expr $restore + 1) ;&
112) echo -n 112 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run " head \ $ var " justumen " No"; restore=$(expr $restore + 1) ;&
113) echo -n 113 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "It is also possible to retrieve the result of a command and make it a temporary variable that will not be saved."; restore=$(expr $restore + 1) ;&
114) echo -n 114 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen " For example, you can do the same without the variable 'var', with: $ {learn} head \ `ls /var/log/*.log\`${reset}"; restore=$(expr $restore + 1) ;&
115) echo -n 115 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run " head \ `ls /var/log/*.log\`` No" justumen ""; restore=$(expr $restore + 1) ;&
116) echo -n 116 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "But of course, these two commands are equivalent to: $ {learn} head /var/log/*.log${reset}"; restore=$(expr $restore + 1) ;&
117) echo -n 117 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "But imagine, for example, that you have a 'LOG' file that contains a list of the files you are interested in."; restore=$(expr $restore + 1) ;&
118) echo -n 118 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen " Display the contents of the 'LOG' file."; restore=$(expr $restore + 1) ;&
119) echo -n 119 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run " cat LOG " justumen " No"; restore=$(expr $restore + 1) ;&
120) echo -n 120 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "So you can directly use $ {code} tail $ {reset} with the contents of this file as an argument with: $ {code} tail \ $ (cat LOG) $ {reset}."; restore=$(expr $restore + 1) ;&
121) echo -n 121 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen " Try with the equivalent command: $ {learn} tail \ `cat LOG \` $ {reset}"; restore=$(expr $restore + 1) ;&
122) echo -n 122 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run " tail \ `cat LOG \` " justumen " No"; restore=$(expr $restore + 1) ;&
123) echo -n 123 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "In this situation, I remind you that line breaks are replaced by spaces."; restore=$(expr $restore + 1) ;&
124) echo -n 124 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Using this method, the contents of this file become a simple string given as an argument to the $ {code} tail $ {reset} command."; restore=$(expr $restore + 1) ;&
125) echo -n 125 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "$ {voc} Beware $ {reset} therefore filenames that contain spaces or special characters."; restore=$(expr $restore + 1) ;&
126) echo -n 126 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "If a file is named for example '/ var / log / this file.log', it will be considered by $ {code} tail $ {reset} as two different files: '/ var / log / ce' and 'file. log '."; restore=$(expr $restore + 1) ;&
127) echo -n 127 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "In general, I advise you never to $ {voc} $ {reset} put spaces in your file names, especially if these files will be handled later by another program."; restore=$(expr $restore + 1) ;&
128) echo -n 128 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "'this.log.log' can become for example 'ce_fichier.log'."; restore=$(expr $restore + 1) ;&
129) echo -n 129 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "But if 'gamescript' is an alias, how is it that you can use it in all your instances of bash?"; restore=$(expr $restore + 1) ;&
130) echo -n 130 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "The alias 'gamescript' is actually created in the main bash configuration file: $ {code} ~ / .bashrc $ {reset}"; restore=$(expr $restore + 1) ;&
131) echo -n 131 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Bash analyzes the contents of your hidden file $ {code} ~ / .bashrc $ {reset} at each launch."; restore=$(expr $restore + 1) ;&
132) echo -n 132 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen " You can find the line corresponding to 'gamescript' with: $ {learn} cat ~ / .bashrc | grep gamescript $ {reset}"; restore=$(expr $restore + 1) ;&
133) echo -n 133 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run " cat ~ / .bashrc | grep gamescript " justumen " No"; restore=$(expr $restore + 1) ;&
134) echo -n 134 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "So if you want to have aliases or permanent variables, you can simply add them to this file."; restore=$(expr $restore + 1) ;&
135) echo -n 135 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "On the other hand, do not forget that 'bash' only uses this file when opening a new session."; restore=$(expr $restore + 1) ;&
136) echo -n 136 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "That is, if your bash session was already open before editing this file, the changes will not take place."; restore=$(expr $restore + 1) ;&
137) echo -n 137 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "To validate your modifications, you will have to open a new bash session or force the replay of this configuration file with: $ {code} source ~ / .bashrc $ {reset}"; restore=$(expr $restore + 1) ;&
138) echo -n 138 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "The $ {code} source command $ {reset} can also be used to read the variables in a file and add them to the current bash session."; restore=$(expr $restore + 1) ;&
139) echo -n 139 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; echo -e 'var = test \ nvar2 = test2'> $HOME / .GameScript_bash10 / variables; restore=$(expr $restore + 1) ;&
140) echo -n 140 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen " Display the contents of the 'variables' file of your current directory."; restore=$(expr $restore + 1) ;&
141) echo -n 141 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run " cat variables " justumen " No"; restore=$(expr $restore + 1) ;&
142) echo -n 142 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen " Display the values ​​of 'var' and 'var2', separated by a space."; restore=$(expr $restore + 1) ;&
143) echo -n 143 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run " echo \ $ var \ $ var2 " justumen " No"; restore=$(expr $restore + 1) ;&
144) echo -n 144 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen " Now do: $ {learn} source variables $ {reset}"; restore=$(expr $restore + 1) ;&
145) echo -n 145 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run " source variables " justumen " No"; restore=$(expr $restore + 1) ;&
146) echo -n 146 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen " And redisplay the values ​​of 'var' and 'var2', separated by a space."; restore=$(expr $restore + 1) ;&
147) echo -n 147 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run " echo \ $ var \ $ var2 " justumen " No"; restore=$(expr $restore + 1) ;&
148) echo -n 148 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "With this example, you should better understand the effect that the $ {learn} source ~ / .bashrc $ {reset} command will have."; restore=$(expr $restore + 1) ;&
149) echo -n 149 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "$ {code} source ~ / .bashrc $ {reset} can also be written $ {code}. ~ / .bashrc $ {reset}."; restore=$(expr $restore + 1) ;&
150) echo -n 150 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "This is a syntax much less readable than the first, but you must know it because you may meet one day."; restore=$(expr $restore + 1) ;&
151) echo -n 151 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Forward for the questionnaire!"; restore=$(expr $restore + 1) ;&
152) echo -n 152 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; clean; restore=$(expr $restore + 1) ;&
esac
}
function clean(){ #in enter_chapter
rm $HOME/.GameScript/restore_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
rm $HOME/.GameScript/restore_pwd_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
	rm $HOME/.GameScript_bash10/variables 2> /dev/null
	rm $HOME/.GameScript_bash10/.MYALIAS 2> /dev/null
	rm $HOME/.GameScript_bash10/LOG 2> /dev/null
	
	
	
	rmdir $HOME/.GameScript_bash10 2> /dev/null
}

function start_quiz(){
  echo ""
  echo -e "\e[15;44m Bash 'Bourne Again SHell' : Quiz Chapter 10 \e[0m"
  echo -e "- The answer should be as short as possible, a good answer adding uneeded characters will be considered as wrong."
  echo -e "Example : If the answer is 'ls'. The answers 'ls .', 'ls ./' and 'ls ././' won't work."
  answer_text_fr "Comment afficher la commande complète de l'alias 'gamescript' ?" "alias gamescript"
  answer_text_fr "Comment afficher la liste complète de vos alias ?" "alias"
  answer_text_fr "Quel est le nom (sans le $) de la variable d'environnment utilisée par la commande man ?" "PAGER"
  answer_text_fr "Comment afficher les dix dernières lignes du fichier 'test' ?" "tail test"
  answer_text_fr "Comment affecter à la variable RET le code retour (exit status) de la dernière commande ?" "RET=$?"  
  answer_text_fr "Sans utiliser de '.', quelle commande vous permet d'ajouter les variables bash contenu dans le fichier 'VAR' dans votre session bash ?" "source VAR"
  answer_text_fr "Comment afficher les dix premières lignes du fichier 'test' ?" "head test"
  unlock "bash" "10" "aba2" "d414"
}


CHAPTER_NAME="bash"
CHAPTER_NUMBER="10"
LANGUAGE="fr"
SPEAKER="m1"

LINES=147
if [ "$1" == "VIDEO" ]; then
	prepare_video
else
	if [ ! "$1" == "MUTE" ]; then
		prepare_audio
	fi
fi

enter_chapter $CHAPTER_NAME $CHAPTER_NUMBER
