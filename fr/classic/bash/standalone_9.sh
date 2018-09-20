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
				press_key
				stop_quiz_music
				#enter_chapter $CHAPTER_NAME $CHAPTER_NUMBER
				exit ;;
			en) talk_not_press_key justumen "\\e[4;37mSorry answer wrong or too long. I recommend you to do / re-do the lecture :-)\nIf you think you already understand the content of the lecture, this question is probably a trap, read the question again carefully. :-)\nIf you feel stuck, ask for help in our chat : https://rocket.bjornulf.org or our discord : https://discord.gg/25eRgvD\\e[0m"
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
		fr) echo -e "Pour débloquer '$1 $2' sur rocketchat (https://rocket.bjornulf.org), ouvrez une conversation privée avec '@boti' et copiez/collez :\n\t\e[97;42mpassword$PASS\e[0m"
			echo -e "Pour débloquer '$1 $2' sur discord (https://discord.gg/25eRgvD), ouvrez le channel '#mots-de-passe-boti' et copiez/collez :\n\t\e[97;42mpassword$PASS\e[0m"
			command -v xclip &> /dev/null && echo "Ce mot de passe a été copié automatiquement avec 'xclip'." || echo "[ Installez 'xclip' pour copier ce mot de passe automatiquement après un questionnaire. ]"
			;;
		en) #echo -e "To unlock '$1 $2' on rocketchat (https://rocket.bjornulf.org), open a private conversation with '@boti' and copy/paste :\n\t\e[97;42mpassword$PASS\e[0m"
			echo -e "To unlock '$1 $2' on discord (https://discord.gg/Dj47Tpf), open the channel '#passwords-boti' and copy/paste :\n\t\e[97;42mpassword$PASS\e[0m"
			command -v xclip &> /dev/null && echo "This password was automaticaly copied with 'xclip'." || echo "[ Install 'xclip' to copy this password automaticaly after a quiz. ]"
			;;
	esac
	command -v xclip &> /dev/null && echo "$PASS" | xclip -i -selection clipboard
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
1) echo -n 1 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; [ -d "$HOME/.GameScript_bash9" ] && echo "Erreur inattendue, ${HOME}/.GameScript_bash9 existe déjà sur votre système ! Supprimez ce dossier $HOME/.GameScript_bash9 et relancez ce script." && exit; restore=$(expr $restore + 1) ;&
2) echo -n 2 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; mkdir $HOME/.GameScript_bash9 2> /dev/null; restore=$(expr $restore + 1) ;&
3) echo -n 3 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; cd $HOME/.GameScript_bash9; restore=$(expr $restore + 1) ;&
4) echo -n 4 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; echo -e "echo Je suis code_bash\\npwd;ls\\nmkdir FOLDER">$HOME/.GameScript_bash9/code_bash;echo -e "echo Je suis code_bash2 et je ne fais rien de spécial.">$HOME/.GameScript_bash9/code_bash2;chmod +x $HOME/.GameScript_bash9/code_bash2; restore=$(expr $restore + 1) ;&
5) echo -n 5 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Bash peut être utilisé de manière interactive, comme nous le faisons depuis le chapitre 1, mais bash est aussi un langage de programmation."; restore=$(expr $restore + 1) ;&
6) echo -n 6 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Vous pouvez donc stocker toutes les commandes que vous avez apprises dans un fichier texte et demander à 'bash' de les lancer ligne par ligne."; restore=$(expr $restore + 1) ;&
7) echo -n 7 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Affichez votre répertoire courant et son contenu avec : ${learn}pwd;ls${reset}."; restore=$(expr $restore + 1) ;&
8) echo -n 8 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "pwd;ls" justumen "Non"; restore=$(expr $restore + 1) ;&
9) echo -n 9 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Affichez le contenu du fichier 'code_bash'."; restore=$(expr $restore + 1) ;&
10) echo -n 10 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "cat code_bash" justumen "Non"; restore=$(expr $restore + 1) ;&
11) echo -n 11 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Ce fichier 'code_bash' contient trois lignes de commande que vous devriez comprendre."; restore=$(expr $restore + 1) ;&
12) echo -n 12 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Pour lancez les commandes de ce fichier 'code_bash', il suffit de donner ce fichier en argument à la commande ${voc}bash${reset}."; restore=$(expr $restore + 1) ;&
13) echo -n 13 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Faites donc : ${learn}bash code_bash${reset}"; restore=$(expr $restore + 1) ;&
14) echo -n 14 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "bash code_bash" justumen "Non"; restore=$(expr $restore + 1) ;&
15) echo -n 15 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Listez les éléments du répertoire courant."; restore=$(expr $restore + 1) ;&
16) echo -n 16 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "ls" justumen "Non"; restore=$(expr $restore + 1) ;&
17) echo -n 17 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Ici 'bash' a bien créé le dossier 'FOLDER' avec la commande ${learn}mkdir FOLDER${reset} contenu dans le fichier 'code_bash'."; restore=$(expr $restore + 1) ;&
18) echo -n 18 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Vous pouvez aussi utiliser tous les autres concepts que vous avez déjà appris dans les chapitres précédents."; restore=$(expr $restore + 1) ;&
19) echo -n 19 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Faites par exemple : ${learn}cat code_bash|bash>/dev/null${reset}"; restore=$(expr $restore + 1) ;&
20) echo -n 20 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "cat code_bash|bash>/dev/null" justumen "Non"; restore=$(expr $restore + 1) ;&
21) echo -n 21 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Ici seul l'erreur de ${code}mkdir${reset} est envoyée dans le terminal, puisque les commandes ${code}ls${reset} et ${code}pwd${reset} utilisent la sortie standard."; restore=$(expr $restore + 1) ;&
22) echo -n 22 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Pour rappel, vous auriez pu également faire ${learn}cat code_bash|bash -${reset} ou utiliser le chemin absolu de ce fichier, avec par exemple ${learn}bash ~/.GameScript_bash9/code_bash${reset}."; restore=$(expr $restore + 1) ;&
23) echo -n 23 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Pour executer un fichier, vous pouvez aussi utiliser ${code}./${reset} avant le nom du fichier que vous voulez lancer."; restore=$(expr $restore + 1) ;&
24) echo -n 24 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Faites donc : ${learn}./code_bash2${reset}"; restore=$(expr $restore + 1) ;&
25) echo -n 25 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "./code_bash2" justumen "Non"; restore=$(expr $restore + 1) ;&
26) echo -n 26 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Faites la même chose pour 'code_bash'."; restore=$(expr $restore + 1) ;&
27) echo -n 27 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "./code_bash" justumen "Non"; restore=$(expr $restore + 1) ;&
28) echo -n 28 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Ici en utilisant ${code}./${reset} nous avons un problème de permission."; restore=$(expr $restore + 1) ;&
29) echo -n 29 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Etrange puisque nous n'avons pas eu de soucis avec la commande ${learn}bash code_bash${reset}."; restore=$(expr $restore + 1) ;&
30) echo -n 30 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Affichez les permissions de tous les éléments du répertoire courant qui commencent par 'code'."; restore=$(expr $restore + 1) ;&
31) echo -n 31 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "ls -l code*" justumen "Non"; restore=$(expr $restore + 1) ;&
32) echo -n 32 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Pour pouvoir executer un fichier avec ${code}./${reset}, ce fichier doit avoir le droit d'execution (x)."; restore=$(expr $restore + 1) ;&
33) echo -n 33 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Un fichier texte n'aura pas cette permission par défaut, vous devez donc l'ajouter manuellement."; restore=$(expr $restore + 1) ;&
34) echo -n 34 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Donnez le droit d'execution sur 'code_bash' pour le propriétaire de ce fichier."; restore=$(expr $restore + 1) ;&
35) echo -n 35 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "chmod u+x code_bash" justumen "Non"; restore=$(expr $restore + 1) ;&
36) echo -n 36 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "On peut dire qu'au moment où un fichier texte devient executable, il se transforme en un ${voc}script${reset} ou ${voc}programme${reset}."; restore=$(expr $restore + 1) ;&
37) echo -n 37 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Autrement dit : ${voc}Un script bash est un simple fichier texte contenant des commandes bash.${reset}"; restore=$(expr $restore + 1) ;&
38) echo -n 38 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Executez maintenant 'code_bash' en utilisant ${code}./${reset}."; restore=$(expr $restore + 1) ;&
39) echo -n 39 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "./code_bash" justumen "Non"; restore=$(expr $restore + 1) ;&
40) echo -n 40 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Vous avez peut être remarqué que ${code}./${reset} ne fait que remplacer votre répertoire courant."; restore=$(expr $restore + 1) ;&
41) echo -n 41 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "C'est effectivement le cas, pour executer un fichier, il suffit de spécifier son chemin."; restore=$(expr $restore + 1) ;&
42) echo -n 42 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Vous pouvez également utiliser son chemin absolu, faites donc : ${learn}~/.GameScript_bash9/code_bash${reset}"; restore=$(expr $restore + 1) ;&
43) echo -n 43 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "~/.GameScript_bash9/code_bash" justumen "Non"; restore=$(expr $restore + 1) ;&
44) echo -n 44 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Attention cependant lorsque vous utilisez le chemin absolu, les commandes du script utiliserons votre répertoire courant, ${voc}pas${reset} le dossier où se trouve votre script."; restore=$(expr $restore + 1) ;&
45) echo -n 45 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Par exemple si vous êtes dans le dossier '/var' et que vous faites ${learn}~/.GameScript_bash9/code_bash${reset}, la commande ${learn}mkdir FOLDER${reset} voudra créer le dossier '/var/FOLDER'."; restore=$(expr $restore + 1) ;&
46) echo -n 46 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Pour éviter toute surprise, je vous recommande d'utiliser le plus souvent possible, des chemins absolus dans vos scripts."; restore=$(expr $restore + 1) ;&
47) echo -n 47 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Dans les chapitres précédents nous avons vu que si vous voulez garder une trace d'une information, vous pouvez la stocker dans un fichier, comme par exemple ${code}ls>fichier${reset}."; restore=$(expr $restore + 1) ;&
48) echo -n 48 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Si cette information n'a pas besoin d'être sauvegardée sur votre disque, nous avons vu qu'elle pouvait aussi être directement envoyée à une autre commande, comme par exemple ${code}ls|wc${reset}."; restore=$(expr $restore + 1) ;&
49) echo -n 49 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Mais bash peut aussi mémoriser certaines informations sans avoir besoin de créer un nouveau fichier."; restore=$(expr $restore + 1) ;&
50) echo -n 50 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Bash est capable de les stocker dans ce que l'on appelle une ${voc}variable${reset}."; restore=$(expr $restore + 1) ;&
51) echo -n 51 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Une variable est un nom symbolique qui est associé à une valeur."; restore=$(expr $restore + 1) ;&
52) echo -n 52 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; name=bjornulf; restore=$(expr $restore + 1) ;&
53) echo -n 53 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Je viens de créer pour vous une variable qui porte le nom : 'name'."; restore=$(expr $restore + 1) ;&
54) echo -n 54 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Afficher la valeur de cette variable avec : ${learn}echo \$name${reset}"; restore=$(expr $restore + 1) ;&
55) echo -n 55 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "echo \$name" justumen "Non"; restore=$(expr $restore + 1) ;&
56) echo -n 56 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Ce ${code}\$${reset} précise que le texte qui suit est le nom d'une variable et qu'il ne faut pas l'afficher tel quel."; restore=$(expr $restore + 1) ;&
57) echo -n 57 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "${code}echo name${reset} affichera bien évidemment le mot 'name' mais ${code}echo \$name${reset} affichera la valeur de la variable 'name'."; restore=$(expr $restore + 1) ;&
58) echo -n 58 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Pour créer une nouvelle variable, il faudra simplement utiliser le nom voulu, le symbole ${code}=${reset} suivit de sa valeur."; restore=$(expr $restore + 1) ;&
59) echo -n 59 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Créons donc une nouvelle variable 'chemin' qui contiendra le texte '/var/log' avec : ${learn}chemin=/var/log${reset}."; restore=$(expr $restore + 1) ;&
60) echo -n 60 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "chemin=/var/log" justumen "Non"; restore=$(expr $restore + 1) ;&
61) echo -n 61 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Si votre commande contient des espaces, vous pouvez par exemple utiliser les délimiteurs ${learn}\"${reset} et ${learn}'${reset} que nous avons déjà vu avec la commande ${code}echo${reset}."; restore=$(expr $restore + 1) ;&
62) echo -n 62 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "${learn}chemin=/var/log${reset} est équivalent à ${learn}chemin=\"/var/log\"${reset} et ${learn}chemin='/var/log'${reset}."; restore=$(expr $restore + 1) ;&
63) echo -n 63 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Affichons maintenant le contenu de cette variable avec : ${learn}echo \$chemin${reset}"; restore=$(expr $restore + 1) ;&
64) echo -n 64 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "echo \$chemin" justumen "Non"; restore=$(expr $restore + 1) ;&
65) echo -n 65 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "La commande ${code}echo${reset} affiche simplement le contenu de cette variable, mais les variables peuvent être utilisés par toutes les commandes."; restore=$(expr $restore + 1) ;&
66) echo -n 66 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Affichez donc le contenu du dossier ${code}/var/log${reset} avec : ${learn}ls \$chemin${reset}"; restore=$(expr $restore + 1) ;&
67) echo -n 67 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "ls \$chemin" justumen "Non"; restore=$(expr $restore + 1) ;&
68) echo -n 68 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Lorsque vous avez fait ${learn}chemin=/var/log${reset}, comme la variable n'existait pas, elle a été créée."; restore=$(expr $restore + 1) ;&
69) echo -n 69 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Pour la modifier, la syntaxe est exactement la même."; restore=$(expr $restore + 1) ;&
70) echo -n 70 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Modifier le contenu de la variable 'name' avec : ${learn}name=bob${reset}"; restore=$(expr $restore + 1) ;&
71) echo -n 71 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "name=bob" justumen "Non"; restore=$(expr $restore + 1) ;&
72) echo -n 72 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Attention à ne pas faire ${codeError}\$name=bob${reset}, le symbole ${code}\$${reset} ne devra être utilisé ${voc}que${reset} lors de l'utilisation de la variable, pas lors de sa modification."; restore=$(expr $restore + 1) ;&
73) echo -n 73 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Affichez maintenant le nouveau contenu de la variable 'name' avec : ${learn}echo \$name${reset}."; restore=$(expr $restore + 1) ;&
74) echo -n 74 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "echo \$name" justumen "Non"; restore=$(expr $restore + 1) ;&
75) echo -n 75 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Ici la valeur 'bjornulf' n'existe plus, votre commande ${learn}name=bob${reset} vient de la remplacer."; restore=$(expr $restore + 1) ;&
76) echo -n 76 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Vous pouvez également ajouter du texte à la commande ${code}echo${reset}, avec par exemple : ${learn}echo mon nom est \$name.${reset}"; restore=$(expr $restore + 1) ;&
77) echo -n 77 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "echo mon nom est \$name." justumen "Non"; restore=$(expr $restore + 1) ;&
78) echo -n 78 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Comme d'habitude, le '.' étant un caractère spécial, un espace n'est pas nécessaire."; restore=$(expr $restore + 1) ;&
79) echo -n 79 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Maintenant essayez par exemple de rajouter 'by' à la suite de cette variable, pour afficher 'bobby', avec : ${learn}echo \$nameby${reset}"; restore=$(expr $restore + 1) ;&
80) echo -n 80 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "echo \$nameby" justumen "Non"; restore=$(expr $restore + 1) ;&
81) echo -n 81 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Ici 'by' se mélange avec le nom de la variable, mais la variable 'nameby' n'existe pas, ${code}echo${reset} affiche donc une chaine de caractère vide."; restore=$(expr $restore + 1) ;&
82) echo -n 82 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Pour remédier à ce problème, vous pouvez par exemple utiliser le caractère d'échappement après le nom de la variable, pour clairement séparer la prochaine lettre."; restore=$(expr $restore + 1) ;&
83) echo -n 83 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Essayez donc d'utiliser la variable 'name' et le caractère d'échappement pour afficher : 'bobby'."; restore=$(expr $restore + 1) ;&
84) echo -n 84 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "echo \$name\\by" justumen "Non"; restore=$(expr $restore + 1) ;&
85) echo -n 85 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Attention, vous ne pouvez utiliser le caractère d'échappement qu'en dehors des délimiteurs ${code}'${reset} et ${code}\"${reset}."; restore=$(expr $restore + 1) ;&
86) echo -n 86 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Car je vous le rappelle, le caractère d'échappement est utilisé avec les délimiteurs pour afficher des mises à la ligne, des tabulations. etc..."; restore=$(expr $restore + 1) ;&
87) echo -n 87 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Une autre possibilité est de définir une limite à votre nom de variable, en utilisant les ${code}{}${reset}."; restore=$(expr $restore + 1) ;&
88) echo -n 88 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Essayez donc de faire : ${learn}echo \${name}by${reset}"; restore=$(expr $restore + 1) ;&
89) echo -n 89 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "echo \${name}by" justumen "Non"; restore=$(expr $restore + 1) ;&
90) echo -n 90 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Parfait, maintenant essayez : ${learn}echo \"\${name}by\"${reset}"; restore=$(expr $restore + 1) ;&
91) echo -n 91 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "echo \"\${name}by\"" justumen "Non"; restore=$(expr $restore + 1) ;&
92) echo -n 92 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Pour afficher un ${code}\$${reset}, il faudra simplement faire ${code} \\$ ${reset}."; restore=$(expr $restore + 1) ;&
93) echo -n 93 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Faites donc : ${learn}echo \"\\\$name=\$name\"${reset}"; restore=$(expr $restore + 1) ;&
94) echo -n 94 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "echo \"\\\$name=\$name\"" justumen "Non"; restore=$(expr $restore + 1) ;&
95) echo -n 95 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Et enfin essayez : ${learn}echo '\\\$name=\$name'${reset}"; restore=$(expr $restore + 1) ;&
96) echo -n 96 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "echo '\\\$name=\$name'" justumen "Non"; restore=$(expr $restore + 1) ;&
97) echo -n 97 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Ici le résultat est très différent ! Tous les caractères entre les ${code}'${reset} sont affichés littéralement."; restore=$(expr $restore + 1) ;&
98) echo -n 98 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Les ${code}'${reset} sont donc très utiles si vous avez besoin d'afficher des caractères qui pourraient avoir une autre signification."; restore=$(expr $restore + 1) ;&
99) echo -n 99 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Vous pouvez aussi utiliser tout en même temps, essayez : ${learn}echo '\${name}='\"\$name. \"ou \$name\\\by.${reset}"; restore=$(expr $restore + 1) ;&
100) echo -n 100 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "echo '\${name}='\"\$name. \"ou \$name\\by." justumen "Non"; restore=$(expr $restore + 1) ;&
101) echo -n 101 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Si vous comprenez parfaitement cette commande, vous avez tout compris."; restore=$(expr $restore + 1) ;&
102) echo -n 102 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Je le répète, la syntaxe de modification d'une variable est identique à celle de sa création."; restore=$(expr $restore + 1) ;&
103) echo -n 103 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Attention donc à ne pas modifier des variables importantes par erreur en pensant les créer."; restore=$(expr $restore + 1) ;&
104) echo -n 104 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "N'hésitez pas à vérifier avec un ${code}echo${reset} si une variable portant ce nom existe déjà."; restore=$(expr $restore + 1) ;&
105) echo -n 105 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Votre environnement possède des variables importantes, appelés ${voc}variables d'environnement${reset}."; restore=$(expr $restore + 1) ;&
106) echo -n 106 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Affichez donc vos ${voc}variables d'environnement${reset} avec : ${learn}printenv${reset}."; restore=$(expr $restore + 1) ;&
107) echo -n 107 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "printenv" justumen "Non"; restore=$(expr $restore + 1) ;&
108) echo -n 108 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Une des variables d'environnement les plus importante est 'PATH'. (l'anglais de chemin)"; restore=$(expr $restore + 1) ;&
109) echo -n 109 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Pour afficher uniquement la variable PATH, faites donc : ${learn}printenv PATH${reset}"; restore=$(expr $restore + 1) ;&
110) echo -n 110 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "printenv PATH" justumen "Non"; restore=$(expr $restore + 1) ;&
111) echo -n 111 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "'PATH' est une liste du chemin absolu de plusieurs dossiers que bash utilise pour simplifier les appels de commandes."; restore=$(expr $restore + 1) ;&
112) echo -n 112 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Ces dossiers sont sur une seule ligne et leurs chemins absolus sont séparés par des ${code}:${reset}."; restore=$(expr $restore + 1) ;&
113) echo -n 113 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Si votre variable d'environnement 'PATH' est mal configurée, vous risquez de rencontrer des difficultés à lancer certaines commandes."; restore=$(expr $restore + 1) ;&
114) echo -n 114 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Des commandes que nous avons déjà vu ensemble sont en fait stockées dans un des dossiers de la variable 'PATH'."; restore=$(expr $restore + 1) ;&
115) echo -n 115 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Par exemple, pour savoir où se trouve la commande ${code}date${reset}, faites : ${learn}type date${reset}."; restore=$(expr $restore + 1) ;&
116) echo -n 116 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "type date" justumen "Non"; restore=$(expr $restore + 1) ;&
117) echo -n 117 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "${code}type${reset} nous permet de comprendre que l'appel de la commande ${code}date${reset} correspond en fait à ${code}/bin/date${reset}."; restore=$(expr $restore + 1) ;&
118) echo -n 118 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Faites donc : ${learn}date;/bin/date${reset}."; restore=$(expr $restore + 1) ;&
119) echo -n 119 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "date;/bin/date" justumen "Non"; restore=$(expr $restore + 1) ;&
120) echo -n 120 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Il est pour vous possible d'utiliser directement la commande ${code}date${reset} au lieu de taper ${code}/bin/date${reset}, car le chemin absolu '/bin' est dans votre variable 'PATH'."; restore=$(expr $restore + 1) ;&
121) echo -n 121 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Attention donc à ne pas modifier accidentellement le contenu de la variable 'PATH', certaines commandes deviendraient inutilisables !"; restore=$(expr $restore + 1) ;&
122) echo -n 122 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Pour ajouter du contenu à une variable, il suffit de rajouter son nom au début de la modification."; restore=$(expr $restore + 1) ;&
123) echo -n 123 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Par exemple, pour ajouter ':~/.GameScript_bash9' à la variable 'PATH' faites donc : ${learn}PATH=\$PATH:~/.GameScript_bash9${reset}"; restore=$(expr $restore + 1) ;&
124) echo -n 124 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "PATH=\$PATH:~/.GameScript_bash9" justumen "Non"; restore=$(expr $restore + 1) ;&
125) echo -n 125 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Ici ${code}\$PATH${reset} est simplement traité comme une chaine de caractère, correspondant au contenu de la variable 'PATH'."; restore=$(expr $restore + 1) ;&
126) echo -n 126 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Auquel on y ajoute à la suite la chaine de caractère ':~/.GameScript_bash9'."; restore=$(expr $restore + 1) ;&
127) echo -n 127 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Affichez le nouveau contenu de la variable 'PATH'."; restore=$(expr $restore + 1) ;&
128) echo -n 128 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "echo \$PATH" justumen "Non"; restore=$(expr $restore + 1) ;&
129) echo -n 129 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Ici vous pouvez voir que '~/.GameScript_bash9' a bien été rajouté à la suite de l'ancienne version de 'PATH'."; restore=$(expr $restore + 1) ;&
130) echo -n 130 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Mais les modifications que vous faites sur les variables sont valables ${voc}uniquement${reset} pour la session de bash que vous utilisez actuellement."; restore=$(expr $restore + 1) ;&
131) echo -n 131 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Ouvrir un autre terminal ${voc}réinitialisera${reset} les variables importantes, comme par exemple 'PATH', et ${voc}supprimera${reset} les autres, comme ici les variables 'name' et 'chemin'."; restore=$(expr $restore + 1) ;&
132) echo -n 132 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Mais pour l'instant, puisque le dossier '~/.GameScript_bash9' est dans votre variable d'environnement 'PATH', vous pouvez simplement lancer le script 'code_bash' en tapant 'code_bash'."; restore=$(expr $restore + 1) ;&
133) echo -n 133 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Lancez donc 'code_bash'."; restore=$(expr $restore + 1) ;&
134) echo -n 134 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "code_bash" justumen "Non"; restore=$(expr $restore + 1) ;&
135) echo -n 135 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Déplacez vous dans le dossier 'FOLDER'."; restore=$(expr $restore + 1) ;&
136) echo -n 136 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "cd FOLDER" justumen "Non"; restore=$(expr $restore + 1) ;&
137) echo -n 137 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Lancez 'code_bash' à nouveau."; restore=$(expr $restore + 1) ;&
138) echo -n 138 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "code_bash" justumen "Non"; restore=$(expr $restore + 1) ;&
139) echo -n 139 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Maintenant faites donc : ${learn}pwd;ls${reset}."; restore=$(expr $restore + 1) ;&
140) echo -n 140 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "pwd;ls" justumen "Non"; restore=$(expr $restore + 1) ;&
141) echo -n 141 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Ici vous devriez comprendre clairement les effets des chemins relatifs dans vos scripts dont je vous ai parlé auparavant."; restore=$(expr $restore + 1) ;&
142) echo -n 142 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Et on termine par le questionnaire !"; restore=$(expr $restore + 1) ;&
143) echo -n 143 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; clean; restore=$(expr $restore + 1) ;&
esac
}
function clean(){ #in enter_chapter
rm $HOME/.GameScript/restore_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
rm $HOME/.GameScript/restore_pwd_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
	rm $HOME/.GameScript_bash9/code_bash 2> /dev/null
	rm $HOME/.GameScript_bash9/code_bash2 2> /dev/null
	rmdir $HOME/.GameScript_bash9/FOLDER/FOLDER 2> /dev/null
	rmdir $HOME/.GameScript_bash9/FOLDER 2> /dev/null
	rmdir $HOME/.GameScript_bash9 2> /dev/null
}

