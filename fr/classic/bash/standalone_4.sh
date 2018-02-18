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
	echo -n "$restore" > ~/PERSONAL_PROGRESS
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
[ -d "$HOME/.GameScript_bash4" ] && echo "Erreur innatendu, ${HOME}/.GameScript_bash4 existe déjà sur votre système ! Supprimez ce dossier $HOME/.GameScript_bash4 et relancer ce script." && exit
mkdir $HOME/.GameScript_bash4
cd $HOME/.GameScript_bash4
talk justumen "Dans le chapitre précédent, nous avons vu comment créer et modifier les fichiers textes."
talk justumen "Ici nous allons continuer sur d'autres types de contrôles."
talk_not_press_key justumen "Commencez par créer un nouveau fichier 'test' avec comme contenu le mot 'bonjour'."
answer_run "echo bonjour>test" justumen "Non"
talk_not_press_key justumen "Créez un nouveau dossier nommé 'DIR'."
answer_run "mkdir DIR" justumen "Non"
talk_not_press_key justumen "Affichez les éléments du répertoire courant."
answer_run "ls" justumen "Non"
talk justumen "Pour déplacer un fichier il faudra utiliser la commande ${code}mv${reset}."
talk justumen "'m' et 'v' sont les consonnes de 'move', le mot anglais pour 'déplacer'."
talk_not_press_key justumen "Déplacez donc ce fichier 'test' dans le dossier DIR avec la commande : ${learn}mv test DIR${reset}"
answer_run "mv test DIR" justumen "Non"
talk_not_press_key justumen "Affichez les éléments du dossier 'DIR'."
answer_run "ls DIR" justumen "Non"
talk_not_press_key justumen "Déplacez votre terminal dans le dossier 'DIR'."
answer_run "cd DIR" justumen "Non"
talk_not_press_key justumen "Affichez le chemin absolu du répertoire courant."
answer_run "pwd" justumen "Non"
talk_not_press_key justumen "Affichez les éléments du répertoire courant."
answer_run "ls" justumen "Non"
talk justumen "Ici le fichier 'test' a bien été déplacé dans le répertoire 'DIR' avec la commande : ${learn}mv test DIR${reset}"
talk justumen "Dans cet exemple, notre premier argument est un fichier et le second est un dossier."
talk justumen "Comme le deuxième argument est un dossier, la commande aurait pu être : ${learn}mv test DIR/${reset}"
talk justumen "Cette version est nettement plus lisible que la première."
talk justumen "Parce que ${code}mv${reset} peut avoir indifféremment en arguments des fichiers ou des dossiers."
talk justumen "Mais si le premier argument est un fichier et que le deuxième est aussi un fichier, la commande agira différemment : le fichier sera déplacé dans un autre fichier avec un nom différent."
talk justumen "Ou pour plus de clarté on peut dire qu'il sera simplement ${voc}renommé${reset}."
talk justumen "Dans votre répertoire courant vous avez toujours ce fichier 'test'."
talk_not_press_key justumen "Utilisez cette commande pour renommer 'test' en 'test2' : ${learn}mv test test2${reset}"
answer_run "mv test test2" justumen "Non"
talk_not_press_key justumen "Affichez les éléments du répertoire courant."
answer_run "ls" justumen "Non"
talk_not_press_key justumen "Affichez le contenu du fichier 'test2'."
answer_run "cat test2" justumen "Non"
talk justumen "Le contenu est bien toujours le même, seul le nom du fichier à changé."
talk_not_press_key justumen "Maintenant créez un nouveau dossier nommé : 'DOS'."
answer_run "mkdir DOS" justumen "Non"
talk justumen "Je le répète, ${code}mv${reset} peut avoir indifféremment en arguments des fichiers ou des dossiers."
talk justumen "C'est à dire que si les deux arguments sont des dossiers, ${code}mv${reset} va encore une fois simplement renommer."
talk_not_press_key justumen "Renommez donc ce dossier 'DOS' en 'DOS2'."
answer_run "mv DOS DOS2" justumen "Non"
talk_not_press_key justumen "Et affichez les éléments du répertoire courant."
answer_run "ls" justumen "Non"
talk justumen "Attention donc à la commande ${code}mv${reset} qui peut avoir deux rôles différents, déplacer et renommer."
talk justumen "${code}mv${reset} peut également faire les deux en une seule commande."
talk_not_press_key justumen "Déplacez 'test2' dans 'DOS2' et renommez le en 'test3' avec : ${learn}mv test2 DOS2/test3${reset}"
answer_run "mv test2 DOS2/test3" justumen "Non"
talk_not_press_key justumen "Affichez les éléments du répertoire DOS2."
answer_run "ls DOS2" justumen "Non"
talk justumen "Le fichier 'test2' a bien été déplacé dans DOS2 et renommé en 'test3'."
talk_not_press_key justumen "Affichez le contenu de ce fichier 'test3'."
answer_run "cat DOS2/test3" justumen "Non"
talk justumen "Le contenu est toujours identique."
talk justumen "Si vous ajoutez le texte 'tout le monde' à la suite de ce fichier, le texte sera ajouté sur une nouvelle ligne."
talk justumen "Parce que lorsque vous utilisez ${code}echo${reset}, il ajoutera par défaut une mise à la ligne à la fin."
talk justumen "Si vous ne voulez pas de cette mise à la ligne, il faudra utiliser l'option ${learn}-n${reset} de la commande ${code}echo${reset}."
talk_not_press_key justumen "Remplacez donc le contenu du fichier 'test3' par 'bonjour', mais sans cet retour à la ligne automatique à la fin."
answer_run "echo -n bonjour>DOS2/test3" justumen "Non"
talk_not_press_key justumen "Maintenant ajoutez le texte ' tout le monde' à ce fichier 'test3', en utisant ${learn}\"${reset}."
answer_run "echo \" tout le monde\">>DOS2/test3" justumen "Non"
talk_not_press_key justumen "Enfin, affichez le contenu de 'test3'."
answer_run "cat DOS2/test3" justumen "Non"
talk justumen "Et voilà, bonjour tout le monde !"
talk justumen "Quand une commande ne fait pas exactement ce que voulez qu'elle fasse, visitez son manuel !"
talk justumen "Il est très probable qu'une simple option soit la réponse à votre problème."
talk justumen "${code}mv${reset} utilise deux arguments, le premier est ${voc}<SOURCE>${reset} et le deuxième est ${voc}<DESTINATION>${reset}."
talk justumen "Et la syntaxe comme on l'a déjà vu est donc : ${code}mv <SOURCE> <DESTINATION>${reset}"
talk justumen "${voc}<SOURCE>${reset} et ${voc}<DESTINATION>${reset} sont à remplacer par les fichiers ou les dossiers voulus."
talk justumen "Lorsqu'une commande a besoin de deux arguments, la plupart du temps cette logique s'applique."
talk justumen "Le premier argument est la ${voc}source${reset}, le second est la ${voc}destination${reset}."
talk justumen "Pour ${voc}copier${reset} ou ${voc}dupliquer${reset} un fichier sur linux il faudra utiliser la commande ${code}cp${reset}."
talk justumen "Son comportement est sensiblement identique à ${code}mv${reset}, sauf que le fichier ${voc}<SOURCE>${reset} ne sera pas supprimé."
talk_not_press_key justumen "Affichez les éléments du répertoire courant."
answer_run "ls" justumen "Non"
talk_not_press_key justumen "Copiez donc le fichier 'test3' dans votre répertoire courant."
answer_run "cp DOS2/test3 ." justumen "Non"
talk justumen "Et ici nous avons notre première utilisation pratique du ${code}.${reset} qui je vous le rappelle représente le répertoire courant."
talk_not_press_key justumen "Listez à nouveau les éléments du répertoire courant."
answer_run "ls" justumen "Non"
talk justumen "Encore une fois ${code}.${reset} étant un dossier, vous pouvez également utiliser ${code}./${reset} à la place."
talk_not_press_key justumen "Maintenant testez cette commande : ${learn}cp DOS2/test3 .new${reset}"
answer_run "cp DOS2/test3 .new" justumen "Non"
talk_not_press_key justumen "Puis listez les éléments du répertoire courant."
answer_run "ls" justumen "Non"
talk justumen "Ce résultat ne devrait pas vous choquer."
talk justumen "Encore une fois, ${code}.new${reset} et  ${code}./new${reset} représentent deux choses différentes."
talk justumen "${code}.new${reset} est bien évidemment un fichier caché."
talk_not_press_key justumen "Listez les fichiers cachés du répertoire courant."
answer_run "ls -a" justumen "Non"
talk justumen "Si vous vouliez copier le fichier 'test3' et renommer cette copie en 'new' dans le répertoire courant, la commande sera : ${learn}cp DOS2/test3 ./new${reset}."
talk justumen "Ici la commande ${learn}cp DOS2/test3 .new${reset} est identique à ${learn}cp DOS2/test3 ./.new${reset}."
talk justumen "Sur bash, il est possible d'avoir plusieures commandes sur une seule ligne, il suffit de les séparer par des ${code};${reset}."
talk_not_press_key justumen "Essayez donc d'afficher 'a', puis sur une autre ligne 'b'. Avec deux commandes et un ${code};${reset}."
answer_run "echo a;echo b" justumen "Non"
talk_not_press_key justumen "Maintenant, essayez de vous déplacer dans le dossier DOS et de créer un dossier NEW à l'intérieur."
answer_run "cd DOS;mkdir NEW" justumen "Non"
talk_not_press_key justumen "Listez les éléments de votre répertoire courant."
answer_run "ls" justumen "Non"
talk justumen "Avec ${code};${reset}, quel que soit le résultat de la première commande, la deuxième se lancera également."
talk justumen "Ici le dossier 'DOS' n'existait pas, pourtant la commande ${learn}mkdir NEW${reset} a été lancée dans ${code}.${reset}."
talk justumen "Le ${code};${reset} ne donne aucun contrôle sur l'état des commandes précédentes."
talk justumen "Mais vous pouvez aussi créer des conditions avant de passer à la prochaine commande."
talk justumen "Si vous voulez que la deuxième commande s'exécute uniquement si la première a été un succès, vous pouvez utiliser ${code}&&${reset} à la place du ${code};${reset}."
talk_not_press_key justumen "Commencez par supprimez ce dossier NEW, que nous avons créé par erreur."
answer_run "rmdir NEW" justumen "Non"
talk_not_press_key justumen "Maintenant, pour créer un dossier NEW dans DOS, essayez : ${learn}cd DOS&&mkdir NEW${reset}"
answer_run "cd DOS&&mkdir NEW" justumen "Non"
talk_not_press_key justumen "Listez les éléments de votre répertoire courant."
answer_run "ls" justumen "Non"
talk justumen "La commande ${learn}cd DOS${reset} renvoyant une erreur, ${code}&&${reset} a bloqué le lancement de la prochaine commande."
talk justumen "Cette technique est particulièrement importante si vous utilisez des commandes ${voc}destructrice${reset}, comme ${code}rm${reset}, ou ${code}echo${reset} avec un ${code}>${reset}."
talk justumen "Si vous ne prenez pas de précaution, vous risquez de supprimer accidentellement un fichier important."
talk justumen "Il est possible d'utiliser ${code};${reset} et ${code}&&${reset} avec toutes les commandes que vous connaissez déjà."
talk justumen "Mais il existe une autre syntaxe : ${code}||${reset}, qui fait l'inverse de ${code}&&${reset}."
talk justumen "C'est à dire que la prochaine commande ne se lancera que si la précédente est un échec."
talk_not_press_key justumen "Essayez donc avec une faute de frappe la commande : ${learn}lss||echo test${reset}"
answer_run "lss||echo test" justumen "Non"
talk_not_press_key justumen "Essayez la même commande, cette fois avec ${code}&&${reset} : ${learn}lss&&echo test${reset}"
answer_run "lss&&echo test" justumen "Non"
talk justumen "Mais il est aussi possible d'avoir les deux conditions sur une seule ligne."
talk_not_press_key justumen "Essayez cette commande : ${learn}cd DOS&&echo SUCCESS||echo ERROR${reset}"
answer_run "cd DOS&&echo SUCCESS||echo ERROR" justumen "Non"
talk justumen "Si vous savez programmer, cette commande peut être vu comme une condition de programmation if/else."
talk_not_press_key justumen "Ici le dossier 'DOS' n'existe pas, utilisez donc DOS2 avec cette commande : ${learn}cd DOS2&&ls||pwd${reset}"
answer_run "cd DOS2&&ls||pwd" justumen "Non"
talk justumen "Comme le dossier 'DOS2' existe, la commande ${learn}pwd${reset}, ne sera pas exécuté."
talk justumen "Vous êtes prêt pour le questionnaire !"
rm $HOME/.GameScript_bash4/DIR/.new
rm $HOME/.GameScript_bash4/DIR/test3
rm $HOME/.GameScript_bash4/DIR/DOS2/test3
rmdir $HOME/.GameScript_bash4/DIR
rmdir $HOME/.GameScript_bash4
}
function quiz(){
  echo -en "\e[0;33m...\e[0m"
  talk_not_press_key justumen "Bash 'Bourne Again SHell' : Chapitre 4"
  talk_not_press_key justumen "- La réponse doit être la plus courte possible, une commande valide mais ajoutant des caractères inutiles ne fonctionnera pas."
  talk_not_press_key justumen "Exemple : si la réponse est 'ls'. Les réponses 'ls .', 'ls ./' et 'ls ././' seront considérées comme fausses."
  answer_text_fr "Quelle est la commande pour déplacer des fichiers ou dossiers ?" "mv"
  answer_text_fr "Quelle est la commande pour renommer des fichiers ou dossiers ?" "mv"
  answer_text_fr "Comment renommer un fichier nommé 'oui' dans votre répertoire courant en 'non' et le déplacer dans son répertoire parent ?" "mv oui ../non"
  answer_text_fr "Comment copier dans votre répertoire courant un fichier dont le chemin absolu est '/root/file' ?" "cp /root/file ."
  answer_text_fr "Comment copier un fichier caché '.file' situé dans votre répertoire parent et le renommer en un fichier non caché 'file' dans le dossier '/root' ?" "cp ../.file /root/file"
  answer_text_fr "Quel symbole doit être utilisé pour séparer simplement deux commandes sur une même ligne ?" ";"
  answer_text_fr "Comment exécuter la commande 'rm file' uniquement si la commande précédente 'cd /root' est un succès ?" "cd /root&&rm file"
  answer_text_fr "Comment afficher 'good' si la commande 'cd /root' est un succès, et 'bad' sinon ?" "cd /root&&echo good||echo bad"
  unlock
}

