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
	( mplayer -af volume=10 "$AUDIO_LOCAL/$AUDIOCMP.mp3" || mpg123 --scale 100000 "$AUDIO_LOCAL/$AUDIOCMP.mp3" ) &> /dev/null &
	(
		wget -nc $AUDIO_DL/`expr $restore + 1`.mp3 -O $HOME/.GameScript/Audio/fr/$CHAPTER_NAME/c$CHAPTER_NUMBER/`expr $restore + 1`.mp3 \
		|| \
		wget -nc $AUDIO_DL/`expr $restore + 2`.mp3 -O $HOME/.GameScript/Audio/fr/$CHAPTER_NAME/c$CHAPTER_NUMBER/`expr $restore + 2`.mp3
	) &> /dev/null & #download next one, or the one after if it doesn't exist
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
		echo -en "\\e[1;31;45m # \\e[0m"
		read key < /dev/tty
		case $key in
			1) 	CHAPTER_FOLDER=".GameScript_$7$8"
				if [ -d "$HOME/$CHAPTER_FOLDER" ];then
					echo "$CHAPTER_FOLDER existe déjà, continuer ou recommencer le cours du début ?"
					while [ "$choice" != "1" ] || [ "$choice" != "2" ] || [ "$choice" != "3" ]; do
						echo -e "\\e[0;100m 1) \\e[0m Continuer"
						echo -e "\\e[0;100m 2) \\e[0m Recommencer"
						echo -e "\\e[0;100m 3) \\e[0m Retour"
						echo -en "\\e[1;31;45m # \\e[0m"
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
		if [ ! "$USER_CODE" == "" ]; then
			talk_not_press_key_ANSWER "$2" "$1"
		fi
		echo -en "\\e[1;31;45m # \\e[0m"
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
1) echo -n 1 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; [ -d "$HOME/House" ] && echo "Erreur innatendu, ${HOME}/House existe déjà sur votre système ! Supprimez ce dossier $HOME/House et relancer ce script." && exit; restore=$(expr $restore + 1) ;&
2) echo -n 2 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; mkdir $HOME/.GameScript_bash1 && mkdir -p $HOME/.GameScript/Audio/fr/bash/c1/ && wget -q -nc $AUDIO_DL/4.mp3 -O $HOME/.GameScript/Audio/fr/bash/c1/4.mp3 > /dev/null 2>&1; restore=$(expr $restore + 1) ;&
3) echo -n 3 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; cd $HOME/; restore=$(expr $restore + 1) ;&
4) echo -n 4 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Hey salut tout le monde et bienvenu dans le premier chapitre sur bash."; restore=$(expr $restore + 1) ;&
5) echo -n 5 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Avant de pouvoir apprendre notre première commande, il va falloir d'abord comprendre la logique derrière l'organisation des répertoires et des fichiers sur les systèmes d'exploitation de ${voc}type Unix${reset}, comme ${voc}Linux${reset}."; restore=$(expr $restore + 1) ;&
6) echo -n 6 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Commençons par nous intéresser aux 'répertoires', qui portent aussi le nom de 'dossiers'."; restore=$(expr $restore + 1) ;&
7) echo -n 7 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; real_tree_1; restore=$(expr $restore + 1) ;&
8) echo -n 8 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Vous pouvez imaginer le système d'organisation des dossiers comme un arbre."; restore=$(expr $restore + 1) ;&
9) echo -n 9 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Dans cet arbre les lignes qui représentent les dossiers sont en bleu ciel."; restore=$(expr $restore + 1) ;&
10) echo -n 10 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "A la base de l'arbre vous avez le symbole ${code}/${reset} qui représente le ${voc}répertoire racine${reset}."; restore=$(expr $restore + 1) ;&
11) echo -n 11 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "C'est un répertoire spécial qui contiendra TOUS les autres dossiers du système."; restore=$(expr $restore + 1) ;&
12) echo -n 12 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; real_tree_2; restore=$(expr $restore + 1) ;&
13) echo -n 13 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Dans cet arbre, à chaque fois qu'une branche se sépare de l'arbre, c'est un nouveau dossier."; restore=$(expr $restore + 1) ;&
14) echo -n 14 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Ce passage à une autre branche se remarque aussi dans les titres en bleu ciel avec l'apparition d'un nouveau symbole '/' supplémentaire."; restore=$(expr $restore + 1) ;&
15) echo -n 15 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Par exemple, ${code}/home/${reset} représente le dossier 'home' dans le ${voc}répertoire racine${reset}."; restore=$(expr $restore + 1) ;&
16) echo -n 16 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "${code}/home/user/${reset} représente le dossier 'user', qui est dans le dossier 'home', qui est lui même dans le ${voc}répertoire racine${reset}."; restore=$(expr $restore + 1) ;&
17) echo -n 17 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Et ainsi de suite, comme par exemple : ${code}/home/user/Images/${reset}"; restore=$(expr $restore + 1) ;&
18) echo -n 18 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Dans ce cas, 'Images' est dans 'user', 'user' est dans 'home' et 'home' est dans '/'."; restore=$(expr $restore + 1) ;&
19) echo -n 19 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Mais attention, pour représenter un répertoire, il n'est pas obligatoire de rajouter un '/' à la fin."; restore=$(expr $restore + 1) ;&
20) echo -n 20 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "C'est à dire que ${learn}/home/user/${reset} est équivalent à ${learn}/home/user${reset}."; restore=$(expr $restore + 1) ;&
21) echo -n 21 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "De même, ${learn}/home/${reset} et ${learn}/home${reset} sont équivalents."; restore=$(expr $restore + 1) ;&
22) echo -n 22 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; real_tree_3; restore=$(expr $restore + 1) ;&
23) echo -n 23 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Parlons maintenant des fichiers, dans mon arbre ils sont ici en vert. Ce sont dans mon exemple des 'feuilles' et sont directement acrochés à une branche, ou parfois même directement au tronc."; restore=$(expr $restore + 1) ;&
24) echo -n 24 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Ces fichiers appartiennent donc directement à un dossier. Mais nous avons ici quelques problèmes en rouge, des fichiers qui ne peuvent pas exister..."; restore=$(expr $restore + 1) ;&
25) echo -n 25 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "${codeError}fichier1${reset} ne peut pas exister car il y a déjà un fichier du même nom ${codeFile}fichier1${reset} dans le même répertoire. Ici le répertoire racine. (/fichier1)"; restore=$(expr $restore + 1) ;&
26) echo -n 26 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "En revanche, en haut, ${codeFile}fichier1${reset} peut exister car même si le nom du fichier est le même, ils ne sont pas dans le même dossier."; restore=$(expr $restore + 1) ;&
27) echo -n 27 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Les éléments d'un système de type Unix doivent avoir une référence unique : ici ${learn}/fichier1${reset} et ${learn}/home/fichier1${reset} ne sont pas en conflit."; restore=$(expr $restore + 1) ;&
28) echo -n 28 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Le fichier ${codeError}/home${reset} ne peut pas exister non plus car il y a déjà un dossier ${code}/home/${reset} qui utilise le même nom au même endroit."; restore=$(expr $restore + 1) ;&
29) echo -n 29 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Pour que ces fichiers puissent exister, il faut leur donner d'autres noms."; restore=$(expr $restore + 1) ;&
30) echo -n 30 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; real_tree_4; restore=$(expr $restore + 1) ;&
31) echo -n 31 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Ici, il suffit d'appeler le deuxième fichier 'fichier2' et le tour est joué."; restore=$(expr $restore + 1) ;&
32) echo -n 32 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Pour ${codeError}home${reset}, il suffit également de lui donner un autre nom qui ne pose pas de problème comme 'Home', avec un h majuscule."; restore=$(expr $restore + 1) ;&
33) echo -n 33 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Oui ! Dans un système d'exploitation de type Unix, les majuscules sont importantes. 'Home', avec un grand H et 'home' sont deux noms différents."; restore=$(expr $restore + 1) ;&
34) echo -n 34 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "En informatique, quand les majuscules ne sont pas équivalentes au minuscules, on dit que les noms sont ${voc}sensibles à la casse${reset}."; restore=$(expr $restore + 1) ;&
35) echo -n 35 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Effectivement, les systèmes de type Unix sont ${voc}sensibles à la casse${reset}. C'est à dire que 'home', 'Home', 'hOme', 'hoMe', 'homE', 'HoMe', 'hOmE', 'HOme', 'hoME', 'HomE', 'hOMe', 'HOME', etc... sont valides et différents !"; restore=$(expr $restore + 1) ;&
36) echo -n 36 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; tree_1; restore=$(expr $restore + 1) ;&
37) echo -n 37 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Il est aussi possible de représenter l'arborescence linux de cette manière."; restore=$(expr $restore + 1) ;&
38) echo -n 38 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; tree_2; restore=$(expr $restore + 1) ;&
39) echo -n 39 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Et ici le même exemple avec les fichiers. Identique à l'arbre que l'on a déjà vu."; restore=$(expr $restore + 1) ;&
40) echo -n 40 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; tree_3; restore=$(expr $restore + 1) ;&
41) echo -n 41 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Mais l'arborescence peut aussi être très claire sans les décalages."; restore=$(expr $restore + 1) ;&
42) echo -n 42 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Si ça n'est pas encore très intuitif pour vous, ne vous inquiétez pas."; restore=$(expr $restore + 1) ;&
43) echo -n 43 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Maintenant que vous connaissez la logique, avec le temps et la répétition ce sera pour vous très bientôt évident."; restore=$(expr $restore + 1) ;&
44) echo -n 44 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Ce genre de ligne, qui commence par ce '/' ou ${voc}répertoire racine${reset} s'appelle le ${voc}chemin absolu${reset} d'un fichier ou d'un dossier."; restore=$(expr $restore + 1) ;&
45) echo -n 45 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Elle représente avec précision uniquement le fichier ou dossier en question."; restore=$(expr $restore + 1) ;&
46) echo -n 46 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Ici il est impossible d'avoir deux lignes identiques."; restore=$(expr $restore + 1) ;&
47) echo -n 47 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Ce ${voc}chemin absolu${reset} est le concept le plus fondamental de la ligne de commande."; restore=$(expr $restore + 1) ;&
48) echo -n 48 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Maintenant nous pouvons voir notre première commande."; restore=$(expr $restore + 1) ;&
49) echo -n 49 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Commençons par créer un nouveau dossier avec la commande ${learn}mkdir${reset} (mkdir vient de l'anglais ${learn}M${reset}a${learn}K${reset}e ${learn}DIR${reset}ectory)."; restore=$(expr $restore + 1) ;&
50) echo -n 50 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Il suffit de taper mkdir, suivi d'un espace et enfin du nom du dossier."; restore=$(expr $restore + 1) ;&
51) echo -n 51 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk_not_press_key justumen "Créeons maintenant le dossier House en faisant : ${learn}mkdir House${reset} puis validez la commande en appuyant sur la touche entrée."; restore=$(expr $restore + 1) ;&
52) echo -n 52 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; answer_run "mkdir House" justumen "Non"; restore=$(expr $restore + 1) ;&
53) echo -n 53 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk_not_press_key justumen "Affichons maintenant les dossiers et les fichiers avec un simple ${learn}ls${reset} (ls vient de l'anglais ${learn}L${reset}i${learn}S${reset}t)."; restore=$(expr $restore + 1) ;&
54) echo -n 54 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; answer_run "ls" justumen "Non"; restore=$(expr $restore + 1) ;&
55) echo -n 55 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Vous devriez voir le dossier que vous venez de créer."; restore=$(expr $restore + 1) ;&
56) echo -n 56 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Maintenant rentrons dans ce dossier avec la commande ${learn}cd${reset} (cd vient de l'anglais ${learn}C${reset}hange ${learn}D${reset}irectory)."; restore=$(expr $restore + 1) ;&
57) echo -n 57 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk_not_press_key justumen "Pour cela, il suffit de faire ${code}cd${reset}, suivi du nom du dossier voulu, dans notre cas : ${learn}cd House${reset}."; restore=$(expr $restore + 1) ;&
58) echo -n 58 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; answer_run "cd House" justumen "Non"; restore=$(expr $restore + 1) ;&
59) echo -n 59 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk_not_press_key justumen "Maintenant réaffichons les fichiers et dossiers avec un simple ${learn}ls${reset}."; restore=$(expr $restore + 1) ;&
60) echo -n 60 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; answer_run "ls" justumen "Non"; restore=$(expr $restore + 1) ;&
61) echo -n 61 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Ici le répertoire House est vide, c'est normal puisque nous venons de le créer."; restore=$(expr $restore + 1) ;&
62) echo -n 62 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Mais qu'en est-il ici du ${voc}chemin absolu${reset} dont je vous ai parlé avant ?"; restore=$(expr $restore + 1) ;&
63) echo -n 63 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "En fait, un terminal tourne toujours dans un dossier, et peut se 'déplacer' dans l'arborescense du système."; restore=$(expr $restore + 1) ;&
64) echo -n 64 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "C'est ce que vous avez fait avec la commande ${learn}cd House${reset}, vous avez déplacé votre terminal dans le dossier House."; restore=$(expr $restore + 1) ;&
65) echo -n 65 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk_not_press_key justumen "Pour savoir dans quel répertoire votre terminal est en ce moment, il suffit de taper ${learn}pwd${reset} (pwd vient de l'anglais ${learn}P${reset}rint ${learn}W${reset}orking ${learn}D${reset}irectory)."; restore=$(expr $restore + 1) ;&
66) echo -n 66 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; answer_run "pwd" justumen "Non"; restore=$(expr $restore + 1) ;&
67) echo -n 67 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Le résultat que vous voyiez ici est le ${voc}chemin absolu${reset} du répertoire ou vous êtes en ce moment."; restore=$(expr $restore + 1) ;&
68) echo -n 68 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Ce répertoire où vous êtes porte un nom spécial : c'est votre ${voc}${voc}répertoire courant${reset}."; restore=$(expr $restore + 1) ;&
69) echo -n 69 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Comme je vous l'ai déjà dit, il n'est pas obligatoire de mettre un '/' pour le dernier dossier c'est pourquoi vous voyez ici ${learn}$(pwd)${reset} sans un '/' à la fin."; restore=$(expr $restore + 1) ;&
70) echo -n 70 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Voilà donc 4 commandes Unix fondamentales : ${learn}pwd${reset}, ${learn}ls${reset}, ${learn}cd${reset} et ${learn}mkdir${reset}."; restore=$(expr $restore + 1) ;&
71) echo -n 71 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "${learn}pwd${reset} et ${learn}ls${reset} sont des commandes particulièrement innoffensives, elle ne font que vous donnez des renseignements."; restore=$(expr $restore + 1) ;&
72) echo -n 72 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "N'hésitez donc pas à les taper systématiquement, dès que vous êtes dans un terminal."; restore=$(expr $restore + 1) ;&
73) echo -n 73 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "${learn}pwd${reset}, pour savoir quel est votre ${voc}répertoire courant${reset}"; restore=$(expr $restore + 1) ;&
74) echo -n 74 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "et ${learn}ls${reset}, pour afficher le contenu de votre ${voc}répertoire courant${reset}."; restore=$(expr $restore + 1) ;&
75) echo -n 75 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk_not_press_key justumen "Maintenant créons un nouveau répertoire 'Room' dans notre ${voc}répertoire courant${reset} en faisant ${learn}mkdir Room${reset}."; restore=$(expr $restore + 1) ;&
76) echo -n 76 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; answer_run "mkdir Room" justumen "Non"; restore=$(expr $restore + 1) ;&
77) echo -n 77 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk_not_press_key justumen "Changeons de ${voc}répertoire courant${reset} avec ${learn}cd Room${reset}."; restore=$(expr $restore + 1) ;&
78) echo -n 78 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; answer_run "cd Room" justumen "Non"; restore=$(expr $restore + 1) ;&
79) echo -n 79 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk_not_press_key justumen "Maintenant, affichez le chemin absolu de votre ${voc}répertoire courant${reset}."; restore=$(expr $restore + 1) ;&
80) echo -n 80 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; answer_run "pwd" justumen "Non"; restore=$(expr $restore + 1) ;&
81) echo -n 81 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk_not_press_key justumen "Super, et maintenant affichez les éléments du ${voc}répertoire courant${reset}."; restore=$(expr $restore + 1) ;&
82) echo -n 82 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; answer_run "ls" justumen "Non"; restore=$(expr $restore + 1) ;&
83) echo -n 83 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Ici le dossier est vide, mais vous maitrisez maintenant les deux commandes les plus importantes : ${learn}pwd${reset} et ${learn}ls${reset}."; restore=$(expr $restore + 1) ;&
84) echo -n 84 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Les commandes ${learn}cd${reset} et ${learn}mkdir${reset} que nous avons vu ensemble sont plus complexes."; restore=$(expr $restore + 1) ;&
85) echo -n 85 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Il faut leur donner une cible, ou un nom comme par exemple : ${learn}mkdir Room${reset}."; restore=$(expr $restore + 1) ;&
86) echo -n 86 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Cette 'cible' est appelée un ${voc}argument${reset}!"; restore=$(expr $restore + 1) ;&
87) echo -n 87 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Mais il est aussi possible d'avoir des commandes avec plusieurs ${voc}arguments${reset}."; restore=$(expr $restore + 1) ;&
88) echo -n 88 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Il suffit de continuer à les séparer par des espaces."; restore=$(expr $restore + 1) ;&
89) echo -n 89 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk_not_press_key justumen "On va créer les dossiers 'bed', 'closet' et 'desk' en une seule commande. Tapez donc la commande : ${learn}mkdir bed closet desk${reset}"; restore=$(expr $restore + 1) ;&
90) echo -n 90 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; answer_run "mkdir bed closet desk" justumen "Non"; restore=$(expr $restore + 1) ;&
91) echo -n 91 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk_not_press_key justumen "Affichez les éléments du ${voc}répertoire courant${reset}."; restore=$(expr $restore + 1) ;&
92) echo -n 92 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; answer_run "ls" justumen "Non"; restore=$(expr $restore + 1) ;&
93) echo -n 93 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk_not_press_key justumen "Maintenant pour supprimer ces dossiers, vous pouvez taper : ${learn}rmdir bed closet desk${reset}. (rmdir vient de l'anglais ${learn}R${reset}e${learn}M${reset}ove ${learn}DIR${reset}ectory)"; restore=$(expr $restore + 1) ;&
94) echo -n 94 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; answer_run "rmdir bed closet desk" justumen "Non"; restore=$(expr $restore + 1) ;&
95) echo -n 95 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "${learn}rmdir${reset} est une commande plutôt innofensive, parce qu'elle refusera de supprimer un dossier si celui ci n'est pas vide."; restore=$(expr $restore + 1) ;&
96) echo -n 96 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Ce qui peut empêcher de graves accidents. Si par exemple, vous faites par erreur ${learn}rmdir /home${reset}."; restore=$(expr $restore + 1) ;&
97) echo -n 97 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "La commande ${learn}rm${reset} est la commande pour supprimer des fichiers. (rm vient de l'anglais ${learn}R${reset}e${learn}M${reset}ove)"; restore=$(expr $restore + 1) ;&
98) echo -n 98 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; touch virus0 virus1 virus2 virus3 virus4; restore=$(expr $restore + 1) ;&
99) echo -n 99 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Tout comme ${learn}mkdir${reset}, il faudra lui donner en ${voc}argument${reset} le nom du fichier en question, par exemple : ${learn}rm test${reset}."; restore=$(expr $restore + 1) ;&
100) echo -n 100 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk_not_press_key justumen "Il vient de se passer quelque chose de bizarre... Affichez le contenu du ${voc}répertoire courant${reset}."; restore=$(expr $restore + 1) ;&
101) echo -n 101 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; answer_run "ls" justumen "Non"; restore=$(expr $restore + 1) ;&
102) echo -n 102 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk_not_press_key justumen "rmdir${reset} a bien supprimé les dossiers. Mais ces fichiers n'ont rien à faire ici, supprimez le fichier 'virus0' avec ${learn}rm virus0${reset}"; restore=$(expr $restore + 1) ;&
103) echo -n 103 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; answer_run "rm virus0" justumen "Non"; restore=$(expr $restore + 1) ;&
104) echo -n 104 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk_not_press_key justumen "Affichez à nouveau les éléments du ${voc}répertoire courant${reset}, pour voir s'il est toujours là."; restore=$(expr $restore + 1) ;&
105) echo -n 105 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; answer_run "ls" justumen "Non"; restore=$(expr $restore + 1) ;&
106) echo -n 106 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Super, virus0 n'existe plus."; restore=$(expr $restore + 1) ;&
107) echo -n 107 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Mais attention avec la commande ${learn}rm${reset}, c'est une commande dangereuse à ne pas utiliser à la légère."; restore=$(expr $restore + 1) ;&
108) echo -n 108 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Les fichiers sont supprimés directement, il ne vont pas dans une corbeille, donc soyez prudent."; restore=$(expr $restore + 1) ;&
109) echo -n 109 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Une erreur en ligne de commande ne pardonne pas."; restore=$(expr $restore + 1) ;&
110) echo -n 110 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Une faute de frappe ou un ${voc}répertoire courant${reset} innatendu peut avoir de graves conséquences."; restore=$(expr $restore + 1) ;&
111) echo -n 111 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Avant de lancer une commande, soyez donc sûrs de ce que vous faites."; restore=$(expr $restore + 1) ;&
112) echo -n 112 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "N'hésitez jamais a lancer ou relancer ${learn}pwd${reset} et ${learn}ls${reset} pour savoir quel est votre ${voc}répertoire courant${reset} et vérifier son contenu."; restore=$(expr $restore + 1) ;&
113) echo -n 113 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Mais nous avons encore d'autres 'virus' à supprimer. Mais on peut aussi les supprimer d'une autre manière."; restore=$(expr $restore + 1) ;&
114) echo -n 114 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Nous pouvons utiliser son ${voc}chemin absolu${reset}."; restore=$(expr $restore + 1) ;&
115) echo -n 115 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; cd ~/; restore=$(expr $restore + 1) ;&
116) echo -n 116 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Lorsque vous avez tapé ${learn}rm virus0${reset}, vous avez demandé la suppression du fichier 'virus0' dans votre ${voc}répertoire courant${reset}."; restore=$(expr $restore + 1) ;&
117) echo -n 117 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk_not_press_key justumen "Je viens de changer votre ${voc}répertoire courant${reset}. Affichez le maintenant."; restore=$(expr $restore + 1) ;&
118) echo -n 118 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; answer_run "pwd" justumen "Non"; restore=$(expr $restore + 1) ;&
119) echo -n 119 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk_not_press_key justumen "Affichez le contenu de votre ${voc}répertoire courant${reset}."; restore=$(expr $restore + 1) ;&
120) echo -n 120 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; answer_run "ls" justumen "Non"; restore=$(expr $restore + 1) ;&
121) echo -n 121 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Le fichier 'virus1', existe toujours dans le répertoire 'Room', mais étant donné votre ${voc}répertoire courant${reset}, vous ne pouvez pas lancer ${learn}rm virus1${reset}."; restore=$(expr $restore + 1) ;&
122) echo -n 122 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Heureusement, vous connaissez le ${voc}chemin absolu${reset} du fichier 'virus1' : ${learn}$HOME/House/Room/virus1${Reset}"; restore=$(expr $restore + 1) ;&
123) echo -n 123 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Vous pouvez utiliser son ${voc}chemin absolu${reset} comme ${voc}argument${reset}. Cette commande marchera donc quel que soit votre ${voc}répertoire courant${reset} !"; restore=$(expr $restore + 1) ;&
124) echo -n 124 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk_not_press_key justumen "Supprimez le avec cette commande : ${learn}rm $HOME/House/Room/virus1${reset}."; restore=$(expr $restore + 1) ;&
125) echo -n 125 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; answer_run "rm $HOME/House/Room/virus1" justumen "Non"; restore=$(expr $restore + 1) ;&
126) echo -n 126 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Maintenant, comment pouvoir vérifier si le fichier a bien été supprimé ?"; restore=$(expr $restore + 1) ;&
127) echo -n 127 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Lorsqu'une commande ne se passe pas comme prévue, elle vous renvoit très souvent une erreur."; restore=$(expr $restore + 1) ;&
128) echo -n 128 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk_not_press_key justumen "Essayez de supprimer le fichier 'virus1' à nouveau en utilisant son ${voc}chemin absolu${reset}."; restore=$(expr $restore + 1) ;&
129) echo -n 129 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; answer_run "rm $HOME/House/Room/virus1" justumen "Non"; restore=$(expr $restore + 1) ;&
130) echo -n 130 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Ici la commande ${learn}rm${reset} vous renvoi une erreur, le fichier n'existe donc déjà plus."; restore=$(expr $restore + 1) ;&
131) echo -n 131 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Maintenant, on peut aussi utiliser le ${voc}chemin absolu${reset} du dossier 'Room' pour afficher son contenu."; restore=$(expr $restore + 1) ;&
132) echo -n 132 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Vous connaissez déjà la commande ${learn}ls${reset}, pour lister le contenu du ${voc}répertoire courant${reset}."; restore=$(expr $restore + 1) ;&
133) echo -n 133 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Sans ${voc}argument${reset}, avec un simple ${learn}ls${reset}, le répertoire utilisé sera automatiquement le ${voc}répertoire courant${reset}."; restore=$(expr $restore + 1) ;&
134) echo -n 134 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Mais il est en fait aussi possible de donner un ${voc}argument${reset} à ${learn}ls${reset}."; restore=$(expr $restore + 1) ;&
135) echo -n 135 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Cet ${voc}argument${reset} représente le répertoire cible, par exemple ${learn}ls /${reset} affichera le contenu du ${voc}répertoire racine${reset}."; restore=$(expr $restore + 1) ;&
136) echo -n 136 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk_not_press_key justumen "Nous pouvons afficher le contenu du répertoire 'Room' sans se déplacer dans l'arborescence, avec cette commande : ${learn}ls $HOME/House/Room/${reset}."; restore=$(expr $restore + 1) ;&
137) echo -n 137 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; answer_run "ls $HOME/House/Room/" justumen "Non"; restore=$(expr $restore + 1) ;&
138) echo -n 138 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Excellent, le fichier 'virus1' n'existe plus."; restore=$(expr $restore + 1) ;&
139) echo -n 139 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Encore une fois, je vous rappelle que dans un ${voc}chemin absolu${reset}, si le dernier caractère est un '/', il n'est pas obligatoire."; restore=$(expr $restore + 1) ;&
140) echo -n 140 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk_not_press_key justumen "Donc ici le dernier '/' dans ${learn}$HOME/House/Room/${reset} n'est pas obligatoire. Testez donc à nouveau avec cette commande : ${learn}ls $HOME/House/Room${reset}"; restore=$(expr $restore + 1) ;&
141) echo -n 141 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; answer_run "ls $HOME/House/Room" justumen "Non"; restore=$(expr $restore + 1) ;&
142) echo -n 142 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Pas de problème, le résultat est le même pour ces deux commandes : ${learn}ls $HOME/House/Room/${reset} et ${learn}ls $HOME/House/Room${reset}."; restore=$(expr $restore + 1) ;&
143) echo -n 143 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Quand vous avez fait ${learn}rm virus0${reset} pour la première suppression, vous avez utilisé ce que l'on appelle le ${voc}chemin relatif${reset}."; restore=$(expr $restore + 1) ;&
144) echo -n 144 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "On dit que ce chemin est relatif parce qu'il dépend de votre ${voc}répertoire courant${reset}."; restore=$(expr $restore + 1) ;&
145) echo -n 145 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Imaginons deux fichiers 'virus' avec comme ${voc}chemin absolu${reset} : ${learn}/virus${reset} et ${learn}/bin/virus${reset}."; restore=$(expr $restore + 1) ;&
146) echo -n 146 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Si ${learn}pwd${reset} vous donne ${learn}$HOME${reset}. Un ${learn}rm virus${reset} ne supprimera aucun d'entre eux. Cette commande voudra supprimer le fichier avec ce chemin absolu : ${learn}$HOME/virus${reset}."; restore=$(expr $restore + 1) ;&
147) echo -n 147 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; cd "$HOME"; restore=$(expr $restore + 1) ;&
148) echo -n 148 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "D'ou la très grande utilité de ce ${voc}chemin absolu${reset}. Vous pouvez utiliser ${learn}rm /virus${reset} et ${learn}rm /bin/virus${reset} quel que soit votre ${voc}répertoire courant${reset}."; restore=$(expr $restore + 1) ;&
149) echo -n 149 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk_not_press_key justumen "Je viens de vous déplacer dans l'arborescence, affichez donc le chemin absolu du ${voc}répertoire courant${reset}."; restore=$(expr $restore + 1) ;&
150) echo -n 150 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; answer_run "pwd" justumen "Non"; restore=$(expr $restore + 1) ;&
151) echo -n 151 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Pour changer de ${voc}répertoire courant${reset}, vous pouvez utiliser la commande ${learn}cd${reset}."; restore=$(expr $restore + 1) ;&
152) echo -n 152 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Pour revenir dans le répertoire 'Room', vous pouvez utiliser son ${voc}chemin absolu${reset} : ${learn}cd $HOME/House/Room/${reset}"; restore=$(expr $restore + 1) ;&
153) echo -n 153 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Mais il n'est pas obligatoire d'utiliser son ${voc}chemin absolu${reset}, il est aussi possible de revenir dans le répertoire 'Room' en utilisant son ${voc}chemin relatif${reset}."; restore=$(expr $restore + 1) ;&
154) echo -n 154 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Vous voulez aller dans ${learn}$HOME/House/Room/${reset} mais vous êtes déjà dans ${learn}$HOME${reset}."; restore=$(expr $restore + 1) ;&
155) echo -n 155 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk_not_press_key justumen "Il est donc possible de se déplacer de là où vous êtes avec un ${learn}cd House/Room/${reset}. Allez-y."; restore=$(expr $restore + 1) ;&
156) echo -n 156 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; answer_run "cd House/Room/" justumen "Non"; restore=$(expr $restore + 1) ;&
157) echo -n 157 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk_not_press_key justumen "Affichez maintenant les éléments de votre ${voc}répertoire courant${reset}."; restore=$(expr $restore + 1) ;&
158) echo -n 158 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; answer_run "ls" justumen "Non"; restore=$(expr $restore + 1) ;&
159) echo -n 159 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk_not_press_key justumen "Ici vous voyez encore des fichiers virus, supprimez le fichier virus2 en utilisant le ${voc}chemin relatif${reset}."; restore=$(expr $restore + 1) ;&
160) echo -n 160 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; answer_run "rm virus2" justumen "Non"; restore=$(expr $restore + 1) ;&
161) echo -n 161 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Excellent!"; restore=$(expr $restore + 1) ;&
162) echo -n 162 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Nous avons vu dans l'exemple précédent que ${learn}cd House/Room/${reset} utilise un ${voc}chemin relatif${reset}, pourtant cette commande contient aussi des '/'."; restore=$(expr $restore + 1) ;&
163) echo -n 163 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Donc comment reconnaitre un ${voc}chemin absolu${reset} d'un ${voc}chemin relatif${reset} ?"; restore=$(expr $restore + 1) ;&
164) echo -n 164 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Le ${voc}chemin absolu${reset} est en fait très facile à reconnaitre !"; restore=$(expr $restore + 1) ;&
165) echo -n 165 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Il commence toujours à la racine, c'est à dire que le premier caractère d'un ${voc}chemin absolu${reset} est toujours un '/'."; restore=$(expr $restore + 1) ;&
166) echo -n 166 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Il y a aussi une syntaxe spéciale très utile pour le ${voc}chemin relatif${reset} : ${learn}..${reset}"; restore=$(expr $restore + 1) ;&
167) echo -n 167 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "${learn}..${reset} représente dans l'arborescence le parent du ${voc}répertoire courant${reset}."; restore=$(expr $restore + 1) ;&
168) echo -n 168 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "C'est le vocabulaire que nous employons pour parler de cette arborescence, ce sont des relations parents / enfants."; restore=$(expr $restore + 1) ;&
169) echo -n 169 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Par exemple pour ${learn}/home/user/test/${reset}, le dossier parent de test est user. Le dossier parent de user est home."; restore=$(expr $restore + 1) ;&
170) echo -n 170 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Et bien evidemment test est un enfant de user, et user est un enfant de home."; restore=$(expr $restore + 1) ;&
171) echo -n 171 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Cibler les enfants en ${voc}argument${reset} avec un ${voc}chemin relatif${reset} est très simple, il suffit d'écrire le nom de leurs parents successifs."; restore=$(expr $restore + 1) ;&
172) echo -n 172 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Comme par exemple avec la commande de tout a l'heure : ${learn}cd House/Room/${reet}"; restore=$(expr $restore + 1) ;&
173) echo -n 173 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Pour cibler les parents, c'est un peu plus compliqué. Il faut utiliser ${learn}..${reset}."; restore=$(expr $restore + 1) ;&
174) echo -n 174 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Affichez donc le chemin absolu de votre ${voc}répertoire courant${reset}."; restore=$(expr $restore + 1) ;&
175) echo -n 175 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Vous connaissez aussi la commande pour changer de répertoire courant : ${learn}cd${reset}."; restore=$(expr $restore + 1) ;&
176) echo -n 176 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Ici nous allons nous déplacer dans le répertoire parent. Nous sommes dans ${learn}$HOME/House/Room/${reset} mais nous voulons aller dans ${learn}$HOME/House/${reset}"; restore=$(expr $restore + 1) ;&
177) echo -n 177 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk_not_press_key justumen "Il est possible de remonter d'un cran dans l'arborescence, ou comme je viens de le dire de se déplacer dans le répertoire parent avec un ${learn}cd ..${reset}"; restore=$(expr $restore + 1) ;&
178) echo -n 178 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; answer_run "cd .." justumen "Non"; restore=$(expr $restore + 1) ;&
179) echo -n 179 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk_not_press_key justumen "Affichez le chemin absolu du ${voc}répertoire courant${reset}."; restore=$(expr $restore + 1) ;&
180) echo -n 180 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; answer_run "pwd" justumen "Non"; restore=$(expr $restore + 1) ;&
181) echo -n 181 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "J'espère que le résultat de ${learn}pwd${reset} est logique pour vous."; restore=$(expr $restore + 1) ;&
182) echo -n 182 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk_not_press_key justumen "Mais il nous reste deux virus à supprimer, commençons par supprimer le fichier virus3 avec son ${voc}chemin relatif${reset}."; restore=$(expr $restore + 1) ;&
183) echo -n 183 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; answer_run "rm Room/virus3" justumen "Non"; restore=$(expr $restore + 1) ;&
184) echo -n 184 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk_not_press_key justumen "Bien. Maintenant supprimons le fichier virus4 en utilisant son ${voc}chemin absolu${reset}."; restore=$(expr $restore + 1) ;&
185) echo -n 185 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; answer_run "rm $HOME/House/Room/virus4" justumen "Non"; restore=$(expr $restore + 1) ;&
186) echo -n 186 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; talk justumen "Parfait, vous avez tout compris ! Et je vous donne rendez-vous au questionnaire !"; restore=$(expr $restore + 1) ;&
187) echo -n 187 > $HOME/.GameScript/restore_bash1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash1; clean; restore=$(expr $restore + 1) ;&
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
             ;       ;%;  %%;        ,     %;    ;%;    ,%'${CLREOL}
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
|-- $code /var/ $reset$basic"
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
|-- $codeFile /Home $reset$basic"
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
$codeFile /Home $reset$basic"
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
  echo ""
  echo -e "\e[15;5;44m Bash 'Bourne Again SHell' : Questionnaire du chapitre 1 \e[0m"
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

AUDIO_LOCAL="$HOME/.GameScript/Audio/fr/bash/c1"
mkdir -p $HOME/.GameScript/Audio/fr/bash/c1 2> /dev/null
AUDIO_DL="https://raw.githubusercontent.com/justUmen/GameScript/master/fr/classic/bash/Audio/m1/c1"
AUDIOCMP=1

enter_chapter $CHAPTER_NAME $CHAPTER_NUMBER
