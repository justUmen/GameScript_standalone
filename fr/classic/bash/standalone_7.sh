#!/bin/bash
#SOME ADDED AND CHANGE IN CLI learn_cli.sh in CLASSIC

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

function new_sound(){
	pkill mplayer &> /dev/null
	pkill mpg123 &> /dev/null
	$SOUNDPLAYER "$AUDIO_LOCAL/$restore.mp3" &> /dev/null &
	( wget -nc $AUDIO_DL/`expr $restore + 1`.mp3 -O $HOME/.GameScript/Audio/fr/$CHAPTER_NAME/c$CHAPTER_NUMBER/`expr $restore + 1`.mp3 || wget -nc $AUDIO_DL/`expr $restore + 2`.mp3 -O $HOME/.GameScript/Audio/fr/$CHAPTER_NAME/c$CHAPTER_NUMBER/`expr $restore + 2`.mp3 ) &> /dev/null & #download next one, or the one after if it doesn't exist
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
		echo -e "\\e[0;100m 1) \\e[0m $1"
		echo -e "\\e[0;100m 2) \\e[0m $2"
		echo -e "\\e[0;100m 3) \\e[0m $3"
		echo -en "\\e[1;15;45m # \\e[0m"
		read key < /dev/tty
		case $key in
			1) 	CHAPTER_FOLDER=".GameScript_$7$8"
				if [ -d "$HOME/$CHAPTER_FOLDER" ];then
					echo "$CHAPTER_FOLDER existe déjà, continuer ou recommencer le cours du début ?"
					while [ "$choice" != "1" ] || [ "$choice" != "2" ] || [ "$choice" != "3" ]; do
						echo -e "\\e[0;100m 1) \\e[0m Continuer"
						echo -e "\\e[0;100m 2) \\e[0m Recommencer"
						echo -e "\\e[0;100m 3) \\e[0m Retour"
						echo -en "\\e[1;15;45m # \\e[0m"
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
	echo -en "\\e[1;15;45m # \\e[0m"
	read -r USER_CODE < /dev/tty
	if [ ! "$USER_CODE" == "$2" ]; then
		talk_not_press_key justumen "\\e[4;37mDésolé, réponse fausse ou trop longue. Je vous conseille de suivre le cours.\\e[0m"
		exit
	else
		talk_not_press_key justumen "Correct !"
	fi
}
function answer_run(){
	echo -en "\\e[1;15;45m # \\e[0m"
	read -r USER_CODE < /dev/tty
	while [ ! "$USER_CODE" == "$1" ]; do
		if [ ! "$USER_CODE" == "" ]; then
			talk_not_press_key_ANSWER "$2" "$1"
		fi
		echo -en "\\e[1;15;45m # \\e[0m"
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
On_Black='\e[40m'
reset='\e[0m'

basic=$On_Black
code=$black_on_lightblue
codeFile=$black_on_green
codeError=$black_on_red

#UNDERLINE
voc='\e[1m'
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
	talk_not_press_key justumen "Allez sur https://rocket.bjornulf.org/direct/boti et copiez/collez : password$PASS"
	touch "$HOME/.GameScript/good_$1$2" 2> /dev/null
	mkdir $HOME/.GameScript/passwords/ 2> /dev/null
	echo -n "$PASS" > "$HOME/.GameScript/passwords/$1$2"
	exit
}

