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
	VOICE_PID=$(ps -f|grep "$SOUNDPLAYER"|grep -v grep|grep -v MUSIC|awk '{print $2}')
	#~ echo "VOICE_PID = $VOICE_PID"
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
1) echo -n 1 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; [ -d "$HOME/.GameScript_bash7" ] && echo "Erreur inattendue, ${HOME}/.GameScript_bash7 existe déjà sur votre système ! Supprimez ce dossier $HOME/.GameScript_bash7 et relancez ce script." && exit; restore=$(expr $restore + 1) ;&
2) echo -n 2 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; mkdir $HOME/.GameScript_bash7 2> /dev/null; restore=$(expr $restore + 1) ;&
3) echo -n 3 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; cd $HOME/.GameScript_bash7; restore=$(expr $restore + 1) ;&
4) echo -n 4 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Nous avons déjà vu dans les chapitres précédents comment utiliser le symbole ${code}>${reset}."; restore=$(expr $restore + 1) ;&
5) echo -n 5 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Ce symbole nous permet de rediriger le résultat d'une commande vers un fichier, comme par exemple ${learn}ls>file${reset}."; restore=$(expr $restore + 1) ;&
6) echo -n 6 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Le fichier 'file' sera créé s'il n'existe pas et contiendra le résultat de la commande ${learn}ls${reset}."; restore=$(expr $restore + 1) ;&
7) echo -n 7 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Avec le symbole ${code}>${reset} le résultat de la commande à sa gauche ne s'affiche plus dans le terminal."; restore=$(expr $restore + 1) ;&
8) echo -n 8 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Commencez par cette commande avec une faute de frappe : ${learn}lss>file${reset}"; restore=$(expr $restore + 1) ;&
9) echo -n 9 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "lss>file" justumen "Non"; restore=$(expr $restore + 1) ;&
10) echo -n 10 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Maintenant affichez le contenu de 'file'."; restore=$(expr $restore + 1) ;&
11) echo -n 11 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "cat file" justumen "Non"; restore=$(expr $restore + 1) ;&
12) echo -n 12 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Ici, la commande ${learn}lss>file${reset} nous affiche une erreur dans le terminal et le fichier 'file' est vide."; restore=$(expr $restore + 1) ;&
13) echo -n 13 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "On aurait pu penser qu'avec la commande ${learn}lss>file${reset}, que le message d'erreur serait dans le fichier 'file'."; restore=$(expr $restore + 1) ;&
14) echo -n 14 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; stdout; restore=$(expr $restore + 1) ;&
15) echo -n 15 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Et bien non ! Lorsqu'une commande s'exécute, il y en en fait ${voc}deux${reset} flux de sortie indépendants."; restore=$(expr $restore + 1) ;&
16) echo -n 16 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Le premier flux est celui que nous avons déjà redirigé avec le ${code}>${reset}, il s'agit de la ${voc}sortie standard${reset}. (en anglais stdout ou standard output)"; restore=$(expr $restore + 1) ;&
17) echo -n 17 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; stderr; restore=$(expr $restore + 1) ;&
18) echo -n 18 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Les erreurs utilisent un autre flux de sortie, qui s'appelle la ${voc}sortie erreur standard${reset}. (en anglais stderr ou standard error)"; restore=$(expr $restore + 1) ;&
19) echo -n 19 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Ayant deux flux différents, il est par exemple possible de rediriger les résultats d'un coté, et les erreurs de l'autre."; restore=$(expr $restore + 1) ;&
20) echo -n 20 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Par défaut, sans l'utilisation des redirections, un terminal affiche les deux flux au même endroit."; restore=$(expr $restore + 1) ;&
21) echo -n 21 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Pour rediriger la ${voc}sortie standard${reset}, il faudra utiliser ${code}1>${reset}."; restore=$(expr $restore + 1) ;&
22) echo -n 22 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; stdout_2; restore=$(expr $restore + 1) ;&
23) echo -n 23 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "${code}>${reset} est en fait une abréviation de ${code}1>${reset}. Les deux sont équivalents et redirigent la ${voc}sortie standard${reset}."; restore=$(expr $restore + 1) ;&
24) echo -n 24 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Faites donc un ${learn}pwd1>file${reset}"; restore=$(expr $restore + 1) ;&
25) echo -n 25 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "pwd1>file" justumen "Non"; restore=$(expr $restore + 1) ;&
26) echo -n 26 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Ici nous avons un problème parce que le terminal considère que la commande complète n'est pas ${code}pwd${reset}, mais ${code}pwd1${reset}."; restore=$(expr $restore + 1) ;&
27) echo -n 27 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Nous avons déjà vu dans le chapitre 3 que la commande ${learn}echo a  b${reset} était équivalente à ${learn}echo a b${reset}."; restore=$(expr $restore + 1) ;&
28) echo -n 28 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "${code}echo${reset} considère que le premier argument est 'a' et que le deuxième est 'b'."; restore=$(expr $restore + 1) ;&
29) echo -n 29 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Mais cette logique s'applique à toutes les commandes. Il est en fait possible d'ajouter des espaces à volonté."; restore=$(expr $restore + 1) ;&
30) echo -n 30 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Par exemple, ${learn}ls -a${reset} est équivalent ${learn}ls          -a${reset}."; restore=$(expr $restore + 1) ;&
31) echo -n 31 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "L'option '-a' a besoin ${voc}d'au moins un espace${reset} pour qu'elle puisse être interprétée comme une option."; restore=$(expr $restore + 1) ;&
32) echo -n 32 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Faites donc un ${learn}ls-a${reset}"; restore=$(expr $restore + 1) ;&
33) echo -n 33 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "ls-a" justumen "Non"; restore=$(expr $restore + 1) ;&
34) echo -n 34 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Ici ${learn}ls-a${reset} provoque tout simplement le lancement d'une commande inconnue sans option."; restore=$(expr $restore + 1) ;&
35) echo -n 35 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Parfois cet espace n'est pas nécessaire, comme avec les symboles spéciaux : ${code}>${reset}, ${code}&${reset}, ${code}|${reset}, etc..."; restore=$(expr $restore + 1) ;&
36) echo -n 36 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Un symbole spécial ne sera pas considéré comme appartenant au nom de la commande ou du fichier, sauf s'il est précédé du caractère d'échappement."; restore=$(expr $restore + 1) ;&
37) echo -n 37 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Mais la commande ${learn}pwd>file${reset} peut tout aussi bien s'écrire ${learn}pwd > file${reset} ou encore ${learn}pwd  >  file${reset} ou encore ${learn}pwd>   file${reset}, etc.."; restore=$(expr $restore + 1) ;&
38) echo -n 38 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Ceci étant dit, revenons sur notre problème avec ${learn}pwd1>file${reset}."; restore=$(expr $restore + 1) ;&
39) echo -n 39 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Le chiffre '1' n'étant pas un caractère spécial, votre terminal considère que la commande complète est ${learn}pwd1${reset}."; restore=$(expr $restore + 1) ;&
40) echo -n 40 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Il faudra donc ici séparer ${code}1>${reset} de ${code}pwd${reset} par un espace."; restore=$(expr $restore + 1) ;&
41) echo -n 41 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Faites donc un ${learn}pwd 1>file${reset}"; restore=$(expr $restore + 1) ;&
42) echo -n 42 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "pwd 1>file" justumen "Non"; restore=$(expr $restore + 1) ;&
43) echo -n 43 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Affichez le contenu du fichier 'file'."; restore=$(expr $restore + 1) ;&
44) echo -n 44 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "cat file" justumen "Non"; restore=$(expr $restore + 1) ;&
45) echo -n 45 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "${learn}pwd 1>file${reset} est donc bien équivalent à ${learn}pwd>file${reset}."; restore=$(expr $restore + 1) ;&
46) echo -n 46 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; stderr_2; restore=$(expr $restore + 1) ;&
47) echo -n 47 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Pour rediriger la ${voc}sortie erreur standard${reset}, il faudra tout simplement utiliser ${code}2>${reset}."; restore=$(expr $restore + 1) ;&
48) echo -n 48 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Faites donc un ${learn}pwd 2>error${reset}"; restore=$(expr $restore + 1) ;&
49) echo -n 49 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "pwd 2>error" justumen "Non"; restore=$(expr $restore + 1) ;&
50) echo -n 50 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Ici le résultat de la commande s'affiche dans le terminal."; restore=$(expr $restore + 1) ;&
51) echo -n 51 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Normal puisque qu'avec cette commande nous n'avons pas de redirection de la sortie standard."; restore=$(expr $restore + 1) ;&
52) echo -n 52 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Affichez maintenant le contenu du fichier 'error'."; restore=$(expr $restore + 1) ;&
53) echo -n 53 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "cat error" justumen "Non"; restore=$(expr $restore + 1) ;&
54) echo -n 54 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Le fichier est vide car aucun message n'a été envoyé sur le flux ${voc}d'erreur standard${reset}."; restore=$(expr $restore + 1) ;&
55) echo -n 55 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Mais vous pouvez noter que le fichier a bien été créé."; restore=$(expr $restore + 1) ;&
56) echo -n 56 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Maintenant faites donc la même commande avec une faute de frappe : ${learn}pwdd 2>error${reset}"; restore=$(expr $restore + 1) ;&
57) echo -n 57 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "pwdd 2>error" justumen "Non"; restore=$(expr $restore + 1) ;&
58) echo -n 58 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Ici rien ne s'affiche dans le terminal."; restore=$(expr $restore + 1) ;&
59) echo -n 59 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Normal encore une fois, puisque rien n'a été envoyé sur la ${voc}sortie standard${reset}."; restore=$(expr $restore + 1) ;&
60) echo -n 60 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Affichez par contre le contenu du fichier 'error'."; restore=$(expr $restore + 1) ;&
61) echo -n 61 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "cat error" justumen "Non"; restore=$(expr $restore + 1) ;&
62) echo -n 62 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Ici l'erreur a bien été enregistrée dans le fichier."; restore=$(expr $restore + 1) ;&
63) echo -n 63 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Essayez de rediriger séparement les résultats et les erreurs d'une commande dans deux fichiers différents avec : ${learn}pwd 1>out 2>err${reset}"; restore=$(expr $restore + 1) ;&
64) echo -n 64 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "pwd 1>out 2>err" justumen "Non"; restore=$(expr $restore + 1) ;&
65) echo -n 65 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Affichez le contenu du fichier 'err'."; restore=$(expr $restore + 1) ;&
66) echo -n 66 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "cat err" justumen "Non"; restore=$(expr $restore + 1) ;&
67) echo -n 67 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "La commande ne provoquant pas d'erreur, 'err' est vide."; restore=$(expr $restore + 1) ;&
68) echo -n 68 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Pour vérifier si ${code}1>${reset} et ${code}2>${reset} peuvent fonctionner en même temps, il va falloir utiliser un code qui utilise les deux flux."; restore=$(expr $restore + 1) ;&
69) echo -n 69 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Prenons par exemple : ${learn}pwdd||pwd${reset}."; restore=$(expr $restore + 1) ;&
70) echo -n 70 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "${code}pwdd${reset} renverra un message d'erreur. Il utilisera donc la sortie erreur standard. (stderr)"; restore=$(expr $restore + 1) ;&
71) echo -n 71 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "${code}pwdd${reset} renvoyant une erreur, la commande ${code}pwd${reset} se lancera et enverra son résultat vers la sortie standard. (stdout)"; restore=$(expr $restore + 1) ;&
72) echo -n 72 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "${code}1>${reset} est équivalent à ${code}>${reset}, et l'équivalent de ${code}>>${reset} est tout simplement ${code}1>>${reset}."; restore=$(expr $restore + 1) ;&
73) echo -n 73 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Essayez donc de faire : ${learn}pwdd||pwd 1>>f 2>>e${reset}"; restore=$(expr $restore + 1) ;&
74) echo -n 74 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "pwdd||pwd 1>>f 2>>e" justumen "Non"; restore=$(expr $restore + 1) ;&
75) echo -n 75 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Ici une erreur s'affiche dans le terminal, ${code}2>>${reset} semble donc ne pas fonctionner..."; restore=$(expr $restore + 1) ;&
76) echo -n 76 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "En fait, les redirections s'utilisent avec une commande. Ici ${code}pwdd||pwd${reset} n'est pas une commande !"; restore=$(expr $restore + 1) ;&
77) echo -n 77 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; stdout_stderr_1; restore=$(expr $restore + 1) ;&
78) echo -n 78 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Il s'agit en fait de ${voc}deux${reset} commandes différentes : ${code}pwdd${reset} et ${code}pwd${reset}."; restore=$(expr $restore + 1) ;&
79) echo -n 79 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "C'est à dire que ${learn}pwdd||pwd 1>>f 2>>e${reset} est aussi composé de ${voc}deux${reset} commandes."; restore=$(expr $restore + 1) ;&
80) echo -n 80 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "La première : ${code}pwdd${reset} et la deuxième : ${code}pwd 1>>f 2>>e${reset}."; restore=$(expr $restore + 1) ;&
81) echo -n 81 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Dans ce cas, ${code}2>>e${reset} ne redirigera que les erreurs de la commmande ${code}pwd${reset}."; restore=$(expr $restore + 1) ;&
82) echo -n 82 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Il est donc normal que l'erreur de ${code}pwdd${reset} s'affiche dans le terminal."; restore=$(expr $restore + 1) ;&
83) echo -n 83 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Pour rediriger les résultats et les erreurs des deux commandes, faites donc : ${learn}pwdd 1>>f 2>>e||pwd 1>>f 2>>e${reset}"; restore=$(expr $restore + 1) ;&
84) echo -n 84 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "pwdd 1>>f 2>>e||pwd 1>>f 2>>e" justumen "Non"; restore=$(expr $restore + 1) ;&
85) echo -n 85 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Vous pouvez aussi plus simplement regrouper les deux commandes pour qu'elles ne fassent ${voc}qu'une${reset}, en utilisant les ${code}()${reset}."; restore=$(expr $restore + 1) ;&
86) echo -n 86 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; stdout_stderr_2; restore=$(expr $restore + 1) ;&
87) echo -n 87 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Par exemple, pour ${code}(ls&&lss)2>e${reset}, la redirection ${code}2>e${reset} sera faite sur ${code}ls&&lss${reset}, et non pas uniquement sur ${code}lss${reset}."; restore=$(expr $restore + 1) ;&
88) echo -n 88 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "L'espace ici entre ${code})${reset} et ${code}2>e${reset} n'est pas nécessaire car ${code})${reset} est un caractère spécial, elle sépare donc sans ambiguïté la redirection."; restore=$(expr $restore + 1) ;&
89) echo -n 89 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Faites donc : ${learn}(pwdd||pwd)1>>f 2>>e${reset}, l'équivalent de la commande précédente : ${learn}pwdd 1>>f 2>>e||pwd 1>>f 2>>e${reset}."; restore=$(expr $restore + 1) ;&
90) echo -n 90 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "(pwdd||pwd)1>>f 2>>e" justumen "Non"; restore=$(expr $restore + 1) ;&
91) echo -n 91 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Affichez le contenu du fichier 'e'."; restore=$(expr $restore + 1) ;&
92) echo -n 92 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "cat e" justumen "Non"; restore=$(expr $restore + 1) ;&
93) echo -n 93 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Ici la deuxième erreur a bien été ajoutée à la suite de l'erreur de la commande précédente."; restore=$(expr $restore + 1) ;&
94) echo -n 94 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Pour mieux comprendre ces ${code}()${reset}, reprenons un exemple que l'on a déjà vu, faites donc : ${learn}cat FICHIER&&echo GOOD||echo ERROR${reset}"; restore=$(expr $restore + 1) ;&
95) echo -n 95 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "cat FICHIER&&echo GOOD||echo ERROR" justumen "Non"; restore=$(expr $restore + 1) ;&
96) echo -n 96 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Ici, si FICHIER n'existe pas dans DOSSIER, ${code}cat FICHIER${reset} renverra une erreur, ce qui provoquera le lancement de ${code}echo ERROR${reset}."; restore=$(expr $restore + 1) ;&
97) echo -n 97 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Maintenant faites un simple : ${learn}echo GOOD||echo ERROR${reset}"; restore=$(expr $restore + 1) ;&
98) echo -n 98 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "echo GOOD||echo ERROR" justumen "Non"; restore=$(expr $restore + 1) ;&
99) echo -n 99 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Evidemment ici ERROR ne s'affiche pas. Pourtant le code est le même que dans la commande précédente : ${learn}cat FICHIER&&echo GOOD||echo ERROR${reset}."; restore=$(expr $restore + 1) ;&
100) echo -n 100 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Mais dans ${learn}cat FICHIER&&echo GOOD||echo ERROR${reset}, ${code}echo ERROR${reset} se lancera car ${code}||${reset} ne se combine pas avec ${code}echo GOOD${reset} comme dans ${learn}echo GOOD||echo ERROR${reset}, mais avec ${code}cat FICHIER&&echo GOOD${reset}."; restore=$(expr $restore + 1) ;&
101) echo -n 101 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Sans les ${code}()${reset}, les conditions se lisent simplement de gauche à droite."; restore=$(expr $restore + 1) ;&
102) echo -n 102 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "${learn}cat FICHIER&&echo GOOD||echo ERROR${reset} a en fait un ordre logique équivalent à ${learn}(cat FICHIER&&echo GOOD)||echo ERROR${reset}"; restore=$(expr $restore + 1) ;&
103) echo -n 103 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Comme ${code}cat FICHIER&&echo GOOD${reset} renvoit une erreur, ${code}echo ERROR${reset} se lancera."; restore=$(expr $restore + 1) ;&
104) echo -n 104 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Vous pouvez donc changer aussi le sens de lecture de vos conditions avec les ${code}()${reset}."; restore=$(expr $restore + 1) ;&
105) echo -n 105 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen ""; restore=$(expr $restore + 1) ;&
106) echo -n 106 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen ""; restore=$(expr $restore + 1) ;&
107) echo -n 107 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Par exemple, prenons le code suivant : ${learn}cd DOSSIER&&(cat FICHIER||echo \"FICHIER n'existe pas dans DOSSIER\")||echo \"DOSSIER n'existe pas\"${reset}"; restore=$(expr $restore + 1) ;&
108) echo -n 108 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Les ${code}()${reset} permettent de lier la commande ${code}echo \"FICHIER n'existe pas dans DOSSIER\"${reset} avec la commande ${code}cat FICHIER${reset}."; restore=$(expr $restore + 1) ;&
109) echo -n 109 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Sans les ${code}()${reset}, ${code}echo \"FICHIER n'existe pas dans DOSSIER\"${reset} se lancera si la commande ${code}cd DOSSIER${reset} renvoit une erreur, ce qui n'est pas ce que l'on veut."; restore=$(expr $restore + 1) ;&
110) echo -n 110 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Vous pouvez donc utiliser ces ${code}()${reset} pour regrouper votre code."; restore=$(expr $restore + 1) ;&
111) echo -n 111 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Que votre but soit de changer la logique d'exécution de vos commandes, ou comme avant pour regrouper les flux de sortie."; restore=$(expr $restore + 1) ;&
112) echo -n 112 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Pour rediriger la sortie standard, vous devez utiliser ${code}>${reset} ou ${code}1>${reset}."; restore=$(expr $restore + 1) ;&
113) echo -n 113 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Pour rediriger la sortie d'erreur, vous devez utiliser ${code}2>${reset}."; restore=$(expr $restore + 1) ;&
114) echo -n 114 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Si vous voulez rediriger les deux à la fois, vous pouvez utiliser : ${code}&>${reset}."; restore=$(expr $restore + 1) ;&
115) echo -n 115 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Ou évidemment ${code}&>>${reset} si vous voulez ajouter le contenu à la fin d'un fichier."; restore=$(expr $restore + 1) ;&
116) echo -n 116 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Faites donc : ${learn}pwd&>>f${reset}"; restore=$(expr $restore + 1) ;&
117) echo -n 117 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "pwd&>>f" justumen "Non"; restore=$(expr $restore + 1) ;&
118) echo -n 118 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "${code}&>>${reset} commence par un caractère spécial, l'espace à sa gauche n'est donc pas nécessaire, contrairement à ${code}1>${reset} ou ${code}2>${reset} que l'on vu précédemment."; restore=$(expr $restore + 1) ;&
119) echo -n 119 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Faites donc la même commande avec une faute de frappe : ${learn}pwdd&>>f${reset}"; restore=$(expr $restore + 1) ;&
120) echo -n 120 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "pwdd&>>f" justumen "Non"; restore=$(expr $restore + 1) ;&
121) echo -n 121 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Avec cette commande, rien ne s'affiche dans le terminal, les deux redirections se passent donc correctement."; restore=$(expr $restore + 1) ;&
122) echo -n 122 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "${code}&>>${reset} est donc bien équivalent à la combinaison de ${code}1>>${reset} et de ${code}2>>${reset}."; restore=$(expr $restore + 1) ;&
123) echo -n 123 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Mais parfois il est possible qu'un flux ne vous intéresse pas du tout."; restore=$(expr $restore + 1) ;&
124) echo -n 124 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Pour ce genre de cas il existe un fichier spécial, ${code}/dev/null${reset}, que vous pouvez utiliser avec vos redirections."; restore=$(expr $restore + 1) ;&
125) echo -n 125 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "${code}/dev/null${reset} est un fichier vide qui restera toujours vide."; restore=$(expr $restore + 1) ;&
126) echo -n 126 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Affichez donc le contenu du fichier inexistant 'X', en vous débarassant des messages d'erreur."; restore=$(expr $restore + 1) ;&
127) echo -n 127 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "cat X 2>/dev/null" justumen "Non"; restore=$(expr $restore + 1) ;&
128) echo -n 128 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Affichez donc le contenu du fichier ${code}/dev/null${reset}"; restore=$(expr $restore + 1) ;&
129) echo -n 129 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "cat /dev/null" justumen "Non"; restore=$(expr $restore + 1) ;&
130) echo -n 130 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Effectivement, malgré cette redirection, ${code}/dev/null${reset} est toujours vide."; restore=$(expr $restore + 1) ;&
131) echo -n 131 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Si vous voulez vous débarasser des deux flux, il suffit d'utiliser ${code}&>/dev/null${reset}."; restore=$(expr $restore + 1) ;&
132) echo -n 132 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Vous pouvez également, si vous le souhaitez, rediriger un flux vers un autre flux."; restore=$(expr $restore + 1) ;&
133) echo -n 133 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "${code}2>&1${reset} redirigera la sortie erreur standard vers la sortie standard, et ${code}1>&2${reset} redirigera la sortie standard vers la sortie erreur standard."; restore=$(expr $restore + 1) ;&
134) echo -n 134 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Ajoutez à la fin du fichier '/tmp/pwd.log' la sortie standard de la commande ${code}pwd${reset}, puis regroupez sa sortie erreur standard avec sa sortie standard."; restore=$(expr $restore + 1) ;&
135) echo -n 135 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "pwd>>/tmp/pwd.log 2>&1" justumen "Non"; restore=$(expr $restore + 1) ;&
136) echo -n 136 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Affichez donc le contenu du fichier '/tmp/pwd.log'."; restore=$(expr $restore + 1) ;&
137) echo -n 137 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "cat /tmp/pwd.log" justumen "Non"; restore=$(expr $restore + 1) ;&
138) echo -n 138 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Maintenant, faites avec une faute de frappe : ${learn}pwdd>>/tmp/pwd.log 2>&1${reset}"; restore=$(expr $restore + 1) ;&
139) echo -n 139 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "pwdd>>/tmp/pwd.log 2>&1" justumen "Non"; restore=$(expr $restore + 1) ;&
140) echo -n 140 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Puis réaffichez le contenu de '/tmp/pwd.log'."; restore=$(expr $restore + 1) ;&
141) echo -n 141 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "cat /tmp/pwd.log" justumen "Non"; restore=$(expr $restore + 1) ;&
142) echo -n 142 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "L'erreur a été ici ajoutée à la suite, ${code}2>&1${reset} est donc clairement dépendant du ${code}>>${reset} de la sortie standard."; restore=$(expr $restore + 1) ;&
143) echo -n 143 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Attention donc à cette syntaxe, ${code}2>&1${reset} veut dire que : \"La sortie d'erreur standard utilisera la même redirection que la sortie standard\"."; restore=$(expr $restore + 1) ;&
144) echo -n 144 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "${code}2>&1${reset} s'adaptera donc si la redirection de la sortie standard est ${code}>${reset} ou ${code}>>${reset}."; restore=$(expr $restore + 1) ;&
145) echo -n 145 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Pour ajouter à la fin d'un fichier, ${codeError}2>>&1${reset} pourrait venir à l'esprit mais ce n'est pas une syntaxe valide."; restore=$(expr $restore + 1) ;&
146) echo -n 146 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Résumons donc : pour combiner les flux de même type de plusieurs commandes, nous devons donc utiliser les ${code}()${reset}."; restore=$(expr $restore + 1) ;&
147) echo -n 147 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Faites donc ${learn}(pwdd;pwd)${reset}"; restore=$(expr $restore + 1) ;&
148) echo -n 148 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "(pwdd;pwd)" justumen "Non"; restore=$(expr $restore + 1) ;&
149) echo -n 149 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; stdout_stderr_3; restore=$(expr $restore + 1) ;&
150) echo -n 150 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Ici les deux sorties standards se regroupent en une seule sortie standard, celle de la commande ${code}pwdd${reset} était vide."; restore=$(expr $restore + 1) ;&
151) echo -n 151 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Les deux sorties erreurs standards se regroupent également en une seule sortie d'erreur standard, celle de la commande ${code}pwd${reset} était vide."; restore=$(expr $restore + 1) ;&
152) echo -n 152 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Nous avons donc maintenant notre code, qui utilise à la fois stdout et stderr : ${learn}(pwdd;pwd)${reset}."; restore=$(expr $restore + 1) ;&
153) echo -n 153 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Mais il reste encore deux flux ${voc}distincts${reset} pour ce groupe de commande : sa sortie standard et sa sortie erreur standard."; restore=$(expr $restore + 1) ;&
154) echo -n 154 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; stdout_stderr_4; restore=$(expr $restore + 1) ;&
155) echo -n 155 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Ce schéma représente ${code}(pwdd;pwd)${reset} : stdout et stderr sont indépendants, vous pouvez donc les rediriger normalement."; restore=$(expr $restore + 1) ;&
156) echo -n 156 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Par exemple ${code}(pwdd;pwd)>>resultats 2>>erreurs${reset}, stdout sera envoyé vers le fichier 'resultat', et stderr vers le fichier 'erreurs'."; restore=$(expr $restore + 1) ;&
157) echo -n 157 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; stdout_stderr_2in1; restore=$(expr $restore + 1) ;&
158) echo -n 158 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Ce schéma représente ${code}(pwdd;pwd)2>&1${reset}, ici la sortie erreur sera combinée avec la sortie standard."; restore=$(expr $restore + 1) ;&
159) echo -n 159 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Cependant, si vous voulez rediriger le contenu dans un fichier, il faudra le faire ${voc}avant${reset} de rediriger stderr avec ${code}2>&1${reset} car les redirections se lisent de gauche à droite."; restore=$(expr $restore + 1) ;&
160) echo -n 160 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Par exemple, ${code}(pwdd;pwd)>tmp 2>&1${reset} n'as pas le même sens que ${code}(pwdd;pwd)2>&1 >tmp${reset}."; restore=$(expr $restore + 1) ;&
161) echo -n 161 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "La première redirigera stdout et stderr vers le fichier 'tmp', alors que la deuxième ne redirigera que stdout vers le fichier 'tmp'."; restore=$(expr $restore + 1) ;&
162) echo -n 162 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Prenons par exemple la commande idiote mais correcte avec deux redirections de la sortie standard ${code}(pwdd;pwd)>/dev/null 2>&1 1>f${reset}."; restore=$(expr $restore + 1) ;&
163) echo -n 163 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Les redirections se lisant de gauche à droite, stdout finira dans le fichier 'f' alors que stderr restera dans '/dev/null'."; restore=$(expr $restore + 1) ;&
164) echo -n 164 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; stdout_stderr_1in2; restore=$(expr $restore + 1) ;&
165) echo -n 165 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Ce schéma représente ${code}(pwdd;pwd)1>&2${reset}, ici la sortie standard sera combinée avec la sortie erreur standard."; restore=$(expr $restore + 1) ;&
166) echo -n 166 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; (pwdd;pwd)2>>test 1>&2; restore=$(expr $restore + 1) ;&
167) echo -n 167 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Pour se débarasser de ces deux flux, vous pourriez y ajouter ${code}&>/dev/null${reset}."; restore=$(expr $restore + 1) ;&
168) echo -n 168 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Faites le donc : ${learn}(pwdd;pwd)&>/dev/null${reset}"; restore=$(expr $restore + 1) ;&
169) echo -n 169 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "(pwdd;pwd)&>/dev/null" justumen "Non"; restore=$(expr $restore + 1) ;&
170) echo -n 170 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "${code}&>/dev/null${reset} serait donc équivalent à : ${code}>/dev/null 2>&1${reset}, ou ${code}1>/dev/null 2>&1${reset}, ou encore ${code}2>/dev/null 1>&2${reset}."; restore=$(expr $restore + 1) ;&
171) echo -n 171 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Maintenant rediriger les deux flux vers le fichier 'F' avec : ${learn}(pwdd;pwd)&>F${reset}"; restore=$(expr $restore + 1) ;&
172) echo -n 172 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "(pwdd;pwd)&>F" justumen "Non"; restore=$(expr $restore + 1) ;&
173) echo -n 173 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Puis affichez le contenu du fichier F."; restore=$(expr $restore + 1) ;&
174) echo -n 174 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "cat F" justumen "Non"; restore=$(expr $restore + 1) ;&
175) echo -n 175 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Vous pouvez notez ici que les deux flux ont été réunis avant l'écriture dans le fichier, c'est à dire que malgré l'utilisation de ${code}>${reset} au lieu de ${code}>>${reset}, la deuxième ligne n'a pas écrasée la première."; restore=$(expr $restore + 1) ;&
176) echo -n 176 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Faites donc à nouveau : ${learn}(pwdd;pwd)&>F${reset}"; restore=$(expr $restore + 1) ;&
177) echo -n 177 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "(pwdd;pwd)&>F" justumen "Non"; restore=$(expr $restore + 1) ;&
178) echo -n 178 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk_not_press_key justumen "Puis réaffichez le contenu du fichier F."; restore=$(expr $restore + 1) ;&
179) echo -n 179 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; answer_run "cat F" justumen "Non"; restore=$(expr $restore + 1) ;&
180) echo -n 180 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Ici vous avez à nouveau ces deux lignes, si vous aviez utilisé ${code}&>>${reset} à la place de ${code}&>${reset} vous auriez ici bien évidemment quatre lignes."; restore=$(expr $restore + 1) ;&
181) echo -n 181 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Pour terminer, la commande ${code}(pwdd;pwd)>>tmp 2>&1${reset} est équivalente à la commande : ${code}(pwdd;pwd)&>>tmp${reset}"; restore=$(expr $restore + 1) ;&
182) echo -n 182 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "J'espère que ces redirections sont maintenant claires pour vous et bonne chance pour le questionnaire."; restore=$(expr $restore + 1) ;&
183) echo -n 183 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; clean; restore=$(expr $restore + 1) ;&
esac
}
CLREOL=$'\x1B[K'

