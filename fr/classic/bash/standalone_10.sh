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
	#~ sleep 1
	PLAYLIST_NEXT #play next video
	#~ sleep 1
	LOOP_OFF
	#~ sleep 1
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
	talk_not_press_key justumen "Pour débloquer '$1 $2' sur le chat, ouvrez une conversation privée avec '@boti' et copiez/collez :\n\t\e[97;42mpassword$PASS\e[0m"
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
1) echo -n 1 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; [ -d "$HOME/.GameScript_bash10" ] && echo "Erreur innatendu, ${HOME}/.GameScript_bash10 existe déjà sur votre système ! Supprimez ce dossier $HOME/.GameScript_bash10 et relancer ce script." && exit; restore=$(expr $restore + 1) ;&
2) echo -n 2 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; mkdir $HOME/.GameScript_bash10 2> /dev/null; restore=$(expr $restore + 1) ;&
3) echo -n 3 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; cd $HOME/.GameScript_bash10;ls /var/log/*.log|head -n 5 > ~/.GameScript_bash10/LOG;cat ~/.bashrc|grep '^[^#]*alias '>~/.GameScript_bash10/.MYALIAS;source ~/.GameScript_bash10/.MYALIAS 2> /dev/null; restore=$(expr $restore + 1) ;&
4) echo -n 4 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Dans le dernier chapitre nous avons vu comment créer et manipuler les variables."; restore=$(expr $restore + 1) ;&
5) echo -n 5 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Mais les variables sont aussi capables de stocker des commandes bash."; restore=$(expr $restore + 1) ;&
6) echo -n 6 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen "Créez donc une variable 'cmd' qui contiendra ${code}ls -a /var${reset} en utilisant les ${code}'${reset}."; restore=$(expr $restore + 1) ;&
7) echo -n 7 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run "cmd='ls -a /var'" justumen "Non"; restore=$(expr $restore + 1) ;&
8) echo -n 8 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen "Faites donc maintenant : ${learn}cmd${reset}."; restore=$(expr $restore + 1) ;&
9) echo -n 9 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run "cmd" justumen "Non"; restore=$(expr $restore + 1) ;&
10) echo -n 10 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Ici nous avons une erreur. Bien évidemment puisque 'cmd' est une ${voc}variable${reset} et n'a jamais été une commande, faites attention à ne pas confondre les deux."; restore=$(expr $restore + 1) ;&
11) echo -n 11 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Vous pouvez néanmoins vous servir de cette variable comme une commande."; restore=$(expr $restore + 1) ;&
12) echo -n 12 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen "Mais pour cela, il faudra utiliser le \$, faites donc : ${learn}\$cmd${reset}."; restore=$(expr $restore + 1) ;&
13) echo -n 13 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run "\$cmd" justumen "Non"; restore=$(expr $restore + 1) ;&
14) echo -n 14 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Ici ${learn}\$cmd${reset} remplace simplement ${learn}ls -a /var${reset}."; restore=$(expr $restore + 1) ;&
15) echo -n 15 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Mais pour lancer GameScript, il vous suffit de taper 'gamescript' dans votre terminal."; restore=$(expr $restore + 1) ;&
16) echo -n 16 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Si le code de GameScript était dans une variable, il vous faudrait pourtant taper '\$gamescript'."; restore=$(expr $restore + 1) ;&
17) echo -n 17 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "On peut donc imaginer que 'gamescript' est peut être un script qui est dans un des dossiers de la variable d'environnement 'PATH'."; restore=$(expr $restore + 1) ;&
18) echo -n 18 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Et bien pas du tout... mais cela aurait pu être le cas."; restore=$(expr $restore + 1) ;&
19) echo -n 19 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "GameScript utilise en fait un ${voc}alias${reset}, un type de variable spécialisé pour les commandes."; restore=$(expr $restore + 1) ;&
20) echo -n 20 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Un ${voc}alias${reset} n'est donc pas un programme mais simplement une commande ou groupe de commande."; restore=$(expr $restore + 1) ;&
21) echo -n 21 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "La syntaxe est similaire aux variable classiques, il suffira d'ajouter le mot clef 'alias' avant la création de l'alias."; restore=$(expr $restore + 1) ;&
22) echo -n 22 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen "Créons notre premier alias avec : ${learn}alias a1='ls -a /var'${reset}."; restore=$(expr $restore + 1) ;&
23) echo -n 23 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run "alias a1='ls -a /var'" justumen "Non"; restore=$(expr $restore + 1) ;&
24) echo -n 24 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen "Puis lancez simplement votre alias avec : ${learn}a1${reset}."; restore=$(expr $restore + 1) ;&
25) echo -n 25 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run "a1" justumen "Non"; restore=$(expr $restore + 1) ;&
26) echo -n 26 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Ici ${code}a1${reset} remplace simplement la commande ${code}ls -a /var${reset}, mais vous pouvez créez des alias beaucoup plus complexes."; restore=$(expr $restore + 1) ;&
27) echo -n 27 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen "Affichez une liste de tous vos alias en faisant simplement : ${learn}alias${reset}."; restore=$(expr $restore + 1) ;&
28) echo -n 28 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run "alias" justumen "Non"; restore=$(expr $restore + 1) ;&
29) echo -n 29 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Je le répète, 'gamescript' est dans votre environnement un alias."; restore=$(expr $restore + 1) ;&
30) echo -n 30 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen "Affichez uniquement l'alias de gamescript avec : ${learn}alias gamescript${reset}."; restore=$(expr $restore + 1) ;&
31) echo -n 31 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run "alias gamescript" justumen "Non"; restore=$(expr $restore + 1) ;&
32) echo -n 32 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Lorsque vous lancez 'gamescript', voilà donc le code qui est réellement executé."; restore=$(expr $restore + 1) ;&
33) echo -n 33 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "${code}wget${reset} télécharge la dernière version de GameScript et l'execute ensuite sur votre machine."; restore=$(expr $restore + 1) ;&
34) echo -n 34 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "La commande 'bash' est exactement comme la commande 'date' du chapitre précédent, il s'agit en fait d'un fichier."; restore=$(expr $restore + 1) ;&
35) echo -n 35 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen "Pour connaitre le chemin absolu de ce fichier 'bash', faites donc : ${learn}type bash${reset}."; restore=$(expr $restore + 1) ;&
36) echo -n 36 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run "type bash" justumen "Non"; restore=$(expr $restore + 1) ;&
37) echo -n 37 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Vous l'avez peut être compris, mais 'gamescript', utilisant simplement 'bash' et non pas '/bin/bash', ne fonctionnera que si le dossier '/bin' est dans votre variable 'PATH'."; restore=$(expr $restore + 1) ;&
38) echo -n 38 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Le répertoire '/bin' possède certains des fichiers ${voc}bin${reset}aires les plus important de votre système."; restore=$(expr $restore + 1) ;&
39) echo -n 39 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Utiliser 'bash' au lieu de '/bin/bash' semble raisonnable dans cet alias, car '/bin' devrait être présent dans la variable d'environnement 'PATH' de tous les systèmes correctement configurés."; restore=$(expr $restore + 1) ;&
40) echo -n 40 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen "Affichez donc plus de details sur ce fichier '/bin/bash' avec : ${learn}wc /bin/bash${reset}."; restore=$(expr $restore + 1) ;&
41) echo -n 41 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run "wc /bin/bash" justumen "Non"; restore=$(expr $restore + 1) ;&
42) echo -n 42 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Ce fichier est particulièrement volumineux, je vous déconseille donc de l'afficher avec la commande ${code}cat${reset}."; restore=$(expr $restore + 1) ;&
43) echo -n 43 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "En revanche, nous pouvons utiliser sans risque notre 'PAGER'."; restore=$(expr $restore + 1) ;&
44) echo -n 44 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "'PAGER' est une autre variable d'environnement qui définit quel programme sera utilisé pour la lecture de fichiers."; restore=$(expr $restore + 1) ;&
45) echo -n 45 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen "Pour connaitre la valeur de 'PAGER', faites donc : ${learn}echo \$PAGER${reset}."; restore=$(expr $restore + 1) ;&
46) echo -n 46 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run "echo \$PAGER" justumen "Non"; restore=$(expr $restore + 1) ;&
47) echo -n 47 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "La plupart du temps ce 'PAGER' sera la commande ${code}less${reset}, mais c'est une variable personnalisable, donc il se peut que vous ayez quelque chose d'autre."; restore=$(expr $restore + 1) ;&
48) echo -n 48 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Lorsque vous visitez le manuel d'une commande, vous pouvez naviguer de haut en bas avec votre clavier et même votre souris."; restore=$(expr $restore + 1) ;&
49) echo -n 49 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "La commande ${code}man${reset} utilise en fait votre 'PAGER'. C'est la commande ${code}less${reset} qui donne à vos manuels cette interface interactive."; restore=$(expr $restore + 1) ;&
50) echo -n 50 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Lorsque vous quittez le manuel avec la touche 'q', vous quittez en fait l'interface fournie par ${code}less${reset}."; restore=$(expr $restore + 1) ;&
51) echo -n 51 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Et vous pouvez très bien utiliser la commande ${code}less${reset} pour naviguer dans le fichier de votre choix."; restore=$(expr $restore + 1) ;&
52) echo -n 52 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen "Regardez très rapidement le contenu du fichier '/bin/bash' avec ${learn}less /bin/bash${reset}, puis quittez avec la touche 'q'."; restore=$(expr $restore + 1) ;&
53) echo -n 53 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run "less /bin/bash" justumen "Non"; restore=$(expr $restore + 1) ;&
54) echo -n 54 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Ici le fichier est illisible car il s'agit en fait d'un fichier ${voc}binaire${reset}."; restore=$(expr $restore + 1) ;&
55) echo -n 55 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "${code}less${reset} considère tout fichier ouvert comme un fichier texte, ce qu'il affiche n'a donc ici simplement aucun sens."; restore=$(expr $restore + 1) ;&
56) echo -n 56 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Si 'less' est la valeur de votre variable d'environnement 'PAGER', vous auriez bien sur également pu faire ${learn}\$PAGER /bin/bash${reset}."; restore=$(expr $restore + 1) ;&
57) echo -n 57 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen "Créons maintenant l'alias 'monpager' avec : ${learn}alias monpager=less${reset}."; restore=$(expr $restore + 1) ;&
58) echo -n 58 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run "alias monpager=less" justumen "Non"; restore=$(expr $restore + 1) ;&
59) echo -n 59 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen "Utilisez maintenant ce nouvel alias avec '/bin/bash', puis quittez avec la touche 'q'."; restore=$(expr $restore + 1) ;&
60) echo -n 60 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run "monpager /bin/bash" justumen "Non"; restore=$(expr $restore + 1) ;&
61) echo -n 61 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Nous avonc donc vu comment créer et manipuler les variables et les alias, mais n'oubliez pas que ces variables et ces alias ne seront disponibles que dans la session de bash que vous utilisez actuellement."; restore=$(expr $restore + 1) ;&
62) echo -n 62 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Maintenant parlons d'une variable très particulière : ${code}\$?${reset}"; restore=$(expr $restore + 1) ;&
63) echo -n 63 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "${code}\$?${reset} contient un nombre entre 0 et 255, qui est la ${voc}valeur de retour${reset} de votre dernière commande. (anglais ${voc}exit status${reset})"; restore=$(expr $restore + 1) ;&
64) echo -n 64 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen "Faites donc : ${learn}pwd;echo \$?${reset}"; restore=$(expr $restore + 1) ;&
65) echo -n 65 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run "pwd;echo \$?" justumen "Non"; restore=$(expr $restore + 1) ;&
66) echo -n 66 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Ici la valeur retour est 0. Cela veut dire que la commande ${code}pwd${reset} n'a pas rencontré de problème."; restore=$(expr $restore + 1) ;&
67) echo -n 67 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen "Maintenant faites : ${learn}pwdd;echo \$?${reset}"; restore=$(expr $restore + 1) ;&
68) echo -n 68 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run "pwdd;echo \$?" justumen "Non"; restore=$(expr $restore + 1) ;&
69) echo -n 69 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Ici la valeur retour est 127. Cela veut dire que la commande ${codeError}pwdd${reset} n'existe pas."; restore=$(expr $restore + 1) ;&
70) echo -n 70 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen "Faites donc : ${learn}lss;echo \$?${reset}"; restore=$(expr $restore + 1) ;&
71) echo -n 71 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run "lss;echo \$?" justumen "Non"; restore=$(expr $restore + 1) ;&
72) echo -n 72 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Ici la valeur retour est encore 127. Cela veut dire que la commande ${codeError}lss${reset} n'existe pas."; restore=$(expr $restore + 1) ;&
73) echo -n 73 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen "Maintenant faites donc : ${learn}cat x;echo \$?${reset}"; restore=$(expr $restore + 1) ;&
74) echo -n 74 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run "cat x;echo \$?" justumen "Non"; restore=$(expr $restore + 1) ;&
75) echo -n 75 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Ici la valeur retour n'est pas 0, ce qui veut dire que la commande a rencontré une erreur."; restore=$(expr $restore + 1) ;&
76) echo -n 76 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Cependant la valeur n'est pas la même que pour 'pwdd' et 'lss' car le type d'erreur est différent."; restore=$(expr $restore + 1) ;&
77) echo -n 77 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "La commande ${code}cat${reset} existe mais c'est le fichier donné en argument qui n'existe pas."; restore=$(expr $restore + 1) ;&
78) echo -n 78 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Vous avez en fait déjà utilisé cette variable ${code}\$?${reset} sans le savoir."; restore=$(expr $restore + 1) ;&
79) echo -n 79 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "${code}||${reset} et ${code}&&${reset} utilisent la variable ${code}\$?${reset} pour définir l'execution des autres commandes."; restore=$(expr $restore + 1) ;&
80) echo -n 80 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "${code}&&${reset} lancera la prochaine commande si ${code}\$?${reset} est égal à 0."; restore=$(expr $restore + 1) ;&
81) echo -n 81 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Et ${code}||${reset} lancera la prochaine commande si ${code}\$?${reset} n'est pas égal à 0."; restore=$(expr $restore + 1) ;&
82) echo -n 82 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Cette variable changera de valeur à chaque nouvelle commande, mais elle peut être sauvegardé dans une autre variable."; restore=$(expr $restore + 1) ;&
83) echo -n 83 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen "Essayez donc de sauvegarder la valeur retour de ${code}ls -O${reset} avec : ${learn}ls -O;VAL=\$?${reset}"; restore=$(expr $restore + 1) ;&
84) echo -n 84 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run "ls -O;VAL=\$?" justumen "Non"; restore=$(expr $restore + 1) ;&
85) echo -n 85 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen "Affichez donc la valeur de la variable 'VAL'."; restore=$(expr $restore + 1) ;&
86) echo -n 86 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run "echo \$VAL" justumen "Non"; restore=$(expr $restore + 1) ;&
87) echo -n 87 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Ce nombre est encore une fois différent, car ici l'erreur vient de l'utilisation d'une option inconnue."; restore=$(expr $restore + 1) ;&
88) echo -n 88 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Pour ce qui est des ${code}alias${reset}, il se peut également que vous utilisiez des alias sans le savoir."; restore=$(expr $restore + 1) ;&
89) echo -n 89 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Ces alias peuvent remplacer une commande en utilisant le même nom."; restore=$(expr $restore + 1) ;&
90) echo -n 90 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen "Faites donc : ${learn}type ls${reset}."; restore=$(expr $restore + 1) ;&
91) echo -n 91 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run "type ls" justumen "Non"; restore=$(expr $restore + 1) ;&
92) echo -n 92 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Ici, vous avez probablement un alias vers la commande : ${code}ls --color=auto${reset}."; restore=$(expr $restore + 1) ;&
93) echo -n 93 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Un alias sera prioritaire sur la variable 'PATH', c'est pourquoi vous ne devriez pas voir ici '/bin/ls'."; restore=$(expr $restore + 1) ;&
94) echo -n 94 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen "Affichez toutes les interprétations possibles de la commande ${code}ls${reset} avec : ${learn}type -a ls${reset}."; restore=$(expr $restore + 1) ;&
95) echo -n 95 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run "type -a ls" justumen "Non"; restore=$(expr $restore + 1) ;&
96) echo -n 96 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Si vous avez bien en première ligne l'alias ${code}ls --color=auto${reset} et en deuxième ligne ${code}/bin/ls${reset}, un simple ${code}ls${reset} deviendra en fait ${code}/bin/ls --color=auto${reset}"; restore=$(expr $restore + 1) ;&
97) echo -n 97 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Pour revenir sur les variables, savez-vous qu'elle peuvent aussi stocker le ${voc}résultat${reset} d'une commande."; restore=$(expr $restore + 1) ;&
98) echo -n 98 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Il faudra pour cela utiliser le ${code}\$${reset} et les ${code}()${reset}"; restore=$(expr $restore + 1) ;&
99) echo -n 99 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen "Par exemple, pour stocker le résultat de la commande ${code}pwd${reset} dans la variable 'var', faites : ${learn}var=\$(pwd)${reset}"; restore=$(expr $restore + 1) ;&
100) echo -n 100 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run "var=\$(pwd)" justumen "Non"; restore=$(expr $restore + 1) ;&
101) echo -n 101 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen "Maintenant pour vérifier, faites : ${learn}echo \$var;pwd${reset}."; restore=$(expr $restore + 1) ;&
102) echo -n 102 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run "echo \$var;pwd" justumen "Non"; restore=$(expr $restore + 1) ;&
103) echo -n 103 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Vous pouvez également faire la même chose en utilisant les ${code}\`\`${reset}."; restore=$(expr $restore + 1) ;&
104) echo -n 104 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen "Essayez par exemple : ${learn}var=\`ls /var/log/*.log\`${reset}"; restore=$(expr $restore + 1) ;&
105) echo -n 105 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run "var=\`ls /var/log/*.log\`" justumen "Non"; restore=$(expr $restore + 1) ;&
106) echo -n 106 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen "Puis affichez le contenu de la variable 'var'."; restore=$(expr $restore + 1) ;&
107) echo -n 107 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run "echo \$var" justumen "Non"; restore=$(expr $restore + 1) ;&
108) echo -n 108 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Vous pouvez noter ici que l'utilisation de ${code}\$()${reset} et ${code}\`\`${reset} remplacent les mises a la ligne par des espaces !"; restore=$(expr $restore + 1) ;&
109) echo -n 109 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Nous avons déjà vu ${learn}cat${reset} pour afficher le contenu d'un fichier, mais il existe deux autres commandes bien utiles pour l'affichage du contenu des fichiers."; restore=$(expr $restore + 1) ;&
110) echo -n 110 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Il s'agit de ${code}head${reset} et de ${code}tail${reset}, qui affichent respectivement les 10 premières et les 10 dernières lignes d'un fichier."; restore=$(expr $restore + 1) ;&
111) echo -n 111 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "La variable 'var' contient une liste de fichier, vous pouvez donc utiliser cette variable en argument de commande."; restore=$(expr $restore + 1) ;&
112) echo -n 112 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen "Affichez donc par exemple les 10 premières lignes de tous les fichiers dans la variable 'var'."; restore=$(expr $restore + 1) ;&
113) echo -n 113 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run "head \$var" justumen "Non"; restore=$(expr $restore + 1) ;&
114) echo -n 114 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Il est aussi possible de récuperer le résultat d'une commande et d'en faire une variable temporaire qui ne sera pas sauvegardée."; restore=$(expr $restore + 1) ;&
115) echo -n 115 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen "Vous pouvez par exemple faire la même chose sans la variable 'var', avec : ${learn}head \`ls /var/log/*.log\`${reset}"; restore=$(expr $restore + 1) ;&
116) echo -n 116 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run "head \`ls /var/log/*.log\`" justumen "Non"; restore=$(expr $restore + 1) ;&
117) echo -n 117 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Mais bien évidemment, ces deux commandes sont équivalentes à : ${learn}head /var/log/*.log${reset}"; restore=$(expr $restore + 1) ;&
118) echo -n 118 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Mais imaginons par exemple que vous ayiez un fichier 'LOG' qui contient une liste des fichiers qui vous intéresse."; restore=$(expr $restore + 1) ;&
119) echo -n 119 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen "Affichez le contenu du fichier 'LOG'."; restore=$(expr $restore + 1) ;&
120) echo -n 120 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run "cat LOG" justumen "Non"; restore=$(expr $restore + 1) ;&
121) echo -n 121 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Vous pouvez donc directement utiliser ${code}tail${reset} avec le contenu de ce fichier en argument avec : ${code}tail \$(cat LOG)${reset}."; restore=$(expr $restore + 1) ;&
122) echo -n 122 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen "Essayez donc avec la commande équivalente : ${learn}tail \`cat LOG\`${reset}"; restore=$(expr $restore + 1) ;&
123) echo -n 123 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run "tail \`cat LOG\`" justumen "Non"; restore=$(expr $restore + 1) ;&
124) echo -n 124 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Dans cette situation, je vous le rappelle que les mises à la ligne sont remplacés par des espaces."; restore=$(expr $restore + 1) ;&
125) echo -n 125 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "En utilisant cette méthode, le contenu de ce fichier devient une simple chaine de caractères donnée en argument à la commande ${code}tail${reset}."; restore=$(expr $restore + 1) ;&
126) echo -n 126 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "${voc}Méfiez vous${reset} donc des noms de fichiers qui contiennent des espaces ou des caractères spéciaux."; restore=$(expr $restore + 1) ;&
127) echo -n 127 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Si un fichier se nomme par exemple '/var/log/ce fichier.log', il sera donc considéré par ${code}tail${reset} comme deux fichiers/arguments différents : '/var/log/ce' et 'fichier.log'."; restore=$(expr $restore + 1) ;&
128) echo -n 128 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "D'une manière générale, je vous conseille de ne ${voc}jamais${reset} mettre d'espaces dans vos noms de fichiers, surtout si ces fichiers seront manipulés plus tard par un autre programme."; restore=$(expr $restore + 1) ;&
129) echo -n 129 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "'ce fichier.log' peut devenir par exemple 'ce_fichier.log'."; restore=$(expr $restore + 1) ;&
130) echo -n 130 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Mais si 'gamescript' est un alias, comment se fait-il que vous puissiez l'utiliser dans toutes vos instances de bash ?"; restore=$(expr $restore + 1) ;&
131) echo -n 131 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "L'alias 'gamescript' est en fait créé dans le fichier de configuration principal de bash : ${code}~/.bashrc${reset}"; restore=$(expr $restore + 1) ;&
132) echo -n 132 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Bash analyse le contenu de votre fichier caché ${code}~/.bashrc${reset} à chaque lancement."; restore=$(expr $restore + 1) ;&
133) echo -n 133 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen "Vous pouvez retrouver la ligne correspondant à 'gamescript' avec : ${learn}cat ~/.bashrc|grep gamescript${reset}"; restore=$(expr $restore + 1) ;&
134) echo -n 134 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run "cat ~/.bashrc|grep gamescript" justumen "Non"; restore=$(expr $restore + 1) ;&
135) echo -n 135 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Donc si vous voulez avoir des alias ou des variables permanentes, vous pouvez tout simplement les ajouter dans ce fichier."; restore=$(expr $restore + 1) ;&
136) echo -n 136 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "En revanche, n'oubliez pas que 'bash' n'utilise ce fichier qu'à l'ouverture d'une nouvelle session."; restore=$(expr $restore + 1) ;&
137) echo -n 137 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "C'est à dire que si votre session bash était déjà ouverte avant la modification de ce fichier, les changements n'auront pas lieu."; restore=$(expr $restore + 1) ;&
138) echo -n 138 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Pour valider vos modifications, il vous faudra donc ouvrir une nouvelle session bash ou forcer la relecture de ce fichier de configuration avec : ${code}source ~/.bashrc${reset}"; restore=$(expr $restore + 1) ;&
139) echo -n 139 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "La commande ${code}source${reset} peut également être utilisée pour lire les variables dans un fichier et les ajouter dans la session bash actuelle."; restore=$(expr $restore + 1) ;&
140) echo -n 140 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; echo -e 'var=test\nvar2=test2' > $HOME/.GameScript_bash10/variables; restore=$(expr $restore + 1) ;&
141) echo -n 141 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen "Affichez le contenu du fichier 'variables' de votre répertoire courant."; restore=$(expr $restore + 1) ;&
142) echo -n 142 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run "cat variables" justumen "Non"; restore=$(expr $restore + 1) ;&
143) echo -n 143 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen "Affichez les valeur de 'var' et 'var2', séparé par un espace."; restore=$(expr $restore + 1) ;&
144) echo -n 144 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run "echo \$var \$var2" justumen "Non"; restore=$(expr $restore + 1) ;&
145) echo -n 145 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen "Maintenant faites : ${learn}source variables${reset}"; restore=$(expr $restore + 1) ;&
146) echo -n 146 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run "source variables" justumen "Non"; restore=$(expr $restore + 1) ;&
147) echo -n 147 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk_not_press_key justumen "Et réaffichez les valeurs de 'var' et 'var2', séparé par un espace."; restore=$(expr $restore + 1) ;&
148) echo -n 148 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; answer_run "echo \$var \$var2" justumen "Non"; restore=$(expr $restore + 1) ;&
149) echo -n 149 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "Avec cet exemple, vous devriez mieux comprendre l'effet qu'aura la commande ${learn}source ~/.bashrc${reset} : elle actualisera le contenu du fichier ~/.bashrc."; restore=$(expr $restore + 1) ;&
150) echo -n 150 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "${code}source ~/.bashrc${reset} peut aussi s'écrire ${code}. ~/.bashrc${reset}."; restore=$(expr $restore + 1) ;&
151) echo -n 151 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "C'est une syntaxe bien moins lisible que la première, mais vous devez la connaitre car vous risquez de la rencontrer un jour."; restore=$(expr $restore + 1) ;&
152) echo -n 152 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; talk justumen "En avant pour le questionnaire !"; restore=$(expr $restore + 1) ;&
153) echo -n 153 > $HOME/.GameScript/restore_bash10; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash10; clean; restore=$(expr $restore + 1) ;&
esac
}
function clean(){ #in enter_chapter
rm $HOME/.GameScript/restore_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
rm $HOME/.GameScript/restore_pwd_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
	rm $HOME/.GameScript_bash10/variables 2> /dev/null
	rm $HOME/.GameScript_bash10/.MYALIAS 2> /dev/null
	rm $HOME/.GameScript_bash10/LOG 2> /dev/null
	
	
	
	rmdir $HOME/.GameScript_bash10 2> /dev/null
}

function start_quiz(){
  echo ""
  echo -e "\e[15;5;44m Bash 'Bourne Again SHell' : Questionnaire du chapitre 10 \e[0m"
  echo -e "- La réponse doit être la plus courte possible, une commande valide mais ajoutant des caractères inutiles ne fonctionnera pas."
  echo -e "Exemple : si la réponse est 'ls'. Les réponses 'ls .', 'ls ./' et 'ls ././' seront considérées comme fausses."
  answer_text_fr "Comment afficher la commande complète de l'alias 'gamescript' ?" "alias gamescript"
  answer_text_fr "Comment afficher la liste complète de vos alias ?" "alias"
  answer_text_fr "Quel est le nom (sans le $) de la variable d'environnment utilisée par la commande man ?" "PAGER"
  answer_text_fr "Comment afficher les dix dernières lignes du fichier 'test' ?" "tail test"
  answer_text_fr "Comment affecter à la variable RET le code retour (exit status) de la dernière commande ?" 'RET=$?'
  answer_text_fr "Sans utiliser de '.', quelle commande vous permet d'ajouter les variables bash contenu dans le fichier 'VAR' dans votre session bash ?" "source VAR"
  answer_text_fr "Comment afficher les dix premières lignes du fichier 'test' ?" "head test"
  unlock "bash" "10" "aba2" "d414"
}


CHAPTER_NAME="bash"
CHAPTER_NUMBER="10"
LANGUAGE="fr"
SPEAKER="m1"

LINES=152
if [ "$1" == "MUTE" ]; then
	prepare_audio
else
	if [ "$1" == "VIDEO" ]; then
		prepare_video
	fi
fi


enter_chapter $CHAPTER_NAME $CHAPTER_NUMBER
