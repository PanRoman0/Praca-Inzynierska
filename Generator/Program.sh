#!/bin/bash

# Pobieranie aktualnej lokalizacji skryptu
script_dir=$(pwd)

# Funkcja generująca plik Macro do automatycznego aktualizowania modeli aktuatorów
create_file() {
	local file_name=$1
	local model_name=$2
	
	if [ ! -e "$file_name" ]; then
		cat <<EOL > $file_name
import sys
file_path = '$script_dir/$model_name.FCStd'
arg1 = sys.argv[2]
arg2 = sys.argv[3]

doc = FreeCAD.open(file_path)
sheet = doc.Spreadsheet

sheet.set('C3', arg1)
sheet.set('C4', arg2)

doc.recompute()
doc.save()

__objs__ = []
__objs__.append(FreeCAD.getDocument("$model_name").getObject("Sketch001"))
__objs__.append(FreeCAD.getDocument("$model_name").getObject("Sketch"))
import importSVG
if hasattr(importSVG, "exportOptions"):
    options = importSVG.exportOptions(u"$script_dir/$model_name.svg")
    importSVG.export(__objs__, u"$script_dir/$model_name.svg", options)
else:
    importSVG.export(__objs__, u"$script_dir/$model_name.svg")

del __objs__

exit()
EOL
		echo "Plik $file_name został wygenerowany."
	else
		echo "Plik $file_name już istnieje. Pomijanie..."
	fi
}


# Funkcja wyświetlająca użytkownikowi opcje wyboru modelu
choose_model(){
	while true; do
		echo "Wybierz model aktuatora:"
		echo "1) Model 1"
		echo "2) Model 2"
		echo "3) Model 3"
		#echo "4) Model 4"
		read -p "Wybierz opcję (1-3): " choose_model
		
		#Sprawdzenie czy wybór jest prawidłowy
		if [[ "$choose_model" =~ ^[1-3]$ ]]; then
			break
		else
			echo "Nieprawidłowy wybór! Proszę wybrać numer od 1 do 3."
		fi
	done
}

# Funkcja sprawdzająca czy podana liczba jest całkowita lub zmiennoprzecinkowa
is_number() {
	[[ $1 =~ ^-?[0-9]+([.][0.9]+)?$ ]]
}

# Funkcja pobierająca argumenty dla modelu 1
get_args_1() {
	while true; do
		read -p "Proszę wpisać średnicę palca pacjenta w milimetrach: " arg1
		if is_number "$arg1"; then
			break
		else
			echo "Wartość średnicy palca pacjenta musi być liczą! Spróbuj ponownie."
		fi
	done
	
	while true; do
		read -p "Proszę wpisać całkowitą długość palca pacjenta w milimetrach: " arg2
		if is_number "$arg2"; then
			break
		else
			echo "Wartość długości palca pacjenta musi być liczbą! Spróbuj ponownie."
		fi
	done
}

# Funkcja pobierająca argumenty dla modelu 2
get_args_2() {
	while true; do
		read -p "Proszę wpisać średnicę palca pacjenta w milimetrach: " arg1
		if is_number "$arg1"; then
			break
		else
			echo "Wartość średnicy palca pacjenta musi być liczą! Spróbuj ponownie."
		fi
	done
	
	while true; do
		read -p "Proszę wpisać całkowitą długość palca pacjenta w milimetrach: " arg2
		if is_number "$arg2"; then
			break
		else
			echo "Wartość długości palca pacjenta musi być liczbą! Spróbuj ponownie."
		fi
	done
}

# Funkcja pobierająca argumenty dla modelu 3
get_args_3() {
	while true; do
		read -p "Proszę wpisać średnicę palca pacjenta w milimetrach: " arg1
		if is_number "$arg1"; then
			break
		else
			echo "Wartość średnicy palca pacjenta musi być liczą! Spróbuj ponownie."
		fi
	done
	
	while true; do
		read -p "Proszę wpisać odległość od pierwszego więzadła do trzeciego więzadła palca pacjenta w milimetrach: " arg2
		if is_number "$arg2"; then
			break
		else
			echo "Wartość długości palca pacjenta musi być liczbą! Spróbuj ponownie."
		fi
	done
}

# Funkcja generująca obraz modelu aktuatora zależnie od wpisanych parametrów
generate_svg(){
	model_name="Model_${choose_model}.FCMacro"
	name_svg="Model_${choose_model}.svg"
	freecad "$model_name" "$arg1" "$arg2"
}

#---------------Główny skrypt-------------------

# Tworzenie plików Macro jeśli ich brak
create_file "Model_1.FCMacro" "Model_1"
create_file "Model_2.FCMacro" "Model_2"
create_file "Model_3.FCMacro" "Model_3"

# Zapytanie użytkownika o wybór modelu
choose_model

# Pobieranie argumentów w zależności od wybranego modelu
case $choose_model in
	1)
		get_args_1
		;;
	2)
		get_args_2
		;;
	3)
		get_args_3
		;;
esac
# Tworzenie obrazu SVG wybranego modelu
generate_svg

# Przygotowanie modelu do wycięcia na ploterze poprzez skrypt pythona
python3 Inkscape.py "$name_svg"

# Przejście do lokalizacji rozszerzenia wycinającego i przesłanie pliku SVG do plotera
cd /usr/share/inkscape/extensions/
python3 silhouette_multi.py --block=true $script_dir/$name_svg
