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
			0) if [[ $VIDEO == 0 ]]; then download_all_sounds; else download_all_videos; fi ;;
			1) 	if [ -f "$HOME/.GameScript/restore_$7$8" ];then
					echo "$HOME/.GameScript/restore_$7$8 existe, continuer ou recommencer le cours du début ?"
					while [ "$choice" != "1" ] || [ "$choice" != "2" ] || [ "$choice" != "3" ]; do
						echo -e "\\e[0;100m 1) \\e[0m Continuer"
						echo -e "\\e[0;100m 2) \\e[0m Recommencer"
						echo -e "\\e[0;100m 3) \\e[0m Retour"
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
		talk_not_press_key justumen "\\e[4;37mDésolé, réponse fausse ou trop longue. Je vous conseille de suivre / refaire le cours.\nSi vous pensez maitriser le contenu du cours, il y a surement un piège, relisez donc attentivement la question. :-)\nSi vous vous sentez vraiment bloqué, demandez de l'aide sur notre chat : https://rocket.bjornulf.org\\e[0m"
		#enter_chapter $CHAPTER_NAME $CHAPTER_NUMBER
		exit
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
	talk_not_press_key justumen "Pour débloquer '$1 $2' sur rocketchat (https://rocket.bjornulf.org), ouvrez une conversation privée avec '@boti' et copiez/collez :\n\t\e[97;42mpassword$PASS\e[0m"
	talk_not_press_key justumen "Pour débloquer '$1 $2' sur discord (https://discord.gg/25eRgvD), ouvrez le channel '#mots-de-passe-boti' et copiez/collez :\n\t\e[97;42mpassword$PASS\e[0m"
	#AUTOMATICALLY DO THIS ?
	touch "$HOME/.GameScript/good_$1$2" 2> /dev/null
	mkdir $HOME/.GameScript/passwords/ 2> /dev/null
	echo -n "$PASS" > "$HOME/.GameScript/passwords/$1$2"
	exit
}