function start_quiz(){
  start_quiz_music
  echo ""
  echo -e "\e[15;44m Bash 'Bourne Again SHell' : Questionnaire du chapitre 9 \e[0m"
  echo -e "- La réponse doit être la plus courte possible, une commande valide mais ajoutant des caractères inutiles ne fonctionnera pas."
  echo -e "Exemple : si la réponse est 'ls'. Les réponses 'ls .', 'ls ./' et 'ls ././' seront considérées comme fausses."
  answer_text_fr "Comment afficher le contenu de la variable 'PATH' ?" 'echo $PATH'
  answer_text_fr "Comment ajouter ':/bin' à la fin de la variable 'PATH' ?" 'PATH=$PATH:/bin'
  answer_text_fr "En utilisant le caractère d'échappement, comment ajouter la lettre 'x' à la fin de la variable 'phrase' ?" 'phrase=$phrase\x'
  answer_text_fr "Comment afficher vos variables d'environnement ?" "printenv"
  answer_text_fr "Comment afficher le chemin absolu du fichier utilisé par la commande 'date' ?" "type date"
  answer_text_fr "Si vous executez le script bash '/scripts/sc' dans le dossier '/var/' et que ce script contient le code 'rm f', quel est le chemin absolu du fichier que 'bash' voudra supprimer ?" "/var/f"
  unlock "bash" "9" "6521" "ddd2"
}


CHAPTER_NAME="bash"
CHAPTER_NUMBER="9"
LANGUAGE="fr"
SPEAKER="m1"

LINES=142
if [ "$1" == "VIDEO" ]; then
	prepare_video
else
	if [ ! "$1" == "MUTE" ]; then
		prepare_audio
	fi
fi


enter_chapter $CHAPTER_NAME $CHAPTER_NUMBER