function enter_chapter(){
	#Usage : enter_chapter bash 1 1 (first 1 is chapter, next one is for case)
	echo ""
	echo -e "\e[15;5;44m - $1, Chapitre $2 \e[0m"
	answer_quiz "Cours" "Questionnaire" "Retour" "4" "5" "6" "$1" "$2"
}
function start_lecture(){
restore=$1
case $1 in
1) echo -n 1 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; [ -d "$HOME/.GameScript_bash7" ] && echo "Erreur innatendu, ${HOME}/.GameScript_bash7 existe déjà sur votre système ! Supprimez ce dossier $HOME/.GameScript_bash7 et relancer ce script." && exit; restore=$(expr $restore + 1) ;&
2) echo -n 2 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; mkdir $HOME/.GameScript_bash7 && mkdir -p $HOME/.GameScript/Audio/fr/bash/c7/ && wget -q -nc $AUDIO_DL/4.mp3 -O $HOME/.GameScript/Audio/fr/bash/c7/4.mp3 > /dev/null 2>&1; restore=$(expr $restore + 1) ;&
3) echo -n 3 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; cd $HOME/.GameScript_bash7; restore=$(expr $restore + 1) ;&
4) echo -n 4 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen ""; restore=$(expr $restore + 1) ;&
5) echo -n 5 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "Par convention"; restore=$(expr $restore + 1) ;&
6) echo -n 6 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen ""; restore=$(expr $restore + 1) ;&
7) echo -n 7 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; rmdir $HOME/.GameScript_bash7/; restore=$(expr $restore + 1) ;&
8) echo -n 8 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen ""; restore=$(expr $restore + 1) ;&
9) echo -n 9 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen ""; restore=$(expr $restore + 1) ;&
10) echo -n 10 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen ""; restore=$(expr $restore + 1) ;&
11) echo -n 11 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen ""; restore=$(expr $restore + 1) ;&
12) echo -n 12 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "stdout"; restore=$(expr $restore + 1) ;&
13) echo -n 13 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "stdin"; restore=$(expr $restore + 1) ;&
14) echo -n 14 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen ""|", like ">" but for other commands"; restore=$(expr $restore + 1) ;&
15) echo -n 15 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen ""<" + filename"; restore=$(expr $restore + 1) ;&
16) echo -n 16 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen ""<<" (EOF ?)"; restore=$(expr $restore + 1) ;&
17) echo -n 17 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen ""1>""; restore=$(expr $restore + 1) ;&
18) echo -n 18 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen ""2>""; restore=$(expr $restore + 1) ;&
19) echo -n 19 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen ""&>" 1+2"; restore=$(expr $restore + 1) ;&
20) echo -n 20 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen ""2>&1""; restore=$(expr $restore + 1) ;&
21) echo -n 21 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen ""1>&2""; restore=$(expr $restore + 1) ;&
22) echo -n 22 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen ""|&" pipe error"; restore=$(expr $restore + 1) ;&
23) echo -n 23 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen ""/dev/null""; restore=$(expr $restore + 1) ;&
24) echo -n 24 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "command < input-file > output-file"; restore=$(expr $restore + 1) ;&
25) echo -n 25 > $HOME/.GameScript/restore_bash7; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash7; talk justumen "ls -y >> c.log 2>&1 VS ls -y 2>&1 >> c.log"; restore=$(expr $restore + 1) ;&
esac
}
function clean(){ #in enter_chapter
rm $HOME/.GameScript/restore_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
rm $HOME/.GameScript/restore_pwd_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
	rmdir $HOME/.GameScript_bash 2> /dev/null
}

function start_quiz(){
  echo ""
  echo -e "\e[15;5;44m Bash 'Bourne Again SHell' : Questionnaire du chapitre 7 \e[0m"
  echo -e "- La réponse doit être la plus courte possible, une commande valide mais ajoutant des caractères inutiles ne fonctionnera pas."
  echo -e "Exemple : si la réponse est 'ls'. Les réponses 'ls .', 'ls ./' et 'ls ././' seront considérées comme fausses."
  talk_not_press_key justumen "Bash 'Bourne Again SHell' : Chapitre 6"
  talk_not_press_key justumen "- La réponse doit être la plus courte possible, une commande valide mais ajoutant des caractères inutiles ne fonctionnera pas."
  talk_not_press_key justumen "Exemple : si la réponse est 'ls'. Les réponses 'ls .', 'ls ./' et 'ls ././' seront considérées comme fausses."
  answer_text_fr "" ""
  unlock "bash" "7" "1109" "ff12"
}


CHAPTER_NAME="bash"
CHAPTER_NUMBER="7"

enter_chapter $CHAPTER_NAME $CHAPTER_NUMBER
