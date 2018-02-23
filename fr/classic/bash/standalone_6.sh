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
[ -d "$HOME/.GameScript_bash6" ] && echo "Erreur innatendu, ${HOME}/.GameScript_bash6 existe déjà sur votre système ! Supprimez ce dossier $HOME/.GameScript_bash6 et relancer ce script." && exit
mkdir $HOME/.GameScript_bash6
cd $HOME/.GameScript_bash6
echo "xxxxxx">intrus;echo "contenu f">f;chmod 222 f;echo "contenu f1">f1;chmod 000 f1;echo "contenu f10">f10;chmod 010 f10;echo "contenu f2">f2;chmod 444 f2;echo "contenu f3">f3;chmod 400 f3;echo "contenu f4">f4;chmod 455 f4;echo "contenu f50">f50;chmod 111 f50;
talk_not_press_key justumen "Commençons par évaluer notre situation avec un : ${learn}ls -l${reset}"
answer_run "ls -l" justumen "Non"
talk justumen "Nous avons ici certains problèmes de permission à régler..."
talk justumen "Nous voulons rajouter le droit de lecture et d'écriture pour le propriétaire sur tous les éléments du répertoire courant."
talk justumen "Il est possible de mettre tous les noms les uns à la suite des autres avec ${code}chmod${reset}."
talk_not_press_key justumen "Faites le donc pour 'f1' et 'f2', puis réaffichez les nouvelles permissions si la commande est un succès."
answer_run "chmod u+rw f1 f2&&ls -l" justumen "Non"
talk justumen "Taper tous les noms de fichiers est finalement particulièrement rébarbatif, surtout si vous avez un grand nombre de fichiers à changer."
talk justumen "Dans ce chapitre nous allons ajouter de nouveaux caractères spéciaux à notre arsenal !"
talk justumen "Le premier que nous allons voir est : ${code}*${reset}"
talk justumen "${code}*${reset} est un symbole très puissant en bash, on l'appelle un ${voc}joker${reset}."
talk justumen "Il peut être utilisé pour remplacer tous les éléments d'un répertoire."
talk justumen "C'est à dire qu'au lieu d'avoir à taper tous les noms les uns à la suite des autres, vous avez juste à mettre ${code}*${reset} à la place."
talk_not_press_key justumen "Ajoutez donc le droit de lecture et d'écriture pour le propriétaire sur tous les éléments du répertoire courant, puis réaffichez les nouvelles permissions si la commande est un succès."
answer_run "chmod u+rw *&&ls -l" justumen "Non"
talk justumen "Si ${code}*${reset} est utilisé seul, le répertoire en question est bien évidemment le répertoire courant : ${code}*${reset} = ${code}./*${reset}"
talk justumen "Mais ${code}*${reset} peut être utilisé avec n'importe quel chemin, par exemple : ${code}/*${reset} représente tous les éléments du répertoire racine."
talk justumen "Ici nous avons finalement résolu tous nos problèmes de permissions en une seule commande !"
talk justumen "Mais ${code}*${reset} peut aussi être utilisé avec les autres commandes."
talk_not_press_key justumen "Affichez tous les éléments du répertoire courant les uns à la suite des autres."
answer_run "cat *" justumen "Non"
talk justumen "L'ordre d'affichage est ${voc}alphabétique${reset}, exactement comme le résultat de ${code}ls${reset}."
talk justumen "Notez que 'f10' est placé avant 'f2', car l'affichage par défaut est ${voc}alphabétique${reset} et non pas ${voc}numérique${reset}."
talk justumen "Si l'affichage numérique vous intéresse, vous auriez pu trouver facilement l'option ${code}-v${reset} dans le manuel de ${code}ls${reset}."
talk justumen "${code}*${reset} peut donc représenter tous les éléments d'un répertoire."
talk justumen "Mais que fait-il exactement pour avoir cet effet ?"
talk justumen "${code}*${reset} peut en fait remplacer une chaine de caractère quelconque."
talk justumen "S'il est utilisé seul, il représente donc tous les fichiers qui ont un nom quelconque..."
talk justumen "Mais il est aussi possible de limiter ce qu'il représente en y ajoutant des caractères."
talk_not_press_key justumen "Par exemple, vous pouvez afficher tous les éléments du répertoire courant qui commence par un 'f' avec : ${learn}ls f*${reset}"
answer_run "ls f*" justumen "Non"
talk justumen "Ici le fichier 'intrus' n'est pas présent car son nom ne commence pas par un 'f'."
talk_not_press_key justumen "Affichez tous les éléments du répertoire courant qui se terminent par un 0 avec : ${learn}ls *0${reset}"
answer_run "ls *0" justumen "Non"
talk justumen "La commande ${code}ls${reset} accepte aussi plusieurs arguments, vous pouvez donc cumuler les syntaxes."
talk_not_press_key justumen "Essayez par exemple de lister les permissions de tous les éléments du répertoire courant qui finissent soit par un 0, soit par un s."
answer_run "ls -l *0 *s" justumen "Non"
talk_not_press_key justumen "Lister maintenant tous les permissions des éléments du répertoire courant qui commencent par un 'i' et finissent par un 's'."
answer_run "ls -l i*s" justumen "Non"
talk justumen "Avec ${code}i*s${reset}, seul le fichier 'intrus' rentre dans les critères de sélection."
talk justumen "Dans le cas de ce fichier 'intrus', ${code}*${reset} remplacera la chaine de caractère 'ntru'."
talk justumen "Si vous avez besoin d'un ciblage plus en finesse, vous pouvez utiliser un autre ${voc}joker${reset} : le ${code}?${reset}."
talk justumen "${code}?${reset} ne remplace lui qu'${voc}un${reset} seul caractère !"
talk_not_press_key justumen "Essayer donc cette commande : ${learn}ls -l f?${reset}"
answer_run "ls -l f?" justumen "Non"
talk justumen "Ici 'f10' et 'f50' ne s'affichent pas, car il y a deux caractères après la lettre f."
talk_not_press_key justumen "Affichez donc ces deux fichiers, en faisant : ${learn}ls -l f??${reset}"
answer_run "ls -l f??" justumen "Non"
talk_not_press_key justumen "Mais qu'en est-il du fichier 'f' ? Affichez donc ses permissions."
answer_run "ls -l f" justumen "Non"
talk justumen "Le fichier 'f' existe bel et bien, mais ne s'est pas affiché lors de nos dernières commandes avec ${code}?${reset}..."
talk justumen "${code}?${reset} remplace exactement ${code}un${reset} caractère, ni plus, ni moins."
talk_not_press_key justumen "Essayez donc avec : ls ${learn}f*${reset}"
answer_run "ls f*" justumen "Non"
talk justumen "Ici même s'il n'y a aucun caractère après le f, le fichier 'f' s'affiche,"
talk justumen "C'est tout simplement parce que ${code}*${reset} peut aussi représenter une chaine de caractère vide !"
talk_not_press_key justumen "Pour afficher les permissions de tous les fichiers avec un nom d'une lettre, vous pouvez utiliser : ${learn}ls -l ?${reset}"
answer_run "ls -l ?" justumen "Non"
talk justumen "Ici 'f' est notre seul fichier avec un nom d'une lettre."
talk justumen "Attention donc lorsque vous utilisez ces ${voc}jokers${reset}, surtout avec des commandes ${voc}destructrices${reset} !"
talk justumen "Une commande comme ${learn}rm *${reset} peut avoir de graves conséquences."
talk_not_press_key justumen "Maintenant que ces deux symboles sont acquis, affichez le contenu du fichier 'f'."
answer_run "cat f" justumen "Non"
talk justumen "Lorque vous utilisez la commande ${code}cat${reset} vous affichez en fait les ${voc}données${reset} du fichier 'f'. (data en anglais)"
talk_not_press_key justumen "Affichez maintenant les résultats de ${learn}ls -l f${reset}."
answer_run "ls -l f" justumen "Non"
talk justumen "Les informations qui s'affichent ici sont les ${voc}métadonnées${reset} du fichier 'f'. (metadata en anglais)"
talk justumen "Les ${voc}métadonnées${reset} sont des informations sur des données !"
talk justumen "${learn}ls -l${reset} vous affiche donc des ${voc}métadonnées${reset}."
talk justumen "Prenons un exemple : -rw------- 1 umen team 10 Feb 20 16:16 f"
talk justumen "Dans cet affichage, il y a en fait 7 colonnes."
talk justumen "${codeFile}-rw-------${reset} 1 umen team 10 Feb 20 16:16 f : Vous connaissez déjà la première colonne, il s'agit du type et des permissions."
talk justumen "-rw------- ${codeFile}1${reset} umen team 10 Feb 20 16:16 f : La deuxième colonne est un nombre qui compte le nombre de liens ou de répertoires dans un élément."
talk justumen "Mais nous reviendrons sur ce nombre dans un autre chapitre, ignorez le pour le moment."
talk justumen "-rw------- 1 ${codeFile}umen${reset} team 10 Feb 20 16:16 f : La troisième colonne est je le rappelle le nom du propriétaire."
talk justumen "-rw------- 1 umen ${codeFile}team${reset} 10 Feb 20 16:16 f : La quatrième colonne est je le rappelle le nom du groupe."
talk justumen "-rw------- 1 umen team ${codeFile}10${reset} Feb 20 16:16 f : La cinquième colonne est la ${voc}taille${reset} en ${voc}octet${reset} du fichier. (byte en anglais)"
talk justumen "Pour rappel : un octet est égal à 8 bits. Et un bit ne peut avoir que deux valeurs, 0 ou 1."
talk justumen "Ce fichier de 10 octets fait donc 80 bits !"
talk justumen "Pour information, le contenu de notre fichier 'f' est égal en binaire à 01100011 01101111 01101110 01110100 01100101 01101110 01110101 00100000 01100110 00001010"
talk justumen "-rw------- 1 umen team 10 ${codeFile}Feb 20 16:16${reset} f : La sixième colonne est la date de la dernière modification du fichier."
talk justumen "-rw------- 1 umen team 10 Feb 20 16:16 ${codeFile}f${reset} : La dernière colonne est simplement le nom du fichier."
talk justumen "Dans le chapitre précédent, vous aviez déjà utilisé la commande ${code}touch${reset} pour créer un fichier."
talk justumen "Effectivement, avec ${code}touch${reset}, si le fichier donné en argument n'existe pas il sera créé."
talk justumen "Mais le but premier de cette commande est de changer cette métadonnée de dernière modification. -rw------- 1 umen team 10 ${codeFile}Feb 20 16:16${reset} f"
talk_not_press_key justumen "Pour actualisez la date de dernière modification de 'f' faites : ${learn}touch f${reset}"
answer_run "touch f" justumen "Non"
talk_not_press_key justumen "Faites donc maintenant : ${learn}ls -l${reset}"
answer_run "ls -l" justumen "Non"
talk justumen "La date de dernière modification de 'f' est effectivement la plus récente."
talk_not_press_key justumen "Pour afficher la date du moment il suffit de lancer la commande : ${learn}date${reset}"
answer_run "date" justumen "Non"
talk justumen "La commande ${code}touch${reset} a donc bien eu son effet."
talk_not_press_key justumen "Affichez maintenant le contenu du fichier 'intrus'."
answer_run "cat intrus" justumen "Non"
talk_not_press_key justumen "Lancez enfin : ${learn}ls -l intrus${reset}"
answer_run "ls -l intrus" justumen "Non"
talk justumen "La date ici n'a pas changé, malgré l'utilisation de la commande ${code}cat${reset} sur ce fichier."
talk justumen "Sans autre options, ${learn}ls -l${reset} affiche la dernière date de ${voc}modification${reset}, pas la dernière date ${voc}d'accès${reset}."
talk justumen "Et évidemment, ${code}cat${reset} ne fait qu'afficher le fichier sans le modifier, donc la date ne change pas."
talk justumen "Et maintenant nous allons revenir rapidement sur les permissions, en particulier sur la commande ${code}chmod${reset}."
talk justumen "Nous avons déjà vu comment utiliser ${code}chmod${reset} avec des lettres : r, w, x, u, g, o."
talk justumen "Mais il est aussi possible d'utiliser ${code}chmod${reset} avec 3 chiffres !"
talk justumen "A chaque lettre correspond une valeur numérique, la lettre 'r' sera 4, 'w' sera 2 et 'x' sera 1."
talk justumen "Il faudra ensuite faire l'addition des permissions, 'rw-' sera donc 4+2=${voc}6${reset}, 'r-x' sera 4+1=${voc}5${reset}, 'r--' sera ${voc}4${reset}, 'rwx' sera 4+2+1=${voc}7${reset}, '---' sera ${voc}0${reset}, etc..."
talk justumen "Vous devez utiliser trois de ces sommes pour respectivement : le propriétaire, le groupe et les autres."
talk justumen "Par exemple pour donner tous les droits au propriétaire mais aucun au reste sur le fichier 'test' : ${learn}chmod 700 test${reset}"
talk justumen "${codeFile}7${reset}00 donne toutes les permissionss au propriétaire : ${codeFile}rwx${reset}"
talk justumen "7${codeFile}0${reset}0 ne donne aucune permission au groupe : ${codeFile}---${reset}"
talk justumen "70${codeFile}0${reset} ne donne aucune permission aux autres : ${codeFile}---${reset}"
talk justumen "${codeFile}700${reset} est donc équivalent à ${codeFile}rwx------${reset}."
talk_not_press_key justumen "Donnez donc les droits rw-r--r-- à tous les éléments de deux lettres du répertoire courant, en utilisant chmod et ses chiffres."
answer_run "chmod 644 ??" justumen "Non"
talk_not_press_key justumen "Voyons le résultat avec : ${learn}ls -l${reset}"
answer_run "ls -l" justumen "Non"
talk justumen "Vous avez peut être remarqué que la commande ${learn}chmod 644 ??${reset} n'a pas d'équivalent avec des lettres."
talk justumen "Ou plutôt qu'il faut plusieures commandes pour avoir le même effet."
talk justumen "Il faudra par exemple ${learn}chmod ugo+r ??${reset} pour faire l'équivalent de ${learn}chmod 444 ??${reset}."
talk justumen "Et il faudra ensuite transformer ${code}444${reset} en ${code}644${reset} avec ${learn}chmod u+w ??${reset}."
talk justumen "Cependant l'inverse n'est pas du tout possible, ${code}u+w${reset} n'a pas d'équivalent en chiffre, parce que le résultat dépendra des permissions précédentes."
talk justumen "Les deux méthodes ne sont pas pas équivalentes !"
talk justumen "Ca sera donc à vous de choisir quelle méthode vous souhaitez utiliser, en fonction de votre situation."
talk justumen "Et pour en terminer avec les bases sur les permissions, nous allons voir comment changer de propriétaire et de groupe."
talk justumen "La commande a utiliser sera : ${code}chown${reset}, abréviation anglaise de : ${code}ch${reset}ange ${code}own${reset}er."
talk_not_press_key justumen "Pour mettre ${voc}root${reset} comme propriétaire du fichier 'f' vous pouvez simplement taper : ${learn}chown root f${reset}"
answer_run "chown root f" justumen "Non"
talk justumen "Ici cette commande ne fonctionne pas !"
talk justumen "C'est encore une fois un problème de permission, mais qui n'est pas du même type."
talk justumen "Par mesure de sécurité, certaines commandes peuvent uniquement être utilisées par l'utilisateur administrateur : ${voc}root${reset}."
talk justumen "${code}chown${reset} est l'une d'entre elles, c'est une commande que seul ${voc}root${reset} peut utiliser !"
talk justumen "Mais je ne vous demanderai pas votre mot de passe ${voc}root${reset} dans ce script."
talk justumen "Je vous invite donc à tester cette commande ${code}chown${reset} en root par vous même dans un autre terminal plus tard !"
talk justumen "Pour vous connectez en ${code}rot${reset} vous pouvez faire : ${learn}su root${reset}, votre mot de passe vous sera alors demandé et vous aurez votre terminal en ${code}root${reset}."
talk justumen "Pour tester si vous êtes bien ${voc}root${reset} vous pouvez utiliser la commande : ${learn}whoami${reset}."
talk justumen "Si vous voulez changer le ${voc}groupe${reset} il faudra utiliser le symbole ${code}:${reset}, comme par exemple ${learn}chown :familleEinstein f${reset}."
talk justumen "Et bien évidemment vous pouvez changer les deux en même temps, comme par exemple ${learn}chown albert:familleEinstein f${reset}."
talk justumen "Attention cependant à toutes les commandes que vous lancez en ${voc}root${reset} !"
talk justumen "${voc}root${reset} possède TOUTES les permissions pour TOUT les éléments !"
talk justumen "${voc}root${reset} est capable de supprimer tous vos fichiers, mais il a aussi le pouvoir de rendre votre système inutilisable !"
talk justumen "Une commande maladroite en ${voc}root${reset}, ou un script malicieux en ${voc}root${reset} peuvent avoir des effets dévastateurs."
talk justumen "Vous maitrisez maintenant tout ce qu'il vous faut pour analyser et maitriser vos permissions."
talk justumen "Bonne chance pour le questionnaire !"
chmod 644 $HOME/.GameScript_bash6/f*
rm $HOME/.GameScript_bash6/f
rm $HOME/.GameScript_bash6/f1
rm $HOME/.GameScript_bash6/f2
rm $HOME/.GameScript_bash6/f3
rm $HOME/.GameScript_bash6/f4
rm $HOME/.GameScript_bash6/f10
rm $HOME/.GameScript_bash6/f50
rm $HOME/.GameScript_bash6/intrus
rmdir $HOME/.GameScript_bash6/
}
function quiz(){
  echo ""
  echo -e "\e[15;5;44m Bash 'Bourne Again SHell' : Questionnaire du chapitre 6 \e[0m"
  echo -e "- La réponse doit être la plus courte possible, une commande valide mais ajoutant des caractères inutiles ne fonctionnera pas."
  echo -e "Exemple : si la réponse est 'ls'. Les réponses 'ls .', 'ls ./' et 'ls ././' seront considérées comme fausses."
  answer_text_fr "Dans terminal root, comment définir 'albert' comme propriétaire et 'familleEinstein' comme groupe au fichier 'test' du répertoire courant ?" "chown albert:familleEinstein test"
  answer_text_fr "Quelle commande affiche les éléments du répertoire courant par ordre alphabétique ?" "ls"
  answer_text_fr "Quelle commande affiche les métadonnées des éléments du répertoire courant ?" "ls -l"
  answer_text_fr "Comment afficher tous les éléments du répertoire courant dont le nom commence par 'x' ?" "ls x*"
  answer_text_fr "Comment supprimer tous les éléments du répertoire courant ayant un nom de 2 lettres ?" "rm ??"
  answer_text_fr "Comment déplacer tous les éléments du répertoire courant qui finissent par '.html' dans le répertoire parent de votre répertoire parent ?" "mv *.html ../.."
  answer_text_fr "Comment donner au fichier 'test' les permissions : --x-----x ?" "chmod 101 test"
  answer_text_fr "Comment donner au fichier 'test' les permissions : rwxr-x-wx ?" "chmod 753 test"
  unlock
}


enter_chapter bash 6 1
