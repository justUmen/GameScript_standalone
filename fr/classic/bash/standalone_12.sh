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
1) { echo -n 1 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; [ -d "$HOME/.GameScript_bash12" ] && echo "Erreur inattendue, ${HOME}/.GameScript_bash12 existe déjà sur votre système ! Supprimez ce dossier $HOME/.GameScript_bash12 et relancez ce script." && exit; restore=$(expr $restore + 1) ;&
2) { echo -n 2 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; mkdir $HOME/.GameScript_bash12 2> /dev/null; restore=$(expr $restore + 1) ;&
3) { echo -n 3 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; cd $HOME/.GameScript_bash12; restore=$(expr $restore + 1) ;&
4) { echo -n 4 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Dans le chapitre précédent nous avons vu l'utilisation des conditions en bash avec la combinaison if/then/else/fi."; restore=$(expr $restore + 1) ;&
5) { echo -n 5 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Comme dans cet exemple :"; restore=$(expr $restore + 1) ;&
6) { echo -n 6 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "if [ $X -gt 10 ];then"; restore=$(expr $restore + 1) ;&
7) { echo -n 7 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "echo plus grand que 10"; restore=$(expr $restore + 1) ;&
8) { echo -n 8 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "else"; restore=$(expr $restore + 1) ;&
9) { echo -n 9 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "if [ $X -gt 5 ];then"; restore=$(expr $restore + 1) ;&
10) { echo -n 10 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "echo entre 5 et 10"; restore=$(expr $restore + 1) ;&
11) { echo -n 11 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "fi"; restore=$(expr $restore + 1) ;&
12) { echo -n 12 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "fi"; restore=$(expr $restore + 1) ;&
13) { echo -n 13 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
14) { echo -n 14 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Mais il existe une autre syntaxe capable de combiner un else et un if : elif."; restore=$(expr $restore + 1) ;&
15) { echo -n 15 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Le code ci-dessus peut aussi s'écrire de cette maniere :"; restore=$(expr $restore + 1) ;&
16) { echo -n 16 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
17) { echo -n 17 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "if [ $X -gt 10 ];then"; restore=$(expr $restore + 1) ;&
18) { echo -n 18 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "echo plus grand que 10"; restore=$(expr $restore + 1) ;&
19) { echo -n 19 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "elif [ $X -gt 5 ];then"; restore=$(expr $restore + 1) ;&
20) { echo -n 20 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "echo entre 5 et 10"; restore=$(expr $restore + 1) ;&
21) { echo -n 21 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "fi"; restore=$(expr $restore + 1) ;&
22) { echo -n 22 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
23) { echo -n 23 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "elif est particulierement utile pour améliorer la lisibilité de votre code."; restore=$(expr $restore + 1) ;&
24) { echo -n 24 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Mais rien ne vous empeche de continuer a utiliser else avec elif si vous en avez besoin."; restore=$(expr $restore + 1) ;&
25) { echo -n 25 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
26) { echo -n 26 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "if [ $X -gt 10 ];then"; restore=$(expr $restore + 1) ;&
27) { echo -n 27 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "echo plus grand que 10"; restore=$(expr $restore + 1) ;&
28) { echo -n 28 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "elif [ $X -gt 5 ];then"; restore=$(expr $restore + 1) ;&
29) { echo -n 29 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "echo entre 5 et 10"; restore=$(expr $restore + 1) ;&
30) { echo -n 30 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "else"; restore=$(expr $restore + 1) ;&
31) { echo -n 31 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "echo inférieur ou égal a 5"; restore=$(expr $restore + 1) ;&
32) { echo -n 32 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "fi"; restore=$(expr $restore + 1) ;&
33) { echo -n 33 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
34) { echo -n 34 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Vous pouvez utilisez autant de elif que vous voulez par if, mais évidemment, il n'y a qu'un seul else par if."; restore=$(expr $restore + 1) ;&
35) { echo -n 35 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
36) { echo -n 36 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Autre chose avec les les conditions : Si elles s'impriquent simplement, comme dans cet exemple :"; restore=$(expr $restore + 1) ;&
37) { echo -n 37 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
38) { echo -n 38 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "if [ $X -ge 5 ];then"; restore=$(expr $restore + 1) ;&
39) { echo -n 39 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "if [ $X -le 10 ];then"; restore=$(expr $restore + 1) ;&
40) { echo -n 40 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "echo La valeur de X est entre 5 et 10."; restore=$(expr $restore + 1) ;&
41) { echo -n 41 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "fi"; restore=$(expr $restore + 1) ;&
42) { echo -n 42 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "fi"; restore=$(expr $restore + 1) ;&
43) { echo -n 43 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
44) { echo -n 44 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Vous pouvez utiliser le && que nous avons déja vu pour le meme effet."; restore=$(expr $restore + 1) ;&
45) { echo -n 45 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
46) { echo -n 46 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "if [ $X -ge 5 ]&&[ $X -le 10 ];then"; restore=$(expr $restore + 1) ;&
47) { echo -n 47 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "echo La valeur de X est entre 5 et 10."; restore=$(expr $restore + 1) ;&
48) { echo -n 48 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "fi"; restore=$(expr $restore + 1) ;&
49) { echo -n 49 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
50) { echo -n 50 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Ou encore le ||, mais bien évidemment le sens sera différent :"; restore=$(expr $restore + 1) ;&
51) { echo -n 51 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
52) { echo -n 52 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "if [ $X -lt 5 ]||[ $X -lt 10 ];then"; restore=$(expr $restore + 1) ;&
53) { echo -n 53 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "echo La valeur de X est inferieur 5 ou superieur a 10."; restore=$(expr $restore + 1) ;&
54) { echo -n 54 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "fi"; restore=$(expr $restore + 1) ;&
55) { echo -n 55 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
56) { echo -n 56 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Dans l'exemple ci-dessus, en utilisant ||, l'argument de if devient "true" si au moins l'une des deux conditions est "true"."; restore=$(expr $restore + 1) ;&
57) { echo -n 57 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Si les deux conditions sont "true", le resultat sera egalement "true". (Meme si dans cet exemple, cela n'est pas possible.)"; restore=$(expr $restore + 1) ;&
58) { echo -n 58 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
59) { echo -n 59 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Il est tres important pour un programmeur de bien maitriser la "table de vérité" pour manipuler les conditions."; restore=$(expr $restore + 1) ;&
60) { echo -n 60 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
61) { echo -n 61 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "false||false => false"; restore=$(expr $restore + 1) ;&
62) { echo -n 62 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "false||true => true"; restore=$(expr $restore + 1) ;&
63) { echo -n 63 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "true||false => true"; restore=$(expr $restore + 1) ;&
64) { echo -n 64 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "true||true => true"; restore=$(expr $restore + 1) ;&
65) { echo -n 65 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "false&&false => false"; restore=$(expr $restore + 1) ;&
66) { echo -n 66 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "false&&true => false"; restore=$(expr $restore + 1) ;&
67) { echo -n 67 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "true&&false => false"; restore=$(expr $restore + 1) ;&
68) { echo -n 68 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "true&&true => true"; restore=$(expr $restore + 1) ;&
69) { echo -n 69 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
70) { echo -n 70 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Vous devez connaitre ce tableau par coeur, mais vous devez aussi comprendre sa logique afin de pouvoir utiliser plus que deux comparaisons."; restore=$(expr $restore + 1) ;&
71) { echo -n 71 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Dans cette "table de vérité", || représente un OR logique et && représente un AND logique."; restore=$(expr $restore + 1) ;&
72) { echo -n 72 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
73) { echo -n 73 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk_not_press_key justumen "Par exemple, que va afficher le code suivant ?"; restore=$(expr $restore + 1) ;&
74) { echo -n 74 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
75) { echo -n 75 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "if (true||false)&&true; then"; restore=$(expr $restore + 1) ;&
76) { echo -n 76 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "echo true;"; restore=$(expr $restore + 1) ;&
77) { echo -n 77 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "else"; restore=$(expr $restore + 1) ;&
78) { echo -n 78 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "echo false;"; restore=$(expr $restore + 1) ;&
79) { echo -n 79 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "fi"; restore=$(expr $restore + 1) ;&
80) { echo -n 80 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
81) { echo -n 81 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; answer_run "true" justumen "Non"; restore=$(expr $restore + 1) ;&
82) { echo -n 82 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
83) { echo -n 83 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Les parentheses donnent ici l'ordre de priorite, il faudra donc d'abord regarder le resultat de true||false, qui est "true"."; restore=$(expr $restore + 1) ;&
84) { echo -n 84 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Et ensuite faire true&&true qui est "true"."; restore=$(expr $restore + 1) ;&
85) { echo -n 85 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
86) { echo -n 86 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk_not_press_key justumen "Autre example, que va afficher le code suivant ?"; restore=$(expr $restore + 1) ;&
87) { echo -n 87 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "if false&&(false||true); then"; restore=$(expr $restore + 1) ;&
88) { echo -n 88 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "echo true;"; restore=$(expr $restore + 1) ;&
89) { echo -n 89 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "else"; restore=$(expr $restore + 1) ;&
90) { echo -n 90 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "echo false;"; restore=$(expr $restore + 1) ;&
91) { echo -n 91 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "fi"; restore=$(expr $restore + 1) ;&
92) { echo -n 92 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
93) { echo -n 93 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; answer_run "false" justumen "Non"; restore=$(expr $restore + 1) ;&
94) { echo -n 94 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
95) { echo -n 95 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk_not_press_key justumen "Qu'en est-il de ce code, que va-t-il afficher ?"; restore=$(expr $restore + 1) ;&
96) { echo -n 96 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
97) { echo -n 97 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "if [ false ]; then"; restore=$(expr $restore + 1) ;&
98) { echo -n 98 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "echo a;"; restore=$(expr $restore + 1) ;&
99) { echo -n 99 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "else"; restore=$(expr $restore + 1) ;&
100) { echo -n 100 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "echo b;"; restore=$(expr $restore + 1) ;&
101) { echo -n 101 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "fi"; restore=$(expr $restore + 1) ;&
102) { echo -n 102 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
103) { echo -n 103 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; answer_run "a" justumen "Non"; restore=$(expr $restore + 1) ;&
104) { echo -n 104 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
105) { echo -n 105 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Effectivement, la reponse n'est probablement pas celle que vous pensiez..."; restore=$(expr $restore + 1) ;&
106) { echo -n 106 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Il est important de comprendre que "false" est en fait une commande qui retourne toujours une erreur. (code de sortie $?=1)"; restore=$(expr $restore + 1) ;&
107) { echo -n 107 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
108) { echo -n 108 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk_not_press_key justumen "Faites donc : false;echo $?"; restore=$(expr $restore + 1) ;&
109) { echo -n 109 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; answer_run "false;echo $?" justumen "Non"; restore=$(expr $restore + 1) ;&
110) { echo -n 110 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
111) { echo -n 111 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk_not_press_key justumen "Et maintenant : true;echo $?"; restore=$(expr $restore + 1) ;&
112) { echo -n 112 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; answer_run "true;echo $?" justumen "Non"; restore=$(expr $restore + 1) ;&
113) { echo -n 113 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
114) { echo -n 114 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Comme nous l'avons deja vu, quand vous utilisez ces [ ], il s'agit en fait d'une syntaxe speciale de la commande "test"."; restore=$(expr $restore + 1) ;&
115) { echo -n 115 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
116) { echo -n 116 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "C'est a dire qu'on lieu de faire if [ $X -gt 2 ], vous pouvez aussi utiliser "if test $X -gt 2"."; restore=$(expr $restore + 1) ;&
117) { echo -n 117 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
118) { echo -n 118 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "If attend donc un code de sortie ($?), qui est donne par la commande "test" ou bien par la commande "false" (Ou $? est toujours 1) ou par la commande "true" (Ou $? est toujours 0)."; restore=$(expr $restore + 1) ;&
119) { echo -n 119 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
120) { echo -n 120 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "La commande test enverra a if, suivant la situation, un code de sortie 0 ou 1."; restore=$(expr $restore + 1) ;&
121) { echo -n 121 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Si le code de sortie est 0, le contenu du if sera execute, sinon, c'est le contenu du else qui sera execute."; restore=$(expr $restore + 1) ;&
122) { echo -n 122 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
123) { echo -n 123 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "C'est assez contre-intuitif, parce qu'avec "if false", false va activer le contenu du if en lui envoyant le code de sortie 0."; restore=$(expr $restore + 1) ;&
124) { echo -n 124 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Mais n'oubliez pas que le code de sortie est utilise pour detecter les erreurs. ($?=0 pas d'erreur, $?=1 type d'erreur 1, $?=2 type d'erreur 2, etc...)"; restore=$(expr $restore + 1) ;&
125) { echo -n 125 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
126) { echo -n 126 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Pour revenir a l'exemple precedent, faire if [ false ] n'a donc aucun sens car il s'agit de l'equivalent de "test false"."; restore=$(expr $restore + 1) ;&
127) { echo -n 127 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "La commande "test false" renverra le code de sortie 0. (Contrairement a la commande false, qui elle renverra le code de sortie 1)"; restore=$(expr $restore + 1) ;&
128) { echo -n 128 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
129) { echo -n 129 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Faites donc : false;echo $?"; restore=$(expr $restore + 1) ;&
130) { echo -n 130 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "???"; restore=$(expr $restore + 1) ;&
131) { echo -n 131 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Et maintenant : test false;echo $?"; restore=$(expr $restore + 1) ;&
132) { echo -n 132 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "???"; restore=$(expr $restore + 1) ;&
133) { echo -n 133 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
134) { echo -n 134 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Sans elements de comparaison (comme -eq, -ne, etc...) la commande "test" n'aura un code de sortie 0 que si son argument n'est pas vide."; restore=$(expr $restore + 1) ;&
135) { echo -n 135 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
136) { echo -n 136 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Vous pouvez donc par exemple utilisez ce comportement pour savoir si une variable a une valeur."; restore=$(expr $restore + 1) ;&
137) { echo -n 137 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
138) { echo -n 138 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "if [ $X ];then echo X existe et non vide;fi"; restore=$(expr $restore + 1) ;&
139) { echo -n 139 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "???"; restore=$(expr $restore + 1) ;&
140) { echo -n 140 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
141) { echo -n 141 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Rien ne s'affiche, X n'existe donc pas ou ne contient rien."; restore=$(expr $restore + 1) ;&
142) { echo -n 142 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
143) { echo -n 143 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Maintenant faites : X=22"; restore=$(expr $restore + 1) ;&
144) { echo -n 144 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "???"; restore=$(expr $restore + 1) ;&
145) { echo -n 145 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
146) { echo -n 146 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Puis faites a nouveau : if [ $X ];then echo X existe et non vide;fi"; restore=$(expr $restore + 1) ;&
147) { echo -n 147 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "???"; restore=$(expr $restore + 1) ;&
148) { echo -n 148 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
149) { echo -n 149 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Voila aussi plusieurs exemples de test qui n'afficheront PAS le mot TEST (Autrement dit le code de sortie $? n'est pas egal a 0) :"; restore=$(expr $restore + 1) ;&
150) { echo -n 150 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "if [ ];then echo TEST;fi"; restore=$(expr $restore + 1) ;&
151) { echo -n 151 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "if [ "" ];then echo TEST;fi"; restore=$(expr $restore + 1) ;&
152) { echo -n 152 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "if [ '' ];then echo TEST;fi"; restore=$(expr $restore + 1) ;&
153) { echo -n 153 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
154) { echo -n 154 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Ou encore l'equivalent avec "test" :"; restore=$(expr $restore + 1) ;&
155) { echo -n 155 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "if test "";then echo TEST;fi"; restore=$(expr $restore + 1) ;&
156) { echo -n 156 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "if test '';then echo TEST;fi"; restore=$(expr $restore + 1) ;&
157) { echo -n 157 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
158) { echo -n 158 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "De plus n'importe quel argument non-vide donne a la commande test, provoquera le lancement de son if correspondant."; restore=$(expr $restore + 1) ;&
159) { echo -n 159 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
160) { echo -n 160 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Essayez donc : if [ nimportequoi ];then echo TEST;fi"; restore=$(expr $restore + 1) ;&
161) { echo -n 161 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "???"; restore=$(expr $restore + 1) ;&
162) { echo -n 162 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
163) { echo -n 163 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Attention donc a bien comprendre que dans le code "if ls", if utilise le code de sortie de la commande ls (apres son execution)."; restore=$(expr $restore + 1) ;&
164) { echo -n 164 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Mais que "if [ ls ]" se deroulera en deux etapes : la chaine de caractere "ls" (et non pas la commande) sera envoyee a la commande test et le code de sortie de test sera ensuite envoye a if."; restore=$(expr $restore + 1) ;&
165) { echo -n 165 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
166) { echo -n 166 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "if utilise donc le code de sortie de la commande qui lui est donne en argument... Parfois la commande test, par exemple pour effectuer des comparaisons, mais pas toujours."; restore=$(expr $restore + 1) ;&
167) { echo -n 167 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Ce qui veut dire que vous pouvez utiliser le code de sortie de n'importe quelle commande."; restore=$(expr $restore + 1) ;&
168) { echo -n 168 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
169) { echo -n 169 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Faites donc par exemple : if cd test;then echo EXISTE;fi"; restore=$(expr $restore + 1) ;&
170) { echo -n 170 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "bash: cd: test: No such file or directory"; restore=$(expr $restore + 1) ;&
171) { echo -n 171 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "???"; restore=$(expr $restore + 1) ;&
172) { echo -n 172 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
173) { echo -n 173 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Ah, apparemment le dossier test n'existe pas..."; restore=$(expr $restore + 1) ;&
174) { echo -n 174 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
175) { echo -n 175 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Essayer avec : if cd dossier;then echo EXISTE;fi"; restore=$(expr $restore + 1) ;&
176) { echo -n 176 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "????"; restore=$(expr $restore + 1) ;&
177) { echo -n 177 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
178) { echo -n 178 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Le texte EXISTE apparait, ce qui veut dire que le dossier dossier existe."; restore=$(expr $restore + 1) ;&
179) { echo -n 179 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Ou plus precisement : que la commande cd dossier a envoye un code de sortie 0."; restore=$(expr $restore + 1) ;&
180) { echo -n 180 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Evidemment, n'oubliez pas que cette commande cd vient de changer votre repertoire courant."; restore=$(expr $restore + 1) ;&
181) { echo -n 181 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Meme si celle-ci est ici un argument de if, elle est execute comme une commande normale."; restore=$(expr $restore + 1) ;&
182) { echo -n 182 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
183) { echo -n 183 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Faites donc :"; restore=$(expr $restore + 1) ;&
184) { echo -n 184 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
185) { echo -n 185 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "echo false>TEST"; restore=$(expr $restore + 1) ;&
186) { echo -n 186 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "cat TEST"; restore=$(expr $restore + 1) ;&
187) { echo -n 187 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
188) { echo -n 188 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Maintenant, imaginez vouloir utiliser le contenu de ce fichier TEST pour definir le comportement de votre if..."; restore=$(expr $restore + 1) ;&
189) { echo -n 189 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Par exemple, vous voulez afficher le mot oui si le fichier TEST contient true."; restore=$(expr $restore + 1) ;&
190) { echo -n 190 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
191) { echo -n 191 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Vous pensez peut etre pouvoir faire : if cat TEST;then echo a;fi"; restore=$(expr $restore + 1) ;&
192) { echo -n 192 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Essayez donc..."; restore=$(expr $restore + 1) ;&
193) { echo -n 193 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "???"; restore=$(expr $restore + 1) ;&
194) { echo -n 194 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
195) { echo -n 195 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Evidemment, cela ne fonctionne pas comme prevu... Essayons de comprendre pourquoi."; restore=$(expr $restore + 1) ;&
196) { echo -n 196 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Ici c'est la commande "cat TEST", qui sera execute, et s'il n'y a pas d'erreur dans cette commande le contenu du if sera execute."; restore=$(expr $restore + 1) ;&
197) { echo -n 197 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
198) { echo -n 198 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Mais meme si le fichier TEST contient le mot false, "cat TEST" ne renverra pas une erreur..."; restore=$(expr $restore + 1) ;&
199) { echo -n 199 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""cat TEST" affichera le mot false et retournera le code de sortie 0, ce qui provoquera l'execution du contenu du if."; restore=$(expr $restore + 1) ;&
200) { echo -n 200 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
201) { echo -n 201 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Nous avons deja vu comment rediriger la sortie standard et l'erreur standard d'une commande. (par example avec > et 2>)"; restore=$(expr $restore + 1) ;&
202) { echo -n 202 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Et nous avons aussi deja vu comment creer des variables. (comme par exemple TEST=false)"; restore=$(expr $restore + 1) ;&
203) { echo -n 203 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
204) { echo -n 204 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Maintenant nous allons voir comment envoyer le resultat d'une commande dans une variable !!!"; restore=$(expr $restore + 1) ;&
205) { echo -n 205 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
206) { echo -n 206 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Pour affecter le resultat de "cat TEST" a la variable TEST, vous pouvez faire : TEST=$(cat TEST)"; restore=$(expr $restore + 1) ;&
207) { echo -n 207 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "???"; restore=$(expr $restore + 1) ;&
208) { echo -n 208 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Maintenant affichez le contenu de la variable TEST avec un simple : echo $TEST"; restore=$(expr $restore + 1) ;&
209) { echo -n 209 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "???"; restore=$(expr $restore + 1) ;&
210) { echo -n 210 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
211) { echo -n 211 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Attention : j'utilise ici le meme nom TEST pour la variable et le fichier, mais bien evidemment ils n'ont pas besoin d'etre identique."; restore=$(expr $restore + 1) ;&
212) { echo -n 212 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
213) { echo -n 213 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Maintenant que la variable TEST contient le mot "false", vous pouvez l'utiliser comme argument de if."; restore=$(expr $restore + 1) ;&
214) { echo -n 214 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
215) { echo -n 215 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "if $TEST;then echo a;fi"; restore=$(expr $restore + 1) ;&
216) { echo -n 216 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "???"; restore=$(expr $restore + 1) ;&
217) { echo -n 217 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
218) { echo -n 218 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Changer donc le contenu du fichier TEST : echo true>TEST"; restore=$(expr $restore + 1) ;&
219) { echo -n 219 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "???"; restore=$(expr $restore + 1) ;&
220) { echo -n 220 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
221) { echo -n 221 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "if $TEST;then echo a;fi"; restore=$(expr $restore + 1) ;&
222) { echo -n 222 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "???"; restore=$(expr $restore + 1) ;&
223) { echo -n 223 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
224) { echo -n 224 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Oh... effectivement. Meme si le contenu du fichier TEST a change, ce n'est pas le cas de la variable TEST..."; restore=$(expr $restore + 1) ;&
225) { echo -n 225 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
226) { echo -n 226 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Refaites donc : TEST=$(cat TEST)"; restore=$(expr $restore + 1) ;&
227) { echo -n 227 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "???"; restore=$(expr $restore + 1) ;&
228) { echo -n 228 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
229) { echo -n 229 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "if $TEST;then echo a;fi"; restore=$(expr $restore + 1) ;&
230) { echo -n 230 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "???"; restore=$(expr $restore + 1) ;&
231) { echo -n 231 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
232) { echo -n 232 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Mais il est aussi possible d'envoyer le resultat directement a if, sans utiliser de variable !"; restore=$(expr $restore + 1) ;&
233) { echo -n 233 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
234) { echo -n 234 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Essayez avec : if $(cat TEST);then echo a;fi"; restore=$(expr $restore + 1) ;&
235) { echo -n 235 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "???"; restore=$(expr $restore + 1) ;&
236) { echo -n 236 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
237) { echo -n 237 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Pour simplifier, on peut dire que $() va creer une variable temporaire que if va pouvoir utiliser. (D'ou l'utilisation du symbole $, normalement reserve pour les variables)"; restore=$(expr $restore + 1) ;&
238) { echo -n 238 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
239) { echo -n 239 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Par soucis de flexibilite, il existe une deuxieme syntaxe, qui se comporte exactement de la meme maniere."; restore=$(expr $restore + 1) ;&
240) { echo -n 240 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
241) { echo -n 241 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Essayer un code identique avec des ` : if `cat TEST`;then echo a;fi"; restore=$(expr $restore + 1) ;&
242) { echo -n 242 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "???"; restore=$(expr $restore + 1) ;&
243) { echo -n 243 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
244) { echo -n 244 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Pour etre sur que tout fonctionne, changeons le contenu du fichier TEST avec : echo false>TEST"; restore=$(expr $restore + 1) ;&
245) { echo -n 245 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "???"; restore=$(expr $restore + 1) ;&
246) { echo -n 246 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
247) { echo -n 247 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Puis a nouveau : if `cat TEST`;then echo a;fi"; restore=$(expr $restore + 1) ;&
248) { echo -n 248 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "???"; restore=$(expr $restore + 1) ;&
249) { echo -n 249 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
250) { echo -n 250 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "Parfait, tout fonctionne comme prevu. En avant pour le questionnaire !!!"; restore=$(expr $restore + 1) ;&
251) { echo -n 251 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
252) { echo -n 252 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
253) { echo -n 253 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
254) { echo -n 254 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
255) { echo -n 255 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "ê"; restore=$(expr $restore + 1) ;&
256) { echo -n 256 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "é"; restore=$(expr $restore + 1) ;&
257) { echo -n 257 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "à"; restore=$(expr $restore + 1) ;&
258) { echo -n 258 > $HOME/.GameScript/restore_bash12; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash12; } 2>/dev/null ; talk justumen "è"; restore=$(expr $restore + 1) ;&
esac
}

function clean(){ #in enter_chapter
rm $HOME/.GameScript/restore_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
rm $HOME/.GameScript/restore_pwd_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
	rmdir $HOME/.GameScript_bash11 2> /dev/null
}

function start_quiz(){
  start_quiz_music
  echo ""
  echo -e "\e[15;44m Bash 'Bourne Again SHell' : Questionnaire du chapitre 11 \e[0m"
  echo -e "- La réponse doit être la plus courte possible, une commande valide mais ajoutant des caractères inutiles ne fonctionnera pas."
  echo -e "Exemple : si la réponse est 'ls'. Les réponses 'ls .', 'ls ./' et 'ls ././' seront considérées comme fausses."
  answer_text_fr "" ""
  unlock "bash" "10" "2211" "ddfb"
}


CHAPTER_NAME="bash"
CHAPTER_NUMBER="11"
LANGUAGE="fr"
SPEAKER="m1"

if [ "$1" == "VIDEO" ]; then
	prepare_video
else
	if [ ! "$1" == "MUTE" ]; then
		prepare_audio
	fi
fi

enter_chapter $CHAPTER_NAME $CHAPTER_NUMBER



//:P trap
if ((true||false)&&true); then
	echo false;
else
	echo true;
fi
