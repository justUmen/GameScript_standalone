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
mkdir Dossier;touch Dossier/X;touch Dossier/Y;chmod 644 Dossier
echo "a">f1;chmod 000 f1;echo "ab">f2;chmod 444 f2;echo "abc">f3;chmod 400 f3;echo "abcd">f4;chmod 477 f4
talk justumen "Dans ce chapitre nous revenons sur la commande ${code}ls${reset}, l'une des commandes les plus importantes."
talk justumen "Et ici nous allons parler de son option la plus importante : ${code}-l${reset}"
talk_not_press_key justumen "Vous pouvez taper : ${learn}ls -l${reset}"
answer_run "ls -l" justumen "Non"
talk justumen "Avec cette option, ${code}ls${reset} nous donne plus d'informations sur les éléments du répertoire courant."
talk justumen "Vous avez au début une chaine de caractères étrange composé de ${code}-${reset} et de lettres à gauche du premier espace de chaque ligne."
talk justumen "Le premier caractère représente le type de l'élément."
talk justumen "Si c'est un ${code}-${reset}, c'est un fichier, si c'est un ${code}d${reset}, c'est un dossier."
talk justumen "Avec ce premier caractère, on voit clairement que 'Dossier' est un dossier et que les autres sont des fichiers."
talk justumen "Les neufs autres caractères représentent les ${voc}permissions${reset} de l'élément en question."
talk justumen "Il est possible d'avoir plusieurs utilisateurs sur un même ordinateur."
talk justumen "Mais certains de vos fichiers méritent peut-être d'être protégés."
talk justumen "Par exemple, il semblerai raissonnable que votre petite soeur ne puisse pas supprimer vos fichier personnels."
talk justumen "En revanche, même si vous ne voulez pas qu'elle puisse supprimer vos fichiers, vous avez peut-être besoin de lui donner la permission de les lire."
talk justumen "Ces neufs caractères sont utilisés pour définir avec précision les permissions que vous désirez."
talk justumen "La permission 'minimale' est ${code}---------${reset} et la permission 'maximale' est ${code}rwxrwxrwx${reset}."
talk justumen "Chaque ${code}-${reset} veut dire que qu'un certain type de permission est ${voc}désactivé${reset}."
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
talk justumen "Exemple : -${codeFile}rw-${reset}r----- 2 ${codeFile}albert${reset} familleEinstein 4096 Feb 19 00:51 Exemple"
talk justumen "Le nom du propriétaire du fichier 'Exemple' est ici 'albert'."
talk justumen "Les trois caractères en vert sont les permissions d'albert."
talk justumen "Exemple : -rw-${codeFile}r--${reset}--- 2 albert ${codeFile}familleEinstein${reset} 4096 Feb 19 00:51 Exemple"
talk justumen "Ici les trois caractères en vert sont les permissions des membres du ${voc}groupe${reset} 'familleEinstein'."
talk justumen "Ici on peut imaginer l'existence d'un groupe 'familleEinstein' pour la famille Einstein."
talk justumen "Exemple : -rw-r--${codeFile}---${reset} 2 albert familleEinstein 4096 Feb 19 00:51 Exemple"
talk justumen "Et enfin, les trois derniers caractères sont les permissions des autres utilisateurs."
talk justumen "Ceux qui ne sont ni albert, ni dans le groupe "familleEinstein"."
talk justumen "Dans cet exemple, albert, le propriétaire du fichier a le droit de lecture avec ce ${code}r${reset} et le droit d'écriture avec ce ${code}w${reset}, mais pas le droit d'exécution car le troisième caractère n'est pas un ${codeError}x${reset} mais un ${code}-${reset}."
talk justumen "Les membres du groupe 'familleEinstein' ont uniquement le droit de lecture sur ce fichier avec ce ${code}r${reset}."
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
talk justumen "Pour pouvoir utiliser la commande ${code}cat${reset}, il vous aurez fallu un ${code}r${reset} à la place de ce tiret rouge : -${codeError}-${reset}--------."
talk_not_press_key justumen "Sur le fichier 'f2', vous avez ce 'r' dans : -${code}r${reset}--r--r-- qui vous donne le droit de lecture. Affichez le contenu de 'f2'."
answer_run "cat f2" justumen "Non"
talk justumen "Ici pas de problème à l'affichage."
talk_not_press_key justumen "Ajoutez le texte 'cd' à la fin du fichier 'f2'."
answer_run "echo cd>>f2" justumen "Non"
talk justumen "Sur 'f2' nous avons encore un problème de permission."
talk justumen "Cette fois c'est un ${code}w${reset} qui nous manque à la place de ce tiret rouge : -r${codeError}-${reset}-r--r--."
talk justumen "Mais 'f3' semble avoir à la fois le ${code}r${reset} et le ${code}w${reset}."
talk_not_press_key justumen "Affichez les permissions de 'f3' avec le nom du fichier en argument de ls :  ${learn}ls -l f3${reset}."
answer_run "ls -l f3" justumen "Non"
talk_not_press_key justumen "Affichez le contenu de 'f3'."
answer_run "cat f3" justumen "Non"
talk_not_press_key justumen "Ajoutez 'def' au fichier 'f3'."
answer_run "echo def>>f3" justumen "Non"
talk_not_press_key justumen "Affichez le contenu de 'f3' a nouveau."
answer_run "cat f3" justumen "Non"
talk justumen "Parfait ! Nous pouvons enfin utiliser les commandes que nous avons apprises."
talk justumen "Mais nous n'avons jamais vu ce problème de permission dans les chapitres précédents..."
talk justumen "Car je viens de les simuler pour vous..."
talk justumen "Vous savez déjà créer un fichier texte avec ${code}echo${reset}."
talk_not_press_key justumen "Mais vous pouvez aussi utiliser la commande ${code}touch${reset}, faites donc : ${learn}touch file${reset}"
answer_run "touch file" justumen "Non"
talk justumen "Maintenant nous pouvons voir les permissions qui sont par défaut lors de la création d'un nouveau fichier."
talk_not_press_key justumen "Pour avoir les permissions de 'file' : ${learn}ls -l file${reset}"
answer_run "ls -l file" justumen "Non"
talk justumen "Si le fichier a été créé par vous, vous aurez par défaut le droit de lecture et d'écriture."
talk justumen "Attention par contre si ce fichier ne vient pas de vous, il peut avoir des permissions limités ou inattendues."
talk justumen "Nous pouvons voir ici le nom du propriétaire du fichier, mais est-ce bien vous ?"
talk_not_press_key justumen "Pour connaitre votre nom d'utilisateur dans ce terminal, vous pouvez taper : ${learn}whoami${reset}"
answer_run "whoami" justumen "Non"
talk justumen "'Who am I ?' est l'anglais pour 'Qui suis-je ?'."
talk justumen "Ici votre nom correspond effectivement au nom du propriétaire de ce fichier."
talk justumen "Mais il existe sur votre machine au moins un autre utilisateur !"
talk justumen "Cet utilisateur possède les droits de vie ou de mort de tout ce qui existe dans votre système..."
talk justumen "Il s'agit de votre compte administrateur, plus connu sous le nom de ${voc}root${reset}."
talk justumen "Traditionnelement, vos fichiers personnels doivent être stockés dans : /home/votrenom"
talk justumen "Et vous devriez être maitre de tout ce qu'il se passe à l'intérieur."
talk justumen "Mais en tant que simple utilisateur, vous ne pouvez contrôler que les éléments de ce répertoire !"
talk_not_press_key justumen "Essayez donc d'afficher les permissions d'un autre dossier, le répertoire racine par exemple : ${learn}ls -l /${reset}"
answer_run "ls -l /" justumen "Non"
talk justumen "Ici nous voyons bien que le propriétaire de ces éléments est ${voc}root${reset}."
talk justumen "Vous n'êtes pas ${voc}root${reset}, les trois premiers caractères de permissions ne vous concernent donc pas. : d${codeError}rwx${reset}r-xr-x"
talk justumen "Vous ne faites également pas partie du groupe en question : drwx${codeError}r-x${reset}r-x"
talk justumen "Les permissions qui vous concernent sont les trois dernières : drwxr-x${codeFile}r-x${reset}"
talk justumen "Vous avez donc les droits de lecture ${codeFile}r${reset} et d'exécution ${codeFile}x${reset}."
talk justumen "Mais qu'en est-il de cette permission ${voc}d'exécution${reset} ?"
talk_not_press_key justumen "Affichons à nouveau les permissions des éléments du répertoire courant."
answer_run "ls -l" justumen "Non"
talk justumen "Ici nous avons un dossier avec le droit de lecture et d'écriture."
talk_not_press_key justumen "Rentrons dans ce dossier."
answer_run "cd Dossier" justumen "Non"
talk justumen "Ici, malgré avoir le droit de lecture sur ce dossier, nous ne pouvons pas nous déplacer dedans."
talk justumen "Pour un fichier texte, les permissions ${codeFile}x${reset} n'ont aucun effet..."
talk justumen "Mais ici avec un ${voc}dossier${reset}, le ${codeFile}x${reset} joue un rôle important !"
talk justumen "Etrangement, nous avons le droit de lecture avec ce d${codeFile}r${reset}w-r--r--"
talk_not_press_key justumen "Donc nous pouvons afficher les éléments de ce dossier."
answer_run "ls Dossier" justumen "Non"
talk justumen "Le contenu de 'Dossier' s'affiche. Il contient un fichier 'X' et un fichier 'Y'."
talk_not_press_key justumen "Affichons maintenant les permissions des fichiers dans ce dossier."
answer_run "ls -l Dossier" justumen "Non"
talk justumen "Ici l'absence de ${codeFile}x${reset} dans les permissions de 'Dossier' nous empêche d'accéder aux détails."
talk justumen "Attention donc à ces permissions !"
talk justumen "Si quelque chose ne se passe pas comme prévu, il se peut que vous ayez simplement un problème de permission à régler."
talk justumen "C'est ce que nous allons voir maintenant : Comment changer ces permissions ?"
talk justumen "Donc en premier lieu il faut que vous soyiez capable d'identifier la permission qu'il vous manque !"
talk justumen "La commande ${code}cat${reset} par exemple a besoin d'une permission de lecture : ${codeFile}r${reset}."
talk justumen "Le fichier 'f1' ne nous donne pas cette permission qu'il nous faut pour l'afficher."
talk justumen "Pour changer ces permissions il faudra utiliser la commande : ${code}chmod${reset}."
talk justumen "Il faudra d'abord mémoriser 3 nouvelles lettres :"
talk justumen "${code}u${reset} pour l'${code}u${reset}tilisateur / le propriétaire : -${codeFile}rwx${reset}rwxrwx"
talk justumen "${code}g${reset} pour le ${code}g${reset}roupe : -rwx${codeFile}rwx${reset}rwx"
talk justumen "et ${code}o${reset} pour '${code}o${reset}thers', l'anglais de 'autres' : -rwxrwx${codeFile}rwx${reset}"
talk justumen "Vous pouvez ensuite utilisez ces lettres en conjonction avec les lettres 'r', 'w' et 'x' que vous connaissez déjà."
talk justumen "Vous devez également utiliser les symboles ${code}+${reset} et ${code}-${reset}, pour ajouter ou supprimer une permission."
talk_not_press_key justumen "Relancez : ${learn}ls -l${reset}"
answer_run "ls -l" justumen "Non"
talk justumen "Et prenons un exemple : Comment pour pouvoir nous autoriser l'affichage de 'f1' ?"
talk justumen "Autrement dit : transformer ---------- en -r--------."
talk justumen "D'abord nous voulons changer les permissions du propriétaire, il faudra donc utiliser la lettre ${code}u${reset}."
talk justumen "Nous voulons ajouter une permission, il faudra donc utiliser le symbole ${code}+${reset}."
talk justumen "Nous voulons le droit de lecture, il faudra donc bien sûr utiliser la lettre ${code}r${reset}."
talk justumen "Et la cible de chmod sera le fichier 'f1'."
talk justumen "La syntaxe sera donc la suivante : ${learn}chmod u+r f1${reset}"
talk_not_press_key justumen "Avant de lancer cette commande, essayez donc d'afficher 'f1'."
answer_run "cat f1" justumen "Non"
talk_not_press_key justumen "Ajoutons donc le droit de lecture à 'f1' pour le propriétaire avec : ${learn}chmod u+r f1${reset}"
answer_run "chmod u+r f1" justumen "Non"
talk_not_press_key justumen "Relancez : ${learn}ls -l${reset}"
answer_run "ls -l" justumen "Non"
talk justumen "Ici nous avons bien : -r-------- pour le fichier 'f1'."
talk_not_press_key justumen "Et enfin, affichez le fichier 'f1'."
answer_run "cat f1" justumen "Non"
talk justumen "Vous pouvez donc utiliser toutes les combinaisons que vous voulez : ${learn}u+r${reset}, ${learn}g-w${reset}, ${learn}u+x${reset}, etc..."
talk justumen "Mais vous pouvez aussi les cumuler avec d'autres, comme par exemple pour donner au propriétaire le droit de lecture ET d'écriture : ${learn}u+rw${reset}."
talk justumen "Pour enlever aux membres du groupe et aux autres le droit d'écriture : ${learn}go-w${reset}"
talk justumen "Ou encore pour donner tous les droits à tout le monde : ${learn}ugo+rwx${reset}."
talk justumen "Ou enlever tous les droits de tout le monde : ${learn}ugo-rwx${reset}."
talk justumen "Avant de passer au questionnaire je vous rappelle que le droit d'écriture donne le droit de ${voc}suppression${reset}."
talk justumen "Bonne chance !"
chmod 700 $HOME/.GameScript_bash5/f1 $HOME/.GameScript_bash5/f2 $HOME/.GameScript_bash5/f3 $HOME/.GameScript_bash5/f4 $HOME/.GameScript_bash5/Dossier
rm $HOME/.GameScript_bash5/f1
rm $HOME/.GameScript_bash5/f2
rm $HOME/.GameScript_bash5/f3
rm $HOME/.GameScript_bash5/f4
rm $HOME/.GameScript_bash5/file
rm $HOME/.GameScript_bash5/Dossier/X
rm $HOME/.GameScript_bash5/Dossier/Y
rmdir $HOME/.GameScript_bash5/Dossier
rmdir $HOME/.GameScript_bash5
}
function quiz(){
  echo -en "\e[0;33m...\e[0m"
  talk_not_press_key justumen "Bash 'Bourne Again SHell' : Chapitre 5"
  talk_not_press_key justumen "- La réponse doit être la plus courte possible, une commande valide mais ajoutant des caractères inutiles ne fonctionnera pas."
  talk_not_press_key justumen "Exemple : si la réponse est 'ls'. Les réponses 'ls .', 'ls ./' et 'ls ././' seront considérées comme fausses."
  answer_text_fr "Comment afficher les permissions des éléments du répertoire de travail de l'utilisateur ?" "ls -l ~"
  answer_text_fr "Quelle lettre représente un dossier dans le résultat de 'ls -l' ?" "d"
  answer_text_fr "Quel symbole représente un fichier dans le résultat de 'ls -l' ?" "-"
  answer_text_fr "Quelle lettre représente le droit d'écriture dans le résultat de 'ls -l' ?" "w"
  answer_text_fr "Quelle lettre représente le droit de lecture dans le résultat de 'ls -l' ?" "r"
  answer_text_fr "Quelle lettre représente le droit d'exécution dans le résultat de 'ls -l' ?" "x"
  answer_text_fr "Quelle est la commande capable de modifier les permissions d'un fichier ?" "chmod"
  answer_text_fr "Quelle lettre représente le propriétaire pour la commande chmod ?" "u"
  answer_text_fr "Comment supprimer la permission de lecture au propriétaire du fichier 'test' ?" "chmod u-r test"
  answer_text_fr "Comment ajouter la permission d'exécution sur le fichier 'test' à tous les utilisateurs sauf pour le propriétaire ?" "chmod go+x test"
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
  PASS=`encode $PSEUDO "28ab" "3d4e"`
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
