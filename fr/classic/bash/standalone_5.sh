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
	VOICE_PID=$(ps -|grep $SOUNDPLAYER|grep -v grep|grep -v MUSIC|awk '{print $2}')
	echo "VOICE_PID = $VOICE_PID"
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
1) echo -n 1 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; [ -d "$HOME/.GameScript_bash5" ] && echo "Erreur inattendue, ${HOME}/.GameScript_bash5 existe déjà sur votre système ! Supprimez ce dossier $HOME/.GameScript_bash5 et relancez ce script." && exit; restore=$(expr $restore + 1) ;&
2) echo -n 2 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; mkdir $HOME/.GameScript_bash5 2> /dev/null; restore=$(expr $restore + 1) ;&
3) echo -n 3 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; cd $HOME/.GameScript_bash5; restore=$(expr $restore + 1) ;&
4) echo -n 4 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; mkdir Dossier;touch Dossier/X;touch Dossier/Y;chmod 644 Dossier; restore=$(expr $restore + 1) ;&
5) echo -n 5 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; echo "a">f1;chmod 000 f1;echo "ab">f2;chmod 444 f2;echo "abc">f3;chmod 600 f3;echo "abcd">f4;chmod 777 f4; restore=$(expr $restore + 1) ;&
6) echo -n 6 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Dans ce chapitre nous revenons sur la commande ${code}ls${reset}, l'une des commandes les plus importantes."; restore=$(expr $restore + 1) ;&
7) echo -n 7 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Et ici nous allons parler de son option la plus importante : ${code}-l${reset}"; restore=$(expr $restore + 1) ;&
8) echo -n 8 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk_not_press_key justumen "Vous pouvez taper : ${learn}ls -l${reset}"; restore=$(expr $restore + 1) ;&
9) echo -n 9 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; answer_run "ls -l" justumen "Non"; restore=$(expr $restore + 1) ;&
10) echo -n 10 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Avec cette option, ${code}ls${reset} nous donne plus d'informations sur les éléments du répertoire courant."; restore=$(expr $restore + 1) ;&
11) echo -n 11 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Vous avez au début une chaine de caractères étrange composé de ${code}-${reset} et de lettres à gauche du premier espace de chaque ligne."; restore=$(expr $restore + 1) ;&
12) echo -n 12 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Le premier caractère représente le type de l'élément."; restore=$(expr $restore + 1) ;&
13) echo -n 13 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Si c'est un ${code}-${reset}, cet élément est un fichier, si c'est un ${code}d${reset}, il s'agit d'un dossier."; restore=$(expr $restore + 1) ;&
14) echo -n 14 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Avec ce premier caractère, on voit clairement que 'Dossier' est un dossier et que les autres sont des fichiers."; restore=$(expr $restore + 1) ;&
15) echo -n 15 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Les neufs autres caractères qui suivent représentent les ${voc}permissions${reset} de l'élément en question."; restore=$(expr $restore + 1) ;&
16) echo -n 16 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Il est possible d'avoir plusieurs utilisateurs sur un même ordinateur."; restore=$(expr $restore + 1) ;&
17) echo -n 17 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Mais certains de vos fichiers méritent peut-être d'être protégés."; restore=$(expr $restore + 1) ;&
18) echo -n 18 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Par exemple, il semblerai raisonnable que votre petite soeur ne puisse pas supprimer vos fichier personnels."; restore=$(expr $restore + 1) ;&
19) echo -n 19 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "En revanche, même si vous ne voulez pas qu'elle puisse supprimer vos fichiers, vous avez peut-être besoin de lui donner la permission de les lire."; restore=$(expr $restore + 1) ;&
20) echo -n 20 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Ces neufs caractères sont utilisés pour définir avec précision les permissions que vous désirez."; restore=$(expr $restore + 1) ;&
21) echo -n 21 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "La permission 'minimale' est ${code}---------${reset} et la permission 'maximale' est ${code}rwxrwxrwx${reset}."; restore=$(expr $restore + 1) ;&
22) echo -n 22 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Chaque ${code}-${reset} veut dire que qu'un certain type de permission est ${voc}désactivé${reset}."; restore=$(expr $restore + 1) ;&
23) echo -n 23 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "A l'inverse, lorsque vous voyez une lettre, c'est qu'un certain type de permission est ${voc}activé${reset}."; restore=$(expr $restore + 1) ;&
24) echo -n 24 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Mais chaque caractère doit respecter cet ordre : ${code}rwxrwxrwx${reset}."; restore=$(expr $restore + 1) ;&
25) echo -n 25 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "C'est à dire qu'ils n'auront pour simplifier que deux états possibles."; restore=$(expr $restore + 1) ;&
26) echo -n 26 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Le premier caractère pourra être soit un ${code}-${reset} soit un ${code}r${reset}."; restore=$(expr $restore + 1) ;&
27) echo -n 27 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Ce ${code}r${reset} vient de l'anglais ${code}r${reset}ead et donne le droit de lecture."; restore=$(expr $restore + 1) ;&
28) echo -n 28 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Le second caractère pourra être soit un ${code}-${reset} soit un ${code}w${reset}."; restore=$(expr $restore + 1) ;&
29) echo -n 29 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Ce ${code}w${reset} vient de l'anglais ${code}W${reset}rite et donne le droit d'écriture : la modification ou la suppression."; restore=$(expr $restore + 1) ;&
30) echo -n 30 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Le troisième caractère pourra être soit un ${code}-${reset} soit un ${code}x${reset}."; restore=$(expr $restore + 1) ;&
31) echo -n 31 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Ce ${code}x${reset} vient de l'anglais e${code}X${reset}ecute et donne le droit d'exécution."; restore=$(expr $restore + 1) ;&
32) echo -n 32 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Et ce schéma de trois caractères ${code}rwx${reset} se répète trois fois."; restore=$(expr $restore + 1) ;&
33) echo -n 33 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Les trois premiers caractères sont les permissions du ${voc}propriétaire${reset} du fichier."; restore=$(expr $restore + 1) ;&
34) echo -n 34 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Exemple : -${codeFile}rw-${reset}r----- 2 ${codeFile}albert${reset} familleEinstein 4096 Feb 19 00:51 Exemple"; restore=$(expr $restore + 1) ;&
35) echo -n 35 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Le nom du propriétaire du fichier 'Exemple' est ici 'albert'."; restore=$(expr $restore + 1) ;&
36) echo -n 36 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Les trois caractères en vert sont les permissions d'albert."; restore=$(expr $restore + 1) ;&
37) echo -n 37 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Exemple : -rw-${codeFile}r--${reset}--- 2 albert ${codeFile}familleEinstein${reset} 4096 Feb 19 00:51 Exemple"; restore=$(expr $restore + 1) ;&
38) echo -n 38 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Ici les trois caractères en vert sont les permissions des membres du ${voc}groupe${reset} 'familleEinstein'."; restore=$(expr $restore + 1) ;&
39) echo -n 39 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Ici on peut imaginer l'existence d'un groupe 'familleEinstein' pour la famille Einstein."; restore=$(expr $restore + 1) ;&
40) echo -n 40 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Exemple : -rw-r--${codeFile}---${reset} 2 albert familleEinstein 4096 Feb 19 00:51 Exemple"; restore=$(expr $restore + 1) ;&
41) echo -n 41 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Et enfin, les trois derniers caractères sont les permissions des autres utilisateurs."; restore=$(expr $restore + 1) ;&
42) echo -n 42 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Ceux qui ne sont ni albert, ni dans le groupe "familleEinstein"."; restore=$(expr $restore + 1) ;&
43) echo -n 43 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Dans cet exemple, albert, le propriétaire du fichier a le droit de lecture avec ce ${code}r${reset} et le droit d'écriture avec ce ${code}w${reset}, mais pas le droit d'exécution car le troisième caractère n'est pas un ${codeError}x${reset} mais un ${code}-${reset}."; restore=$(expr $restore + 1) ;&
44) echo -n 44 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Les membres du groupe 'familleEinstein' ont uniquement le droit de lecture sur ce fichier avec ce ${code}r${reset}."; restore=$(expr $restore + 1) ;&
45) echo -n 45 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Ils n'ont pas le droit de le modifier ou de le supprimer, car il n'y a pas de ${code}w${reset} !"; restore=$(expr $restore + 1) ;&
46) echo -n 46 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Le reste des utilisateurs n'ont aucune permission, car il n'y a pour eux aucune lettre : ${codeFile}---${reset}."; restore=$(expr $restore + 1) ;&
47) echo -n 47 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk_not_press_key justumen "Maintenant revenons à nos fichiers et relançons la commande ${learn}ls -l${reset}"; restore=$(expr $restore + 1) ;&
48) echo -n 48 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; answer_run "ls -l" justumen "Non"; restore=$(expr $restore + 1) ;&
49) echo -n 49 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Sur un système simple, il est probable que vous ayez un nom de groupe similaire à votre nom d'utilisateur, mais ça n'est pas un problème."; restore=$(expr $restore + 1) ;&
50) echo -n 50 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Il y a donc de nombreuses combinaisons de permission possibles, ici nous avons 'f1' avec les permissions minimales : ${code}---------${reset}."; restore=$(expr $restore + 1) ;&
51) echo -n 51 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Nous avons 'f4' avec les permissions maximales : ${code}rwxrwxrwx${reset}."; restore=$(expr $restore + 1) ;&
52) echo -n 52 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Et nous avons d'autres combinaisons de permissions pour les autres éléments."; restore=$(expr $restore + 1) ;&
53) echo -n 53 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk_not_press_key justumen "Commençez par afficher le contenu du fichier 'f1'."; restore=$(expr $restore + 1) ;&
54) echo -n 54 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; answer_run "cat f1" justumen "Non"; restore=$(expr $restore + 1) ;&
55) echo -n 55 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Et oui, il n'est pas possible d'afficher le contenu de ce fichier, car vous n'avez pas le droit de lecture."; restore=$(expr $restore + 1) ;&
56) echo -n 56 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Pour pouvoir utiliser la commande ${code}cat${reset}, il vous aurez fallu un ${code}r${reset} à la place de ce tiret rouge : -${codeError}-${reset}--------."; restore=$(expr $restore + 1) ;&
57) echo -n 57 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk_not_press_key justumen "Sur le fichier 'f2', vous avez ce 'r' dans : -${code}r${reset}--r--r-- qui vous donne le droit de lecture. Affichez le contenu de 'f2'."; restore=$(expr $restore + 1) ;&
58) echo -n 58 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; answer_run "cat f2" justumen "Non"; restore=$(expr $restore + 1) ;&
59) echo -n 59 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Ici pas de problème à l'affichage."; restore=$(expr $restore + 1) ;&
60) echo -n 60 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk_not_press_key justumen "Ajoutez le texte 'cd' à la fin du fichier 'f2'."; restore=$(expr $restore + 1) ;&
61) echo -n 61 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; answer_run "echo cd>>f2" justumen "Non"; restore=$(expr $restore + 1) ;&
62) echo -n 62 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Sur 'f2' nous avons encore un problème de permission."; restore=$(expr $restore + 1) ;&
63) echo -n 63 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Cette fois c'est un ${code}w${reset} qui nous manque à la place de ce tiret rouge : -r${codeError}-${reset}-r--r--."; restore=$(expr $restore + 1) ;&
64) echo -n 64 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Mais 'f3' semble avoir à la fois le ${code}r${reset} et le ${code}w${reset}."; restore=$(expr $restore + 1) ;&
65) echo -n 65 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk_not_press_key justumen "Affichez les permissions de 'f3' avec le nom du fichier en argument : ${learn}ls -l f3${reset}."; restore=$(expr $restore + 1) ;&
66) echo -n 66 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; answer_run "ls -l f3" justumen "Non"; restore=$(expr $restore + 1) ;&
67) echo -n 67 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk_not_press_key justumen "Affichez le contenu de 'f3'."; restore=$(expr $restore + 1) ;&
68) echo -n 68 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; answer_run "cat f3" justumen "Non"; restore=$(expr $restore + 1) ;&
69) echo -n 69 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk_not_press_key justumen "Ajoutez 'def' au fichier 'f3'."; restore=$(expr $restore + 1) ;&
70) echo -n 70 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; answer_run "echo def>>f3" justumen "Non"; restore=$(expr $restore + 1) ;&
71) echo -n 71 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk_not_press_key justumen "Affichez le contenu de 'f3' a nouveau."; restore=$(expr $restore + 1) ;&
72) echo -n 72 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; answer_run "cat f3" justumen "Non"; restore=$(expr $restore + 1) ;&
73) echo -n 73 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Parfait ! Nous pouvons enfin utiliser les commandes que nous avons apprises."; restore=$(expr $restore + 1) ;&
74) echo -n 74 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Mais nous n'avons jamais eu ce problème de permission dans les chapitres précédents..."; restore=$(expr $restore + 1) ;&
75) echo -n 75 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Je viens ici en fait de les simuler pour vous..."; restore=$(expr $restore + 1) ;&
76) echo -n 76 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Vous savez déjà créer un fichier texte avec ${code}echo${reset}."; restore=$(expr $restore + 1) ;&
77) echo -n 77 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk_not_press_key justumen "Mais vous pouvez aussi utiliser la commande ${code}touch${reset}, faites donc : ${learn}touch file${reset}"; restore=$(expr $restore + 1) ;&
78) echo -n 78 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; answer_run "touch file" justumen "Non"; restore=$(expr $restore + 1) ;&
79) echo -n 79 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Maintenant nous pouvons voir les permissions par défaut lors de la création d'un nouveau fichier."; restore=$(expr $restore + 1) ;&
80) echo -n 80 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk_not_press_key justumen "Pour avoir les permissions de 'file', faites ${learn}ls -l file${reset}"; restore=$(expr $restore + 1) ;&
81) echo -n 81 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; answer_run "ls -l file" justumen "Non"; restore=$(expr $restore + 1) ;&
82) echo -n 82 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Si le fichier a été créé par vous, vous aurez par défaut le droit de lecture et d'écriture."; restore=$(expr $restore + 1) ;&
83) echo -n 83 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Attention par contre si ce fichier ne vient pas de vous, il peut avoir des permissions limités ou inattendues."; restore=$(expr $restore + 1) ;&
84) echo -n 84 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Nous pouvons voir ici le nom du propriétaire du fichier, mais est-ce bien vous ?"; restore=$(expr $restore + 1) ;&
85) echo -n 85 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk_not_press_key justumen "Pour connaitre votre nom d'utilisateur, vous pouvez taper : ${learn}whoami${reset}"; restore=$(expr $restore + 1) ;&
86) echo -n 86 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; answer_run "whoami" justumen "Non"; restore=$(expr $restore + 1) ;&
87) echo -n 87 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "'Who am I ?' est l'anglais pour 'Qui suis-je ?'."; restore=$(expr $restore + 1) ;&
88) echo -n 88 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Ici votre nom correspond effectivement au nom du propriétaire de ce fichier."; restore=$(expr $restore + 1) ;&
89) echo -n 89 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Mais il existe sur votre machine au moins un autre utilisateur !"; restore=$(expr $restore + 1) ;&
90) echo -n 90 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Cet utilisateur possède les droits de vie ou de mort de tout ce qui existe dans votre système..."; restore=$(expr $restore + 1) ;&
91) echo -n 91 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Il s'agit de votre compte administrateur, plus connu sous le nom de ${voc}root${reset}."; restore=$(expr $restore + 1) ;&
92) echo -n 92 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Traditionnelement, vos fichiers personnels doivent être stockés dans : /home/votrenom"; restore=$(expr $restore + 1) ;&
93) echo -n 93 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Et vous devriez être maitre de tout ce qu'il se passe à l'intérieur."; restore=$(expr $restore + 1) ;&
94) echo -n 94 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Mais en tant que simple utilisateur, vous ne pouvez contrôler que les éléments de ce répertoire !"; restore=$(expr $restore + 1) ;&
95) echo -n 95 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk_not_press_key justumen "Essayez donc d'afficher les permissions d'un autre dossier, le répertoire racine par exemple : ${learn}ls -l /${reset}"; restore=$(expr $restore + 1) ;&
96) echo -n 96 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; answer_run "ls -l /" justumen "Non"; restore=$(expr $restore + 1) ;&
97) echo -n 97 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Ici nous voyons bien que le propriétaire de ces éléments est ${voc}root${reset}."; restore=$(expr $restore + 1) ;&
98) echo -n 98 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Vous n'êtes pas ${voc}root${reset}, les trois premiers caractères de permissions ne vous concernent donc pas. : d${codeError}rwx${reset}r-xr-x"; restore=$(expr $restore + 1) ;&
99) echo -n 99 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Vous ne faites également pas partie du groupe en question : drwx${codeError}r-x${reset}r-x"; restore=$(expr $restore + 1) ;&
100) echo -n 100 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Les permissions qui vous concernent sont les trois dernières : drwxr-x${codeFile}r-x${reset}"; restore=$(expr $restore + 1) ;&
101) echo -n 101 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Vous avez donc les droits de lecture ${codeFile}r${reset} et d'exécution ${codeFile}x${reset}."; restore=$(expr $restore + 1) ;&
102) echo -n 102 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Mais qu'en est-il de cette permission ${voc}d'exécution${reset} ?"; restore=$(expr $restore + 1) ;&
103) echo -n 103 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk_not_press_key justumen "Affichons à nouveau les permissions des éléments du répertoire courant."; restore=$(expr $restore + 1) ;&
104) echo -n 104 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; answer_run "ls -l" justumen "Non"; restore=$(expr $restore + 1) ;&
105) echo -n 105 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Ici nous avons un dossier avec le droit de lecture et d'écriture."; restore=$(expr $restore + 1) ;&
106) echo -n 106 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk_not_press_key justumen "Rentrons dans ce dossier."; restore=$(expr $restore + 1) ;&
107) echo -n 107 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; answer_run "cd Dossier" justumen "Non"; restore=$(expr $restore + 1) ;&
108) echo -n 108 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Ici, malgré avoir le droit de lecture sur ce dossier, nous ne pouvons pas nous déplacer dedans."; restore=$(expr $restore + 1) ;&
109) echo -n 109 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Pour un fichier texte, les permissions ${codeFile}x${reset} n'ont aucun effet..."; restore=$(expr $restore + 1) ;&
110) echo -n 110 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Mais ici avec un ${voc}dossier${reset}, le ${codeFile}x${reset} joue un rôle important !"; restore=$(expr $restore + 1) ;&
111) echo -n 111 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Etrangement, nous avons le droit de lecture avec ce d${codeFile}r${reset}w-r--r--"; restore=$(expr $restore + 1) ;&
112) echo -n 112 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk_not_press_key justumen "Donc nous pouvons afficher les éléments de ce dossier, faites le donc."; restore=$(expr $restore + 1) ;&
113) echo -n 113 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; answer_run "ls Dossier" justumen "Non"; restore=$(expr $restore + 1) ;&
114) echo -n 114 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Le contenu de 'Dossier' s'affiche. Il contient un fichier 'X' et un fichier 'Y'."; restore=$(expr $restore + 1) ;&
115) echo -n 115 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk_not_press_key justumen "Affichons maintenant les permissions des fichiers dans ce dossier."; restore=$(expr $restore + 1) ;&
116) echo -n 116 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; answer_run "ls -l Dossier" justumen "Non"; restore=$(expr $restore + 1) ;&
117) echo -n 117 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Ici l'absence de ${codeFile}x${reset} dans les permissions de 'Dossier' nous empêche d'accéder aux détails."; restore=$(expr $restore + 1) ;&
118) echo -n 118 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Attention donc à ces permissions !"; restore=$(expr $restore + 1) ;&
119) echo -n 119 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Si quelque chose ne se passe pas comme prévu, il se peut que vous ayez simplement un problème de permission à régler."; restore=$(expr $restore + 1) ;&
120) echo -n 120 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "C'est ce que nous allons voir maintenant : Comment changer ces permissions ?"; restore=$(expr $restore + 1) ;&
121) echo -n 121 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Donc en premier lieu il faut que vous soyiez capable d'identifier la permission qu'il vous manque !"; restore=$(expr $restore + 1) ;&
122) echo -n 122 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "La commande ${code}cat${reset} par exemple a besoin d'une permission de lecture : ${codeFile}r${reset}."; restore=$(expr $restore + 1) ;&
123) echo -n 123 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Le fichier 'f1' ne nous donne pas cette permission pour l'afficher."; restore=$(expr $restore + 1) ;&
124) echo -n 124 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Pour changer ces permissions il faudra utiliser la commande : ${code}chmod${reset}."; restore=$(expr $restore + 1) ;&
125) echo -n 125 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Il faudra d'abord mémoriser 3 nouvelles lettres :"; restore=$(expr $restore + 1) ;&
126) echo -n 126 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "${code}u${reset} pour l'${code}u${reset}tilisateur ou le propriétaire : -${codeFile}rwx${reset}rwxrwx"; restore=$(expr $restore + 1) ;&
127) echo -n 127 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "${code}g${reset} pour le ${code}g${reset}roupe : -rwx${codeFile}rwx${reset}rwx"; restore=$(expr $restore + 1) ;&
128) echo -n 128 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "et ${code}o${reset} pour '${code}o${reset}thers', l'anglais de 'autres' : -rwxrwx${codeFile}rwx${reset}"; restore=$(expr $restore + 1) ;&
129) echo -n 129 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Vous pouvez ensuite utilisez ces lettres en conjonction avec les lettres 'r', 'w' et 'x' que vous connaissez déjà."; restore=$(expr $restore + 1) ;&
130) echo -n 130 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Vous devez également utiliser les symboles ${code}+${reset} et ${code}-${reset}, pour ajouter ou supprimer une permission."; restore=$(expr $restore + 1) ;&
131) echo -n 131 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk_not_press_key justumen "Relancez : ${learn}ls -l${reset}"; restore=$(expr $restore + 1) ;&
132) echo -n 132 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; answer_run "ls -l" justumen "Non"; restore=$(expr $restore + 1) ;&
133) echo -n 133 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Et prenons un exemple : Comment pouvoir nous autoriser l'affichage de 'f1' ?"; restore=$(expr $restore + 1) ;&
134) echo -n 134 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Autrement dit : transformer ---------- en -r--------."; restore=$(expr $restore + 1) ;&
135) echo -n 135 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "D'abord nous voulons changer les permissions du propriétaire, il faudra donc utiliser la lettre ${code}u${reset}."; restore=$(expr $restore + 1) ;&
136) echo -n 136 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Nous voulons ajouter une permission, il faudra donc utiliser le symbole ${code}+${reset}."; restore=$(expr $restore + 1) ;&
137) echo -n 137 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Nous voulons le droit de lecture, il faudra donc bien sûr utiliser la lettre ${code}r${reset}."; restore=$(expr $restore + 1) ;&
138) echo -n 138 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Et la cible de chmod sera le fichier 'f1'."; restore=$(expr $restore + 1) ;&
139) echo -n 139 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "La syntaxe sera donc la suivante : ${learn}chmod u+r f1${reset}"; restore=$(expr $restore + 1) ;&
140) echo -n 140 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk_not_press_key justumen "Avant de lancer cette commande, essayez donc d'afficher le contenu de 'f1'."; restore=$(expr $restore + 1) ;&
141) echo -n 141 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; answer_run "cat f1" justumen "Non"; restore=$(expr $restore + 1) ;&
142) echo -n 142 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk_not_press_key justumen "Ajoutons donc le droit de lecture à 'f1' pour le propriétaire avec : ${learn}chmod u+r f1${reset}"; restore=$(expr $restore + 1) ;&
143) echo -n 143 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; answer_run "chmod u+r f1" justumen "Non"; restore=$(expr $restore + 1) ;&
144) echo -n 144 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk_not_press_key justumen "Relancez : ${learn}ls -l${reset}"; restore=$(expr $restore + 1) ;&
145) echo -n 145 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; answer_run "ls -l" justumen "Non"; restore=$(expr $restore + 1) ;&
146) echo -n 146 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Ici nous avons bien : -r-------- pour le fichier 'f1'."; restore=$(expr $restore + 1) ;&
147) echo -n 147 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk_not_press_key justumen "Et enfin, affichez le fichier 'f1'."; restore=$(expr $restore + 1) ;&
148) echo -n 148 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; answer_run "cat f1" justumen "Non"; restore=$(expr $restore + 1) ;&
149) echo -n 149 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Vous pouvez donc utiliser toutes les combinaisons que vous voulez : ${learn}u+r${reset}, ${learn}g-w${reset}, ${learn}u+x${reset}, etc..."; restore=$(expr $restore + 1) ;&
150) echo -n 150 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Mais vous pouvez aussi les cumuler avec d'autres, comme par exemple pour donner au propriétaire le droit de lecture ET d'écriture, vous pouvez faire : ${learn}u+rw${reset}."; restore=$(expr $restore + 1) ;&
151) echo -n 151 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Pour enlever aux membres du groupe et aux autres le droit d'écriture, vous pouvez faire : ${learn}go-w${reset}"; restore=$(expr $restore + 1) ;&
152) echo -n 152 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Ou encore pour donner tous les droits à tout le monde, vous pouvez faire : ${learn}ugo+rwx${reset}."; restore=$(expr $restore + 1) ;&
153) echo -n 153 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Ou enlever tous les droits de tout le monde avec ${learn}ugo-rwx${reset}."; restore=$(expr $restore + 1) ;&
154) echo -n 154 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Avant de passer au questionnaire je vous rappelle que le droit d'écriture donne le droit de ${voc}suppression${reset}."; restore=$(expr $restore + 1) ;&
155) echo -n 155 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Bonne chance !"; restore=$(expr $restore + 1) ;&
156) echo -n 156 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; clean; restore=$(expr $restore + 1) ;&
esac
}
function clean(){ #in enter_chapter
rm $HOME/.GameScript/restore_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
rm $HOME/.GameScript/restore_pwd_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
	chmod -R 744 $HOME/.GameScript_bash5 2> /dev/null
	rm $HOME/.GameScript_bash5/f1 2> /dev/null
	rm $HOME/.GameScript_bash5/f2 2> /dev/null
	rm $HOME/.GameScript_bash5/f3 2> /dev/null
	rm $HOME/.GameScript_bash5/f4 2> /dev/null
	rm $HOME/.GameScript_bash5/file 2> /dev/null
	rm $HOME/.GameScript_bash5/Dossier/X 2> /dev/null
	rm $HOME/.GameScript_bash5/Dossier/Y 2> /dev/null
	rmdir $HOME/.GameScript_bash5/Dossier 2> /dev/null
	rmdir $HOME/.GameScript_bash5 2> /dev/null
}

