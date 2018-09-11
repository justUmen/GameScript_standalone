#!/bin/bash
#SOME ADDED AND CHANGE IN CLI learn_cli.sh in CLASSIC
shopt -s expand_aliases
source ~/.bashrc

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
		new_video &
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
							3) exit ;;
						esac
					done
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
1) echo -n 1 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; [ -d "$HOME/.GameScript_sys1" ] && echo "Erreur inattendue, ${HOME}/.GameScript_sys1 existe déjà sur votre système ! Supprimez ce dossier $HOME/.GameScript_sys1 et relancez ce script." && exit; restore=$(expr $restore + 1) ;&
2) echo -n 2 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; command -v xdotool >/dev/null 2>&1 || { echo "Veuillez installer les dépendances requises. Faites en tant qu'administrateur : apt-get install xdotool" >&2; exit 3; }; restore=$(expr $restore + 1) ;&
3) echo -n 3 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; mkdir $HOME/.GameScript_sys1 2> /dev/null; restore=$(expr $restore + 1) ;&
4) echo -n 4 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; cd $HOME/.GameScript_sys1; restore=$(expr $restore + 1) ;&
5) echo -n 5 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Votre système d'exploitation est multitâche, c'est à dire qu'il est capable d'exécuter plusieurs tâches simultanément."; restore=$(expr $restore + 1) ;&
6) echo -n 6 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Par exemple, vous pouvez avoir un éditeur de texte et un navigateur web ouvert en même temps sans rencontrer de difficultés."; restore=$(expr $restore + 1) ;&
7) echo -n 7 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Lorsque ces programmes sont en cours d'exécution sur votre ordinateur, on parle alors de ${voc}processus${reset}."; restore=$(expr $restore + 1) ;&
8) echo -n 8 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Un programme est donc une entité ${voc}passive${reset} (Seulement présent sur votre disque en tant que fichier exécutable), alors qu'un processus est une entité ${voc}active${reset} (Exécuté par votre processeur)."; restore=$(expr $restore + 1) ;&
9) echo -n 9 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Un même programme peut être lancé plusieures fois, il est donc possible d'avoir plusieurs processus pour un seul programme."; restore=$(expr $restore + 1) ;&
10) echo -n 10 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Dans cette série nous verrons ensemble comment analyser et contrôler ces processus."; restore=$(expr $restore + 1) ;&
11) echo -n 11 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk_not_press_key justumen "Commencons par lister vos processus avec la commande : ${learn}ps${reset}"; restore=$(expr $restore + 1) ;&
12) echo -n 12 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; answer_run "ps" justumen "Non"; restore=$(expr $restore + 1) ;&
13) echo -n 13 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Evidemment il y a bien plus de processus que ça sur votre ordinateur..."; restore=$(expr $restore + 1) ;&
14) echo -n 14 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk_not_press_key justumen "Pour lister tous les processus, faites : ${learn}ps -e${reset}"; restore=$(expr $restore + 1) ;&
15) echo -n 15 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; answer_run "ps -e" justumen "Non"; restore=$(expr $restore + 1) ;&
16) echo -n 16 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk_not_press_key justumen "Pour compter le nombre de processus dans cette liste, vous pouvez donc faire : ${learn}ps -e|wc -l${reset}"; restore=$(expr $restore + 1) ;&
17) echo -n 17 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; answer_run "ps -e|wc -l" justumen "Non"; restore=$(expr $restore + 1) ;&
18) echo -n 18 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Mais pour l'instant nous allons nous concentrer sur le résultat de la commande ps, qui affiche uniquement certains processus."; restore=$(expr $restore + 1) ;&
19) echo -n 19 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk_not_press_key justumen "Faites donc à nouveau : ${learn}ps${reset}"; restore=$(expr $restore + 1) ;&
20) echo -n 20 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; answer_run "ps" justumen "Non"; restore=$(expr $restore + 1) ;&
21) echo -n 21 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Tout exécutable qui a été 'exécuté' sur votre système d'exploitation est un processus !"; restore=$(expr $restore + 1) ;&
22) echo -n 22 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Votre terminal est un processus, mais l'instance de bash à l'intérieur de ce terminal est également un processus."; restore=$(expr $restore + 1) ;&
23) echo -n 23 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk_not_press_key justumen "Affichez plus détails sur ces processus avec : ${learn}ps -f${reset}"; restore=$(expr $restore + 1) ;&
24) echo -n 24 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; answer_run "ps -f" justumen "Non"; restore=$(expr $restore + 1) ;&
25) echo -n 25 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Chaque processus aura un identifiant unique capable de l'identifier : son PID. (l'anglais de Process IDentifier)"; restore=$(expr $restore + 1) ;&
26) echo -n 26 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "C'est un numéro unique qui pourra être utilisé pour manipuler le comportement du processus portant ce numéro."; restore=$(expr $restore + 1) ;&
27) echo -n 27 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk_not_press_key justumen "Affichez donc le même résultat avec une indentation : ${learn}ps -fH${reset}"; restore=$(expr $restore + 1) ;&
28) echo -n 28 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; answer_run "ps -fH" justumen "Non"; restore=$(expr $restore + 1) ;&
29) echo -n 29 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Vous pouvez voir ici, une colonne nommée 'PPID' : Il s'agit de l'identifiant du processus parent. (Parent Process IDentifier)"; restore=$(expr $restore + 1) ;&
30) echo -n 30 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Les processus ont une relation parent/enfant : On dit que 'ps -fH' est le processus enfant de 'standalone.sh' et que 'standalone.sh' est le parent du processus 'ps -fH'."; restore=$(expr $restore + 1) ;&
31) echo -n 31 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Cette indentation/décalage avec l'option '-H' représente visuellement cette relation enfant/parent."; restore=$(expr $restore + 1) ;&
32) echo -n 32 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Ici vous pouvez voir que 'gamescript.sh' est le parent d'un processus 'standalone', qui est en fait le chapitre que vous utilisez en ce moment."; restore=$(expr $restore + 1) ;&
33) echo -n 33 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Toutes les commandes que vous lancez seront bien évidemment aussi des processus."; restore=$(expr $restore + 1) ;&
34) echo -n 34 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "C'est pourquoi vous pouvez voir ici la commande 'ps -fH', c'est un processus comme un autre."; restore=$(expr $restore + 1) ;&
35) echo -n 35 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "La seul différence avec les autres est que ce processus 'ps -fH' n'existe plus."; restore=$(expr $restore + 1) ;&
36) echo -n 36 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Il existera juste le temps qu'il lui faut pour afficher ce qu'il doit afficher et se fermera."; restore=$(expr $restore + 1) ;&
37) echo -n 37 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Si cette commande est lancée à partir d'un shell bash, cette instance de bash sera le parent de ce processus et cette commande y sera 'attachée'."; restore=$(expr $restore + 1) ;&
38) echo -n 38 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Le processus en question prendra le contrôle de votre shell et s'appropriera son interactivité."; restore=$(expr $restore + 1) ;&
39) echo -n 39 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk_not_press_key justumen "Voyons la même chose au ralentit : lancez par exemple la commande qui attend 5 secondes : ${learn}sleep 5${reset}"; restore=$(expr $restore + 1) ;&
40) echo -n 40 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; answer_run "sleep 5" justumen "Non"; restore=$(expr $restore + 1) ;&
41) echo -n 41 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Ici, votre terminal attend que la commande soit terminée pour vous rendre la main."; restore=$(expr $restore + 1) ;&
42) echo -n 42 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; gamescript_window=$(xdotool getwindowfocus); restore=$(expr $restore + 1) ;&
43) echo -n 43 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk_not_press_key justumen "Essayez donc de lancer leafpad, regardez l'état de votre terminal, puis quitter leafpad en cliquant sur "fichier", puis "quitter"."; restore=$(expr $restore + 1) ;&
44) echo -n 44 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; answer_run "leafpad" justumen "Non"; restore=$(expr $restore + 1) ;&
45) echo -n 45 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; while [ ! `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
46) echo -n 46 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Quitter le processus leafpad vous permet de continuer à utiliser votre terminal normalement."; restore=$(expr $restore + 1) ;&
47) echo -n 47 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Si vous lancez un processus interactif (comme leafpad), votre terminal se mettre en 'pause'."; restore=$(expr $restore + 1) ;&
48) echo -n 48 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Vous ne pouvez plus interagir avec votre shell, mais vous pouvez envoyer des signaux à ce processus à partir du terminal qui l'a lancé."; restore=$(expr $restore + 1) ;&
49) echo -n 49 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Vous pouvez par exemple fermer ce processus avec une combinaison de touche."; restore=$(expr $restore + 1) ;&
50) echo -n 50 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Attention cependant à ne pas le faire deux fois, car 'gamescript.sh' est lui-même un processus qui peut être fermé avec la même combinaison de touche."; restore=$(expr $restore + 1) ;&
51) echo -n 51 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; gamescript_window=$(xdotool getwindowfocus); restore=$(expr $restore + 1) ;&
52) echo -n 52 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk_not_press_key justumen "Ouvrez un nouveau terminal et lancez directement leafpad dessus avec ${learn}lxterminal -e leafpad${reset}, allez sur ce terminal et faites 'Ctrl + c'."; restore=$(expr $restore + 1) ;&
53) echo -n 53 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; answer_run "lxterminal -e leafpad" justumen "Non"; restore=$(expr $restore + 1) ;&
54) echo -n 54 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; sleep 1; while [ ! `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
55) echo -n 55 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Ici vous voyez que faire 'Ctrl + c' dans le terminal parent a fermé ce processus leafpad."; restore=$(expr $restore + 1) ;&
56) echo -n 56 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Si vous voulez lancer un programme, mais que vous voulez continuer à utiliser votre terminal, vous pouvez suspendre ce programme avec la combinaison 'Ctrl+ z'."; restore=$(expr $restore + 1) ;&
57) echo -n 57 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Pour revenir sur le programme qui a été suspendu vous devez utiliser la commande ${code}fg${reset}."; restore=$(expr $restore + 1) ;&
58) echo -n 58 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Essayez donc de suspendre GameScript avec la combinaison de touche 'Ctrl + z', puis faites ${code}fg${reset} pour revenir sur GameScript, et appuyez sur Entrée."; restore=$(expr $restore + 1) ;&
59) echo -n 59 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "..."; restore=$(expr $restore + 1) ;&
60) echo -n 60 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Ce que vous avez fait ici avec GameScript peut être fait avec d'autres processus."; restore=$(expr $restore + 1) ;&
61) echo -n 61 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk_not_press_key justumen "Ouvrez un nouveau terminal avec un shell bash en faisant ici : ${learn}lxterminal -e bash${reset}."; restore=$(expr $restore + 1) ;&
62) echo -n 62 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; answer_run "lxterminal -e bash" justumen "Non"; restore=$(expr $restore + 1) ;&
63) echo -n 63 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Mettez ce terminal dans un endroit comfortable pour vous, nous allons faire plusieurs aller-retour entre ce terminal et GameScript."; restore=$(expr $restore + 1) ;&
64) echo -n 64 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Dans ce nouveau terminal, lancez ${learn}leafpad${reset}, faites 'Ctrl + z' pour détacher ce processus de leafpad du terminal et revenez sur GameScript."; restore=$(expr $restore + 1) ;&
65) echo -n 65 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; while [ `xdotool getwindowfocus` = $gamescript_window ];do sleep 2; done; restore=$(expr $restore + 1) ;&
66) echo -n 66 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; while [ ! `xdotool getwindowfocus` = $gamescript_window ];do sleep 2; done; restore=$(expr $restore + 1) ;&
67) echo -n 67 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Ici vous pouvez remarquer que leafpad ne s'est pas fermé, mais vous pouvez continuer à utiliser votre terminal normalement."; restore=$(expr $restore + 1) ;&
68) echo -n 68 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk_not_press_key justumen "Faites donc dans votre autre terminal : ${learn}ps${reset}"; restore=$(expr $restore + 1) ;&
69) echo -n 69 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; while [ `xdotool getwindowfocus` = $gamescript_window ];do sleep 2; done; restore=$(expr $restore + 1) ;&
70) echo -n 70 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; while [ ! `xdotool getwindowfocus` = $gamescript_window ];do sleep 2; done; restore=$(expr $restore + 1) ;&
71) echo -n 71 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Sans argument, la commande ${learn}ps${reset} affichera le processus enfants de votre shell."; restore=$(expr $restore + 1) ;&
72) echo -n 72 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Comme vous avez utilisé ce terminal pour lancer 'leafpad', vous pouvez voir ici que 'leafpad' est dans la liste."; restore=$(expr $restore + 1) ;&
73) echo -n 73 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk_not_press_key justumen "Retournez dans ce terminal et affichez les relations parents/enfants de vos processus avec la commande : ${learn}ps -fH${reset}"; restore=$(expr $restore + 1) ;&
74) echo -n 74 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; while [ `xdotool getwindowfocus` = $gamescript_window ];do sleep 2; done; restore=$(expr $restore + 1) ;&
75) echo -n 75 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; while [ ! `xdotool getwindowfocus` = $gamescript_window ];do sleep 2; done; restore=$(expr $restore + 1) ;&
76) echo -n 76 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Ici vous pouvez voir clairement que leafpad est un enfant de votre shell (bash)."; restore=$(expr $restore + 1) ;&
77) echo -n 77 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Maintenant, essayez d'écrire quelque chose dans leafpad, puis revenez sur GameScript pour continuer."; restore=$(expr $restore + 1) ;&
78) echo -n 78 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "'Ctrl + z' a suspendu ce processus de leafpad, ce qui a eu pour effet de le rendre ${voc}inutilisable${reset}."; restore=$(expr $restore + 1) ;&
79) echo -n 79 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Pour faire l'inverse de 'Ctrl + z', c'est à dire récuperer ce programme, vous pouvez utilisez la commande 'fg' que nous avons déjà vu."; restore=$(expr $restore + 1) ;&
80) echo -n 80 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk_not_press_key justumen "Retournez sur votre terminal, lancez ${learn}fg${reset}, essayez d'utiliser votre instance de 'leafpad' et revenez sur GameScript."; restore=$(expr $restore + 1) ;&
81) echo -n 81 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; while [ `xdotool getwindowfocus` = $gamescript_window ];do sleep 2; done; restore=$(expr $restore + 1) ;&
82) echo -n 82 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; while [ ! `xdotool getwindowfocus` = $gamescript_window ];do sleep 2; done; restore=$(expr $restore + 1) ;&
83) echo -n 83 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "'fg' est l'abréviation de 'foreground', l'anglais de 'premier plan'."; restore=$(expr $restore + 1) ;&
84) echo -n 84 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Vous pouvez aussi utiliser la commande 'bg', l'abréviation de 'background', l'anglais de 'arrière plan' pour que le processus soit utilisable mais ne monopolise pas le terminal."; restore=$(expr $restore + 1) ;&
85) echo -n 85 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk_not_press_key justumen "Retournez sur votre terminal, faites 'Ctrl + z' pour pouvoir utiliser votre shell et affichez la situation des processus que vous avez ouvert dans ce terminal avec la commande : ${learn}jobs${reset}"; restore=$(expr $restore + 1) ;&
86) echo -n 86 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; while [ `xdotool getwindowfocus` = $gamescript_window ];do sleep 2; done; restore=$(expr $restore + 1) ;&
87) echo -n 87 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; while [ ! `xdotool getwindowfocus` = $gamescript_window ];do sleep 2; done; restore=$(expr $restore + 1) ;&
88) echo -n 88 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Un 'job' est un processus que vous pouvez contrôler avec 'fg' ou 'bg'."; restore=$(expr $restore + 1) ;&
89) echo -n 89 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Nous allons maintenant rajouter un processus à cette liste !"; restore=$(expr $restore + 1) ;&
90) echo -n 90 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Retournez sur votre terminal, lancez une autre instance de 'leafpad', faites à nouveau 'Ctrl + z' et lancer la commande : ${learn}jobs${reset} avant de revenir sur GameScript."; restore=$(expr $restore + 1) ;&
91) echo -n 91 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; while [ `xdotool getwindowfocus` = $gamescript_window ];do sleep 2; done; restore=$(expr $restore + 1) ;&
92) echo -n 92 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; while [ ! `xdotool getwindowfocus` = $gamescript_window ];do sleep 2; done; restore=$(expr $restore + 1) ;&
93) echo -n 93 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Ici nous avons deux 'jobs', et aucun d'entre eux n'est utilisable, comme vous pouvez le voir car leur état est : ${voc}Stopped${reset}."; restore=$(expr $restore + 1) ;&
94) echo -n 94 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Si il n'y a qu'un seul job dans votre terminal, vous n'avez pas besoin de spécifier un argument aux commandes ${code}fg${reset} et ${code}bg${reset}."; restore=$(expr $restore + 1) ;&
95) echo -n 95 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "En revanche, si vous en avez plusieurs, il faudra ajouter en argument leur identifiants, que vous pouvez voir tout à gauche entre crochets."; restore=$(expr $restore + 1) ;&
96) echo -n 96 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk_not_press_key justumen "Retournez sur votre terminal, et mettez le job [1] en arrière plan avec ${learn}bg %1${reset}, puis revenez sur GameScript."; restore=$(expr $restore + 1) ;&
97) echo -n 97 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; while [ `xdotool getwindowfocus` = $gamescript_window ];do sleep 2; done; restore=$(expr $restore + 1) ;&
98) echo -n 98 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; while [ ! `xdotool getwindowfocus` = $gamescript_window ];do sleep 2; done; restore=$(expr $restore + 1) ;&
99) echo -n 99 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Si vous vouliez utiliser ${learn}fg${reset} à la place, la syntaxe aurait été similaire : ${learn}fg %1${reset}"; restore=$(expr $restore + 1) ;&
100) echo -n 100 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk_not_press_key justumen "Retournez sur votre terminal, et faites à nouveau : ${learn}jobs${reset}"; restore=$(expr $restore + 1) ;&
101) echo -n 101 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; while [ `xdotool getwindowfocus` = $gamescript_window ];do sleep 2; done; restore=$(expr $restore + 1) ;&
102) echo -n 102 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; while [ ! `xdotool getwindowfocus` = $gamescript_window ];do sleep 2; done; restore=$(expr $restore + 1) ;&
103) echo -n 103 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Vous devriez voir maintenant que l'une des deux instances de leafpad a comme état : ${voc}Running${reset}."; restore=$(expr $restore + 1) ;&
104) echo -n 104 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Cette instance de leafpad fonctionne tout à fait normalement et vous pouvez continuer à utiliser votre terminal en même temps."; restore=$(expr $restore + 1) ;&
105) echo -n 105 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Il est aussi possible de lancer directement un processus en arrière plan avec le symbole ${code}&${reset} à la fin de votre commande."; restore=$(expr $restore + 1) ;&
106) echo -n 106 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk_not_press_key justumen "Faites le donc maintenant. Retournez sur votre terminal, lancez une autre instance de leafpad en arrière plan avec ${learn}leafpad&${reset} et refaites ${learn}jobs${reset}."; restore=$(expr $restore + 1) ;&
107) echo -n 107 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; while [ `xdotool getwindowfocus` = $gamescript_window ];do sleep 2; done; restore=$(expr $restore + 1) ;&
108) echo -n 108 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; while [ ! `xdotool getwindowfocus` = $gamescript_window ];do sleep 2; done; restore=$(expr $restore + 1) ;&
109) echo -n 109 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Ici vous voyez qu'avec l'utiisation du symbole ${code}&${reset} son statut est ${voc}Running${reset}."; restore=$(expr $restore + 1) ;&
110) echo -n 110 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "'jobs', 'bg', 'fg' et '&' sont très utiles pour contrôler les jobs du terminal en question."; restore=$(expr $restore + 1) ;&
111) echo -n 111 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Mais ${voc}attention${reset} !! Si vous fermez ce terminal, tous ses jobs se fermeront également !"; restore=$(expr $restore + 1) ;&
112) echo -n 112 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk_not_press_key justumen "Voyons un exemple de ce phénomène : Ouvrez un nouveau terminal qui lance directement une instance de mousepad avec ${learn}lxterminal -e mousepad${reset}, puis fermez ce terminal !"; restore=$(expr $restore + 1) ;&
113) echo -n 113 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; answer_run "lxterminal -e mousepad" justumen "Non"; restore=$(expr $restore + 1) ;&
114) echo -n 114 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Vous pouvez voir que cette instance de mousepad s'est également fermée."; restore=$(expr $restore + 1) ;&
115) echo -n 115 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Attention donc à ne pas fermer le terminal qui contient vos processus importants."; restore=$(expr $restore + 1) ;&
116) echo -n 116 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Si vous voulez fermer ce terminal, mais que le processus reste ouvert, vous pouvez ordonner à ce terminal d'abandonner ce processus avec la commande ${learn}disown${reset}."; restore=$(expr $restore + 1) ;&
117) echo -n 117 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk_not_press_key justumen "Faites donc dans votre terminal ${learn}disown %1${reset}, puis réaffichez l'état de vos jobs."; restore=$(expr $restore + 1) ;&
118) echo -n 118 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; while [ `xdotool getwindowfocus` = $gamescript_window ];do sleep 2; done; restore=$(expr $restore + 1) ;&
119) echo -n 119 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; while [ ! `xdotool getwindowfocus` = $gamescript_window ];do sleep 2; done; restore=$(expr $restore + 1) ;&
120) echo -n 120 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Ici vous voyez que l'un des processus de leafpad n'est plus dans la liste."; restore=$(expr $restore + 1) ;&
121) echo -n 121 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "A partir de maintenant, ce processus ne se fermera plus quand votre terminal se fermera. (Faites moi confiance.)"; restore=$(expr $restore + 1) ;&
122) echo -n 122 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Mais n'oubliez pas que ces jobs sont avant tout des processus !"; restore=$(expr $restore + 1) ;&
123) echo -n 123 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Et vous pouvez aussi directement les contrôler avec leur PID, quel que soit votre terminal actuel."; restore=$(expr $restore + 1) ;&
124) echo -n 124 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk_not_press_key justumen "Retournez sur votre terminal et affichez le PID de vos jobs avec : ${learn}jobs -l${reset}"; restore=$(expr $restore + 1) ;&
125) echo -n 125 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; while [ `xdotool getwindowfocus` = $gamescript_window ];do sleep 2; done; restore=$(expr $restore + 1) ;&
126) echo -n 126 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; while [ ! `xdotool getwindowfocus` = $gamescript_window ];do sleep 2; done; restore=$(expr $restore + 1) ;&
127) echo -n 127 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk_not_press_key justumen "Retournez sur votre terminal et affichez également ces éléments en tant que processus avec la commande : ${learn}ps${reset}"; restore=$(expr $restore + 1) ;&
128) echo -n 128 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; while [ `xdotool getwindowfocus` = $gamescript_window ];do sleep 2; done; restore=$(expr $restore + 1) ;&
129) echo -n 129 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; while [ ! `xdotool getwindowfocus` = $gamescript_window ];do sleep 2; done; restore=$(expr $restore + 1) ;&
130) echo -n 130 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Avec son PID et la commande ${code}kill${reset}, vous pouvez cibler un processus même en dehors de votre terminal. (contrairement à fg, bg et disown.)"; restore=$(expr $restore + 1) ;&
131) echo -n 131 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "La commande ${code}kill${reset} (anglais de tuer) permet de fermer un processus dont le PID est donné en argument."; restore=$(expr $restore + 1) ;&
132) echo -n 132 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; THISPID=`ps -e|grep leafpad|grep -v grep|tail -n 1|awk '{ print $1 }'`; restore=$(expr $restore + 1) ;&
133) echo -n 133 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk_not_press_key justumen "Fermez un des processus de leafpad à partir de GameScript avec : ${learn}kill $THISPID${reset}"; restore=$(expr $restore + 1) ;&
134) echo -n 134 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; answer_run "kill $THISPID" justumen "Non"; restore=$(expr $restore + 1) ;&
135) echo -n 135 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Retournez sur votre terminal et listez vos processus à nouveau avec ${learn}ps -fH${reset} puis revenez sur GameScript."; restore=$(expr $restore + 1) ;&
136) echo -n 136 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; while [ `xdotool getwindowfocus` = $gamescript_window ];do sleep 2; done; restore=$(expr $restore + 1) ;&
137) echo -n 137 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; while [ ! `xdotool getwindowfocus` = $gamescript_window ];do sleep 2; done; restore=$(expr $restore + 1) ;&
138) echo -n 138 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Ici il est bien clair que l'une des instances de leafpad a été fermée."; restore=$(expr $restore + 1) ;&
139) echo -n 139 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Malgré son nom, la commande ${code}kill${reset} est capable de faire bien plus que de fermer un processus."; restore=$(expr $restore + 1) ;&
140) echo -n 140 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "${code}kill${reset} est capable d'envoyer vers un processus une grande quantité de ${voc}signaux${reset} différents."; restore=$(expr $restore + 1) ;&
141) echo -n 141 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk_not_press_key justumen "Regardez rapidement le résultat de la commande ${code}man 7 signal${reset} pour affichez la liste des signaux disponibles et revenez sur GameScript."; restore=$(expr $restore + 1) ;&
142) echo -n 142 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; answer_run "man 7 signal" justumen "Non"; restore=$(expr $restore + 1) ;&
143) echo -n 143 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Ici nous allons nous intéresser à seulement quatre signaux de ces signaux : SIGTERM , SIGTSTP, SIGCONT et SIGKILL"; restore=$(expr $restore + 1) ;&
144) echo -n 144 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "SIGTERM est le signal par défaut de la commande ${code}kill${reset}, c'est à dire que la commande ${code}kill${reset} est équivalente à la commande ${code}kill -SIGTERM${reset}."; restore=$(expr $restore + 1) ;&
145) echo -n 145 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Le processus en argument de la commande ${code}kill${reset} recevra ce signal SIGTERM et tentera de se fermer proprement."; restore=$(expr $restore + 1) ;&
146) echo -n 146 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Si votre processus ne répond plus pour une certaine raison, il ne sera pas possible de le fermer de cette manière..."; restore=$(expr $restore + 1) ;&
147) echo -n 147 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Dans ce genre de situation, (qui ne devrait jamais se produire sans une excellente raison) vous pouvez envoyez le signal SIGKILL !"; restore=$(expr $restore + 1) ;&
148) echo -n 148 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Contrairement à SIGTERM, le signal SIGKILL ne peut pas être capturé par le processus cible, il ne pourra donc pas se fermer proprement."; restore=$(expr $restore + 1) ;&
149) echo -n 149 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Pour afficher le statut de vos processus, vous pouvez utiliser ps avec son option -l. Essayez donc ${learn}ps -lfH${reset} dans votre terminal."; restore=$(expr $restore + 1) ;&
150) echo -n 150 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Le statut de vos processus est dans le résultat de ${code}ps -l${reset} une lettre dans la colonne S (statut)."; restore=$(expr $restore + 1) ;&
151) echo -n 151 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "${code}T${reset} est l'équivalent du statut job 'Running', et ${code}S${reset} est l'équivalent du statut 'Stopped'."; restore=$(expr $restore + 1) ;&
152) echo -n 152 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Pour plus de détails sur ces statut et leur signification, n'hésitez pas à visitez le manuel de la commande ${code}ps${reset}."; restore=$(expr $restore + 1) ;&
153) echo -n 153 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; THISPID=`ps -e|grep leafpad|head -n 1|awk '{ print $1 }'`; restore=$(expr $restore + 1) ;&
154) echo -n 154 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Voyons maintenant deux autres signaux, capables de changer le statut de vos processus : SIGTSTP, SIGCONT."; restore=$(expr $restore + 1) ;&
155) echo -n 155 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Le signal SIGTSTP a le même effet que la combinaison de touche 'Ctrl + z', votre processus sera 'suspendu'."; restore=$(expr $restore + 1) ;&
156) echo -n 156 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk_not_press_key justumen "Listez les statut de vos processus leafpad avec : ${learn}ps -elf|grep leafpad${reset} ('elf' est l'anglais de 'elfe' :p)"; restore=$(expr $restore + 1) ;&
157) echo -n 157 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; answer_run "ps -elf|grep leafpad" justumen "Non"; restore=$(expr $restore + 1) ;&
158) echo -n 158 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk_not_press_key justumen "Suspendez un processus leafpad avec : ${learn}kill -SIGTSTP $THISPID${reset}"; restore=$(expr $restore + 1) ;&
159) echo -n 159 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; answer_run "kill -SIGTSTP $THISPID" justumen "Non"; restore=$(expr $restore + 1) ;&
160) echo -n 160 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk_not_press_key justumen "Puis listez à nouveau le statut de vos processus leafpad avec : ${learn}ps -lf|grep leafpad${reset}"; restore=$(expr $restore + 1) ;&
161) echo -n 161 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; answer_run "ps -elf|grep leafpad" justumen "Non"; restore=$(expr $restore + 1) ;&
162) echo -n 162 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Cette commande confirme que cette instance de leafpad à été suspendue (T), mais vous pouvez tester par vous-même."; restore=$(expr $restore + 1) ;&
163) echo -n 163 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk_not_press_key justumen "Pour permettre au processus de continuer à exister, faites : ${learn}kill -SIGCONT $THISPID${reset}"; restore=$(expr $restore + 1) ;&
164) echo -n 164 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; answer_run "kill -SIGCONT $THISPID" justumen "Non"; restore=$(expr $restore + 1) ;&
165) echo -n 165 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk_not_press_key justumen "Puis faites à nouveau : ${learn}ps -elf|grep leafpad${reset}"; restore=$(expr $restore + 1) ;&
166) echo -n 166 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; answer_run "ps -elf|grep leafpad" justumen "Non"; restore=$(expr $restore + 1) ;&
167) echo -n 167 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Cette commande confirme que cette instance de leafpad est à nouveau utilisable (S), mais vous pouvez tester par vous-même."; restore=$(expr $restore + 1) ;&
168) echo -n 168 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Mais... qu'en est-il de la combinaison 'Ctrl + c' que nous avions déjà vu ? Est-ce un signal ?"; restore=$(expr $restore + 1) ;&
169) echo -n 169 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Et bien oui, le signal en question est SIGINT, qui représente une interruption par l'intermédiaire du clavier."; restore=$(expr $restore + 1) ;&
170) echo -n 170 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Mais son effet est similaire à SIGTERM : il donne donc au processus l'occasion de se fermer correctement."; restore=$(expr $restore + 1) ;&
171) echo -n 171 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Avant de finir ce chapitre, ferme le terminal que vous avez ouvert."; restore=$(expr $restore + 1) ;&
172) echo -n 172 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Comme promis, l'un des processus de leafpad a survécu : celui que vous avez ${code}disown${reset}."; restore=$(expr $restore + 1) ;&
173) echo -n 173 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; talk justumen "Vous être prêt pour le questionnaire de ce chapitre !"; restore=$(expr $restore + 1) ;&
174) echo -n 174 > $HOME/.GameScript/restore_sys1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_sys1; clean; restore=$(expr $restore + 1) ;&
esac
}
function clean(){ #in enter_chapter
rm $HOME/.GameScript/restore_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
rm $HOME/.GameScript/restore_pwd_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
	rmdir $HOME/.GameScript_sys1 2> /dev/null
}

