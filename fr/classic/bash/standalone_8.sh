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
	cat to_dl.wget | xargs -n 1 -P 4 wget -q &
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
	talk_not_press_key justumen "Pour débloquer '$1 $2' sur le chat, ouvrez une conversation privée avec 'boti' et copiez/collez :\n\t\e[97;42mpassword$PASS\e[0m"
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
1) echo -n 1 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; [ -d "$HOME/.GameScript_bash8" ] && echo "Erreur innatendu, ${HOME}/.GameScript_bash8 existe déjà sur votre système ! Supprimez ce dossier $HOME/.GameScript_bash8 et relancer ce script." && exit; restore=$(expr $restore + 1) ;&
2) echo -n 2 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; mkdir $HOME/.GameScript_bash8 2> /dev/null; restore=$(expr $restore + 1) ;&
3) echo -n 3 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; cd $HOME/.GameScript_bash8; restore=$(expr $restore + 1) ;&
4) echo -n 4 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; echo -e "Josephnemail:joseph@bjornulf.orgnCarlanemail:carla@bjornulf.orgnCharlienemail:charlie@bjornulf.orgnAkemailnemail:akemail@bjornulf.orgnBobnemail:bob@bjornulf.orgnAlbertnemail:albert@bjornulf.orgnJessicanemail:jessica@bjornulf.orgnCarlanemail:carla@bjornulf.org" > $HOME/.GameScript_bash8/LIST; restore=$(expr $restore + 1) ;&
5) echo -n 5 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Commençons par créer notre environnement pour ce chapitre."; restore=$(expr $restore + 1) ;&
6) echo -n 6 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk_not_press_key justumen "Créez le fichier 'test' avec : ${learn}echo au revoir>test${reset}"; restore=$(expr $restore + 1) ;&
7) echo -n 7 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; answer_run "echo au revoir>test" justumen "Non"; restore=$(expr $restore + 1) ;&
8) echo -n 8 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Nous allons maintenant utiliser la commande ${code}wc${reset} pour avoir des informations supplémentaires sur le contenu de ce fichier."; restore=$(expr $restore + 1) ;&
9) echo -n 9 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk_not_press_key justumen "Faites donc ${learn}wc test${reset}"; restore=$(expr $restore + 1) ;&
10) echo -n 10 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; answer_run "wc test" justumen "Non"; restore=$(expr $restore + 1) ;&
11) echo -n 11 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Ici nous avons trois nombres, le premier représente le nombre de ${voc}lignes${reset} du fichier : ${code}1${reset}  2 10 test"; restore=$(expr $restore + 1) ;&
12) echo -n 12 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Le deuxième représente le nombre de ${voc}mots${reset} du fichier : 1  ${code}2${reset} 10 test"; restore=$(expr $restore + 1) ;&
13) echo -n 13 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Le troisième représente le nombre de ${voc}caractères${reset} du fichier : 1  2 ${code}10${reset} test"; restore=$(expr $restore + 1) ;&
14) echo -n 14 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk_not_press_key justumen "Affichez donc le contenu de 'test'"; restore=$(expr $restore + 1) ;&
15) echo -n 15 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; answer_run "cat test" justumen "Non"; restore=$(expr $restore + 1) ;&
16) echo -n 16 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Nous avons bien dans ce fichier ${code}1${reset} ligne et ${code}2${reset} mots : 'au' et 'revoir'."; restore=$(expr $restore + 1) ;&
17) echo -n 17 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "${code}wc${reset} nous informe également que ce fichier est composé de 10 caractères."; restore=$(expr $restore + 1) ;&
18) echo -n 18 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Le premier mot 'au' est composé de deux caractères, 'a' et 'u'."; restore=$(expr $restore + 1) ;&
19) echo -n 19 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Le deuxième mot 'revoir' est lui composé de six caractères, ce qui en ajoutant les deux précédents, fait huit."; restore=$(expr $restore + 1) ;&
20) echo -n 20 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "L'espace séparant les deux mots est aussi un caractère, ce qui nous amène à neuf."; restore=$(expr $restore + 1) ;&
21) echo -n 21 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Le dixième caractère est en fait la mise à la ligne que nous avons vu dans le chapitre 3 : que l'on peut représenter avec 'n'."; restore=$(expr $restore + 1) ;&
22) echo -n 22 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Je vous rappelle que la commande ${code}echo${reset} ajoute automatiquement un 'n' à la fin, à moins que l'option -n soit présente."; restore=$(expr $restore + 1) ;&
23) echo -n 23 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Voyons ce que nous avons fait jusqu'à présent : ${code}echo au revoir>test${reset} pour créer le fichier 'test' et ${code}wc test${reset} pour analyser ce fichier."; restore=$(expr $restore + 1) ;&
24) echo -n 24 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "La commande ${voc}wc${reset} prend ici en argument le fichier qui contient le contenu de ce que vous voulez analyser."; restore=$(expr $restore + 1) ;&
25) echo -n 25 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Dans le chapitre précédent, nous avons vu que l'on pouvait rediriger la ${voc}sortie standard${reset} vers un fichier avec ${code}>${reset} ou ${code}1>${reset}."; restore=$(expr $restore + 1) ;&
26) echo -n 26 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Mais vous n'êtes pas obligé de créer le fichier 'test' si vous n'en avez pas besoin."; restore=$(expr $restore + 1) ;&
27) echo -n 27 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Il est en fait aussi possible de rediriger la sortie standard non pas vers un fichier mais vers ${voc}une autre commande${reset} avec le symbole ${code}|${reset}, aussi appelé 'pipe' ou tuyau."; restore=$(expr $restore + 1) ;&
28) echo -n 28 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "${voc}wc${reset} est, comme de très nombreuses commandes, aussi capable de lire la ${voc}sortie standard${reset}."; restore=$(expr $restore + 1) ;&
29) echo -n 29 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk_not_press_key justumen "Faites donc : ${learn}echo au revoir|wc${reset}"; restore=$(expr $restore + 1) ;&
30) echo -n 30 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; answer_run "echo au revoir|wc" justumen "Non"; restore=$(expr $restore + 1) ;&
31) echo -n 31 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Ici avec la barre verticale, le résultat est identique, sauf que le nom du fichier ne s'affiche pas car il n'y a pas de fichier."; restore=$(expr $restore + 1) ;&
32) echo -n 32 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Le 'pipe' est un des concepts les plus puissant de la ligne de commande."; restore=$(expr $restore + 1) ;&
33) echo -n 33 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Une commande peut envoyer sa sortie standard à une deuxième commande, celle-ci peut ensuite envoyer sa propre sortie standard à une troisième commande, et ainsi de suite."; restore=$(expr $restore + 1) ;&
34) echo -n 34 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk_not_press_key justumen "Affichez donc le contenu du fichier 'LIST'."; restore=$(expr $restore + 1) ;&
35) echo -n 35 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; answer_run "cat LIST" justumen "Non"; restore=$(expr $restore + 1) ;&
36) echo -n 36 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Ici vous avez une liste de noms et d'emails. Imaginons que seul les emails vous intéresse."; restore=$(expr $restore + 1) ;&
37) echo -n 37 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Pour détecter la présence d'un mot clef dans une ligne, il vous faudra utiliser la commande ${code}grep${reset}."; restore=$(expr $restore + 1) ;&
38) echo -n 38 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Bien évidemment, ${code}grep${reset} est capable de lire la ${voc}sortie standard${reset}, vous pouvez donc l'utiliser en combinaison avec  la ${voc}|${reset}."; restore=$(expr $restore + 1) ;&
39) echo -n 39 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk_not_press_key justumen "Affichez uniquement les lignes du fichier qui contiennent le mot 'email' avec : ${learn}cat LIST|grep email${reset}"; restore=$(expr $restore + 1) ;&
40) echo -n 40 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; answer_run "cat LIST|grep email" justumen "Non"; restore=$(expr $restore + 1) ;&
41) echo -n 41 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Ici le choix du mot clef "email" est personnel, et vous devez faire attention à ce que ce choix soit judicieux."; restore=$(expr $restore + 1) ;&
42) echo -n 42 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "${code}grep email${reset} posera problème si un des noms est 'email', ou contient le mot 'email', comme 'Akemail'."; restore=$(expr $restore + 1) ;&
43) echo -n 43 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk_not_press_key justumen "Pour détecter les emails d'une manière plus fiable, vous pouvez utiliser la présence de '@', faites donc : ${learn}cat LIST|grep @${reset}"; restore=$(expr $restore + 1) ;&
44) echo -n 44 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; answer_run "cat LIST|grep @" justumen "Non"; restore=$(expr $restore + 1) ;&
45) echo -n 45 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Vous avez donc ici dans votre sortie standard uniquement les adresses emails."; restore=$(expr $restore + 1) ;&
46) echo -n 46 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk_not_press_key justumen "Utilisez maintenant votre nouvelle sortie standard pour créer le fichier 'EMAILS' qui contiendra tous les emails du fichier LIST en faisant : ${learn}cat LIST|grep @>EMAILS${reset}"; restore=$(expr $restore + 1) ;&
47) echo -n 47 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; answer_run "cat LIST|grep @>EMAILS" justumen "Non"; restore=$(expr $restore + 1) ;&
48) echo -n 48 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "${code}grep @${reset} affichera donc toutes les lignes qui contiennent au moins une '@'."; restore=$(expr $restore + 1) ;&
49) echo -n 49 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Pour faire l'inverse, vous devez ajouter à ${code}grep @${reset} l'option -v."; restore=$(expr $restore + 1) ;&
50) echo -n 50 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk_not_press_key justumen "Affichez donc toutes les lignes qui ne contiennent pas '@' avec : ${learn}cat LIST|grep -v @${reset}"; restore=$(expr $restore + 1) ;&
51) echo -n 51 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; answer_run "cat LIST|grep -v @" justumen "Non"; restore=$(expr $restore + 1) ;&
52) echo -n 52 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Avant d'enregistrer cette liste dans un fichier, nous voulons classer alphabétiquement ces noms avec la commande ${learn}sort${reset}."; restore=$(expr $restore + 1) ;&
53) echo -n 53 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk_not_press_key justumen "Pour cela il suffit de continuer à utiliser la sortie standard, faites donc : ${learn}cat LIST|grep -v @|sort${reset}"; restore=$(expr $restore + 1) ;&
54) echo -n 54 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; answer_run "cat LIST|grep -v @|sort" justumen "Non"; restore=$(expr $restore + 1) ;&
55) echo -n 55 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Ici nous avons un problème. Le nom de Carla apparait clairement deux fois."; restore=$(expr $restore + 1) ;&
56) echo -n 56 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Pour éliminer les noms identiques qui se suivent, vous devez utiliser la commande ${learn}uniq${reset}."; restore=$(expr $restore + 1) ;&
57) echo -n 57 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk_not_press_key justumen "Continuons à enchainer les pipes, faites donc : ${learn}cat LIST|grep -v @|sort|uniq${reset}"; restore=$(expr $restore + 1) ;&
58) echo -n 58 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; answer_run "cat LIST|grep -v @|sort|uniq" justumen "Non"; restore=$(expr $restore + 1) ;&
59) echo -n 59 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Ici notre résultat est parfait, vous pourriez donc rediriger la dernière sortie standard pour créer un fichier 'NAMES'."; restore=$(expr $restore + 1) ;&
60) echo -n 60 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "En programmation comme dans un terminal, il a toujours plus d'une seule fac???on pour faire la même chose."; restore=$(expr $restore + 1) ;&
61) echo -n 61 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Nous avons utilisé le code suivant : ${code}cat LIST|grep -v @|sort|uniq${reset}"; restore=$(expr $restore + 1) ;&
62) echo -n 62 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Ici ${code}grep${reset} utilisera la sortie standard, mais comme ${code}wc${reset}, ${code}grep${reset} accepte aussi en argument un fichier."; restore=$(expr $restore + 1) ;&
63) echo -n 63 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Vous auriez pu donc tout aussi bien ne pas utiliser la commande ${code}cat${reset}, en faisant directement : ${code}grep -v @ LIST|sort|uniq${reset}"; restore=$(expr $restore + 1) ;&
64) echo -n 64 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "${code}uniq${reset} peut également être supprimé, car ${code}sort${reset} possède aussi une option qui est capable de supprimer les doublons : -u."; restore=$(expr $restore + 1) ;&
65) echo -n 65 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk_not_press_key justumen "Essayez donc cette nouvelle commande : ${learn}grep -v @ LIST|sort -u${reset}"; restore=$(expr $restore + 1) ;&
66) echo -n 66 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; answer_run "grep -v @ LIST|sort -u" justumen "Non"; restore=$(expr $restore + 1) ;&
67) echo -n 67 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "${learn}grep -v @ LIST|sort -u${reset} donne donc un résultat identique à ${learn}cat LIST|grep -v @|sort|uniq${reset}."; restore=$(expr $restore + 1) ;&
68) echo -n 68 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Mais l'important n'est pas tant votre style d'écriture, mais une excellente compréhension de toutes les fonctionnalités qui vous sont offertes."; restore=$(expr $restore + 1) ;&
69) echo -n 69 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Pour l'instant je vous impose un style d'écriture minimal, mais avec le temps vous développerez probablement un style différent, qui ne sera pas moins valide que celui que je partage ici avec vous."; restore=$(expr $restore + 1) ;&
70) echo -n 70 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Que cela soit l'utilisation des espaces pour la présentation, ou la logique derrière votre code."; restore=$(expr $restore + 1) ;&
71) echo -n 71 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Maintenant je vais vous donner quelques clarifications sur les commandes précédentes."; restore=$(expr $restore + 1) ;&
72) echo -n 72 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Pour afficher uniquement le nombre de lignes, vous auriez pu utiliser ${code}wc${reset} avec l'option -l."; restore=$(expr $restore + 1) ;&
73) echo -n 73 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk_not_press_key justumen "Essayez donc : ${learn}echo au revoir|wc -l${reset}"; restore=$(expr $restore + 1) ;&
74) echo -n 74 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; answer_run "echo au revoir|wc -l" justumen "Non"; restore=$(expr $restore + 1) ;&
75) echo -n 75 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Pour être précis, ${code}wc${reset} ne compte pas réellement le nombre de lignes, mais pluto???t le nombre de retour à la ligne."; restore=$(expr $restore + 1) ;&
76) echo -n 76 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk_not_press_key justumen "Essayez donc de faire : ${learn}echo -n au revoir|wc -l${reset}"; restore=$(expr $restore + 1) ;&
77) echo -n 77 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; answer_run "echo -n au revoir|wc -l" justumen "Non"; restore=$(expr $restore + 1) ;&
78) echo -n 78 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Ici le résultat n'est bien évidemment pas 0 ligne, mais 0 'n', puisque nous n'avons pas le dernier caractère 'n' avec l'option -n."; restore=$(expr $restore + 1) ;&
79) echo -n 79 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "C'est une convention d'avoir une mise a la ligne a la fin d'un fichier texte."; restore=$(expr $restore + 1) ;&
80) echo -n 80 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Mais cela n'est pas strictement obligatoire, attention donc à certains fichiers qui ne se terminent pas par un 'n'."; restore=$(expr $restore + 1) ;&
81) echo -n 81 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Nous avons vu que ${code}|${reset} était utilisé pour rediriger la sortie standard vers une autre commande."; restore=$(expr $restore + 1) ;&
82) echo -n 82 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Mais il est aussi possible de rediriger la sortie erreur standard de la même manière, en utilisant cette fois ${code}|&${reset}."; restore=$(expr $restore + 1) ;&
83) echo -n 83 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk_not_press_key justumen "Faites donc par exemple : ${learn}cat x|&grep cat${reset}"; restore=$(expr $restore + 1) ;&
84) echo -n 84 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; answer_run "cat X|&grep cat" justumen "Non"; restore=$(expr $restore + 1) ;&
85) echo -n 85 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk_not_press_key justumen "Et l'inverse : ${learn}cat x|&grep -v cat${reset}"; restore=$(expr $restore + 1) ;&
86) echo -n 86 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; answer_run "cat X|&grep cat" justumen "Non"; restore=$(expr $restore + 1) ;&
87) echo -n 87 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "La logique est identique à celle de la sortie standard, libre à vous de faire ce que vous désirez."; restore=$(expr $restore + 1) ;&
88) echo -n 88 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "Bien évidemment, attention à ne pas mélanger ${code}|${reset} ou ${code}|&${reset} avec ${code}||${reset} !"; restore=$(expr $restore + 1) ;&
89) echo -n 89 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen ""; restore=$(expr $restore + 1) ;&
90) echo -n 90 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen ""; restore=$(expr $restore + 1) ;&
91) echo -n 91 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen ""; restore=$(expr $restore + 1) ;&
92) echo -n 92 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "??? Convention d'avoir une mise a la ligne a la fin d'un fichier texte"; restore=$(expr $restore + 1) ;&
93) echo -n 93 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen ""; restore=$(expr $restore + 1) ;&
94) echo -n 94 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen ""; restore=$(expr $restore + 1) ;&
95) echo -n 95 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen ""; restore=$(expr $restore + 1) ;&
96) echo -n 96 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "wc"; restore=$(expr $restore + 1) ;&
97) echo -n 97 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "sort"; restore=$(expr $restore + 1) ;&
98) echo -n 98 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "grep"; restore=$(expr $restore + 1) ;&
99) echo -n 99 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "uniq"; restore=$(expr $restore + 1) ;&
100) echo -n 100 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "stdin - ?"; restore=$(expr $restore + 1) ;&
101) echo -n 101 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen ""|", like ">" but for other commands"; restore=$(expr $restore + 1) ;&
102) echo -n 102 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen ""<" + filename"; restore=$(expr $restore + 1) ;&
103) echo -n 103 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen ""<<" (EOF ?)"; restore=$(expr $restore + 1) ;&
104) echo -n 104 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen ""|&" pipe error"; restore=$(expr $restore + 1) ;&
105) echo -n 105 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "command < input-file > output-file"; restore=$(expr $restore + 1) ;&
106) echo -n 106 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "ls -y >> c.log 2>&1 VS ls -y 2>&1 >> c.log"; restore=$(expr $restore + 1) ;&
107) echo -n 107 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen ""; restore=$(expr $restore + 1) ;&
108) echo -n 108 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; clean; restore=$(expr $restore + 1) ;&
109) echo -n 109 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen ""; restore=$(expr $restore + 1) ;&
110) echo -n 110 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen ""; restore=$(expr $restore + 1) ;&
111) echo -n 111 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "être"; restore=$(expr $restore + 1) ;&
112) echo -n 112 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "déjà"; restore=$(expr $restore + 1) ;&
113) echo -n 113 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "è"; restore=$(expr $restore + 1) ;&
114) echo -n 114 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen ""; restore=$(expr $restore + 1) ;&
115) echo -n 115 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen ""; restore=$(expr $restore + 1) ;&
116) echo -n 116 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen ""; restore=$(expr $restore + 1) ;&
117) echo -n 117 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "wc -l : donne le nombre de nouvelle ligne du fichier (ex : echo -n test|wc -l) = 0"; restore=$(expr $restore + 1) ;&
118) echo -n 118 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen ""; restore=$(expr $restore + 1) ;&
119) echo -n 119 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen ""; restore=$(expr $restore + 1) ;&
120) echo -n 120 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk_not_press_key justumen "Affichez la taille en octets du fichier 'test'."; restore=$(expr $restore + 1) ;&
121) echo -n 121 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; answer_run "ls -l test" justumen "Non"; restore=$(expr $restore + 1) ;&
122) echo -n 122 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen ""; restore=$(expr $restore + 1) ;&
123) echo -n 123 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen ""; restore=$(expr $restore + 1) ;&
124) echo -n 124 > $HOME/.GameScript/restore_bash8; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash8; talk justumen "echo FORCE ASCII ?"; restore=$(expr $restore + 1) ;&
esac
}
CLREOL=$'\x1B[K'