function start_quiz(){
  echo ""
  echo -e "\e[15;44m Bash 'Bourne Again SHell' : Questionnaire du chapitre 5 \e[0m"
  echo -e "- La réponse doit être la plus courte possible, une commande valide mais ajoutant des caractères inutiles ne fonctionnera pas."
  echo -e "Exemple : si la réponse est 'ls'. Les réponses 'ls .', 'ls ./' et 'ls ././' seront considérées comme fausses."
  answer_text_fr "Comment afficher les permissions des éléments du répertoire personnel de l'utilisateur ?" "ls -l ~"
  answer_text_fr "Quelle lettre représente un dossier dans le résultat de 'ls -l' ?" "d"
  answer_text_fr "Quel symbole représente un fichier dans le résultat de 'ls -l' ?" "-"
  answer_text_fr "Quelle lettre représente le droit d'écriture dans le résultat de 'ls -l' ?" "w"
  answer_text_fr "Quelle lettre représente le droit de lecture dans le résultat de 'ls -l' ?" "r"
  answer_text_fr "Quelle lettre représente le droit d'exécution dans le résultat de 'ls -l' ?" "x"
  answer_text_fr "Quelle est la commande capable de modifier les permissions d'un fichier ?" "chmod"
  answer_text_fr "Quelle lettre représente le propriétaire pour la commande chmod ?" "u"
  answer_text_fr "Comment supprimer la permission de lecture au propriétaire du fichier 'test' ?" "chmod u-r test"
  answer_text_fr "Comment ajouter la permission d'exécution sur le fichier 'test' à tous les utilisateurs sauf pour le propriétaire ?" "chmod go+x test"
  unlock "bash" "5" "28ab" "3d4e"
}


CHAPTER_NAME="bash"
CHAPTER_NUMBER="5"
LANGUAGE="fr"
SPEAKER="m1"

LINES=155
if [ "$1" == "VIDEO" ]; then
	prepare_video
else
	if [ ! "$1" == "MUTE" ]; then
		prepare_audio
	fi
fi


enter_chapter $CHAPTER_NAME $CHAPTER_NUMBER