function enter_chapter(){
	#Usage : enter_chapter bash 1 1 (first 1 is chapter, next one is for case)
	echo ""
	echo -e "\e[97;44m - $1, Chapitre $2 \e[0m"
	answer_quiz "Cours" "Questionnaire" "Retour" "4" "5" "6" "$1" "$2"
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
1) echo -n 1 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; [ -d "$HOME/.GameScript_bash5" ] && echo "Unexpected error, ${HOME}/.GameScript_bash5 already exists on your system! Delete this $HOME/.GameScript_bash5 folder and restart this script." && exit; restore=$(expr $restore + 1) ;&
2) echo -n 2 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; mkdir $HOME/.GameScript_bash5 2> /dev/null; restore=$(expr $restore + 1) ;&
3) echo -n 3 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; cd $HOME/.GameScript_bash5; restore=$(expr $restore + 1) ;&
4) echo -n 4 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; mkdir Folder;touch Folder/X;touch Folder/Y;chmod 644 Folder; restore=$(expr $restore + 1) ;&
5) echo -n 5 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; echo "a">f1;chmod 000 f1;echo "ab">f2;chmod 444 f2;echo "abc">f3;chmod 600 f3;echo "abcd">f4;chmod 777 f4; restore=$(expr $restore + 1) ;&
6) echo -n 6 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "In this chapter we return to the command ${code}ls${reset}, one of the most important command."; restore=$(expr $restore + 1) ;&
7) echo -n 7 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "And here we'll talk about its most important option: ${code}-l${reset}"; restore=$(expr $restore + 1) ;&
8) echo -n 8 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk_not_press_key justumen "You can type: ${learn}ls -l${reset}"; restore=$(expr $restore + 1) ;&
9) echo -n 9 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; answer_run "ls -l" justumen "No"; restore=$(expr $restore + 1) ;&
10) echo -n 10 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "With this option, ${code}ls${reset} gives us more informations about the elements of the current directory."; restore=$(expr $restore + 1) ;&
11) echo -n 11 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "At the beginning you have a string consisting of ${code}-${reset} and letters to the left of the first space of each line."; restore=$(expr $restore + 1) ;&
12) echo -n 12 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "The first character represents the type of the element."; restore=$(expr $restore + 1) ;&
13) echo -n 13 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "If it's a ${code}-${reset}, this item is a file, if it's a ${code}d${reset}, it's a folder."; restore=$(expr $restore + 1) ;&
14) echo -n 14 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "With this first character, it is clear that 'Folder' is a folder and the others are files."; restore=$(expr $restore + 1) ;&
15) echo -n 15 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "The other nine characters that follow represent the ${voc}permissions${reset} of the element in question."; restore=$(expr $restore + 1) ;&
16) echo -n 16 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "On modern operating systems, it is possible to have multiple users on the same computer."; restore=$(expr $restore + 1) ;&
17) echo -n 17 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "But some of your files may deserve protection."; restore=$(expr $restore + 1) ;&
18) echo -n 18 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "For example, it seems reasonable that your little sister can not delete your personal files."; restore=$(expr $restore + 1) ;&
19) echo -n 19 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "On the other hand, even if you do not want her to delete your files, you may need to give her permission to read them."; restore=$(expr $restore + 1) ;&
20) echo -n 20 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "These nine characters are used to define with precision the permissions you want."; restore=$(expr $restore + 1) ;&
21) echo -n 21 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "The 'minimal' permission is ${code}---------${reset} and the 'maximum' permission is ${code}rwxrwxrwx${reset}."; restore=$(expr $restore + 1) ;&
22) echo -n 22 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Every ${code}-${reset} means that some type of permission is ${voc}disabled${reset}."; restore=$(expr $restore + 1) ;&
23) echo -n 23 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "On the other hand, if you see a letter, it means that some type of permission is ${voc}activated${reset}."; restore=$(expr $restore + 1) ;&
24) echo -n 24 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "But each character must respect this order: ${code}rwxrwxrwx${reset}."; restore=$(expr $restore + 1) ;&
25) echo -n 25 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "That means that they will have only two possible states."; restore=$(expr $restore + 1) ;&
26) echo -n 26 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "The first character can be either a ${code}-${reset} or a ${code}r${reset}."; restore=$(expr $restore + 1) ;&
27) echo -n 27 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "This ${code}r${reset} comes from the word ${code}r${reset}ead and gives the permission to read the file."; restore=$(expr $restore + 1) ;&
28) echo -n 28 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "The second character can be either a ${code}-${reset} or a ${code}w${reset}."; restore=$(expr $restore + 1) ;&
29) echo -n 29 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "This ${code}w${reset} comes from the word ${code}w${reset}rite and gives the permission to write the file : modification and deletion."; restore=$(expr $restore + 1) ;&
30) echo -n 30 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "The third character can be either a ${code}-${reset} or a ${code}x${reset}."; restore=$(expr $restore + 1) ;&
31) echo -n 31 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "This ${code}x${reset} comes from the word e${code}x${reset}ecute and gives the permission to execute the file."; restore=$(expr $restore + 1) ;&
32) echo -n 32 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Every line, this three-character pattern ${code}rwx${reset} is repeated three times."; restore=$(expr $restore + 1) ;&
33) echo -n 33 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "The first three characters are the permissions of the ${voc}owner${reset} of the file."; restore=$(expr $restore + 1) ;&
34) echo -n 34 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Example: -${codeFile}rw-${reset}r----- 2 ${codeFile}albert${reset} EinsteinFamily 4096 Feb 19 00:51 Example"; restore=$(expr $restore + 1) ;&
35) echo -n 35 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "The name of the owner of the 'Example' file is here 'albert'."; restore=$(expr $restore + 1) ;&
36) echo -n 36 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "The three characters in green here are albert's permissions."; restore=$(expr $restore + 1) ;&
37) echo -n 37 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Example: -rw-${codeFile}r--${reset}--- 2 albert ${codeFile} EinsteinFamily${reset} 4096 Feb 19 00:51 Example"; restore=$(expr $restore + 1) ;&
38) echo -n 38 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Here the three characters in green are the permissions of the members of the ${voc}group${reset} 'EinsteinFamily'."; restore=$(expr $restore + 1) ;&
39) echo -n 39 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Here you can imagine the existence of a group 'EinsteinFamily' for the members of Einstein's family."; restore=$(expr $restore + 1) ;&
40) echo -n 40 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Example: -rw-r--${codeFile}---${reset} 2 albert EinsteinFamily 4096 Feb 19 00:51 Example"; restore=$(expr $restore + 1) ;&
41) echo -n 41 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "And finally, the last three characters are the permissions of all the other users."; restore=$(expr $restore + 1) ;&
42) echo -n 42 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Those who are neither albert nor part of the group "EinsteinFamily"."; restore=$(expr $restore + 1) ;&
43) echo -n 43 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "In this example, albert, the owner of the file has the permission to read with this ${code}r${reset} and the permission to write with this ${code}w${reset}, but not the right to execute the file, because the third character is not a ${codeError}x${reset} but a ${code}-${reset}."; restore=$(expr $restore + 1) ;&
44) echo -n 44 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Members of the 'EinsteinFamily' group are only allowed to read this file with this ${code}r${reset}."; restore=$(expr $restore + 1) ;&
45) echo -n 45 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "They do not have the permission to modify or delete it because there is no ${code}w${reset}!"; restore=$(expr $restore + 1) ;&
46) echo -n 46 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "The rest of the users have no permission at all on this file, because there is no letter for them. Only ${codeFile}---${reset}."; restore=$(expr $restore + 1) ;&
47) echo -n 47 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk_not_press_key justumen "Now that you understand this, launch the command ${learn}ls -l${reset} again."; restore=$(expr $restore + 1) ;&
48) echo -n 48 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; answer_run "ls -l" justumen "No"; restore=$(expr $restore + 1) ;&
49) echo -n 49 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "On a simple system, it's likely that you have a group similar to your username, but that's not a problem."; restore=$(expr $restore + 1) ;&
50) echo -n 50 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "There are many possible permission combinations, here we have 'f1' with the minimum permissions: ${code}---------${reset}."; restore=$(expr $restore + 1) ;&
51) echo -n 51 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "We have 'f4' with the maximum permissions: ${code}rwxrwxrwx${reset}."; restore=$(expr $restore + 1) ;&
52) echo -n 52 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "And we have other combinations of permissions for the other elements."; restore=$(expr $restore + 1) ;&
53) echo -n 53 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk_not_press_key justumen "Let's start by displaying the content of the file 'f1'."; restore=$(expr $restore + 1) ;&
54) echo -n 54 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; answer_run "cat f1" justumen "No"; restore=$(expr $restore + 1) ;&
55) echo -n 55 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "And yes... it is not possible to display the content of this file because you do not have the right to read it."; restore=$(expr $restore + 1) ;&
56) echo -n 56 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "To use the ${code}cat${reset} command, you will need a ${code}r${reset} instead of this red dash: -${codeError}-${reset}--------."; restore=$(expr $restore + 1) ;&
57) echo -n 57 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk_not_press_key justumen "On the file 'f2', you have this 'r' in: -${code}r${reset}--r--r-- which gives you the right to read. View the content of 'f2'."; restore=$(expr $restore + 1) ;&
58) echo -n 58 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; answer_run "cat f2" justumen "No"; restore=$(expr $restore + 1) ;&
59) echo -n 59 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Here no problem with this command that reads the file."; restore=$(expr $restore + 1) ;&
60) echo -n 60 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk_not_press_key justumen "Now, try to add the text 'cd' at the end of the file 'f2'."; restore=$(expr $restore + 1) ;&
61) echo -n 61 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; answer_run "echo cd>>f2" justumen "No"; restore=$(expr $restore + 1) ;&
62) echo -n 62 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Here we have another permission problem."; restore=$(expr $restore + 1) ;&
63) echo -n 63 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "This time we have a missing ${code}w${reset} instead of this red dash: -r${codeError}-${reset}-r--r--."; restore=$(expr $restore + 1) ;&
64) echo -n 64 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "But the file 'f3' seems to have both ${code}r${reset} and ${code}w${reset}."; restore=$(expr $restore + 1) ;&
65) echo -n 65 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk_not_press_key justumen "Display the permissions of 'f3' with the name of the file as argument: ${learn}ls -l f3${reset}."; restore=$(expr $restore + 1) ;&
66) echo -n 66 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; answer_run "ls -l f3" justumen "No"; restore=$(expr $restore + 1) ;&
67) echo -n 67 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk_not_press_key justumen "Display the content of 'f3'."; restore=$(expr $restore + 1) ;&
68) echo -n 68 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; answer_run "cat f3" justumen "No"; restore=$(expr $restore + 1) ;&
69) echo -n 69 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk_not_press_key justumen "Add 'def' to the 'f3' file."; restore=$(expr $restore + 1) ;&
70) echo -n 70 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; answer_run "echo def>>f3" justumen "No"; restore=$(expr $restore + 1) ;&
71) echo -n 71 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk_not_press_key justumen "And display the content of 'f3' again."; restore=$(expr $restore + 1) ;&
72) echo -n 72 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; answer_run "cat f3" justumen "No"; restore=$(expr $restore + 1) ;&
73) echo -n 73 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Perfect ! We can finally use the commands we have learned before."; restore=$(expr $restore + 1) ;&
74) echo -n 74 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "But we never had this permission problem in previous chapters ..."; restore=$(expr $restore + 1) ;&
75) echo -n 75 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "I actually just simulated them for you here..."; restore=$(expr $restore + 1) ;&
76) echo -n 76 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "You already know how to create a text file with ${code}echo${reset}."; restore=$(expr $restore + 1) ;&
77) echo -n 77 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk_not_press_key justumen "But you can also use the ${code}touch${reset} command, like so: ${learn}touch file${reset}"; restore=$(expr $restore + 1) ;&
78) echo -n 78 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; answer_run "touch file" justumen "No"; restore=$(expr $restore + 1) ;&
79) echo -n 79 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Now we can take a look at the default permissions when creating a new file."; restore=$(expr $restore + 1) ;&
80) echo -n 80 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk_not_press_key justumen "To have the permissions of 'file', do ${learn}ls -l file${reset}"; restore=$(expr $restore + 1) ;&
81) echo -n 81 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; answer_run "ls -l file" justumen "No"; restore=$(expr $restore + 1) ;&
82) echo -n 82 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "If the file was created by you, you will have the right to read and write by default."; restore=$(expr $restore + 1) ;&
83) echo -n 83 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Be careful though, if this file wasn't created by you, it may have limited or unexpected permissions."; restore=$(expr $restore + 1) ;&
84) echo -n 84 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "We can see here the name of the owner of the file, but is it really you ?"; restore=$(expr $restore + 1) ;&
85) echo -n 85 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk_not_press_key justumen "To know your username, you can type: ${learn}whoami${reset}"; restore=$(expr $restore + 1) ;&
86) echo -n 86 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; answer_run "whoami" justumen "No"; restore=$(expr $restore + 1) ;&
87) echo -n 87 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "This command being very close to the sentence 'Who am I?', it is indeed very easy to remember."; restore=$(expr $restore + 1) ;&
88) echo -n 88 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Here your name and the name of the owner of this file are the same."; restore=$(expr $restore + 1) ;&
89) echo -n 89 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "You may think that you are the only user on your computer, but there is at least one more !"; restore=$(expr $restore + 1) ;&
90) echo -n 90 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "This user has the life and death permissions of everything that exists in your system ..."; restore=$(expr $restore + 1) ;&
91) echo -n 91 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "It is your administrator's account, better known as ${voc}root${reset}."; restore=$(expr $restore + 1) ;&
92) echo -n 92 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Traditionally, your personal files must be stored in: /home/yourname"; restore=$(expr $restore + 1) ;&
93) echo -n 93 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "And you should be in control of everything that's going on inside it."; restore=$(expr $restore + 1) ;&
94) echo -n 94 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "But as a simple user, you can only control the items in this directory!"; restore=$(expr $restore + 1) ;&
95) echo -n 95 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk_not_press_key justumen "Try to show the permissions of another folder, the root directory for example: ${learn}ls -l /${reset}"; restore=$(expr $restore + 1) ;&
96) echo -n 96 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; answer_run "ls -l /" justumen "No"; restore=$(expr $restore + 1) ;&
97) echo -n 97 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Here we see that the owner of these elements is ${voc}root${reset}."; restore=$(expr $restore + 1) ;&
98) echo -n 98 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "You are not ${voc}root${reset}, so the first three characters of permissions do not apply to you. : d${codeError}rwx${reset}r-xr-x"; restore=$(expr $restore + 1) ;&
99) echo -n 99 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "You are also not part of the group: drwx${codeError}r-x${reset}r-x"; restore=$(expr $restore + 1) ;&
100) echo -n 100 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "The permissions that concern you are the last three: drwxr-x${codeFile}r-x${reset}"; restore=$(expr $restore + 1) ;&
101) echo -n 101 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "You have the permission to read ${codeFile}r${reset} and execute ${codeFile}x${reset}."; restore=$(expr $restore + 1) ;&
102) echo -n 102 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "But what about this ${voc}execution permission${reset} ?"; restore=$(expr $restore + 1) ;&
103) echo -n 103 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk_not_press_key justumen "Show the permissions of the items in your current directory again."; restore=$(expr $restore + 1) ;&
104) echo -n 104 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; answer_run "ls -l" justumen "No"; restore=$(expr $restore + 1) ;&
105) echo -n 105 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Here we have a folder with the permissions of reading and writing."; restore=$(expr $restore + 1) ;&
106) echo -n 106 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk_not_press_key justumen "Let's go back into this folder."; restore=$(expr $restore + 1) ;&
107) echo -n 107 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; answer_run "cd File" justumen "No"; restore=$(expr $restore + 1) ;&
108) echo -n 108 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Here, despite having the right to read this folder, we can not move in it."; restore=$(expr $restore + 1) ;&
109) echo -n 109 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "For a text file, the ${codeFile}x${reset} permission doesn't have any effect ..."; restore=$(expr $restore + 1) ;&
110) echo -n 110 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "But here with a ${voc}folder${reset}, the ${codeFile}x${reset} plays an important role !"; restore=$(expr $restore + 1) ;&
111) echo -n 111 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Strangely, we have the right to read with this d${codeFile}r${reset}w-r-r--"; restore=$(expr $restore + 1) ;&
112) echo -n 112 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk_not_press_key justumen "So we can display the elements of this folder, try to do it."; restore=$(expr $restore + 1) ;&
113) echo -n 113 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; answer_run "ls Folder" justumen "No"; restore=$(expr $restore + 1) ;&
114) echo -n 114 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "The content of 'Folder' is displayed without problem. It contains an 'X' file and a 'Y' file."; restore=$(expr $restore + 1) ;&
115) echo -n 115 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk_not_press_key justumen "Let's now display the permissions of the files in this folder."; restore=$(expr $restore + 1) ;&
116) echo -n 116 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; answer_run "ls -l Folder" justumen "No"; restore=$(expr $restore + 1) ;&
117) echo -n 117 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Here the absence of ${codeFile}x${reset} in the permissions of 'Folder' prevents us from accessing the details."; restore=$(expr $restore + 1) ;&
118) echo -n 118 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "So be careful with these permissions!"; restore=$(expr $restore + 1) ;&
119) echo -n 119 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "If something does not go as planned, you may just have a permission issue to fix."; restore=$(expr $restore + 1) ;&
120) echo -n 120 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "This is what we will see now : How can we change these permissions ?"; restore=$(expr $restore + 1) ;&
121) echo -n 121 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "So in the first place you must be able to identify the permission you are missing !"; restore=$(expr $restore + 1) ;&
122) echo -n 122 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "For example, the ${code}cat${reset} command needs read permission: ${codeFile}r${reset}."; restore=$(expr $restore + 1) ;&
123) echo -n 123 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "The file 'f1' does not give us this permission, so we can't display it."; restore=$(expr $restore + 1) ;&
124) echo -n 124 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "To change these permissions, you will have to use the command: ${code}chmod${reset}."; restore=$(expr $restore + 1) ;&
125) echo -n 125 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "You will have to memorize 3 new letters :"; restore=$(expr $restore + 1) ;&
126) echo -n 126 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "${code}u${reset} for ${code}u${reset}ser or owner: -${codeFile}rwx${reset}rwxrwx"; restore=$(expr $restore + 1) ;&
127) echo -n 127 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "${code}g${reset} for the ${code}g${reset}roup: -rwx${codeFile}rwx${reset}rwx"; restore=$(expr $restore + 1) ;&
128) echo -n 128 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "and ${code}o${reset} for '${code}o${reset}thers', the English of 'others': -rwxrwx${codeFile}rwx${reset}"; restore=$(expr $restore + 1) ;&
129) echo -n 129 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "You can then use these letters in conjunction with the letters 'r', 'w' and 'x' you already know."; restore=$(expr $restore + 1) ;&
130) echo -n 130 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "You must also use the symbols ${code}+${reset} and ${code}-${reset}, to add or remove a permission."; restore=$(expr $restore + 1) ;&
131) echo -n 131 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk_not_press_key justumen "Display the permissions again with : ${learn}ls -l${reset}"; restore=$(expr $restore + 1) ;&
132) echo -n 132 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; answer_run "ls -l" justumen "No"; restore=$(expr $restore + 1) ;&
133) echo -n 133 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "And let's take an example : How can we allow the display of 'f1' for ourself ?"; restore=$(expr $restore + 1) ;&
134) echo -n 134 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "In other words: transform ---------- into -r--------."; restore=$(expr $restore + 1) ;&
135) echo -n 135 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "First we want to change the permissions of the owner, so we will use the letter ${code}u${reset}."; restore=$(expr $restore + 1) ;&
136) echo -n 136 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "We want to add a permission, so use the symbol ${code}+${reset}."; restore=$(expr $restore + 1) ;&
137) echo -n 137 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "We want the permission to read, so we will use the letter ${code}r${reset}."; restore=$(expr $restore + 1) ;&
138) echo -n 138 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "And the target of chmod will be the file 'f1'."; restore=$(expr $restore + 1) ;&
139) echo -n 139 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "The complete syntax will be: ${learn}chmod u + r f1${reset}"; restore=$(expr $restore + 1) ;&
140) echo -n 140 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk_not_press_key justumen "Before running this command, try to display the contents of 'f1'."; restore=$(expr $restore + 1) ;&
141) echo -n 141 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; answer_run "cat f1" justumen "No"; restore=$(expr $restore + 1) ;&
142) echo -n 142 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk_not_press_key justumen "Let's add the permission to read on 'f1' for the owner with: ${learn}chmod u+r f1${reset}"; restore=$(expr $restore + 1) ;&
143) echo -n 143 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; answer_run "chmod u+r f1" justumen "No"; restore=$(expr $restore + 1) ;&
144) echo -n 144 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk_not_press_key justumen "Display the new permissions with : ${learn}ls -l${reset}"; restore=$(expr $restore + 1) ;&
145) echo -n 145 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; answer_run "ls -l" justumen "No"; restore=$(expr $restore + 1) ;&
146) echo -n 146 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Here we have: -r-------- for the file 'f1'."; restore=$(expr $restore + 1) ;&
147) echo -n 147 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk_not_press_key justumen "And finally, display the file 'f1'."; restore=$(expr $restore + 1) ;&
148) echo -n 148 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; answer_run "cat f1" justumen "No"; restore=$(expr $restore + 1) ;&
149) echo -n 149 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "So you can use any combination you want: ${learn}u+r${reset}, ${learn}g-w${reset}, ${learn}u+x${reset}, etc ..."; restore=$(expr $restore + 1) ;&
150) echo -n 150 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "But you can also combine them with others, for example to give the owner the right to read AND write, you can do: ${learn}u+rw${reset}."; restore=$(expr $restore + 1) ;&
151) echo -n 151 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "To remove group members and others from the write privilege, you can do this: ${learn}go-w${reset}"; restore=$(expr $restore + 1) ;&
152) echo -n 152 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Or to give all rights to everyone, you can do: ${learn}ugo+rwx${reset}."; restore=$(expr $restore + 1) ;&
153) echo -n 153 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Or take away everyone's rights with ${learn}ugo-rwx${reset}."; restore=$(expr $restore + 1) ;&
154) echo -n 154 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Before going on to the quiz, I want to remind you that the writing permission also gives the permission of ${voc}deletion${reset}."; restore=$(expr $restore + 1) ;&
155) echo -n 155 > $HOME/.GameScript/restore_bash5; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash5; talk justumen "Good luck with the quiz !"; restore=$(expr $restore + 1) ;&
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
	rm $HOME/.GameScript_bash5/Folder/X 2> /dev/null
	rm $HOME/.GameScript_bash5/Folder/Y 2> /dev/null
	rmdir $HOME/.GameScript_bash5/Folder 2> /dev/null
	rmdir $HOME/.GameScript_bash5 2> /dev/null
}

