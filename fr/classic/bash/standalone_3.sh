#!/bin/bash
#SOME ADDED AND CHANGE IN CLI learn_cli.sh in CLASSIC


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
[ -d "$HOME/.GameScript_bash3" ] && echo "Erreur innatendu, ${HOME}/.GameScript_bash3 existe déjà sur votre système ! Supprimez ce dossier $HOME/.GameScript_bash3 et relancer ce script." && exit
mkdir $HOME/.GameScript_bash3
cd $HOME/.GameScript_bash3
talk justumen "Dans le chapitre 2, nous avons vu que les options peuvent avoir deux formes, l'une courte comme dans ${learn}ls -l${reset}, et l'autre longue comme dans ${learn}ls --all${reset}."
talk justumen "Si vous avez plusieures options à passer à la même commande, vous pouvez les mettre les unes après les autres : ${learn}ls -a -w 1${reset}."
talk_not_press_key justumen "Essayez donc avec l'exemple que l'on a déjà vu : ${learn}ls -a -w 1${reset}"
answer_run "ls -a -w 1" justumen "Non"
talk justumen "Vous pouvez bien évidemment aussi utiliser les versions longues de la même manière."
talk_not_press_key justumen "Essayez donc la même chose avec : ${learn}ls --all --width=1${reset}"
answer_run "ls --all --width=1" justumen "Non"
talk justumen "Mais n'oubliez pas les options courtes commencent par ${code}-${reset} et les options longues commencent par ${code}--${reset}."
talk justumen "Si vous utilisez les versions courtes, vous pouvez également les regrouper avec le même ${code}-${reset}."
talk justumen "Par exemple pour passez l'option ${code}-a${reset} et l'option ${code}-w 10${reset} à ${code}ls${reset}, vous pouvez tapez ${code}ls -aw 10${reset}"
talk_not_press_key justumen "Essayez donc cette commande : ${learn}ls -aw 10${reset}"
answer_run "ls -aw 10" justumen "Non"
talk justumen "Attention donc à ne pas oublier qu'il y a deux ${code}-${reset} avant les options longues."
talk justumen "Les commandes ${learn}ls --all${reset} et ${learn}ls -all${reset} ne sont pas du tout identiques."
talk justumen "${learn}ls -a${reset} est identique à ${learn}ls --all${reset}."
talk justumen "Mais ${learn}ls -all${reset} est identique à ${learn}ls -a -l -l${reset}"
talk_not_press_key justumen "Ouvrez maintenant le manuel de ${code}ls${reset} et cherchez l'option pour afficher son numéro de version."
answer_run "man ls" justumen "Non"
talk_not_press_key justumen "Affichez le numéro de version de ${code}ls${reset}."
answer_run "ls --version" justumen "Non"
talk justumen "Parfait !"
talk justumen "Le script que vous utilisez en ce moment affiche du texte dans votre terminal."
talk justumen "Ce script étant lui-même en bash, quelle commande est utilisée ici pour affichez ces phrases ?"
talk justumen "Pour afficher quelque chose dans un terminal, il vous faudra utiliser la commande ${code}echo${reset}."
talk justumen "Il vous renverra simplement un écho de ce que vous lui donnez en argument."
talk_not_press_key justumen "Affichez donc le mot bonjour dans votre terminal avec la commande : ${learn}echo bonjour${reset}"
answer_run "echo bonjour" justumen "Non"
talk_not_press_key justumen "La commande ${code}echo${reset} accepte plusieurs arguments, vous pouvez tester : ${learn}echo bonjour tout le monde${reset}"
answer_run "echo bonjour tout le monde" justumen "Non"
talk justumen "Simple comme bonjour !"
talk justumen "On a déjà vu ensemble que ${code}mkdir${reset} est utilisé pour créer de nouveaux dossiers."
talk justumen "Mais comment créer de nouveaux fichiers ?"
talk justumen "Figurez-vous que vous pouvez utiliser la commande ${code}echo${reset} !"
talk justumen "Lorsque vous utilisez la commande ${code}echo${reset}, le résultat s'affichera dans votre terminal."
talk justumen "Mais il est aussi possible de ${voc}rediriger${reset} ce résultat ailleurs, par exemple dans un fichier texte."
talk justumen "Il vous faudra utiliser le symbole ${code}>${reset}. Il représente une ${voc}redirection${reset} du résultat."
talk_not_press_key justumen "Créez donc le fichier texte 'test' avec la commande : ${code}echo bonjour>test${reset}"
answer_run "echo bonjour>test" justumen "Non"
talk justumen "Lorsque vous utilisez ${code}>${reset}, si le fichier n'existe pas il sera créé."
talk_not_press_key justumen "Affichez donc les éléments de votre répertoire de travail."
answer_run "ls" justumen "Non"
talk justumen "Ici vous avez non seulement créé le fichier texte 'test' mais vous lui avez également donné un contenu."
talk justumen "Ce contenu est le résultat de la commande à gauche du symbole ${code}>${reset}."
talk justumen "Pour afficher le contenu de ce fichier, il vous faudra utiliser la commande ${code}cat${reset}."
talk justumen "Encore une fois il suffira de donner en argument à ${code}cat${reset} le nom du fichier en question, comme vous le feriez pour la commande ${code}rm${reset}."
talk_not_press_key justumen "Affichez donc le contenu du fichier 'test' avec : ${learn}cat test${reset}"
answer_run "cat test" justumen "Non"
talk justumen "La commande ${code}cat${reset} porte ce nom car elle peut être utilisé pour la con${code}cat${reset}énation. (Mettre bout à bout des chaines de caractère.)"
talk justumen "Pour concaténer, il suffit de mettre les fichiers en argument les uns après les autres."
talk justumen "Il est aussi possible d'utiliser plusieures fois le même fichier."
talk_not_press_key justumen "Testez donc la commande : ${learn}cat test test${reset}"
answer_run "cat test test" justumen "Non"
talk justumen "${learn}cat test test${reset} affiche ici deux fois le contenu du fichier 'test'."
talk justumen "Encore une fois : lorsque vous utilisez ${code}>${reset}, si le fichier n'existe pas il sera créé."
talk justumen "Si le fichier existe déjà le contenu sera remplacé."
talk_not_press_key justumen "Testons donc la commande : ${learn}echo au revoir>test${reset}"
answer_run "echo au revoir>test" justumen "Non"
talk_not_press_key justumen "Affichez maintenant le fichier 'test'."
answer_run "cat test" justumen "Non"
talk justumen "Ici le contenu a été remplacé ! Les mots 'bonjour' n'existent plus."
talk justumen "Attention donc à ${code}>${reset}, car il peut supprimer le contenu de vos fichiers."
talk justumen "Si vous voulez ${voc}concaténer${reset} du nouveau contenu dans ce fichier il vous faudra utiliser ${code}>>${reset}."
talk justumen "Encore une fois si vous utilisez ${code}>>${reset}, si le fichier n'existe pas il sera créé."
talk justumen "Mais si le fichier existe déjà, le nouveau contenu s'ajoutera à la fin du fichier."
talk_not_press_key justumen "Testez donc avec : ${learn}echo bonjour>>test${reset}"
answer_run "echo bonjour>>test" justumen "Non"
talk_not_press_key justumen "Puis affichez le fichier 'test'."
answer_run "cat test" justumen "Non"
talk justumen "Ici le mot 'bonjour' a été rajouté à la fin du fichier texte."
talk justumen "Vous pouvez continuer à utiliser ${code}>>${reset} pour ajouter le contenu les uns à la suite des autres."
talk justumen "Mais ces redirections (${code}>>${reset} et ${code}>${reset}) ne se limitent pas à ${code}echo${reset}."
talk justumen "Toutes les commandes peuvent les utiliser."
talk_not_press_key justumen "Mettez par exemple le résultat de la commande ${learn}ls${reset} à la suite de ce  !"
answer_run "ls>>test" justumen "Non"
talk_not_press_key justumen "Et affichez le fichier 'test'."
answer_run "cat test" justumen "Non"
talk justumen "C'est le ${voc}résultat${reset} de la commande qui sera redirigé. Ici ${learn}ls>>test${reset} donne comme résultat : 'test'."
talk justumen "Si vous voulez y ajouter du texte, il faudra utiliser ${code}>>${reset} en combinaison avec la commande ${code}echo${reset}."
talk justumen "Si vous voulez ajouter le mot 'pwd' à la fin du fichier il faudra utiliser : ${learn}echo pwd>>test${reset}"
talk_not_press_key justumen "Ajoutons les trois lettres : 'pwd' à la fin du fichier 'test'."
answer_run "echo pwd>>test" justumen "Non"
talk justumen "Donc attention à ne pas confondre ${learn}pwd>>test${reset} avec ${learn}echo pwd>>test${reset}."
talk_not_press_key justumen "Maintenant ajoutons le ${voc}résultat${reset} de ${code}pwd${reset} à la fin du fichier 'test'."
answer_run "pwd>>test" justumen "Non"
talk_not_press_key justumen "Et affichez le fichier 'test'."
answer_run "cat test" justumen "Non"
talk justumen "Très Bien ! J'espère que le résultat ne vous surprend pas."
talk justumen "Maintenant revenons à la commande ${code}echo${reset}."
talk justumen "Certains caractères spéciaux ne sont pas simple à afficher."
talk_not_press_key justumen "Essayez d'afficher la lettre 'a' et la lettre 'b', séparé par deux espaces avec : ${learn}echo a  b${reset}"
answer_run "echo a  b" justumen "Non"
talk justumen "Le résultat n'est pas celui qui était prévu... Il n'y a qu'un seul espace entre a et b."
talk justumen "Ici, ${code}echo${reset} considère qu'il y a deux arguments, le premier argument 'a' et le deuxième argument 'b'."
talk justumen "Il affiche donc les deux arguments séparé par un espace."
talk justumen "Il est donc parfois utile de limiter le nombre d'argument à un !"
talk justumen "Mais comment afficher cet espace pour que la suite ne soit pas considéré comme un nouvel argument ?"
talk justumen "Il faudra utiliser ce que l'on appele en informatique un ${voc}caractère d'échappement${reset}."
talk justumen "Sur bash, il s'agit du caractère ${code} \ ${reset}."
talk justumen "Le caractère d'échappement affectera uniquement le prochain caractère."
talk justumen "Dans notre cas pour représenter un espace nous pouvons utiliser ${code}\\ ${reset}."
talk_not_press_key justumen "Essayez donc avec ce caractère d'échappement : ${learn}echo a \\ b${reset}"
answer_run "echo a \ b" justumen "Non"
talk justumen "Cependant dans cet exemple il y a toujours deux arguments, le premier est 'a' et le deuxième est '\\ b'."
talk justumen "Pour avoir un seul et unique argument il faut supprimer cet espace après le 'a'."
talk_not_press_key justumen "Essayez donc avec un seul argument : ${learn}echo a\\ b${reset}"
answer_run "echo a\ b" justumen "Non"
talk_not_press_key justumen "Maintenant, essayez d'afficher un deuxième espace entre a et b."
answer_run "echo a\ \ b" justumen "Non"
talk justumen "Ce caractère d'échappement est très utile pour afficher des caractères que vous ne pouvez pas afficher autrement."
talk justumen "Comme par exemple le symbole ${learn}>${reset}, qui comme vous le savez est aussi interprété par bash comme un caractère spécial."
talk_not_press_key justumen "Testez donc cette commande : ${learn}echo x\\>y${reset}"
answer_run "echo x\>y" justumen "Non"
talk justumen "Ici, vous comprenez bien ${voc}l'énorme${reset} différence qu'il y a entre ${learn}echo x\>y${reset} et ${learn}echo x>y${reset}."
talk justumen "${learn}echo x>y${reset} va créer un nouveau fichier 'y' avec comme contenu 'x' !"
talk justumen "${learn}echo x\\>y${reset} affiche simplement du texte dans le terminal."
talk justumen "Pour affichez le symbole ${code} \ ${reset} avec echo, il suffit de rajouter avant votre caractère d'échappement."
talk_not_press_key justumen "Essayez par exemple d'afficher : ${code}\\quitter${reset}."
answer_run "echo \\\\quitter" justumen "Non"
talk justumen "Dans ${code} \\\\\\quitter ${reset}, le premier ${code} \ ${reset} est le caractère d'échappement, mais le deuxième est simplement le caractère qui doit être interprété littéralement par le terminal."
talk justumen "Pour ne pas avoir à utiliser ce ${code} \ ${reset} à chaque espace, vous pouvez également utiliser les ${code}\"${reset}."
talk justumen "Deux ${code}\"${reset} peuvent agir en temps que ${code}délimiteur${reset} d'arguments."
talk justumen "C'est à dire que ${learn}echo x\>y${reset} peut être remplacé par ${learn}echo \"x>y\"${reset}."
talk justumen "Le contenu entre le premier ${code}\"${reset} et le deuxième ${code}\"${reset} sera considéré comme un seul argument pour la commande ${code}echo${reset}."
talk justumen "Faisant partie de l'argument, les espaces seront donc traités et affichés en temps que tel."
talk_not_press_key justumen "Essayez donc de faire : ${learn}echo \"X   X\"${reset}"
answer_run "echo \"X   X\"" justumen "Non"
talk justumen "Ici les espaces s'affichent correctement."
talk_not_press_key justumen "Vous pouvez aussi remplacer les ${code}\"${reset} par des ${code}'${reset} : ${learn}echo 'X   X'${reset}"
answer_run "echo 'X   X'" justumen "Non"
talk justumen "Si vous avez de nombreux ${code}'${reset} à afficher, utilisez ${code}\"${reset} comme délimiteur, et vice versa."
talk justumen "Par exemple, ${learn}echo '\"Pierre\" et \"Marie\"'${reset} est une commande plus lisible que ${learn}echo \"\\\"Pierre\\\" et \\\"Marie\\\"\"${reset}."
talk justumen "Le ${voc}caractère d'échappement${reset} ${code} \ ${reset} peut aussi être utilisé pour afficher d'autres caractères spéciaux, comme des mises à la ligne ou des tabulations."
talk_not_press_key justumen "Regardez rapidement cette liste dans le manuel de la commmande ${code}echo${reset}."
answer_run "man echo" justumen "Non"
talk justumen "Si vous avez bien lu le manuel vous avez compris que cela ne fonctionnera que si l'option ${code}-e${reset} est présente."
talk justumen "Sur bash, la lettre 'n' est utilisée avec ${code} \ ${reset} pour représenter une mise à la ligne, 'n' comme ${code}n${reset}ouvelle ligne."
talk_not_press_key justumen "Affichez donc la lettre 'a', puis la lettre 'b' sur une nouvelle ligne en utilisant ${code}'${reset} comme délimiteur."
answer_run "echo -e 'a\nb'" justumen "Non"
talk_not_press_key justumen "Trouvez la syntaxe d'une ${voc}tabulation${reset} horizontale dans le manuel de la commande echo."
answer_run "man echo" justumen "Non"
talk_not_press_key justumen "En utilisant ${code}'${reset}, affichez la lettre 'a', suivi d'une tabulation, puis de la lettre 'b'."
answer_run "echo -e 'a\tb'" justumen "Non"
talk_not_press_key justumen "Maintenant au lieu d'afficher le résultat dans le terminal, mettez le dans un fichier avec le nom 'tab'."
answer_run "echo -e 'a\tb'>tab" justumen "Non"
talk_not_press_key justumen "Affichez le contenu du fichier 'tab'."
answer_run "cat tab" justumen "Non"
talk_not_press_key justumen "Affichez maintenant le fichier 'test' puis le fichier 'tab' à la suite."
answer_run "cat test tab" justumen "Non"
talk_not_press_key justumen "Supprimez maintenant 'tab' et 'test' en une seule commande."
answer_run "rm tab test" justumen "Non"
talk justumen "Excellent ! Vous êtes prêt pour le questionnaire."
rmdir $HOME/.GameScript_bash3
}
function quiz(){
  echo -en "\e[0;33m...\e[0m"
  talk_not_press_key justumen "Bash 'Bourne Again SHell' : Chapitre 3"
  talk_not_press_key justumen "- La réponse doit être la plus courte possible, une commande valide mais ajoutant des caractères inutiles ne fonctionnera pas."
  talk_not_press_key justumen "Exemple : si la réponse est 'ls'. Les réponses 'ls .', 'ls ./' et 'ls ././' seront considérées comme fausses."
  answer_text_fr "Quel est la version abrégée de 'ls -a -l' ?" "ls -al"
  answer_text_fr "Comment ajouter le mot 'non' à la fin du fichier texte 'oui' ?" "echo non>>oui"
  answer_text_fr "Comment remplacer le contenu du fichier 'test' par 'exemple' ?" "echo exemple>test"
  answer_text_fr "Comment afficher le contenu du fichier 'test' ?" "cat test"
  answer_text_fr "Sur bash, quel est le caractère d'échappement ?" "\\"
  answer_text_fr "Comment afficher dans le terminal : a>b" "echo a\>b"
  answer_text_fr "Quel est la lettre à utiliser après le caractère d'échappement pour représenter une mise à la ligne ?" "n"
  answer_text_fr "Affichez, sans utiliser le caractère d'échappement, la phrase : j'ai bon" "echo \"j'ai bon\""
  answer_text_fr "Affichez trois guillemets (\"), sans utiliser le caractère d'échappement." "echo '\"\"\"'"
  unlock
}

function unlock(){
  talk_not_press_key justumen "Pour débloquer \"bash 3\" dans le chat, allez sur https://rocket.bjornulf.org/direct/boti et tapez : password 2452a8c193a3" #Super secure password ! Please don't cheat for your own good. :-)
}

function enter(){
case $1 in
	1) echo -en "\e[0;33m...\e[0m" ;&
	2) talk_not_press_key justumen "Bash Bourne Again SHell : Chapitre 3" ;&
	3) answer_quiz "Cours" "Questionnaire" "Quitter" "4" "5" "6" ;;
	4) code ;;
	5) quiz 1 ;;
	6) exit ;;
esac
}

restore=2 #first line of LIST_4GEN should be environment test (test ~/House)
# justumen_intro_fr

enter 1
