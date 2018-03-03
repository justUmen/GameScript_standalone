#!/bin/bash
#SOME ADDED AND CHANGE IN CLI learn_cli.sh in CLASSIC

function download_all_sounds(){
	#~ echo "Downloading..."
	cd $AUDIO_LOCAL || exit
	i=4
	rm to_dl.wget 2> /dev/null
	echo "Downloading Audio..."
	while [ $i -le $LINES ]; do
		#~ ( wget -q $AUDIO_DL/$i.mp3 -O $AUDIO_LOCAL/$i.mp3 || rm $AUDIO_LOCAL/$i.mp3 ) &> /dev/null &
		echo "$AUDIO_DL/$i.mp3" >> to_dl.wget
		i=`expr $i + 1`
	done
	cat to_dl.wget | xargs -n 1 -P 8 wget -q &
}

function prepare_audio(){
	AUDIO_LOCAL="$HOME/.GameScript/Audio/$LANGUAGE/classic/$CHAPTER_NAME/$SPEAKER/c$CHAPTER_NUMBER"
	mkdir -p $AUDIO_LOCAL 2> /dev/null
	AUDIO_DL="https://raw.githubusercontent.com/justUmen/GameScript/master/$LANGUAGE/classic/$CHAPTER_NAME/Audio/$SPEAKER/c$CHAPTER_NUMBER"
	AUDIOCMP=1
	if [ ! -f "$AUDIO_LOCAL/4.mp3" ]; then
		wget -q --spider http://google.com
		if [ $? -eq 0 ]; then
			download_all_sounds
		else
			echo "Cannot download audio, no internet ?"
		fi
	fi
}

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

#TODO ???
function new_sound(){
	pkill mplayer &> /dev/null
	pkill mpg123 &> /dev/null
	$SOUNDPLAYER "$AUDIO_LOCAL/$restore.mp3" &> /dev/null &
	#~ if [[ ! -f "$AUDIO_DL/`expr $restore + 1`.mp3" ]];then
		#~ ( wget $AUDIO_DL/`expr $restore + 1`.mp3 -O $AUDIO_LOCAL/`expr $restore + 1`.mp3 || rm $AUDIO_LOCAL/`expr $restore + 1`.mp3 ) &> /dev/null &
		#~ ( wget -nc $AUDIO_DL/`expr $restore + 1`.mp3 -O $AUDIO_LOCAL/`expr $restore + 1`.mp3 || ( rm $AUDIO_LOCAL/`expr $restore + 1`.mp3 ; wget -nc $AUDIO_DL/`expr $restore + 2`.mp3 -O $AUDIO_LOCAL/`expr $restore + 2`.mp3 || $AUDIO_LOCAL/`expr $restore + 2`.mp3 ) ) &> /dev/null & #download next one, or the one after if it doesn't exist
	#~ fi
	#~ if [[ ! -f "$AUDIO_DL/`expr $restore + 2`.mp3" ]];then
		#~ ( wget $AUDIO_DL/`expr $restore + 2`.mp3 -O $AUDIO_LOCAL/`expr $restore + 2`.mp3 || rm $AUDIO_LOCAL/`expr $restore + 2`.mp3 ) &> /dev/null &
	#~ fi
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
		#~ echo -e "\\e[0;100m 0) \\e[0m Télécharger audio en avance"
		echo -e "\\e[0;100m 1) \\e[0m $1"
		echo -e "\\e[0;100m 2) \\e[0m $2"
		echo -e "\\e[0;100m 3) \\e[0m $3"
		echo -en "\\e[97;45m # \\e[0m"
		read key < /dev/tty
		case $key in
			0) download_all_sounds ;;
			1) 	if [ -f "$HOME/.GameScript/restore_$7$8" ];then
					echo "$HOME/.GameScript/restore_$7$8 existe, continuer ou recommencer le cours du début ?"
					while [ "$choice" != "1" ] || [ "$choice" != "2" ] || [ "$choice" != "3" ]; do
						echo -e "\\e[0;100m 1) \\e[0m Continuer"
						echo -e "\\e[0;100m 2) \\e[0m Recommencer"
						echo -e "\\e[0;100m 3) \\e[0m Retour"
						echo -en "\\e[97;45m # \\e[0m"
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
	echo -en "\\e[97;45m # \\e[0m"
	read -r USER_CODE < /dev/tty
	if [ ! "$USER_CODE" == "$2" ]; then
		talk_not_press_key justumen "\\e[4;37mDésolé, réponse fausse ou trop longue. Je vous conseille de suivre le cours.\\e[0m"
		exit
	else
		talk_not_press_key justumen "Correct !"
	fi
}
function answer_run(){
	echo -en "\\e[97;45m # \\e[0m"
	read -r USER_CODE < /dev/tty
	while [ ! "$USER_CODE" == "$1" ]; do
		if [ ! "$USER_CODE" == "" ]; then
			talk_not_press_key_ANSWER "$2" "$1"
		fi
		echo -en "\\e[97;45m # \\e[0m"
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
On_Black='\e[97;40m'
reset='\e[0m'

basic=$On_Black
code=$black_on_lightblue
codeFile=$black_on_green
codeError=$black_on_red

#UNDERLINE
#~ voc='\e[1m'
voc='\e[4;37m'
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
	talk_not_press_key justumen "Pour débloquer '$1 $2' sur le chat, allez sur \e[4;37mhttps://rocket.bjornulf.org/direct/boti\e[0m et copiez/collez : \e[97;42mpassword$PASS\e[0m"
	touch "$HOME/.GameScript/good_$1$2" 2> /dev/null
	mkdir $HOME/.GameScript/passwords/ 2> /dev/null
	echo -n "$PASS" > "$HOME/.GameScript/passwords/$1$2"
	exit
}

