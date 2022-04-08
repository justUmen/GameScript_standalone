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
1) { echo -n 1 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; [ -d "$HOME/.GameScript_bash13" ] && echo "Erreur inattendue, ${HOME}/.GameScript_bash13 existe déjà sur votre système ! Supprimez ce dossier $HOME/.GameScript_bash13 et relancez ce script." && exit; restore=$(expr $restore + 1) ;&
2) { echo -n 2 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; mkdir $HOME/.GameScript_bash13 2> /dev/null; restore=$(expr $restore + 1) ;&
3) { echo -n 3 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; cd $HOME/.GameScript_bash13; restore=$(expr $restore + 1) ;&
4) { echo -n 4 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
5) { echo -n 5 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Nous avons deja vu comment comparer deux nombres entre eux avec -eq, -ne, -gt, -lt,  -le et -ge."; restore=$(expr $restore + 1) ;&
6) { echo -n 6 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Maintenant nous allons voir comment comparer deux chaines de caracteres."; restore=$(expr $restore + 1) ;&
7) { echo -n 7 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
8) { echo -n 8 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Commencez par afficher le contenu du fichier selection:"; restore=$(expr $restore + 1) ;&
9) { echo -n 9 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "cat select"; restore=$(expr $restore + 1) ;&
10) { echo -n 10 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "??? chat"; restore=$(expr $restore + 1) ;&
11) { echo -n 11 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
12) { echo -n 12 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Maintenant, affichez le contenu du script selection.sh"; restore=$(expr $restore + 1) ;&
13) { echo -n 13 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "cat select.sh"; restore=$(expr $restore + 1) ;&
14) { echo -n 14 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "???"; restore=$(expr $restore + 1) ;&
15) { echo -n 15 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
16) { echo -n 16 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "select=$(cat select)"; restore=$(expr $restore + 1) ;&
17) { echo -n 17 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "if [ $select = chat ] || [ $select = chien ];then"; restore=$(expr $restore + 1) ;&
18) { echo -n 18 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "echo select est un animal"; restore=$(expr $restore + 1) ;&
19) { echo -n 19 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "elif [ $select = avion ] || [ $select = bateau ];then"; restore=$(expr $restore + 1) ;&
20) { echo -n 20 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "echo select est un objet"; restore=$(expr $restore + 1) ;&
21) { echo -n 21 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "else"; restore=$(expr $restore + 1) ;&
22) { echo -n 22 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "echo select est de type inconnu"; restore=$(expr $restore + 1) ;&
23) { echo -n 23 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "fi"; restore=$(expr $restore + 1) ;&
24) { echo -n 24 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
25) { echo -n 25 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Executez le script select.sh avec bash"; restore=$(expr $restore + 1) ;&
26) { echo -n 26 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "bash select.sh"; restore=$(expr $restore + 1) ;&
27) { echo -n 27 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "???"; restore=$(expr $restore + 1) ;&
28) { echo -n 28 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
29) { echo -n 29 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Ici le simple symbole = est utilise entre les [ ] pour comparer deux chaines de caracteres."; restore=$(expr $restore + 1) ;&
30) { echo -n 30 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Attention a ne pas confondre le comportement de = dans un code comme x=2. (Ici affectation et non pas comparaison)"; restore=$(expr $restore + 1) ;&
31) { echo -n 31 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Par soucis de similarite avec d'autres langages de programmation, vous pouvez aussi utiliser les ==."; restore=$(expr $restore + 1) ;&
32) { echo -n 32 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
33) { echo -n 33 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Essayez donc de faire : if [ $select == chat ];then echo chat;fi"; restore=$(expr $restore + 1) ;&
34) { echo -n 34 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "???"; restore=$(expr $restore + 1) ;&
35) { echo -n 35 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "bash: [: ==: unary operator expected"; restore=$(expr $restore + 1) ;&
36) { echo -n 36 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
37) { echo -n 37 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Oh, que s'est-il passe ?!"; restore=$(expr $restore + 1) ;&
38) { echo -n 38 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
39) { echo -n 39 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Faites donc : echo $select"; restore=$(expr $restore + 1) ;&
40) { echo -n 40 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "???"; restore=$(expr $restore + 1) ;&
41) { echo -n 41 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
42) { echo -n 42 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Effectivement, la variable select a ete definit dans le script select.sh mais pas dans le terminal ou nous sommes actuellement."; restore=$(expr $restore + 1) ;&
43) { echo -n 43 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
44) { echo -n 44 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Faites donc : select=$(cat select)"; restore=$(expr $restore + 1) ;&
45) { echo -n 45 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "???"; restore=$(expr $restore + 1) ;&
46) { echo -n 46 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
47) { echo -n 47 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Refaites donc : if [ $select == chat ];then echo chat;fi"; restore=$(expr $restore + 1) ;&
48) { echo -n 48 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "???"; restore=$(expr $restore + 1) ;&
49) { echo -n 49 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
50) { echo -n 50 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Tout fonctionne cette fois."; restore=$(expr $restore + 1) ;&
51) { echo -n 51 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Mais comment eviter que bash ne crashe lamentablement si la variable n'existe pas..."; restore=$(expr $restore + 1) ;&
52) { echo -n 52 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
53) { echo -n 53 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Et bien, il suffit d'utiliser les guillemets !"; restore=$(expr $restore + 1) ;&
54) { echo -n 54 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
55) { echo -n 55 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Essayez donc avec : if [ "$rien" == chat ];then echo test;fi"; restore=$(expr $restore + 1) ;&
56) { echo -n 56 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "???"; restore=$(expr $restore + 1) ;&
57) { echo -n 57 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
58) { echo -n 58 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Ici, le contenu du if ne se lance pas, mais au moins bash ne retourne pas d'erreur."; restore=$(expr $restore + 1) ;&
59) { echo -n 59 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
60) { echo -n 60 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Avec les guillemets, si la variable rien ne contient rien, le code devient : if [ "" == chat ];then echo test;fi"; restore=$(expr $restore + 1) ;&
61) { echo -n 61 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Sans les guillemets, si la variable rien ne contient rien, le code devient : if [  == chat ];then echo test;fi, ce qui evidemment provoque une erreur car la syntaxe du if n'est pas correcte."; restore=$(expr $restore + 1) ;&
62) { echo -n 62 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
63) { echo -n 63 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Le contraire de == est != (N'est pas egal a...)."; restore=$(expr $restore + 1) ;&
64) { echo -n 64 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
65) { echo -n 65 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Essayez donc d'afficher la valeur de select si celle-ci n'est pas vide."; restore=$(expr $restore + 1) ;&
66) { echo -n 66 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "???"; restore=$(expr $restore + 1) ;&
67) { echo -n 67 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "if [ "$select" ];then echo $select;fi"; restore=$(expr $restore + 1) ;&
68) { echo -n 68 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
69) { echo -n 69 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Et oui... Il y avait un piege. Souvenez-vous du cours precedent, vous n'avez pas besoin d'utiliser : != "" avec if et la commande test, c'est en fait son comportement par defaut."; restore=$(expr $restore + 1) ;&
70) { echo -n 70 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Mais vous auriez tres bien pu faire if [ "$select" != "" ];then echo $select;fi, cela fonctionne aussi."; restore=$(expr $restore + 1) ;&
71) { echo -n 71 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
72) { echo -n 72 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Pour quelque chose de simple, souvenez vous qu'il n'est pas toujours indispensable d'utiliser if."; restore=$(expr $restore + 1) ;&
73) { echo -n 73 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
74) { echo -n 74 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Sans utiliser de if mais en utilisant le symbole !, affichez "pas root" si l'utilisateur que vous utilisez actuellement n'est pas root."; restore=$(expr $restore + 1) ;&
75) { echo -n 75 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "[ `whoami` != root ]||echo pas root"; restore=$(expr $restore + 1) ;&
76) { echo -n 76 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "???"; restore=$(expr $restore + 1) ;&
77) { echo -n 77 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
78) { echo -n 78 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Ce symbole ! peut aussi etre utilise seul pour signifier le contraire de quelques chose."; restore=$(expr $restore + 1) ;&
79) { echo -n 79 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Par exemple ! true est false et ! false est true."; restore=$(expr $restore + 1) ;&
80) { echo -n 80 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
81) { echo -n 81 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Creez donc un fichier vide test avec : touch test"; restore=$(expr $restore + 1) ;&
82) { echo -n 82 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "???"; restore=$(expr $restore + 1) ;&
83) { echo -n 83 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
84) { echo -n 84 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Sans utiliser de if mais en utilisant cat, affichez le mot vide si le fichier test est vide."; restore=$(expr $restore + 1) ;&
85) { echo -n 85 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "[ `cat test` ]||echo vide"; restore=$(expr $restore + 1) ;&
86) { echo -n 86 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "???"; restore=$(expr $restore + 1) ;&
87) { echo -n 87 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
88) { echo -n 88 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Sans utiliser de if mais en utilisant ! et cat, affichez le mot vide si le fichier test est vide."; restore=$(expr $restore + 1) ;&
89) { echo -n 89 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "[ ! `cat test` ]&&echo vide"; restore=$(expr $restore + 1) ;&
90) { echo -n 90 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "???"; restore=$(expr $restore + 1) ;&
91) { echo -n 91 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
92) { echo -n 92 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Mais qu'en est-il si vous devez comparer une grande quantite d'elements ?"; restore=$(expr $restore + 1) ;&
93) { echo -n 93 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Prenons cet exemple :"; restore=$(expr $restore + 1) ;&
94) { echo -n 94 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
95) { echo -n 95 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "VAR=5"; restore=$(expr $restore + 1) ;&
96) { echo -n 96 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "if [ $VAR -eq 1 ]; then"; restore=$(expr $restore + 1) ;&
97) { echo -n 97 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "echo 1"; restore=$(expr $restore + 1) ;&
98) { echo -n 98 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "elif [ $VAR -eq 2 ]; then"; restore=$(expr $restore + 1) ;&
99) { echo -n 99 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "echo 2"; restore=$(expr $restore + 1) ;&
100) { echo -n 100 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "elif [ $VAR -eq 3 ]; then"; restore=$(expr $restore + 1) ;&
101) { echo -n 101 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "echo 3"; restore=$(expr $restore + 1) ;&
102) { echo -n 102 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "elif [ $VAR -eq 4 ]; then"; restore=$(expr $restore + 1) ;&
103) { echo -n 103 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "echo 4"; restore=$(expr $restore + 1) ;&
104) { echo -n 104 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "elif [ $VAR -eq 5 ]; then"; restore=$(expr $restore + 1) ;&
105) { echo -n 105 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "echo 5"; restore=$(expr $restore + 1) ;&
106) { echo -n 106 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "elif [ $VAR -eq 6 ]; then"; restore=$(expr $restore + 1) ;&
107) { echo -n 107 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "echo 6"; restore=$(expr $restore + 1) ;&
108) { echo -n 108 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "elif [ $VAR -eq 7 ]; then"; restore=$(expr $restore + 1) ;&
109) { echo -n 109 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "echo 7"; restore=$(expr $restore + 1) ;&
110) { echo -n 110 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "elif [ $VAR -eq 8 ]; then"; restore=$(expr $restore + 1) ;&
111) { echo -n 111 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "echo 8"; restore=$(expr $restore + 1) ;&
112) { echo -n 112 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "elif [ $VAR -eq 9 ]; then"; restore=$(expr $restore + 1) ;&
113) { echo -n 113 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "echo 9"; restore=$(expr $restore + 1) ;&
114) { echo -n 114 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "elif [ $VAR -eq 10 ]; then"; restore=$(expr $restore + 1) ;&
115) { echo -n 115 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "echo 10"; restore=$(expr $restore + 1) ;&
116) { echo -n 116 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "fi"; restore=$(expr $restore + 1) ;&
117) { echo -n 117 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
118) { echo -n 118 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Ce code devient rapidement encombrant..."; restore=$(expr $restore + 1) ;&
119) { echo -n 119 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Vous pouvez en fait utiliser une syntaxe speciale dans ce genre de situation : case/in/esac."; restore=$(expr $restore + 1) ;&
120) { echo -n 120 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
121) { echo -n 121 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Voila un code identique au precedent :"; restore=$(expr $restore + 1) ;&
122) { echo -n 122 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
123) { echo -n 123 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "VAR=5"; restore=$(expr $restore + 1) ;&
124) { echo -n 124 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "case $VAR in"; restore=$(expr $restore + 1) ;&
125) { echo -n 125 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "1) echo 1;;"; restore=$(expr $restore + 1) ;&
126) { echo -n 126 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "2) echo 2;;"; restore=$(expr $restore + 1) ;&
127) { echo -n 127 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "3) echo 3;;"; restore=$(expr $restore + 1) ;&
128) { echo -n 128 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "4) echo 4;;"; restore=$(expr $restore + 1) ;&
129) { echo -n 129 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "5) echo 5;;"; restore=$(expr $restore + 1) ;&
130) { echo -n 130 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "6) echo 6;;"; restore=$(expr $restore + 1) ;&
131) { echo -n 131 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "7) echo 7;;"; restore=$(expr $restore + 1) ;&
132) { echo -n 132 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "8) echo 8;;"; restore=$(expr $restore + 1) ;&
133) { echo -n 133 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "9) echo 9;;"; restore=$(expr $restore + 1) ;&
134) { echo -n 134 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "10) echo 10;;"; restore=$(expr $restore + 1) ;&
135) { echo -n 135 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "esac"; restore=$(expr $restore + 1) ;&
136) { echo -n 136 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
137) { echo -n 137 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Notez que chaque comparaisons se terminent par ;;."; restore=$(expr $restore + 1) ;&
138) { echo -n 138 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "case/in/esac utilise des chaines de caracteres comme comparaison, vous pouvez donc aussi faire quelque chose comme :"; restore=$(expr $restore + 1) ;&
139) { echo -n 139 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
140) { echo -n 140 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "VAR=avion"; restore=$(expr $restore + 1) ;&
141) { echo -n 141 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "case $VAR in"; restore=$(expr $restore + 1) ;&
142) { echo -n 142 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "avion) echo avion;;"; restore=$(expr $restore + 1) ;&
143) { echo -n 143 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "chat) echo chat;;"; restore=$(expr $restore + 1) ;&
144) { echo -n 144 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "esac"; restore=$(expr $restore + 1) ;&
145) { echo -n 145 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
146) { echo -n 146 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Ou des guillemets, si vous en avez besoin :"; restore=$(expr $restore + 1) ;&
147) { echo -n 147 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
148) { echo -n 148 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "VAR="deux mots""; restore=$(expr $restore + 1) ;&
149) { echo -n 149 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "case $VAR in"; restore=$(expr $restore + 1) ;&
150) { echo -n 150 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""deux mots") echo deux mots;;"; restore=$(expr $restore + 1) ;&
151) { echo -n 151 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "chat) echo chat;;"; restore=$(expr $restore + 1) ;&
152) { echo -n 152 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "esac"; restore=$(expr $restore + 1) ;&
153) { echo -n 153 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
154) { echo -n 154 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Vous pouvez aussi utiliser |, qui a le meme comportement que le || d'un if (logique OR):"; restore=$(expr $restore + 1) ;&
155) { echo -n 155 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
156) { echo -n 156 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "VAR=2"; restore=$(expr $restore + 1) ;&
157) { echo -n 157 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "case $VAR in"; restore=$(expr $restore + 1) ;&
158) { echo -n 158 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "1|2) echo 1 ou 2;;"; restore=$(expr $restore + 1) ;&
159) { echo -n 159 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "*) echo autre chose"; restore=$(expr $restore + 1) ;&
160) { echo -n 160 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "esac"; restore=$(expr $restore + 1) ;&
161) { echo -n 161 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
162) { echo -n 162 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
163) { echo -n 163 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Un * vous permet de definir un code a executer "par defaut" si aucune des autres comparaisons n'est bonne. (Comme le else d'un if)"; restore=$(expr $restore + 1) ;&
164) { echo -n 164 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
165) { echo -n 165 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "VAR="192.168.1.1""; restore=$(expr $restore + 1) ;&
166) { echo -n 166 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "case $VAR in"; restore=$(expr $restore + 1) ;&
167) { echo -n 167 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""deux mots") echo deux mots;;"; restore=$(expr $restore + 1) ;&
168) { echo -n 168 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "[[[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}]]) echo ip;;"; restore=$(expr $restore + 1) ;&
169) { echo -n 169 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "*) echo "ni l'un, ni l'autre""; restore=$(expr $restore + 1) ;&
170) { echo -n 170 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "esac"; restore=$(expr $restore + 1) ;&
171) { echo -n 171 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
172) { echo -n 172 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Pourquoi ce symbole * me diriez-vous ? Et bien si vous connaissez les expressions regulieres, vous pouvez les utiliser ici, sinon rendez-vous sur mon cours sur ce sujet..."; restore=$(expr $restore + 1) ;&
173) { echo -n 173 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Je ne detaillerai pas la syntaxe de ces expressions regulieres dans cette serie sur bash mais voici juste un exemple pour vous donner une idee de ce qui est possible de faire :"; restore=$(expr $restore + 1) ;&
174) { echo -n 174 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
175) { echo -n 175 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "VAR=autre"; restore=$(expr $restore + 1) ;&
176) { echo -n 176 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "case $VAR in"; restore=$(expr $restore + 1) ;&
177) { echo -n 177 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "[a-z]???) echo commence par une lettre de l'alphabet en minuscule et contient 4 caracteres au total;;"; restore=$(expr $restore + 1) ;&
178) { echo -n 178 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "[[:digit:]]) echo est un chiffre;;"; restore=$(expr $restore + 1) ;&
179) { echo -n 179 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "a*) echo autre chose mais commence par un a;;"; restore=$(expr $restore + 1) ;&
180) { echo -n 180 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "au*) echo autre chose mais commence par un au;;"; restore=$(expr $restore + 1) ;&
181) { echo -n 181 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "*) echo autre chose;;"; restore=$(expr $restore + 1) ;&
182) { echo -n 182 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "esac"; restore=$(expr $restore + 1) ;&
183) { echo -n 183 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "?????????? PUT MORE EXAMPLE OF REGEX INSIDE THIS CASE TO SHOW THE POWER OF REGEX ????????"; restore=$(expr $restore + 1) ;&
184) { echo -n 184 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "IS AN IP ADRESS, IS AN EMAIL, IS HEXADECIMAL, IS A VALID PHONE NUMBER..."; restore=$(expr $restore + 1) ;&
185) { echo -n 185 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
186) { echo -n 186 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Dans ce cours nous n'allons voir que la signification du symbole *, qui represente un "joker" : il remplace une quelconque suite de caracteres. (Meme vide.)"; restore=$(expr $restore + 1) ;&
187) { echo -n 187 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Vous pouvez donc traduire * par : "une chaine de caracteres quelconque". Alors que a* peut se traduire par : "une chaine de caracteres quelconque qui commence par un a.""; restore=$(expr $restore + 1) ;&
188) { echo -n 188 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
189) { echo -n 189 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Notez que l'ordre de comparaison est important, dans l'exemple precedent avec VAR=autre, deux conditions sont valides : a* et au*."; restore=$(expr $restore + 1) ;&
190) { echo -n 190 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Dans ce cas, case ne lancera que le premier qu'il rencontre."; restore=$(expr $restore + 1) ;&
191) { echo -n 191 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
192) { echo -n 192 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Affichez le fichier case1.sh"; restore=$(expr $restore + 1) ;&
193) { echo -n 193 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "???"; restore=$(expr $restore + 1) ;&
194) { echo -n 194 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
195) { echo -n 195 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "VAR="autre""; restore=$(expr $restore + 1) ;&
196) { echo -n 196 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "case $VAR in"; restore=$(expr $restore + 1) ;&
197) { echo -n 197 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "a*) echo a;;"; restore=$(expr $restore + 1) ;&
198) { echo -n 198 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "au*) echo au;;"; restore=$(expr $restore + 1) ;&
199) { echo -n 199 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "esac"; restore=$(expr $restore + 1) ;&
200) { echo -n 200 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
201) { echo -n 201 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Lancez le script case1.sh avec bash"; restore=$(expr $restore + 1) ;&
202) { echo -n 202 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "???bash case1.sh"; restore=$(expr $restore + 1) ;&
203) { echo -n 203 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
204) { echo -n 204 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Donc bien evidemment le *) doit toujours se situer en dernier de liste."; restore=$(expr $restore + 1) ;&
205) { echo -n 205 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Le code ci-dessous affichera par exemple toujours le mot "ici", quel que soit le contenu de la variable VAR :"; restore=$(expr $restore + 1) ;&
206) { echo -n 206 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
207) { echo -n 207 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "VAR="autre""; restore=$(expr $restore + 1) ;&
208) { echo -n 208 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "case $VAR in"; restore=$(expr $restore + 1) ;&
209) { echo -n 209 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "*) echo ici;;"; restore=$(expr $restore + 1) ;&
210) { echo -n 210 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "a*) echo a;;"; restore=$(expr $restore + 1) ;&
211) { echo -n 211 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "au*) echo au;;"; restore=$(expr $restore + 1) ;&
212) { echo -n 212 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "esac"; restore=$(expr $restore + 1) ;&
213) { echo -n 213 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
214) { echo -n 214 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
215) { echo -n 215 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
216) { echo -n 216 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
217) { echo -n 217 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
218) { echo -n 218 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
219) { echo -n 219 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "regular expressions with if ??????"; restore=$(expr $restore + 1) ;&
220) { echo -n 220 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "[[ ]]"; restore=$(expr $restore + 1) ;&
221) { echo -n 221 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "if [[ "$ip" =~ ^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5])).){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$ ]]; then"; restore=$(expr $restore + 1) ;&
222) { echo -n 222 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
223) { echo -n 223 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
224) { echo -n 224 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
225) { echo -n 225 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "????????????????????POURQUOI deux ;; ???????"; restore=$(expr $restore + 1) ;&
226) { echo -n 226 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "*) ??? default"; restore=$(expr $restore + 1) ;&
227) { echo -n 227 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "comportement / continuer"; restore=$(expr $restore + 1) ;&
228) { echo -n 228 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "math in case ??? 1..10) 1-100) ???"; restore=$(expr $restore + 1) ;&
229) { echo -n 229 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "1|2|3"; restore=$(expr $restore + 1) ;&
230) { echo -n 230 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
231) { echo -n 231 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "read YN"; restore=$(expr $restore + 1) ;&
232) { echo -n 232 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "case $YN in"; restore=$(expr $restore + 1) ;&
233) { echo -n 233 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "[yY]|[yY][eE][sS]) echo you agree;;"; restore=$(expr $restore + 1) ;&
234) { echo -n 234 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "[nN]|[nN][oO]) echo you disagree;;"; restore=$(expr $restore + 1) ;&
235) { echo -n 235 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "*) echo invalid;;"; restore=$(expr $restore + 1) ;&
236) { echo -n 236 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "esac"; restore=$(expr $restore + 1) ;&
237) { echo -n 237 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
238) { echo -n 238 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "[a-z]) echo ok;;"; restore=$(expr $restore + 1) ;&
239) { echo -n 239 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
240) { echo -n 240 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
241) { echo -n 241 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "VAR="mOts""; restore=$(expr $restore + 1) ;&
242) { echo -n 242 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "case $VAR in"; restore=$(expr $restore + 1) ;&
243) { echo -n 243 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "m[oO]ts) echo mots;;"; restore=$(expr $restore + 1) ;&
244) { echo -n 244 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "chat) echo chat;;"; restore=$(expr $restore + 1) ;&
245) { echo -n 245 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "esac"; restore=$(expr $restore + 1) ;&
246) { echo -n 246 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
247) { echo -n 247 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
248) { echo -n 248 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "POSIX ??? [] vs [[ ]]"; restore=$(expr $restore + 1) ;&
249) { echo -n 249 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "[[ yes == [yY]es ]]&&echo yes"; restore=$(expr $restore + 1) ;&
250) { echo -n 250 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
251) { echo -n 251 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
252) { echo -n 252 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
253) { echo -n 253 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
254) { echo -n 254 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
255) { echo -n 255 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
256) { echo -n 256 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "$() and ``"; restore=$(expr $restore + 1) ;&
257) { echo -n 257 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "NEED MORE INFO ???"; restore=$(expr $restore + 1) ;&
258) { echo -n 258 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
259) { echo -n 259 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
260) { echo -n 260 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; MORE ABOUT TEST -f, more ???; restore=$(expr $restore + 1) ;&
261) { echo -n 261 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "if [ -f /var/log/messages ]"; restore=$(expr $restore + 1) ;&
262) { echo -n 262 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "test command is also capable of comparing files (-en, -ft, -ot)"; restore=$(expr $restore + 1) ;&
263) { echo -n 263 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
264) { echo -n 264 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
265) { echo -n 265 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
266) { echo -n 266 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; BASH SCRIPT ARGUMENTS; restore=$(expr $restore + 1) ;&
267) { echo -n 267 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "read OR use argument of script !!! $1 !!!!!!"; restore=$(expr $restore + 1) ;&
268) { echo -n 268 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "if [ $# -eq 0 ]; then ;;fi"; restore=$(expr $restore + 1) ;&
269) { echo -n 269 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "IF NO ARGUMENTS"; restore=$(expr $restore + 1) ;&
270) { echo -n 270 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "if [ -z "$1" ]"; restore=$(expr $restore + 1) ;&
271) { echo -n 271 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
272) { echo -n 272 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
273) { echo -n 273 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; BASH SCRIPT VARIABLES; restore=$(expr $restore + 1) ;&
274) { echo -n 274 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "$0 $1 $2 $@ $# $_ $- “$@” $!"; restore=$(expr $restore + 1) ;&
275) { echo -n 275 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
276) { echo -n 276 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
277) { echo -n 277 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
278) { echo -n 278 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "variable in script + variable in shell that launched bash"; restore=$(expr $restore + 1) ;&
279) { echo -n 279 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "difference bash et ./"; restore=$(expr $restore + 1) ;&
280) { echo -n 280 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "(nouvelle instance de bash)"; restore=$(expr $restore + 1) ;&
281) { echo -n 281 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "bash ls"; restore=$(expr $restore + 1) ;&
282) { echo -n 282 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "shebang"; restore=$(expr $restore + 1) ;&
283) { echo -n 283 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
284) { echo -n 284 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
285) { echo -n 285 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
286) { echo -n 286 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
287) { echo -n 287 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
288) { echo -n 288 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "difference between $var and ${var}"; restore=$(expr $restore + 1) ;&
289) { echo -n 289 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "var=2;echo $var;echo ${var}"; restore=$(expr $restore + 1) ;&
290) { echo -n 290 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "var1=1;var2=2;echo $var1_$var2;echo ${var1}_${var2}"; restore=$(expr $restore + 1) ;&
291) { echo -n 291 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
292) { echo -n 292 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
293) { echo -n 293 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
294) { echo -n 294 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "functions and recursive"; restore=$(expr $restore + 1) ;&
295) { echo -n 295 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "argument of functions"; restore=$(expr $restore + 1) ;&
296) { echo -n 296 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
297) { echo -n 297 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
298) { echo -n 298 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "$((expression)) arithmetic"; restore=$(expr $restore + 1) ;&
299) { echo -n 299 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
300) { echo -n 300 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "💣(){ 💣|💣& };💣"; restore=$(expr $restore + 1) ;&
301) { echo -n 301 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "explain recursive..."; restore=$(expr $restore + 1) ;&
302) { echo -n 302 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "max processes for user : ulimit -u (-a for all limits)"; restore=$(expr $restore + 1) ;&
303) { echo -n 303 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "change limits : ulimit -S -u 5000"; restore=$(expr $restore + 1) ;&
304) { echo -n 304 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
305) { echo -n 305 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "SUBSHELLS (i lied to you, use () instead of {}...)"; restore=$(expr $restore + 1) ;&
306) { echo -n 306 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "I have been lying to you for a few chapters... () is creating a subshell... :("; restore=$(expr $restore + 1) ;&
307) { echo -n 307 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "The real "simple" grouping is {}, but requires a ; and a space after the opening { (simpler concept, but more complex syntax)"; restore=$(expr $restore + 1) ;&
308) { echo -n 308 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "subshells and variables :"; restore=$(expr $restore + 1) ;&
309) { echo -n 309 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "x=2;echo $x;(echo $x;x=1;echo $x);echo $x"; restore=$(expr $restore + 1) ;&
310) { echo -n 310 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "x=2;echo $x;{ echo $x;x=1;echo $x;};echo $x"; restore=$(expr $restore + 1) ;&
311) { echo -n 311 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "try_catch() {"; restore=$(expr $restore + 1) ;&
312) { echo -n 312 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "{ # Try-block:"; restore=$(expr $restore + 1) ;&
313) { echo -n 313 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "eval "$@""; restore=$(expr $restore + 1) ;&
314) { echo -n 314 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "} ||"; restore=$(expr $restore + 1) ;&
315) { echo -n 315 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "{ # Catch-block:"; restore=$(expr $restore + 1) ;&
316) { echo -n 316 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "echo "An error occurred""; restore=$(expr $restore + 1) ;&
317) { echo -n 317 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "return -1"; restore=$(expr $restore + 1) ;&
318) { echo -n 318 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "}"; restore=$(expr $restore + 1) ;&
319) { echo -n 319 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "}"; restore=$(expr $restore + 1) ;&
320) { echo -n 320 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
321) { echo -n 321 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
322) { echo -n 322 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
323) { echo -n 323 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "exec 6<>/dev/tcp/127.0.0.1/9999 	&& echo "Server available on port 9999" 	|| { echo "Please run the server with : php -S 127.0.0.1:9999 -t /home/umen/SyNc/Projects/GameScript/PopUpLearn" && exec 6>&- && exec 6<&- && exit; }"; restore=$(expr $restore + 1) ;&
324) { echo -n 324 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
325) { echo -n 325 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
326) { echo -n 326 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
327) { echo -n 327 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "CODE PLANNING BEFORE CODING"; restore=$(expr $restore + 1) ;&
328) { echo -n 328 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
329) { echo -n 329 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
330) { echo -n 330 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "HOW TO DECLARE ARRAYS ???"; restore=$(expr $restore + 1) ;&
331) { echo -n 331 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "table / arrays / list ?"; restore=$(expr $restore + 1) ;&
332) { echo -n 332 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "x=({1..10})"; restore=$(expr $restore + 1) ;&
333) { echo -n 333 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "x=({1,2,3,4,5,6,7,8,9,10})"; restore=$(expr $restore + 1) ;&
334) { echo -n 334 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "echo ${x[1]}"; restore=$(expr $restore + 1) ;&
335) { echo -n 335 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "echo ${x[@]}"; restore=$(expr $restore + 1) ;&
336) { echo -n 336 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "declare -a ???"; restore=$(expr $restore + 1) ;&
337) { echo -n 337 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "what about multidimensional arrays ???"; restore=$(expr $restore + 1) ;&
338) { echo -n 338 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
339) { echo -n 339 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
340) { echo -n 340 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
341) { echo -n 341 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
342) { echo -n 342 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
343) { echo -n 343 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
344) { echo -n 344 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
345) { echo -n 345 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
346) { echo -n 346 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "LOOPS :"; restore=$(expr $restore + 1) ;&
347) { echo -n 347 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "while"; restore=$(expr $restore + 1) ;&
348) { echo -n 348 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "for i in 1 2 3 4 5 6 7 8 9 10; do"; restore=$(expr $restore + 1) ;&
349) { echo -n 349 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "..."; restore=$(expr $restore + 1) ;&
350) { echo -n 350 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "done"; restore=$(expr $restore + 1) ;&
351) { echo -n 351 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "for filename in $(ls);do"; restore=$(expr $restore + 1) ;&
352) { echo -n 352 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "ext=${filename##*.}"; restore=$(expr $restore + 1) ;&
353) { echo -n 353 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "done"; restore=$(expr $restore + 1) ;&
354) { echo -n 354 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "do while ???"; restore=$(expr $restore + 1) ;&
355) { echo -n 355 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "while <"; restore=$(expr $restore + 1) ;&
356) { echo -n 356 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk_not_press_key justumen " c style "for" loop ???"; restore=$(expr $restore + 1) ;&
357) { echo -n 357 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
358) { echo -n 358 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
359) { echo -n 359 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
360) { echo -n 360 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
361) { echo -n 361 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
362) { echo -n 362 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
363) { echo -n 363 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
364) { echo -n 364 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
365) { echo -n 365 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "for (( i=0; i < (( ${#array[@]} – 1 )) ; i++ )); do"; restore=$(expr $restore + 1) ;&
366) { echo -n 366 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "..."; restore=$(expr $restore + 1) ;&
367) { echo -n 367 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "done"; restore=$(expr $restore + 1) ;&
368) { echo -n 368 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
369) { echo -n 369 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
370) { echo -n 370 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
371) { echo -n 371 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
372) { echo -n 372 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
373) { echo -n 373 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
374) { echo -n 374 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
375) { echo -n 375 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "let command ???"; restore=$(expr $restore + 1) ;&
376) { echo -n 376 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "declare command ???"; restore=$(expr $restore + 1) ;&
377) { echo -n 377 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "typeset command"; restore=$(expr $restore + 1) ;&
378) { echo -n 378 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "local command"; restore=$(expr $restore + 1) ;&
379) { echo -n 379 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "shopt command"; restore=$(expr $restore + 1) ;&
380) { echo -n 380 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
381) { echo -n 381 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
382) { echo -n 382 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "type source ---> built-in ----> man bash"; restore=$(expr $restore + 1) ;&
383) { echo -n 383 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
384) { echo -n 384 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
385) { echo -n 385 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
386) { echo -n 386 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
387) { echo -n 387 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
388) { echo -n 388 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen " avant mise a la ligne to escape n (code peut continuer sur une autre ligne)"; restore=$(expr $restore + 1) ;&
389) { echo -n 389 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
390) { echo -n 390 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
391) { echo -n 391 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
392) { echo -n 392 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
393) { echo -n 393 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
394) { echo -n 394 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
395) { echo -n 395 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "Braces : https://wiki.bash-hackers.org/syntax/expansion/brace"; restore=$(expr $restore + 1) ;&
396) { echo -n 396 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "echo {a,b}$PATH"; restore=$(expr $restore + 1) ;&
397) { echo -n 397 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "{$a..$b} NOT POSSIBLE !!! use intead eval : (can you recommend using eval ??? ...)"; restore=$(expr $restore + 1) ;&
398) { echo -n 398 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "a=1;b=100;eval echo {$a..$b}"; restore=$(expr $restore + 1) ;&
399) { echo -n 399 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "for i in $(eval echo {$a..$b})"; restore=$(expr $restore + 1) ;&
400) { echo -n 400 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "declare -a 'pics=(img{'"$a..$b"'}.png)'; mv "${pics[@]}" ../imgs"; restore=$(expr $restore + 1) ;&
401) { echo -n 401 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "echo {I,want,my,money,back}"; restore=$(expr $restore + 1) ;&
402) { echo -n 402 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "echo {A..Z}{0..9}"; restore=$(expr $restore + 1) ;&
403) { echo -n 403 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "echo {{A..Z},{a..z}}"; restore=$(expr $restore + 1) ;&
404) { echo -n 404 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "NEW WITH BASH 4 :"; restore=$(expr $restore + 1) ;&
405) { echo -n 405 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "echo {0001..5}"; restore=$(expr $restore + 1) ;&
406) { echo -n 406 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "increment defined : echo {1..10..2}"; restore=$(expr $restore + 1) ;&
407) { echo -n 407 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "echo {100..1..3}"; restore=$(expr $restore + 1) ;&
408) { echo -n 408 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "x=({1..5});echo ${x[@]}"; restore=$(expr $restore + 1) ;&
409) { echo -n 409 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "wget http://docs.example.com/documentation/slides_part{1,2,3,4,5,6}.html"; restore=$(expr $restore + 1) ;&
410) { echo -n 410 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
411) { echo -n 411 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
412) { echo -n 412 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
413) { echo -n 413 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "VAR=9; [[ $VAR == +([[:digit:]]) ]] && echo number"; restore=$(expr $restore + 1) ;&
414) { echo -n 414 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "printf...."; restore=$(expr $restore + 1) ;&
415) { echo -n 415 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
416) { echo -n 416 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
417) { echo -n 417 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
418) { echo -n 418 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
419) { echo -n 419 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "https://www.gnu.org/software/bash/manual/html_node/Word-Designators.html"; restore=$(expr $restore + 1) ;&
420) { echo -n 420 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
421) { echo -n 421 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
422) { echo -n 422 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "https://www.gnu.org/software/bash/manual/html_node/History-Interaction.html#History-Interaction"; restore=$(expr $restore + 1) ;&
423) { echo -n 423 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
424) { echo -n 424 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
425) { echo -n 425 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
426) { echo -n 426 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
427) { echo -n 427 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "function braceify {"; restore=$(expr $restore + 1) ;&
428) { echo -n 428 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "[[ $1 == +([[:digit:]]) ]] || return"; restore=$(expr $restore + 1) ;&
429) { echo -n 429 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "typeset -a a"; restore=$(expr $restore + 1) ;&
430) { echo -n 430 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "read -ra a < <(factor "$1")"; restore=$(expr $restore + 1) ;&
431) { echo -n 431 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "eval "echo $(printf '{$(printf ,%%.s {1..%s})}' "${a[@]:1}")""; restore=$(expr $restore + 1) ;&
432) { echo -n 432 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "}"; restore=$(expr $restore + 1) ;&
433) { echo -n 433 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
434) { echo -n 434 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "printf 'eval printf "$arg"%s' "$(braceify 1000000)""; restore=$(expr $restore + 1) ;&
435) { echo -n 435 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
436) { echo -n 436 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
437) { echo -n 437 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
438) { echo -n 438 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
439) { echo -n 439 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
440) { echo -n 440 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "num=4; if (( $num <= 5 )); then echo lower than 5; fi"; restore=$(expr $restore + 1) ;&
441) { echo -n 441 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
442) { echo -n 442 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
443) { echo -n 443 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
444) { echo -n 444 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
445) { echo -n 445 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
446) { echo -n 446 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "ê"; restore=$(expr $restore + 1) ;&
447) { echo -n 447 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "é"; restore=$(expr $restore + 1) ;&
448) { echo -n 448 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "à"; restore=$(expr $restore + 1) ;&
449) { echo -n 449 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "è"; restore=$(expr $restore + 1) ;&
450) { echo -n 450 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
451) { echo -n 451 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
452) { echo -n 452 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
453) { echo -n 453 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
454) { echo -n 454 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
455) { echo -n 455 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
456) { echo -n 456 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
457) { echo -n 457 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "NOT INCLUDED ON PURPOSE (Obso/confusion) :"; restore=$(expr $restore + 1) ;&
458) { echo -n 458 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "1 : -a and -o for AND / OR with test"; restore=$(expr $restore + 1) ;&
459) { echo -n 459 > $HOME/.GameScript/restore_bash13; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash13; } 2>/dev/null ; talk justumen "LIKE : if [ $foo -ge 3 -a $foo -lt 10 ]; then"; restore=$(expr $restore + 1) ;&
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