function stderr(){
echo -e "$basic
%%%%%%%%%%%%%%%%%${CLREOL}
%               % stdout${CLREOL}
%      lss      %========>${CLREOL}
%               %${CLREOL}
%%%%%%%%%%%%%%%%%${CLREOL}
        |${CLREOL}
        |================> ${codeError}bash: lss: command not found${reset}${basic}${CLREOL}
         stderr${CLREOL}$reset"
}


function stderr_2(){
echo -e "$basic
%%%%%%%%%%%%%%%%%${CLREOL}
%               % stdout${CLREOL}
%      lss      %========>${CLREOL}
%               %${CLREOL}
%%%%%%%%%%%%%%%%%${CLREOL}
        |${CLREOL}
        |================> ${codeError}bash: lss: command not found${reset}${basic}${CLREOL}
         stderr ( ${code}2>${reset}${basic} )${CLREOL}$reset"
}


function stdout(){
echo -e "$basic
%%%%%%%%%%%%%%%%%${CLREOL}
%               % stdout${CLREOL}
%      pwd      %========> ${codeFile}$HOME/.GameScript_bash7${reset}${basic}${CLREOL}
%               %${CLREOL}
%%%%%%%%%%%%%%%%%${CLREOL}
        |${CLREOL}
        |================>${CLREOL}
         stderr${CLREOL}$reset"
}