function enter_chapter(){
	#Usage : enter_chapter bash 1 1 (first 1 is chapter, next one is for case)
	echo ""
	echo -e "\e[97;44m - $1, Chapitre $2 \e[0m"
	answer_quiz "Cours" "Questionnaire" "Retour" "4" "5" "6" "$1" "$2"
}
function start_lecture(){
restore=$1
case $1 in
1) echo -n 1 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; [ -d "$HOME/.GameScript_bash6" ] && echo "Erreur innatendu, ${HOME}/.GameScript_bash6 existe déjà sur votre système ! Supprimez ce dossier $HOME/.GameScript_bash6 et relancer ce script." && exit; restore=$(expr $restore + 1) ;&
2) echo -n 2 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; ( mkdir $HOME/.GameScript_bash6 ; wget -q -nc $AUDIO_DL/5.mp3 -O $AUDIO_LOCAL/5.mp3 || rm $AUDIO_LOCAL/5.mp3 ) > /dev/null 2>&1; restore=$(expr $restore + 1) ;&
3) echo -n 3 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; cd $HOME/.GameScript_bash6; restore=$(expr $restore + 1) ;&
4) echo -n 4 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; echo "xxxxxx">intrus;echo "contenu f">f;chmod 222 f;echo "contenu f1">f1;chmod 000 f1;echo "contenu f10">f10;chmod 010 f10;echo "contenu f2">f2;chmod 444 f2;echo "contenu f3">f3;chmod 400 f3;echo "contenu f4">f4;chmod 455 f4;echo "contenu f50">f50;chmod 111 f50; restore=$(expr $restore + 1) ;&
5) echo -n 5 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk_not_press_key justumen "Commençons par évaluer notre situation avec un : ${learn}ls -l${reset}"; restore=$(expr $restore + 1) ;&
6) echo -n 6 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; answer_run "ls -l" justumen "Non"; restore=$(expr $restore + 1) ;&
7) echo -n 7 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "Nous avons ici certains problèmes de permission à régler..."; restore=$(expr $restore + 1) ;&
8) echo -n 8 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "Nous voulons rajouter le droit de lecture et d'écriture pour le propriétaire sur tous les éléments du répertoire courant."; restore=$(expr $restore + 1) ;&
9) echo -n 9 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "Il est possible de mettre tous les noms les uns à la suite des autres avec ${code}chmod${reset}."; restore=$(expr $restore + 1) ;&
10) echo -n 10 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk_not_press_key justumen "Faites le donc pour 'f1' et 'f2', puis réaffichez les nouvelles permissions si la commande est un succès."; restore=$(expr $restore + 1) ;&
11) echo -n 11 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; answer_run "chmod u+rw f1 f2&&ls -l" justumen "Non"; restore=$(expr $restore + 1) ;&
12) echo -n 12 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "Taper tous les noms de fichiers est finalement particulièrement rébarbatif, surtout si vous avez un grand nombre de fichiers à changer."; restore=$(expr $restore + 1) ;&
13) echo -n 13 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "Dans ce chapitre nous allons ajouter de nouveaux caractères spéciaux à notre arsenal !"; restore=$(expr $restore + 1) ;&
14) echo -n 14 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "Le premier que nous allons voir est : ${code}*${reset}"; restore=$(expr $restore + 1) ;&
15) echo -n 15 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "${code}*${reset} est un symbole très puissant, on l'appelle un ${voc}joker${reset}."; restore=$(expr $restore + 1) ;&
16) echo -n 16 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "${code}*${reset} peut être utilisée pour remplacer tous les éléments d'un répertoire."; restore=$(expr $restore + 1) ;&
17) echo -n 17 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "C'est à dire qu'au lieu d'avoir à taper tous les noms les uns à la suite des autres, vous avez juste à mettre une ${code}*${reset} à la place."; restore=$(expr $restore + 1) ;&
18) echo -n 18 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk_not_press_key justumen "Ajoutez donc le droit de lecture et d'écriture pour le propriétaire sur tous les éléments du répertoire courant, puis réaffichez les nouvelles permissions si la commande est un succès."; restore=$(expr $restore + 1) ;&
19) echo -n 19 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; answer_run "chmod u+rw *&&ls -l" justumen "Non"; restore=$(expr $restore + 1) ;&
20) echo -n 20 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "Si ${code}*${reset} est utilisée seule, le répertoire en question est bien évidemment le répertoire courant : ${code}*${reset} = ${code}./*${reset}"; restore=$(expr $restore + 1) ;&
21) echo -n 21 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "Mais ${code}*${reset} peut être utilisée avec n'importe quel chemin, par exemple : ${code}/*${reset} représente tous les éléments du répertoire racine."; restore=$(expr $restore + 1) ;&
22) echo -n 22 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "Ici nous avons finalement résolu tous nos problèmes de permissions en une seule commande !"; restore=$(expr $restore + 1) ;&
23) echo -n 23 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "Mais ${code}*${reset} peut aussi être utilisée avec les autres commandes."; restore=$(expr $restore + 1) ;&
24) echo -n 24 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk_not_press_key justumen "Affichez donc le contenu de tous les fichiers du répertoire courant les uns à la suite des autres."; restore=$(expr $restore + 1) ;&
25) echo -n 25 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; answer_run "cat *" justumen "Non"; restore=$(expr $restore + 1) ;&
26) echo -n 26 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "L'ordre d'affichage est ${voc}alphabétique${reset}, exactement comme le résultat de ${code}ls${reset}."; restore=$(expr $restore + 1) ;&
27) echo -n 27 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "Notez que 'f10' est placé avant 'f2', car l'affichage par défaut est ${voc}alphabétique${reset} et non pas ${voc}numérique${reset}."; restore=$(expr $restore + 1) ;&
28) echo -n 28 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "Si l'affichage numérique vous intéresse, vous auriez pu trouver facilement l'option ${code}-v${reset} dans le manuel de ${code}ls${reset}."; restore=$(expr $restore + 1) ;&
29) echo -n 29 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "${code}*${reset} peut donc représenter tous les éléments d'un répertoire."; restore=$(expr $restore + 1) ;&
30) echo -n 30 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "Mais que fait-elle exactement pour avoir cet effet ?"; restore=$(expr $restore + 1) ;&
31) echo -n 31 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "${code}*${reset} peut en fait remplacer une chaine de caractère quelconque."; restore=$(expr $restore + 1) ;&
32) echo -n 32 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "Si elle est utilisée seule, elle représente donc tous les fichiers qui ont un nom quelconque..."; restore=$(expr $restore + 1) ;&
33) echo -n 33 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "Mais il est aussi possible de limiter ce qu'elle représente en y ajoutant des caractères."; restore=$(expr $restore + 1) ;&
34) echo -n 34 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk_not_press_key justumen "Par exemple, vous pouvez afficher tous les éléments du répertoire courant qui commence par un 'f' avec : ${learn}ls f*${reset}"; restore=$(expr $restore + 1) ;&
35) echo -n 35 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; answer_run "ls f*" justumen "Non"; restore=$(expr $restore + 1) ;&
36) echo -n 36 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "Ici le fichier 'intrus' n'est pas présent car son nom ne commence pas par un 'f'."; restore=$(expr $restore + 1) ;&
37) echo -n 37 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk_not_press_key justumen "Affichez tous les éléments du répertoire courant qui se terminent par un 0 avec : ${learn}ls *0${reset}"; restore=$(expr $restore + 1) ;&
38) echo -n 38 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; answer_run "ls *0" justumen "Non"; restore=$(expr $restore + 1) ;&
39) echo -n 39 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "La commande ${code}ls${reset} accepte aussi plusieurs arguments, vous pouvez donc cumuler les syntaxes."; restore=$(expr $restore + 1) ;&
40) echo -n 40 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk_not_press_key justumen "Essayez par exemple de lister les permissions de tous les éléments du répertoire courant qui finissent soit par un 0, soit par un s."; restore=$(expr $restore + 1) ;&
41) echo -n 41 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; answer_run "ls -l *0 *s" justumen "Non"; restore=$(expr $restore + 1) ;&
42) echo -n 42 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk_not_press_key justumen "Lister maintenant toutes les permissions des éléments du répertoire courant qui commencent par un 'i' et finissent par un 's'."; restore=$(expr $restore + 1) ;&
43) echo -n 43 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; answer_run "ls -l i*s" justumen "Non"; restore=$(expr $restore + 1) ;&
44) echo -n 44 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "Avec ${code}i*s${reset}, seul le fichier 'intrus' rentre dans les critères de sélection."; restore=$(expr $restore + 1) ;&
45) echo -n 45 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "Dans le cas de ce fichier 'intrus', ${code}*${reset} remplacera la chaine de caractère 'ntru'."; restore=$(expr $restore + 1) ;&
46) echo -n 46 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "Si vous avez besoin d'un ciblage plus en finesse, vous pouvez utiliser un autre ${voc}joker${reset} : le ${code}?${reset}."; restore=$(expr $restore + 1) ;&
47) echo -n 47 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "${code}?${reset} ne remplace lui qu'${voc}un${reset} seul caractère !"; restore=$(expr $restore + 1) ;&
48) echo -n 48 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk_not_press_key justumen "Essayer donc cette commande : ${learn}ls -l f?${reset}"; restore=$(expr $restore + 1) ;&
49) echo -n 49 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; answer_run "ls -l f?" justumen "Non"; restore=$(expr $restore + 1) ;&
50) echo -n 50 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "Ici 'f10' et 'f50' ne s'affichent pas, car il y a deux caractères après la lettre f."; restore=$(expr $restore + 1) ;&
51) echo -n 51 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk_not_press_key justumen "Affichez donc ces deux fichiers, en faisant : ${learn}ls -l f??${reset}"; restore=$(expr $restore + 1) ;&
52) echo -n 52 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; answer_run "ls -l f??" justumen "Non"; restore=$(expr $restore + 1) ;&
53) echo -n 53 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk_not_press_key justumen "Mais qu'en est-il du fichier 'f' ? Affichez donc ses permissions."; restore=$(expr $restore + 1) ;&
54) echo -n 54 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; answer_run "ls -l f" justumen "Non"; restore=$(expr $restore + 1) ;&
55) echo -n 55 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "Le fichier 'f' existe bel et bien, mais ne s'est pas affiché lors de nos dernières commandes avec ${code}?${reset}..."; restore=$(expr $restore + 1) ;&
56) echo -n 56 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "${code}?${reset} remplace exactement ${code}un${reset} caractère, ni plus, ni moins."; restore=$(expr $restore + 1) ;&
57) echo -n 57 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk_not_press_key justumen "Essayez donc avec : ls ${learn}f*${reset}"; restore=$(expr $restore + 1) ;&
58) echo -n 58 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; answer_run "ls f*" justumen "Non"; restore=$(expr $restore + 1) ;&
59) echo -n 59 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "Ici même s'il n'y a aucun caractère après le f, le fichier 'f' s'affiche."; restore=$(expr $restore + 1) ;&
60) echo -n 60 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk justumen "C'est tout simplement parce que ${code}*${reset} peut aussi représenter une chaine de caractère vide !"; restore=$(expr $restore + 1) ;&
61) echo -n 61 > $HOME/.GameScript/restore_bash6; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash6; talk_not_press_key justumen "Pour afficher les permissions de tous les fichiers avec un nom d'une lettre, vous pouvez utiliser : ${learn}ls -l ?${reset}"; restore=$(expr $restore + 1) ;&
