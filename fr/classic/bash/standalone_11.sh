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
1) echo -n 1 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; [ -d "$HOME/.GameScript_bash11" ] && echo "Erreur innatendu, ${HOME}/.GameScript_bash10 existe déjà sur votre système ! Supprimez ce dossier $HOME/.GameScript_bash10 et relancer ce script." && exit; restore=$(expr $restore + 1) ;&
2) echo -n 2 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; mkdir $HOME/.GameScript_bash11 2> /dev/null; restore=$(expr $restore + 1) ;&
3) echo -n 3 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; cd $HOME/.GameScript_bash11; restore=$(expr $restore + 1) ;&
4) echo -n 4 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; ; restore=$(expr $restore + 1) ;&
5) echo -n 5 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "echo -e 'read X;if [ $X -eq 1 ];then echo COURS; else echo QUESTIONNAIRE; fi' > $HOME/.GameScript_bash11/if1;"; restore=$(expr $restore + 1) ;&
6) echo -n 6 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "echo -e 'read X\\nif [ $X -eq 1 ]\\nthen\\necho COURS\\nelse\\necho QUESTIONNAIRE\\nfi' > $HOME/.GameScript_bash11/if2"; restore=$(expr $restore + 1) ;&
7) echo -n 7 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "echo -e 'read X\\nif [ $X -eq 1 ]\\nthen\\n\\techo COURS\\nelse\\n\\techo QUESTIONNAIRE\\nfi' > $HOME/.GameScript_bash11/if3"; restore=$(expr $restore + 1) ;&
8) echo -n 8 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "echo -e 'read X\\nif [ $X -eq 1 ]\\nthen\\n\\techo COURS\\nfi\\necho TEXTE' > $HOME/.GameScript_bash11/if4"; restore=$(expr $restore + 1) ;&
9) echo -n 9 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen ""; restore=$(expr $restore + 1) ;&
10) echo -n 10 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Nous avons déjà vu que pour créer un script bash, il suffit de cumuler dans un fichier texte les commandes que vous connaissez déjà."; restore=$(expr $restore + 1) ;&
11) echo -n 11 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Mais bash est donc aussi un langage de programmation que vous pouvez utiliser pour créer des scripts complexes."; restore=$(expr $restore + 1) ;&
12) echo -n 12 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen ""; restore=$(expr $restore + 1) ;&
13) echo -n 13 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Il est par exemple aussi possible de demander une valeur à l'utilisateur, pour donner à votre script une certaine interactivité."; restore=$(expr $restore + 1) ;&
14) echo -n 14 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Pour cela il faut utiliser la commande ${code}read${reset}, qui prend en argument le nom de la variable où sera stocké la valeur donnée."; restore=$(expr $restore + 1) ;&
15) echo -n 15 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Pour demander la valeur de la variable NAME à l'utilisateur, il suffira de faire ${learn}read NAME${reset}"; restore=$(expr $restore + 1) ;&
16) echo -n 16 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Votre script attendra qu'une valeur soit donnée et que la touche entrée soit pressée pour continuer."; restore=$(expr $restore + 1) ;&
17) echo -n 17 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk_not_press_key justumen "Essayez donc de demander la valeur de la variable 'NAME' avec ${learn}read NAME${reset}, tapez quelque chose, puis validez avec la touche entrée."; restore=$(expr $restore + 1) ;&
18) echo -n 18 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; answer_run "read NAME" justumen "Non"; restore=$(expr $restore + 1) ;&
19) echo -n 19 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk_not_press_key justumen "Affichez maintenant la valeur de la variable 'NAME'."; restore=$(expr $restore + 1) ;&
20) echo -n 20 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; answer_run "echo $NAME" justumen "Non"; restore=$(expr $restore + 1) ;&
21) echo -n 21 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "A chaque fois que GameScript vous demande quelque chose après ce \e[97;45m # \e[0m, c'est cette commande ${code}read${reset} qui est utilisée."; restore=$(expr $restore + 1) ;&
22) echo -n 22 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen ""; restore=$(expr $restore + 1) ;&
23) echo -n 23 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Mais il est aussi possible de contrôler comment se comportera votre script en y ajoutant des ${code}conditions${reset}."; restore=$(expr $restore + 1) ;&
24) echo -n 24 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "C'est à dire qu'au lieu d'executer toutes vos commandes les unes après les autres, vous pouvez y intégrer de la logique plus complexe avec ${code}if${reset}."; restore=$(expr $restore + 1) ;&
25) echo -n 25 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "GameScript par exemple, utilise régulièrement des ${code}if${reset} pour décider des commandes qui doivent être lancées et celles qui ne doivent pas l'être."; restore=$(expr $restore + 1) ;&
26) echo -n 26 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk_not_press_key justumen "Affichez le contenu du fichier 'if1'."; restore=$(expr $restore + 1) ;&
27) echo -n 27 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; answer_run "cat if1" justumen "Non"; restore=$(expr $restore + 1) ;&
28) echo -n 28 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Ici nous avons un exemple de l'utilisation de la commande ${code}if${reset} (l'anglais du mot 'si') en combinaison avec ${code}else${reset} (l'anglais de 'sinon')."; restore=$(expr $restore + 1) ;&
29) echo -n 29 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Ce script demandera à l'utilisateur la valeur de la variable 'X', si cette valeur est 1, le script affichera 'COURS', sinon le script affichera 'QUESTIONNAIRE'."; restore=$(expr $restore + 1) ;&
30) echo -n 30 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Tous les espaces que vous voyez dans ce fichier sont nécessaire pour le bon fonctionnement du ${code}if${reset}."; restore=$(expr $restore + 1) ;&
31) echo -n 31 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Notez également dans ce script l'importance des ${code};${reset}."; restore=$(expr $restore + 1) ;&
32) echo -n 32 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "D'une manière générale, vous l'avez surement remarqué mais le ${code};${reset} n'est utile que lorsque le code est sur une même ligne."; restore=$(expr $restore + 1) ;&
33) echo -n 33 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Vous pouvez avoir dans un script ${code}pwd${reset} sur la première ligne et ${code}ls${reset} sur la deuxième."; restore=$(expr $restore + 1) ;&
34) echo -n 34 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Mais si vous voulez avoir les deux sur la même ligne, il faudra faire ${code}pwd;ls${reset}."; restore=$(expr $restore + 1) ;&
35) echo -n 35 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk_not_press_key justumen "Affichez donc le contenu du fichier 'if2'."; restore=$(expr $restore + 1) ;&
36) echo -n 36 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; answer_run "cat if2" justumen "Non"; restore=$(expr $restore + 1) ;&
37) echo -n 37 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Le code du script 'if2' est équivalent au code du script 'if1', seul la présentation du code est différente."; restore=$(expr $restore + 1) ;&
38) echo -n 38 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Ici les ${code};${reset} ont été remplacés par une mise à la ligne."; restore=$(expr $restore + 1) ;&
39) echo -n 39 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Comme pour les commandes, les espaces peuvent être utilisés pour présenter votre code différemment, par exemple pour le rendre plus lisible."; restore=$(expr $restore + 1) ;&
40) echo -n 40 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Traditionnelement, des tabulations ou plusieurs espaces sont ajoutés au début d'une ligne quand le code est d'un autre niveau."; restore=$(expr $restore + 1) ;&
41) echo -n 41 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "On appelle cette présentation un style d'indentation, l'${voc}indentation${reset} étant ce décalage en début de ligne."; restore=$(expr $restore + 1) ;&
42) echo -n 42 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk_not_press_key justumen "Affichez donc le contenu du fichier 'if3'."; restore=$(expr $restore + 1) ;&
43) echo -n 43 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; answer_run "cat if3" justumen "Non"; restore=$(expr $restore + 1) ;&
44) echo -n 44 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Ici par exemple, il est très facile de voir le ${voc}bloc de code${reset} à l'intérieur du ${code}if${reset} et celui à l'intérieur du ${code}else${reset}."; restore=$(expr $restore + 1) ;&
45) echo -n 45 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen ""; restore=$(expr $restore + 1) ;&
46) echo -n 46 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Si vous n'avez pas besoin, le ${code}else${reset} dans votre script n'est pas obligatoire."; restore=$(expr $restore + 1) ;&
47) echo -n 47 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk_not_press_key justumen "Affichez donc le contenu du fichier 'if4'."; restore=$(expr $restore + 1) ;&
48) echo -n 48 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; answer_run "cat if4" justumen "Non"; restore=$(expr $restore + 1) ;&
49) echo -n 49 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Le mot ${code}fi${reset} représente la fin du ${code}if${reset}, après ce ${code}fi${reset} le script continue à s'executer normalement ligne par ligne."; restore=$(expr $restore + 1) ;&
50) echo -n 50 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "C'est à dire qu'ici, quel que soit la valeur donnée à 'X' la commande 'echo TEXTE' se lancera."; restore=$(expr $restore + 1) ;&
51) echo -n 51 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "L'absence d'espaces en début de ligne nous permet de rapidement comprendre que cette ligne de code n'est pas dépendant d'un ${code}if${reset}."; restore=$(expr $restore + 1) ;&
52) echo -n 52 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Mais attention, ces ${voc}indentations${reset} ne sont pas obligatoires : c'est un choix esthétique qui revient au créateur du script."; restore=$(expr $restore + 1) ;&
53) echo -n 53 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Je vous recommande cependant d'utiliser ce ${voc}style d'indentation${reset} pour que votre script soit plus facilement compréhensible."; restore=$(expr $restore + 1) ;&
54) echo -n 54 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen ""; restore=$(expr $restore + 1) ;&
55) echo -n 55 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Nous avons donc vu que ${code}[ \$X -eq 5 ]${reset} est capable de vérifier si 'X' est égal à la valeur 5. (anglais ${code}eq${reset}ual)"; restore=$(expr $restore + 1) ;&
56) echo -n 56 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Mais vous pouvez aussi vérifier si 'X' n'est ${voc}pas${reset} égal à la valeur 5 avec : ${code}[ \$X -ne 5 ]${reset} (anglais ${code}n${reset}ot ${code}e${reset}qual)"; restore=$(expr $restore + 1) ;&
57) echo -n 57 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Vérifier si 'X' est supérieur à 5 avec : ${code}[ \$X -gt 5 ]${reset} (anglais ${code}g${reset}reater ${code}t${reset}han)"; restore=$(expr $restore + 1) ;&
58) echo -n 58 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Vérifier si 'X' est inférieur à 5 avec : ${code}[ \$X -lt 5 ]${reset} (anglais ${code}l${reset}ess ${code}t${reset}han)"; restore=$(expr $restore + 1) ;&
59) echo -n 59 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen ""; restore=$(expr $restore + 1) ;&
60) echo -n 60 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk_not_press_key justumen "Affichez donc le contenu du fichier 'if5'."; restore=$(expr $restore + 1) ;&
61) echo -n 61 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; answer_run "cat if5" justumen "Non"; restore=$(expr $restore + 1) ;&
62) echo -n 62 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen ""; restore=$(expr $restore + 1) ;&
63) echo -n 63 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen ""; restore=$(expr $restore + 1) ;&
64) echo -n 64 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "-eq difference with ="; restore=$(expr $restore + 1) ;&
65) echo -n 65 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen ""; restore=$(expr $restore + 1) ;&
66) echo -n 66 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Plusieurs niveaux if if if"; restore=$(expr $restore + 1) ;&
67) echo -n 67 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen ""; restore=$(expr $restore + 1) ;&
68) echo -n 68 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Nombreuses versions de conditions possibles, toutes identiques."; restore=$(expr $restore + 1) ;&
69) echo -n 69 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen ""; restore=$(expr $restore + 1) ;&
70) echo -n 70 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "Syntaxe que nous avons déjà vu :"; restore=$(expr $restore + 1) ;&
71) echo -n 71 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "[ $x == 111 ]; echo $?"; restore=$(expr $restore + 1) ;&
72) echo -n 72 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "[ $x == 11 ] && echo YES || echo NO"; restore=$(expr $restore + 1) ;&
73) echo -n 73 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen ""; restore=$(expr $restore + 1) ;&
74) echo -n 74 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen ""; restore=$(expr $restore + 1) ;&
75) echo -n 75 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen ""; restore=$(expr $restore + 1) ;&
76) echo -n 76 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "if [ "$(whoami)" != 'root' ]; then"; restore=$(expr $restore + 1) ;&
77) echo -n 77 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen ""; restore=$(expr $restore + 1) ;&
78) echo -n 78 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "if [ $# -eq 0 ]; then ;; fi"; restore=$(expr $restore + 1) ;&
79) echo -n 79 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "IF NO ARGUMENTS"; restore=$(expr $restore + 1) ;&
80) echo -n 80 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "if [ -z "$1" ]"; restore=$(expr $restore + 1) ;&
81) echo -n 81 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "if [ -f /var/log/messages ]"; restore=$(expr $restore + 1) ;&
82) echo -n 82 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen ""; restore=$(expr $restore + 1) ;&
83) echo -n 83 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "$0 $1 $2 $@ $# $_ $- “$@” $!"; restore=$(expr $restore + 1) ;&
84) echo -n 84 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen ""; restore=$(expr $restore + 1) ;&
85) echo -n 85 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "variable in script + variable in shell that launched bash"; restore=$(expr $restore + 1) ;&
86) echo -n 86 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "difference bash et ./ (nouvelle instance de bash)"; restore=$(expr $restore + 1) ;&
87) echo -n 87 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "bash ls"; restore=$(expr $restore + 1) ;&
88) echo -n 88 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "shebang"; restore=$(expr $restore + 1) ;&
89) echo -n 89 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen ""; restore=$(expr $restore + 1) ;&
90) echo -n 90 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen ""; restore=$(expr $restore + 1) ;&
91) echo -n 91 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "type source ---> built-in ----> man bash"; restore=$(expr $restore + 1) ;&
92) echo -n 92 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen ""; restore=$(expr $restore + 1) ;&
93) echo -n 93 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen ""; restore=$(expr $restore + 1) ;&
94) echo -n 94 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen ""; restore=$(expr $restore + 1) ;&
95) echo -n 95 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen ""; restore=$(expr $restore + 1) ;&
96) echo -n 96 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "ê"; restore=$(expr $restore + 1) ;&
97) echo -n 97 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "é"; restore=$(expr $restore + 1) ;&
98) echo -n 98 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "à"; restore=$(expr $restore + 1) ;&
99) echo -n 99 > $HOME/.GameScript/restore_bash11; echo -n $(pwd) > $HOME/.GameScript/restore_pwd_bash11; talk justumen "è"; restore=$(expr $restore + 1) ;&
esac
}
function clean(){ #in enter_chapter
rm $HOME/.GameScript/restore_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
rm $HOME/.GameScript/restore_pwd_$CHAPTER_NAME$CHAPTER_NUMBER 2> /dev/null
	rmdir $HOME/.GameScript_bash10 2> /dev/null
}

function start_quiz(){
  echo ""
  echo -e "\e[15;5;44m Bash 'Bourne Again SHell' : Questionnaire du chapitre 10 \e[0m"
  echo -e "- La réponse doit être la plus courte possible, une commande valide mais ajoutant des caractères inutiles ne fonctionnera pas."
  echo -e "Exemple : si la réponse est 'ls'. Les réponses 'ls .', 'ls ./' et 'ls ././' seront considérées comme fausses."
  answer_text_fr "" ""
  unlock "bash" "10" "aba2" "d414"
}


CHAPTER_NAME="bash"
CHAPTER_NUMBER="10"
LANGUAGE="fr"
SPEAKER="m1"

if [ ! "$1" == "MUTE" ]; then prepare_audio; fi

enter_chapter $CHAPTER_NAME $CHAPTER_NUMBER