function stdout_2(){
echo -e "$basic
%%%%%%%%%%%%%%%%%${CLREOL}
%               % stdout ( ${code}1>${reset}${basic} / ${code}>${reset}${basic} )${CLREOL}
%      pwd      %========> ${codeFile}$HOME/.GameScript_bash7${reset}${basic}${CLREOL}
%               %${CLREOL}
%%%%%%%%%%%%%%%%%${CLREOL}
        |${CLREOL}
        |================>${CLREOL}
         stderr${CLREOL}$reset"
}


function stdout_stderr_1(){
echo -e "$basic
%%%%%%%%%%%%%%%%%${CLREOL}
%               % stdout ( ${code}1>${reset}${basic} )${CLREOL}
%     pwdd      %========>${CLREOL}
%               %${CLREOL}
%%%%%%%%%%%%%%%%%${CLREOL}
        |${CLREOL}
        |================> ${codeError}bash: pwdd: command not found${reset}${basic}${CLREOL}
         stderr ( ${code}2>${reset}${basic} )${CLREOL}
${CLREOL}
%%%%%%%%%%%%%%%%%${CLREOL}
%               % stdout ( ${code}1>${reset}${basic} )${CLREOL}
%      pwd      %========> ${codeFile}$HOME/.GameScript_bash7${reset}${basic}${CLREOL}
%               %${CLREOL}
%%%%%%%%%%%%%%%%%${CLREOL}
        |${CLREOL}
        |================>${CLREOL}
         stderr ( ${code}2>${reset}${basic} )${CLREOL}$reset"
}

