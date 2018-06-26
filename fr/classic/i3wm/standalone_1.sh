#!/bin/bash
#SOME ADDED AND CHANGE IN CLI learn_cli.sh in CLASSIC
shopt -s expand_aliases
source ~/.bashrc

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

	#??? test delay avoid past read input
	read -s -t 1 -n 10000 discard

	#~ sleep 1
	#~ while read -r -t 0; do read -r; done
	
	#~ sleep 0.5
	#~ read -s -e -t 0.1 #flush stdin ?

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

QUIZ_NUMBER=1
function answer_text_fr(){
	echo ""
	echo "($QUIZ_NUMBER) > $1"
	#~ echo -en "\\e[97;45m # \\e[0m"
	read -e -r -p $'\e[97;45m # \e[0m' USER_CODE < /dev/tty
	if [ ! "$USER_CODE" == "$2" ]; then
		talk_not_press_key justumen "\\e[4;37mDésolé, réponse fausse ou trop longue. Je vous conseille de suivre / refaire le cours.\nSi vous pensez maitriser le contenu du cours, il y a surement un piège, relisez donc attentivement la question. :-)\nSi vous vous sentez vraiment bloqué, demandez de l'aide sur notre chat : https://rocket.bjornulf.org\\e[0m"
		#enter_chapter $CHAPTER_NAME $CHAPTER_NUMBER
		exit
	else
		talk_not_press_key justumen "Correct !"
		QUIZ_NUMBER=`expr $QUIZ_NUMBER + 1`
	fi
}
function answer_run(){
	#~ echo -en "\\e[97;45m # \\e[0m"
	read -e -r -p $'\e[97;45m # \e[0m' USER_CODE < /dev/tty
	while [ ! "$USER_CODE" == "$1" ]; do
		if [ ! "$USER_CODE" == "" ]; then
			talk_not_press_key_ANSWER "$2" "$1"
		fi
		echo -en "\\e[97;45m # \\e[0m"
		read -e -r -p $'\e[97;45m # \e[0m' USER_CODE < /dev/tty
	done
	if [ ! "$1" == "" ];then
		echo -e "\e[1m"
		printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
		#Quick solve for bash10 pb "alias a1='ls -a /var'" ???
		#~ case $1 in
			#~ a1) eval ls -a /var ;;
			#~ alias) alias ;;
			#~ *) eval "$1" ;;
		#~ esac
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
	talk_not_press_key justumen "Pour débloquer '$1 $2' sur le chat, ouvrez une conversation privée avec '@boti' et copiez/collez :\n\t\e[97;42mpassword$PASS\e[0m"
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
1) echo -n 1 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; [ -d "$HOME/.GameScript_i3wm1" ] && echo "Erreur innatendu, ${HOME}/.GameScript_i3wm1 existe déjà sur votre système ! Supprimez ce dossier $HOME/.GameScript_i3wm1 et relancer ce script." && exit; restore=$(expr $restore + 1) ;&
2) echo -n 2 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; mkdir $HOME/.GameScript_i3wm1 &> /dev/null; restore=$(expr $restore + 1) ;&
3) echo -n 3 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; cd $HOME/.GameScript_i3wm1; restore=$(expr $restore + 1) ;&
4) echo -n 4 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; gamescript_window=$(xdotool getwindowfocus); restore=$(expr $restore + 1) ;&
5) echo -n 5 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Il y a deux choses que vous devez apprendre a manipuler, les espaces de travail et les FENETRES."; restore=$(expr $restore + 1) ;&
6) echo -n 6 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Commencons par les espaces de travail. Encore une fois je vais vous donnez mes configurations, libre a vous de les changer plus tard."; restore=$(expr $restore + 1) ;&
7) echo -n 7 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Vous pouvez avoir plusieurs espaces de travail, chacun pourra avoir ses propres configurations et ses propres objectifs."; restore=$(expr $restore + 1) ;&
8) echo -n 8 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Si vous regardez en bas a gauche de votre ecran vous devriez voir le chiffre 1 dans un carre."; restore=$(expr $restore + 1) ;&
9) echo -n 9 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "C'est en fait le nom de votre espace de travail ou vous etes en ce moment."; restore=$(expr $restore + 1) ;&
10) echo -n 10 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Cet espace de travail pour l'instant ne contient que GameScript."; restore=$(expr $restore + 1) ;&
11) echo -n 11 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen ""; restore=$(expr $restore + 1) ;&
12) echo -n 12 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Pour communiquer avec i3, il faudra utiliser des combinaisons de touches."; restore=$(expr $restore + 1) ;&
13) echo -n 13 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Elles sont toutes personnalissables mais je vais vous en donner certaines que je vous conseille de garder."; restore=$(expr $restore + 1) ;&
14) echo -n 14 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Vous pouvez passer d'un espace de travail a l'autre avec la touche super, parfois appele touche windows."; restore=$(expr $restore + 1) ;&
15) echo -n 15 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen ""; restore=$(expr $restore + 1) ;&
16) echo -n 16 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Il faudra en meme temps appuyer sur la touche Super et le numero de l'espace de travail ou vous voulez aller."; restore=$(expr $restore + 1) ;&
17) echo -n 17 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Vous etes en ce moment dans l'espace de travail 1, il faudra donc faire Super + 1 pour revenir sur cet espace de travail."; restore=$(expr $restore + 1) ;&
18) echo -n 18 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Gamescript est en ce moment dans l'espace de travail 1, souvenez vous donc que pour continuer a interagir avec GameScript, il vous faudra faire Super + 1."; restore=$(expr $restore + 1) ;&
19) echo -n 19 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen ""; restore=$(expr $restore + 1) ;&
20) echo -n 20 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Maintenant, deplacez vous dans l'espace de travail 2 avec Super + 2, regardez la liste de vos espaces de travail en bas a gauche votre ecran, puis faites Super + 1 pour revenir sur GameScript."; restore=$(expr $restore + 1) ;&
21) echo -n 21 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 2 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
22) echo -n 22 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen ""; restore=$(expr $restore + 1) ;&
23) echo -n 23 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "De retour dans l'espace de travail 1 vous pouvez remarquer que l'espace de travail 2 n'est pas affiche en bas a gauche."; restore=$(expr $restore + 1) ;&
24) echo -n 24 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Pourtant lorsque vous etiez dans l'espacce de travail 2, l'espace de travail 1 etait visible dans cette liste."; restore=$(expr $restore + 1) ;&
25) echo -n 25 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen ""; restore=$(expr $restore + 1) ;&
26) echo -n 26 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "En fait, i3 se debarassera automatiquement de tous les espaces de travail qui ne contiennent pas de fenetres."; restore=$(expr $restore + 1) ;&
27) echo -n 27 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "L'espace de travail 2 etant pour le moment vide, il ne restera pas affiche dans cette liste."; restore=$(expr $restore + 1) ;&
28) echo -n 28 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Contrairement a l'espace de travail 1, qui contient la fenetre de GameScript."; restore=$(expr $restore + 1) ;&
29) echo -n 29 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen ""; restore=$(expr $restore + 1) ;&
30) echo -n 30 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Je vous conseille d'utiliser des raccourcis clavier pour tous les programmes que vous utilisez regulierement."; restore=$(expr $restore + 1) ;&
31) echo -n 31 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Par exemple, pour ouvrir un nouveau terminal, il faudra utiliser le raccourci clavier Super + Entree."; restore=$(expr $restore + 1) ;&
32) echo -n 32 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen ""; restore=$(expr $restore + 1) ;&
33) echo -n 33 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "On va commencer par creer une nouvelle fenetre dans cet espace de travail 2."; restore=$(expr $restore + 1) ;&
34) echo -n 34 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Deplacez vous dans l'espace de travail 2 avec Super + 2, ouvrez un nouveau terminal avec Super + Entree, puis revenez sur GameScript."; restore=$(expr $restore + 1) ;&
35) echo -n 35 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 2 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
36) echo -n 36 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen ""; restore=$(expr $restore + 1) ;&
37) echo -n 37 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "De retour dans l'espace de travail 1 vous pouvez remarquer que l'espace de travail 2 est cette fois dans la liste, car il contient une fenetre."; restore=$(expr $restore + 1) ;&
38) echo -n 38 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen ""; restore=$(expr $restore + 1) ;&
39) echo -n 39 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Vous pouvez egalement utiliser votre souris et cliquer sur le nom de l'espace de travail ou vous voulez vous rendre."; restore=$(expr $restore + 1) ;&
40) echo -n 40 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Utilisez la liste en bas en gauche pour vous rendre sur l'espace de travail 2 et revenez sur gamescrit en utilisant votre souris egalement."; restore=$(expr $restore + 1) ;&
41) echo -n 41 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `i3-msg -t get_workspaces | jq -r 'map(select(.focused))[0].name'` != 2 ]; do sleep .5; done; restore=$(expr $restore + 1) ;&
42) echo -n 42 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen ""; restore=$(expr $restore + 1) ;&
43) echo -n 43 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Maintenant regardez la barre en haut de votre ecran, elle contient le titre de la fenetre qu'utilise GameScript."; restore=$(expr $restore + 1) ;&
44) echo -n 44 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Bien evidemment, il est possible d'avoir plusieurs fenetres dans un meme espace de travail."; restore=$(expr $restore + 1) ;&
45) echo -n 45 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen ""; restore=$(expr $restore + 1) ;&
46) echo -n 46 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; i3-msg 'exec lxterminal' ???; restore=$(expr $restore + 1) ;&
47) echo -n 47 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Je viens d'ouvrir un nouveau terminal dans votre espace de travail, vous devriez voir deux titres en haut de votre ecran."; restore=$(expr $restore + 1) ;&
48) echo -n 48 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Chaque titre correspond a une fenetre, celui de gauche est le titre de la fenetre de gamescript."; restore=$(expr $restore + 1) ;&
49) echo -n 49 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen ""; restore=$(expr $restore + 1) ;&
50) echo -n 50 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Les titres de fenetres s'affichent de gauche a droite, des plus anciennes aux plus recentes."; restore=$(expr $restore + 1) ;&
51) echo -n 51 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Chaque nouvelle fenetre que vous ouvrez s'ajoutera donc a droite de cette liste."; restore=$(expr $restore + 1) ;&
52) echo -n 52 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Le terminal qui contient GameScript ayant ete ouvert en premier, il restera a le plus a gauche."; restore=$(expr $restore + 1) ;&
53) echo -n 53 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen ""; restore=$(expr $restore + 1) ;&
54) echo -n 54 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Cliquez sur le titre de la deuxieme fenetre pour l'afficher, et revenez sur gamescript en cliquant sur le titre de sa fenetre."; restore=$(expr $restore + 1) ;&
55) echo -n 55 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done;sleep 1;while [ ! `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
56) echo -n 56 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Bien evidemment, je vous conseille d'utiliser votre clavier pour faire cela bien plus rapidement, vous pouvez tout simplement utilisez Super + fleche de gauche/droite."; restore=$(expr $restore + 1) ;&
57) echo -n 57 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen ""; restore=$(expr $restore + 1) ;&
58) echo -n 58 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Faites le donc maintenant, utilisez Super et les fleches gauche et droite."; restore=$(expr $restore + 1) ;&
59) echo -n 59 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done;sleep 1;while [ ! `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
60) echo -n 60 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen ""; restore=$(expr $restore + 1) ;&
61) echo -n 61 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Quand vous passez sur une autre fenetre, on dit que cette fenetre a le focus."; restore=$(expr $restore + 1) ;&
62) echo -n 62 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "C'est a dire que tout autre raccourci clavier sera envoye a la fenetre qui a le focus en ce moment."; restore=$(expr $restore + 1) ;&
63) echo -n 63 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen ""; restore=$(expr $restore + 1) ;&
64) echo -n 64 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Par exemple, pour fermer une fenetre, vous pouvez faire Super + Shift + E, mais attention a ne pas fermer le terminal qui contient Gamescript par erreur."; restore=$(expr $restore + 1) ;&
65) echo -n 65 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Changez le focus avec Super + fleche de droite, et fermez le deuxieme terminal que j'ai ouvert tout a l'heure avec Super + Shift + E."; restore=$(expr $restore + 1) ;&
66) echo -n 66 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
67) echo -n 67 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; to_close=$(xdotool getwindowfocus); restore=$(expr $restore + 1) ;&
68) echo -n 68 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `xdotool search --class ""|grep "^$to_close$"` ];do sleep .5; done; restore=$(expr $restore + 1) ;&
69) echo -n 69 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ ! `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
70) echo -n 70 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen ""; restore=$(expr $restore + 1) ;&
71) echo -n 71 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Maintenant, ouvrez un nouveau terminal avec Super + Entree, vous remarquerez alors que le focus changera automatiquement, il vous faudra donc manuellement revenir sur GameScript."; restore=$(expr $restore + 1) ;&
72) echo -n 72 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; while [ `xdotool getwindowfocus` = $gamescript_window ];do sleep .5; done; restore=$(expr $restore + 1) ;&
73) echo -n 73 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Il y a 3 modes d'affichages des fenetres sur i3."; restore=$(expr $restore + 1) ;&
74) echo -n 74 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen ""; restore=$(expr $restore + 1) ;&
75) echo -n 75 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Par defaut, l'affichage est en onglet, mais vous pouvez aussi avoir une liste des fenetres de haut en bas, ou le titre des fenetres prendra toute la ligne."; restore=$(expr $restore + 1) ;&
76) echo -n 76 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Mais pour passer d'une fenetre a l'autre dans ce mode, il faudra utiliser Super + fleche du haut et bas au lieu de gauche et droite."; restore=$(expr $restore + 1) ;&
77) echo -n 77 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Essayez donc ce mode d'affichage maintenant en faisant Super + S."; restore=$(expr $restore + 1) ;&
78) echo -n 78 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen ""; restore=$(expr $restore + 1) ;&
79) echo -n 79 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Pour revenir au mode d'affichage en onglet, vous pouvez faire Super + W."; restore=$(expr $restore + 1) ;&
80) echo -n 80 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen ""; restore=$(expr $restore + 1) ;&
81) echo -n 81 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Et enfin vous avez un  troisieme mode d'affichage, qui affiche toutes vos fenetres de votre espace de travail dans un damier."; restore=$(expr $restore + 1) ;&
82) echo -n 82 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Essayez ce mode d'affichage en faisant Super + E."; restore=$(expr $restore + 1) ;&
83) echo -n 83 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "En etant dans ce mode, vous pouvez continuer a utiliser Super + E pour alterner entre decoupage vertical et horizontal."; restore=$(expr $restore + 1) ;&
84) echo -n 84 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Faites donc Super + E jusqu'a avoir le nouveau terminal en dessous de la fenetre de GameScript."; restore=$(expr $restore + 1) ;&
85) echo -n 85 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen ""; restore=$(expr $restore + 1) ;&
86) echo -n 86 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Ici meme si les deux fenetres sont visibles a l'ecran, seulement l'une d'entre elles a le focus."; restore=$(expr $restore + 1) ;&
87) echo -n 87 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Toujours de la meme maniere, vous pouvez changer le focus avec Super + les fleches de votre clavier."; restore=$(expr $restore + 1) ;&
88) echo -n 88 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Essayez donc d'alterner votre focus entre ces deux fenetres avec votre clavier et donnez ensuite le focus a la fenetre de GameScript pour continuer."; restore=$(expr $restore + 1) ;&
89) echo -n 89 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen ""; restore=$(expr $restore + 1) ;&
90) echo -n 90 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen ""; restore=$(expr $restore + 1) ;&
91) echo -n 91 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Vous pouvez aussi remarquer qu'avec ce mode d'affichage, il est aussi possible de changer la fenetre focus avec le curseur de votre souris."; restore=$(expr $restore + 1) ;&
92) echo -n 92 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Notez que seul le mouvement de votre curseur est necessaire pour ce changement de focus, vous n'avez pas besoin de cliquer."; restore=$(expr $restore + 1) ;&
93) echo -n 93 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen ""; restore=$(expr $restore + 1) ;&
94) echo -n 94 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Bien evidemment, comme tout ce que vous faites dans i3, je vous conseille d'utiliser votre souris au minimum et de privilegier vos raccourcis clavier."; restore=$(expr $restore + 1) ;&
95) echo -n 95 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Si vous continuez, GameScript disparaitra... et il vous faudra le retrouver pour continuer."; restore=$(expr $restore + 1) ;&
96) echo -n 96 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; i3-msg 'move window to workspace 5'; restore=$(expr $restore + 1) ;&
97) echo -n 97 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen ""; restore=$(expr $restore + 1) ;&
98) echo -n 98 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "GameScript est donc en ce moment dans l'espace de travail 5."; restore=$(expr $restore + 1) ;&
99) echo -n 99 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Vous savez deja comment passer d'un espace de travail a l'autre, mais il est aussi possible de deplacer vos fenetres dans un autre espace de travail."; restore=$(expr $restore + 1) ;&
100) echo -n 100 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Remettez donc la fenetre de GameScript dans l'espace de travail 1 avec Super + Shift + 1, puis revenez sur l'espace de travail 1."; restore=$(expr $restore + 1) ;&
101) echo -n 101 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen ""; restore=$(expr $restore + 1) ;&
102) echo -n 102 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Avoir plusieurs espaces de travail differents vous permet d'organiser vos fenetres selon votre volonte."; restore=$(expr $restore + 1) ;&
103) echo -n 103 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Personnelement, j'utilise l'espace de travail 1 pour tous mes terminaux."; restore=$(expr $restore + 1) ;&
104) echo -n 104 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "L'espace de travail 2 pour mes editeurs de texte."; restore=$(expr $restore + 1) ;&
105) echo -n 105 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "L'espace de travail 3 pour navigateur web et autres fenetres oriente web."; restore=$(expr $restore + 1) ;&
106) echo -n 106 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "L'espace de travail 4 pour gestionnaire de fichier et affichage de contenu, comme visionneuse d'image."; restore=$(expr $restore + 1) ;&
107) echo -n 107 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "L'espace de travail 5 pour tout ce qui est social, email, chat, IRC, etc..."; restore=$(expr $restore + 1) ;&
108) echo -n 108 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen ""; restore=$(expr $restore + 1) ;&
109) echo -n 109 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen "Organiser vos fenetres par theme vous permet de les retrouver tres rapidement, meme si elles sont tres nombreuses."; restore=$(expr $restore + 1) ;&
110) echo -n 110 > $HOME/.GameScript/restore_i3wm1; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_i3wm1; talk justumen ""; restore=$(expr $restore + 1) ;&
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
|-- $code /var/ $reset"
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
|-- $codeFile /Home $reset"
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
$codeFile /Home $reset"
#~ restore=$(expr $restore + 1)
}
function clean(){ #in enter_chapter
rm $HOME/.GameScript/restore_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
rm $HOME/.GameScript/restore_pwd_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
}

function start_quiz(){
  echo ""
  echo -e "\e[15;5;44m i3wm 'i3 Window Manager' : Questionnaire du chapitre 1 \e[0m"
  echo -e "- La réponse doit être la plus courte possible, une commande valide mais ajoutant des caractères inutiles ne fonctionnera pas."
  echo -e "Exemple : si la réponse est 'ls'. Les réponses 'ls .', 'ls ./' et 'ls ././' seront considérées comme fausses."
  answer_text_fr "" ""
  unlock "i3wm" "1" "" ""
}


CHAPTER_NAME="i3wm"
CHAPTER_NUMBER="1"
LANGUAGE="fr"
SPEAKER="m1"

LINES=187
if [ ! "$1" == "MUTE" ]; then prepare_audio; fi

enter_chapter $CHAPTER_NAME $CHAPTER_NUMBER
