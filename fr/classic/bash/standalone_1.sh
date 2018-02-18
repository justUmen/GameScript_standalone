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
[ -d "$HOME/House" ] && echo "Erreur innatendu, ${HOME}/House existe déjà sur votre système ! Supprimez ce dossier $HOME/House et relancer ce script." && exit
cd ~/
talk justumen "Hey salut tout le monde et bienvenu sur la ligne de commande linux."
talk justumen "Avant de pouvoir apprendre notre première commande, il va falloir d'abord comprendre la logique derrière l'organisation des répertoires et des fichiers sur Linux."
talk justumen "Commençons par nous intéresser aux 'répertoires', qui portent aussi le nom de 'dossiers'."
real_tree_1
talk justumen "Vous pouvez imaginer le système d'organisation des dossiers linux comme un arbre."
talk justumen "Dans cette arbre les lignes qui représentent les dossiers sont en bleu ciel."
talk justumen "A la base de l'arbre vous avez le symbole ${code}/${reset} qui représente le ${voc}répertoire racine${reset}."
talk justumen "C'est un répertoire spécial qui contiendra TOUS les autres dossiers du système."
real_tree_2
talk justumen "Dans cet arbre, à chaque fois qu'une branche se sépare de l'arbre, c'est un nouveau dossier."
talk justumen "Ce passage à une autre branche se remarque aussi dans les titres en bleu ciel avec l'apparition d'un nouveau symbole '/' supplémentaire."
talk justumen "Par exemple, ${code}/home/${reset} représente le dossier 'home' dans le ${voc}répertoire racine${reset}."
talk justumen "${code}/home/user/${reset} représente le dossier 'user', qui est dans le dossier 'home', qui est lui même dans le ${voc}répertoire racine${reset}."
talk justumen "Et ainsi de suite, comme par exemple : ${code}/home/user/Images/${reset}"
talk justumen "Dans ce cas, 'Images' est dans 'user', 'user' est dans 'home' et 'home' est dans '/'."
talk justumen "Mais attention, pour représenter un répertoire, il n'est pas obligatoire de rajouter un '/' à la fin."
talk justumen "C'est à dire que ${learn}/home/user/${reset} est équivalent à ${learn}/home/user${reset}."
talk justumen "De même, ${learn}/home/${reset} et ${learn}/home${reset} sont équivalents."
real_tree_3
talk justumen "Parlons maintenant des fichiers, dans mon arbre ils sont ici en vert. Ce sont dans mon exemple des feuilles et sont directement acrochés à une branche, ou parfois directement au tronc."
talk justumen "Ces fichiers appartiennent donc directement à un dossier. Mais nous avons ici quelques problèmes en rouge, des fichiers qui ne peuvent pas exister..."
talk justumen "${codeError}fichier1${reset} ne peut pas exister car il y a déjà un fichier du même nom ${codeFile}fichier1${reset} dans le même répertoire. Ici le répertoire racine. (/fichier1)"
talk justumen "En revanche, en haut, ${codeFile}fichier1${reset} peut exister car même si le nom du fichier est le même, ils ne sont pas dans le même dossier."
talk justumen "Les éléments d'un système linux doivent avoir une référence unique : ici ${learn}/fichier1${reset} et ${learn}/home/fichier1${reset} ne sont pas en conflit."
talk justumen "Le fichier ${codeError}/home${reset} ne peut pas exister non plus car il y a déjà un dossier ${code}/home/${reset} qui utilise le même nom au même endroit."
talk justumen "Pour que ces fichiers puissent exister, il faut leur donner d'autres noms."
real_tree_4
talk justumen "Ici, il suffit d'appeler le deuxième fichier 'fichier2' et le tour est joué."
talk justumen "Pour ${codeError}home${reset}, il suffit également de lui donner un autre nom qui ne pose pas de problème comme 'Home'."
talk justumen "Oui ! Sur linux, les majuscules sont importantes. 'Home' et 'home' sont deux noms différents."
talk justumen "Quand les majuscules ne sont pas identiques au minuscules, on dit que les noms sont ${voc}sensibles à la casse${reset}."
talk justumen "Effectivement, linux est ${voc}sensible à la casse${reset}. C'est à dire que 'home', 'Home', 'hOme', 'hoMe', 'homE', 'HoMe', 'hOmE', 'HOme', 'hoME', 'HomE', 'hOMe', 'HOME', etc... sont tous des noms valides et différents !"
tree_1
talk justumen "Il est aussi possible de représenter l'arborescence linux de cette manière."
tree_2
talk justumen "Et ici le même exemple avec les fichiers. Identique à l'arbre du dessus."
tree_3
talk justumen "Mais l'arborescence peut aussi être très claire sans les décalages."
talk justumen "Si ça n'est pas encore très intuitif pour vous, ne vous inquiétez pas."
talk justumen "Maintenant que vous connaissez la logique, avec le temps et la répétition ce sera pour vous très bientôt évident."
talk justumen "Ce genre de ligne, qui commence par le ${voc}répertoire racine${reset} '/' s'appelle le ${voc}chemin absolu${reset} d'un fichier ou d'un dossier."
talk justumen "Elle représente avec précision uniquement le fichier ou dossier en question."
talk justumen "Ici il est impossible d'avoir deux lignes identiques."
talk justumen "Ce ${voc}chemin absolu${reset} est le concept le plus fondamental de la ligne de commande linux."
talk justumen "Maintenant nous pouvons voir notre première commande linux."
talk justumen "Commençons par créer un nouveau dossier avec la commande ${learn}mkdir${reset} (${learn}M${reset}a${learn}K${reset}e ${learn}DIR${reset}ectory)."
talk justumen "Il suffit de taper mkdir, suivi d'un espace et enfin du nom du dossier."
talk_not_press_key justumen "Créeons maintenant le dossier House en faisant : ${learn}mkdir House${reset} puis validez la commande en appuyant sur la touche entrée."
answer_run "mkdir House" justumen "Non"
talk_not_press_key justumen "Affichons maintenant les fichiers et dossiers avec un simple ${learn}ls${reset} (${learn}L${reset}i${learn}S${reset}t)."
answer_run "ls" justumen "Non"
talk justumen "Vous devriez voir le dossier que vous venez de créer."
talk justumen "Maintenant rentrons dans ce dossier avec la commande ${learn}cd${reset} (${learn}C${reset}hange ${learn}D${reset}irectory)."
talk_not_press_key justumen "Pour cela, il suffit de faire cd, suivi du nom du dossier voulu, dans notre cas : ${learn}cd House${reset}."
answer_run "cd House" justumen "Non"
talk_not_press_key justumen "Maintenant réaffichons les fichiers et dossiers avec un simple ${learn}ls${reset}."
answer_run "ls" justumen "Non"
talk justumen "Ici le répertoire House est vide, c'est normal puisque vous venez de le créer."
talk justumen "Mais qu'en est-il ici du ${voc}chemin absolu${reset} dont je vous ai parlé avant ?"
talk justumen "En fait, un terminal linux tourne toujours dans un dossier, et peut se 'déplacer' dans l'arborescense du système."
talk justumen "C'est ce que vous avez fait avec la commande ${learn}cd House${reset}, vous avez déplacé votre terminal dans le dossier House."
talk_not_press_key justumen "Pour savoir dans quel répertoire votre terminal est en ce moment, il suffit de taper ${learn}pwd${reset} (${learn}P${reset}rint ${learn}W${reset}orking ${learn}D${reset}irectory)."
answer_run "pwd" justumen "Non"
talk justumen "Le résultat que vous voyiez ici est le ${voc}chemin absolu${reset} du répertoire ou vous êtes en ce moment."
talk justumen "Ce répertoire où vous êtes porte un nom spécial : le ${voc}${voc}répertoire courant${reset} ${reset}."
talk justumen "Comme je vous l'ai déjà dit, il n'est pas obligatoire de mettre un / pour le dernier dossier c'est pourquoi vous voyez ici ${learn}$(pwd)${reset} et non pas ${learn}$(pwd)/${reset}."
talk justumen "Voilà donc 4 commandes linux fondamentales : ${learn}pwd${reset}, ${learn}ls${reset}, ${learn}cd${reset} et ${learn}mkdir${reset}."
talk justumen "${learn}pwd${reset} et ${learn}ls${reset} sont des commandes particulièrement innoffensives, elle ne font que vous donnez des renseignements."
talk justumen "N'hésitez donc pas à les taper systématiquement, dès que vous êtes dans un terminal."
talk justumen "${learn}pwd${reset}, pour savoir quel est votre ${voc}répertoire courant${reset}."
talk justumen "et ${learn}ls${reset}, pour afficher le contenu de votre ${voc}répertoire courant${reset}."
talk_not_press_key justumen "Maintenant créons un nouveau répertoire 'Room' dans notre ${voc}répertoire courant${reset} en faisant ${learn}mkdir Room${reset}."
answer_run "mkdir Room" justumen "Non"
talk_not_press_key justumen "Changeons le ${voc}répertoire courant${reset} avec ${learn}cd Room${reset}."
answer_run "cd Room" justumen "Non"
talk_not_press_key justumen "Maintenant, affichez le chemin absolu de votre ${voc}répertoire courant${reset}."
answer_run "pwd" justumen "Non"
talk_not_press_key justumen "Super, et maintenant affichez les éléments du ${voc}répertoire courant${reset}."
answer_run "ls" justumen "Non"
talk justumen "Impressionnant ! Vous maitrisez les deux commandes linux les plus importantes : ${learn}pwd${reset} et ${learn}ls${reset}."
talk justumen "Les commandes ${learn}cd${reset} et ${learn}mkdir${reset} que nous avons vu ensemble sont plus complexes."
talk justumen "Il faut leur donner une cible, ou un nom comme par exemple : ${learn}mkdir Room${reset}."
talk justumen "Cette 'cible' est appelée un ${voc}argument${reset}!"
talk justumen "Mais il est aussi possible d'avoir des commandes avec plusieurs ${voc}arguments${reset}."
talk justumen "Il suffit de continuer à les séparer par des espaces"
talk_not_press_key justumen "On va créer les dossiers 'bed', 'closet' et 'desk' en une seule commande. Tapez donc la commande : ${learn}mkdir bed closet desk${reset}"
answer_run "mkdir bed closet desk" justumen "Non"
talk_not_press_key justumen "Affichez les éléments du ${voc}répertoire courant${reset}."
answer_run "ls" justumen "Non"
talk_not_press_key justumen "Maintenant pour supprimer ces dossiers, vous pouvez taper : ${learn}rmdir bed closet desk${reset}. (${learn}R${reset}e${learn}M${reset}ove ${learn}DIR${reset}ectory)"
answer_run "rmdir bed closet desk" justumen "Non"
talk justumen "${learn}rmdir${reset} est une commande plutôt innofensive, parce qu'elle refusera de supprimer un dossier si celui ci n'est pas vide."
talk justumen "Ce qui peut empêcher de grave accidents. Si par exemple, vous faites par erreur ${learn}rmdir /home${reset}."
talk justumen "La commande ${learn}rm${reset} est la commande pour supprimer des fichiers. (${learn}R${reset}e${learn}M${reset}ove)"
touch virus0 virus1 virus2 virus3 virus4
talk justumen "Tout comme ${learn}mkdir${reset}, il faudra lui donner un ${voc}argument${reset} le nom du fichier en question, par exemple : ${learn}rm test${reset}."
talk_not_press_key justumen "Il vient de se passer quelque chose de bizarre... Affichez le contenu du ${voc}répertoire courant${reset}."
answer_run "ls" justumen "Non"
talk_not_press_key justumen "rmdir${reset} a bien supprimé les dossiers. Mais ces fichiers n'ont rien à faire ici, supprimez le fichier 'virus0' avec ${learn}rm virus0${reset}"
answer_run "rm virus0" justumen "Non"
talk_not_press_key justumen "Affichez à nouveau les éléments du ${voc}répertoire courant${reset}, pour voir s'il est toujours là."
answer_run "ls" justumen "Non"
talk justumen "Super, virus0 n'existe plus."
talk justumen "Mais attention avec la commande ${learn}rm${reset}, c'est une commande de professionnel à ne pas utiliser à la légère."
talk justumen "Les fichiers sont supprimés directement, il ne vont pas dans une corbeille, donc soyez prudent."
talk justumen "Une erreur en ligne de commande ne pardonne pas."
talk justumen "Une faute de frappe ou un ${voc}répertoire courant${reset} innatendu peut avoir de graves conséquences."
talk justumen "Avant de lancer une commande, soyez donc sûrs de ce que vous faites."
talk justumen "N'hésitez jamais a lancer ${learn}pwd${reset} et ${learn}ls${reset} pour savoir quel est votre ${voc}répertoire courant${reset} et vérifier son contenu."
talk justumen "Mais nous avons d'autres virus à supprimer. Mais on peut aussi les supprimer d'une autre manière."
talk justumen "En utilisant son ${voc}chemin absolu${reset} dont j'ai déjà parlé auparavant."
cd ~/
talk justumen "Lorsque vous avez tapé ${learn}rm virus${reset}, vous demandez de supprimer le fichier 'virus' dans votre ${voc}répertoire courant${reset}."
talk_not_press_key justumen "Je viens de changer votre ${voc}répertoire courant${reset}. Affichez le maintenant."
answer_run "pwd" justumen "Non"
talk_not_press_key justumen "Affichez le contenu de votre ${voc}répertoire courant${reset}."
answer_run "ls" justumen "Non"
talk justumen "Le fichier virus1, existe toujours dans le répertoire 'Room', mais étant donné votre ${voc}répertoire courant${reset}, vous ne pouvez pas lancer ${learn}rm virus1${reset}."
talk justumen "Heureusement, vous connaissez le ${voc}chemin absolu${reset} du fichier 'virus1' : ${learn}$(echo $HOME)/House/Room/virus1${Reset}"
talk justumen "Vous pouvez utiliser son ${voc}chemin absolu${reset} comme ${voc}argument${reset}. Cette commande marchera donc quel que soit votre ${voc}répertoire courant${reset} actuel !"
talk_not_press_key justumen "Supprimez le avec ${learn}rm $(echo $HOME)/House/Room/virus1${reset}."
answer_run "rm $(echo $HOME)/House/Room/virus1" justumen "Non"
talk justumen "Maintenant, comment pouvoir vérifier que le fichier a bien ete supprimé ?"
talk justumen "Lorsqu'une commande linux ne se passe pas comme prévue, elle vous renvoit très souvent une erreur."
talk_not_press_key justumen "Essayez de supprimer le fichier 'virus1' à nouveau en utilisant son ${voc}chemin absolu${reset}."
answer_run "rm $(echo $HOME)/House/Room/virus1" justumen "Non"
talk justumen "Ici la commande ${learn}rm${reset} vous renvoi une erreur, le fichier n'existe donc déjà plus."
talk justumen "Maintenant, on peut aussi utiliser le ${voc}chemin absolu${reset} du dossier 'Room' pour afficher son contenu."
talk justumen "Vous connaissez déjà la commande ${learn}ls${reset}, pour lister le contenu du ${voc}répertoire courant${reset}."
talk justumen "Sans ${voc}argument${reset}, avec un simple ${learn}ls${reset}, le répertoire utilisé sera automatiquement le ${voc}répertoire courant${reset}."
talk justumen "Mais il est en fait aussi possible de donner un ${voc}argument${reset} a ls."
talk justumen "Cet ${voc}argument${reset} représente le répertoire cible, par exemple ${learn}ls /${reset} affichera le contenu du ${voc}répertoire racine${reset}."
talk_not_press_key justumen "Maintenant nous pouvons afficher le contenu du répertoire 'Room' sans se déplacer dans l'arborescence, avec : ${learn}ls $(echo $HOME)/House/Room/${reset}."
answer_run "ls $(echo $HOME)/House/Room/" justumen "Non"
talk justumen "Excellent, le fichier 'virus1' n'existe plus."
talk justumen "Encore une fois, je vous rappelle que dans un ${voc}chemin absolu${reset}, si le dernier caractère est un '/', il n'est pas obligatoire."
talk_not_press_key justumen "Donc ici le dernier '/' dans ${learn}$(echo $HOME)/House/Room/${reset} n'est pas obligatoire. Testez donc a nouveau avec ${learn}ls $(echo $HOME)/House/Room${reset}"
answer_run "ls $(echo $HOME)/House/Room" justumen "Non"
talk justumen "Pas de problème, le résultat est le même pour ${learn}ls $(echo $HOME)/House/Room/${reset} et ${learn}ls $(echo $HOME)/House/Room${reset}."
talk justumen "Quand vous avez fait ${learn}rm virus${reset} pour la première suppression, vous avez utilisé ce que l'on appelle le ${voc}chemin relatif${reset}."
talk justumen "On dit que ce chemin est relatif parce qu'il dépend de votre ${voc}répertoire courant${reset}."
talk justumen "Imaginons deux fichiers 'virus' avec comme ${voc}chemin absolu${reset} : ${learn}/virus${reset} et ${learn}/bin/virus${reset}."
talk justumen "Si ${learn}pwd${reset} vous donne ${learn}$(echo $HOME)${reset}. Un ${learn}rm virus${reset} ne supprimera aucun d'entre eux. Cette commande voudra supprimer le fichier ${learn}/home/umen/virus${reset}."
cd "$(echo $HOME)"
talk justumen "D'ou la très grande utilité de ce ${voc}chemin absolu${reset}. Vous pouvez utiliser ${learn}rm /virus${reset} et ${learn}rm /bin/virus${reset} quel que soit votre ${voc}répertoire courant${reset}."
talk_not_press_key justumen "Je viens de vous déplacer dans l'arborescence, affichez donc le chemin absolu du ${voc}répertoire courant${reset}."
answer_run "pwd" justumen "Non"
talk justumen "Pour changer de ${voc}répertoire courant${reset}, vous pouvez utiliser la commande ${learn}cd${reset}. (${learn}C${reset}hange ${learn}D${reset}irectory)"
talk justumen "Pour revenir dans le répertoire 'Room', vous pouvez utiliser le ${voc}chemin absolu${reset} avec la commande ${learn}cd $(echo $HOME)/House/Room/${reset}"
talk justumen "Mais il n'est pas obligatoire d'utiliser le ${voc}chemin absolu${reset}, il est possible de revenir dans le répertoire 'Room' en utilisant un ${voc}chemin relatif${reset}."
talk justumen "Vous voulez aller dans ${learn}$(echo $HOME)/House/Room/${reset} mais vous êtes déjà dans ${learn}$(echo $HOME)${reset}."
talk_not_press_key justumen "Il est donc possible de se déplacer de là où vous êtes avec un ${learn}cd House/Room/${reset}. Allez-y."
answer_run "cd House/Room/" justumen "Non"
talk_not_press_key justumen "Affichez maintenant les éléments de votre ${voc}répertoire courant${reset}."
answer_run "ls" justumen "Non"
talk_not_press_key justumen "Ici vous voyez encore des fichiers virus, supprimez le fichier virus2 en utilisant le ${voc}chemin relatif${reset}."
answer_run "rm virus2" justumen "Non"
talk justumen "Excellent!"
talk justumen "Nous avons vu dans l'exemple précédent que ${learn}cd House/Room/${reset} utilise un ${voc}chemin relatif${reset}, pourtant cette commande contient aussi des '/."
talk justumen "Donc comment reconnaitre un ${voc}chemin absolu${reset} d'un ${voc}chemin relatif${reset} ?"
talk justumen "Le ${voc}chemin absolu${reset} est en fait très facile à reconnaitre !"
talk justumen "Il commence toujours à la racine, c'est à dire que le premier caractère d'un ${voc}chemin absolu${reset} est toujours '/'."
talk justumen "Il y a aussi une syntaxe spéciale très utile pour le ${voc}chemin relatif${reset} les ${learn}..${reset}"
talk justumen "${learn}..${reset} représente dans l'arborescence linux le parent du ${voc}répertoire courant${reset}."
talk justumen "C'est le vocabulaire que nous employons pour parler de cette arborescence, ce sont des relations parents / enfants."
talk justumen "Par exemple pour ${learn}/home/user/test/${reset}, le dossier parent de test est user. Le dossier parent de user est home."
talk justumen "Et bien evidemment test est un enfant de user, et user est un enfant de home."
talk justumen "Cibler les enfants en ${voc}argument${reset} avec un ${voc}chemin relatif${reset} est très simple, il suffit d'ecrire le nom des parents successifs."
talk justumen "Comme par exemple avec la commande de tout a l'heure : ${learn}cd House/Room/${reet}"
talk justumen "Pour cibler les parents, c'est un peu plus compliqué. Il faut utiliser ${learn}..${reset}."
talk justumen "Affichez le chemin absolu de votre ${voc}répertoire courant${reset}."
talk justumen "Vous connaissez maintenant la commande pour le changer : ${learn}cd${reset}."
talk justumen "Ici nous allons nous déplacer dans le répertoire parent. Nous sommes dans ${learn}$(echo $HOME)/House/Room/${reset} mais nous voulons aller dans ${learn}$(echo $HOME)/House/${reset}"
talk_not_press_key justumen "Il est possible de remonter d'un cran dans l'arborescence, ou comme je viens de le dire de se déplacer dans le répertoire parent avec un ${learn}cd ..${reset}"
answer_run "cd .." justumen "Non"
talk_not_press_key justumen "Affichez le chemin absolu du ${voc}répertoire courant${reset}."
answer_run "pwd" justumen "Non"
talk justumen "J'espère que le résultat de ${learn}pwd${reset} est logique pour vous."
talk_not_press_key justumen "Mais il nous reste deux virus à supprimer, commençons par supprimer le fichier virus3 avec le ${voc}chemin relatif${reset}."
answer_run "rm Room/virus3" justumen "Non"
talk_not_press_key justumen "Bien. Maintenant supprimons le fichier virus4 en utilisant le ${voc}chemin absolu${reset}."
answer_run "rm $(echo $HOME)/House/Room/virus4" justumen "Non"
talk justumen "Parfait ! Felicitations, vous avez tout compris."
rmdir ~/House/Room
rmdir ~/House
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
restore=$(expr $restore + 1)
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
restore=$(expr $restore + 1)
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
restore=$(expr $restore + 1)
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
restore=$(expr $restore + 1)
}

