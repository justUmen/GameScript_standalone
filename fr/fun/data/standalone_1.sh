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
		fr) echo -e "Pour débloquer '$1 $2' sur rocketchat (https://rocket.bjornulf.org), ouvrez une conversation privée avec '@boti' et copiez/collez :\n\t\e[97;42mpassword$PASS\e[0m"
			echo -e "Pour débloquer '$1 $2' sur discord (https://discord.gg/25eRgvD), ouvrez le channel '#mots-de-passe-boti' et copiez/collez :\n\t\e[97;42mpassword$PASS\e[0m"
			command -v xclip &> /dev/null && echo "Ce mot de passe a été copié automatiquement avec 'xclip'." || echo "[ Installez 'xclip' pour copier ce mot de passe automatiquement après un questionnaire. ]"
			;;
		en) #echo -e "To unlock '$1 $2' on rocketchat (https://rocket.bjornulf.org), open a private conversation with '@boti' and copy/paste :\n\t\e[97;42mpassword$PASS\e[0m"
			echo -e "To unlock '$1 $2' on discord (https://discord.gg/Dj47Tpf), open the channel '#passwords-boti' and copy/paste :\n\t\e[97;42mpassword$PASS\e[0m"
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
1) { echo -n 1 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Bonjour à tous et bienvenue dans le sujet le plus ennuyeux de tous les temps."; restore=$(expr $restore + 1) ;&
2) { echo -n 2 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Je suis sûr que vous allez me haïr tout de suite, mais j'ai décidé de vous parler de ce dont vous avez besoin et non de ce que vous voulez entendre."; restore=$(expr $restore + 1) ;&
3) { echo -n 3 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Sauter les bases fondamentales et se lancer dans des sujets passionnants est une erreur classique pour les débutants."; restore=$(expr $restore + 1) ;&
4) { echo -n 4 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Mais ce dont je vais vous parler ici est très important et je ne pense pas que vous savez tout sur le sujet."; restore=$(expr $restore + 1) ;&
5) { echo -n 5 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Même si vous pensez que c'est déjà le cas..."; restore=$(expr $restore + 1) ;&
6) { echo -n 6 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "J'ai vu beaucoup de personnes négliger certaines bases et ont fini par le regretter."; restore=$(expr $restore + 1) ;&
7) { echo -n 7 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Moi-même inclus ..."; restore=$(expr $restore + 1) ;&
8) { echo -n 8 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Au cours de votre relation à long terme avec votre ordinateur, vous créerez et contrôlerez un grand nombre d’entre eux."; restore=$(expr $restore + 1) ;&
9) { echo -n 9 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Et pour mettre fin au suspense, je parle de vos ${voc}fichiers${reset} et ${voc}dossiers${reset}."; restore=$(expr $restore + 1) ;&
10) { echo -n 10 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Dans ce chapitre, nous verrons quelques règles pour les créer et les organiser."; restore=$(expr $restore + 1) ;&
11) { echo -n 11 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Donc, pour résumer, il existe deux principaux types d’éléments qui sont stockés et gérés par votre ordinateur : des fichiers et des dossiers."; restore=$(expr $restore + 1) ;&
12) { echo -n 12 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Les fichiers représentent le coeur de pratiquement tout : ils stockent les informations réelles ou «données»."; restore=$(expr $restore + 1) ;&
13) { echo -n 13 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Cela peut être ce que vous voulez: texte, image, vidéo, pron, son, programme, etc."; restore=$(expr $restore + 1) ;&
14) { echo -n 14 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Et d'un autre coté, vous avez les dossiers."; restore=$(expr $restore + 1) ;&
15) { echo -n 15 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Les dossiers sont des éléments que vous pouvez utiliser pour organiser vos fichiers."; restore=$(expr $restore + 1) ;&
16) { echo -n 16 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Vous verrez ou entendez parfois le mot "répertoire" au lieu de "dossier"."; restore=$(expr $restore + 1) ;&
17) { echo -n 17 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Mais il n'y a absolument aucune différence entre les deux. Parfois, vous verrez l'un, parfois l'autre."; restore=$(expr $restore + 1) ;&
18) { echo -n 18 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Le nom 'dossier' vient d'un objet très ancien que les gens utilisaient pour stocker plusieurs éléments ensemble."; restore=$(expr $restore + 1) ;&
19) { echo -n 19 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Avant que l'écran ne soit inventé, le texte, comme la phrase que vous lisez actuellement, était stocké sur un fin morceau d'arbre mort."; restore=$(expr $restore + 1) ;&
20) { echo -n 20 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Cette partie du corps de l'arbre aplatie a été appelée «papier»."; restore=$(expr $restore + 1) ;&
21) { echo -n 21 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen ""; restore=$(expr $restore + 1) ;&
22) { echo -n 22 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "C'est difficile à imaginer, mais nos ancêtres assassinaient des arbres, les transformaient en ces feuilles minces et plates dans le seul but de stocker des mots sur leur surface."; restore=$(expr $restore + 1) ;&
23) { echo -n 23 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Mais c'était il y a longtemps, bien avant que cela ne soit considéré comme primitif et barbare."; restore=$(expr $restore + 1) ;&
24) { echo -n 24 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Croyez-le ou non, ces papiers sur lesquels étaient écrits des textes s'appelaient des «fichiers»."; restore=$(expr $restore + 1) ;&
25) { echo -n 25 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Oui, exactement comme ceux que vous avez sur votre ordinateur aujourd'hui."; restore=$(expr $restore + 1) ;&
26) { echo -n 26 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Revenons donc au dossier. Cela s'appelait un "classeur" parce que ce papier était deux fois plus grand qu'un papier normal, vous pouviez littéralement le "plier" et vous pouvez y mettre plusieurs papiers."; restore=$(expr $restore + 1) ;&
27) { echo -n 27 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Les fichiers à l'intérieur iront là où se trouve le dossier et, à cause du pli en bas, ils ne tomberont pas."; restore=$(expr $restore + 1) ;&
28) { echo -n 28 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; folder_unfold; restore=$(expr $restore + 1) ;&
29) { echo -n 29 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Je ne peux pas vous montrer un vrai dossier car ils sont bien sûr tous éteints, mais je peux vous le montrer afin que vous puissiez visualiser le concept. Ici vous pouvez clairement voir le pli."; restore=$(expr $restore + 1) ;&
30) { echo -n 30 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; folder_front; restore=$(expr $restore + 1) ;&
31) { echo -n 31 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Mais du côté ça va ressembler à ça, la partie au dessus du reste est utilisée pour une étiquette: le nom du dossier."; restore=$(expr $restore + 1) ;&
32) { echo -n 32 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "La complexité de l'organisation des fichiers de nos ancêtres peut être encore pire!"; restore=$(expr $restore + 1) ;&
33) { echo -n 33 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Dans ce dossier, vous pouvez également stocker un autre dossier plus petit, et dans ce dossier, vous pouvez stocker un autre dossier."; restore=$(expr $restore + 1) ;&
34) { echo -n 34 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Comme un système de dossiers russe où les dossiers deviennent de plus en plus petits."; restore=$(expr $restore + 1) ;&
35) { echo -n 35 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Votre ordinateur utilise le même concept!"; restore=$(expr $restore + 1) ;&
36) { echo -n 36 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Mais les ordinateurs n’ont pas les limites du monde réel, car comme nous le savons tous: le monde réel est nul et a été créé pour les personnes âgées."; restore=$(expr $restore + 1) ;&
37) { echo -n 37 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Sur un ordinateur, contrairement au monde réel, vous pouvez avoir une quantité illimitée de dossiers les uns dans les autres."; restore=$(expr $restore + 1) ;&
38) { echo -n 38 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Donc, si vous ne contrôlez PAS ce que vous faites, cela peut devenir très rapidement compliqué."; restore=$(expr $restore + 1) ;&
39) { echo -n 39 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Sur un ordinateur, $ {voc} avant $ {reset} créant un nouveau fichier ou un nouveau répertoire, vous devez penser à 2 choses:"; restore=$(expr $restore + 1) ;&
40) { echo -n 40 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "1 - Un bon emplacement."; restore=$(expr $restore + 1) ;&
41) { echo -n 41 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "2 - Un bon nom."; restore=$(expr $restore + 1) ;&
42) { echo -n 42 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Je vais vous donner un exemple et expliquer toutes mes décisions en cours de route."; restore=$(expr $restore + 1) ;&
43) { echo -n 43 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Votre objectif principal est de pouvoir retrouver vos fichiers, même après une longue période de temps ... Il est donc très important de leur trouver un endroit approprié."; restore=$(expr $restore + 1) ;&
44) { echo -n 44 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "S'il vous est difficile de trouver quelque chose sur votre propre ordinateur, c'est que vous vous êtes trompé. (aka: tu crains.)"; restore=$(expr $restore + 1) ;&
45) { echo -n 45 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Vous devez choisir une méthodologie et vous y tenir."; restore=$(expr $restore + 1) ;&
46) { echo -n 46 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Si vous avez déjà des fichiers et des dossiers, n’ayez pas peur de les supprimer ou de les réorganiser."; restore=$(expr $restore + 1) ;&
47) { echo -n 47 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Mais le meilleur conseil que je puisse vous donner pour éviter de perdre beaucoup de temps, est de bien le faire dès le début!"; restore=$(expr $restore + 1) ;&
48) { echo -n 48 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Je vais vous donner le système que j'utilise tous les jours et je vous invite à l'utiliser aussi ... si vous n'avez pas déjà quelque chose de mieux."; restore=$(expr $restore + 1) ;&
49) { echo -n 49 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Dans cet exemple, je veux créer et écrire un nouveau script shell!"; restore=$(expr $restore + 1) ;&
50) { echo -n 50 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Si vous ne savez pas ce qu’est un script shell: c’est un programme informatique simple basé sur du texte!"; restore=$(expr $restore + 1) ;&
51) { echo -n 51 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Un fichier texte qui peut faire des choses si vous le donnez à un shell comme bash."; restore=$(expr $restore + 1) ;&
52) { echo -n 52 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "GameScript est lui-même un script shell, et oui, il ne s'agit que d'un fichier texte digéré par bash."; restore=$(expr $restore + 1) ;&
53) { echo -n 53 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Quoi qu'il en soit, avant d'écrire notre nouveau script, nous devons le créer!"; restore=$(expr $restore + 1) ;&
54) { echo -n 54 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Alors d’abord, comme je l’ai dit, nous devons trouver un bon emplacement."; restore=$(expr $restore + 1) ;&
55) { echo -n 55 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Commençons notre voyage sur le répertoire de mon utilisateur. (/ home / justumen /)"; restore=$(expr $restore + 1) ;&
56) { echo -n 56 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Mais ne vous arrêtez pas là et créez le fichier '/ home / justumen / script'! C'est la pire chose que vous puissiez faire."; restore=$(expr $restore + 1) ;&
57) { echo -n 57 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Et c'est exactement ce que je ne veux pas que vous fassiez."; restore=$(expr $restore + 1) ;&
58) { echo -n 58 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Voici ce que nous allons faire: Nous allons entrer dans un répertoire appelé "Sync". (/ home / justumen / Sync /)"; restore=$(expr $restore + 1) ;&
59) { echo -n 59 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Ce répertoire est le répertoire que j'utilise pour synchroniser mes fichiers et répertoires sur toutes mes machines."; restore=$(expr $restore + 1) ;&
60) { echo -n 60 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Si je télécharge un gros morceau de données, une vidéo par exemple, je ne veux pas que ce soit dans le répertoire Sync!"; restore=$(expr $restore + 1) ;&
61) { echo -n 61 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Ce serait un gaspillage d'espace et de bande passante, je le mettrai dans "/ home / justumen / Videos" ou autre chose."; restore=$(expr $restore + 1) ;&
62) { echo -n 62 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Mais dans ce cas, disons que nous voulons pouvoir utiliser ce nouveau script sur toutes nos machines, alors dans le dossier "Sync", nous allons."; restore=$(expr $restore + 1) ;&
63) { echo -n 63 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Ce fichier sera un script, nous allons donc aller dans le répertoire "Script". (/ home / justumen / Sync / Script /)"; restore=$(expr $restore + 1) ;&
64) { echo -n 64 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Maintenant, je veux que le prochain répertoire représente le type du script."; restore=$(expr $restore + 1) ;&
65) { echo -n 65 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Si vous avez seulement quelques scripts, je suppose que vous pouvez simplement le créer ici."; restore=$(expr $restore + 1) ;&
66) { echo -n 66 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Mais si le répertoire est déjà encombré, comme le mien, vous devrez peut-être organiser vos scripts par catégories."; restore=$(expr $restore + 1) ;&
67) { echo -n 67 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Cela dépend de vos goûts et du nombre de fichiers et de répertoires que vous possédez déjà."; restore=$(expr $restore + 1) ;&
68) { echo -n 68 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Certaines personnes les organiseront en fonction du langage de programmation dans lequel ils sont écrits."; restore=$(expr $restore + 1) ;&
69) { echo -n 69 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Ainsi, dans leur répertoire "Script", ils auront des répertoires tels que "Python", "Perl", "Bash", etc."; restore=$(expr $restore + 1) ;&
70) { echo -n 70 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Mais personnellement, je suis plus intéressé par le travail du script que par le langage que j'utilise pour le faire."; restore=$(expr $restore + 1) ;&
71) { echo -n 71 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Tout est une question de goût, il n'y a pas de bonne ou de mauvaise façon de le faire .. mais les gens qui les organisent en fonction des langues sont stupides."; restore=$(expr $restore + 1) ;&
72) { echo -n 72 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Alors parlons d'abord de ce que je veux que notre script fasse, sinon ce que je dirai n'aura aucun sens."; restore=$(expr $restore + 1) ;&
73) { echo -n 73 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Disons que nous voulons que notre nouveau script fasse plusieurs requêtes à tous les principaux moteurs de recherche et ne renvoie que les résultats qu'ils ont tous en commun."; restore=$(expr $restore + 1) ;&
74) { echo -n 74 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Ce script devra évidemment explorer le Web comme une araignée ... sur le Web."; restore=$(expr $restore + 1) ;&
75) { echo -n 75 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Donc, si mon ordinateur n'est pas connecté à Internet, notre script est totalement inutile."; restore=$(expr $restore + 1) ;&
76) { echo -n 76 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Et comme nous sommes intelligents, nous avons déjà un dossier appelé "Web" prêt à être utilisé. (/ home / justumen / Sync / Script / Web)"; restore=$(expr $restore + 1) ;&
77) { echo -n 77 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Si un script se trouve dans ce dossier, nous savons qu'il ne fonctionnera pas correctement si l'ordinateur est hors ligne."; restore=$(expr $restore + 1) ;&
78) { echo -n 78 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Encore une fois ... si vous avez beaucoup de choses là-bas: Créez un autre répertoire!"; restore=$(expr $restore + 1) ;&
79) { echo -n 79 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Ce script va être lié au moteur de recherche, je vais donc aller dans mon dossier "SearchEngine". (/ home / justumen / Sync / Script / Web / SearchEngine)"; restore=$(expr $restore + 1) ;&
80) { echo -n 80 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Et c'est tout pour la première étape, nous avons finalement choisi un bon emplacement pour notre nouveau fichier !!"; restore=$(expr $restore + 1) ;&
81) { echo -n 81 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Et comme vous êtes très intelligent, vous avez probablement remarqué que j’avais utilisé des lettres majuscules."; restore=$(expr $restore + 1) ;&
82) { echo -n 82 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Oui ! Je vous recommande de toujours utiliser une lettre majuscule pour la première lettre d'un dossier."; restore=$(expr $restore + 1) ;&
83) { echo -n 83 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Il est très facile de voir que "Web" est en fait un dossier et non un fichier."; restore=$(expr $restore + 1) ;&
84) { echo -n 84 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Notez que sur tous les systèmes d'exploitation réels, «exemple» et «exemple» sont deux noms différents, une lettre majuscule est simplement considérée comme une lettre totalement différente."; restore=$(expr $restore + 1) ;&
85) { echo -n 85 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Lorsque c'est le cas, le système d'exploitation est appelé sensible à la casse."; restore=$(expr $restore + 1) ;&
86) { echo -n 86 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Ainsi, si vous lisez quelque part la phrase "le mot de passe est sensible à la casse", cela signifie qu'un "A" majuscule et un minuscule "a" sont considérés comme des lettres différentes."; restore=$(expr $restore + 1) ;&
87) { echo -n 87 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Linux est un vrai système d'exploitation, alors souvenez-vous: Linux est sensible à la casse."; restore=$(expr $restore + 1) ;&
88) { echo -n 88 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Broken Windows Broken est par exemple un système d’exploitation non réel / sensible à la casse, conçu pour permettre à votre grand-mère de lire ses emails."; restore=$(expr $restore + 1) ;&
89) { echo -n 89 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Mais vous pouvez également remarquer que ce nom que j'ai choisi, "SearchEngine", contient deux mots mais ne contient aucun espace."; restore=$(expr $restore + 1) ;&
90) { echo -n 90 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Si vous utilisez GameScript, vous ne voulez évidemment pas être un utilisateur informatique de base!"; restore=$(expr $restore + 1) ;&
91) { echo -n 91 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Et vous allez bientôt être un h4x0r un jour, alors vous aurez besoin de vous préparer à être admiré pour vos compétences."; restore=$(expr $restore + 1) ;&
92) { echo -n 92 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Donc, à compter d’aujourd’hui, voici mon conseil: lorsque vous créez un fichier ou un répertoire, n’utilisez pas d’espace dans son nom."; restore=$(expr $restore + 1) ;&
93) { echo -n 93 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "N'utilisez jamais d'espaces pour nommer ou renommer un fichier!"; restore=$(expr $restore + 1) ;&
94) { echo -n 94 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Bien entendu, vous ne devez pas utiliser d'espaces dans le nom de votre fichier."; restore=$(expr $restore + 1) ;&
95) { echo -n 95 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Et bien sûr, mettre des espaces dans les noms devrait être récompensé par une gifle à l'arrière de la tête."; restore=$(expr $restore + 1) ;&
96) { echo -n 96 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Dans de nombreux cas, shell inclus, les espaces sont déjà utilisés pour séparer les éléments les uns des autres."; restore=$(expr $restore + 1) ;&
97) { echo -n 97 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Si vous utilisez des espaces dans les noms de fichiers, toutes les commandes l33t que vous avez apprises échoueront dramatiquement et vous feront probablement pleurer."; restore=$(expr $restore + 1) ;&
98) { echo -n 98 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Nous y reviendrons plus tard, mais pour l’instant, rappelez-vous: les espaces ne sont pas destinés aux noms de fichiers!"; restore=$(expr $restore + 1) ;&
99) { echo -n 99 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Alors, que devriez-vous utiliser à la place des espaces?"; restore=$(expr $restore + 1) ;&
100) { echo -n 100 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Parfois, vous devez séparer deux mots différents dans votre nom de fichier ... Et pour résoudre ce problème, il existe deux méthodes."; restore=$(expr $restore + 1) ;&
101) { echo -n 101 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Certains ont mis une lettre majuscule sur la première lettre du mot suivant, comme je l’ai fait avec «SearchEngine»."; restore=$(expr $restore + 1) ;&
102) { echo -n 102 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "D'autres préfèrent remplacer les espaces par des tirets bas: 'Search_engine'."; restore=$(expr $restore + 1) ;&
103) { echo -n 103 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "J'utilise personnellement la première option, une majuscule pour les annuaires: 'SearchEngine'."; restore=$(expr $restore + 1) ;&
104) { echo -n 104 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Mais j'utilise la deuxième stratégie pour les espaces dans les fichiers: 'this_is_a_file'."; restore=$(expr $restore + 1) ;&
105) { echo -n 105 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Dans notre exemple, l'élément que je veux créer est un répertoire. Donc, "SearchEngine" est ce que nous allons utiliser ici."; restore=$(expr $restore + 1) ;&
106) { echo -n 106 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Je n'ai actuellement que quelques scripts ici, donc je n'ai pas besoin de plus de répertoires imbriqués."; restore=$(expr $restore + 1) ;&
107) { echo -n 107 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "'/ home / justumen / Sync / Script / Web / SearchEngine': Cette succession de répertoires est appelée $ {voc} chemin $ {reset}."; restore=$(expr $restore + 1) ;&
108) { echo -n 108 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Donc, pour dire ce que j'ai dit différemment: avant de créer un nouveau fichier, nous devons trouver un dossier avec un bon $ {voc} path $ {reset} pour le trouver!"; restore=$(expr $restore + 1) ;&
109) { echo -n 109 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Et nous pouvons enfin nous concentrer sur la deuxième étape, trouver un bon nom pour notre fichier!"; restore=$(expr $restore + 1) ;&
110) { echo -n 110 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Le pire nom est facile à trouver, quelque chose comme «fichier», «ce_fichier» ou «mon_script» est en effet un très mauvais choix."; restore=$(expr $restore + 1) ;&
111) { echo -n 111 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Les fichiers et les répertoires sont uniquement identifiés par la combinaison de leur nom et de leur chemin."; restore=$(expr $restore + 1) ;&
112) { echo -n 112 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Rappelez-vous que cela signifie que deux éléments situés au même endroit ne peuvent pas avoir exactement le même nom!"; restore=$(expr $restore + 1) ;&
113) { echo -n 113 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Donc, si vous respectez la règle dont j'ai parlé précédemment et utilisez un vrai système d'exploitation, vous pouvez avoir un répertoire appelé "Exemple" et un fichier appelé "exemple" au même endroit."; restore=$(expr $restore + 1) ;&
114) { echo -n 114 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Alors, qu'est-ce qui fait qu'un nom est bon?"; restore=$(expr $restore + 1) ;&
115) { echo -n 115 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Le nom doit être aussi court que possible mais en même temps, résumer le contenu réel du fichier."; restore=$(expr $restore + 1) ;&
116) { echo -n 116 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Vous devriez être capable de comprendre ce que le fichier contient en regardant simplement le chemin de son dossier et son nom."; restore=$(expr $restore + 1) ;&
117) { echo -n 117 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Par exemple, si vous devez ouvrir un script pour comprendre ce qu’il contient: Son nom est mauvais."; restore=$(expr $restore + 1) ;&
118) { echo -n 118 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Ou le chemin de son dossier est mauvais."; restore=$(expr $restore + 1) ;&
119) { echo -n 119 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Ou les deux..."; restore=$(expr $restore + 1) ;&
120) { echo -n 120 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Linux vous permet de faire ce que vous voulez avec vos noms, vous n’avez aucune obligation."; restore=$(expr $restore + 1) ;&
121) { echo -n 121 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Mais vous devez créer vos propres limites pour rester efficace à long terme."; restore=$(expr $restore + 1) ;&
122) { echo -n 122 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Pour les fichiers, vous avez également une autre astuce que vous pouvez utiliser: les extensions!"; restore=$(expr $restore + 1) ;&
123) { echo -n 123 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Si un fichier contient du texte brut sur "bob", vous souhaitez appeler ce fichier "bob.txt" ou "bob.text"."; restore=$(expr $restore + 1) ;&
124) { echo -n 124 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Pour une image jpeg de bob, vous pouvez utiliser "bob.jpg" ou "bob.jpeg"."; restore=$(expr $restore + 1) ;&
125) { echo -n 125 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Pour un script, vous pouvez par exemple utiliser "bob.sh" ou "bob.shell" ou "bob.bash"."; restore=$(expr $restore + 1) ;&
126) { echo -n 126 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Encore une fois, sur linux, vous êtes libre de faire ce que vous voulez. Mais n'abusez pas de cette liberté pour faire des bêtises!"; restore=$(expr $restore + 1) ;&
127) { echo -n 127 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Vous pouvez par exemple renommer l'image "bob.jpeg" en "bob.txt", mais il s'agira toujours d'une image de bob ..."; restore=$(expr $restore + 1) ;&
128) { echo -n 128 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Cela ne transformera PAS le fichier en un fichier texte, c'est juste la même image JPEG avec un nom stupide."; restore=$(expr $restore + 1) ;&
129) { echo -n 129 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Comme si vous aviez un dossier appelé "fichier.txt", cela serait très déroutant."; restore=$(expr $restore + 1) ;&
130) { echo -n 130 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "J'espère que cela est clair pour tout le monde, seulement le nom a changé, les données et le type de données à l'intérieur de $ {voc} ne sont pas $ {reset}."; restore=$(expr $restore + 1) ;&
131) { echo -n 131 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Je vous recommande donc d'utiliser des extensions qui correspondent à leur type. .html pour le langage de balisage hypertexte, .js pour javascript, .css pour la feuille de style en cascade, .sh pour les scripts shell, etc."; restore=$(expr $restore + 1) ;&
132) { echo -n 132 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Revenons donc à notre exemple: Le script que nous voulons créer."; restore=$(expr $restore + 1) ;&
133) { echo -n 133 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Nous avons déjà un bon chemin, nous avons donc besoin d’un bon nom."; restore=$(expr $restore + 1) ;&
134) { echo -n 134 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Dans notre exemple, basé sur ce que le script est supposé faire, un bon nom pourrait être "common_results.sh"."; restore=$(expr $restore + 1) ;&
135) { echo -n 135 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "".sh" car ce sera un script shell."; restore=$(expr $restore + 1) ;&
136) { echo -n 136 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen ""common_results" n'est certainement pas un bon nom en soi !!"; restore=$(expr $restore + 1) ;&
137) { echo -n 137 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Mais à cause du chemin que nous avons choisi, c'est en fait."; restore=$(expr $restore + 1) ;&
138) { echo -n 138 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Voyons le résultat final: "/home/justumen/Sync/Script/Web/SearchEngine/common_results.sh""; restore=$(expr $restore + 1) ;&
139) { echo -n 139 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Cette ligne est assez explicite."; restore=$(expr $restore + 1) ;&
140) { echo -n 140 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Il sera disponible sur toutes mes machines, il s’agit d’un script, il a besoin d’un accès à Internet et il peut me donner les résultats communs des moteurs de recherche."; restore=$(expr $restore + 1) ;&
141) { echo -n 141 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Ça y est, nous devons maintenant écrire le script."; restore=$(expr $restore + 1) ;&
142) { echo -n 142 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Quelque chose que nous ne ferons pas ici, car ce n'est pas le sujet de ce chapitre ..."; restore=$(expr $restore + 1) ;&
143) { echo -n 143 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Donc, pour résumer, il y a souvent plus d'une bonne réponse à un problème."; restore=$(expr $restore + 1) ;&
144) { echo -n 144 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Je vous ai donné quelques conseils, mais la manière dont vous créez et gérez tout dépend vraiment de vous."; restore=$(expr $restore + 1) ;&
145) { echo -n 145 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Tant que ça ne vous dérange pas d'être appelé stupide, bien sûr."; restore=$(expr $restore + 1) ;&
146) { echo -n 146 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Mais parfois, il y a plus d'une bonne réponse."; restore=$(expr $restore + 1) ;&
147) { echo -n 147 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Prenons un exemple: imaginons que vous souhaitiez utiliser 3 images différentes de 3 utilisateurs différents dans un script."; restore=$(expr $restore + 1) ;&
148) { echo -n 148 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Une petite image, une image de taille normale et une grande image pour disons: Rick, Jerry et Morty."; restore=$(expr $restore + 1) ;&
149) { echo -n 149 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Après avoir eu un bon chemin et un bon nom pour ce script, vous devez maintenant réfléchir à la façon dont vous voulez stocker ces images."; restore=$(expr $restore + 1) ;&
150) { echo -n 150 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Nous pouvons dire que la création d'un dossier 'Image' dans notre répertoire de script est une bonne idée!"; restore=$(expr $restore + 1) ;&
151) { echo -n 151 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "À partir de là, nous avons le choix: souhaitons-nous les stocker de la manière suivante: './Image/Rick/big.jpeg' ou de cette manière: './Image/Big/rick.jpeg'."; restore=$(expr $restore + 1) ;&
152) { echo -n 152 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Il n'y a pas de meilleure réponse, mais cela dépend peut-être de la manière dont vous utiliserez vos images dans votre script."; restore=$(expr $restore + 1) ;&
153) { echo -n 153 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Lorsque vous organisez vos fichiers et vos dossiers, la meilleure chose à faire est probablement d'imaginer une troisième personne en train de vous lire."; restore=$(expr $restore + 1) ;&
154) { echo -n 154 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Cette personne doit immédiatement comprendre comment votre système est organisé."; restore=$(expr $restore + 1) ;&
155) { echo -n 155 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "J'ai récemment récupéré d'anciens fichiers lorsque j'étais stupide."; restore=$(expr $restore + 1) ;&
156) { echo -n 156 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "La plupart d'entre eux portaient des noms tels que "exemple", "lol", "test.txt", "image75.jpeg" et ainsi de suite."; restore=$(expr $restore + 1) ;&
157) { echo -n 157 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Certains programmes s'appelaient 'script.sh', ou 'program.c' dans un dossier 'TMP' et des choses horribles similaires."; restore=$(expr $restore + 1) ;&
158) { echo -n 158 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Et je devais ouvrir et lire presque tous les fichiers pour comprendre ce qu’ils étaient censés faire."; restore=$(expr $restore + 1) ;&
159) { echo -n 159 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "C'était une énorme perte de temps et d'énergie!"; restore=$(expr $restore + 1) ;&
160) { echo -n 160 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Cette "troisième personne" dont je parlais pourrait être vous du futur !!!"; restore=$(expr $restore + 1) ;&
161) { echo -n 161 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Donc, quoi que vous fassiez, soyez plus intelligent que moi et ne sous-estimez pas l’organisation de vos fichiers et répertoires."; restore=$(expr $restore + 1) ;&
162) { echo -n 162 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Félicitations pour durer jusqu'à la fin de ce chapitre."; restore=$(expr $restore + 1) ;&
163) { echo -n 163 > $HOME/.GameScript/restore_data1; } 2>/dev/null ; { echo -n $(pwd) > $HOME/.GameScript/restore_pwd_data1; } 2>/dev/null ; talk justumen "Mais même si je suis déjà très impressionné par votre présence, je ne peux vous donner aucune récompense avant le quiz ..."; restore=$(expr $restore + 1) ;&
esac
}
CLREOL=$'\x1B[K'

