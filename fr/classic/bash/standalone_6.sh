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
1) { echo -n 1 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; [ -d "$HOME/.GameScript_bash6" ] && echo "Erreur inattendue, ${HOME}/.GameScript_bash6 existe déjà sur votre système ! Supprimez ce dossier $HOME/.GameScript_bash6 et relancez ce script." && exit; restore=$(expr $restore + 1) ;&
2) { echo -n 2 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; mkdir $HOME/.GameScript_bash6 2> /dev/null; restore=$(expr $restore + 1) ;&
3) { echo -n 3 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; cd $HOME/.GameScript_bash6; restore=$(expr $restore + 1) ;&
4) { echo -n 4 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; echo "xxxxxx">intrus;echo "contenu f">f;chmod 222 f;echo "contenu f1">f1;chmod 000 f1;echo "contenu f10">f10;chmod 010 f10;echo "contenu f2">f2;chmod 444 f2;echo "contenu f3">f3;chmod 400 f3;echo "contenu f4">f4;chmod 455 f4;echo "contenu f50">f50;chmod 111 f50; restore=$(expr $restore + 1) ;&
5) { echo -n 5 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk_not_press_key justumen "Commençons par évaluer notre situation avec un : ${learn}ls -l${reset}"; restore=$(expr $restore + 1) ;&
6) { echo -n 6 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; answer_run "ls -l" justumen "Non"; restore=$(expr $restore + 1) ;&
7) { echo -n 7 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Nous avons ici quelques problèmes de permission à régler..."; restore=$(expr $restore + 1) ;&
8) { echo -n 8 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Nous voulons rajouter le droit de lecture et d'écriture pour le propriétaire sur tous les éléments du répertoire courant."; restore=$(expr $restore + 1) ;&
9) { echo -n 9 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Il est possible de mettre tous les noms les uns à la suite des autres avec ${code}chmod${reset}."; restore=$(expr $restore + 1) ;&
10) { echo -n 10 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk_not_press_key justumen "Faites le donc pour 'f1' et 'f2', puis réaffichez les nouvelles permissions si la commande est un succès."; restore=$(expr $restore + 1) ;&
11) { echo -n 11 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; answer_run "chmod u+rw f1 f2&&ls -l" justumen "Non"; restore=$(expr $restore + 1) ;&
12) { echo -n 12 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Taper tous les noms de fichiers est finalement particulièrement rébarbatif, surtout si vous avez un grand nombre de fichiers à changer."; restore=$(expr $restore + 1) ;&
13) { echo -n 13 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Dans ce chapitre nous allons ajouter de nouveaux caractères spéciaux à notre arsenal !"; restore=$(expr $restore + 1) ;&
14) { echo -n 14 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Le premier que nous allons voir est : ${code}*${reset}"; restore=$(expr $restore + 1) ;&
15) { echo -n 15 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "${code}*${reset} est un symbole très puissant, on l'appelle un ${voc}joker${reset}."; restore=$(expr $restore + 1) ;&
16) { echo -n 16 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "${code}*${reset} peut être utilisée pour remplacer tous les éléments d'un répertoire."; restore=$(expr $restore + 1) ;&
17) { echo -n 17 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "C'est à dire qu'au lieu d'avoir à taper tous les noms les uns à la suite des autres, vous avez juste à mettre une ${code}*${reset} à la place."; restore=$(expr $restore + 1) ;&
18) { echo -n 18 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk_not_press_key justumen "Ajoutez donc le droit de lecture et d'écriture pour le propriétaire sur tous les éléments du répertoire courant, puis réaffichez les nouvelles permissions si la commande est un succès."; restore=$(expr $restore + 1) ;&
19) { echo -n 19 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; answer_run "chmod u+rw *&&ls -l" justumen "Non"; restore=$(expr $restore + 1) ;&
20) { echo -n 20 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Si ${code}*${reset} est utilisée seule, le répertoire en question est bien évidemment le répertoire courant : ${code}*${reset} = ${code}./*${reset}"; restore=$(expr $restore + 1) ;&
21) { echo -n 21 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Mais ${code}*${reset} peut être utilisée avec n'importe quel chemin, par exemple : ${code}/*${reset} représente tous les éléments du répertoire racine."; restore=$(expr $restore + 1) ;&
22) { echo -n 22 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Ici nous avons finalement résolu tous nos problèmes de permissions en une seule commande !"; restore=$(expr $restore + 1) ;&
23) { echo -n 23 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Mais ${code}*${reset} peut aussi être utilisée avec les autres commandes."; restore=$(expr $restore + 1) ;&
24) { echo -n 24 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk_not_press_key justumen "Affichez donc le contenu de tous les fichiers du répertoire courant les uns à la suite des autres."; restore=$(expr $restore + 1) ;&
25) { echo -n 25 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; answer_run "cat *" justumen "Non"; restore=$(expr $restore + 1) ;&
26) { echo -n 26 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "L'ordre d'affichage est ${voc}alphabétique${reset}, exactement comme le résultat de ${code}ls${reset}."; restore=$(expr $restore + 1) ;&
27) { echo -n 27 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Notez que 'f10' est placé avant 'f2', car l'affichage par défaut est ${voc}alphabétique${reset} et non pas ${voc}numérique${reset}."; restore=$(expr $restore + 1) ;&
28) { echo -n 28 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Si l'affichage numérique vous intéresse, vous auriez pu trouver facilement l'option ${code}-v${reset} dans le manuel de ${code}ls${reset}."; restore=$(expr $restore + 1) ;&
29) { echo -n 29 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "${code}*${reset} peut donc représenter tous les éléments d'un répertoire."; restore=$(expr $restore + 1) ;&
30) { echo -n 30 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Mais que fait-elle exactement pour avoir cet effet ?"; restore=$(expr $restore + 1) ;&
31) { echo -n 31 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "${code}*${reset} peut en fait remplacer une chaine de caractère quelconque."; restore=$(expr $restore + 1) ;&
32) { echo -n 32 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Si elle est utilisée seule, elle représente donc tous les fichiers qui ont un nom quelconque..."; restore=$(expr $restore + 1) ;&
33) { echo -n 33 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Mais il est aussi possible de limiter ce qu'elle représente en y ajoutant des caractères."; restore=$(expr $restore + 1) ;&
34) { echo -n 34 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk_not_press_key justumen "Par exemple, vous pouvez afficher tous les éléments du répertoire courant qui commence par un 'f' avec : ${learn}ls f*${reset}"; restore=$(expr $restore + 1) ;&
35) { echo -n 35 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; answer_run "ls f*" justumen "Non"; restore=$(expr $restore + 1) ;&
36) { echo -n 36 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Ici le fichier 'intrus' n'est pas présent car son nom ne commence pas par un 'f'."; restore=$(expr $restore + 1) ;&
37) { echo -n 37 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk_not_press_key justumen "Affichez tous les éléments du répertoire courant qui se terminent par un 0 avec : ${learn}ls *0${reset}"; restore=$(expr $restore + 1) ;&
38) { echo -n 38 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; answer_run "ls *0" justumen "Non"; restore=$(expr $restore + 1) ;&
39) { echo -n 39 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "La commande ${code}ls${reset} accepte aussi plusieurs arguments, vous pouvez donc cumuler les syntaxes."; restore=$(expr $restore + 1) ;&
40) { echo -n 40 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk_not_press_key justumen "Essayez par exemple de lister les permissions de tous les éléments du répertoire courant qui finissent soit par un 0, soit par un s."; restore=$(expr $restore + 1) ;&
41) { echo -n 41 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; answer_run "ls -l *0 *s" justumen "Non"; restore=$(expr $restore + 1) ;&
42) { echo -n 42 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk_not_press_key justumen "Lister maintenant toutes les permissions des éléments du répertoire courant qui commencent par un 'i' et finissent par un 's'."; restore=$(expr $restore + 1) ;&
43) { echo -n 43 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; answer_run "ls -l i*s" justumen "Non"; restore=$(expr $restore + 1) ;&
44) { echo -n 44 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Avec ${code}i*s${reset}, seul le fichier 'intrus' rentre dans les critères de sélection."; restore=$(expr $restore + 1) ;&
45) { echo -n 45 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Dans le cas de ce fichier 'intrus', ${code}*${reset} remplacera la chaine de caractère 'ntru'."; restore=$(expr $restore + 1) ;&
46) { echo -n 46 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Si vous avez besoin d'un ciblage plus en finesse, vous pouvez utiliser un autre ${voc}joker${reset} : le ${code}?${reset}."; restore=$(expr $restore + 1) ;&
47) { echo -n 47 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "${code}?${reset} ne remplace lui qu'${voc}un${reset} seul caractère !"; restore=$(expr $restore + 1) ;&
48) { echo -n 48 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk_not_press_key justumen "Essayer donc cette commande : ${learn}ls -l f?${reset}"; restore=$(expr $restore + 1) ;&
49) { echo -n 49 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; answer_run "ls -l f?" justumen "Non"; restore=$(expr $restore + 1) ;&
50) { echo -n 50 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Ici 'f10' et 'f50' ne s'affichent pas, car il y a deux caractères après la lettre f."; restore=$(expr $restore + 1) ;&
51) { echo -n 51 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk_not_press_key justumen "Affichez donc ces deux fichiers, en faisant : ${learn}ls -l f??${reset}"; restore=$(expr $restore + 1) ;&
52) { echo -n 52 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; answer_run "ls -l f??" justumen "Non"; restore=$(expr $restore + 1) ;&
53) { echo -n 53 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk_not_press_key justumen "Mais qu'en est-il du fichier 'f' ? Affichez donc ses permissions."; restore=$(expr $restore + 1) ;&
54) { echo -n 54 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; answer_run "ls -l f" justumen "Non"; restore=$(expr $restore + 1) ;&
55) { echo -n 55 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Le fichier 'f' existe bel et bien, mais ne s'est pas affiché lors de nos dernières commandes avec ${code}?${reset}..."; restore=$(expr $restore + 1) ;&
56) { echo -n 56 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "${code}?${reset} remplace exactement ${code}un${reset} caractère, ni plus, ni moins."; restore=$(expr $restore + 1) ;&
57) { echo -n 57 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk_not_press_key justumen "Essayez donc avec : ls ${learn}f*${reset}"; restore=$(expr $restore + 1) ;&
58) { echo -n 58 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; answer_run "ls f*" justumen "Non"; restore=$(expr $restore + 1) ;&
59) { echo -n 59 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Ici même s'il n'y a aucun caractère après le f, le fichier 'f' s'affiche."; restore=$(expr $restore + 1) ;&
60) { echo -n 60 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "C'est tout simplement parce que ${code}*${reset} peut aussi représenter une chaine de caractère vide !"; restore=$(expr $restore + 1) ;&
61) { echo -n 61 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk_not_press_key justumen "Pour afficher les permissions de tous les fichiers avec un nom d'une lettre, vous pouvez utiliser : ${learn}ls -l ?${reset}"; restore=$(expr $restore + 1) ;&
62) { echo -n 62 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; answer_run "ls -l ?" justumen "Non"; restore=$(expr $restore + 1) ;&
63) { echo -n 63 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Ici 'f' est notre seul fichier avec un nom d'une lettre."; restore=$(expr $restore + 1) ;&
64) { echo -n 64 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Attention donc lorsque vous utilisez ces ${voc}jokers${reset}, surtout avec des commandes ${voc}destructrices${reset} !"; restore=$(expr $restore + 1) ;&
65) { echo -n 65 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Une commande comme ${learn}rm *${reset} peut avoir de graves conséquences."; restore=$(expr $restore + 1) ;&
66) { echo -n 66 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk_not_press_key justumen "Maintenant que ces deux nouveaux symboles sont acquis, affichez le contenu du fichier 'f'."; restore=$(expr $restore + 1) ;&
67) { echo -n 67 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; answer_run "cat f" justumen "Non"; restore=$(expr $restore + 1) ;&
68) { echo -n 68 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Lorque vous utilisez la commande ${code}cat${reset} vous affichez en fait les ${voc}données${reset} du fichier 'f'. (data en anglais)"; restore=$(expr $restore + 1) ;&
69) { echo -n 69 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk_not_press_key justumen "Affichez maintenant les résultats de ${learn}ls -l f${reset}."; restore=$(expr $restore + 1) ;&
70) { echo -n 70 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; answer_run "ls -l f" justumen "Non"; restore=$(expr $restore + 1) ;&
71) { echo -n 71 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Les informations qui s'affichent ici sont les ${voc}métadonnées${reset} du fichier 'f'. (metadata en anglais)"; restore=$(expr $restore + 1) ;&
72) { echo -n 72 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Les ${voc}métadonnées${reset} sont des informations sur des données !"; restore=$(expr $restore + 1) ;&
73) { echo -n 73 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "${learn}ls -l${reset} vous affiche donc des ${voc}métadonnées${reset}."; restore=$(expr $restore + 1) ;&
74) { echo -n 74 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Prenons cet exemple : -rw------- 1 umen team 10 Feb 20 16:16 f"; restore=$(expr $restore + 1) ;&
75) { echo -n 75 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Dans cet affichage, il y a en fait 7 colonnes."; restore=$(expr $restore + 1) ;&
76) { echo -n 76 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "${codeFile}-rw-------${reset} 1 umen team 10 Feb 20 16:16 f : Vous connaissez déjà la première colonne, il s'agit du type de l'élément et de ses permissions."; restore=$(expr $restore + 1) ;&
77) { echo -n 77 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "-rw------- ${codeFile}1${reset} umen team 10 Feb 20 16:16 f : La deuxième colonne est un nombre qui compte le nombre de liens ou de répertoires dans un élément."; restore=$(expr $restore + 1) ;&
78) { echo -n 78 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Mais nous reviendrons sur ce nombre dans un autre chapitre, ignorez le pour le moment."; restore=$(expr $restore + 1) ;&
79) { echo -n 79 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "-rw------- 1 ${codeFile}umen${reset} team 10 Feb 20 16:16 f : La troisième colonne est je le rappelle le nom du propriétaire."; restore=$(expr $restore + 1) ;&
80) { echo -n 80 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "-rw------- 1 umen ${codeFile}team${reset} 10 Feb 20 16:16 f : La quatrième colonne est je le rappelle le nom du groupe."; restore=$(expr $restore + 1) ;&
81) { echo -n 81 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "-rw------- 1 umen team ${codeFile}10${reset} Feb 20 16:16 f : La cinquième colonne est la ${voc}taille${reset} en ${voc}octet${reset} du fichier. (octect = byte en anglais)"; restore=$(expr $restore + 1) ;&
82) { echo -n 82 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Pour rappel : un octet est égal à 8 bits. Et un bit ne peut avoir que deux valeurs, 0 ou 1."; restore=$(expr $restore + 1) ;&
83) { echo -n 83 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Ce fichier de 10 octets fait donc 80 bits !"; restore=$(expr $restore + 1) ;&
84) { echo -n 84 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Pour information, le contenu de notre fichier 'f' est égal en binaire à ça : 01100011 01101111 01101110 01110100 01100101 01101110 01110101 00100000 01100110 00001010"; restore=$(expr $restore + 1) ;&
85) { echo -n 85 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "-rw------- 1 umen team 10 ${codeFile}Feb 20 16:16${reset} f : La sixième colonne est la date de la dernière modification du fichier."; restore=$(expr $restore + 1) ;&
86) { echo -n 86 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "-rw------- 1 umen team 10 Feb 20 16:16 ${codeFile}f${reset} : Et la dernière colonne est simplement le nom du fichier."; restore=$(expr $restore + 1) ;&
87) { echo -n 87 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Dans le chapitre précédent, vous aviez déjà utilisé la commande ${code}touch${reset} pour créer un fichier."; restore=$(expr $restore + 1) ;&
88) { echo -n 88 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Effectivement, avec ${code}touch${reset}, si le fichier donné en argument n'existe pas il sera créé."; restore=$(expr $restore + 1) ;&
89) { echo -n 89 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Mais le but premier de cette commande est de changer cette métadonnée de dernière modification. -rw------- 1 umen team 10 ${codeFile}Feb 20 16:16${reset} f"; restore=$(expr $restore + 1) ;&
90) { echo -n 90 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk_not_press_key justumen "Pour actualisez la date de dernière modification de 'f' faites : ${learn}touch f${reset}"; restore=$(expr $restore + 1) ;&
91) { echo -n 91 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; answer_run "touch f" justumen "Non"; restore=$(expr $restore + 1) ;&
92) { echo -n 92 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk_not_press_key justumen "Faites donc maintenant : ${learn}ls -l${reset}"; restore=$(expr $restore + 1) ;&
93) { echo -n 93 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; answer_run "ls -l" justumen "Non"; restore=$(expr $restore + 1) ;&
94) { echo -n 94 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "La date de dernière modification de 'f' est effectivement la plus récente."; restore=$(expr $restore + 1) ;&
95) { echo -n 95 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk_not_press_key justumen "Pour afficher la date du moment il suffit de lancer la commande : ${learn}date${reset}"; restore=$(expr $restore + 1) ;&
96) { echo -n 96 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; answer_run "date" justumen "Non"; restore=$(expr $restore + 1) ;&
97) { echo -n 97 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "La commande ${code}touch${reset} a donc bien eu son effet."; restore=$(expr $restore + 1) ;&
98) { echo -n 98 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk_not_press_key justumen "Affichez maintenant le contenu du fichier 'intrus'."; restore=$(expr $restore + 1) ;&
99) { echo -n 99 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; answer_run "cat intrus" justumen "Non"; restore=$(expr $restore + 1) ;&
100) { echo -n 100 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk_not_press_key justumen "Lancez enfin : ${learn}ls -l intrus${reset}"; restore=$(expr $restore + 1) ;&
101) { echo -n 101 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; answer_run "ls -l intrus" justumen "Non"; restore=$(expr $restore + 1) ;&
102) { echo -n 102 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "La date ici n'a pas changé, malgré l'utilisation de la commande ${code}cat${reset} sur ce fichier."; restore=$(expr $restore + 1) ;&
103) { echo -n 103 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Sans autre options, ${learn}ls -l${reset} affiche la dernière date de ${voc}modification${reset}, pas la dernière date ${voc}d'accès${reset}."; restore=$(expr $restore + 1) ;&
104) { echo -n 104 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Et évidemment, ${code}cat${reset} ne fait qu'afficher le fichier sans le modifier, donc la date ne change pas."; restore=$(expr $restore + 1) ;&
105) { echo -n 105 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Et maintenant nous allons revenir rapidement sur les permissions, en particulier sur la commande ${code}chmod${reset}."; restore=$(expr $restore + 1) ;&
106) { echo -n 106 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Nous avons déjà vu comment utiliser ${code}chmod${reset} avec des lettres : r, w, x, u, g, o."; restore=$(expr $restore + 1) ;&
107) { echo -n 107 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Mais il est aussi possible d'utiliser ${code}chmod${reset} avec 3 chiffres !"; restore=$(expr $restore + 1) ;&
108) { echo -n 108 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "A chaque lettre correspond une valeur numérique, la lettre 'r' sera 4, 'w' sera 2 et 'x' sera 1."; restore=$(expr $restore + 1) ;&
109) { echo -n 109 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Il faudra ensuite faire l'addition des permissions, 'rw-' sera donc 4+2=${voc}6${reset}, 'r-x' sera 4+1=${voc}5${reset}, 'r--' sera ${voc}4${reset}, 'rwx' sera 4+2+1=${voc}7${reset}, '---' sera bien évidemment ${voc}0${reset}, etc..."; restore=$(expr $restore + 1) ;&
110) { echo -n 110 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Vous devez utiliser trois de ces sommes pour respectivement : le propriétaire, le groupe et les autres."; restore=$(expr $restore + 1) ;&
111) { echo -n 111 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Par exemple, sur le fichier 'test', pour donner tous les droits au propriétaire mais aucun au reste, il faudra faire ${learn}chmod 700 test${reset}"; restore=$(expr $restore + 1) ;&
112) { echo -n 112 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "${codeFile}7${reset}00 donne toutes les permissions au propriétaire : ${codeFile}rwx${reset}"; restore=$(expr $restore + 1) ;&
113) { echo -n 113 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "7${codeFile}0${reset}0 ne donne aucune permission au groupe : ${codeFile}---${reset}"; restore=$(expr $restore + 1) ;&
114) { echo -n 114 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "70${codeFile}0${reset} ne donne aucune permission aux autres : ${codeFile}---${reset}"; restore=$(expr $restore + 1) ;&
115) { echo -n 115 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "${codeFile}700${reset} est donc équivalent à ${codeFile}rwx------${reset}."; restore=$(expr $restore + 1) ;&
116) { echo -n 116 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk_not_press_key justumen "Donnez donc les droits rw-r--r-- à tous les éléments de deux lettres du répertoire courant, en utilisant chmod et ses chiffres."; restore=$(expr $restore + 1) ;&
117) { echo -n 117 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; answer_run "chmod 644 ??" justumen "Non"; restore=$(expr $restore + 1) ;&
118) { echo -n 118 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk_not_press_key justumen "Voyons le résultat avec : ${learn}ls -l${reset}"; restore=$(expr $restore + 1) ;&
119) { echo -n 119 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; answer_run "ls -l" justumen "Non"; restore=$(expr $restore + 1) ;&
120) { echo -n 120 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Vous avez peut être remarqué que la commande ${learn}chmod 644 ??${reset} n'a pas d'équivalent avec des lettres."; restore=$(expr $restore + 1) ;&
121) { echo -n 121 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Ou plutôt qu'il faut plusieures commandes pour avoir le même effet."; restore=$(expr $restore + 1) ;&
122) { echo -n 122 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Il faudra d'abord réinitialiser toutes les permissions à 0 avec ${learn}chmod ugo-rwx ??${reset}."; restore=$(expr $restore + 1) ;&
123) { echo -n 123 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Ensuite ${learn}chmod ugo+r ??${reset} pour faire l'équivalent de ${learn}chmod 444 ??${reset}."; restore=$(expr $restore + 1) ;&
124) { echo -n 124 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Et il faudra ensuite transformer ${code}444${reset} en ${code}644${reset} avec ${learn}chmod u+w ??${reset}."; restore=$(expr $restore + 1) ;&
125) { echo -n 125 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Cependant l'inverse n'est pas du tout possible, ${code}u+w${reset} n'a pas d'équivalent en chiffre, parce que le résultat dépendra des permissions précédentes."; restore=$(expr $restore + 1) ;&
126) { echo -n 126 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Les deux méthodes ne sont pas pas équivalentes !"; restore=$(expr $restore + 1) ;&
127) { echo -n 127 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Ca sera donc à vous de choisir quelle méthode vous souhaitez utiliser, en fonction de votre situation."; restore=$(expr $restore + 1) ;&
128) { echo -n 128 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Et pour en terminer avec les bases sur les permissions, nous allons voir comment changer de propriétaire et de groupe."; restore=$(expr $restore + 1) ;&
129) { echo -n 129 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "La commande à utiliser sera : ${code}chown${reset}, abréviation anglaise de : ${code}ch${reset}ange ${code}own${reset}er."; restore=$(expr $restore + 1) ;&
130) { echo -n 130 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk_not_press_key justumen "Pour mettre ${voc}root${reset} comme propriétaire du fichier 'f' vous pouvez simplement taper : ${learn}chown root f${reset}"; restore=$(expr $restore + 1) ;&
131) { echo -n 131 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; answer_run "chown root f" justumen "Non"; restore=$(expr $restore + 1) ;&
132) { echo -n 132 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Ici cette commande ne fonctionne pas ! C'est encore une fois un problème de permission, mais qui n'est pas du même type."; restore=$(expr $restore + 1) ;&
133) { echo -n 133 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Par mesure de sécurité, certaines commandes peuvent uniquement être utilisées par l'utilisateur administrateur : ${voc}root${reset}."; restore=$(expr $restore + 1) ;&
134) { echo -n 134 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "${code}chown${reset} est l'une d'entre elles, c'est une commande que seul ${voc}root${reset} peut utiliser !"; restore=$(expr $restore + 1) ;&
135) { echo -n 135 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Mais je ne vous demanderai pas votre mot de passe ${voc}root${reset} dans GameScript."; restore=$(expr $restore + 1) ;&
136) { echo -n 136 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Je vous invite donc à tester cette commande ${code}chown${reset} plus tard, en root, par vous même dans un autre terminal !"; restore=$(expr $restore + 1) ;&
137) { echo -n 137 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Pour vous connectez en ${code}root${reset} vous pouvez faire : ${learn}su root${reset}. Votre mot de passe vous sera alors demandé et vous aurez votre terminal en ${code}root${reset}."; restore=$(expr $restore + 1) ;&
138) { echo -n 138 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Pour tester si vous êtes bien ${voc}root${reset} vous pouvez utiliser la commande : ${learn}whoami${reset}."; restore=$(expr $restore + 1) ;&
139) { echo -n 139 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Si vous voulez changer le ${voc}groupe${reset} il faudra utiliser le symbole ${code}:${reset}, comme par exemple ${learn}chown :familleEinstein f${reset}."; restore=$(expr $restore + 1) ;&
140) { echo -n 140 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Et bien évidemment vous pouvez changer les deux en même temps, comme par exemple ${learn}chown albert:familleEinstein f${reset}."; restore=$(expr $restore + 1) ;&
141) { echo -n 141 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Attention cependant à toutes les commandes que vous lancez en ${voc}root${reset} !"; restore=$(expr $restore + 1) ;&
142) { echo -n 142 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "${voc}root${reset} possède TOUTES les permissions pour TOUS les éléments !"; restore=$(expr $restore + 1) ;&
143) { echo -n 143 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "${voc}root${reset} est non seulement capable de supprimer tous vos fichiers, mais il a aussi le pouvoir de rendre votre système inutilisable !"; restore=$(expr $restore + 1) ;&
144) { echo -n 144 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Une commande maladroite en ${voc}root${reset}, ou un script malicieux en ${voc}root${reset} peuvent avoir des effets dévastateurs."; restore=$(expr $restore + 1) ;&
145) { echo -n 145 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Vous maitrisez maintenant tout ce qu'il vous faut pour analyser et maitriser vos permissions."; restore=$(expr $restore + 1) ;&
146) { echo -n 146 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; talk justumen "Bonne chance pour le questionnaire !"; restore=$(expr $restore + 1) ;&
147) { echo -n 147 > $HOME/.GameScript/restore_bash6; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; } 2>/dev/null ; clean; restore=$(expr $restore + 1) ;&
esac
}
function clean(){ #in enter_chapter
rm $HOME/.GameScript/restore_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
rm $HOME/.GameScript/restore_pwd_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
	chmod -R 744 $HOME/.GameScript_bash6 2> /dev/null
	rm $HOME/.GameScript_bash6/f 2> /dev/null
	rm $HOME/.GameScript_bash6/f1 2> /dev/null
	rm $HOME/.GameScript_bash6/f2 2> /dev/null
	rm $HOME/.GameScript_bash6/f3 2> /dev/null
	rm $HOME/.GameScript_bash6/f4 2> /dev/null
	rm $HOME/.GameScript_bash6/f10 2> /dev/null
	rm $HOME/.GameScript_bash6/f50 2> /dev/null
	rm $HOME/.GameScript_bash6/intrus 2> /dev/null
	rmdir $HOME/.GameScript_bash6 2> /dev/null
}

function start_quiz(){
  start_quiz_music
  echo ""
  echo -e "\e[15;44m Bash 'Bourne Again SHell' : Questionnaire du chapitre 6 \e[0m"
  echo -e "- La réponse doit être la plus courte possible, une commande valide mais ajoutant des caractères inutiles ne fonctionnera pas."
  echo -e "Exemple : si la réponse est 'ls'. Les réponses 'ls .', 'ls ./' et 'ls ././' seront considérées comme fausses."
  answer_text_fr "Dans un terminal root, comment définir 'albert' comme propriétaire et 'familleEinstein' comme groupe au fichier 'test' du répertoire courant ?" "chown albert:familleEinstein test"
  answer_text_fr "Quelle commande affiche les éléments du répertoire courant par ordre alphabétique ?" "ls"
  answer_text_fr "Quelle commande affiche les métadonnées des éléments du répertoire courant ?" "ls -l"
  answer_text_fr "Comment afficher tous les éléments du répertoire courant dont le nom commence par 'x' ?" "ls x*"
  answer_text_fr "Comment supprimer tous les éléments du répertoire courant ayant un nom de 2 lettres ?" "rm ??"
  answer_text_fr "Comment déplacer tous les éléments du répertoire courant qui finissent par '.html' dans le répertoire parent de votre répertoire parent ?" "mv *.html ../.."
  answer_text_fr "Comment donner au fichier 'test' les permissions : --x-----x ?" "chmod 101 test"
  answer_text_fr "Comment donner au fichier 'test' les permissions : rwxr-x-wx ?" "chmod 753 test"
  unlock "bash" "6" "8239" "df22"
}


CHAPTER_NAME="bash"
CHAPTER_NUMBER="6"
LANGUAGE="fr"
SPEAKER="m1"

LINES=146
if [ "$1" == "VIDEO" ]; then
	prepare_video
else
	if [ ! "$1" == "MUTE" ]; then
		prepare_audio
	fi
fi


enter_chapter $CHAPTER_NAME $CHAPTER_NUMBER