function stds(){
echo -e "$basic
%%%%%%%%%%%%%%%%%          %%%%%%%%%%%%%%%%%
%               %    stdin %               % 
%   cat LIST    %========> %    |grep @    %========>
%               % stdout   %               % stdout
%%%%%%%%%%%%%%%%%          %%%%%%%%%%%%%%%%%
        |                          |
        |================>         |================>
         stderr                     stderr


        ${CLREOL}
${CLREOL}$reset"
}

function clean(){ #in enter_chapter
rm $HOME/.GameScript/restore_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
rm $HOME/.GameScript/restore_pwd_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
	rm $HOME/.GameScript_bash8/file 2> /dev/null
	rm $HOME/.GameScript_bash8/error 2> /dev/null
	rmdir $HOME/.GameScript_bash8 2> /dev/null
}

function start_quiz(){
  echo ""
  echo -e "\e[15;5;44m Bash 'Bourne Again SHell' : Questionnaire du chapitre 8 \e[0m"
  echo -e "- La réponse doit être la plus courte possible, une commande valide mais ajoutant des caractères inutiles ne fonctionnera pas."
  echo -e "Exemple : si la réponse est 'ls'. Les réponses 'ls .', 'ls ./' et 'ls ././' seront considérées comme fausses."
  answer_text_fr "" ""
  unlock "bash" "8" "88ab" "44d5"
}


CHAPTER_NAME="bash"
CHAPTER_NUMBER="8"
LANGUAGE="fr"
SPEAKER="m1"

prepare_audio

enter_chapter $CHAPTER_NAME $CHAPTER_NUMBER