function tree_1(){
echo -e "
$code / $reset$basic
|-- $code /home/ $reset$basic
|   |-- $code /home/user/ $reset$basic
|   |   |-- $code /home/user/Pictures/ $reset$basic
|-- $code /bin/ $reset$basic
|-- $code /var/ $reset$basic"
restore=$(expr $restore + 1)
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
restore=$(expr $restore + 1)
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
restore=$(expr $restore + 1)
}
function quiz(){
  echo -en "\e[0;33m...\e[0m"
  talk_not_press_key justumen "Bash 'Bourne Again SHell' : Chapitre 1"
  talk_not_press_key justumen "- La réponse doit être la plus courte possible, une commande valide mais ajoutant des caractères inutiles ne fonctionnera pas."
  talk_not_press_key justumen "Exemple : si la réponse est 'ls'. Les réponses 'ls .', 'ls ./' et 'ls ././' seront considérées comme fausses."
  answer_text_fr "Quel symbole représente le répertoire racine sur Linux ?" "/"
  answer_text_fr "Quelle commande affiche le chemin absolu du répertoire courant ?" "pwd"
  answer_text_fr "Quelle commande affiche le contenu du répertoire racine ?" "ls /"
  answer_text_fr "Quelle commande change le répertoire courant du terminal par son répertoire parent ?" "cd .."
  answer_text_fr "Quelle commande affiche le contenu du répertoire courant ?" "ls"
  answer_text_fr "Quelle commande supprime le dossier vide 'test' du répertoire courant ?" "rmdir test"
  answer_text_fr "Par quel symbole commence le chemin absolu d'un fichier ?" "/"
  answer_text_fr "Le nom du chemin relatif d'un fichier est souvent plus court que son équivalent en chemin absolu. (vrai/faux)" "vrai"
  answer_text_fr "Quelle commande peut supprimer le fichier /home/test quel que soit votre répertoire courant ?" "rm /home/test"
  unlock
}

function unlock(){
  #~ talk_not_press_key justumen "Pour débloquer \"bash 1\" dans le chat, allez sur https://rocket.bjornulf.org/direct/boti et tapez : password 24d8b826ff016" #Super secure password ! Please don't cheat for your own good. :-)
  talk_not_press_key justumen "Pour débloquer \"bash 1\" dans le chat, veuillez saisir votre pseudo :"
  echo -n " > "
  read -r PSEUDO
  PASS=`encode $PSEUDO "24d8" "f016"`
  talk_not_press_key justumen "Allez sur https://rocket.bjornulf.org/direct/boti et tapez : password$PASS"
}

function enter(){
case $1 in
	1) echo -en "\e[0;33m...\e[0m" ;&
	2) talk_not_press_key justumen "Bash Bourne Again SHell : Chapitre 1" ;&
	3) answer_quiz "Cours" "Questionnaire" "Quitter" "4" "5" "6" ;;
	4) code ;;
	5) quiz 1 ;;
	6) exit ;;
esac
}

restore=2 #first line of LIST_4GEN should be environment test (test ~/House)
justumen_intro_fr

enter 1
