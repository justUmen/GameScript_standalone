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
	while [ "$key" != "1" ] || [ "$key" != "2" ] || [ "$key" != "e" ]; do
		# echo ""
		#~ echo -e "\\e[0;100m 0) \\e[0m Télécharger audio en avance"
		echo -e "\\e[0;100m 1) \\e[0m $1"
		echo -e "\\e[0;100m 2) \\e[0m $2"
		echo -e "\\e[0;100m e) \\e[0m $3"
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
						echo -e "\\e[0;100m e) \\e[0m $TEXT_BACK"
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
	press_key
	echo ""
	exit
}

function enter_chapter(){
	#Usage : enter_chapter bash 1 1 (first 1 is chapter, next one is for case)
	echo ""
	case $LANGUAGE in
		fr) echo -e "\e[97;44m - $1, Chapitre $2 \e[0m"
			answer_quiz "Cours" "Questionnaire" "Retour" "4" "5" "6" "$1" "$2" ;;
		en) echo -e "\e[97;44m - $1, Chapter $2 \e[0m"
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
1) echo -n 1 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; command -v lxterminal >/dev/null 2>&1 || { echo "Veuillez installer les dépendances requises. Faites en tant qu'administrateur : apt-get install i3 i3status qutebrowser mousepad leafpad pcmanfm jq feh wmctrl xdotool lxterminal galculator" >&2; exit 3; }; restore=$(expr $restore + 1) ;&
2) echo -n 2 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; command -v i3 >/dev/null 2>&1 || { echo "Veuillez installer les dépendances requises. Faites en tant qu'administrateur : apt-get install i3 i3status qutebrowser mousepad leafpad pcmanfm jq feh wmctrl xdotool lxterminal galculator" >&2; exit 3; }; restore=$(expr $restore + 1) ;&
3) echo -n 3 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; command -v i3status >/dev/null 2>&1 || { echo "Veuillez installer les dépendances requises. Faites en tant qu'administrateur : apt-get install i3 i3status qutebrowser mousepad leafpad pcmanfm jq feh wmctrl xdotool lxterminal galculator" >&2; exit 3; }; restore=$(expr $restore + 1) ;&
4) echo -n 4 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; command -v qutebrowser >/dev/null 2>&1 || { echo "Veuillez installer les dépendances requises. Faites en tant qu'administrateur : apt-get install i3 i3status qutebrowser mousepad leafpad pcmanfm jq feh wmctrl xdotool lxterminal galculator" >&2; exit 3; }; restore=$(expr $restore + 1) ;&
5) echo -n 5 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; command -v mousepad  >/dev/null 2>&1 || { echo "Veuillez installer les dépendances requises. Faites en tant qu'administrateur : apt-get install i3 i3status qutebrowser mousepad leafpad pcmanfm jq feh wmctrl xdotool lxterminal galculator" >&2; exit 3; }; restore=$(expr $restore + 1) ;&
6) echo -n 6 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; command -v leafpad >/dev/null 2>&1 || { echo "Veuillez installer les dépendances requises. Faites en tant qu'administrateur : apt-get install i3 i3status qutebrowser mousepad leafpad pcmanfm jq feh wmctrl xdotool lxterminal galculator" >&2; exit 3; }; restore=$(expr $restore + 1) ;&
7) echo -n 7 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; command -v pcmanfm >/dev/null 2>&1 || { echo "Veuillez installer les dépendances requises. Faites en tant qu'administrateur : apt-get install i3 i3status qutebrowser mousepad leafpad pcmanfm jq feh wmctrl xdotool lxterminal galculator" >&2; exit 3; }; restore=$(expr $restore + 1) ;&
8) echo -n 8 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; command -v jq >/dev/null 2>&1 || { echo "Veuillez installer les dépendances requises. Faites en tant qu'administrateur : apt-get install i3 i3status qutebrowser mousepad leafpad pcmanfm jq feh wmctrl xdotool lxterminal galculator" >&2; exit 3; }; restore=$(expr $restore + 1) ;&
9) echo -n 9 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; command -v feh >/dev/null 2>&1 || { echo "Veuillez installer les dépendances requises. Faites en tant qu'administrateur : apt-get install i3 i3status qutebrowser mousepad leafpad pcmanfm jq feh wmctrl xdotool lxterminal galculator" >&2; exit 3; }; restore=$(expr $restore + 1) ;&
10) echo -n 10 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; command -v wmctrl >/dev/null 2>&1 || { echo "Veuillez installer les dépendances requises. Faites en tant qu'administrateur : apt-get install i3 i3status qutebrowser mousepad leafpad pcmanfm jq feh wmctrl xdotool lxterminal galculator" >&2; exit 3; }; restore=$(expr $restore + 1) ;&
11) echo -n 11 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; command -v xdotool >/dev/null 2>&1 || { echo "Veuillez installer les dépendances requises. Faites en tant qu'administrateur : apt-get install i3 i3status qutebrowser mousepad leafpad pcmanfm jq feh wmctrl xdotool lxterminal galculator" >&2; exit 3; }; restore=$(expr $restore + 1) ;&
12) echo -n 12 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; command -v galculator >/dev/null 2>&1 || { echo "Veuillez installer les dépendances requises. Faites en tant qu'administrateur : apt-get install i3 i3status qutebrowser mousepad leafpad pcmanfm jq feh wmctrl xdotool lxterminal galculator" >&2; exit 3; }; restore=$(expr $restore + 1) ;&
13) echo -n 13 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; mkdir ~/.config 2>/dev/null; restore=$(expr $restore + 1) ;&
14) echo -n 14 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; mkdir ~/.config/i3 2>/dev/null; restore=$(expr $restore + 1) ;&
15) echo -n 15 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; [ -f "$HOME/.config/i3/config_GS_backup" ] && [ ! -f "$HOME/.GameScript/i3wm_1_installed" ] && echo "$HOME/.config/i3/config_GS_backup existe déjà sur votre système, veuillez le renommer ou le supprimer pour continuer." && exit; restore=$(expr $restore + 1) ;&
16) echo -n 16 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; [ -f "$HOME/.i3/config_GS_backup" ] && [ ! -f "$HOME/.GameScript/i3wm_1_installed" ] && echo "$HOME/.i3/config_GS_backup existe déjà sur votre système, veuillez le renommer ou le supprimer pour continuer." && exit; restore=$(expr $restore + 1) ;&
17) echo -n 17 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; if [ ! -f "$HOME/.GameScript/i3wm_1_installed" ]; then [ -f "$HOME/.config/i3/config" ] && mv $HOME/.config/i3/config $HOME/.config/i3/config_GS_backup && echo "Votre fichier de configuration $HOME/.config/i3/config a été renommé en $HOME/.config/i3/config_GS_backup"; [ -f "$HOME/.i3/config" ] && mv $HOME/.i3/config $HOME/.i3/config_GS_backup && echo "Votre fichier de configuration $HOME/.i3/config a été renommé en $HOME/.i3/config_GS_backup"; touch $HOME/.GameScript/i3wm_1_installed;wget https://raw.githubusercontent.com/justUmen/GameScript/master/fr/classic/i3wm/_1/config -O ~/.config/i3/config &> /dev/null; rm $HOME/.GameScript/restore_i3wm1; echo "SUCCES : Veuillez maintenant fermer votre environment habituel et lancez i3 normalement : Déconnexion et sélection de i3 dans votre Display Manager (lightdm, gdm, xdm...). GameScript sera là pour vous accueillir. :-)"; exit; fi; restore=$(expr $restore + 1) ;&
18) echo -n 18 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; mkdir $HOME/.GameScript_i3wm_1 &> /dev/null; restore=$(expr $restore + 1) ;&
19) echo -n 19 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; cd $HOME/.GameScript_i3wm_1; restore=$(expr $restore + 1) ;&
20) echo -n 20 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; gamescript_window=$(xdotool getwindowfocus); restore=$(expr $restore + 1) ;&
21) echo -n 21 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Dans un ${voc}gestionnaire de fenêtres${reset} (anglais ${voc}Window Manager${reset}), il y a deux choses que vous devez apprendre à manipuler, les espaces de travail (anglais ${voc}Workspaces${reset}) et les fenêtres (anglais ${voc}Windows${reset})."; restore=$(expr $restore + 1) ;&
22) echo -n 22 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Commençons par les ${voc}espaces de travail${reset}. Ici je vais vous donnez mes configurations, mais libre à vous de les modifier plus tard."; restore=$(expr $restore + 1) ;&
23) echo -n 23 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Vous pouvez avoir plusieurs espaces de travail, et chacun pourra avoir ses propres configurations et ses propres objectifs."; restore=$(expr $restore + 1) ;&
24) echo -n 24 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Si vous regardez en bas à gauche de votre écran vous devriez voir le chiffre 1 dans un carre."; restore=$(expr $restore + 1) ;&
25) echo -n 25 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Le 1 est en fait le nom/numéro de l'espace de travail où vous êtes en ce moment."; restore=$(expr $restore + 1) ;&
26) echo -n 26 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Cet espace de travail pour l'instant ne contient que la fenêtre du terminal qui contient GameScript."; restore=$(expr $restore + 1) ;&
27) echo -n 27 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Le gestionnaire de fenêtres i3 (${voc}i3wm${reset}) se base sur des combinaisons de touches pour fonctionner."; restore=$(expr $restore + 1) ;&
28) echo -n 28 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Elles sont toutes personnalisables, mais je vais vous en donner certaines que je vous conseille de garder."; restore=$(expr $restore + 1) ;&
29) echo -n 29 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Vous pouvez passer d'un espace de travail à l'autre avec la touche 'Super', parfois appelée par certains novices : 'touche windows'."; restore=$(expr $restore + 1) ;&
30) echo -n 30 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Il faudra en même temps appuyer sur la touche 'Super' et le numéro de l'espace de travail ou vous voulez aller."; restore=$(expr $restore + 1) ;&
31) echo -n 31 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Gamescript est en ce moment dans l'espace de travail 1, souvenez vous donc que pour continuer à interagir avec GameScript, il vous faudra faire 'Super + 1'."; restore=$(expr $restore + 1) ;&
32) echo -n 32 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Maintenant, déplacez vous dans l'espace de travail 2 avec 'Super + 2', regardez la liste de vos espaces de travail en bas à gauche votre écran, puis faites 'Super + 1' pour revenir sur GameScript."; restore=$(expr $restore + 1) ;&
33) echo -n 33 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 2 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
34) echo -n 34 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ ! `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
35) echo -n 35 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "De retour dans l'espace de travail 1, vous pouvez remarquer que l'espace de travail 2 n'est pas affiché en bas à gauche."; restore=$(expr $restore + 1) ;&
36) echo -n 36 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Pourtant lorsque vous étiez dans l'espace de travail 2, l'espace de travail 1 était visible dans cette liste."; restore=$(expr $restore + 1) ;&
37) echo -n 37 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "En fait, i3 se débarassera automatiquement de tous les espaces de travail qui ne contiennent pas de fenêtres."; restore=$(expr $restore + 1) ;&
38) echo -n 38 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "L'espace de travail 2 étant pour le moment vide, il ne restera pas affiché dans cette liste."; restore=$(expr $restore + 1) ;&
39) echo -n 39 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Contrairement à l'espace de travail 1, qui contient la fenêtre de GameScript."; restore=$(expr $restore + 1) ;&
40) echo -n 40 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Je vous conseille d'utiliser des raccourcis clavier pour tous les programmes que vous utilisez regulièrement."; restore=$(expr $restore + 1) ;&
41) echo -n 41 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Par exemple, pour ouvrir un nouveau terminal, il faudra utiliser le raccourci clavier 'Super + Entrée'."; restore=$(expr $restore + 1) ;&
42) echo -n 42 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "On va commencer par créer une nouvelle fenêtre dans cet espace de travail 2."; restore=$(expr $restore + 1) ;&
43) echo -n 43 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Déplacez vous dans l'espace de travail 2 avec 'Super + 2', ouvrez un nouveau terminal dans cet espace de travail avec 'Super + Entrée', puis revenez sur GameScript avec 'Super + 1'."; restore=$(expr $restore + 1) ;&
44) echo -n 44 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 2 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
45) echo -n 45 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ ! `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
46) echo -n 46 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "De retour dans l'espace de travail 1, vous pouvez remarquer que l'espace de travail 2 est cette fois dans la liste, car maintenant il n'est plus vide."; restore=$(expr $restore + 1) ;&
47) echo -n 47 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Vous pouvez également utiliser votre souris et cliquer sur le nom de l'espace de travail où vous voulez vous rendre."; restore=$(expr $restore + 1) ;&
48) echo -n 48 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Utilisez la liste en bas en gauche pour vous rendre sur l'espace de travail 2, fermez ce terminal et revenez sur GameScript en utilisant votre souris."; restore=$(expr $restore + 1) ;&
49) echo -n 49 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 2 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
50) echo -n 50 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ ! `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
51) echo -n 51 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Regardez maintenant la barre bleu en haut de votre écran : elle contient le titre de la fenêtre qui contient GameScript."; restore=$(expr $restore + 1) ;&
52) echo -n 52 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Bien évidemment, il est possible d'avoir plusieurs fenêtres dans un même espace de travail."; restore=$(expr $restore + 1) ;&
53) echo -n 53 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; i3-msg 'exec lxterminal' &>/dev/null; while [ `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done; i3-msg focus left; restore=$(expr $restore + 1) ;&
54) echo -n 54 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Je viens d'ouvrir un nouveau terminal dans votre espace de travail, vous devriez maintenant voir deux onglets différents en haut de votre écran."; restore=$(expr $restore + 1) ;&
55) echo -n 55 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Chaque onglet correspond a une fenêtre, celui de gauche en bleu est le titre de la fenêtre de GameScript."; restore=$(expr $restore + 1) ;&
56) echo -n 56 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Les fenêtres s'affichent dans ces onglets de gauche à droite, des plus anciennes aux plus récentes."; restore=$(expr $restore + 1) ;&
57) echo -n 57 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Chaque nouvelle fenêtre s'ajoutera donc a droite des onglets deja présents."; restore=$(expr $restore + 1) ;&
58) echo -n 58 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Le terminal qui contient GameScript ayant été ouvert en premier, il restera le plus à gauche."; restore=$(expr $restore + 1) ;&
59) echo -n 59 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Cliquez sur l'onglet de la deuxième fenêtre pour l'afficher, et revenez sur GameScript en cliquant sur le premier onglet."; restore=$(expr $restore + 1) ;&
60) echo -n 60 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done;sleep 1;while [ ! `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
61) echo -n 61 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Bien évidemment, je vous conseille d'utiliser votre clavier pour faire cela bien plus rapidement, vous pouvez tout simplement utiliser 'Super + flèche de gauche/droite'."; restore=$(expr $restore + 1) ;&
62) echo -n 62 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Faites le donc maintenant, utilisez 'Super + la flèche de droite' pour cibler la seconde fenêtre et revenez sur GameScript avec 'Super + flèche de gauche'."; restore=$(expr $restore + 1) ;&
63) echo -n 63 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done;sleep 1;while [ ! `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
64) echo -n 64 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Quand vous ciblez une autre fenêtre, on dit que cette fenêtre a le ${voc}focus${reset}."; restore=$(expr $restore + 1) ;&
65) echo -n 65 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "C'est à dire que tout autre raccourci clavier sera envoyé à la fenêtre qui a le focus en ce moment."; restore=$(expr $restore + 1) ;&
66) echo -n 66 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Par exemple, pour fermer une fenêtre, la combinaison de touche est 'Super + Shift + q', mais attention à ne pas fermer Gamescript par erreur !"; restore=$(expr $restore + 1) ;&
67) echo -n 67 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Changez le focus avec 'Super + flèche de droite', et fermez le deuxième terminal que j'ai ouvert tout à l'heure avec 'Super + Shift + q'."; restore=$(expr $restore + 1) ;&
68) echo -n 68 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; gamescript_window=$(xdotool getwindowfocus); restore=$(expr $restore + 1) ;&
69) echo -n 69 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
70) echo -n 70 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; to_close=$(xdotool getwindowfocus); restore=$(expr $restore + 1) ;&
71) echo -n 71 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `xdotool search --class ""|grep "^$to_close$"` ];do sleep .5; done; restore=$(expr $restore + 1) ;&
72) echo -n 72 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ ! `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
73) echo -n 73 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Maintenant, ouvrez un nouveau terminal avec 'Super + Entrée', vous remarquerez alors que le focus changera automatiquement en faveur de cette nouvelle fenêtre, il vous faudra donc manuellement revenir sur GameScript."; restore=$(expr $restore + 1) ;&
74) echo -n 74 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
75) echo -n 75 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `xdotool getwindowfocus` != $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
76) echo -n 76 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Il y a 3 modes d'affichage des fenêtres sur i3."; restore=$(expr $restore + 1) ;&
77) echo -n 77 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Ici, l'affichage est en ${voc}onglet${reset}, mais vous pouvez aussi avoir une ${voc}liste${reset} des fenêtres de haut en bas, où le titre des fenêtres prendra toute la ligne."; restore=$(expr $restore + 1) ;&
78) echo -n 78 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Mais pour passer d'une fenêtre à l'autre dans ce mode, il faudra utiliser 'Super + flèche du haut/bas' au lieu de gauche et droite."; restore=$(expr $restore + 1) ;&
79) echo -n 79 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Essayez donc ce mode d'affichage maintenant en faisant 'Super + s', et naviguez entre les deux fenêtres avec 'Super + flèche du haut/bas'."; restore=$(expr $restore + 1) ;&
80) echo -n 80 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
81) echo -n 81 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `xdotool getwindowfocus` != $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
82) echo -n 82 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Revenez maintenant au mode d'affichage en onglet en faisant 'Super + w'."; restore=$(expr $restore + 1) ;&
83) echo -n 83 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Et enfin vous avez un troisième mode d'affichage, qui affiche toutes vos fenêtres de votre espace de travail dans un ${voc}damier${reset}."; restore=$(expr $restore + 1) ;&
84) echo -n 84 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Essayez ce mode d'affichage en faisant 'Super + e'."; restore=$(expr $restore + 1) ;&
85) echo -n 85 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "En étant dans ce mode, vous pouvez continuer à utiliser 'Super + e' pour alterner entre découpage vertical et horizontal."; restore=$(expr $restore + 1) ;&
86) echo -n 86 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Faites donc 'Super + e' jusqu'à avoir le nouveau terminal en dessous de la fenêtre de GameScript."; restore=$(expr $restore + 1) ;&
87) echo -n 87 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Ici même si les deux fenêtres sont visibles à l'écran, seulement l'une d'entre elles a le focus."; restore=$(expr $restore + 1) ;&
88) echo -n 88 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Ici la fenêtre qui a le focus a sa barre de titre ainsi que ses contours colorés en bleu."; restore=$(expr $restore + 1) ;&
89) echo -n 89 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Toujours de la même maniere, vous pouvez changer le focus avec 'Super + les flèches de votre clavier'."; restore=$(expr $restore + 1) ;&
90) echo -n 90 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Donnez le focus à la fenêtre du bas et lancer la commande ${learn}ls${reset} dedans, puis redonnez le focus à la fenêtre de GameScript."; restore=$(expr $restore + 1) ;&
91) echo -n 91 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
92) echo -n 92 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `xdotool getwindowfocus` != $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
93) echo -n 93 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Vous pouvez remarquer qu'avec ce mode d'affichage, il est aussi possible de changer la fenêtre focus avec le curseur de votre souris."; restore=$(expr $restore + 1) ;&
94) echo -n 94 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Notez que seul le mouvement de votre curseur est nécessaire pour ce changement de focus, vous n'avez pas besoin de cliquer."; restore=$(expr $restore + 1) ;&
95) echo -n 95 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Essayez donc d'alterner le focus entre les deux fenêtres juste en déplacant votre souris."; restore=$(expr $restore + 1) ;&
96) echo -n 96 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
97) echo -n 97 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `xdotool getwindowfocus` != $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
98) echo -n 98 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Bien évidemment, comme tout ce que vous faites dans i3, je vous conseille d'utiliser votre souris au minimum et de privilégier vos raccourcis clavier."; restore=$(expr $restore + 1) ;&
99) echo -n 99 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Attention, après cette phrase, la fenêtre de GameScript disparaitra... et il vous faudra la retrouver pour continuer !!"; restore=$(expr $restore + 1) ;&
100) echo -n 100 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; i3-msg 'move window to workspace 5' &>/dev/null; restore=$(expr $restore + 1) ;&
101) echo -n 101 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 5 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
102) echo -n 102 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Félicitations, vous avez retrouvé GameScript dans l'espace de travail 5 !"; restore=$(expr $restore + 1) ;&
103) echo -n 103 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Vous savez déjà comment passer d'un espace de travail à l'autre, mais il est aussi possible de déplacer vos fenêtres dans un autre espace de travail."; restore=$(expr $restore + 1) ;&
104) echo -n 104 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Remettez donc la fenêtre de GameScript dans l'espace de travail 1 avec 'Super + Shift + 1', puis revenez sur l'espace de travail 1 pour retrouver GameScript et continuer."; restore=$(expr $restore + 1) ;&
105) echo -n 105 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 1 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
106) echo -n 106 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ ! `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
107) echo -n 107 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Vous pouvez remarquer que la fenêtre de GameScript est désormais en dessous, car elle est devenu la fenêtre la plus récente sur cet espace de travail."; restore=$(expr $restore + 1) ;&
108) echo -n 108 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Si l'affichage était en onglet, GameScript serait donc dans l'onglet le plus à droite."; restore=$(expr $restore + 1) ;&
109) echo -n 109 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Avoir plusieurs espaces de travail différents vous permet d'organiser vos fenêtres selon votre volonté."; restore=$(expr $restore + 1) ;&
110) echo -n 110 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Personnelement, j'utilise l'espace de travail 1 pour mon terminal principal, qui doit toujours être opérationnel rapidement."; restore=$(expr $restore + 1) ;&
111) echo -n 111 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "J'utilise l'espace de travail 2 pour mes éditeurs de texte."; restore=$(expr $restore + 1) ;&
112) echo -n 112 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "J'utilise l'espace de travail 3 pour mes navigateur web et autres fenêtres orientés web."; restore=$(expr $restore + 1) ;&
113) echo -n 113 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "J'utilise l'espace de travail 4 pour mes gestionnaires de fichiers."; restore=$(expr $restore + 1) ;&
114) echo -n 114 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Et j'utilise l'espace de travail 5 pour tout ce qui est social : email, notre rocketchat, notre discord, etc..."; restore=$(expr $restore + 1) ;&
115) echo -n 115 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Organiser vos fenêtres par thème vous permet de les retrouver très rapidement, même si elles sont très nombreuses."; restore=$(expr $restore + 1) ;&
116) echo -n 116 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; gamescript_window=$(xdotool getwindowfocus); restore=$(expr $restore + 1) ;&
117) echo -n 117 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Fermez la fenêtre du dessus pour continuer."; restore=$(expr $restore + 1) ;&
118) echo -n 118 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
119) echo -n 119 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; to_close=$(xdotool getwindowfocus); restore=$(expr $restore + 1) ;&
120) echo -n 120 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `xdotool search --class ""|grep "^$to_close$"` ];do sleep .5; done; restore=$(expr $restore + 1) ;&
121) echo -n 121 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ ! `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
122) echo -n 122 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; echo -e "<html>\\n\\t<head>\\n\\t\\t<link rel="stylesheet" href="style.css">\\n\\t</head>\\n\\t<body>\\n\\t\\t<h1>GameScript</h1>\\n\\t\\t<div>bonjour</div>\\n\\t</body>\\n</html>" > ~/.GameScript_i3wm_1/index.html; restore=$(expr $restore + 1) ;&
123) echo -n 123 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; echo -e "h1{color:red;}" > ~/.GameScript_i3wm_1/style.css; restore=$(expr $restore + 1) ;&
124) echo -n 124 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; i3-msg exec leafpad ~/.GameScript_i3wm_1/index.html &>/dev/null; restore=$(expr $restore + 1) ;&
125) echo -n 125 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; i3-msg exec qutebrowser ~/.GameScript_i3wm_1/index.html &>/dev/null; restore=$(expr $restore + 1) ;&
126) echo -n 126 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; i3-msg exec pcmanfm ~/.GameScript_i3wm_1/ &>/dev/null; restore=$(expr $restore + 1) ;&
127) echo -n 127 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Je viens de préparer pour vous un exemple complet, avec une fenêtre par espace de travail."; restore=$(expr $restore + 1) ;&
128) echo -n 128 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Cet exemple utilise mes configurations personnelles, mais libre à vous d'avoir votre propre organisation plus tard, en fonction des programmes que vous utilisez le plus souvent."; restore=$(expr $restore + 1) ;&
129) echo -n 129 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "L'espace de travail 2 contient un fichier 'index.html' ouvert dans un éditeur de texte (leafpad), visitez cet espace de travail avant de revenir sur GameScript."; restore=$(expr $restore + 1) ;&
130) echo -n 130 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 2 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
131) echo -n 131 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 1 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
132) echo -n 132 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ ! `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
133) echo -n 133 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "L'espace de travail 3 contient le même fichier html ouvert dans un navigateur web (qutebrowser), visitez cet espace de travail avant de revenir sur GameScript."; restore=$(expr $restore + 1) ;&
134) echo -n 134 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 3 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
135) echo -n 135 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 1 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
136) echo -n 136 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ ! `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
137) echo -n 137 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Et enfin, l'espace de travail 4 contient un gestionnaire de fichier (pcmanfm) ouvert dans le dossier qui contient ce fichier html. Visitez cet espace de travail avant de revenir sur GameScript."; restore=$(expr $restore + 1) ;&
138) echo -n 138 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 4 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
139) echo -n 139 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 1 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
140) echo -n 140 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ ! `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
141) echo -n 141 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Donc au lieu d'avoir 4 fenêtres différentes, vous avez ici 4 espaces de travail contenant chacun une fenêtre."; restore=$(expr $restore + 1) ;&
142) echo -n 142 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Modifiez le mot 'bonjour' du fichier html par le mot 'bonsoir' dans l'espace de travail 2, sauvegardez le fichier, puis revenez sur GameScript."; restore=$(expr $restore + 1) ;&
143) echo -n 143 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 2 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
144) echo -n 144 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 1 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
145) echo -n 145 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Affichez maintenant le changement en actualisant votre navigateur web dans l'espace de travail 3, puis revenez sur GameScript. (Touche F5)"; restore=$(expr $restore + 1) ;&
146) echo -n 146 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 3 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
147) echo -n 147 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 1 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
148) echo -n 148 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Allez maintenant sur l'espace de travail 4 et ouvrez le fichier 'style.css' avec leafpad en faisant clic droit sur le fichier, ouvrir avec, Leafpad, puis revenez sur GameScript."; restore=$(expr $restore + 1) ;&
149) echo -n 149 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 4 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
150) echo -n 150 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 1 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
151) echo -n 151 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Vous avez surement remarqué que leafpad ne s'est pas ouvert dans l'espace de travail 4, mais dans l'espace de travail 2 !"; restore=$(expr $restore + 1) ;&
152) echo -n 152 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "C'est en fait parce que j'ai configuré votre i3 pour que cela soit le cas."; restore=$(expr $restore + 1) ;&
153) echo -n 153 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Votre espace de travail 2 devrait d'ailleurs être en ce moment de couleur rouge dans la liste des espaces de travail."; restore=$(expr $restore + 1) ;&
154) echo -n 154 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Ce rouge veut dire qu'une nouvelle fenêtre vient de s'ouvrir dans cet espace de travail, et cette couleur restera rouge tant que cette fenêtre n'aura pas recu de focus."; restore=$(expr $restore + 1) ;&
155) echo -n 155 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Modifiez donc ce fichier 'style.css' en changeant 'red' par 'blue', enregistrez les modifications, verifiez l'effet de vos changements dans l'espace de travail 3 avec F5 et revenez sur GameScript."; restore=$(expr $restore + 1) ;&
156) echo -n 156 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 2 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
157) echo -n 157 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 3 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
158) echo -n 158 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 1 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
159) echo -n 159 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Avec i3, il est donc possible de contrôler dans quel espace de travail se lance quel programme."; restore=$(expr $restore + 1) ;&
160) echo -n 160 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "'leafpad' étant un éditeur de texte, nous voulons qu'il soit sur l'espace de travail 2 par défaut."; restore=$(expr $restore + 1) ;&
161) echo -n 161 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Ce genre d'envie doit être écrit dans le fichier de configuration d'i3 : ${code}$HOME/.config/i3/config${reset}"; restore=$(expr $restore + 1) ;&
162) echo -n 162 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Pour ouvrir systématiquement 'leafpad' dans l'espace de travail 2, j'ai ajouté dans votre fichier de configuration la ligne : ${code}assign [class=\"Leafpad\"] workspace 2${reset}"; restore=$(expr $restore + 1) ;&
163) echo -n 163 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Essayez donc de faire la même chose avec 'mousepad', un autre éditeur de texte : ${learn}echo 'assign [class=\"Mousepad\"] workspace 2'>>~/.config/i3/config${reset}"; restore=$(expr $restore + 1) ;&
164) echo -n 164 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; answer_run "echo 'assign [class=\"Mousepad\"] workspace 2'>>~/.config/i3/config" justumen ""; restore=$(expr $restore + 1) ;&
165) echo -n 165 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Lancez maintenant 'mousepad' en le détachant du terminal de GameScript et ignorant ses erreurs en faisant : ${learn}mousepad&>/dev/null&${reset}"; restore=$(expr $restore + 1) ;&
166) echo -n 166 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; answer_run "mousepad&>/dev/null&" justumen ""; restore=$(expr $restore + 1) ;&
167) echo -n 167 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Vous pouvez remarquer que 'mousepad' s'est ouvert sur l'espace de travail 1, ce qui n'est pas vraiment ce qui était prévu."; restore=$(expr $restore + 1) ;&
168) echo -n 168 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Pour que vos modifications soit prises en compte, il vous faudra ${voc}réactualiser${reset} le fichier de configuration avec : 'Super + Shift + c', faites le donc maintenant avant de continuer."; restore=$(expr $restore + 1) ;&
169) echo -n 169 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Après avoir fait 'Super + Shift + c', vous devriez voir l'interface d'i3 clignoter pendant un bref instant."; restore=$(expr $restore + 1) ;&
170) echo -n 170 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Mais notre fenêtre de 'mousepad' est toujours dans l'espace de travail 1, car 'assign' n'aura d'effet que pour les nouvelles fenêtres."; restore=$(expr $restore + 1) ;&
171) echo -n 171 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Fermez donc cette fenêtre de 'mousepad' avant de continuer."; restore=$(expr $restore + 1) ;&
172) echo -n 172 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "A partir de maintenant, toutes les instances de 'mousepad' seront automatiquement lancées dans l'espace de travail 2."; restore=$(expr $restore + 1) ;&
173) echo -n 173 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Lancez donc mousepad à nouveau avec : ${learn}mousepad&>/dev/null&${reset}"; restore=$(expr $restore + 1) ;&
174) echo -n 174 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; answer_run "mousepad&>/dev/null&" justumen ""; restore=$(expr $restore + 1) ;&
175) echo -n 175 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Vous êtes toujours en ce moment dans l'espace de travail 1, mais vous devriez voir l'espace de travail 2 s'illuminer en rouge."; restore=$(expr $restore + 1) ;&
176) echo -n 176 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Trouvez et fermez cette nouvelle fenêtre de 'mousepad' avant de continuer."; restore=$(expr $restore + 1) ;&
177) echo -n 177 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 2 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
178) echo -n 178 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 1 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
179) echo -n 179 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Ouvrez donc maintenant 'galculator' avec ${learn}galculator&>/dev/null&${reset} et revenez sur gamescript."; restore=$(expr $restore + 1) ;&
180) echo -n 180 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; answer_run "galculator&>/dev/null&" justumen ""; restore=$(expr $restore + 1) ;&
181) echo -n 181 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Vous pouvez remarquer que cette fenêtre remplira la moitié de votre écran, ce qui n'est pas vraiment pratique pour ce genre de fenêtre..."; restore=$(expr $restore + 1) ;&
182) echo -n 182 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Dans ce genre de situation, il existe un mode particulier dit ${voc}flottant${reset} (anglais floating${reset}), que vous pouvez activer et désactiver avec la combinaison de touche 'Super + Shift + Espace'."; restore=$(expr $restore + 1) ;&
183) echo -n 183 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Après avoir 'focus' la calculatrice, utilisez donc cette combinaison de touche pour la rendre indépendante des autres."; restore=$(expr $restore + 1) ;&
184) echo -n 184 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Vous pouvez remarquer que sur i3 une fenêtre flottante est toujours au premier plan, même si le focus est sur une autre fenêtre !"; restore=$(expr $restore + 1) ;&
185) echo -n 185 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Mais ce changement est temporaire : Il n'affectera que cette instance de galculator !"; restore=$(expr $restore + 1) ;&
186) echo -n 186 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Pour que 'galculator' soit toujours en mode flottant, il va falloir encore une fois modifier le fichier de configuration."; restore=$(expr $restore + 1) ;&
187) echo -n 187 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Le code ${code}assign [class=\"Leafpad\"] workspace 2${reset} que nous avons déjà vu, cible toutes les nouvelles instances de leafpad en utilisant en argument ${code}class${reset} qui doit  être égal à ${code}Leafpad${reset}."; restore=$(expr $restore + 1) ;&
188) echo -n 188 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Pour connaitre la classe (anglais ${voc}class${reset}) d'une fenêtre vous pouvez utiliser la commande : ${code}xprop${reset}"; restore=$(expr $restore + 1) ;&
189) echo -n 189 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Lancez donc la commande ${learn}xprop${reset}, le curseur de votre souris deviendra une croix, puis cliquez sur le terminal qui contient GameScript."; restore=$(expr $restore + 1) ;&
190) echo -n 190 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; answer_run "xprop" justumen ""; restore=$(expr $restore + 1) ;&
191) echo -n 191 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Le nom de la 'class' de la fenêtre que vous avez ciblée est le deuxième nom de la ligne qui commence par 'WM_CLASS'."; restore=$(expr $restore + 1) ;&
192) echo -n 192 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Si seul cette ligne vous intéresse, vous pouvez utiliser ${code}grep${reset}."; restore=$(expr $restore + 1) ;&
193) echo -n 193 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Faites donc ${learn}xprop|grep CLASS${reset} et cliquez sur la calculatrice pour récuperer le nom de sa 'class'."; restore=$(expr $restore + 1) ;&
194) echo -n 194 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; answer_run "xprop|grep CLASS" justumen ""; restore=$(expr $restore + 1) ;&
195) echo -n 195 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Votre résultat devrait être : ${code}WM_CLASS(STRING) = \"galculator\", \"Galculator\"${reset}"; restore=$(expr $restore + 1) ;&
196) echo -n 196 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "La ${code}class${reset} est ici la deuxième chaine de caractères : ${code}\"Galculator\"${reset}"; restore=$(expr $restore + 1) ;&
197) echo -n 197 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Pour que la ${code}class${reset} qui correspond à ${code}Galculator${reset} soit systématiquement en mode flottant, il faudra ajouter dans le fichier de configuration : ${code}for_window [class=\"Galculator\"] floating enable${reset}"; restore=$(expr $restore + 1) ;&
198) echo -n 198 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Si vous voulez que votre fenêtre flottante soit présente sur tous les espaces de travail (${voc}collante${reset}, anglais ${voc}sticky${reset}), il vous faudra utiliser ${code}sticky enable${reset}."; restore=$(expr $restore + 1) ;&
199) echo -n 199 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "${code}for_window${reset} accepte plusieurs paramètres, que vous pouvez séparer par des virgules."; restore=$(expr $restore + 1) ;&
200) echo -n 200 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Pour que la 'class' ${code}Galculator${reset} soit à la fois flottante et présente sur tous les espaces de travail, il faudra donc faire : ${code}for_window [class=\"Galculator\"] floating enable, sticky enable${reset}"; restore=$(expr $restore + 1) ;&
201) echo -n 201 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Fermez la calculatrice et faites : ${code}echo 'for_window [class=\"Galculator\"] floating enable, sticky enable'>>~/.config/i3/config${reset}"; restore=$(expr $restore + 1) ;&
202) echo -n 202 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; answer_run "echo 'for_window [class=\"Galculator\"] floating enable, sticky enable'>>~/.config/i3/config" justumen ""; restore=$(expr $restore + 1) ;&
203) echo -n 203 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Affichez les deux dernières lignes de votre fichier de configuration avec : ${learn}tail -n 2 ~/.config/i3/config${reset}"; restore=$(expr $restore + 1) ;&
204) echo -n 204 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; answer_run "tail -n 2 ~/.config/i3/config" justumen ""; restore=$(expr $restore + 1) ;&
205) echo -n 205 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Bien sur, n'oubliez pas de réactualiser le fichier de configuration maintenant avec 'Super + Shift + c'."; restore=$(expr $restore + 1) ;&
206) echo -n 206 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Apres avoir réactualisé le fichier de configuration, relancez donc 'galculator' avec : ${learn}galculator&>/dev/null&${reset}"; restore=$(expr $restore + 1) ;&
207) echo -n 207 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; answer_run "galculator&>/dev/null&" justumen ""; restore=$(expr $restore + 1) ;&
208) echo -n 208 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Ici vous pouvez voir que la calculatrice est maintenant en mode flottant grâce au code ${code}floating enable${reset}."; restore=$(expr $restore + 1) ;&
209) echo -n 209 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Mais si vous essayez de changer d'espace de travail, vous verrez qu'avec le code ${code}sticky enable${reset} la fenêtre vous suivra."; restore=$(expr $restore + 1) ;&
210) echo -n 210 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Déplacez vous donc dans l'espace de travail 5 et revenez sur GameScript."; restore=$(expr $restore + 1) ;&
211) echo -n 211 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 5 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
212) echo -n 212 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 1 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
213) echo -n 213 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Vous pouvez noter que le mode 'sticky' ne fonctionne que si pour les fenêtres flottantes."; restore=$(expr $restore + 1) ;&
214) echo -n 214 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Notez également que pour déplacer cette fenêtre flottante, vous pouvez maintenir la touche 'Super' et le bouton gauche de votre souris enfoncés."; restore=$(expr $restore + 1) ;&
215) echo -n 215 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Essayez donc de déplacer la calculatrice en maintenant la touche 'Super' enfoncée, vous n'avez pas besoin de cliquer sur la barre de titre."; restore=$(expr $restore + 1) ;&
216) echo -n 216 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Il n'est cependant pas très pratique d'avoir à lancer toutes les applications à partir d'un terminal."; restore=$(expr $restore + 1) ;&
217) echo -n 217 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "C'est pourquoi un ${voc}lanceur d'application${reset} (anglais ${voc}run dialog${reset}) est un outil très important dans i3 !"; restore=$(expr $restore + 1) ;&
218) echo -n 218 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Nous allons donc créer notre premier raccourci clavier personnalisé pour ce lanceur d'application."; restore=$(expr $restore + 1) ;&
219) echo -n 219 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Pour créer un nouveau raccourci clavier, il faudra utiliser ${code}bindsym${reset}. ('bind' est l'anglais de 'lier')"; restore=$(expr $restore + 1) ;&
220) echo -n 220 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Pour cet exemple nous utiliserons comme lanceur d'application : ${code}rofi${reset}, plus précisement la commande ${code}rofi -show run${reset} et la combinaison de touche 'Alt + F2'."; restore=$(expr $restore + 1) ;&
221) echo -n 221 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Dans le fichier de configuration d'i3, si vous voulez lancez une commande, il faudra la précéder par le mot clef ${code}exec${reset}."; restore=$(expr $restore + 1) ;&
222) echo -n 222 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Pour i3, la touche 'Alt' est ${code}mod1${reset}, et la touche 'Super' est ${code}mod4${reset}. Le code de configuration sera donc : ${code}bindsym mod1+F2 exec rofi -show run${reset}"; restore=$(expr $restore + 1) ;&
223) echo -n 223 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Ajoutez donc ce code à la suite de votre fichier de configuration avec : ${learn}echo 'bindsym mod1+F2 exec rofi -show run'>>~/.config/i3/config${reset}"; restore=$(expr $restore + 1) ;&
224) echo -n 224 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; answer_run "echo 'bindsym mod1+F2 exec rofi -show run'>>~/.config/i3/config" justumen ""; restore=$(expr $restore + 1) ;&
225) echo -n 225 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Et enfin, réactualisez votre fichier de configuration avec 'Super + Shift + c'."; restore=$(expr $restore + 1) ;&
226) echo -n 226 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Faites maintenant 'Alt + F2' pour lancer ${code}rofi -show run${reset}, et exécutez 'galculator' avec."; restore=$(expr $restore + 1) ;&
227) echo -n 227 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Voila donc trois examples pour les trois configurations les plus fondamentales d'i3 : ${code}assign${reset}, ${code}for_window${reset} et ${code}bindsym${reset}."; restore=$(expr $restore + 1) ;&
228) echo -n 228 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Pour un rappel de syntaxe, affichez les 3 lignes de configurations que nous avons ajoutées dans ce chapitre avec : ${learn}tail -n 3 ~/.config/i3/config${reset}"; restore=$(expr $restore + 1) ;&
229) echo -n 229 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; answer_run "tail -n 3 ~/.config/i3/config" justumen ""; restore=$(expr $restore + 1) ;&
230) echo -n 230 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "${code}assign${reset} est utilisé pour lier certaines fenêtres à un certain espace de travail."; restore=$(expr $restore + 1) ;&
231) echo -n 231 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "${code}for_window${reset} est utilisé pour donner une configuration particulière à certaines fenêtres."; restore=$(expr $restore + 1) ;&
232) echo -n 232 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Et enfin ${code}bindsym${reset} est utilisé pour lancer d'autres commandes directement avec une combinaison de touche."; restore=$(expr $restore + 1) ;&
233) echo -n 233 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Vous pouvez maintenant fermer les calculatrices."; restore=$(expr $restore + 1) ;&
234) echo -n 234 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Bien évidemment tous les combinaisons de touche que vous utilisez sont personnalisables."; restore=$(expr $restore + 1) ;&
235) echo -n 235 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Par exemple, pour recharger votre fichier de configuration vous devez faire : 'Super+Shift+c'."; restore=$(expr $restore + 1) ;&
236) echo -n 236 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Mais ce code est modifiable comme tous les autres dans votre fichier de configuration. Faites donc : ${learn}grep reload ~/.config/i3/config${reset}"; restore=$(expr $restore + 1) ;&
237) echo -n 237 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; answer_run "grep reload ~/.config/i3/config" justumen ""; restore=$(expr $restore + 1) ;&
238) echo -n 238 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Ici vous devriez voir le 'bindsym' responsable de cette combinaison de touche, mais libre à vous de le modifier si vous le désirez."; restore=$(expr $restore + 1) ;&
239) echo -n 239 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk_not_press_key justumen "Par exemple, pour voir la ligne responsable pour quitter i3, faites : ${learn}grep exit ~/.config/i3/config${reset}"; restore=$(expr $restore + 1) ;&
240) echo -n 240 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; answer_run "grep exit ~/.config/i3/config" justumen ""; restore=$(expr $restore + 1) ;&
241) echo -n 241 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Essayez de faire maintenant 'Super + Shift + e' pour voir ce code en action : vous recevrez un message demandant votre confirmation, cliquez ensuite sur la croix pour annuler la fermeture de i3."; restore=$(expr $restore + 1) ;&
242) echo -n 242 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Et si par exemple vous voulez lancer 'nm-applet' au démarrage d'i3, il suffit de mettre dans votre fichier de configuration : ${code}exec nm-applet${reset}."; restore=$(expr $restore + 1) ;&
243) echo -n 243 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "'nm-applet' est une interface graphique capable de gérer les configurations réseaux de 'NetworkManager'. (Installable avec le paquet 'network-manager-applet' sur Arch et 'network-manager-gnome' sur Debian.)"; restore=$(expr $restore + 1) ;&
244) echo -n 244 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "L'utilisation des raccourcis clavier peut vous paraitre étrange pour le moment, mais faites moi confiance, vous ne pourrez bientôt plus vous en passer !"; restore=$(expr $restore + 1) ;&
245) echo -n 245 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; i3-msg exec 'mousepad ~/.config/i3/config'; restore=$(expr $restore + 1) ;&
246) echo -n 246 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Avant d'en finir avec ce chapitre, je viens d'ouvrir pour vous le fichier de configuration d'i3 dans l'espace de travail 2."; restore=$(expr $restore + 1) ;&
247) echo -n 247 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Pour éviter que 'GameScript i3wm' ne se lance au démarrage à chaque fois, supprimez la première ligne contenant le code 'exec'."; restore=$(expr $restore + 1) ;&
248) echo -n 248 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "C'est tout pour cette fois, dans le prochain chapitre nous verrons comment contrôler avec précision l'organisation de nos fenêtres."; restore=$(expr $restore + 1) ;&
249) echo -n 249 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "En avant pour le questionnaire !"; restore=$(expr $restore + 1) ;&
250) echo -n 250 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; clean; restore=$(expr $restore + 1) ;&
esac
}
function clean(){ #in enter_chapter
rm $HOME/.GameScript/restore_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
rm $HOME/.GameScript/restore_pwd_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
}