function start_quiz(){
  echo ""
  echo -e "\e[15;44m System : Questionnaire du chapitre 1 \e[0m"
  echo -e "- La réponse doit être la plus courte possible, une commande valide mais ajoutant des caractères inutiles ne fonctionnera pas."
  echo -e "Exemple : si la réponse est 'ls'. Les réponses 'ls .', 'ls ./' et 'ls ././' seront considérées comme fausses."
#^C+c , ^C+z , jobs , fg , bg , kill , disown , PID , PPID , SIGCONT , SIGINT , SIGTSTP , SIGKILL
  answer_text_fr "Quelle est la commande qui affiche la liste de vos 'jobs' ?" "jobs"
  answer_text_fr "Comment lancer le gestionnaire de fichier 'pcmanfm' en arrière plan à partir d'un terminal ?" "pcmanfm&"
  answer_text_fr "Si votre job est 'Stopped', quel signal devez vous envoyer pour le rendre utilisable ? (le signal doit la syntaxe -SIG...)" "SIGCONT"
  answer_text_fr "Quelle est la lettre INCONNU dans la phrase ? : Pour envoyer le signal SIGINT au processus, vous devez faire 'Ctrl + INCONNU'." "c"
  answer_text_fr "Un PID représente uniquement un seul processus à un moment donné. (vrai/faux)" "vrai"
  answer_text_fr "Un PPID en revanche peut représenter plusieurs processus à un moment donné. (vrai/faux)" "faux"
  answer_text_fr "Quelle est la commande pour envoyer le job numéro 4 en arrière plan ?" "bg %4"
  answer_text_fr "Quelle est la commande pour fermer le processus avec le PID 666 ?" "kill 666"
  answer_text_fr "Quelle est la commande qui permet d'éviter que le job numéro 4 ne se ferme en même temps que son terminal parent ?" "disown %4"
  answer_text_fr "Quelle est la lettre INCONNU dans la phrase ? : Pour envoyer le signal SIGTSTP au processus, vous devez faire 'Ctrl + INCONNU'." "z"
  answer_text_fr "Quelle est la commande qui peut fermer le processus avec le PID 666 même s'il ne répond plus ? (la commande doit utiliser la syntaxe -SIG...)" "kill -SIGKILL 666"
  unlock "sys" "1" "bbb2" "112b"
}


CHAPTER_NAME="sys"
CHAPTER_NUMBER="1"
LANGUAGE="fr"
SPEAKER="m1"

LINES=173
if [ "$1" == "VIDEO" ]; then
	prepare_video
else
	if [ ! "$1" == "MUTE" ]; then
		prepare_audio
	fi
fi

enter_chapter $CHAPTER_NAME $CHAPTER_NUMBER