function unlock(){
  #~ talk_not_press_key justumen "Pour débloquer \"bash 3\" dans le chat, allez sur https://rocket.bjornulf.org/direct/boti et tapez : password 2421a9d18fbb" #Super secure password ! Please don't cheat for your own good. :-)
  talk_not_press_key justumen "Pour débloquer \"bash 4\" dans le chat, veuillez saisir votre pseudo :"
  PSEUDO=""
  while [[ $PSEUDO = "" ]]; do
    echo -en "\\e[1;31;42m # \\e[0m"
    read -r PSEUDO < /dev/tty
  done
  PASS=`encode $PSEUDO "a9d1" "21af"`
  talk_not_press_key justumen "Allez sur https://rocket.bjornulf.org/direct/boti et tapez : password$PASS"
}

function enter(){
case $1 in
	1) echo -en "\e[0;33m...\e[0m" ;&
	2) talk_not_press_key justumen "Bash Bourne Again SHell : Chapitre 4" ;&
	3) answer_quiz "Cours" "Questionnaire" "Quitter" "4" "5" "6" ;;
	4) code ;;
	5) quiz 1 ;;
	6) exit ;;
esac
}

restore=2 #first line of LIST_4GEN should be environment test (test ~/House)
# justumen_intro_fr

enter 1
