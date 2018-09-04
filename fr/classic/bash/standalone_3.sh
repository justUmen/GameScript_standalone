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
	if [ ! -f "$AUDIO_LOCAL/4.mp3" ]; then
		wget -q --spider http://google.com
		if [ $? -eq 0 ]; then
			download_all_sounds
		else
			echo "Cannot download audio, no internet ?"
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
	pkill mplayer &> /dev/null
	pkill mpg123 &> /dev/null
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
	while [ "$key" != "1" ] || [ "$key" != "2" ] || [ "$key" != "3" ]; do
		# echo ""
		#~ echo -e "\\e[0;100m 0) \\e[0m Télécharger audio en avance"
		echo -e "\\e[0;100m 1) \\e[0m $1"
		echo -e "\\e[0;100m 2) \\e[0m $2"
		echo -e "\\e[0;100m 3) \\e[0m $3"
		echo -en "\\e[97;45m # \\e[0m"
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
						echo -e "\\e[0;100m 1) \\e[0m $TEXT_CONTINUE"
						echo -e "\\e[0;100m 2) \\e[0m $TEXT_RESTART"
						echo -e "\\e[0;100m 3) \\e[0m $TEXT_BACK"
						echo -en "\\e[97;45m # \\e[0m"
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
			3) exit ;;
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
		fr) talk_not_press_key justumen "Pour débloquer '$1 $2' sur rocketchat (https://rocket.bjornulf.org), ouvrez une conversation privée avec '@boti' et copiez/collez :\n\t\e[97;42mpassword$PASS\e[0m"
			talk_not_press_key justumen "Pour débloquer '$1 $2' sur discord (https://discord.gg/25eRgvD), ouvrez le channel '#mots-de-passe-boti' et copiez/collez :\n\t\e[97;42mpassword$PASS\e[0m"
				;;
		en) talk_not_press_key justumen "To unlock '$1 $2' on rocketchat (https://rocket.bjornulf.org), open a private conversation with '@boti' and copy/paste :\n\t\e[97;42mpassword$PASS\e[0m"
			talk_not_press_key justumen "To unlock '$1 $2' on discord (https://discord.gg/25eRgvD), open the channel '#mots-de-passe-boti' and copy/paste :\n\t\e[97;42mpassword$PASS\e[0m"
				;;
	esac
	#AUTOMATICALLY DO THIS ?
	touch "$HOME/.GameScript/good_$1$2" 2> /dev/null
	mkdir $HOME/.GameScript/passwords/ 2> /dev/null
	echo -n "$PASS" > "$HOME/.GameScript/passwords/$1$2"
	exit
}