function stdout_stderr_2(){
echo -e "$basic
%%%%%%%%%%%%%%%%%${CLREOL}
%               % stdout ( ${code}1>${reset}${basic} )${CLREOL}
%   (ls&&lss)   %========> ${codeFile}e  error  f  file  err  out${reset}${basic}${CLREOL}
%               %${CLREOL}
%%%%%%%%%%%%%%%%%${CLREOL}
        |${CLREOL}
        |================> ${codeError}bash: lss: command not found${reset}${basic}${CLREOL}
         stderr ( ${code}2>${reset}${basic} )${CLREOL}$reset"
}

function stdout_stderr_3(){
echo -e "$basic
%%%%%%%%%%%%%%%%%${CLREOL}
%               % stdout   ${codeFile} ${reset}${basic} ( pwdd )${CLREOL}
%  (pwdd;pwd)   %========> ${codeFile}$HOME/.GameScript_bash7${reset}${basic} ( pwd )${CLREOL}
%               %${CLREOL}
%%%%%%%%%%%%%%%%%${CLREOL}
        |                  ${codeError}bash: pwdd: command not found${reset}${basic} ( pwdd )${CLREOL}
        |================> ${codeError} ${reset}${basic} ( pwd )${CLREOL}
         stderr${CLREOL}$reset"
}

