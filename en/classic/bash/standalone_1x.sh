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
1) echo -n 1 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; [ -d "$HOME/House" ] && echo "Unknown error, ${HOME}/House already exist ! Delete this folder $HOME/House and launch the script again." && exit; restore=$(expr $restore + 1) ;&
2) echo -n 2 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; mkdir $HOME/.GameScript_bash1; restore=$(expr $restore + 1) ;&
3) echo -n 3 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; cd $HOME/; restore=$(expr $restore + 1) ;&
4) echo -n 4 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Hello everyone and welcome in the first chapter about bash."; restore=$(expr $restore + 1) ;&
5) echo -n 5 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Before seeing our first command, we need to understand the logic behind the organisation of the files and folders in Linux."; restore=$(expr $restore + 1) ;&
6) echo -n 6 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Let's start to talk about 'directories', which are also called 'folders'."; restore=$(expr $restore + 1) ;&
7) echo -n 7 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; real_tree_1; restore=$(expr $restore + 1) ;&
8) echo -n 8 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "On linux, you can imagine the organization of files and folders like a tree."; restore=$(expr $restore + 1) ;&
9) echo -n 9 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "In this tree, the folders are shown in sky blue."; restore=$(expr $restore + 1) ;&
10) echo -n 10 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "At the base of the tree you have the symbol ${code}/${reset} which represent the ${voc}root directory${reset}."; restore=$(expr $restore + 1) ;&
11) echo -n 11 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "It a special folder that will contain ALL the other folders of the system."; restore=$(expr $restore + 1) ;&
12) echo -n 12 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; real_tree_2; restore=$(expr $restore + 1) ;&
13) echo -n 13 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "In this tree, everytime you see a new branch, it represent a new folder."; restore=$(expr $restore + 1) ;&
14) echo -n 14 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "This passage to another branch can also be seen in the sky blue names with the appearance of an additional symbol '/'."; restore=$(expr $restore + 1) ;&
15) echo -n 15 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "For example, ${code}/home/${reset} represent the folder 'home' in the ${voc}root directory${reset}."; restore=$(expr $restore + 1) ;&
16) echo -n 16 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "${code}/home/user/${reset} represent the directory 'user', which is the directory 'home', which is himself in the ${voc}root directory${reset}."; restore=$(expr $restore + 1) ;&
17) echo -n 17 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "And so on, like for example : ${code}/home/user/Images/${reset}"; restore=$(expr $restore + 1) ;&
18) echo -n 18 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "In this case, 'Images' is in 'user', 'user' is in 'home' and 'home' is in '/'."; restore=$(expr $restore + 1) ;&
19) echo -n 19 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "But be careful, to represent a directory, having a '/' at the end isn't mandatory."; restore=$(expr $restore + 1) ;&
20) echo -n 20 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "It means that ${learn}/home/user/${reset} is equivalent to ${learn}/home/user${reset}."; restore=$(expr $restore + 1) ;&
21) echo -n 21 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Also, ${learn}/home/${reset} and ${learn}/home${reset} are equivalent."; restore=$(expr $restore + 1) ;&
22) echo -n 22 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; real_tree_3; restore=$(expr $restore + 1) ;&
23) echo -n 23 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Now let's talk about the files, here in my tree they are in green. In my example, they are 'leaves' and are connected to a branch, or even sometimes the trunk itsef."; restore=$(expr $restore + 1) ;&
24) echo -n 24 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "These files belong to a folder. But we have here some problems in red, files that can't exist..."; restore=$(expr $restore + 1) ;&
25) echo -n 25 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "${codeError}fichier1${reset} can't exist because there is already a file with the same name ${codeFile}fichier1${reset} in the same directory. Here the root directory (/fichier1)"; restore=$(expr $restore + 1) ;&
26) echo -n 26 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "But above, ${codeFile}fichier1${reset} can exist because even if the name of the file is the same, they are not in the same folder."; restore=$(expr $restore + 1) ;&
27) echo -n 27 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "The elements in a Unix-like operating system should have a unique reference : here ${learn}/fichier1${reset} and ${learn}/home/fichier1${reset} are not in conflit."; restore=$(expr $restore + 1) ;&
28) echo -n 28 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "The file ${codeError}/home${reset} can't exist either, because there is already a folder ${code}/home/${reset} using the same name in the same place."; restore=$(expr $restore + 1) ;&
29) echo -n 29 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "For these files to exist, we must give them different names."; restore=$(expr $restore + 1) ;&
30) echo -n 30 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; real_tree_4; restore=$(expr $restore + 1) ;&
31) echo -n 31 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Here we just have to call the second file 'fichier2'."; restore=$(expr $restore + 1) ;&
32) echo -n 32 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "For ${codeError}home${reset}, we need to give another name that won't be a problem like 'Home'."; restore=$(expr $restore + 1) ;&
33) echo -n 33 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Yes ! On linux, uppercase letters are important. 'Home' and 'home' are two differents names."; restore=$(expr $restore + 1) ;&
34) echo -n 34 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "When the uppercase letters are different from the lowercase letters, we say that they are ${voc}case sensitive${reset}."; restore=$(expr $restore + 1) ;&
35) echo -n 35 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Indeed, linux is ${voc}case sensitive${reset}. It means that 'home', 'Home', 'hOme', 'hoMe', 'homE', 'HoMe', 'hOmE', 'HOme', 'hoME', 'HomE', 'hOMe', 'HOME', etc... are all different and valid names !"; restore=$(expr $restore + 1) ;&
36) echo -n 36 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; tree_1; restore=$(expr $restore + 1) ;&
37) echo -n 37 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "It is also possible to represent the linux folders this way."; restore=$(expr $restore + 1) ;&
38) echo -n 38 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; tree_2; restore=$(expr $restore + 1) ;&
39) echo -n 39 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "And here is the same example with files. Identical to the tree above."; restore=$(expr $restore + 1) ;&
40) echo -n 40 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; tree_3; restore=$(expr $restore + 1) ;&
41) echo -n 41 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "But the structure can also be understood without the tree-like format."; restore=$(expr $restore + 1) ;&
42) echo -n 42 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "If all this isn't obvious for you now, don't worry."; restore=$(expr $restore + 1) ;&
43) echo -n 43 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Now that you understand the logic, with time and repetition it will soon be easy for you."; restore=$(expr $restore + 1) ;&
44) echo -n 44 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "This kind of line, which start with the ${voc}root directory${reset} '/' is called the ${voc}absolute path${reset} of a folder or a file."; restore=$(expr $restore + 1) ;&
45) echo -n 45 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "It represents with precision only the file or the folder in question."; restore=$(expr $restore + 1) ;&
46) echo -n 46 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Here it is impossible to have too identical lines."; restore=$(expr $restore + 1) ;&
47) echo -n 47 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "This ${voc}absolute path${reset} is the most important concept of the command line."; restore=$(expr $restore + 1) ;&
48) echo -n 48 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen ""; restore=$(expr $restore + 1) ;&
49) echo -n 49 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Ce ${voc}chemin absolu${reset} est le concept le plus fondamental de la ligne de commande."; restore=$(expr $restore + 1) ;&
50) echo -n 50 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Maintenant nous pouvons voir notre première commande."; restore=$(expr $restore + 1) ;&
51) echo -n 51 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Commençons par créer un nouveau dossier avec la commande ${learn}mkdir${reset} (mkdir vient de l'anglais ${learn}M${reset}a${learn}K${reset}e ${learn}DIR${reset}ectory)."; restore=$(expr $restore + 1) ;&
52) echo -n 52 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Il suffit de taper mkdir, suivi d'un espace et enfin du nom du dossier."; restore=$(expr $restore + 1) ;&
53) echo -n 53 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk_not_press_key justumen "Créeons maintenant le dossier House en faisant : ${learn}mkdir House${reset} puis validez la commande en appuyant sur la touche entrée."; restore=$(expr $restore + 1) ;&
54) echo -n 54 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; answer_run "mkdir House" justumen "Non"; restore=$(expr $restore + 1) ;&
55) echo -n 55 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk_not_press_key justumen "Affichons maintenant les dossiers et les fichiers avec un simple ${learn}ls${reset} (ls vient de l'anglais ${learn}L${reset}i${learn}S${reset}t)."; restore=$(expr $restore + 1) ;&
56) echo -n 56 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; answer_run "ls" justumen "Non"; restore=$(expr $restore + 1) ;&
57) echo -n 57 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Vous devriez voir le dossier que vous venez de créer."; restore=$(expr $restore + 1) ;&
58) echo -n 58 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Maintenant rentrons dans ce dossier avec la commande ${learn}cd${reset} (cd vient de l'anglais ${learn}C${reset}hange ${learn}D${reset}irectory)."; restore=$(expr $restore + 1) ;&
59) echo -n 59 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk_not_press_key justumen "Pour cela, il suffit de faire ${code}cd${reset}, suivi du nom du dossier voulu, dans notre cas : ${learn}cd House${reset}."; restore=$(expr $restore + 1) ;&
60) echo -n 60 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; answer_run "cd House" justumen "Non"; restore=$(expr $restore + 1) ;&
61) echo -n 61 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk_not_press_key justumen "Maintenant réaffichons les fichiers et dossiers avec un simple ${learn}ls${reset}."; restore=$(expr $restore + 1) ;&
62) echo -n 62 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; answer_run "ls" justumen "Non"; restore=$(expr $restore + 1) ;&
63) echo -n 63 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Ici le répertoire 'House' est vide, c'est normal puisque nous venons de le créer."; restore=$(expr $restore + 1) ;&
64) echo -n 64 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Mais qu'en est-il ici du ${voc}chemin absolu${reset} dont je vous ai parlé avant ?"; restore=$(expr $restore + 1) ;&
65) echo -n 65 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "En fait, un terminal tourne toujours dans un dossier, et peut se 'déplacer' dans l'arborescense du système."; restore=$(expr $restore + 1) ;&
66) echo -n 66 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "C'est ce que vous avez fait avec la commande ${learn}cd House${reset}, vous avez déplacé votre terminal dans le dossier 'House'."; restore=$(expr $restore + 1) ;&
67) echo -n 67 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk_not_press_key justumen "Pour savoir dans quel répertoire votre terminal est en ce moment, il suffit de taper ${learn}pwd${reset} (pwd vient de l'anglais ${learn}P${reset}rint ${learn}W${reset}orking ${learn}D${reset}irectory)."; restore=$(expr $restore + 1) ;&
68) echo -n 68 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; answer_run "pwd" justumen "Non"; restore=$(expr $restore + 1) ;&
69) echo -n 69 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Le résultat que vous voyiez ici est le ${voc}chemin absolu${reset} du répertoire ou vous êtes en ce moment."; restore=$(expr $restore + 1) ;&
70) echo -n 70 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Ce répertoire où vous êtes porte un nom spécial : c'est votre ${voc}${voc}répertoire courant${reset}."; restore=$(expr $restore + 1) ;&
71) echo -n 71 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Comme je vous l'ai déjà dit, il n'est pas obligatoire de mettre un '/' pour le dernier dossier, c'est pourquoi vous voyez ici ${learn}$(pwd)${reset} sans un '/' à la fin."; restore=$(expr $restore + 1) ;&
72) echo -n 72 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Voilà donc 4 commandes Unix fondamentales : ${learn}pwd${reset}, ${learn}ls${reset}, ${learn}cd${reset} et ${learn}mkdir${reset}."; restore=$(expr $restore + 1) ;&
73) echo -n 73 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "${learn}pwd${reset} et ${learn}ls${reset} sont des commandes particulièrement innoffensives, elle ne font que vous donnez des renseignements."; restore=$(expr $restore + 1) ;&
74) echo -n 74 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "N'hésitez donc pas à les taper systématiquement, dès que vous êtes dans un terminal."; restore=$(expr $restore + 1) ;&
75) echo -n 75 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "${learn}pwd${reset}, pour savoir quel est votre ${voc}répertoire courant${reset}"; restore=$(expr $restore + 1) ;&
76) echo -n 76 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "et ${learn}ls${reset}, pour afficher le contenu de votre ${voc}répertoire courant${reset}."; restore=$(expr $restore + 1) ;&
77) echo -n 77 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk_not_press_key justumen "Maintenant créons un nouveau répertoire 'Room' dans notre ${voc}répertoire courant${reset} en faisant ${learn}mkdir Room${reset}."; restore=$(expr $restore + 1) ;&
78) echo -n 78 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; answer_run "mkdir Room" justumen "Non"; restore=$(expr $restore + 1) ;&
79) echo -n 79 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk_not_press_key justumen "Changeons de ${voc}répertoire courant${reset} avec ${learn}cd Room${reset}."; restore=$(expr $restore + 1) ;&
80) echo -n 80 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; answer_run "cd Room" justumen "Non"; restore=$(expr $restore + 1) ;&
81) echo -n 81 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk_not_press_key justumen "Maintenant, affichez le chemin absolu de votre ${voc}répertoire courant${reset}."; restore=$(expr $restore + 1) ;&
82) echo -n 82 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; answer_run "pwd" justumen "Non"; restore=$(expr $restore + 1) ;&
83) echo -n 83 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk_not_press_key justumen "Super, et maintenant affichez les éléments du ${voc}répertoire courant${reset}."; restore=$(expr $restore + 1) ;&
84) echo -n 84 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; answer_run "ls" justumen "Non"; restore=$(expr $restore + 1) ;&
85) echo -n 85 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Ici le dossier est vide, mais vous maitrisez maintenant les deux commandes les plus importantes : ${learn}pwd${reset} et ${learn}ls${reset}."; restore=$(expr $restore + 1) ;&
86) echo -n 86 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Les commandes ${learn}cd${reset} et ${learn}mkdir${reset} que nous avons vu ensemble sont plus complexes."; restore=$(expr $restore + 1) ;&
87) echo -n 87 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Il faut leur donner une cible, ou un nom comme par exemple : ${learn}mkdir Room${reset}."; restore=$(expr $restore + 1) ;&
88) echo -n 88 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Cette 'cible' est appelée un ${voc}argument${reset}!"; restore=$(expr $restore + 1) ;&
89) echo -n 89 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Mais il est aussi possible d'avoir des commandes avec plusieurs ${voc}arguments${reset}."; restore=$(expr $restore + 1) ;&
90) echo -n 90 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Il suffit de continuer à les séparer par des espaces."; restore=$(expr $restore + 1) ;&
91) echo -n 91 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk_not_press_key justumen "On va créer les dossiers 'bed', 'closet' et 'desk' en une seule commande. Tapez donc la commande : ${learn}mkdir bed closet desk${reset}"; restore=$(expr $restore + 1) ;&
92) echo -n 92 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; answer_run "mkdir bed closet desk" justumen "Non"; restore=$(expr $restore + 1) ;&
93) echo -n 93 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk_not_press_key justumen "Affichez les éléments du ${voc}répertoire courant${reset}."; restore=$(expr $restore + 1) ;&
94) echo -n 94 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; answer_run "ls" justumen "Non"; restore=$(expr $restore + 1) ;&
95) echo -n 95 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk_not_press_key justumen "Maintenant pour supprimer ces dossiers, vous pouvez taper : ${learn}rmdir bed closet desk${reset}. (rmdir vient de l'anglais ${learn}R${reset}e${learn}M${reset}ove ${learn}DIR${reset}ectory)"; restore=$(expr $restore + 1) ;&
96) echo -n 96 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; answer_run "rmdir bed closet desk" justumen "Non"; restore=$(expr $restore + 1) ;&
97) echo -n 97 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "${learn}rmdir${reset} est une commande plutôt innofensive, parce qu'elle refusera de supprimer un dossier si celui-ci n'est pas vide."; restore=$(expr $restore + 1) ;&
98) echo -n 98 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Ce qui peut empêcher de graves accidents. Si par exemple, vous faites par erreur ${learn}rmdir /home${reset}."; restore=$(expr $restore + 1) ;&
99) echo -n 99 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "La commande ${learn}rm${reset} est la commande pour supprimer des fichiers. (rm vient de l'anglais ${learn}R${reset}e${learn}M${reset}ove)"; restore=$(expr $restore + 1) ;&
100) echo -n 100 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; touch virus0 virus1 virus2 virus3 virus4; restore=$(expr $restore + 1) ;&
101) echo -n 101 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Tout comme ${learn}mkdir${reset}, il faudra lui donner en ${voc}argument${reset} le nom du fichier en question, par exemple : ${learn}rm test${reset}."; restore=$(expr $restore + 1) ;&
102) echo -n 102 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk_not_press_key justumen "Il vient de se passer quelque chose de bizarre... Affichez le contenu du ${voc}répertoire courant${reset}."; restore=$(expr $restore + 1) ;&
103) echo -n 103 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; answer_run "ls" justumen "Non"; restore=$(expr $restore + 1) ;&
104) echo -n 104 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk_not_press_key justumen "rmdir${reset} a bien supprimé les dossiers. Mais ces fichiers n'ont rien à faire ici, supprimez le fichier 'virus0' avec ${learn}rm virus0${reset}"; restore=$(expr $restore + 1) ;&
105) echo -n 105 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; answer_run "rm virus0" justumen "Non"; restore=$(expr $restore + 1) ;&
106) echo -n 106 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk_not_press_key justumen "Affichez à nouveau les éléments du ${voc}répertoire courant${reset}, pour voir s'il est toujours là."; restore=$(expr $restore + 1) ;&
107) echo -n 107 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; answer_run "ls" justumen "Non"; restore=$(expr $restore + 1) ;&
108) echo -n 108 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Super, virus0 n'existe plus."; restore=$(expr $restore + 1) ;&
109) echo -n 109 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Mais attention avec la commande ${learn}rm${reset}, c'est une commande dangereuse à ne pas utiliser à la légère."; restore=$(expr $restore + 1) ;&
110) echo -n 110 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Les fichiers sont supprimés directement, il ne vont pas dans une corbeille, donc soyez prudent."; restore=$(expr $restore + 1) ;&
111) echo -n 111 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Une erreur en ligne de commande ne pardonne pas."; restore=$(expr $restore + 1) ;&
112) echo -n 112 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Une faute de frappe ou un ${voc}répertoire courant${reset} innatendu peut avoir de graves conséquences."; restore=$(expr $restore + 1) ;&
113) echo -n 113 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Avant de lancer une commande, soyez donc sûrs de ce que vous faites."; restore=$(expr $restore + 1) ;&
114) echo -n 114 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "N'hésitez jamais a lancer ou relancer ${learn}pwd${reset} et ${learn}ls${reset} pour savoir quel est votre ${voc}répertoire courant${reset} et vérifier son contenu."; restore=$(expr $restore + 1) ;&
115) echo -n 115 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Mais nous avons encore d'autres 'virus' à supprimer. Mais on peut aussi les supprimer d'une autre manière."; restore=$(expr $restore + 1) ;&
116) echo -n 116 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Nous pouvons utiliser son ${voc}chemin absolu${reset}."; restore=$(expr $restore + 1) ;&
117) echo -n 117 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; cd ~/; restore=$(expr $restore + 1) ;&
118) echo -n 118 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Lorsque vous avez tapé ${learn}rm virus0${reset}, vous avez demandé la suppression du fichier 'virus0' dans votre ${voc}répertoire courant${reset}."; restore=$(expr $restore + 1) ;&
119) echo -n 119 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk_not_press_key justumen "Je viens de changer votre ${voc}répertoire courant${reset}. Affichez le maintenant."; restore=$(expr $restore + 1) ;&
120) echo -n 120 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; answer_run "pwd" justumen "Non"; restore=$(expr $restore + 1) ;&
121) echo -n 121 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk_not_press_key justumen "Affichez le contenu de votre ${voc}répertoire courant${reset}."; restore=$(expr $restore + 1) ;&
122) echo -n 122 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; answer_run "ls" justumen "Non"; restore=$(expr $restore + 1) ;&
123) echo -n 123 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Le fichier 'virus1', existe toujours dans le répertoire 'Room', mais étant donné votre ${voc}répertoire courant${reset}, vous ne pouvez pas lancer ${learn}rm virus1${reset}."; restore=$(expr $restore + 1) ;&
124) echo -n 124 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Heureusement, vous connaissez le ${voc}chemin absolu${reset} du fichier 'virus1' : ${learn}$HOME/House/Room/virus1${Reset}"; restore=$(expr $restore + 1) ;&
125) echo -n 125 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Vous pouvez utiliser son ${voc}chemin absolu${reset} comme ${voc}argument${reset}. Cette commande marchera donc quel que soit votre ${voc}répertoire courant${reset} !"; restore=$(expr $restore + 1) ;&
126) echo -n 126 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk_not_press_key justumen "Supprimez le avec cette commande : ${learn}rm $HOME/House/Room/virus1${reset}."; restore=$(expr $restore + 1) ;&
127) echo -n 127 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; answer_run "rm $HOME/House/Room/virus1" justumen "Non"; restore=$(expr $restore + 1) ;&
128) echo -n 128 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Maintenant, comment pouvoir vérifier si le fichier a bien été supprimé ?"; restore=$(expr $restore + 1) ;&
129) echo -n 129 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Lorsqu'une commande ne se passe pas comme prévue, elle vous renvoit très souvent une erreur."; restore=$(expr $restore + 1) ;&
130) echo -n 130 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk_not_press_key justumen "Essayez de supprimer le fichier 'virus1' à nouveau en utilisant son ${voc}chemin absolu${reset}."; restore=$(expr $restore + 1) ;&
131) echo -n 131 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; answer_run "rm $HOME/House/Room/virus1" justumen "Non"; restore=$(expr $restore + 1) ;&
132) echo -n 132 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Ici la commande ${learn}rm${reset} vous renvoit une erreur, le fichier n'existe donc déjà plus."; restore=$(expr $restore + 1) ;&
133) echo -n 133 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Maintenant, on peut aussi utiliser le ${voc}chemin absolu${reset} du dossier 'Room' pour afficher son contenu."; restore=$(expr $restore + 1) ;&
134) echo -n 134 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Vous connaissez déjà la commande ${learn}ls${reset}, pour lister le contenu du ${voc}répertoire courant${reset}."; restore=$(expr $restore + 1) ;&
135) echo -n 135 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Sans ${voc}argument${reset}, avec un simple ${learn}ls${reset}, le répertoire utilisé sera automatiquement le ${voc}répertoire courant${reset}."; restore=$(expr $restore + 1) ;&
136) echo -n 136 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Mais il est en fait aussi possible de donner un ${voc}argument${reset} à ${learn}ls${reset}."; restore=$(expr $restore + 1) ;&
137) echo -n 137 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Cet ${voc}argument${reset} représente le répertoire cible, par exemple ${learn}ls /${reset} affichera le contenu du ${voc}répertoire racine${reset}."; restore=$(expr $restore + 1) ;&
138) echo -n 138 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk_not_press_key justumen "Nous pouvons afficher le contenu du répertoire 'Room' sans se déplacer dans l'arborescence, avec cette commande : ${learn}ls $HOME/House/Room/${reset}."; restore=$(expr $restore + 1) ;&
139) echo -n 139 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; answer_run "ls $HOME/House/Room/" justumen "Non"; restore=$(expr $restore + 1) ;&
140) echo -n 140 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Excellent, le fichier 'virus1' n'existe plus."; restore=$(expr $restore + 1) ;&
141) echo -n 141 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Encore une fois, je vous rappelle que dans un ${voc}chemin absolu${reset}, si le dernier caractère est un '/', il n'est pas obligatoire."; restore=$(expr $restore + 1) ;&
142) echo -n 142 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk_not_press_key justumen "Donc ici le dernier '/' dans ${learn}$HOME/House/Room/${reset} n'est pas obligatoire. Testez donc à nouveau avec cette commande : ${learn}ls $HOME/House/Room${reset}"; restore=$(expr $restore + 1) ;&
143) echo -n 143 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; answer_run "ls $HOME/House/Room" justumen "Non"; restore=$(expr $restore + 1) ;&
144) echo -n 144 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Pas de problème, le résultat est le même pour ces deux commandes : ${learn}ls $HOME/House/Room/${reset} et ${learn}ls $HOME/House/Room${reset}."; restore=$(expr $restore + 1) ;&
145) echo -n 145 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Quand vous avez fait ${learn}rm virus0${reset} pour la première suppression, vous avez utilisé ce que l'on appelle le ${voc}chemin relatif${reset}."; restore=$(expr $restore + 1) ;&
146) echo -n 146 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "On dit que ce chemin est relatif parce qu'il dépend de votre ${voc}répertoire courant${reset}."; restore=$(expr $restore + 1) ;&
147) echo -n 147 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Imaginons deux fichiers 'virus' avec comme ${voc}chemin absolu${reset} : ${learn}/virus${reset} et ${learn}/bin/virus${reset}."; restore=$(expr $restore + 1) ;&
148) echo -n 148 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Si ${learn}pwd${reset} vous donne ${learn}$HOME${reset}. Un ${learn}rm virus${reset} ne supprimera aucun d'entre eux. Cette commande voudra supprimer le fichier avec ce chemin absolu : ${learn}$HOME/virus${reset}."; restore=$(expr $restore + 1) ;&
149) echo -n 149 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; cd "$HOME"; restore=$(expr $restore + 1) ;&
150) echo -n 150 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "D'ou la très grande utilité de ce ${voc}chemin absolu${reset}. Vous pouvez utiliser ${learn}rm /virus${reset} et ${learn}rm /bin/virus${reset} quel que soit votre ${voc}répertoire courant${reset}."; restore=$(expr $restore + 1) ;&
151) echo -n 151 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk_not_press_key justumen "Je viens de vous déplacer dans l'arborescence, affichez donc le chemin absolu du ${voc}répertoire courant${reset}."; restore=$(expr $restore + 1) ;&
152) echo -n 152 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; answer_run "pwd" justumen "Non"; restore=$(expr $restore + 1) ;&
153) echo -n 153 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Pour changer de ${voc}répertoire courant${reset}, vous pouvez utiliser la commande ${learn}cd${reset}."; restore=$(expr $restore + 1) ;&
154) echo -n 154 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Pour revenir dans le répertoire 'Room', vous pouvez utiliser son ${voc}chemin absolu${reset} : ${learn}cd $HOME/House/Room/${reset}"; restore=$(expr $restore + 1) ;&
155) echo -n 155 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Mais il n'est pas obligatoire d'utiliser son ${voc}chemin absolu${reset}, il est aussi possible de revenir dans le répertoire 'Room' en utilisant son ${voc}chemin relatif${reset}."; restore=$(expr $restore + 1) ;&
156) echo -n 156 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Vous voulez aller dans ${learn}$HOME/House/Room/${reset} mais vous êtes déjà dans ${learn}$HOME${reset}."; restore=$(expr $restore + 1) ;&
157) echo -n 157 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk_not_press_key justumen "Il est donc possible de se déplacer de là où vous êtes avec un ${learn}cd House/Room/${reset}. Allez-y."; restore=$(expr $restore + 1) ;&
158) echo -n 158 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; answer_run "cd House/Room/" justumen "Non"; restore=$(expr $restore + 1) ;&
159) echo -n 159 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk_not_press_key justumen "Affichez maintenant les éléments de votre ${voc}répertoire courant${reset}."; restore=$(expr $restore + 1) ;&
160) echo -n 160 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; answer_run "ls" justumen "Non"; restore=$(expr $restore + 1) ;&
161) echo -n 161 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk_not_press_key justumen "Ici vous voyez encore des fichiers virus, supprimez le fichier virus2 en utilisant le ${voc}chemin relatif${reset}."; restore=$(expr $restore + 1) ;&
162) echo -n 162 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; answer_run "rm virus2" justumen "Non"; restore=$(expr $restore + 1) ;&
163) echo -n 163 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Excellent!"; restore=$(expr $restore + 1) ;&
164) echo -n 164 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Nous avons vu dans l'exemple précédent que ${learn}cd House/Room/${reset} utilise un ${voc}chemin relatif${reset}, pourtant cette commande contient aussi des '/'."; restore=$(expr $restore + 1) ;&
165) echo -n 165 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Donc comment reconnaitre un ${voc}chemin absolu${reset} d'un ${voc}chemin relatif${reset} ?"; restore=$(expr $restore + 1) ;&
166) echo -n 166 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Le ${voc}chemin absolu${reset} est en fait très facile à reconnaitre !"; restore=$(expr $restore + 1) ;&
167) echo -n 167 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Il commence toujours à la racine, c'est à dire que le premier caractère d'un ${voc}chemin absolu${reset} est toujours un '/'."; restore=$(expr $restore + 1) ;&
168) echo -n 168 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Il y a aussi une syntaxe spéciale très utile pour le ${voc}chemin relatif${reset} : ${learn}..${reset}"; restore=$(expr $restore + 1) ;&
169) echo -n 169 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "${learn}..${reset} représente dans l'arborescence le parent du ${voc}répertoire courant${reset}."; restore=$(expr $restore + 1) ;&
170) echo -n 170 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "C'est le vocabulaire que nous employons pour parler de cette arborescence, ce sont des relations parents / enfants."; restore=$(expr $restore + 1) ;&
171) echo -n 171 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Par exemple pour ${learn}/home/user/test/${reset}, le dossier parent de test est user. Le dossier parent de user est home."; restore=$(expr $restore + 1) ;&
172) echo -n 172 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Et bien évidemment test est un enfant de user, et user est un enfant de home."; restore=$(expr $restore + 1) ;&
173) echo -n 173 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Cibler les enfants en ${voc}argument${reset} avec un ${voc}chemin relatif${reset} est très simple, il suffit d'écrire le nom de leurs parents successifs."; restore=$(expr $restore + 1) ;&
174) echo -n 174 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Comme par exemple avec la commande de tout a l'heure : ${learn}cd House/Room/${reet}"; restore=$(expr $restore + 1) ;&
175) echo -n 175 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Pour cibler les parents, c'est un peu plus compliqué. Il faut utiliser ${learn}..${reset}."; restore=$(expr $restore + 1) ;&
176) echo -n 176 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk_not_press_key justumen "Affichez donc le chemin absolu de votre ${voc}répertoire courant${reset}."; restore=$(expr $restore + 1) ;&
177) echo -n 177 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; answer_run "pwd" justumen "Non"; restore=$(expr $restore + 1) ;&
178) echo -n 178 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Vous connaissez aussi la commande pour changer de répertoire courant : ${learn}cd${reset}."; restore=$(expr $restore + 1) ;&
179) echo -n 179 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Ici nous allons nous déplacer dans le répertoire parent. Nous sommes dans ${learn}$HOME/House/Room/${reset} mais nous voulons aller dans ${learn}$HOME/House/${reset}"; restore=$(expr $restore + 1) ;&
180) echo -n 180 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk_not_press_key justumen "Il est possible de remonter d'un cran dans l'arborescence, ou comme je viens de le dire de se déplacer dans le répertoire parent avec un ${learn}cd ..${reset}"; restore=$(expr $restore + 1) ;&
181) echo -n 181 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; answer_run "cd .." justumen "Non"; restore=$(expr $restore + 1) ;&
182) echo -n 182 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk_not_press_key justumen "Affichez le chemin absolu du ${voc}répertoire courant${reset}."; restore=$(expr $restore + 1) ;&
183) echo -n 183 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; answer_run "pwd" justumen "Non"; restore=$(expr $restore + 1) ;&
184) echo -n 184 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "J'espère que le résultat de ${learn}pwd${reset} est logique pour vous."; restore=$(expr $restore + 1) ;&
185) echo -n 185 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk_not_press_key justumen "Mais il nous reste deux virus à supprimer, commençons par supprimer le fichier virus3 avec son ${voc}chemin relatif${reset}."; restore=$(expr $restore + 1) ;&
186) echo -n 186 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; answer_run "rm Room/virus3" justumen "Non"; restore=$(expr $restore + 1) ;&
187) echo -n 187 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk_not_press_key justumen "Bien ! Maintenant supprimons le fichier virus4 en utilisant son ${voc}chemin absolu${reset}."; restore=$(expr $restore + 1) ;&
188) echo -n 188 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; answer_run "rm $HOME/House/Room/virus4" justumen "Non"; restore=$(expr $restore + 1) ;&
189) echo -n 189 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; talk justumen "Parfait, vous avez tout compris ! Et je vous donne rendez-vous au questionnaire !"; restore=$(expr $restore + 1) ;&
190) echo -n 190 > $HOME/.GameScript/restore_bash1x; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1x; clean; restore=$(expr $restore + 1) ;&
esac
}
