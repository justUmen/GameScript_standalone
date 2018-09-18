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
				stop_quiz_music
				#enter_chapter $CHAPTER_NAME $CHAPTER_NUMBER
				exit ;;
			en) talk_not_press_key justumen "\\e[4;37mSorry answer wrong or too long. I recommend you to do / re-do the lecture :-)\nIf you think you already understand the content of the lecture, this question is probably a trap, read the question again carefully. :-)\nIf you feel stuck, ask for help in our chat : https://rocket.bjornulf.org or our discord : https://discord.gg/25eRgvD\\e[0m"
				#enter_chapter $CHAPTER_NAME $CHAPTER_NUMBER
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
command -v mplayer &> /dev/null && SOUNDPLAYER_MUSIC_QUIZ="mplayer -volume 99" || SOUNDPLAYER_MUSIC_QUIZ="mpg123"

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
				;;
		en) #echo -e "To unlock '$1 $2' on rocketchat (https://rocket.bjornulf.org), open a private conversation with '@boti' and copy/paste :\n\t\e[97;42mpassword$PASS\e[0m"
			echo -e "To unlock '$1 $2' on discord (https://discord.gg/Dj47Tpf), open the channel '#passwords-boti' and copy/paste :\n\t\e[97;42mpassword$PASS\e[0m"
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
1) echo -n 1 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; [ -d "$HOME/.GameScript_bash4" ] && echo "Erreur inattendue, ${HOME}/.GameScript_bash4 existe déjà sur votre système ! Supprimez ce dossier $HOME/.GameScript_bash4 et relancez ce script." && exit; restore=$(expr $restore + 1) ;&
2) echo -n 2 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; mkdir $HOME/.GameScript_bash4 2> /dev/null; restore=$(expr $restore + 1) ;&
3) echo -n 3 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; cd $HOME/.GameScript_bash4; restore=$(expr $restore + 1) ;&
4) echo -n 4 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Dans le chapitre précédent, nous avons vu comment créer et modifier les fichiers textes."; restore=$(expr $restore + 1) ;&
5) echo -n 5 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Ici nous allons continuer avec d'autres types de contrôles."; restore=$(expr $restore + 1) ;&
6) echo -n 6 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk_not_press_key justumen "Commençons par créer un nouveau fichier 'test' avec comme contenu le mot 'bonjour'."; restore=$(expr $restore + 1) ;&
7) echo -n 7 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; answer_run "echo bonjour>test" justumen "Non"; restore=$(expr $restore + 1) ;&
8) echo -n 8 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk_not_press_key justumen "Créez un nouveau dossier nommé 'DIR'."; restore=$(expr $restore + 1) ;&
9) echo -n 9 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; answer_run "mkdir DIR" justumen "Non"; restore=$(expr $restore + 1) ;&
10) echo -n 10 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk_not_press_key justumen "Affichez les éléments du répertoire courant."; restore=$(expr $restore + 1) ;&
11) echo -n 11 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; answer_run "ls" justumen "Non"; restore=$(expr $restore + 1) ;&
12) echo -n 12 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Pour déplacer un fichier il faudra utiliser la commande ${code}mv${reset}."; restore=$(expr $restore + 1) ;&
13) echo -n 13 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "'m' et 'v' sont les consonnes de 'move', le mot anglais pour 'déplacer'."; restore=$(expr $restore + 1) ;&
14) echo -n 14 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk_not_press_key justumen "Déplacez donc ce fichier 'test' dans le dossier DIR avec la commande : ${learn}mv test DIR${reset}"; restore=$(expr $restore + 1) ;&
15) echo -n 15 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; answer_run "mv test DIR" justumen "Non"; restore=$(expr $restore + 1) ;&
16) echo -n 16 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk_not_press_key justumen "Affichez les éléments du dossier 'DIR'."; restore=$(expr $restore + 1) ;&
17) echo -n 17 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; answer_run "ls DIR" justumen "Non"; restore=$(expr $restore + 1) ;&
18) echo -n 18 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk_not_press_key justumen "Déplacez votre terminal dans le dossier 'DIR'."; restore=$(expr $restore + 1) ;&
19) echo -n 19 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; answer_run "cd DIR" justumen "Non"; restore=$(expr $restore + 1) ;&
20) echo -n 20 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk_not_press_key justumen "Affichez le chemin absolu du répertoire courant."; restore=$(expr $restore + 1) ;&
21) echo -n 21 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; answer_run "pwd" justumen "Non"; restore=$(expr $restore + 1) ;&
22) echo -n 22 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk_not_press_key justumen "Affichez les éléments du répertoire courant."; restore=$(expr $restore + 1) ;&
23) echo -n 23 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; answer_run "ls" justumen "Non"; restore=$(expr $restore + 1) ;&
24) echo -n 24 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Ici le fichier 'test' a bien été déplacé dans le répertoire 'DIR' avec cette commande : ${learn}mv test DIR${reset}"; restore=$(expr $restore + 1) ;&
25) echo -n 25 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Dans cet exemple, notre premier argument est un fichier et le second est un dossier."; restore=$(expr $restore + 1) ;&
26) echo -n 26 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Comme le deuxième argument est un dossier, la commande aurait pu être : ${learn}mv test DIR/${reset}"; restore=$(expr $restore + 1) ;&
27) echo -n 27 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Cette version est nettement plus lisible que la première."; restore=$(expr $restore + 1) ;&
28) echo -n 28 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Parce que ${code}mv${reset} peut avoir indifféremment en arguments des fichiers ou des dossiers."; restore=$(expr $restore + 1) ;&
29) echo -n 29 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Mais si le premier argument est un fichier et que le deuxième n'est pas un dossier, la commande agira différemment : cette fois le premier argument sera ${voc}renommé${reset}."; restore=$(expr $restore + 1) ;&
30) echo -n 30 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Attention donc à bien comprendre votre environnement."; restore=$(expr $restore + 1) ;&
31) echo -n 31 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Dans votre répertoire courant vous avez toujours ce fichier 'test'."; restore=$(expr $restore + 1) ;&
32) echo -n 32 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk_not_press_key justumen "Utilisez cette commande pour renommer 'test' en 'test2' : ${learn}mv test test2${reset}"; restore=$(expr $restore + 1) ;&
33) echo -n 33 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; answer_run "mv test test2" justumen "Non"; restore=$(expr $restore + 1) ;&
34) echo -n 34 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk_not_press_key justumen "Affichez les éléments du répertoire courant."; restore=$(expr $restore + 1) ;&
35) echo -n 35 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; answer_run "ls" justumen "Non"; restore=$(expr $restore + 1) ;&
36) echo -n 36 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk_not_press_key justumen "Affichez le contenu du fichier 'test2'."; restore=$(expr $restore + 1) ;&
37) echo -n 37 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; answer_run "cat test2" justumen "Non"; restore=$(expr $restore + 1) ;&
38) echo -n 38 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Le contenu est bien toujours le même, seul le nom du fichier à changé."; restore=$(expr $restore + 1) ;&
39) echo -n 39 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk_not_press_key justumen "Maintenant créez un nouveau dossier nommé : 'DOS'."; restore=$(expr $restore + 1) ;&
40) echo -n 40 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; answer_run "mkdir DOS" justumen "Non"; restore=$(expr $restore + 1) ;&
41) echo -n 41 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Je le répète, ${code}mv${reset} peut avoir indifféremment en arguments des fichiers ou des dossiers."; restore=$(expr $restore + 1) ;&
42) echo -n 42 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "C'est à dire que si le premier argument est un dossier, et que le second n'existe pas, ${code}mv${reset} va encore une fois simplement renommer le dossier en argument."; restore=$(expr $restore + 1) ;&
43) echo -n 43 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk_not_press_key justumen "Renommez donc ce dossier 'DOS' en 'DOS2'."; restore=$(expr $restore + 1) ;&
44) echo -n 44 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; answer_run "mv DOS DOS2" justumen "Non"; restore=$(expr $restore + 1) ;&
45) echo -n 45 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk_not_press_key justumen "Et affichez les éléments du répertoire courant."; restore=$(expr $restore + 1) ;&
46) echo -n 46 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; answer_run "ls" justumen "Non"; restore=$(expr $restore + 1) ;&
47) echo -n 47 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Attention donc à la commande ${code}mv${reset} qui peut avoir deux rôles différents : déplacer et renommer."; restore=$(expr $restore + 1) ;&
48) echo -n 48 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "${code}mv${reset} peut également faire les deux en une seule commande."; restore=$(expr $restore + 1) ;&
49) echo -n 49 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk_not_press_key justumen "Déplacez 'test2' dans le dossier 'DOS2' et renommez le en 'test3' avec : ${learn}mv test2 DOS2/test3${reset}"; restore=$(expr $restore + 1) ;&
50) echo -n 50 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; answer_run "mv test2 DOS2/test3" justumen "Non"; restore=$(expr $restore + 1) ;&
51) echo -n 51 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk_not_press_key justumen "Affichez les éléments du répertoire DOS2."; restore=$(expr $restore + 1) ;&
52) echo -n 52 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; answer_run "ls DOS2" justumen "Non"; restore=$(expr $restore + 1) ;&
53) echo -n 53 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Le fichier 'test2' a bien été déplacé dans DOS2 et renommé en 'test3'."; restore=$(expr $restore + 1) ;&
54) echo -n 54 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk_not_press_key justumen "Affichez le contenu de ce fichier 'test3'."; restore=$(expr $restore + 1) ;&
55) echo -n 55 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; answer_run "cat DOS2/test3" justumen "Non"; restore=$(expr $restore + 1) ;&
56) echo -n 56 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Le contenu est toujours identique."; restore=$(expr $restore + 1) ;&
57) echo -n 57 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Si vous ajoutez le texte 'tout le monde' à la suite de ce fichier, le texte sera ajouté sur une nouvelle ligne."; restore=$(expr $restore + 1) ;&
58) echo -n 58 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Parce que lorsque vous utilisez ${code}echo${reset}, il ajoutera par défaut une mise à la ligne à la fin."; restore=$(expr $restore + 1) ;&
59) echo -n 59 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Si vous ne voulez pas de cette mise à la ligne, il faudra utiliser l'option ${learn}-n${reset} de la commande ${code}echo${reset}."; restore=$(expr $restore + 1) ;&
60) echo -n 60 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk_not_press_key justumen "Remplacez donc le contenu du fichier 'test3' par 'bonjour', mais sans ce retour à la ligne automatique à la fin."; restore=$(expr $restore + 1) ;&
61) echo -n 61 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; answer_run "echo -n bonjour>DOS2/test3" justumen "Non"; restore=$(expr $restore + 1) ;&
62) echo -n 62 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk_not_press_key justumen "Maintenant ajoutez le texte ' tout le monde' à ce fichier 'test3', en utilisant ${learn}\"${reset}."; restore=$(expr $restore + 1) ;&
63) echo -n 63 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; answer_run "echo \" tout le monde\">>DOS2/test3" justumen "Non"; restore=$(expr $restore + 1) ;&
64) echo -n 64 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk_not_press_key justumen "Et enfin, affichez le contenu de 'test3'."; restore=$(expr $restore + 1) ;&
65) echo -n 65 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; answer_run "cat DOS2/test3" justumen "Non"; restore=$(expr $restore + 1) ;&
66) echo -n 66 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Et voilà, bonjour tout le monde !"; restore=$(expr $restore + 1) ;&
67) echo -n 67 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Quand une commande ne fait pas exactement ce que voulez qu'elle fasse, visitez son manuel !"; restore=$(expr $restore + 1) ;&
68) echo -n 68 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Il est très probable qu'une simple option soit la réponse à votre problème."; restore=$(expr $restore + 1) ;&
69) echo -n 69 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "${code}mv${reset} utilise deux arguments, le premier est la ${voc}<SOURCE>${reset} et le deuxième est la ${voc}<DESTINATION>${reset}."; restore=$(expr $restore + 1) ;&
70) echo -n 70 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Et la syntaxe comme on l'a déjà vu est : ${code}mv <SOURCE> <DESTINATION>${reset}"; restore=$(expr $restore + 1) ;&
71) echo -n 71 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "${voc}<SOURCE>${reset} et ${voc}<DESTINATION>${reset} sont à remplacer par les fichiers ou les dossiers voulus."; restore=$(expr $restore + 1) ;&
72) echo -n 72 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Lorsqu'une commande a besoin de deux arguments, la plupart du temps cette logique s'applique."; restore=$(expr $restore + 1) ;&
73) echo -n 73 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Le premier argument est la ${voc}source${reset}, le second est la ${voc}destination${reset}."; restore=$(expr $restore + 1) ;&
74) echo -n 74 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Pour ${voc}copier${reset} ou ${voc}dupliquer${reset} un fichier, il faudra utiliser la commande ${code}cp${reset}."; restore=$(expr $restore + 1) ;&
75) echo -n 75 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Son comportement est sensiblement identique à ${code}mv${reset}, sauf que le fichier ${voc}<SOURCE>${reset} ne sera pas supprimé."; restore=$(expr $restore + 1) ;&
76) echo -n 76 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk_not_press_key justumen "Affichez les éléments du répertoire courant."; restore=$(expr $restore + 1) ;&
77) echo -n 77 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; answer_run "ls" justumen "Non"; restore=$(expr $restore + 1) ;&
78) echo -n 78 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk_not_press_key justumen "Copiez donc le fichier 'test3' dans votre répertoire courant."; restore=$(expr $restore + 1) ;&
79) echo -n 79 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; answer_run "cp DOS2/test3 ." justumen "Non"; restore=$(expr $restore + 1) ;&
80) echo -n 80 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Et ici nous avons notre première utilisation pratique du ${code}.${reset}, qui je vous le rappelle représente le répertoire courant."; restore=$(expr $restore + 1) ;&
81) echo -n 81 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk_not_press_key justumen "Listez à nouveau les éléments du répertoire courant."; restore=$(expr $restore + 1) ;&
82) echo -n 82 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; answer_run "ls" justumen "Non"; restore=$(expr $restore + 1) ;&
83) echo -n 83 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Encore une fois ${code}.${reset} étant un dossier, vous pouvez également utiliser ${code}./${reset} à la place."; restore=$(expr $restore + 1) ;&
84) echo -n 84 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk_not_press_key justumen "Maintenant testez cette commande : ${learn}cp DOS2/test3 .new${reset}"; restore=$(expr $restore + 1) ;&
85) echo -n 85 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; answer_run "cp DOS2/test3 .new" justumen "Non"; restore=$(expr $restore + 1) ;&
86) echo -n 86 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk_not_press_key justumen "Puis listez les éléments du répertoire courant."; restore=$(expr $restore + 1) ;&
87) echo -n 87 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; answer_run "ls" justumen "Non"; restore=$(expr $restore + 1) ;&
88) echo -n 88 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Ce résultat ne devrait pas vous choquer."; restore=$(expr $restore + 1) ;&
89) echo -n 89 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Encore une fois, ${code}.new${reset} et ${code}./new${reset} représentent deux choses différentes."; restore=$(expr $restore + 1) ;&
90) echo -n 90 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "${code}.new${reset} est bien évidemment un fichier caché."; restore=$(expr $restore + 1) ;&
91) echo -n 91 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk_not_press_key justumen "Listez les fichiers cachés du répertoire courant."; restore=$(expr $restore + 1) ;&
92) echo -n 92 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; answer_run "ls -a" justumen "Non"; restore=$(expr $restore + 1) ;&
93) echo -n 93 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Si vous voulez copier le fichier 'test3' et renommer cette copie en 'new' dans le répertoire courant, la commande serait : ${learn}cp DOS2/test3 ./new${reset}."; restore=$(expr $restore + 1) ;&
94) echo -n 94 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Ici la commande ${learn}cp DOS2/test3 .new${reset} est identique à ${learn}cp DOS2/test3 ./.new${reset}."; restore=$(expr $restore + 1) ;&
95) echo -n 95 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Il est aussi possible d'avoir plusieures commandes sur une seule ligne, il suffit de les séparer par des ${code};${reset}."; restore=$(expr $restore + 1) ;&
96) echo -n 96 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk_not_press_key justumen "Essayez donc d'afficher 'a', puis sur une autre ligne 'b'. Avec deux commandes et un ${code};${reset}."; restore=$(expr $restore + 1) ;&
97) echo -n 97 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; answer_run "echo a;echo b" justumen "Non"; restore=$(expr $restore + 1) ;&
98) echo -n 98 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk_not_press_key justumen "Maintenant, essayez de vous déplacer dans le dossier DOS et de créer un dossier NEW à l'intérieur."; restore=$(expr $restore + 1) ;&
99) echo -n 99 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; answer_run "cd DOS;mkdir NEW" justumen "Non"; restore=$(expr $restore + 1) ;&
100) echo -n 100 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk_not_press_key justumen "Listez les éléments de votre répertoire courant."; restore=$(expr $restore + 1) ;&
101) echo -n 101 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; answer_run "ls" justumen "Non"; restore=$(expr $restore + 1) ;&
102) echo -n 102 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Avec ${code};${reset}, quel que soit le résultat de la première commande, la deuxième se lancera."; restore=$(expr $restore + 1) ;&
103) echo -n 103 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Ici le dossier 'DOS' n'existait pas, pourtant la commande ${learn}mkdir NEW${reset} a été lancée dans ${code}.${reset}."; restore=$(expr $restore + 1) ;&
104) echo -n 104 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Le ${code};${reset} ne donne aucun contrôle sur l'état des commandes précédentes."; restore=$(expr $restore + 1) ;&
105) echo -n 105 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Mais vous pouvez aussi créer des conditions avant de passer à la prochaine commande."; restore=$(expr $restore + 1) ;&
106) echo -n 106 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Si vous voulez que la deuxième commande s'exécute uniquement si la première a été un succès, vous pouvez utiliser ${code}&&${reset} à la place du ${code};${reset}."; restore=$(expr $restore + 1) ;&
107) echo -n 107 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk_not_press_key justumen "Commencez par supprimer ce dossier NEW, que nous avons créé par erreur dans le mauvais répertoire."; restore=$(expr $restore + 1) ;&
108) echo -n 108 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; answer_run "rmdir NEW" justumen "Non"; restore=$(expr $restore + 1) ;&
109) echo -n 109 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk_not_press_key justumen "Maintenant, pour créer un dossier NEW dans DOS, essayez : ${learn}cd DOS&&mkdir NEW${reset}"; restore=$(expr $restore + 1) ;&
110) echo -n 110 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; answer_run "cd DOS&&mkdir NEW" justumen "Non"; restore=$(expr $restore + 1) ;&
111) echo -n 111 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk_not_press_key justumen "Listez les éléments de votre répertoire courant."; restore=$(expr $restore + 1) ;&
112) echo -n 112 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; answer_run "ls" justumen "Non"; restore=$(expr $restore + 1) ;&
113) echo -n 113 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "La commande ${learn}cd DOS${reset} renvoyant une erreur, ${code}&&${reset} a bloqué le lancement de la prochaine commande."; restore=$(expr $restore + 1) ;&
114) echo -n 114 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Cette technique est particulièrement importante si vous utilisez des commandes ${voc}destructrices${reset}, comme ${code}rm${reset}, ou ${code}echo${reset} avec le ${code}>${reset}."; restore=$(expr $restore + 1) ;&
115) echo -n 115 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Si vous ne prenez pas de précaution, vous risquez de supprimer accidentellement un fichier important."; restore=$(expr $restore + 1) ;&
116) echo -n 116 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Il est possible d'utiliser ${code};${reset} et ${code}&&${reset} avec toutes les commandes que vous connaissez déjà."; restore=$(expr $restore + 1) ;&
117) echo -n 117 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Mais il existe une autre syntaxe : ${code}||${reset}, qui fait l'inverse de ${code}&&${reset}."; restore=$(expr $restore + 1) ;&
118) echo -n 118 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "C'est à dire que la prochaine commande ne se lancera que si la précédente est un échec."; restore=$(expr $restore + 1) ;&
119) echo -n 119 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk_not_press_key justumen "Essayez donc avec une faute de frappe la commande : ${learn}lss||echo test${reset}"; restore=$(expr $restore + 1) ;&
120) echo -n 120 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; answer_run "lss||echo test" justumen "Non"; restore=$(expr $restore + 1) ;&
121) echo -n 121 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk_not_press_key justumen "Essayez la même commande, cette fois avec ${code}&&${reset} : ${learn}lss&&echo test${reset}"; restore=$(expr $restore + 1) ;&
122) echo -n 122 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; answer_run "lss&&echo test" justumen "Non"; restore=$(expr $restore + 1) ;&
123) echo -n 123 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Mais il est aussi possible d'avoir les deux conditions sur une seule ligne."; restore=$(expr $restore + 1) ;&
124) echo -n 124 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk_not_press_key justumen "Essayez cette commande : ${learn}cd DOS&&echo SUCCESS||echo ERROR${reset}"; restore=$(expr $restore + 1) ;&
125) echo -n 125 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; answer_run "cd DOS&&echo SUCCESS||echo ERROR" justumen "Non"; restore=$(expr $restore + 1) ;&
126) echo -n 126 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Si vous savez déjà programmer, cette commande peut être vu comme une condition de programmation if/else."; restore=$(expr $restore + 1) ;&
127) echo -n 127 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk_not_press_key justumen "Ici le dossier 'DOS' n'existe pas, utilisez donc DOS2 avec cette commande : ${learn}cd DOS2&&ls||pwd${reset}"; restore=$(expr $restore + 1) ;&
128) echo -n 128 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; answer_run "cd DOS2&&ls||pwd" justumen "Non"; restore=$(expr $restore + 1) ;&
129) echo -n 129 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Comme le dossier 'DOS2' existe, la commande ${learn}pwd${reset}, ne sera pas exécutée."; restore=$(expr $restore + 1) ;&
130) echo -n 130 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; talk justumen "Vous êtes prêt pour le questionnaire !"; restore=$(expr $restore + 1) ;&
131) echo -n 131 > $HOME/.GameScript/restore_bash4; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash4; clean; restore=$(expr $restore + 1) ;&
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
  echo -e "\e[15;44m Bash 'Bourne Again SHell' : Questionnaire du chapitre 4 \e[0m"
  echo -e "- La réponse doit être la plus courte possible, une commande valide mais ajoutant des caractères inutiles ne fonctionnera pas."
  echo -e "Exemple : si la réponse est 'ls'. Les réponses 'ls .', 'ls ./' et 'ls ././' seront considérées comme fausses."
  answer_text_fr "Quelle est la commande pour déplacer des fichiers ou dossiers ?" "mv"
  answer_text_fr "Quelle est la commande pour renommer des fichiers ou dossiers ?" "mv"
  answer_text_fr "Comment renommer un fichier nommé 'oui' dans votre répertoire courant en 'non' et le déplacer dans son répertoire parent ?" "mv oui ../non"
  answer_text_fr "Comment copier dans votre répertoire courant un fichier dont le chemin absolu est '/root/file' ?" "cp /root/file ."
  answer_text_fr "Comment copier un fichier caché '.file' situé dans votre répertoire parent et le renommer en un fichier non caché 'file' dans le dossier '/root' ?" "cp ../.file /root/file"
  answer_text_fr "Quel symbole doit être utilisé pour séparer simplement deux commandes sur une même ligne ?" ";"
  answer_text_fr "Comment exécuter la commande 'rm file' uniquement si la commande précédente 'cd /root' est un succès ?" "cd /root&&rm file"
  answer_text_fr "Comment afficher 'good' si la commande 'cd /root' est un succès, et 'bad' sinon ?" "cd /root&&echo good||echo bad"
  unlock "bash" "4" "a9d1" "21af"
}


CHAPTER_NAME="bash"
CHAPTER_NUMBER="4"
LANGUAGE="fr"
SPEAKER="m1"

LINES=130
if [ "$1" == "VIDEO" ]; then
	prepare_video
else
	if [ ! "$1" == "MUTE" ]; then
		prepare_audio
	fi
fi


enter_chapter $CHAPTER_NAME $CHAPTER_NUMBER