function enter_chapter(){
	#Usage : enter_chapter bash 1 1 (first 1 is chapter, next one is for case)
	echo ""
	case $LANGUAGE in
		fr) echo -e "\e[97;44m - $1, Chapitre $2 \e[0m"
			answer_quiz "Cours" "Questionnaire" "Retour" "4" "5" "6" "$1" "$2" ;;
		en) echo -e "\e[97;44m - $1, Chapter $2 \e[0m"
			answer_quiz "Lecture" "Quiz" "Return" "4" "5" "6" "$1" "$2" ;;
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
1) echo -n 1 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; [ -d "$HOME/.GameScript_bash3" ] && echo "Erreur inattendue, ${HOME}/.GameScript_bash3 existe déjà sur votre système ! Supprimez ce dossier $HOME/.GameScript_bash3 et relancez ce script." && exit; restore=$(expr $restore + 1) ;&
2) echo -n 2 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; mkdir $HOME/.GameScript_bash3 2> /dev/null; restore=$(expr $restore + 1) ;&
3) echo -n 3 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; cd $HOME/.GameScript_bash3; restore=$(expr $restore + 1) ;&
4) echo -n 4 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Dans le chapitre 2, nous avons vu que les options peuvent avoir deux formes, l'une courte comme dans ${learn}ls -l${reset}, et l'autre longue comme dans ${learn}ls --all${reset}."; restore=$(expr $restore + 1) ;&
5) echo -n 5 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Si vous avez plusieures options à passer à la même commande, vous pouvez les mettre les unes à la suite des autres : ${learn}ls -a -w 1${reset}."; restore=$(expr $restore + 1) ;&
6) echo -n 6 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk_not_press_key justumen "Essayez donc avec cet exemple : ${learn}ls -a -w 1${reset}"; restore=$(expr $restore + 1) ;&
7) echo -n 7 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; answer_run "ls -a -w 1" justumen "Non"; restore=$(expr $restore + 1) ;&
8) echo -n 8 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Vous pouvez bien évidemment utiliser les versions longues de la même manière, ou même les mélanger avec des options courtes."; restore=$(expr $restore + 1) ;&
9) echo -n 9 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk_not_press_key justumen "Essayez donc de faire la même chose avec : ${learn}ls -a --width=1${reset}"; restore=$(expr $restore + 1) ;&
10) echo -n 10 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; answer_run "ls -a --width=1" justumen "Non"; restore=$(expr $restore + 1) ;&
11) echo -n 11 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Mais n'oubliez pas les options courtes commencent par ${code}-${reset} et les options longues commencent par ${code}--${reset}."; restore=$(expr $restore + 1) ;&
12) echo -n 12 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Si vous utilisez les options courtes, vous pouvez également les regrouper avec le même ${code}-${reset}."; restore=$(expr $restore + 1) ;&
13) echo -n 13 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Par exemple pour passez l'option ${code}-a${reset} et l'option ${code}-w 10${reset} à ${code}ls${reset}, vous pouvez tapez ${code}ls -aw 10${reset}"; restore=$(expr $restore + 1) ;&
14) echo -n 14 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk_not_press_key justumen "Essayez donc cette commande : ${learn}ls -aw 10${reset}"; restore=$(expr $restore + 1) ;&
15) echo -n 15 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; answer_run "ls -aw 10" justumen "Non"; restore=$(expr $restore + 1) ;&
16) echo -n 16 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Attention donc à ne pas oublier qu'il y a deux ${code}-${reset} avant les options longues."; restore=$(expr $restore + 1) ;&
17) echo -n 17 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Les commandes ${learn}ls --all${reset} et ${learn}ls -all${reset} ne sont pas du tout identiques."; restore=$(expr $restore + 1) ;&
18) echo -n 18 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "${learn}ls --all${reset} est identique à ${learn}ls -a${reset}."; restore=$(expr $restore + 1) ;&
19) echo -n 19 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Mais ${learn}ls -all${reset} est identique à ${learn}ls -a -l -l${reset}"; restore=$(expr $restore + 1) ;&
20) echo -n 20 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk_not_press_key justumen "Ouvrez maintenant le manuel de ${code}ls${reset} et cherchez l'option pour afficher son numéro de version."; restore=$(expr $restore + 1) ;&
21) echo -n 21 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; answer_run "man ls" justumen "Non"; restore=$(expr $restore + 1) ;&
22) echo -n 22 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk_not_press_key justumen "Affichez le numéro de version de ${code}ls${reset}."; restore=$(expr $restore + 1) ;&
23) echo -n 23 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; answer_run "ls --version" justumen "Non"; restore=$(expr $restore + 1) ;&
24) echo -n 24 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Parfait !"; restore=$(expr $restore + 1) ;&
25) echo -n 25 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "GameScript affiche en ce moment du texte dans votre terminal."; restore=$(expr $restore + 1) ;&
26) echo -n 26 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "GameScript utilisant les mêmes commandes, laquelle est utilisée ici pour affichez ces phrases ?"; restore=$(expr $restore + 1) ;&
27) echo -n 27 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Pour afficher quelque chose dans un terminal, il vous faudra utiliser la commande ${code}echo${reset}."; restore=$(expr $restore + 1) ;&
28) echo -n 28 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Cette commande vous renverra simplement un écho de ce que vous lui avez donné en argument."; restore=$(expr $restore + 1) ;&
29) echo -n 29 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk_not_press_key justumen "Affichez donc le mot 'bonjour' dans votre terminal avec la commande : ${learn}echo bonjour${reset}"; restore=$(expr $restore + 1) ;&
30) echo -n 30 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; answer_run "echo bonjour" justumen "Non"; restore=$(expr $restore + 1) ;&
31) echo -n 31 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk_not_press_key justumen "La commande ${code}echo${reset} accepte plusieurs arguments, vous pouvez tester : ${learn}echo bonjour tout le monde${reset}"; restore=$(expr $restore + 1) ;&
32) echo -n 32 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; answer_run "echo bonjour tout le monde" justumen "Non"; restore=$(expr $restore + 1) ;&
33) echo -n 33 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Simple comme bonjour !"; restore=$(expr $restore + 1) ;&
34) echo -n 34 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "On a déjà vu ensemble que ${code}mkdir${reset} était utilisé pour créer de nouveaux dossiers."; restore=$(expr $restore + 1) ;&
35) echo -n 35 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Mais comment créer de nouveaux fichiers ?"; restore=$(expr $restore + 1) ;&
36) echo -n 36 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Figurez-vous que vous pouvez utiliser la commande ${code}echo${reset} !"; restore=$(expr $restore + 1) ;&
37) echo -n 37 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Lorsque vous utilisez la commande ${code}echo${reset}, le résultat s'affichera dans votre terminal."; restore=$(expr $restore + 1) ;&
38) echo -n 38 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Mais il est aussi possible de ${voc}rediriger${reset} ce résultat ailleurs, par exemple dans un fichier texte."; restore=$(expr $restore + 1) ;&
39) echo -n 39 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Il vous faudra utiliser le symbole ${code}>${reset}. Il représente une ${voc}redirection${reset} du résultat."; restore=$(expr $restore + 1) ;&
40) echo -n 40 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk_not_press_key justumen "Créez donc le fichier texte 'test' avec la commande : ${code}echo bonjour>test${reset}"; restore=$(expr $restore + 1) ;&
41) echo -n 41 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; answer_run "echo bonjour>test" justumen "Non"; restore=$(expr $restore + 1) ;&
42) echo -n 42 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Lorsque vous utilisez ${learn}echo bonjour>test${reset}, si le fichier 'test' n'existe pas il sera créé."; restore=$(expr $restore + 1) ;&
43) echo -n 43 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk_not_press_key justumen "Affichez donc les éléments de votre répertoire de travail."; restore=$(expr $restore + 1) ;&
44) echo -n 44 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; answer_run "ls" justumen "Non"; restore=$(expr $restore + 1) ;&
45) echo -n 45 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Ici vous avez non seulement créé le fichier texte 'test', mais vous lui avez également donné un contenu."; restore=$(expr $restore + 1) ;&
46) echo -n 46 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Ce contenu sera le résultat de la commande à gauche du symbole ${code}>${reset}."; restore=$(expr $restore + 1) ;&
47) echo -n 47 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Pour afficher le contenu de ce fichier, il vous faudra utiliser la commande ${code}cat${reset}."; restore=$(expr $restore + 1) ;&
48) echo -n 48 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Encore une fois, il suffira de donner en argument à ${code}cat${reset} le nom du fichier en question, comme vous le feriez pour la commande ${code}rm${reset}."; restore=$(expr $restore + 1) ;&
49) echo -n 49 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk_not_press_key justumen "Affichez donc le contenu du fichier 'test' avec : ${learn}cat test${reset}"; restore=$(expr $restore + 1) ;&
50) echo -n 50 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; answer_run "cat test" justumen "Non"; restore=$(expr $restore + 1) ;&
51) echo -n 51 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "La commande ${code}cat${reset} porte ce nom car elle peut être utilisée pour faire une con${code}cat${reset}énation. C'est à dire mettre bout à bout des chaines de caractère."; restore=$(expr $restore + 1) ;&
52) echo -n 52 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Pour concaténer, il suffit de mettre les fichiers en argument les uns après les autres."; restore=$(expr $restore + 1) ;&
53) echo -n 53 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Il est aussi possible d'utiliser plusieures fois le même fichier."; restore=$(expr $restore + 1) ;&
54) echo -n 54 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk_not_press_key justumen "Testez donc la commande : ${learn}cat test test${reset}"; restore=$(expr $restore + 1) ;&
55) echo -n 55 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; answer_run "cat test test" justumen "Non"; restore=$(expr $restore + 1) ;&
56) echo -n 56 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "${learn}cat test test${reset} affiche ici simplement deux fois le contenu du fichier 'test'."; restore=$(expr $restore + 1) ;&
57) echo -n 57 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Encore une fois : lorsque vous utilisez ${code}>${reset}, si le fichier n'existe pas il sera créé."; restore=$(expr $restore + 1) ;&
58) echo -n 58 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Par contre, si le fichier existe déjà le contenu sera remplacé."; restore=$(expr $restore + 1) ;&
59) echo -n 59 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk_not_press_key justumen "Testons donc la commande : ${learn}echo au revoir>test${reset}"; restore=$(expr $restore + 1) ;&
60) echo -n 60 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; answer_run "echo au revoir>test" justumen "Non"; restore=$(expr $restore + 1) ;&
61) echo -n 61 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk_not_press_key justumen "Affichez maintenant le contenu du fichier 'test'."; restore=$(expr $restore + 1) ;&
62) echo -n 62 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; answer_run "cat test" justumen "Non"; restore=$(expr $restore + 1) ;&
63) echo -n 63 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Ici le contenu a été remplacé ! Le mot 'bonjour' n'existe plus."; restore=$(expr $restore + 1) ;&
64) echo -n 64 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Attention donc à ${code}>${reset}, car il peut supprimer le contenu de vos fichiers."; restore=$(expr $restore + 1) ;&
65) echo -n 65 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Si vous voulez ${voc}ajouter${reset} du nouveau contenu dans un fichier, il vous faudra utiliser ${code}>>${reset}."; restore=$(expr $restore + 1) ;&
66) echo -n 66 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "De même, si vous utilisez ${code}>>${reset}, si le fichier n'existe pas il sera créé."; restore=$(expr $restore + 1) ;&
67) echo -n 67 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Mais si le fichier existe déjà, le nouveau contenu s'ajoutera à la fin du fichier."; restore=$(expr $restore + 1) ;&
68) echo -n 68 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk_not_press_key justumen "Testez donc avec : ${learn}echo bonjour>>test${reset}"; restore=$(expr $restore + 1) ;&
69) echo -n 69 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; answer_run "echo bonjour>>test" justumen "Non"; restore=$(expr $restore + 1) ;&
70) echo -n 70 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk_not_press_key justumen "Puis affichez le contenu du fichier 'test'."; restore=$(expr $restore + 1) ;&
71) echo -n 71 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; answer_run "cat test" justumen "Non"; restore=$(expr $restore + 1) ;&
72) echo -n 72 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Ici le mot 'bonjour' a été rajouté à la fin du fichier texte."; restore=$(expr $restore + 1) ;&
73) echo -n 73 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Vous pouvez continuer à utiliser ${code}>>${reset} pour ajouter votre nouveau contenu les uns à la suite des autres."; restore=$(expr $restore + 1) ;&
74) echo -n 74 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Mais ces redirections (${code}>${reset} et ${code}>>${reset}) ne se limitent pas à la commande ${code}echo${reset}."; restore=$(expr $restore + 1) ;&
75) echo -n 75 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Toutes les commandes peuvent les utiliser."; restore=$(expr $restore + 1) ;&
76) echo -n 76 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk_not_press_key justumen "Mettez par exemple le résultat de la commande ${learn}ls${reset} à la suite du fichier 'test'  !"; restore=$(expr $restore + 1) ;&
77) echo -n 77 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; answer_run "ls>>test" justumen "Non"; restore=$(expr $restore + 1) ;&
78) echo -n 78 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk_not_press_key justumen "Et affichez le fichier 'test'."; restore=$(expr $restore + 1) ;&
79) echo -n 79 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; answer_run "cat test" justumen "Non"; restore=$(expr $restore + 1) ;&
80) echo -n 80 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "C'est le ${voc}résultat${reset} de la commande qui sera redirigé. Ici ${learn}ls${reset} donne comme résultat : 'test', car 'test' est le seul élément du répertoire courant."; restore=$(expr $restore + 1) ;&
81) echo -n 81 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Si vous voulez y ajouter du texte, il faudra utiliser ${code}>>${reset} en combinaison avec la commande ${code}echo${reset}."; restore=$(expr $restore + 1) ;&
82) echo -n 82 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Si vous voulez ajouter le mot 'pwd' à la fin du fichier il faudra utiliser : ${learn}echo pwd>>test${reset}"; restore=$(expr $restore + 1) ;&
83) echo -n 83 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk_not_press_key justumen "Ajoutez ces trois lettres 'pwd' à la fin du fichier 'test'."; restore=$(expr $restore + 1) ;&
84) echo -n 84 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; answer_run "echo pwd>>test" justumen "Non"; restore=$(expr $restore + 1) ;&
85) echo -n 85 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Donc attention à ne pas confondre ${learn}pwd>>test${reset} avec ${learn}echo pwd>>test${reset}."; restore=$(expr $restore + 1) ;&
86) echo -n 86 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk_not_press_key justumen "Maintenant ajoutons le ${voc}résultat${reset} de ${code}pwd${reset} à la fin du fichier 'test'."; restore=$(expr $restore + 1) ;&
87) echo -n 87 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; answer_run "pwd>>test" justumen "Non"; restore=$(expr $restore + 1) ;&
88) echo -n 88 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk_not_press_key justumen "Et affichez le fichier 'test'."; restore=$(expr $restore + 1) ;&
89) echo -n 89 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; answer_run "cat test" justumen "Non"; restore=$(expr $restore + 1) ;&
90) echo -n 90 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Très Bien ! J'espère que le résultat ne vous surprend pas."; restore=$(expr $restore + 1) ;&
91) echo -n 91 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Maintenant revenons à la commande ${code}echo${reset}."; restore=$(expr $restore + 1) ;&
92) echo -n 92 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Certains caractères spéciaux ne sont pas simple à afficher."; restore=$(expr $restore + 1) ;&
93) echo -n 93 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk_not_press_key justumen "Essayez d'afficher la lettre 'a' et la lettre 'b', séparé par deux espaces avec : ${learn}echo a  b${reset}"; restore=$(expr $restore + 1) ;&
94) echo -n 94 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; answer_run "echo a  b" justumen "Non"; restore=$(expr $restore + 1) ;&
95) echo -n 95 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Le résultat n'est pas celui qui était prévu... Il n'y a qu'un seul espace entre a et b."; restore=$(expr $restore + 1) ;&
96) echo -n 96 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Ici, ${code}echo${reset} considère qu'il y a deux arguments, le premier argument 'a' et le deuxième argument 'b'."; restore=$(expr $restore + 1) ;&
97) echo -n 97 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Il affiche donc les deux arguments séparé par un espace."; restore=$(expr $restore + 1) ;&
98) echo -n 98 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Il est donc parfois utile de limiter le nombre d'argument à un !"; restore=$(expr $restore + 1) ;&
99) echo -n 99 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Mais comment afficher cet espace pour que la suite ne soit pas considérée comme un nouvel argument ?"; restore=$(expr $restore + 1) ;&
100) echo -n 100 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Il faudra utiliser ce que l'on appele en informatique un ${voc}caractère d'échappement${reset}."; restore=$(expr $restore + 1) ;&
101) echo -n 101 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Ici, il s'agit du caractère ${code} \ ${reset}."; restore=$(expr $restore + 1) ;&
102) echo -n 102 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Ce caractère d'échappement affectera ${voc}uniquement${reset} le prochain caractère."; restore=$(expr $restore + 1) ;&
103) echo -n 103 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Dans notre cas, pour représenter un espace avec la commande ${code}echo${reset} nous pouvons utiliser ${code}\\ ${reset}."; restore=$(expr $restore + 1) ;&
104) echo -n 104 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk_not_press_key justumen "Essayez donc avec ce caractère d'échappement : ${learn}echo a \\ b${reset}"; restore=$(expr $restore + 1) ;&
105) echo -n 105 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; answer_run "echo a \ b" justumen "Non"; restore=$(expr $restore + 1) ;&
106) echo -n 106 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Il y a bien cette fois deux espaces entre 'a' et 'b', cependant il y a toujours deux arguments, le premier est 'a' et le deuxième est ' b'."; restore=$(expr $restore + 1) ;&
107) echo -n 107 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Pour avoir un seul et unique argument, il faut supprimer cet espace après le 'a'."; restore=$(expr $restore + 1) ;&
108) echo -n 108 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk_not_press_key justumen "Essayez donc avec un seul argument : ${learn}echo a\\ b${reset}"; restore=$(expr $restore + 1) ;&
109) echo -n 109 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; answer_run "echo a\ b" justumen "Non"; restore=$(expr $restore + 1) ;&
110) echo -n 110 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk_not_press_key justumen "Maintenant, essayez d'afficher un deuxième espace entre a et b."; restore=$(expr $restore + 1) ;&
111) echo -n 111 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; answer_run "echo a\ \ b" justumen "Non"; restore=$(expr $restore + 1) ;&
112) echo -n 112 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Ce caractère d'échappement est très utile pour afficher des caractères que vous ne pouvez pas afficher autrement."; restore=$(expr $restore + 1) ;&
113) echo -n 113 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Comme par exemple le symbole ${learn}>${reset}, qui comme vous le savez, est aussi interprété par votre terminal comme un caractère spécial."; restore=$(expr $restore + 1) ;&
114) echo -n 114 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk_not_press_key justumen "Testez donc cette commande : ${learn}echo x\\>y${reset}"; restore=$(expr $restore + 1) ;&
115) echo -n 115 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; answer_run "echo x\>y" justumen "Non"; restore=$(expr $restore + 1) ;&
116) echo -n 116 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Ici, vous comprenez bien ${voc}l'énorme${reset} différence qu'il y a entre ${learn}echo x\>y${reset} et ${learn}echo x>y${reset}."; restore=$(expr $restore + 1) ;&
117) echo -n 117 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "${learn}echo x>y${reset} va créer le nouveau fichier 'y' avec comme contenu 'x' !"; restore=$(expr $restore + 1) ;&
118) echo -n 118 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "${learn}echo x\\>y${reset} affiche simplement du texte dans le terminal."; restore=$(expr $restore + 1) ;&
119) echo -n 119 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Pour affichez le symbole ${code} \ ${reset} avec echo, il suffit de rajouter juste avant votre caractère d'échappement."; restore=$(expr $restore + 1) ;&
120) echo -n 120 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk_not_press_key justumen "Essayez par exemple d'afficher dans votre terminal : ${code}\\quitter${reset}."; restore=$(expr $restore + 1) ;&
121) echo -n 121 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; answer_run "echo \\\\quitter" justumen "Non"; restore=$(expr $restore + 1) ;&
122) echo -n 122 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Dans ${code} \\\\\\quitter ${reset}, le premier ${code} \ ${reset} est le caractère d'échappement, mais le deuxième est simplement le caractère qui doit être interprété littéralement par votre terminal."; restore=$(expr $restore + 1) ;&
123) echo -n 123 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Pour ne pas avoir à utiliser cet ${code} \ ${reset} à chaque espace, vous pouvez également utiliser les ${code}\"${reset}."; restore=$(expr $restore + 1) ;&
124) echo -n 124 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Deux ${code}\"${reset} peuvent agir en temps que ${code}délimiteur${reset} d'arguments."; restore=$(expr $restore + 1) ;&
125) echo -n 125 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "C'est à dire que ${learn}echo x\>y${reset} peut être remplacé par ${learn}echo \"x>y\"${reset}."; restore=$(expr $restore + 1) ;&
126) echo -n 126 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Le contenu entre le premier ${code}\"${reset} et le deuxième ${code}\"${reset} sera considéré comme un seul argument pour la commande ${code}echo${reset}."; restore=$(expr $restore + 1) ;&
127) echo -n 127 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Faisant partie de l'argument, les espaces seront donc traités et affichés en temps que tel."; restore=$(expr $restore + 1) ;&
128) echo -n 128 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk_not_press_key justumen "Essayez donc de faire : ${learn}echo \"X   X\"${reset}"; restore=$(expr $restore + 1) ;&
129) echo -n 129 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; answer_run "echo \"X   X\"" justumen "Non"; restore=$(expr $restore + 1) ;&
130) echo -n 130 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Ici, les espaces s'affichent correctement."; restore=$(expr $restore + 1) ;&
131) echo -n 131 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk_not_press_key justumen "Vous pouvez aussi remplacer les ${code}\"${reset} par des ${code}'${reset}. Faites le donc avec ${learn}echo 'X   X'${reset}"; restore=$(expr $restore + 1) ;&
132) echo -n 132 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; answer_run "echo 'X   X'" justumen "Non"; restore=$(expr $restore + 1) ;&
133) echo -n 133 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Si vous avez de nombreux ${code}'${reset} à afficher, je vous conseille d'utiliser les ${code}\"${reset} comme délimiteur, et si vous avez beaucoup de ${code}\"${reset} à afficher, je vous conseille d'utiliser les ${code}\'${reset} comme délimiteur."; restore=$(expr $restore + 1) ;&
134) echo -n 134 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Par exemple, même si l'affichage est équivalent, ${learn}echo '\"Pierre\" et \"Marie\"'${reset} est plus lisible que ${learn}echo \"\\\"Pierre\\\" et \\\"Marie\\\"\"${reset}."; restore=$(expr $restore + 1) ;&
135) echo -n 135 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Le ${voc}caractère d'échappement${reset} ${code} \ ${reset} peut aussi être utilisé pour afficher d'autres caractères spéciaux, comme des mises à la ligne ou des tabulations."; restore=$(expr $restore + 1) ;&
136) echo -n 136 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk_not_press_key justumen "Regardez rapidement cette liste dans le manuel de la commmande ${code}echo${reset}."; restore=$(expr $restore + 1) ;&
137) echo -n 137 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; answer_run "man echo" justumen "Non"; restore=$(expr $restore + 1) ;&
138) echo -n 138 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Si vous avez bien lu le manuel, vous avez compris que cela ne fonctionnera que si l'option ${code}-e${reset} est présente."; restore=$(expr $restore + 1) ;&
139) echo -n 139 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "La lettre 'n' est utilisée avec ${code} \ ${reset} pour représenter une mise à la ligne, 'n' comme ${code}n${reset}ouvelle ligne."; restore=$(expr $restore + 1) ;&
140) echo -n 140 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk_not_press_key justumen "Affichez donc la lettre 'a', puis la lettre 'b' sur une nouvelle ligne en utilisant les ${code}'${reset} comme délimiteurs."; restore=$(expr $restore + 1) ;&
141) echo -n 141 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; answer_run "echo -e 'a\nb'" justumen "Non"; restore=$(expr $restore + 1) ;&
142) echo -n 142 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk_not_press_key justumen "Trouvez la syntaxe d'une ${voc}tabulation${reset} horizontale dans le manuel de la commande ${code}echo${reset}."; restore=$(expr $restore + 1) ;&
143) echo -n 143 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; answer_run "man echo" justumen "Non"; restore=$(expr $restore + 1) ;&
144) echo -n 144 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk_not_press_key justumen "En utilisant les ${code}'${reset}, affichez la lettre 'a', suivi d'une tabulation, puis de la lettre 'b'."; restore=$(expr $restore + 1) ;&
145) echo -n 145 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; answer_run "echo -e 'a\tb'" justumen "Non"; restore=$(expr $restore + 1) ;&
146) echo -n 146 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk_not_press_key justumen "Maintenant au lieu d'afficher le résultat dans le terminal, mettez le dans un fichier avec le nom 'tab'."; restore=$(expr $restore + 1) ;&
147) echo -n 147 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; answer_run "echo -e 'a\tb'>tab" justumen "Non"; restore=$(expr $restore + 1) ;&
148) echo -n 148 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk_not_press_key justumen "Affichez le contenu du fichier 'tab'."; restore=$(expr $restore + 1) ;&
149) echo -n 149 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; answer_run "cat tab" justumen "Non"; restore=$(expr $restore + 1) ;&
150) echo -n 150 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk_not_press_key justumen "Affichez maintenant en une seule commande le fichier 'test' avec le fichier 'tab' à la suite."; restore=$(expr $restore + 1) ;&
151) echo -n 151 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; answer_run "cat test tab" justumen "Non"; restore=$(expr $restore + 1) ;&
152) echo -n 152 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk_not_press_key justumen "Supprimez maintenant 'tab' et 'test' en une seule commande."; restore=$(expr $restore + 1) ;&
153) echo -n 153 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; answer_run "rm tab test" justumen "Non"; restore=$(expr $restore + 1) ;&
154) echo -n 154 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Excellent ! Vous êtes prêt pour le questionnaire."; restore=$(expr $restore + 1) ;&
155) echo -n 155 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; clean; restore=$(expr $restore + 1) ;&
esac
}
function clean(){ #in enter_chapter
rm $HOME/.GameScript/restore_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
rm $HOME/.GameScript/restore_pwd_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
	rmdir $HOME/.GameScript_bash3/test 2> /dev/null
	rmdir $HOME/.GameScript_bash3 2> /dev/null
}

