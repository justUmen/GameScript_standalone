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
1) echo -n 1 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; [ -d "$HOME/.GameScript_bash9" ] && echo "Unexpected error, ${HOME}/.GameScript_bash9 already exists on your system! Delete this $HOME/.GameScript_bash9 folder and restart this script." && exit; restore=$(expr $restore + 1) ;&
2) echo -n 2 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; mkdir $HOME/.GameScript_bash9 2> /dev/null; restore=$(expr $restore + 1) ;&
3) echo -n 3 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; cd $HOME/.GameScript_bash9; restore=$(expr $restore + 1) ;&
4) echo -n 4 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; echo -e "echo Je suis code_bash\\npwd;ls\\nmkdir FOLDER">$HOME/.GameScript_bash9/code_bash;echo -e "echo Je suis code_bash2 et je ne fais rien de spécial.">$HOME/.GameScript_bash9/code_bash2;chmod +x $HOME/.GameScript_bash9/code_bash2; restore=$(expr $restore + 1) ;&
5) echo -n 5 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Bash can be used interactively, as we have done since chapter 1, but bash is also a programming language."; restore=$(expr $restore + 1) ;&
6) echo -n 6 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "So you can store all the commands you learned in a text file and ask 'bash' to launch them line by line."; restore=$(expr $restore + 1) ;&
7) echo -n 7 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Display your current directory and its contents with: ${learn}pwd; ls${reset}."; restore=$(expr $restore + 1) ;&
8) echo -n 8 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "Pwd, ls" justumen "No"; restore=$(expr $restore + 1) ;&
9) echo -n 9 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Display the contents of the 'code_bash' file."; restore=$(expr $restore + 1) ;&
10) echo -n 10 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "cat code_bash" justumen "No"; restore=$(expr $restore + 1) ;&
11) echo -n 11 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "This 'code_bash' file contains three command lines that you should understand."; restore=$(expr $restore + 1) ;&
12) echo -n 12 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "To launch the commands of this file 'code_bash', just give this file as an argument to the command ${voc}bash${reset}."; restore=$(expr $restore + 1) ;&
13) echo -n 13 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Do: ${learn}bash code_bash${reset}"; restore=$(expr $restore + 1) ;&
14) echo -n 14 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "bash code_bash" justumen "No"; restore=$(expr $restore + 1) ;&
15) echo -n 15 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "List the elements of the current directory."; restore=$(expr $restore + 1) ;&
16) echo -n 16 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "Ls" justumen "No"; restore=$(expr $restore + 1) ;&
17) echo -n 17 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Here 'bash' has created the folder 'FOLDER' with the command ${learn}mkdir FOLDER${reset} contained in the file 'code_bash'."; restore=$(expr $restore + 1) ;&
18) echo -n 18 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "You can also use all the other concepts that you have already learned in previous chapters."; restore=$(expr $restore + 1) ;&
19) echo -n 19 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "For example: ${learn}cat_code_bash | bash> / dev / null${reset}"; restore=$(expr $restore + 1) ;&
20) echo -n 20 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "cat code_bash | bash> / dev / null" justumen "No"; restore=$(expr $restore + 1) ;&
21) echo -n 21 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Here only the ${code}mkdir${reset} error is sent to the terminal, since the ${code}ls${reset} and ${code}pwd${reset} commands use the standard output."; restore=$(expr $restore + 1) ;&
22) echo -n 22 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "As a reminder, you could also do ${learn}cat_code_bash | bash -${reset} or use the absolute path of this file, with for example ${learn}bash ~ / .GameScript_bash9 / code_bash${reset}."; restore=$(expr $restore + 1) ;&
23) echo -n 23 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "To execute a file, you can also use ${code}./${reset} before the name of the file you want to launch."; restore=$(expr $restore + 1) ;&
24) echo -n 24 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Do: ${learn}./ code_bash2${reset}"; restore=$(expr $restore + 1) ;&
25) echo -n 25 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "./ code_bash2" justumen "No"; restore=$(expr $restore + 1) ;&
26) echo -n 26 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Do the same thing for 'code_bash'."; restore=$(expr $restore + 1) ;&
27) echo -n 27 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "./ code_bash" justumen "No"; restore=$(expr $restore + 1) ;&
28) echo -n 28 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Here using ${code}./${reset} we have a permission problem."; restore=$(expr $restore + 1) ;&
29) echo -n 29 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Strange because we had no problem with the command ${learn}bash code_bash${reset}."; restore=$(expr $restore + 1) ;&
30) echo -n 30 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Display the permissions of all items in the current directory that start with 'code'."; restore=$(expr $restore + 1) ;&
31) echo -n 31 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "ls -l code *" justumen "No"; restore=$(expr $restore + 1) ;&
32) echo -n 32 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "To execute a file with ${code}./${reset}, this file must have execute (x)."; restore=$(expr $restore + 1) ;&
33) echo -n 33 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "A text file will not have this permission by default, so you must add it manually."; restore=$(expr $restore + 1) ;&
34) echo -n 34 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Give the execution right on 'code_bash' for the owner of this file."; restore=$(expr $restore + 1) ;&
35) echo -n 35 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "chmod u + x code_bash" justumen "No"; restore=$(expr $restore + 1) ;&
36) echo -n 36 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "It can be said that when a text file becomes executable, it is transformed into a ${voc}script${reset} or ${voc}program${reset}."; restore=$(expr $restore + 1) ;&
37) echo -n 37 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "In other words: ${voc}A bash script is a simple text file containing bash commands.${reset}"; restore=$(expr $restore + 1) ;&
38) echo -n 38 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Now run 'code_bash' using ${code}./${reset}."; restore=$(expr $restore + 1) ;&
39) echo -n 39 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "./ code_bash" justumen "No"; restore=$(expr $restore + 1) ;&
40) echo -n 40 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "You may have noticed that ${code}./${reset} just replaces your current directory."; restore=$(expr $restore + 1) ;&
41) echo -n 41 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "This is indeed the case, to execute a file, just specify its path."; restore=$(expr $restore + 1) ;&
42) echo -n 42 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "You can also use its absolute path, so do: ${learn}~ / .GameScript_bash9 / code_bash${reset}"; restore=$(expr $restore + 1) ;&
43) echo -n 43 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "~ / .GameScript_bash9 / code_bash" justumen "No"; restore=$(expr $restore + 1) ;&
44) echo -n 44 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Be careful however when using the absolute path, the commands of the script will use your current directory, ${voc}not${reset} the folder where your script is located."; restore=$(expr $restore + 1) ;&
45) echo -n 45 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "For example, if you are in the '/ var' folder and you are doing ${learn}~ / .GameScript_bash9 / $_block_code, the ${learn}mkdir FOLDER${reset} command will want to create the '/ var' folder. / FOLDER."; restore=$(expr $restore + 1) ;&
46) echo -n 46 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "To avoid any surprises, I recommend using as often as possible, absolute paths in your scripts."; restore=$(expr $restore + 1) ;&
47) echo -n 47 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "In previous chapters we have seen that if you want to keep track of information, you can store it in a file, like ${code}ls> file${reset}."; restore=$(expr $restore + 1) ;&
48) echo -n 48 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "If this information does not need to be saved on your disk, we saw that it could also be sent directly to another command, such as ${code}ls | wc${reset}."; restore=$(expr $restore + 1) ;&
49) echo -n 49 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "But bash can also store certain information without having to create a new file."; restore=$(expr $restore + 1) ;&
50) echo -n 50 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Bash is able to store them in what is called a ${voc}variable${reset}."; restore=$(expr $restore + 1) ;&
51) echo -n 51 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "A variable is a symbolic name that is associated with a value."; restore=$(expr $restore + 1) ;&
52) echo -n 52 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9;  Name = bjornulf; restore=$(expr $restore + 1) ;&
53) echo -n 53 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "I just created for you a variable named 'name'."; restore=$(expr $restore + 1) ;&
54) echo -n 54 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Show the value of this variable with: ${learn}echo \ $ name${reset}"; restore=$(expr $restore + 1) ;&
55) echo -n 55 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "echo \ $ name" justumen "No"; restore=$(expr $restore + 1) ;&
56) echo -n 56 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "This ${code}\ $${reset} specifies that the following text is the name of a variable and should not be displayed as is."; restore=$(expr $restore + 1) ;&
57) echo -n 57 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "${code}echo name${reset} will of course display the word 'name' but ${code}echo \ $ name${reset} will show the value of the variable 'name'."; restore=$(expr $restore + 1) ;&
58) echo -n 58 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "To create a new variable, it will simply use the name, the symbol ${code}=${reset} followed by its value."; restore=$(expr $restore + 1) ;&
59) echo -n 59 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Let's create a new variable 'path' which will contain the text '/ var / log' with: ${learn}path = / var / log${reset}."; restore=$(expr $restore + 1) ;&
60) echo -n 60 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "Path = / var / log" justumen "No"; restore=$(expr $restore + 1) ;&
61) echo -n 61 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "For example, if your command contains spaces, you can use the ${learn}\ "${reset} and ${learn}'${reset} delimiters that we've already seen with the command ${code}echo${reset}."; restore=$(expr $restore + 1) ;&
62) echo -n 62 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "${learn}path = / var / log${reset} is equivalent to ${learn}path = \ "/ var / log \"${reset} and ${learn}path = '/ var / log'${reset}."; restore=$(expr $restore + 1) ;&
63) echo -n 63 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Let's now display the contents of this variable with: ${learn}echo \ $ path${reset}"; restore=$(expr $restore + 1) ;&
64) echo -n 64 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "echo \ $ way" justumen "No"; restore=$(expr $restore + 1) ;&
65) echo -n 65 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "The ${code}echo${reset} command simply displays the contents of this variable, but the variables can be used by all commands."; restore=$(expr $restore + 1) ;&
66) echo -n 66 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Display the contents of the folder ${code}/ var / log${reset} with: ${learn}ls \ $ path${reset}"; restore=$(expr $restore + 1) ;&
67) echo -n 67 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "ls \ $ way" justumen "No"; restore=$(expr $restore + 1) ;&
68) echo -n 68 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "When you made ${learn}path = / var / log${reset}, since the variable did not exist, it was created."; restore=$(expr $restore + 1) ;&
69) echo -n 69 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "To modify it, the syntax is exactly the same."; restore=$(expr $restore + 1) ;&
70) echo -n 70 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Modify the contents of the variable 'name' with: ${learn}name = bob${reset}"; restore=$(expr $restore + 1) ;&
71) echo -n 71 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "Name = bob" justumen "No"; restore=$(expr $restore + 1) ;&
72) echo -n 72 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Be careful not to make ${codeError} \ $ name = bob${reset}, the symbol ${code}\ $${reset} should be used ${voc}only${reset} when use of the variable, not when it is modified."; restore=$(expr $restore + 1) ;&
73) echo -n 73 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Now display the new contents of the variable 'name' with: ${learn}echo \ $ name${reset}."; restore=$(expr $restore + 1) ;&
74) echo -n 74 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "echo \ $ name" justumen "No"; restore=$(expr $restore + 1) ;&
75) echo -n 75 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Here the 'bjornulf' value no longer exists, your ${learn}name = bob${reset} command has just replaced it."; restore=$(expr $restore + 1) ;&
76) echo -n 76 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "You can also add text to the command ${code}echo${reset}, for example: ${learn}echo my name is \ $ name.${reset}"; restore=$(expr $restore + 1) ;&
77) echo -n 77 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "echo my name is \ $ name."; restore=$(expr $restore + 1) ;&
78) echo -n 78 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "As usual, the '.' being a special character, space is not needed."; restore=$(expr $restore + 1) ;&
79) echo -n 79 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Now try for example to add 'by' after this variable, to display 'bobby', with: ${learn}echo \ $ nameby${reset}"; restore=$(expr $restore + 1) ;&
80) echo -n 80 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "echo \ $ nameby" justumen "No"; restore=$(expr $restore + 1) ;&
81) echo -n 81 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Here 'by' gets mixed with the name of the variable, but the 'nameby' variable does not exist, so ${code}echo${reset} displays an empty string."; restore=$(expr $restore + 1) ;&
82) echo -n 82 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "To remedy this problem, for example, you can use the escape character after the name of the variable to clearly separate the next letter."; restore=$(expr $restore + 1) ;&
83) echo -n 83 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Try using the variable 'name' and the escape character to display: 'bobby'."; restore=$(expr $restore + 1) ;&
84) echo -n 84 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "echo \ $ name \\ by" justumen "No"; restore=$(expr $restore + 1) ;&
85) echo -n 85 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Be careful, you can only use the escape character outside the delimiters ${code}'${reset} and ${code}\ "${reset}."; restore=$(expr $restore + 1) ;&
86) echo -n 86 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "As I remind you, the escape character is used with delimiters to display line breaks, tabs. etc ..."; restore=$(expr $restore + 1) ;&
87) echo -n 87 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Another possibility is to set a limit to your variable name, using the ${code}{}${reset}."; restore=$(expr $restore + 1) ;&
88) echo -n 88 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Try doing: ${learn}echo \ ${name} by${reset}"; restore=$(expr $restore + 1) ;&
89) echo -n 89 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "echo \ ${name} by" justumen "No"; restore=$(expr $restore + 1) ;&
90) echo -n 90 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Perfect, now try ${learn}echo \ "\ ${name} by \"${reset}"; restore=$(expr $restore + 1) ;&
91) echo -n 91 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "echo \ "\ ${name} by \"" justumen "No"; restore=$(expr $restore + 1) ;&
92) echo -n 92 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "To display a ${code}\ $${reset}, simply make ${code}\\ $${reset}."; restore=$(expr $restore + 1) ;&
93) echo -n 93 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Do: ${learn}echo \ "\\\ $ name = \ $ name \"${reset}"; restore=$(expr $restore + 1) ;&
94) echo -n 94 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "echo \ "\\\ $ name = \ $ name \"" justumen "No"; restore=$(expr $restore + 1) ;&
95) echo -n 95 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "And finally try: ${learn}echo '\\\ $ name = \ $ name'${reset}"; restore=$(expr $restore + 1) ;&
96) echo -n 96 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "echo '\\\ $ name = \ $ name'" justumen "No"; restore=$(expr $restore + 1) ;&
97) echo -n 97 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Here the result is very different! All characters between ${code}'${reset} are displayed literally."; restore=$(expr $restore + 1) ;&
98) echo -n 98 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "The ${code}'${reset} are therefore very useful if you need to display characters that could have another meaning."; restore=$(expr $restore + 1) ;&
99) echo -n 99 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "You can also use all at the same time, try: ${learn}echo '\ ${name} =' \ "\ $ name. \" or \ $ name \\\ by.${reset}"; restore=$(expr $restore + 1) ;&
100) echo -n 100 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "echo '\ ${name} =' \ "\ $ name. \" or \ $ name \\ by." justumen "No"; restore=$(expr $restore + 1) ;&
101) echo -n 101 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "If you understand this order perfectly, you have understood everything."; restore=$(expr $restore + 1) ;&
102) echo -n 102 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "I repeat, the modification syntax of a variable is identical to that of its creation."; restore=$(expr $restore + 1) ;&
103) echo -n 103 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Be careful not to modify important variables by mistake thinking to create them."; restore=$(expr $restore + 1) ;&
104) echo -n 104 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Feel free to check with a ${code}echo${reset} if a variable with that name already exists."; restore=$(expr $restore + 1) ;&
105) echo -n 105 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Your environment has important variables called ${voc}environment variables${reset}."; restore=$(expr $restore + 1) ;&
106) echo -n 106 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Display your ${voc}environment variables${reset} with: ${learn}printenv${reset}."; restore=$(expr $restore + 1) ;&
107) echo -n 107 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "Printenv" justumen "No"; restore=$(expr $restore + 1) ;&
108) echo -n 108 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "One of the most important environment variables is 'PATH'. (Path English)"; restore=$(expr $restore + 1) ;&
109) echo -n 109 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "To display only the PATH variable, do: ${learn}printenv PATH${reset}"; restore=$(expr $restore + 1) ;&
110) echo -n 110 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "printenv PATH" justumen "No"; restore=$(expr $restore + 1) ;&
111) echo -n 111 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "'PATH' is a list of the absolute path of several folders that bash uses to simplify command calls."; restore=$(expr $restore + 1) ;&
112) echo -n 112 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "These folders are on one line and their absolute paths are separated by ${code}:${reset}."; restore=$(expr $restore + 1) ;&
113) echo -n 113 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "If your 'PATH' environment variable is set incorrectly, you may have difficulty running some commands."; restore=$(expr $restore + 1) ;&
114) echo -n 114 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Commands we have already seen together are actually stored in one of the 'PATH' variable folders."; restore=$(expr $restore + 1) ;&
115) echo -n 115 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "For example, to find where the ${code}date${reset} command is, make: ${learn}date type${reset}."; restore=$(expr $restore + 1) ;&
116) echo -n 116 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "type date" justumen "No"; restore=$(expr $restore + 1) ;&
117) echo -n 117 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "${code}type${reset} allows us to understand that calling the ${code}date${reset} command is actually ${code}/ bin / date${reset}."; restore=$(expr $restore + 1) ;&
118) echo -n 118 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Do: ${learn}date; / bin / date${reset}."; restore=$(expr $restore + 1) ;&
119) echo -n 119 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "Date; / bin / Date" justumen "No"; restore=$(expr $restore + 1) ;&
120) echo -n 120 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "It is possible for you to use the ${code}date${reset} command directly instead of typing ${code}/ bin / date${reset}, because the absolute path '/ bin' is in your variable ' PATH."; restore=$(expr $restore + 1) ;&
121) echo -n 121 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Be careful not to accidentally modify the contents of the variable 'PATH', some commands would become unusable!"; restore=$(expr $restore + 1) ;&
122) echo -n 122 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "To add content to a variable, simply add its name at the beginning of the modification."; restore=$(expr $restore + 1) ;&
123) echo -n 123 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "For example, to add ': ~ / .GameScript_bash9' to the variable 'PATH' do: ${learn}PATH = \ $ PATH: ~ / .GameScript_bash9${reset}"; restore=$(expr $restore + 1) ;&
124) echo -n 124 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "\ PATH = $ PATH: ~ /" justumen "No .GameScript_bash9"; restore=$(expr $restore + 1) ;&
125) echo -n 125 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Here ${code}\ $ PATH${reset} is simply treated as a string, corresponding to the contents of the variable 'PATH'."; restore=$(expr $restore + 1) ;&
126) echo -n 126 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "To which one adds thereafter the string ': ~ / .GameScript_bash9'."; restore=$(expr $restore + 1) ;&
127) echo -n 127 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Display the new contents of the variable 'PATH'."; restore=$(expr $restore + 1) ;&
128) echo -n 128 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "echo \ $ PATH" justumen "No"; restore=$(expr $restore + 1) ;&
129) echo -n 129 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Here you can see that '~ / .GameScript_bash9' has been added after the old version of 'PATH'."; restore=$(expr $restore + 1) ;&
130) echo -n 130 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "But the changes you make on the variables are valid ${voc}only${reset} for the bash session you are currently using."; restore=$(expr $restore + 1) ;&
131) echo -n 131 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Opening another terminal ${voc}will reset {{reset} important variables, such as 'PATH', and ${voc}will remove${reset} the others, as here the variables 'name' and 'path'."; restore=$(expr $restore + 1) ;&
132) echo -n 132 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "But for now, since the folder '~ / .GameScript_bash9' is in your environment variable 'PATH', you can just start the script 'code_bash' by typing 'code_bash'."; restore=$(expr $restore + 1) ;&
133) echo -n 133 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Start therefore 'code_bash'."; restore=$(expr $restore + 1) ;&
134) echo -n 134 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "Code_bash" justumen "No"; restore=$(expr $restore + 1) ;&
135) echo -n 135 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Move to the folder 'FOLDER'."; restore=$(expr $restore + 1) ;&
136) echo -n 136 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "cd FOLDER" justumen "No"; restore=$(expr $restore + 1) ;&
137) echo -n 137 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Start 'code_bash' again."; restore=$(expr $restore + 1) ;&
138) echo -n 138 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "Code_bash" justumen "No"; restore=$(expr $restore + 1) ;&
139) echo -n 139 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk_not_press_key justumen "Now do: ${learn}pwd; ls${reset}."; restore=$(expr $restore + 1) ;&
140) echo -n 140 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; answer_run "Pwd, ls" justumen "No"; restore=$(expr $restore + 1) ;&
141) echo -n 141 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "Here you should clearly understand the effects of relative paths in your scripts that I have spoken to before."; restore=$(expr $restore + 1) ;&
142) echo -n 142 > $HOME/.GameScript/restore_bash9; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash9; talk justumen "And we end with the questionnaire!"; restore=$(expr $restore + 1) ;&
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
  echo ""
  echo -e "\e[15;5;44m Bash 'Bourne Again SHell' : Quiz Chapter 9 \e[0m"
  echo -e "- The answer should be as short as possible, a good answer adding uneeded characters will be considered as wrong."
  echo -e "Example : If the answer is 'ls'. The answers 'ls .', 'ls ./' and 'ls ././' won't work."
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
