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
[ -d "$HOME/.GameScript_bash2" ] && echo "Erreur innatendu, ${HOME}/.GameScript_bash2 existe déjà sur votre système ! Supprimez ce dossier $HOME/.GameScript_bash2 et relancer ce script." && exit
mkdir $HOME/.GameScript_bash2
cd $HOME/.GameScript_bash2
touch $HOME/.GameScript_bash2/bOb
talk justumen "Dans le dernier cours, nous avons vu l'utilisation des commandes et de leurs arguments."
talk justumen "La commande ${learn}cd${reset} permet de se déplacer dans le répertoire de notre choix."
talk justumen "Ce choix doit se donner en argument de la commande, par exemple ${learn}cd test${reset} pour se déplacer dans le dossier 'test'."
talk justumen "Ou encore ${learn}mkdir test${reset} pour créer un répertoire qui porte le nom 'test'."
talk justumen "Cet argument peut avoir un nom spécial, comme ${code}..${reset} qui représente le répertoire parent."
talk justumen "${code}..${reset} étant l'abréviation d'un répertoire, il peut également s'écrire ${code}../${reset}"
talk justumen "${code}..${reset} étant lui même un répertoire, il peut avoir un parent, qui peut être ciblé en argument par ${code}../..${reset} ou encore ${code}../../${reset}."
talk justumen "${code}../..${reset} cible donc le grand parent du répertoire courant, ${code}../../..${reset} l'arrière grand parent et ainsi de suite."
talk justumen "Mais il existe un autre nom spécial, qui représente le répertoire courant : ${code}.${reset}."
talk justumen "Comme il s'agit d'un dossier, ${code}./${reset} est également correct."
talk_not_press_key justumen "Affichez maintenant le contenu de ce répertoire courant."
answer_run "ls" justumen "Non"
talk justumen "Vous pouvez utilisez directement ces chemins spéciaux avec cette commande."
talk_not_press_key justumen "Testez donc la commande : ${learn}ls .${reset}"
answer_run "ls ." justumen "Non"
talk_not_press_key justumen "Et maintenant : ${learn}ls ./${reset}"
answer_run "ls ./" justumen "Non"
talk justumen "Oui toutes ces ${learn}ls${reset} donnent le même résultat. Sans argument, la commande cible par défaut le répertoire ${code}.${reset}."
talk justumen "Vous l'avez compris, ${code}.${reset} est l'abréviation du répertoire courant !"
talk_not_press_key justumen "Pour supprimer le fichier ${code}bOb${reset}, vous pouvez donc taper ${learn}rm ./bOb${reset}, allez-y."
answer_run "rm ./bOb" justumen "Non"
talk_not_press_key justumen "Affichez donc le chemin du répertoire courant."
answer_run "pwd" justumen "Non"
talk justumen "Attention à ce symbole ${code}.${reset}, dans une autre situation il peut avoir une autre signification."
talk justumen "Ici ce ${code}.${reset} dans ${code}$HOME/.GameScript_bash2${reset} fait simplement partie du nom du dossier."
talk justumen "Le nom du dossier est ${code}.GameScript_bash2${reset}."
talk justumen "Mais sur Linux si un nom de fichier ou dossier commence par un ${code}.${reset}, il sera ${voc}caché${reset}."
talk justumen "En faisant ${learn}pwd${reset}, vous avez bien vu que le terminal est dans le dossier ${code}${HOME}/.GameScript_bash2${reset}."
talk justumen "Ce dossier est donc bien évidemment dans ${code}${HOME}${reset} !"
talk justumen "Mais si vous tentez d'afficher les éléments de ${code}${HOME}${reset}, vous ne le ve verrez pas."
talk_not_press_key justumen "Essayez donc de faire ${learn}ls ${HOME}${reset}."
answer_run "ls ${HOME}" justumen "Non"
talk justumen "Ici il n'est pas dans la liste, pourtant il existe bel et bien, mais il est ${voc}caché${reset}."
talk_not_press_key justumen "Maintenant créez un nouveau dossier 'enfant'."
answer_run "mkdir enfant" justumen "Non"
talk_not_press_key justumen "Déplacez vous dans ce dossier 'enfant' que vous venez de créer."
answer_run "cd enfant" justumen "Non"
talk_not_press_key justumen "Affichez donc le chemin du répertoire courant."
answer_run "pwd" justumen "Non"
talk_not_press_key justumen "Maintenant déplacez vous dans votre répertoire grand parent en utilisant son chemin relatif."
answer_run "cd ../.." justumen "Non"
talk justumen "Vous êtes maintenant dans ${code}${HOME}${reset}."
talk justumen "Mais comment pouvez vous afficher ce dossier caché ?"
talk_not_press_key justumen "Essayez donc de faire ${learn}ls${reset} : le dossier ne sera toujours pas affiché."
answer_run "ls" justumen "Non"
talk justumen "La plupart des commandes peuvent avoir des arguments spéciaux, qui donnent plus de détails à la commande."
talk justumen "Ces arguments spéciaux commence par un ${code}-${reset} et se nomment ${code}options${reset}."
talk_not_press_key justumen "Pour que ${learn}ls${reset} affiche les fichiers ${voc}cachés${reset}, tapez donc ${learn}ls -a${reset}"
answer_run "ls -a" justumen "Non"
talk justumen "Ici vous devriez voir le dossier ${code}.GameScript_bash2${reset}, mais aussi beaucoup d'autres éléments ${voc}cachés${reset}."
talk justumen "Maintenant comment revenir dans ce dossier ${code}.GameScript_bash2${reset} ?"
talk justumen "Vous l'avez compris ${code}./${reset} représente le répertoire courant."
talk justumen "Il est possible de se dépalcer dans ce dossier avec ${learn}cd .GameScript_bash2${reset}."
talk_not_press_key justumen "Mais il est aussi possible de se déplacer dans ce répertoire avec : ${learn}cd ./.GameScript_bash2${reset}, essayez donc cette commande."
answer_run "cd ./.GameScript_bash2" justumen "Non"
talk justumen "J'espère que la différence entre ces deux ${code}.${reset} dans cette commande est pour vous évidente."
talk_not_press_key justumen "Maintenant affichez les fichiers ${voc}cachés${reset} de ce répertoire."
answer_run "ls -a" justumen "Non"
talk justumen "Il n'y en a aucun, mais vous pouvez en revanche voir ${code}.${reset} et ${code}..${reset}"
talk justumen "Maintenant que l'on parle de répertoire avec symbole spéciaux, nous pouvons parler de ${code}~${reset}."
talk justumen "${code}~${reset} représente le répertoire de base de l'utilisateur."
talk justumen "Le plus souvent ce répertoire porte le nom de l'utilisateur dans ${code}/home/${reset}."
talk justumen "Dans votre cas, ${code}~${reset} s'agit de ${code}$HOME${reset}."
talk justumen "Ce ${code}~${reset} étant un répertoire, vous pouvez utilisez ce symbole comme un répertoire."
talk_not_press_key justumen "Déplacez vous donc dans ce répertoire avec ${learn}cd ~${reset}"
answer_run "cd ~" justumen "Non"
talk_not_press_key justumen "Vérifiez maintenant votre répertoire courant."
answer_run "pwd" justumen "Non"
talk justumen "${code}~${reset} remplace dans votre cas ${code}$HOME${reset}"
talk justumen "Pour cibler ce dossier, vous pouvez donc utiliser comme chemin relatif ${code}.GameScript_bash2${reset} ou ${code}./.GameScript_bash2${reset}"
talk justumen "Mais vous avez également, grace à ${code}~${reset}, utiliser un nouveau chemin absolu : ${code}~/.GameScript_bash2${reset}"
talk_not_press_key justumen "Supprimez le fichier enfant avec ${learn}rmdir .GameScript_bash2/enfant${reset}"
answer_run "rmdir .GameScript_bash2/enfant" justumen "Non"
talk_not_press_key justumen "Déplacez vous donc dans le répertoire racine."
answer_run "cd /" justumen "Non"
talk_not_press_key justumen "Maintenant supprimez le dossier ${code}.GameScript_bash2${reset} en utilisant le symbole ${code}~${reset} dans votre commande !"
answer_run "rmdir ~/.GameScript_bash2" justumen "Non"
talk justumen "Parfait !"
talk justumen "Maintenant revenons sur les commandes et leurs ${code}options${reset}."
talk_not_press_key justumen "Listez les fichiers ${voc}cachés${reset} du répertoire courant avec ${learn}ls -a${reset}."
answer_run "ls -a" justumen "Non"
talk justumen "La plupart des arguments ont aussi une version longue, parfois plus facile à mémoriser, qui commence elle par ${code}--${reset}."
talk justumen "Par exemple vous pouvez remplacer ${code}-a${reset} par ${code}--all${reset}."
talk justumen "Les commandes ${code}ls -a${reset} et ${code}ls --all${reset} sont identiques !"
talk_not_press_key justumen "Listez les fichiers ${voc}cachés${reset} de ${code}$HOME${reset}  ${learn}ls --all $HOME${reset}."
answer_run "ls --all $HOME" justumen "Non"
talk justumen "Mais comment pouvoir retenir autant d'options ?"
talk justumen "En fait vous n'avez pas besoin de les mémoriser car vous pouvez toujours accéder au ${code}manuel${reset} d'une commande avec la commande ${learn}man${reset}."
talk justumen "Pour quitter le manuel, utiliser la touche q, comme quitter."
talk_not_press_key justumen "Ouvrez le manuel de la commande ls et regardez rapidement son contenu avec ${learn}man ls${reset}, puis quitter avec la touche q."
answer_run "man ls" justumen "Non"
talk justumen "Si vous ne vous souvenez plus des options d'une commande vous pouvez toujours ouvrir son manuel."
talk justumen "Si vous posez une question sur une commande dont la réponse est dans le manuel, il est possible que vous ayez la réponse : RTFM."
talk justumen "C'est un acronyme anglais pour 'Read The Fucking Manual' ou 'Lit le Putain de Manuel'."
talk justumen "Apprendre à utiliser les manuels est indispensable pour pouvoir se débrouiller seul."
talk justumen "Vous ne pouvez pas mémoriser toutes les options et leurs effets pour toutes les commandes, mais ayez toujours le réflexe de visiter le manuel avant de demander de l'aide."
talk justumen "Avec la répétition vous devriez vous souvenir des options les plus importantes mais le manuel sera roujours là pour vous."
talk justumen "Si vous ne vous souvenez plus de ce que fais une commande, il vous suffit de visiter son manuel."
talk_not_press_key justumen "Faites le pour rmdir, regardez rapidement les options disponibles puis quittez avec q : ${learn}man rmdir${reset}"
answer_run "man rmdir" justumen "Non"
talk justumen "La plupart des commandes ont une option ${code}--help${reset}, qui affiche l'aide de la commande, parfois simplement le contenu du manuel."
talk_not_press_key justumen "Affichez l'aide de rmdir avec ${learn}rmdir --help${reset}"
answer_run "rmdir --help" justumen "Non"
talk_not_press_key justumen "Déplacez vous dans $HOME avec la commande ${learn}cd ~${reset}"
answer_run "cd ~" justumen "Non"
talk_not_press_key justumen "Affichez simplement les éléments du répertoire courant avec ${learn}ls${reset}."
answer_run "ls" justumen "Non"
talk justumen "${learn}ls${reset} utilise par défaut toute la longueur du terminal pour l'affichage."
talk justumen "Mais il est possible de limiter sa longueur avec l'option ${code}-w${reset}."
talk_not_press_key justumen "Ouvrez le manuel de ${code}ls${reset}, lisez les détails de l'option ${code}-w${reset} et quittez le manuel."
answer_run "man ls" justumen "Non"
talk justumen "Certaines options, comme ici ${code}-w${reset}, peuvent aussi avoir des valeurs."
talk justumen "Ici il faudra donner une valeur numérique à ${code}-w${reset}."
talk justumen "Si vous limitez cette longueur à 1, il y aura un nom de fichier par ligne."
talk_not_press_key justumen "Essayez donc cette commande : ${learn}ls -w 1${reset}"
answer_run "ls -w 1" justumen "Non"
talk_not_press_key justumen "Essayez maintenant avec 100 comme limite : ${learn}ls -w 100${reset}"
answer_run "ls -w 100" justumen "Non"
talk justumen "La version longue des options avec valeur est parfois différente avec l'utilisation du signe ${code}=${reset} au lieu d'un espace."
talk_not_press_key justumen "Essayez d'utiliser la version longue avec ${learn}ls --width=100${reset}"
answer_run "ls --width=100" justumen "Non"
talk justumen "Vous êtes maintenant prêt pour le questionnaire ! Allez vérifier vos connaissances !"
rmdir $HOME/.GameScript_bash2
}
function quiz(){
  echo -en "\e[0;33m...\e[0m"
  talk_not_press_key justumen "Bash 'Bourne Again SHell' : Chapitre 2"
  talk_not_press_key justumen "- La réponse doit être la plus courte possible, une commande valide mais ajoutant des caractères inutiles ne fonctionnera pas."
  talk_not_press_key justumen "Exemple : si la réponse est 'ls'. Les réponses 'ls .', 'ls ./' et 'ls ././' seront considérées comme fausses."
  answer_text_fr "Quel est le symbole qui représente le répertoire de travail de l'utilisateur ?" "~"
  answer_text_fr "Par quel symbole commence un fichier caché ?" "."
  answer_text_fr "Par quel symbole commence un dossier caché ?" "."
  answer_text_fr "Comment se déplacer dans le répertoire grand parent ?" "cd ../.."
  answer_text_fr "Quel est le symbole qui représente le répertoire courant ?" "."
  answer_text_fr "Comment afficher le manuel de la commande rm" "man rm"
  answer_text_fr "Par quel symbole commence les options courtes de commande données en argument ?" "-"
  answer_text_fr "Par quel symboles commencent les options longues de commande donnée en argument ?" "--"
  unlock
}

function unlock(){
  #~ talk_not_press_key justumen "Pour débloquer \"bash 2\" dans le chat, allez sur https://rocket.bjornulf.org/direct/boti et tapez : password 246eb9c41f13" #Super secure password ! Please don't cheat for your own good. :-)
  talk_not_press_key justumen "Pour débloquer \"bash 2\" dans le chat, veuillez saisir votre pseudo :"
  echo -en "\\e[1;31;42m # \\e[0m"
  read -r PSEUDO
  echo "Votre pseudo : $PSEUDO"
  PASS=`encode $PSEUDO "246e" "1f13"`
  talk_not_press_key justumen "Allez sur https://rocket.bjornulf.org/direct/boti et tapez : password$PASS"
}

function enter(){
case $1 in
	1) echo -en "\e[0;33m...\e[0m" ;&
	2) talk_not_press_key justumen "Bash Bourne Again SHell : Chapitre 2" ;&
	3) answer_quiz "Cours" "Questionnaire" "Quitter" "4" "5" "6" ;;
	4) code ;;
	5) quiz 1 ;;
	6) exit ;;
esac
}

restore=2 #first line of LIST_4GEN should be environment test (test ~/House)
# justumen_intro_fr

enter 1
