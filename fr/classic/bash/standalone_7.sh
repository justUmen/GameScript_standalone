#!/bin/bash
#SOME ADDED AND CHANGE IN CLI learn_cli.sh in CLASSIC

function encode_b64(){
	echo -n "$2$1$3" | base64
}

function press_key(){
	echo -en "\e[0;33m...\e[0m"
	read -n1 key < /dev/tty
	if [ "$key" == 'q' ] || [ "$key" == 'e' ]; then
		pkill mpg123  > /dev/null 2>&1
		echo -e "\e[0m "
		exit 1
	fi
	if [ "$key" == 'r' ]; then
		pkill mpg123  > /dev/null 2>&1
		normal_line $restore
	fi
	pkill mpg123
}

#	echo -en "\e[0;33m...\e[0m "
function talk(){
	echo -e "($restore)\e[0;32m $1\e[0m - $2"
	#~ echo -n "$restore" > ~/PERSONAL_PROGRESS
	press_key
	restore=$(expr $restore + 1)
}
function talk_not_press_key(){
	echo -e "($restore)\e[0;32m $1\e[0m - $2"
	restore=$(expr $restore + 1)
}
function talk_not_press_key_ASNWER(){
	echo -en "($restore)\e[0;32m $1\e[0m - "
	echo -ne "\\e[4;37m"
	echo -nE "$2"
	echo -e "\\e[0m"
	restore=$(expr $restore + 1)
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
		echo -en "\\e[1;31;45m # \\e[0m"
		read key < /dev/tty
		case $key in
			1) enter_chapter "$7" "$4";;
			2) enter_chapter "$7" "$5";;
			3) enter_chapter "$7" "$6";;
		esac
	done
}
function answer_text_fr(){
	echo "> $1"
	echo -en "\\e[1;31;45m # \\e[0m"
	read -r USER_CODE < /dev/tty
	if [ ! "$USER_CODE" == "$2" ]; then
		talk_not_press_key justumen "\\e[4;37mDésolé, réponse fausse ou trop longue. Je vous conseille de suivre le cours.\\e[0m"
		exit
	else
		talk_not_press_key justumen "Correct !"
	fi
}
function answer_run(){
	echo -en "\\e[1;31;45m # \\e[0m"
	read -r USER_CODE < /dev/tty
	while [ ! "$USER_CODE" == "$1" ]; do
		#$3 is the correct answer
		#~ talk_not_press_key "$2" "$3 \\e[4;37m$1\\e[0m"
		#~ talk_not_press_key "$2" "\\e[4;37m$1\\e[0m"
		talk_not_press_key_ASNWER "$2" "$1"
		echo -en "\\e[1;31;45m # \\e[0m"
		read -r USER_CODE < /dev/tty
	done
	if [ ! "$1" == "" ];then
		echo -e "\e[1m"
		printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
		#??? remplacer ~ par $HOME ???
		#~ if [ "$1" == "rmdir ~/.GameScript_bash2" ];then
			#~ rmdir ${HOME}/.GameScript_bash2
		#~ else
			#~ if [ "$1" == "cd ~" ];then
				#~ cd ${HOME}
			#~ else
				#$1
			#~ fi
		#~ fi
		#SIMPLE REPLACE BY EVAL (test bash 2 ???)
		eval "$1"
		printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
		echo -e "\\e[0m"
	fi
	restore=$(expr $restore + 1)
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

function justumen_intro_fr(){
echo -e "
Bonjour,
Vous êtes ici dans un ${voc}terminal${reset} linux.
Ce fichier que vous avez lancé est un script bash qui peut vous aider a apprendre le ${voc}bash${reset}.
Bash est le ${voc}shell${reset} par défaut de la grande majorité des systèmes linux.
Ce script est interactif :
  Lorsque vous voyez \e[0;33m...\e[0m le script attend que vous pressiez une touche pour continuer. (comme la touche Espace ou Entrée)
  Lorsque vous voyez \\e[1;31;45m # \\e[0m le script attend que vous tapiez une commande linux. (lettre par lettre)

Le code bash que vous allez taper s'exécutera réellement sur votre machine.
Tous les codes que vous tapez sont donc strictement controlés, il ne laissera passer qu'une seule commande, ce n'est donc pas un véritable terminal.

Tous les chapitres fonctionneront de la même manière :
  Au début vous devez choisir entre 'accéder au cours' ou 'accéder au questionnaire'.

Si vous pensez ne pas avoir besoin du cours, vous pouvez directement aller au questionnaire.
Si vous répondez parfaitement au questionnaire, vous pourrez donc débloquer le prochain niveau sans avoir besoin du cours.

En revanche si vous devez suivre le cours, le questionnaire reviendra à la fin et vous aurez aussi besoin d'y répondre parfaitement pour allez plus loin.

Si le contenu du cours est nouveau pour vous, n'hésitez pas à relancer ce script à plusieures reprises, notamment à des intervalles de temps différentes.
Par exemple, une fois aujourd'hui, une autre fois demain et une autre la semaine prochaine. Le contenu doit être entièrement assimillé avant d'aller plus loin.
Ne passez pas trop vite au niveau suivant si votre compréhension du cours précédent est incertaine.

Je vous recommande de ne pas quitter un cours au milieu, même si pouvez le faire avec CTRL + C.
Le script nettoie derrière lui tout ce qu'il a créé, si vous coupez le script au milieu il vous faudra donc nettoyer manuellement.

Bonne journée et bonne chance !

Merci de soutenir mes cours et mes projets sur https://www.patreon.com/justumen
Et merci de me signalez les bugs si vous en trouvez.
Justumen
"
}


#OBSOLETE ?
restore=2 #first line of LIST_4GEN should be environment test (test ~/House)
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
	restore=$(expr $restore + 1)
}







function unlock(){
	#Usage : unlock "bash" "1" "24d8" "f016"
  # talk_not_press_key justumen "Pour débloquer \"$1 $2\" dans le chat, veuillez saisir votre pseudo :"
  # PSEUDO=""
  # while [[ $PSEUDO = "" ]]; do
  #   echo -en "\e[1;31;42m # \e[0m"
  #   read -r PSEUDO < /dev/tty
  # done
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
	case $2 in
		# 1) echo -en "\e[0;33m...\e[0m" ;&
		1) echo "" ;&
		2) echo -e "\e[15;5;44m - $1, Chapitre $2 \e[0m" ;&
		3) answer_quiz "Cours" "Questionnaire" "Retour" "4" "5" "6" "$1" ;;
		4) code ;; #generated by GEN.all
		5) quiz ;;
		6) exit ;;
	esac
}
function code(){
[ -d "$HOME/.GameScript_bash7" ] && echo "Erreur innatendu, ${HOME}/.GameScript_bash7 existe déjà sur votre système ! Supprimez ce dossier $HOME/.GameScript_bash7 et relancer ce script." && exit
mkdir $HOME/.GameScript_bash7
cd $HOME/.GameScript_bash7
talk justumen ""
talk justumen "Par convention"
talk justumen ""
rmdir $HOME/.GameScript_bash7/
talk justumen ""
talk justumen ""
talk justumen ""
talk justumen ""
talk justumen "stdout"
talk justumen "stdin"
talk justumen ""|", like ">" but for other commands"
talk justumen ""<" + filename"
talk justumen ""<<" (EOF ?)"
talk justumen ""1>""
talk justumen ""2>""
talk justumen ""&>" 1+2"
talk justumen ""2>&1""
talk justumen ""1>&2""
talk justumen ""|&" pipe error"
talk justumen ""/dev/null""
talk justumen "command < input-file > output-file"
talk justumen "ls -y >> c.log 2>&1 VS ls -y 2>&1 >> c.log"
}
function quiz(){
  echo ""
  echo -e "\e[15;5;44m Bash 'Bourne Again SHell' : Questionnaire du chapitre 7 \e[0m"
  echo -e "- La réponse doit être la plus courte possible, une commande valide mais ajoutant des caractères inutiles ne fonctionnera pas."
  echo -e "Exemple : si la réponse est 'ls'. Les réponses 'ls .', 'ls ./' et 'ls ././' seront considérées comme fausses."
  talk_not_press_key justumen "Bash 'Bourne Again SHell' : Chapitre 6"
  talk_not_press_key justumen "- La réponse doit être la plus courte possible, une commande valide mais ajoutant des caractères inutiles ne fonctionnera pas."
  talk_not_press_key justumen "Exemple : si la réponse est 'ls'. Les réponses 'ls .', 'ls ./' et 'ls ././' seront considérées comme fausses."
  answer_text_fr "" ""
  unlock
}


enter_chapter bash 7 1
