#!/bin/bash
#SOME ADDED AND CHANGE IN CLI learn_cli.sh in CLASSIC

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
function talk(){
	if [[ $MUTE == 0 ]]; then 
		new_sound
	fi
	echo -e "($restore)\e[0;32m $1\e[0m - $2"
	press_key
}
function talk_not_press_key(){
	if [[ $MUTE == 0 ]]; then 
		new_sound
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
			0) download_all_sounds ;;
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
function answer_text_fr(){
	echo "> $1"
	echo -en "\\e[97;45m # \\e[0m"
	read -r USER_CODE < /dev/tty
	if [ ! "$USER_CODE" == "$2" ]; then
		talk_not_press_key justumen "\\e[4;37mDésolé, réponse fausse ou trop longue. Je vous conseille de suivre / refaire le cours.\nSi vous pensez maitriser le contenu du cours, il y a surement un piège, relisez donc attentivement la question. :-)\nSi vous vous sentez vraiment bloqué, demandez de l'aide sur notre chat.\\e[0m"
		#enter_chapter $CHAPTER_NAME $CHAPTER_NUMBER
		exit
	else
		talk_not_press_key justumen "Correct !"
	fi
}
function answer_run(){
	echo -en "\\e[97;45m # \\e[0m"
	read -r USER_CODE < /dev/tty
	while [ ! "$USER_CODE" == "$1" ]; do
		if [ ! "$USER_CODE" == "" ]; then
			talk_not_press_key_ANSWER "$2" "$1"
		fi
		echo -en "\\e[97;45m # \\e[0m"
		read -r USER_CODE < /dev/tty
	done
	if [ ! "$1" == "" ];then
		echo -e "\e[1m"
		printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
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
	talk_not_press_key justumen "Pour débloquer '$1 $2' sur le chat, ouvrez une conversation privée avec 'boti' et copiez/collez :\n\t\e[97;42mpassword$PASS\e[0m"
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
function start_lecture(){
restore=$1
case $1 in
1) echo -n 1 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; [ -d "$HOME/.GameScript_bash3" ] && echo "Erreur innatendu, ${HOME}/.GameScript_bash3 existe déjà sur votre système ! Supprimez ce dossier $HOME/.GameScript_bash3 et relancer ce script." && exit; restore=$(expr $restore + 1) ;&
2) echo -n 2 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; mkdir $HOME/.GameScript_bash3 2> /dev/null; restore=$(expr $restore + 1) ;&
3) echo -n 3 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; cd $HOME/.GameScript_bash3; restore=$(expr $restore + 1) ;&
4) echo -n 4 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Dans le chapitre 2, nous avons vu que les options peuvent avoir deux formes, l'une courte comme dans ${learn}ls -l${reset}, et l'autre longue comme dans ${learn}ls --all${reset}."; restore=$(expr $restore + 1) ;&
5) echo -n 5 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Si vous avez plusieures options à passer à la même commande, vous pouvez les mettre les unes à la suite des autres : ${learn}ls -a -w 1${reset}."; restore=$(expr $restore + 1) ;&
6) echo -n 6 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk_not_press_key justumen "Essayez donc avec cet exemple : ${learn}ls -a -w 1${reset}"; restore=$(expr $restore + 1) ;&
7) echo -n 7 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; answer_run "ls -a -w 1" justumen "Non"; restore=$(expr $restore + 1) ;&
8) echo -n 8 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Vous pouvez bien évidemment utiliser les versions longues de la même manière, ou même les mélanger avec des options courtes."; restore=$(expr $restore + 1) ;&
9) echo -n 9 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk_not_press_key justumen "Essayez donc de faire la même chose avec : ${learn}ls -a --width=1${reset}"; restore=$(expr $restore + 1) ;&
10) echo -n 10 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; answer_run "ls -a --width=1" justumen "Non"; restore=$(expr $restore + 1) ;&
11) echo -n 11 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Mais n'oubliez pas les options courtes commencent par ${code}-${reset} et les options longues commencent par ${code}--${reset}."; restore=$(expr $restore + 1) ;&
12) echo -n 12 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Si vous utilisez les options courtes, vous pouvez également les regrouper avec le même ${code}-${reset}."; restore=$(expr $restore + 1) ;&
13) echo -n 13 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Par exemple pour passez l'option ${code}-a${reset} et l'option ${code}-w 10${reset} à ${code}ls${reset}, vous pouvez tapez ${code}ls -aw 10${reset}"; restore=$(expr $restore + 1) ;&
14) echo -n 14 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk_not_press_key justumen "Essayez donc cette commande : ${learn}ls -aw 10${reset}"; restore=$(expr $restore + 1) ;&
15) echo -n 15 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; answer_run "ls -aw 10" justumen "Non"; restore=$(expr $restore + 1) ;&
16) echo -n 16 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Attention donc à ne pas oublier qu'il y a deux ${code}-${reset} avant les options longues."; restore=$(expr $restore + 1) ;&
17) echo -n 17 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Les commandes ${learn}ls --all${reset} et ${learn}ls -all${reset} ne sont pas du tout identiques."; restore=$(expr $restore + 1) ;&
18) echo -n 18 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "${learn}ls --all${reset} est identique à ${learn}ls -a${reset}."; restore=$(expr $restore + 1) ;&
19) echo -n 19 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Mais ${learn}ls -all${reset} est identique à ${learn}ls -a -l -l${reset}"; restore=$(expr $restore + 1) ;&
20) echo -n 20 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk_not_press_key justumen "Ouvrez maintenant le manuel de ${code}ls${reset} et cherchez l'option pour afficher son numéro de version."; restore=$(expr $restore + 1) ;&
21) echo -n 21 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; answer_run "man ls" justumen "Non"; restore=$(expr $restore + 1) ;&
22) echo -n 22 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk_not_press_key justumen "Affichez le numéro de version de ${code}ls${reset}."; restore=$(expr $restore + 1) ;&
23) echo -n 23 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; answer_run "ls --version" justumen "Non"; restore=$(expr $restore + 1) ;&
24) echo -n 24 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Parfait !"; restore=$(expr $restore + 1) ;&
25) echo -n 25 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "GameScript affiche en ce moment du texte dans votre terminal."; restore=$(expr $restore + 1) ;&
26) echo -n 26 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "GameScript utilisant les mêmes commandes, laquelle est utilisée ici pour affichez ces phrases ?"; restore=$(expr $restore + 1) ;&
27) echo -n 27 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Pour afficher quelque chose dans un terminal, il vous faudra utiliser la commande ${code}echo${reset}."; restore=$(expr $restore + 1) ;&
28) echo -n 28 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk justumen "Cette commande vous renverra simplement un écho de ce que vous lui avez donné en argument."; restore=$(expr $restore + 1) ;&
29) echo -n 29 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk_not_press_key justumen "Affichez donc le mot 'bonjour' dans votre terminal avec la commande : ${learn}echo bonjour${reset}"; restore=$(expr $restore + 1) ;&
30) echo -n 30 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; answer_run "echo bonjour" justumen "Non"; restore=$(expr $restore + 1) ;&
31) echo -n 31 > $HOME/.GameScript/restore_bash3; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash3; talk_not_press_key justumen "La commande ${code}echo${reset} accepte plusieurs arguments, vous pouvez tester : ${learn}echo bonjour tout le monde${reset}"; restore=$(expr $restore + 1) ;&