function start_quiz(){
  echo ""
  echo -e "\e[15;5;44m Bash 'Bourne Again SHell' : Quiz Chapter 5 \e[0m"
  echo -e "- The answer should be as short as possible, a good answer adding uneeded characters will be considered as wrong."
  echo -e "Example : If the answer is 'ls'. The answers 'ls .', 'ls ./' and 'ls ././' won't work."
  answer_text_fr "How to display the permissions of all the elements in your user directory ?" "ls -l ~"
  answer_text_fr "Which letter represents a folder in the result of : 'ls -l' ?" "d"
  answer_text_fr "Which symbol represents a file in the result of 'ls -l' ?" "-"
  answer_text_fr "Which letter represents the permission to write in the result of 'ls -l' ?" "w"
  answer_text_fr "Which letter represents the permission to read in the result of 'ls -l' ?" "r"
  answer_text_fr "Which letter represents the permission to execute in the result of 'ls -l' ?" "x"
  answer_text_fr "Which command is able to change the file's permissions ?" "chmod"
  answer_text_fr "Which letter represents the owner for the command 'chmod' ?" "u"
  answer_text_fr "How to remove the permission to write for the owner on the file 'test' ?" "chmod u-r test"
  answer_text_fr "How to add the permission to execute on the file 'test' to all users except for the owner ?" "chmod go+x test"
  unlock "bash" "5" "28ab" "3d4e"
}


CHAPTER_NAME="bash"
CHAPTER_NUMBER="5"
LANGUAGE="en"
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
