#!/bin/bash
#SOME ADDED AND CHANGE IN CLI learn_cli.sh in CLASSIC

function encode(){
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
	key="9"
	while [ "$key" != "1" ] || [ "$key" != "2" ] || [ "$key" != "3" ]; do
		echo ""
		echo -e "\\e[0;100m 1) \\e[0m $1"
		echo -e "\\e[0;100m 2) \\e[0m $2"
		echo -e "\\e[0;100m 3) \\e[0m $3"
		echo -en "\\e[1;31;42m # \\e[0m"
		read -n1 key < /dev/tty
		case $key in
			1) echo -en "\n\e[0;33m...\e[0m" ;enter "$4" ;;
			2) echo -en "\n\e[0;33m...\e[0m" ;enter "$5" ;;
			3) echo -en "\n\e[0;33m...\e[0m" ;enter "$6" ;;
		esac
	done
}
function answer_text_fr(){
	echo "> $1"
	echo -en "\\e[1;31;42m # \\e[0m"
	read -r USER_CODE < /dev/tty
	if [ ! "$USER_CODE" == "$2" ]; then
		talk_not_press_key justumen "\\e[4;37mDésolé, réponse fausse ou trop longue. Je vous conseille de relancer ce script et de suivre le cours.\\e[0m"
		exit
	else
		talk_not_press_key justumen "Correct !"
	fi
}
function answer_run(){
	echo -en "\\e[1;31;42m # \\e[0m"
	read -r USER_CODE < /dev/tty
	while [ ! "$USER_CODE" == "$1" ]; do
		#$3 is the correct answer
		#~ talk_not_press_key "$2" "$3 \\e[4;37m$1\\e[0m"
		#~ talk_not_press_key "$2" "\\e[4;37m$1\\e[0m"
		talk_not_press_key_ASNWER "$2" "$1"
		echo -en "\\e[1;31;42m # \\e[0m"
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
  Lorsque vous voyez \\e[1;31;42m # \\e[0m le script attend que vous tapiez une commande linux. (lettre par lettre)

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
function code(){
[ -d "$HOME/.GameScript_bash5" ] && echo "Erreur innatendu, ${HOME}/.GameScript_bash5 existe déjà sur votre système ! Supprimez ce dossier $HOME/.GameScript_bash5 et relancer ce script." && exit
mkdir $HOME/.GameScript_bash5
cd $HOME/.GameScript_bash5
mkdir Dossier;touch Dossier/fichier;chmod 444 Dossier
echo "a">f1;chmod 000 f1;echo "ab">f2;chmod 444 f2;echo "abc">f3;chmod 600 f3;echo "abcd">f4;chmod 777 f4
talk justumen "Dans ce chapitre nous revenons sur la commande ${code}ls${reset}, l'une des commandes les plus importantes."
talk justumen "Et ici nous allons parler de son option la plus importante : ${code}-l${reset}"
talk_not_press_key justumen "Vous pouvez taper : ${learn}ls -l${reset}"
answer_run "ls -l" justumen "Non"
talk justumen "Avec cette option, ${code}ls${reset} nous donne plus d'informations sur les éléments du répertoire courant."
talk justumen "Vous avez au début une chaine de caractères étrange composé de ${code}-${reset} et de lettres à gauche du premier espace de chaque ligne."
talk justumen "Le premier caractère représente le type de l'élément."
talk justumen "Si c'est un ${code}-${reset}, c'est un fichier, si c'est un ${code}d${reset}, c'est un dossier."
talk justumen "Avec ce premier caractère, on voit clairement que 'Dossier' est un dossier et que les autres sont des fichiers."
talk justumen "Les neufs autres caractères représentent les ${voc}permissions${reset} du fichier."
talk justumen "Il est possible d'avoir plusieurs utilisateurs sur un même ordinateur."
talk justumen "Mais certains de vos fichiers méritent peut-être d'être protégés."
talk justumen "Par exemple, si vous ne voulez pas que votre petite soeur soit capable de supprimer votre travail."
talk justumen "En revanche, même si vous ne voulez pas qu'elle puisse supprimer vos fichiers, vous avez peut-être besoin de lui donner la permission de les lire."
talk justumen "Ces neufs caractères sont utilisés pour définir avec précision les permissions que vous désirez."
talk justumen "La permission 'minimale' est ${code}---------${reset} et la permission 'maximale' est ${code}rwxrwxrwx${reset}."
talk justumen "Chaque ${code}-${code} veut dire que qu'un certain type de permission est ${voc}désactivé${reset}."
talk justumen "A l'inverse, lorsque vous voyez une lettre, c'est qu'un certain type de permission est ${voc}activé${reset}."
talk justumen "Mais chaque caractère doit respecter cet ordre : ${code}rwxrwxrwx${reset}."
talk justumen "C'est à dire qu'ils n'auront pour simplifier que deux états possibles."
talk justumen "Le premier caractère pourra être soit un ${code}-${reset} soit un ${code}r${reset}."
talk justumen "Ce ${code}r${reset} vient de l'anglais ${code}r${reset}ead et donne le droit de lecture."
talk justumen "Le second caractère pourra être soit un ${code}-${reset} soit un ${code}w${reset}."
talk justumen "Ce ${code}w${reset} vient de l'anglais ${code}W${reset}rite et donne le droit d'écriture : modification et suppression."
talk justumen "Le troisième caractère pourra être soit un ${code}-${reset} soit un ${code}x${reset}."
talk justumen "Ce ${code}x${reset} vient de l'anglais e${code}X${reset}ecute et donne le droit d'exécution."
talk justumen "Et ce schéma de trois caractères ${code}rwx${reset} se répète trois fois."
talk justumen "Les trois premiers caractères sont les permissions du ${voc}propriétaire${reset} du fichier."
talk justumen "Pour vous donner un exemple de résultat : -${codeFile}rw-${reset}r----- 2 ${codeFile}albert${reset} Einstein 4096 Feb 19 00:51 Exemple"
talk justumen "Le nom du propriétaire du fichier 'Exemple' est ici 'albert'."
talk justumen "Les trois caractères suivants sont les permissions des membres du ${voc}groupe${reset} 'Einstein'."
talk justumen "Pour vous donner le même exemple : -rw-${codeFile}r--${reset}--- 2 albert ${codeFile}Einstein${reset} 4096 Feb 19 00:51 Exemple"
talk justumen "Ici on peut imaginer l'existence d'un groupe pour la famille 'Einstein'."
talk justumen "Et enfin, les trois derniers caractères sont les permissions des autres utilisateurs."
talk justumen "Pour le même exemple : -rw-r--${codeFile}---${reset} 2 albert Einstein 4096 Feb 19 00:51 Exemple"
talk justumen "Ceux qui ne sont pas dans le groupe "Einstein"."
talk justumen "Dans cet exemple, albert, le propriétaire du fichier a le droit de lecture avec ce ${code}r${reset} et le droit d'écriture avec ce ${code}w${reset}."
talk justumen "Les membres du groupe 'Einstein' ont uniquement le droit de lecture sur ce fichier avec ce ${code}r${reset}."
talk justumen "Ils n'ont pas le droit de le modifier ou de le supprimer, car il n'y a pas de ${code}w${reset} !"
talk justumen "Le reste des utilisateurs n'ont aucune permission, car il n'y a pour eux aucune lettre : ${codeFile}---${reset}."
talk_not_press_key justumen "Maintenant revenons à nos fichiers et relançons : ${learn}ls -l${reset}"
answer_run "ls -l" justumen "Non"
talk justumen "Sur un système simple, il est probable que vous ayez un nom de groupe similaire à votre nom d'utilisateur, mais ça n'est pas un problème."
talk justumen "Il y a donc de nombreuses combinaisons de permission possibles, ici nous avons 'f1' avec les permissions minimales : ${code}---------${reset}."
talk justumen "Nous avons 'f4' avec les permissions maximales : ${code}rwxrwxrwx${reset}."
talk justumen "Et nous avons d'autres combinaisons de permissions pour les autres éléments."
talk_not_press_key justumen "Commençez par afficher le contenu du fichier 'f1'."
answer_run "cat f1" justumen "Non"
talk justumen "Et oui, il n'est pas possible d'afficher le contenu de ce fichier, car vous n'avez pas le droit de lecture."
talk justumen "Pour pouvoir utiliser la commande ${code}cat${reset}, il vous aurez fallu un ${code}r${reset} à la place de ce tiret rouge : ${codeError}-${reset}--------."
talk_not_press_key justumen "Sur le fichier 'f2', vous avez ce ${code}r${reset}--r--r-- qui vous donne le droit de lecture. Affichez le contenu de 'f2'."
answer_run "cat f2" justumen "Non"
talk justumen "Ici pas de problème à l'affichage."
talk_not_press_key justumen "Ajoutez 'cd' au fichier 'f2'."
answer_run "echo cd>>f2" justumen "Non"
talk justumen "Sur 'f2' nous avons encore un problème de permission."
talk justumen "Cette fois c'est un ${code}w${reset} qui nous manque à la place de ce tiret rouge : r${codeError}-${reset}-r--r--."
talk justumen "Mais 'f3' semble avoir à la fois le ${code}r${reset} et le ${code}w${reset}."
talk_not_press_key justumen "Affichez le contenu de 'f3'."
answer_run "cat f3" justumen "Non"
talk_not_press_key justumen "Ajoutez 'def' au fichier 'f3'."
answer_run "echo def>>f3" justumen "Non"
talk_not_press_key justumen "Affichez le contenu de 'f3' a nouveau."
answer_run "cat f3" justumen "Non"
talk justumen "Parfait ! Nous pouvons enfin utiliser nos commandes sans soucis."
talk justumen ""
talk justumen ""
rmdir $HOME/.GameScript_bash5
talk justumen ""
talk_not_press_key justumen "Pour créer un fichier texte vide vous pouvez aussi utiliser la commande ${code}touch${reset}, faites donc : ${learn}touch file${reset}"
answer_run "touch fichier" justumen "Non"
talk justumen ""
talk justumen ""
talk justumen ""
talk justumen ""-rw-r--r--" and so on ..."
talk justumen "whoami"
talk justumen "how to identify if an element is a directory or a file ?"
talk justumen ""chmod" + numbers"
talk justumen ""chown""
talk justumen ""touch""
talk justumen ""
talk justumen ""
talk justumen "é"
talk justumen "à"
talk justumen "è"
talk justumen "ê"
}
function quiz(){
  echo -en "\e[0;33m...\e[0m"
  talk_not_press_key justumen "Bash 'Bourne Again SHell' : Chapitre 5"
  talk_not_press_key justumen "- La réponse doit être la plus courte possible, une commande valide mais ajoutant des caractères inutiles ne fonctionnera pas."
  talk_not_press_key justumen "Exemple : si la réponse est 'ls'. Les réponses 'ls .', 'ls ./' et 'ls ././' seront considérées comme fausses."
  answer_text_fr "" ""
  unlock
}

function unlock(){
  #~ talk_not_press_key justumen "Pour débloquer \"bash 3\" dans le chat, allez sur https://rocket.bjornulf.org/direct/boti et tapez : password 2421a9d18fbb" #Super secure password ! Please don't cheat for your own good. :-)
  talk_not_press_key justumen "Pour débloquer \"bash 5\" dans le chat, veuillez saisir votre pseudo :"
  PSEUDO=""
  while [[ $PSEUDO = "" ]]; do
    echo -en "\\e[1;31;42m # \\e[0m"
    read -r PSEUDO < /dev/tty
  done
  PASS=`encode $PSEUDO "8ab2" "2f30"`
  talk_not_press_key justumen "Allez sur https://rocket.bjornulf.org/direct/boti et tapez : password$PASS"
}

function enter(){
case $1 in
	1) echo -en "\e[0;33m...\e[0m" ;&
	2) talk_not_press_key justumen "Bash Bourne Again SHell : Chapitre 5" ;&
	3) answer_quiz "Cours" "Questionnaire" "Quitter" "4" "5" "6" ;;
	4) code ;;
	5) quiz 1 ;;
	6) exit ;;
esac
}

restore=2 #first line of LIST_4GEN should be environment test (test ~/House)
# justumen_intro_fr

enter 1