function stdout_stderr_4(){
echo -e "$basic
%%%%%%%%%%%%%%%%%${CLREOL}
%               % stdout${CLREOL}
%  (pwdd;pwd)   %========> ${codeFile}$HOME/.GameScript_bash7${reset}${basic}${CLREOL}
%               %${CLREOL}
%%%%%%%%%%%%%%%%%${CLREOL}
        |${CLREOL}
        |================> ${codeError}bash: pwdd: command not found${reset}${basic}${CLREOL}
         stderr${CLREOL}$reset"
}

function stdout_stderr_2in1(){
echo -e "$basic
%%%%%%%%%%%%%%%%%${CLREOL}
%               % stdout + stderr${CLREOL}
%  (pwdd;pwd)   %========> ${codeFile}$HOME/.GameScript_bash7${reset}${basic}${CLREOL}
%               %   |      ${codeError}bash: pwdd: command not found${reset}${basic}${CLREOL}
%%%%%%%%%%%%%%%%%   |${CLREOL}
        |           | ( ${code}2>&1${reset}${basic} )${CLREOL}
        |===========|${CLREOL}
         stderr${CLREOL}$reset"
}

function stdout_stderr_1in2(){
echo -e "$basic
%%%%%%%%%%%%%%%%%${CLREOL}
%               %${CLREOL}
%  (pwdd;pwd)   %===|${CLREOL}
%               %   | ( ${code}1>&2${reset}${basic} )${CLREOL}
%%%%%%%%%%%%%%%%%   |${CLREOL}
        |           |      ${codeFile}$HOME/.GameScript_bash7${reset}${basic}${CLREOL}
        |================> ${codeError}bash: pwdd: command not found${reset}${basic}${CLREOL}
         stderr + stdout${CLREOL}$reset"
}



