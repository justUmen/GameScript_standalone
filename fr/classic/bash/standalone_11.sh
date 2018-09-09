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
	VOICE_PID=$(ps -|grep "$SOUNDPLAYER"|grep -v grep|grep -v MUSIC|awk '{print $2}')
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
1) echo -n 1 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; [ -d "$HOME/.GameScript_bash11" ] && echo "Erreur inattendue, ${HOME}/.GameScript_bash11 existe déjà sur votre système ! Supprimez ce dossier $HOME/.GameScript_bash11 et relancez ce script." && exit; restore=$(expr $restore + 1) ;&
2) echo -n 2 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; mkdir $HOME/.GameScript_bash11 2> /dev/null; restore=$(expr $restore + 1) ;&
3) echo -n 3 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; cd $HOME/.GameScript_bash11; restore=$(expr $restore + 1) ;&
4) echo -n 4 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; echo -e 'echo -n void=\nread void\necho $void' > $HOME/.GameScript_bash11/CODE;echo -e 'read X;if [ $X -eq 1 ];then echo COURS;else echo QUESTIONNAIRE;fi' > $HOME/.GameScript_bash11/if1;echo -e 'read X\nif\n[ $X -eq 1 ]\nthen\necho COURS\nelse\necho QUESTIONNAIRE\nfi' > $HOME/.GameScript_bash11/if2;echo -e 'read X\nif [ $X -eq 1 ]\nthen\n\techo COURS\nelse\n\techo QUESTIONNAIRE\nfi' > $HOME/.GameScript_bash11/if3;echo -e 'read X\nif [ $X -eq 1 ]\nthen\n\techo COURS\nfi\necho TEXTE' > $HOME/.GameScript_bash11/if4;echo -e 'read X\n[ $X -eq 1 ]&&echo COURS||echo QUESTIONNAIRE' > $HOME/.GameScript_bash11/if5;echo -e 'X=11;if [ $X -gt 5 ];then echo h;if [ $X -lt 10 ];then echo o;if [ $X -eq 8 ];then echo i;else echo f;fi else echo e;if [ $X -lt 11 ];then echo o;else echo y;fi fi else if [ $X -lt 3 ];then echo o;if [ $X -eq 1 ];then echo l;else echo u;fi else echo x;fi fi' > $HOME/.GameScript_bash11/if6;echo -e 'X=11\nif [ $X -gt 5 ];then\n\techo h\n\tif [ $X -lt 10 ];then\n\t\techo o\n\t\tif [ $X -eq 8 ];then\n\t\t\techo i\n\t\telse\n\t\t\techo f\n\t\tfi\n\telse\n\t\techo e\n\t\tif [ $X -lt 11 ];then\n\t\t\techo o\n\t\telse\n\t\t\techo y\n\t\tfi\n\tfi\nelse\n\tif [ $X -lt 3 ];then\n\t\techo o\n\t\tif [ $X -eq 1 ];then\n\t\t\techo l\n\t\telse\n\t\t\techo u\n\t\tfi\n\telse\n\t\techo x\n\tfi\nfi' > $HOME/.GameScript_bash11/if7;echo -e 'X=7\nif [ $X -gt 5 ];then\n\techo h\n\tif [ $X -lt 10 ];then\n\t\techo o\n\t\tif [ $X -eq 8 ];then\n\t\t\techo i\n\t\telse\n\t\t\techo f\n\t\tfi\n\telse\n\t\techo e\n\t\tif [ $X -lt 11 ];then\n\t\t\techo o\n\t\telse\n\t\t\techo y\n\t\tfi\n\tfi\nelse\n\tif [ $X -lt 3 ];then\n\t\techo o\n\t\tif [ $X -eq 1 ];then\n\t\t\techo l\n\t\telse\n\t\t\techo u\n\t\tfi\n\telse\n\t\techo x\n\tfi\nfi' > $HOME/.GameScript_bash11/if8; restore=$(expr $restore + 1) ;&
5) echo -n 5 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Avec 'bash', il par exemple possible de demander une valeur à l'utilisateur, pour donner à votre script une certaine interactivité."; restore=$(expr $restore + 1) ;&
6) echo -n 6 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Pour cela il faudra utiliser la commande ${code}read${reset}, qui prendra en argument le nom de la variable où sera stocké la valeur donnée."; restore=$(expr $restore + 1) ;&
7) echo -n 7 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Pour demander la valeur de la variable NAME à l'utilisateur, il suffira de faire ${learn}read NAME${reset} (l'anglais de lire)"; restore=$(expr $restore + 1) ;&
8) echo -n 8 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "${code}read${reset} attendra qu'une valeur soit donnée et que la touche Entrée soit pressée pour continuer."; restore=$(expr $restore + 1) ;&
9) echo -n 9 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk_not_press_key justumen "Essayez donc de demander la valeur de la variable 'NAME' avec ${learn}read NAME${reset}, donnez lui une valeur quelconque, puis validez avec la touche entrée."; restore=$(expr $restore + 1) ;&
10) echo -n 10 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; answer_run "read NAME" justumen "Non"; restore=$(expr $restore + 1) ;&
11) echo -n 11 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk_not_press_key justumen "Affichez maintenant la valeur de la variable 'NAME'."; restore=$(expr $restore + 1) ;&
12) echo -n 12 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; answer_run "echo \$NAME" justumen "Non"; restore=$(expr $restore + 1) ;&
13) echo -n 13 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Nous avons déjà vu que pour créer un script bash, il suffisait d'écrire les commandes que vous voulez exécuter dans un fichier texte."; restore=$(expr $restore + 1) ;&
14) echo -n 14 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Les commandes seront alors lancés les unes après les autres lorsque vous donnez ce fichier en argument à la commande 'bash'."; restore=$(expr $restore + 1) ;&
15) echo -n 15 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Si la commande ${code}read${reset} est utilisée dans un script, elle mettra ce script en pause tant qu'elle n'aura pas reçu une valeur pour sa variable."; restore=$(expr $restore + 1) ;&
16) echo -n 16 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk_not_press_key justumen "Affichez donc le contenu du fichier 'CODE'."; restore=$(expr $restore + 1) ;&
17) echo -n 17 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; answer_run "cat CODE" justumen "Non"; restore=$(expr $restore + 1) ;&
18) echo -n 18 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk_not_press_key justumen "Faites maintenant : ${learn}bash CODE${reset}, il vous faudra donner une valeur à 'void' pour continuer."; restore=$(expr $restore + 1) ;&
19) echo -n 19 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; answer_run "bash CODE" justumen "Non"; restore=$(expr $restore + 1) ;&
20) echo -n 20 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Ici vous voyez bien que la première commande ${learn}echo -n void=${reset} se lance avant la commande read, mais que la deuxième commande ${learn}echo \$void${reset} attendra la fin de la commande ${code}read${reset} avant de se lancer."; restore=$(expr $restore + 1) ;&
21) echo -n 21 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "A chaque fois que GameScript vous demande de taper quelque chose après ce \e[97;45m # \e[0m, c'est en fait cette commande ${code}read${reset} qui est utilisée !"; restore=$(expr $restore + 1) ;&
22) echo -n 22 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Mais Bash est aussi capable de créer des scripts plus complexes qu'une simple succession de commande."; restore=$(expr $restore + 1) ;&
23) echo -n 23 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Par exemple, lorque Gamescript vous demande de taper quelque chose, il vérifie si le contenu que vous avez tapé correspond à la commande qui vous a été demandé."; restore=$(expr $restore + 1) ;&
24) echo -n 24 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Si vous faites une erreur ou une faute de frappe, GameScript ne vous laissera pas continuer."; restore=$(expr $restore + 1) ;&
25) echo -n 25 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Pour avoir cet effet, un script bash utilise des ${voc}conditions${reset}, avec une combinaison de plusieurs commandes : ${code}if${reset}, ${code}then${reset}, ${code}else${reset} et ${code}fi${reset}."; restore=$(expr $restore + 1) ;&
26) echo -n 26 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Avec ces ${voc}conditions${reset}, il est possible de contrôler avec précision le comportement de votre script."; restore=$(expr $restore + 1) ;&
27) echo -n 27 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "GameScript utilise régulièrement cette combinaison ${code}if{reset}/${code}then{reset}/${code}else{reset}/${code}fi${reset} pour décider quelles commandes doivent être lancées et quelles commandes ne doivent pas l'être."; restore=$(expr $restore + 1) ;&
28) echo -n 28 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk_not_press_key justumen "Voyons notre premier exemple, affichez le contenu du fichier 'if1'."; restore=$(expr $restore + 1) ;&
29) echo -n 29 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; answer_run "cat if1" justumen "Non"; restore=$(expr $restore + 1) ;&
30) echo -n 30 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Ici nous avons un exemple de l'utilisation de la commande ${code}if${reset} (l'anglais du mot 'si') en combinaison avec ${code}else${reset} (l'anglais de 'sinon')."; restore=$(expr $restore + 1) ;&
31) echo -n 31 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Ce script demandera à l'utilisateur la valeur de la variable 'X', si cette valeur est 1, le script affichera 'COURS', si cette valeur n'est pas 1, le script affichera 'QUESTIONNAIRE'."; restore=$(expr $restore + 1) ;&
32) echo -n 32 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Ce mot clef ${code}if${reset} annonce l'ouverture d'une condition, qui devra avoir le ${voc}test logique${reset} voulu en argument."; restore=$(expr $restore + 1) ;&
33) echo -n 33 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Il faudra ensuite utiliser le mot clef ${code}then${reset}, pour définir l'emplacement du début du code à exécuter si cette condition est valide."; restore=$(expr $restore + 1) ;&
34) echo -n 34 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Cette condition commence à ${code}if${reset} mais vous devez également définir où elle se termine en utilisant le mot clef ${code}fi${reset}."; restore=$(expr $restore + 1) ;&
35) echo -n 35 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Vous pouvez lire cette combinaison ${code}if${reset}/${code}then${reset}/${code}else${reset}/${code}fi${reset} comme 'si/faire/sinon faire/fin'."; restore=$(expr $restore + 1) ;&
36) echo -n 36 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Le code ${code}[ \$X -eq 1 ]${reset} est un ${voc}test logique${reset} que vous pouvez lire comme 'X est égal à 1'."; restore=$(expr $restore + 1) ;&
37) echo -n 37 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Finalement vous pouvez lire le code ${learn}if [ \$X -eq 1 ];then echo COURS;else echo QUESTIONNAIRE;fi${reset} comme : 'si X est égal à 1, faire afficher COURS, sinon faire afficher QUESTIONNAIRE, fin du si'."; restore=$(expr $restore + 1) ;&
38) echo -n 38 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Comme d'habitude, les ${code};${reset} peuvent être remplacées par des mises à la lignes, mais attention car tous les espaces que vous voyez dans cet exemple sont indispensables !"; restore=$(expr $restore + 1) ;&
39) echo -n 39 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Par exemple, il y a un espace entre ${code}if${reset} et le code entre []."; restore=$(expr $restore + 1) ;&
40) echo -n 40 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Vous pouvez tout simplement voir ${code}if${reset} comme une commande qui prend ce code en argument."; restore=$(expr $restore + 1) ;&
41) echo -n 41 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Bien évidemment un espace est indispensable pour séparer une commande de son argument."; restore=$(expr $restore + 1) ;&
42) echo -n 42 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "L'argument d'un ${code}if${reset} peut être soit ${learn}true${reset} (vrai) soit ${learn}false${reset} (faux)."; restore=$(expr $restore + 1) ;&
43) echo -n 43 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "C'est en fait ce que renvoit le code que vous voyez ici ${code}[ \$X -eq 1 ]${reset}, c'est un ${voc}test logique${reset} qui renverra ${learn}true${reset} si la variable X est égal à 1, et ${learn}false${reset} si ça n'est pas le cas."; restore=$(expr $restore + 1) ;&
44) echo -n 44 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Vous pouvez également utiliser la variable ${code}\$?${reset} que nous avons déjà vu."; restore=$(expr $restore + 1) ;&
45) echo -n 45 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk_not_press_key justumen "Testez donc si 1 est égal à 2 avec : ${learn}[ 1 -eq 2 ];echo \$?${reset}"; restore=$(expr $restore + 1) ;&
46) echo -n 46 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; answer_run "[ 1 -eq 2 ];echo \$?" justumen "Non"; restore=$(expr $restore + 1) ;&
47) echo -n 47 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Si donné en argument à if, 0 devient ${learn}true${reset} et tout autre nombre devient ${learn}false${reset}. Ici ce 1 deviendra donc ${learn}false${reset}."; restore=$(expr $restore + 1) ;&
48) echo -n 48 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Ce ${code}-eq${reset} permet de comparer si deux nombres sont équivalents. (de l'anglais EQual : égal)"; restore=$(expr $restore + 1) ;&
49) echo -n 49 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Vous pouvez en utilisez d'autres, comme ${code}-lt${reset} (Less Than / moins que), ${code}-gt${reset} (Greater Than / plus grand que), ${code}-ge${reset} (Greater or Equal / plus grand ou égal), ${code}-le${reset} (Less or Equal / moins ou égal) et ${code}-ne${reset} (Not Equal / pas égal)."; restore=$(expr $restore + 1) ;&
50) echo -n 50 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Par exemple, si X=1, le code ${code}[ \$X -eq 1 ]${reset} renverra ${learn}true${reset}, ${code}[ 1 -lt 2 ]${reset} renverra ${learn}true${reset} et ${code}[ 2 -gt 22 ]${reset} renverra ${learn}false${reset}."; restore=$(expr $restore + 1) ;&
51) echo -n 51 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "${code}[ 1 -eq 1 ]${reset} renverra ${learn}true${reset} (\$? = 0) si 1 est égal à 1, ce qui sera bien évidemment toujours le cas."; restore=$(expr $restore + 1) ;&
52) echo -n 52 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "C'est pourquoi vous pouvez aussi utiliser cette syntaxe que vous connaissez déjà : ${learn}[ 1 -eq 1 ] && echo GOOD${reset}"; restore=$(expr $restore + 1) ;&
53) echo -n 53 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "N'importe quelle commande en argument de ${code}if${reset} peut également fonctionner."; restore=$(expr $restore + 1) ;&
54) echo -n 54 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk_not_press_key justumen "Testez donc cette commande, qui affiche 'GOOD' si la commande donnée en argument est un succès : ${learn}if ls;then echo GOOD;fi${reset}"; restore=$(expr $restore + 1) ;&
55) echo -n 55 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; answer_run "if ls;then echo GOOD;fi" justumen "Non"; restore=$(expr $restore + 1) ;&
56) echo -n 56 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "${code}ls${reset} renvoit ${learn}true${reset} à ${code}if${reset} car la commande est un succès. Autrement dit ${code}\$?${reset} est égal à 0."; restore=$(expr $restore + 1) ;&
57) echo -n 57 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk_not_press_key justumen "Essayez donc de faire : ${learn}if true;then echo vrai;else echo faux;fi${reset}"; restore=$(expr $restore + 1) ;&
58) echo -n 58 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; answer_run "if true;then echo vrai;else echo faux;fi" justumen "Non"; restore=$(expr $restore + 1) ;&
59) echo -n 59 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Si vous n'en avez pas besoin, le ${code}else${reset} dans votre script n'est pas obligatoire."; restore=$(expr $restore + 1) ;&
60) echo -n 60 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk_not_press_key justumen "Essayez donc de faire : ${learn}if true;then echo vrai;fi${reset}"; restore=$(expr $restore + 1) ;&
61) echo -n 61 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; answer_run "if true;then echo vrai;fi" justumen "Non"; restore=$(expr $restore + 1) ;&
62) echo -n 62 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Dans cet exemple, tous les espaces et les ${code};${reset} sont indispensables, faites donc bien attention à ne pas en oublier."; restore=$(expr $restore + 1) ;&
63) echo -n 63 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "${learn}if${codeFile} ${learn}true;then echo vrai;fi${reset} : Cet espace en vert entre ${code}if${reset} et son argument est ${voc}important${reset}, c'est pourquoi ${code}if [ \$X -gt 5 ]${reset} est correct mais ${codeError}if[ \$X -gt 5 ]${reset} ne l'est pas."; restore=$(expr $restore + 1) ;&
64) echo -n 64 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "${learn}if true${codeFile};${learn}then echo vrai;fi${reset} : La commande ${code}if${reset} et son argument doivent aussi être séparés du reste, c'est pourquoi il faudra utiliser un ${code};${reset} ou une mise à la ligne."; restore=$(expr $restore + 1) ;&
65) echo -n 65 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "${learn}if true;${codeFile}then echo vrai;${learn}fi${reset} : Pour être valide, un ${code}if${reset} doit contenir le mot clef 'then', suivi d'un espace, suivi d'au moins une commande et d'un ${code};${reset}."; restore=$(expr $restore + 1) ;&
66) echo -n 66 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "${learn}if true;then echo vrai;${codeFile}fi${reset} : Il doit aussi se terminer par un ${code}fi${reset}."; restore=$(expr $restore + 1) ;&
67) echo -n 67 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; echo -e "\nif\ntrue\nthen\necho vrai\nfi"; restore=$(expr $restore + 1) ;&
68) echo -n 68 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "La présentation est bien évidemment flexible, ces espaces et ${code};${reset} peuvent être remplacés par des mises à la lignes comme vous le voyez dans le code ci-dessus."; restore=$(expr $restore + 1) ;&
69) echo -n 69 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Mais revenons sur un exemple complet 'if/then/else/fi' : ${code}if true;then echo vrai;else echo faux;fi${reset}"; restore=$(expr $restore + 1) ;&
70) echo -n 70 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Ici, quel que soit la situation, il est important de comprendre que seul l'${voc}une${reset} de ces commandes ${code}echo${reset} se lancera, ${voc}jamais${reset} les deux."; restore=$(expr $restore + 1) ;&
71) echo -n 71 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk_not_press_key justumen "Revenons maintenant sur notre premier exemple, réaffichez le contenu du fichier 'if1'."; restore=$(expr $restore + 1) ;&
72) echo -n 72 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; answer_run "cat if1" justumen "Non"; restore=$(expr $restore + 1) ;&
73) echo -n 73 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk_not_press_key justumen "Puis lancez ce script avec : ${learn}bash if1${reset}, puis donnez à X la valeur 1 en tapant simplement 1 et validez avec la touche entrée."; restore=$(expr $restore + 1) ;&
74) echo -n 74 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; answer_run "bash if1" justumen "Non"; restore=$(expr $restore + 1) ;&
75) echo -n 75 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk_not_press_key justumen "Lancez à nouveau ce script avec : ${learn}bash if1${reset}, et donnez à X une valeur numérique différente de 1."; restore=$(expr $restore + 1) ;&
76) echo -n 76 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; answer_run "bash if1" justumen "Non"; restore=$(expr $restore + 1) ;&
77) echo -n 77 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Maintenant vous devriez comprendre comment cette syntaxe fonctionne."; restore=$(expr $restore + 1) ;&
78) echo -n 78 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk_not_press_key justumen "Affichez maintenant le contenu du fichier 'if2'."; restore=$(expr $restore + 1) ;&
79) echo -n 79 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; answer_run "cat if2" justumen "Non"; restore=$(expr $restore + 1) ;&
80) echo -n 80 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Le code du script 'if2' est équivalent au code du script 'if1', seul la présentation du code est différente."; restore=$(expr $restore + 1) ;&
81) echo -n 81 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Ici les ${code};${reset} ont été remplacés par des mises à la ligne."; restore=$(expr $restore + 1) ;&
82) echo -n 82 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk_not_press_key justumen "Affichez donc le contenu du fichier 'if3'."; restore=$(expr $restore + 1) ;&
83) echo -n 83 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; answer_run "cat if3" justumen "Non"; restore=$(expr $restore + 1) ;&
84) echo -n 84 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Comme pour les commandes, les espaces peuvent être utilisés pour présenter votre code différemment, par exemple pour le rendre plus lisible."; restore=$(expr $restore + 1) ;&
85) echo -n 85 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Traditionnelement, des tabulations ou plusieurs espaces sont ajoutés au début d'une ligne quand le code est d'un autre niveau."; restore=$(expr $restore + 1) ;&
86) echo -n 86 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "On appelle cette présentation un style d'indentation, l'${voc}indentation${reset} étant ce décalage en début de ligne avant le code ${code}echo COURS${reset}"; restore=$(expr $restore + 1) ;&
87) echo -n 87 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Avec l'exemple de 'if3', il est très facile de voir le ${voc}bloc de code${reset} à l'intérieur du ${code}if${reset} et celui à l'intérieur du ${code}else${reset}."; restore=$(expr $restore + 1) ;&
88) echo -n 88 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk_not_press_key justumen "Affichez donc le contenu du fichier 'if4'."; restore=$(expr $restore + 1) ;&
89) echo -n 89 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; answer_run "cat if4" justumen "Non"; restore=$(expr $restore + 1) ;&
90) echo -n 90 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Après ce ${code}fi${reset} le script continuera à s'exécuter normalement ligne par ligne."; restore=$(expr $restore + 1) ;&
91) echo -n 91 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "C'est à dire qu'ici, quel que soit la valeur donnée à 'X' la commande ${code}echo TEXTE${reset} se lancera."; restore=$(expr $restore + 1) ;&
92) echo -n 92 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "L'absence d'espaces en début de ligne nous permet de rapidement comprendre que cette ligne de code n'est pas dépendant d'un ${code}if${reset}."; restore=$(expr $restore + 1) ;&
93) echo -n 93 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Mais attention, ces ${voc}indentations${reset} ne sont pas obligatoires : c'est un choix esthétique qui revient au créateur du script."; restore=$(expr $restore + 1) ;&
94) echo -n 94 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Je vous recommande cependant d'utiliser ce ${voc}style d'indentation${reset} pour que votre script soit plus facilement compréhensible."; restore=$(expr $restore + 1) ;&
95) echo -n 95 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Nous avons donc vu que le code ${code}[ \$X -eq 5 ]${reset} est capable de vérifier si 'X' est égal à la valeur 5. (anglais ${code}eq${reset}ual)"; restore=$(expr $restore + 1) ;&
96) echo -n 96 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Mais vous pouvez aussi vérifier si 'X' n'est ${voc}pas${reset} égal à la valeur 5 avec : ${code}[ \$X -ne 5 ]${reset} (anglais ${code}n${reset}ot ${code}e${reset}qual)"; restore=$(expr $restore + 1) ;&
97) echo -n 97 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Vérifier si 'X' est supérieur à 5 avec : ${code}[ \$X -gt 5 ]${reset} (anglais ${code}g${reset}reater ${code}t${reset}han)"; restore=$(expr $restore + 1) ;&
98) echo -n 98 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Vérifier si 'X' est inférieur à 5 avec : ${code}[ \$X -lt 5 ]${reset} (anglais ${code}l${reset}esser ${code}t${reset}han)"; restore=$(expr $restore + 1) ;&
99) echo -n 99 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Ce code entre '[ ]' contiendra la logique qui sera donné à if."; restore=$(expr $restore + 1) ;&
100) echo -n 100 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Mais ce code peut aussi être utilisé comme une commande avec une syntaxe que nous avons déjà vu."; restore=$(expr $restore + 1) ;&
101) echo -n 101 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk_not_press_key justumen "Affichez donc le contenu du fichier 'if5'."; restore=$(expr $restore + 1) ;&
102) echo -n 102 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; answer_run "cat if5" justumen "Non"; restore=$(expr $restore + 1) ;&
103) echo -n 103 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Cette syntaxe est identique au traditionnel 'if/then/else/fi', mais sa lisibilité est assez réduite, je vous déconseille donc de l'utiliser dans un script lorsque les conditions deviennent complexes."; restore=$(expr $restore + 1) ;&
104) echo -n 104 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Voyons donc maintenant un exemple contenant ${voc}plusieurs niveaux de conditions${reset} : des if dans d'autres if."; restore=$(expr $restore + 1) ;&
105) echo -n 105 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk_not_press_key justumen "Affichez donc le contenu du fichier 'if6'."; restore=$(expr $restore + 1) ;&
106) echo -n 106 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; answer_run "cat if6" justumen "Non"; restore=$(expr $restore + 1) ;&
107) echo -n 107 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Ce code est en fait très simple, mais le manque d'indentation le rend impossible à lire."; restore=$(expr $restore + 1) ;&
108) echo -n 108 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk_not_press_key justumen "Voyons le même code avec une indentation propre, affichez donc le contenu du fichier 'if7'."; restore=$(expr $restore + 1) ;&
109) echo -n 109 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; answer_run "cat if7" justumen "Non"; restore=$(expr $restore + 1) ;&
110) echo -n 110 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Ici avec ce genre de présentation, il est très facile de voir quelles commandes appartiennent à quel ${code}if${reset}, quel ${code}else${reset} correspond à quel ${code}if${reset} et quel sont les ${code}if${reset} à l'intérieur d'autres ${code}if${reset}."; restore=$(expr $restore + 1) ;&
111) echo -n 111 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "A chaque passage dans un nouveau ${code}if${reset} vous pouvez voir ici une tabulation de plus avant le début de la commande."; restore=$(expr $restore + 1) ;&
112) echo -n 112 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Au contraire, à chaque fois qu'un ${code}if${reset} se termine avec un ${code}fi${reset}, il y a une tabulation de moins."; restore=$(expr $restore + 1) ;&
113) echo -n 113 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Maintenant que ce code est plus lisible, nous allons le lire et le comprendre ensemble."; restore=$(expr $restore + 1) ;&
114) echo -n 114 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Pour cela nous allons nous comporter comme le ferait 'bash', en lisant et interprétant les commandes ligne par ligne."; restore=$(expr $restore + 1) ;&
115) echo -n 115 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; echo '';echo -e '\e[30;48;5;82mX=11\e[0m\nif [ $X -gt 5 ];then\n\techo h\n\tif [ $X -lt 10 ];then\n\t\techo o\n\t\tif [ $X -eq 8 ];then\n\t\t\techo i\n\t\telse\n\t\t\techo f\n\t\tfi\n\telse\n\t\techo e\n\t\tif [ $X -lt 11 ];then\n\t\t\techo o\n\t\telse\n\t\t\techo y\n\t\tfi\n\tfi\nelse\n\tif [ $X -lt 3 ];then\n\t\techo o\n\t\tif [ $X -eq 1 ];then\n\t\t\techo l\n\t\telse\n\t\t\techo u\n\t\tfi\n\telse\n\t\techo x\n\tfi\nfi'|cat -n; restore=$(expr $restore + 1) ;&
116) echo -n 116 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "- Tout d'abord, une variable nommé X sera créé et contiendra la valeur 11."; restore=$(expr $restore + 1) ;&
117) echo -n 117 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; echo '';echo -e 'X=11\n\e[30;48;5;82mif [ $X -gt 5 ];then\e[0m\n\techo h\n\tif [ $X -lt 10 ];then\n\t\techo o\n\t\tif [ $X -eq 8 ];then\n\t\t\techo i\n\t\telse\n\t\t\techo f\n\t\tfi\n\telse\n\t\techo e\n\t\tif [ $X -lt 11 ];then\n\t\t\techo o\n\t\telse\n\t\t\techo y\n\t\tfi\n\tfi\nelse\n\tif [ $X -lt 3 ];then\n\t\techo o\n\t\tif [ $X -eq 1 ];then\n\t\t\techo l\n\t\telse\n\t\t\techo u\n\t\tfi\n\telse\n\t\techo x\n\tfi\nfi'|cat -n; restore=$(expr $restore + 1) ;&
118) echo -n 118 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "- Ensuite nous avons notre première condition."; restore=$(expr $restore + 1) ;&
119) echo -n 119 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; echo '';echo -e 'X=11\nif [ $X -gt 5 ];then\n\e[30;48;5;81m\techo h\n\tif [ $X -lt 10 ];then\n\t\techo o\n\t\tif [ $X -eq 8 ];then\n\t\t\techo i\n\t\telse\n\t\t\techo f\n\t\tfi\n\telse\n\t\techo e\n\t\tif [ $X -lt 11 ];then\n\t\t\techo o\n\t\telse\n\t\t\techo y\n\t\tfi\n\tfi\e[0m\nelse\n\tif [ $X -lt 3 ];then\n\t\techo o\n\t\tif [ $X -eq 1 ];then\n\t\t\techo l\n\t\telse\n\t\t\techo u\n\t\tfi\n\telse\n\t\techo x\n\tfi\nfi'|cat -n; restore=$(expr $restore + 1) ;&
120) echo -n 120 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "- Si celle-ci est correcte nous entrerons dans le code du 'then' correspondant."; restore=$(expr $restore + 1) ;&
121) echo -n 121 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; echo '';echo -e 'X=11\nif [ $X -gt 5 ];then\n\techo h\n\tif [ $X -lt 10 ];then\n\t\techo o\n\t\tif [ $X -eq 8 ];then\n\t\t\techo i\n\t\telse\n\t\t\techo f\n\t\tfi\n\telse\n\t\techo e\n\t\tif [ $X -lt 11 ];then\n\t\t\techo o\n\t\telse\n\t\t\techo y\n\t\tfi\n\tfi\nelse\n\e[30;48;5;81m\tif [ $X -lt 3 ];then\n\t\techo o\n\t\tif [ $X -eq 1 ];then\n\t\t\techo l\n\t\telse\n\t\t\techo u\n\t\tfi\n\telse\n\t\techo x\n\tfi\e[0m\nfi'|cat -n; restore=$(expr $restore + 1) ;&
122) echo -n 122 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "- Si cette condition est incorrecte, nous entrerons dans le 'else' correspondant à ce premier 'if'."; restore=$(expr $restore + 1) ;&
123) echo -n 123 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; echo '';echo -e 'X=11\nif [ $X -gt 5 ];then\n\e[30;48;5;81m\techo h\n\tif [ $X -lt 10 ];then\n\t\techo o\n\t\tif [ $X -eq 8 ];then\n\t\t\techo i\n\t\telse\n\t\t\techo f\n\t\tfi\n\telse\n\t\techo e\n\t\tif [ $X -lt 11 ];then\n\t\t\techo o\n\t\telse\n\t\t\techo y\n\t\tfi\n\tfi\e[0m\nelse\n\tif [ $X -lt 3 ];then\n\t\techo o\n\t\tif [ $X -eq 1 ];then\n\t\t\techo l\n\t\telse\n\t\t\techo u\n\t\tfi\n\telse\n\t\techo x\n\tfi\nfi'|cat -n; restore=$(expr $restore + 1) ;&
124) echo -n 124 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "- Ici X étant égal à 11, nous rentrons dans le 'if' car 11 est un nombre plus grand que 5."; restore=$(expr $restore + 1) ;&
125) echo -n 125 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; echo '';echo -e 'X=11\nif [ $X -gt 5 ];then\n\techo h\n\tif [ $X -lt 10 ];then\n\t\techo o\n\t\tif [ $X -eq 8 ];then\n\t\t\techo i\n\t\telse\n\t\t\techo f\n\t\tfi\n\telse\n\t\techo e\n\t\tif [ $X -lt 11 ];then\n\t\t\techo o\n\t\telse\n\t\t\techo y\n\t\tfi\n\tfi\nelse\n\e[41m\tif [ $X -lt 3 ];then\n\t\techo o\n\t\tif [ $X -eq 1 ];then\n\t\t\techo l\n\t\telse\n\t\t\techo u\n\t\tfi\n\telse\n\t\techo x\n\tfi\e[0m\nfi'|cat -n; restore=$(expr $restore + 1) ;&
126) echo -n 126 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "- Dans notre cas avec X=11, ce code ne sera donc pas utilisé."; restore=$(expr $restore + 1) ;&
127) echo -n 127 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; echo '';echo -e 'X=11\nif [ $X -gt 5 ];then\n\e[30;48;5;82m\techo h\e[0m\n\tif [ $X -lt 10 ];then\n\t\techo o\n\t\tif [ $X -eq 8 ];then\n\t\t\techo i\n\t\telse\n\t\t\techo f\n\t\tfi\n\telse\n\t\techo e\n\t\tif [ $X -lt 11 ];then\n\t\t\techo o\n\t\telse\n\t\t\techo y\n\t\tfi\n\tfi\nelse\n\tif [ $X -lt 3 ];then\n\t\techo o\n\t\tif [ $X -eq 1 ];then\n\t\t\techo l\n\t\telse\n\t\t\techo u\n\t\tfi\n\telse\n\t\techo x\n\tfi\nfi'|cat -n; restore=$(expr $restore + 1) ;&
128) echo -n 128 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "- Dans ce 'if' nous avons notre première commande qui sera executée : ${code}echo h${reset}, qui affichera la lettre h."; restore=$(expr $restore + 1) ;&
129) echo -n 129 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; echo '';echo -e 'X=11\nif [ $X -gt 5 ];then\n\techo h\n\t\e[30;48;5;82mif [ $X -lt 10 ];then\e[0m\n\t\techo o\n\t\tif [ $X -eq 8 ];then\n\t\t\techo i\n\t\telse\n\t\t\techo f\n\t\tfi\n\telse\n\t\techo e\n\t\tif [ $X -lt 11 ];then\n\t\t\techo o\n\t\telse\n\t\t\techo y\n\t\tfi\n\tfi\nelse\n\tif [ $X -lt 3 ];then\n\t\techo o\n\t\tif [ $X -eq 1 ];then\n\t\t\techo l\n\t\telse\n\t\t\techo u\n\t\tfi\n\telse\n\t\techo x\n\tfi\nfi'|cat -n; restore=$(expr $restore + 1) ;&
130) echo -n 130 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "- Puis nous avons une nouvelle condition sur la valeur de X : si X est inférieur à 10."; restore=$(expr $restore + 1) ;&
131) echo -n 131 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; echo '';echo -e 'X=11\nif [ $X -gt 5 ];then\n\techo h\n\tif [ $X -lt 10 ];then\n\e[41m\t\techo o\n\t\tif [ $X -eq 8 ];then\n\t\t\techo i\n\t\telse\n\t\t\techo f\n\t\tfi\e[0m\n\telse\n\t\techo e\n\t\tif [ $X -lt 11 ];then\n\t\t\techo o\n\t\telse\n\t\t\techo y\n\t\tfi\n\tfi\nelse\n\tif [ $X -lt 3 ];then\n\t\techo o\n\t\tif [ $X -eq 1 ];then\n\t\t\techo l\n\t\telse\n\t\t\techo u\n\t\tfi\n\telse\n\t\techo x\n\tfi\nfi'|cat -n; restore=$(expr $restore + 1) ;&
132) echo -n 132 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "- X étant égal à 11, et 11 n'étant pas inférieur à 10, nous ignorerons le contenu de ce 'if'."; restore=$(expr $restore + 1) ;&
133) echo -n 133 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; echo '';echo -e 'X=11\nif [ $X -gt 5 ];then\n\techo h\n\tif [ $X -lt 10 ];then\n\t\techo o\n\t\tif [ $X -eq 8 ];then\n\t\t\techo i\n\t\telse\n\t\t\techo f\n\t\tfi\n\telse\n\e[30;48;5;81m\t\techo e\n\t\tif [ $X -lt 11 ];then\n\t\t\techo o\n\t\telse\n\t\t\techo y\n\t\tfi\e[0m\n\tfi\nelse\n\tif [ $X -lt 3 ];then\n\t\techo o\n\t\tif [ $X -eq 1 ];then\n\t\t\techo l\n\t\telse\n\t\t\techo u\n\t\tfi\n\telse\n\t\techo x\n\tfi\nfi'|cat -n; restore=$(expr $restore + 1) ;&
134) echo -n 134 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "- Et nous irons dans le contenu du 'else' correspondant à ce 'if'."; restore=$(expr $restore + 1) ;&
135) echo -n 135 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; echo '';echo -e 'X=11\nif [ $X -gt 5 ];then\n\techo h\n\tif [ $X -lt 10 ];then\n\t\techo o\n\t\tif [ $X -eq 8 ];then\n\t\t\techo i\n\t\telse\n\t\t\techo f\n\t\tfi\n\telse\n\t\t\e[30;48;5;82mecho e\e[0m\n\t\tif [ $X -lt 11 ];then\n\t\t\techo o\n\t\telse\n\t\t\techo y\n\t\tfi\n\tfi\nelse\n\tif [ $X -lt 3 ];then\n\t\techo o\n\t\tif [ $X -eq 1 ];then\n\t\t\techo l\n\t\telse\n\t\t\techo u\n\t\tfi\n\telse\n\t\techo x\n\tfi\nfi'|cat -n; restore=$(expr $restore + 1) ;&
136) echo -n 136 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "- Notre deuxième commande est donc : ${code}echo e${reset}, qui affichera la lettre e."; restore=$(expr $restore + 1) ;&
137) echo -n 137 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; echo '';echo -e 'X=11\nif [ $X -gt 5 ];then\n\techo h\n\tif [ $X -lt 10 ];then\n\t\techo o\n\t\tif [ $X -eq 8 ];then\n\t\t\techo i\n\t\telse\n\t\t\techo f\n\t\tfi\n\telse\n\t\techo e\n\t\t\e[30;48;5;82mif [ $X -lt 11 ];then\e[0m\n\t\t\techo o\n\t\telse\n\t\t\techo y\n\t\tfi\n\tfi\nelse\n\tif [ $X -lt 3 ];then\n\t\techo o\n\t\tif [ $X -eq 1 ];then\n\t\t\techo l\n\t\telse\n\t\t\techo u\n\t\tfi\n\telse\n\t\techo x\n\tfi\nfi'|cat -n; restore=$(expr $restore + 1) ;&
138) echo -n 138 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "- Puis nous avons un nouvelle condition : si X est inférieur à 11."; restore=$(expr $restore + 1) ;&
139) echo -n 139 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; echo '';echo -e 'X=11\nif [ $X -gt 5 ];then\n\techo h\n\tif [ $X -lt 10 ];then\n\t\techo o\n\t\tif [ $X -eq 8 ];then\n\t\t\techo i\n\t\telse\n\t\t\techo f\n\t\tfi\n\telse\n\t\techo e\n\t\tif [ $X -lt 11 ];then\n\t\t\techo o\n\t\telse\n\t\t\t\e[30;48;5;82mecho y\e[0m\n\t\tfi\n\tfi\nelse\n\tif [ $X -lt 3 ];then\n\t\techo o\n\t\tif [ $X -eq 1 ];then\n\t\t\techo l\n\t\telse\n\t\t\techo u\n\t\tfi\n\telse\n\t\techo x\n\tfi\nfi'|cat -n; restore=$(expr $restore + 1) ;&
140) echo -n 140 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "- X n'étant pas inférieur à 11, puisqu'il est égal à 11, nous irons dans le 'else' correspondant, et nous affichons notre troisième lettre avec ${code}echo y${reset}"; restore=$(expr $restore + 1) ;&
141) echo -n 141 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; echo '';echo -e 'X=11\nif [ $X -gt 5 ];then\n\t\e[30;48;5;82mecho h\e[0m\n\tif [ $X -lt 10 ];then\n\t\techo o\n\t\tif [ $X -eq 8 ];then\n\t\t\techo i\n\t\telse\n\t\t\techo f\n\t\tfi\n\telse\n\t\t\e[30;48;5;82mecho e\e[0m\n\t\tif [ $X -lt 11 ];then\n\t\t\techo o\n\t\telse\n\t\t\t\e[30;48;5;82mecho y\e[0m\n\t\tfi\n\tfi\nelse\n\tif [ $X -lt 3 ];then\n\t\techo o\n\t\tif [ $X -eq 1 ];then\n\t\t\techo l\n\t\telse\n\t\t\techo u\n\t\tfi\n\telse\n\t\techo x\n\tfi\nfi'|cat -n; restore=$(expr $restore + 1) ;&
142) echo -n 142 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "- Au final, avec X égal à 11, voilà les trois commandes qui seront exécutés."; restore=$(expr $restore + 1) ;&
143) echo -n 143 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk_not_press_key justumen "Vous pouvez maintenant lancer ce script avec : ${learn}bash if7${reset}."; restore=$(expr $restore + 1) ;&
144) echo -n 144 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; answer_run "bash if7" justumen "Non"; restore=$(expr $restore + 1) ;&
145) echo -n 145 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Bash affiche bien ce que nous avions prévu : h, puis e, puis y."; restore=$(expr $restore + 1) ;&
146) echo -n 146 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Bien évidemment, lorsque la valeur de X n'est pas 11, le même code n'affichera pas la même chose."; restore=$(expr $restore + 1) ;&
147) echo -n 147 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk_not_press_key justumen "Affichez donc le contenu du fichier 'if8'."; restore=$(expr $restore + 1) ;&
148) echo -n 148 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; answer_run "cat if8" justumen "Non"; restore=$(expr $restore + 1) ;&
149) echo -n 149 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Ici le code est identique, seul la valeur de X a changé, essayez de lire ce code et trouvez ce qu'il affichera avant de continuer."; restore=$(expr $restore + 1) ;&
150) echo -n 150 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk_not_press_key justumen "Si vous pensez avoir la bonne réponse, lancez ce script pour vérifier : ${learn}bash if8${reset}."; restore=$(expr $restore + 1) ;&
151) echo -n 151 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; answer_run "bash if8" justumen "Non"; restore=$(expr $restore + 1) ;&
152) echo -n 152 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Lorsque vous voyez ces [], il s'agit en fait de la syntaxe secondaire de la commande ${code}test${reset}."; restore=$(expr $restore + 1) ;&
153) echo -n 153 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Par exemple, ${code}[ 1 -eq 2 ]${reset} est en fait équivalent à ${code}test 1 -eq 2${reset} !"; restore=$(expr $restore + 1) ;&
154) echo -n 154 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "N'hésitez donc pas à voir plus de détails sur ces ${voc}tests logiques${reset} avec un : ${code}man test${reset} !"; restore=$(expr $restore + 1) ;&
155) echo -n 155 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "En avant pour le questionnaire !"; restore=$(expr $restore + 1) ;&
156) echo -n 156 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; clean; restore=$(expr $restore + 1) ;&
esac
}
function clean(){ #in enter_chapter
rm $HOME/.GameScript/restore_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
rm $HOME/.GameScript/restore_pwd_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
	rm $HOME/.GameScript_bash11/if1 2> /dev/null
	rm $HOME/.GameScript_bash11/if2 2> /dev/null
	rm $HOME/.GameScript_bash11/if3 2> /dev/null
	rm $HOME/.GameScript_bash11/if4 2> /dev/null
	rm $HOME/.GameScript_bash11/if5 2> /dev/null
	rm $HOME/.GameScript_bash11/if6 2> /dev/null
	rm $HOME/.GameScript_bash11/if7 2> /dev/null
	rm $HOME/.GameScript_bash11/if8 2> /dev/null
	rm $HOME/.GameScript_bash11/CODE 2> /dev/null
	rmdir $HOME/.GameScript_bash11 2> /dev/null
}