function start_quiz(){
  echo ""
  echo -e "\e[15;5;44m i3wm 'i3 Window Manager' : Questionnaire du chapitre 1 \e[0m"
  echo -e "- La réponse doit être la plus courte possible, une commande valide mais ajoutant des caractères inutiles ne fonctionnera pas."
  echo -e "Exemple : si la réponse est 'ls'. Les réponses 'ls .', 'ls ./' et 'ls ././' seront considérées comme fausses."
  answer_text_fr "Quel est la touche 'INCONNU' dans cette phrase : Pour quitter i3 faites Super + Shift + INCONNU" "e"
  answer_text_fr "La combinaison de touche 'Super + Shift + Entrée' ouvre un nouveau terminal. (vrai/faux)" "faux"
  answer_text_fr "Les fenêtres flottantes sont toujours au premier plan. (vrai/faux)" "vrai"
  answer_text_fr "Le code de configuration pour que leafpad soit dans une fenêtre flottante est (vrai/faux) : assign [class=\"Leafpad\"] floating enable" "faux"
  answer_text_fr "Quel est le code à ajouter dans le fichier de configuration d'i3 pour lancer le script '/this/script.sh' au démarrage d'i3." "exec /this/script.sh"
  answer_text_fr "Quel est le mot clef responsable de la création des nouveaux raccourcis clavier dans le fichier de configuration d'i3 ?" "bindsym"
  answer_text_fr "Quel est le code à ajouter dans le fichier de configuration d'i3 pour lancer le script '/this/script.sh' avec la combinaison de touche Alt + o ?" "bindsym mod1+o exec /this/script.sh"
  answer_text_fr "Justumen aime bien i3. (vrai/faux)" "vrai"
  
  wget "https://github.com/justUmen/WallpaperGenerator/raw/master/Wallpaper/fr/i3wm_1/`xrandr | grep ' connected' | sed 's/.*primary //' | sed 's/+.*//'`.jpg" -O ~/.GameScript/i3wm_1_wallpaper.jpg &>/dev/null
  feh --bg-scale ~/.GameScript/i3wm_1_wallpaper.jpg

  echo -e "Je viens de changer votre fond d'écran avec un rappel de ce que vous venez d'apprendre dans ce chapitre. (Commande : 'feh --bg-scale ~/.GameScript/i3wm_1_wallpaper.jpg')"
  echo -e "Vous pouvez donc désormais vous rendre sur un espace de travail vide pour un rappel rapide des combinaisons de touche de ce chapitre. :-)"
  echo -e "Si vous désirez que ce fond d'écran soit utilisé a chaque redémarrage, rajoutez 'exec feh --bg-scale ~/.GameScript/i3wm_1_wallpaper.jpg' dans votre fichier de configuration."

  echo -e "Si le fond d'écran ne s'affiche pas, c'est probablement parce la résolution de votre écran n'est pas supportée, veuillez me contacter pour que je puisse l'ajouter à la liste."
  echo -e "Pour voir les résolutions disponibles, vous pouvez visitez : https://github.com/justUmen/WallpaperGenerator/tree/master/Wallpaper/fr/i3wm_1"
  echo -e "Pour connaitre la résolution de votre écran, vous pouvez utiliser la commande : 'xrandr'"

  unlock "i3wm" "1" "99ac" "871f"
 }


CHAPTER_NAME="i3wm"
CHAPTER_NUMBER="1"
LANGUAGE="fr"
SPEAKER="m1"

LINES=249
if [ ! "$1" == "MUTE" ]; then prepare_audio; fi

enter_chapter $CHAPTER_NAME $CHAPTER_NUMBER