function clean(){ #in enter_chapter
rm $HOME/.GameScript/restore_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
rm $HOME/.GameScript/restore_pwd_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
	rm $HOME/.GameScript_bash7/file 2> /dev/null
	rm $HOME/.GameScript_bash7/error 2> /dev/null
	rm $HOME/.GameScript_bash7/e 2> /dev/null
	rm $HOME/.GameScript_bash7/f 2> /dev/null
	rm $HOME/.GameScript_bash7/out 2> /dev/null
	rm $HOME/.GameScript_bash7/err 2> /dev/null
	rm $HOME/.GameScript_bash7/F 2> /dev/null
	rm /tmp/pwd.log 2> /dev/null
	rmdir $HOME/.GameScript_bash7 2> /dev/null
}

function start_quiz(){
  echo ""
  echo -e "\e[15;44m Bash 'Bourne Again SHell' : Questionnaire du chapitre 7 \e[0m"
  echo -e "- La réponse doit être la plus courte possible, une commande valide mais ajoutant des caractères inutiles ne fonctionnera pas."
  echo -e "Exemple : si la réponse est 'ls'. Les réponses 'ls .', 'ls ./' et 'ls ././' seront considérées comme fausses."
  answer_text_fr "Comment afficher le contenu du fichier 'cat' en se débarassant de tous les messages d'erreur potentiels ?" "cat cat 2>/dev/null"
  answer_text_fr "Comment executer deux commandes : 'mkdir A' et 'touch B' et regrouper leurs flux de même type ? (erreur et sortie standard)" "(mkdir A;touch B)"
  answer_text_fr "La commande 'pwdd&>/dev/null' est équivalente à la commande 'pwdd 2>&1 >/dev/null'. (vrai/faux)" "faux"
  answer_text_fr "Le fichier ERROR étant créé par la commande 'cat x 2>ERROR', comment afficher son contenu sur la sortie standard ?" "cat ERROR"
  answer_text_fr "Comment afficher le contenu du fichier 'LOG' sur la sortie erreur standard ?" "cat LOG 1>&2"
  answer_text_fr "Comment rediriger la sortie standard et la sortie erreur standard de la commande 'mkdir TEST' dans le fichier /var/mkdir" "mkdir TEST&>/var/mkdir"
  answer_text_fr "Sans utiliser '&>>', comment ajouter à la fin du fichier '/tmp/pwd.log' la sortie standard de la commande 'pwd', puis regroupez sa sortie erreur standard avec sa sortie standard ?" "pwd>>/tmp/pwd.log 2>&1"
  unlock "bash" "7" "1109" "ff12"
}


CHAPTER_NAME="bash"
CHAPTER_NUMBER="7"
LANGUAGE="fr"
SPEAKER="m1"

LINES=180
if [ "$1" == "VIDEO" ]; then
	prepare_video
else
	if [ ! "$1" == "MUTE" ]; then
		prepare_audio
	fi
fi


enter_chapter $CHAPTER_NAME $CHAPTER_NUMBER