function start_quiz(){
  echo ""
  echo -e "\e[15;44m Bash 'Bourne Again SHell' : Questionnaire du chapitre 11 \e[0m"
  echo -e "- La réponse doit être la plus courte possible, une commande valide mais ajoutant des caractères inutiles ne fonctionnera pas."
  echo -e "Exemple : si la réponse est 'ls'. Les réponses 'ls .', 'ls ./' et 'ls ././' seront considérées comme fausses."
  answer_text_fr "Par quel mot clef doit se terminer une condition 'if' ?" "fi"
  answer_text_fr "Quel argument pouvez-vous donner à 'if' qui garantira l'exécution du contenu dans son 'else' correspondant ?" "false"
  answer_text_fr "Comment demander la valeur de la variable 'nom' à l'utilisateur ?" "read nom"
  answer_text_fr "En utilisant 'if', un seul '[' et un seul ']', comment afficher le mot 'oui' si la valeur de X est plus grande que 2 ?" 'if [ $X -gt 2 ];then echo oui;fi'
  answer_text_fr "Sans utiliser de 'if' et en utilisant qu'un seul '[' et qu'un seul ']', comment afficher le mot 'oui' si la valeur de X est plus petite que 2 ?" '[ $X -lt 2 ]&&echo oui'
  answer_text_fr "Sans utiliser de 'if' ou de '[', comment afficher le mot 'oui' si la valeur de X est égal à 2 ?" 'test $X -eq 2&&echo oui'
  unlock "bash" "11" "2211" "ddfb"
}


CHAPTER_NAME="bash"
CHAPTER_NUMBER="11"
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