function real_tree_1(){
echo -e "$basic
                                              .         ;${CLREOL}
                 .              .              ;%     ;;${CLREOL}
                   ,           ,                :;%  %;${CLREOL}
                    :         ;                   :;%;'     .,${CLREOL}
           ,.        %;     %;            ;        %;'    ,;${CLREOL}
             ;       ;%;  %%;        ,     %;    ;%;    ,%'${CLREOL}
              %;       %;%;      ,  ;       %;  ;%;   ,%;'%;%;;,.${CLREOL}
               ;%;      %;        ;%;        % ;%;  ,%;'${CLREOL}
                '%;.     ;%;     %;'         ';%%;.%;'${CLREOL}
                 ':;%.    ;%%. %@;        %; ;@%;%'${CLREOL}
                    ':%;.  :;bd%;          %;@%;'${CLREOL}
                      '@%:.  :;%.         ;@@%;'${CLREOL}
                        '@%.  ';@%.      ;@@%;${CLREOL}
                          '@%%. '@%%    ;@@%;${CLREOL}
                            ;@%. :@%%  %@@%;${CLREOL}
                             %@bd%%%bd%%:;${CLREOL}
                                #@%%%%%@@;${CLREOL}
                                %@@%%%@@;${CLREOL}
                                %@@@%(o);  . '${CLREOL}
                                %@@@o%@@(.,'${CLREOL}
                            '.. %@@@o%@@;${CLREOL}
                               ')@@@o%@@;${CLREOL}
                                %@@(o)@@;${CLREOL}
                               .%@@@@%@@;${CLREOL}
                               ;%@@@@%@@;.${CLREOL}
                              ;%@@@$code / $reset$basic@@@;.${CLREOL}
                         ...;%@@@@@@@@@@@@%..${CLREOL}$reset"
#~ restore=$(expr $restore + 1)
}


function real_tree_2(){
echo -e "$basic
                                              .         ;${CLREOL}
                 .              .              ;%     ;;${CLREOL}
                   ,           ,                :;%  %;${CLREOL}
                    :         ;                   :;%;'     .,${CLREOL}
           ,.        %;     %;            ;        %;'    ,;${CLREOL}
             ;       ;%;  %%;        ,     %;    ;%;    ,%'${CLREOL}
              %;       %;%;      ,  ;       %;  ;%;   ,%;'%;%;;,.$code /home/user/Images/ $reset$basic${CLREOL}
               ;%;      %;        ;%;        % ;%;  ,%;'${CLREOL}
                '%;.     ;%;     %;'         ';%%;.%;'${CLREOL}
                 ':;%.    ;%%. %@;        %; ;@%;%'$code /home/user/ $reset$basic${CLREOL}
                    ':%;.  :;bd%;          %;@%;'${CLREOL}
                      '@%:.  :;%.         ;@@%;'${CLREOL}
                        '@%.  ';@%.      ;@@%;${CLREOL}
                          '@%%. $code /var/ $reset$basic  ;@@%;${CLREOL}
                            ;@%. :@%%  %@@%;${CLREOL}
                       $code /bin/ $reset$basic%@bd%%%bd%%:;$code /home/ $reset$basic${CLREOL}
                                #@%%%%%@@;${CLREOL}
                                %@@%%%@@;${CLREOL}
                                %@@@%(o);  . '${CLREOL}
                                %@@@o%@@(.,'${CLREOL}
                            '.. %@@@o%@@;${CLREOL}
                               ')@@@o%@@;${CLREOL}
                                %@@(o)@@;${CLREOL}
                               .%@@@@%@@;${CLREOL}
                               ;%@@@@%@@;.${CLREOL}
                              ;%@@@$code / $reset$basic@@@;.${CLREOL}
                         ...;%@@@@@@@@@@@@%..${CLREOL}$reset"
#~ restore=$(expr $restore + 1)
}


function real_tree_3(){
echo -e "$basic
                                              .         ;${CLREOL}
                 .              .              ;%     ;;${CLREOL}
                   ,           ,                :;%  %;${CLREOL}
                    :         ;                   :;%;'     .,${CLREOL}
           ,.        %;     %;            ;        %;'    ,;${CLREOL}
             ;       ;%;  %%;        ,     %;    ;%;    ,%'      $codeFile /home/user/Images/linux.jpeg $reset$basic${CLREOL}
              %;       %;%;      ,  ;       %;  ;%;   ,%;'%;%;;,.$code /home/user/Images/ $reset$basic${CLREOL}
               ;%;      %;        ;%;        % ;%;  ,%;'${CLREOL}
                '%;.     ;%;     %;'         ';%%;.%;'${CLREOL}
                 ':;%.    ;%%. %@;        %; ;@%;%'$code /home/user/ $reset$basic${CLREOL}
                    ':%;.  :;bd%;          %;@%;'${CLREOL}
                      '@%:.  :;%.         ;@@%;'${CLREOL}
                        '@%.  ';@%.      ;@@%;$codeFile /home/fichier1 $reset$basic${CLREOL}
                          '@%%. $code /var/ $reset$basic  ;@@%;${CLREOL}
                            ;@%. :@%%  %@@%;${CLREOL}
                       $code /bin/ $reset$basic%@bd%%%bd%%:;$code /home/ $reset$basic${CLREOL}
                                #@%%%%%@@;${CLREOL}
                                %@@%%%@@;${CLREOL}
                                %@@@%(o);  . '${CLREOL}
                                %@@@o%@@(.,'${CLREOL}
                            '.. %@@@o%@@;${CLREOL}
                               ')@@@o%@@;$codeError /home $reset$basic${CLREOL}
                                %@@(o)@@;$codeFile /fichier1 $reset$basic${CLREOL}
                               .%@@@@%@@;$codeError /fichier1 $reset$basic${CLREOL}
                               ;%@@@@%@@;.${CLREOL}
                              ;%@@@$code / $reset$basic@@@;.${CLREOL}
                         ...;%@@@@@@@@@@@@%..${CLREOL}$reset"
#~ restore=$(expr $restore + 1)
}
function real_tree_4(){
echo -e "$basic
                                              .         ;${CLREOL}
                 .              .              ;%     ;;${CLREOL}
                   ,           ,                :;%  %;${CLREOL}
                    :         ;                   :;%;'     .,${CLREOL}
           ,.        %;     %;            ;        %;'    ,;${CLREOL}
             ;       ;%;  %%;        ,     %;    ;%;    ,%'      $codeFile /home/user/Images/linux.jpeg $reset$basic${CLREOL}
              %;       %;%;      ,  ;       %;  ;%;   ,%;'%;%;;,.$code /home/user/Images/ $reset$basic${CLREOL}
               ;%;      %;        ;%;        % ;%;  ,%;'${CLREOL}
                '%;.     ;%;     %;'         ';%%;.%;'${CLREOL}
                 ':;%.    ;%%. %@;        %; ;@%;%'$code /home/user/ $reset$basic${CLREOL}
                    ':%;.  :;bd%;          %;@%;'${CLREOL}
                      '@%:.  :;%.         ;@@%;'${CLREOL}
                        '@%.  ';@%.      ;@@%;$codeFile /home/fichier1 $reset$basic${CLREOL}
                          '@%%. $code /var/ $reset$basic  ;@@%;${CLREOL}
                            ;@%. :@%%  %@@%;${CLREOL}
                       $code /bin/ $reset$basic%@bd%%%bd%%:;$code /home/ $reset$basic${CLREOL}
                                #@%%%%%@@;${CLREOL}
                                %@@%%%@@;${CLREOL}
                                %@@@%(o);  . '${CLREOL}
                                %@@@o%@@(.,'${CLREOL}
                            '.. %@@@o%@@;${CLREOL}
                               ')@@@o%@@;$codeFile /Home $reset$basic${CLREOL}
                                %@@(o)@@;$codeFile /fichier1 $reset$basic${CLREOL}
                               .%@@@@%@@;$codeFile /fichier2 $reset$basic${CLREOL}
                               ;%@@@@%@@;.${CLREOL}
                              ;%@@@$code / $reset$basic@@@;.${CLREOL}
                         ...;%@@@@@@@@@@@@%..${CLREOL}$reset"
#~ restore=$(expr $restore + 1)
}

function tree_1(){
echo -e "
$code / $reset$basic
|-- $code /home/ $reset$basic
|   |-- $code /home/user/ $reset$basic
|   |   |-- $code /home/user/Pictures/ $reset$basic
|-- $code /bin/ $reset$basic
|-- $code /var/ $reset"
#~ restore=$(expr $restore + 1)
}

function tree_2(){
echo -e "
$code / $reset$basic
|-- $code /home/ $reset$basic
|   |-- $code /home/user/ $reset$basic
|   |   |-- $code /home/user/Pictures/ $reset$basic
|   |   |   |-- $codeFile /home/user/Pictures/linux.jpeg $reset$basic
|   |-- $codeFile /home/fichier1 $reset$basic
|   |-- $codeFile /home/fichier2 $reset$basic
|-- $code /bin/ $reset$basic
|-- $code /var/ $reset$basic
|-- $codeFile /fichier1 $reset$basic
|-- $codeFile /fichier2 $reset$basic
|-- $codeFile /Home $reset"
#~ restore=$(expr $restore + 1)
}

function tree_3(){
echo -e "
$code / $reset$basic
$code /home/ $reset$basic
$code /home/user/ $reset$basic
$code /home/user/Pictures/ $reset$basic
$codeFile /home/user/Pictures/linux.jpeg $reset$basic
$codeFile /home/fichier1 $reset$basic
$codeFile /home/fichier2 $reset$basic
$code /bin/ $reset$basic
$code /var/ $reset$basic
$codeFile /fichier1 $reset$basic
$codeFile /fichier2 $reset$basic
$codeFile /Home $reset"
#~ restore=$(expr $restore + 1)
}
function clean(){ #in enter_chapter
rm $HOME/.GameScript/restore_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
rm $HOME/.GameScript/restore_pwd_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null						
	rm $HOME/House/Room/virus0 2> /dev/null
	rm $HOME/House/Room/virus1 2> /dev/null
	rm $HOME/House/Room/virus2 2> /dev/null
	rm $HOME/House/Room/virus3 2> /dev/null
	rm $HOME/House/Room/virus4 2> /dev/null
	rmdir $HOME/House/Room/bed 2> /dev/null
	rmdir $HOME/House/Room/closet 2> /dev/null
	rmdir $HOME/House/Room/desk 2> /dev/null
	rmdir $HOME/House/Room/ 2> /dev/null
	rmdir $HOME/House/ 2> /dev/null
	rmdir $HOME/.GameScript_bash1 2> /dev/null
}

function start_quiz(){
  start_quiz_music
  echo ""
  echo -e "\e[15;44m Bash 'Bourne Again SHell' : Questionnaire du chapitre 1 \e[0m"
  echo -e "- La réponse doit être la plus courte possible, une commande valide mais ajoutant des caractères inutiles ne fonctionnera pas."
  echo -e "Exemple : si la réponse est 'ls'. Les réponses 'ls .', 'ls ./' et 'ls ././' seront considérées comme fausses."
  answer_text_fr "Quel symbole représente le répertoire racine sur Linux ?" "/"
  answer_text_fr "Quelle commande affiche le chemin absolu du répertoire courant ?" "pwd"
  answer_text_fr "Quelle commande affiche le contenu du répertoire racine ?" "ls /"
  answer_text_fr "Quelle commande change le répertoire courant du terminal par son répertoire parent ?" "cd .."
  answer_text_fr "Quelle commande affiche le contenu du répertoire courant ?" "ls"
  answer_text_fr "Quelle commande supprime le dossier vide 'test' du répertoire courant ?" "rmdir test"
  answer_text_fr "Par quel symbole commence le chemin absolu d'un fichier ?" "/"
  answer_text_fr "Le nom du chemin relatif d'un fichier est souvent plus court que son équivalent en chemin absolu. (vrai/faux)" "vrai"
  answer_text_fr "Quelle commande peut supprimer le fichier /home/test quel que soit votre répertoire courant ?" "rm /home/test"
  unlock "bash" "1" "24d8" "f016"
}


CHAPTER_NAME="bash"
CHAPTER_NUMBER="1"
LANGUAGE="fr"
SPEAKER="m1"

LINES=187
if [ "$1" == "VIDEO" ]; then
	prepare_video
else
	if [ ! "$1" == "MUTE" ]; then
		prepare_audio
	fi
fi


enter_chapter $CHAPTER_NAME $CHAPTER_NUMBER