function start_quiz(){
  echo ""
  echo -e "\e[15;5;44m Bash 'Bourne Again SHell' : Questionnaire du chapitre 3 \e[0m"
  echo -e "- La réponse doit être la plus courte possible, une commande valide mais ajoutant des caractères inutiles ne fonctionnera pas."
  echo -e "Exemple : si la réponse est 'ls'. Les réponses 'ls .', 'ls ./' et 'ls ././' seront considérées comme fausses."
  answer_text_fr "Quel est la version abrégée de 'ls -a -l' ?" "ls -al"
  answer_text_fr "Comment ajouter le mot 'non' à la fin du fichier texte 'oui' ?" "echo non>>oui"
  answer_text_fr "Comment remplacer le contenu du fichier 'test' par 'exemple' ?" "echo exemple>test"
  answer_text_fr "Comment afficher le contenu du fichier 'test' ?" "cat test"
  answer_text_fr "Sur bash, quel est le caractère d'échappement ?" "\\"
  answer_text_fr "Comment afficher dans le terminal : a>b" "echo a\>b"
  answer_text_fr "Quel est la lettre à utiliser après le caractère d'échappement pour représenter une mise à la ligne ?" "n"
  answer_text_fr "Affichez, sans utiliser le caractère d'échappement, la phrase : j'ai bon" "echo \"j'ai bon\""
  answer_text_fr "Affichez trois guillemets (\"), sans utiliser le caractère d'échappement." "echo '\"\"\"'"
  unlock "bash" "3" "2452" "93a3"
}


CHAPTER_NAME="bash"
CHAPTER_NUMBER="3"
LANGUAGE="fr"
SPEAKER="m1"

LINES=154
if [ "$1" == "VIDEO" ]; then
	prepare_video
else
	if [ ! "$1" == "MUTE" ]; then
		prepare_audio
	fi
fi


enter_chapter $CHAPTER_NAME $CHAPTER_NUMBER
