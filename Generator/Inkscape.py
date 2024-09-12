import sys
import subprocess

def inkscape_convert_to_stroke(input_file):
    # Otwarcie pliku SVG, zaznaczenie wszystkich obiektów i konwersja na kontury
    command = [
        "inkscape",
        input_file,
        "--batch-process",          # Uruchomienie w trybie batch
        "--actions", "select-all;object-stroke-to-path;export-filename:{};export-do".format(input_file) # Wybór wszystkich obiektów, konwersja na kontury, zapisanie pliku, wyjście
    ]

    try:
        # Uruchomienie komendy inkscape
        subprocess.run(command, check=True)
        print(f"Plik {input_file} został pomyślnie zmodyfikowany.")
    except subprocess.CalledProcessError as e:
        print(f"Wystąpił błąd podczas modyfikacji pliku: {e}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Podaj nazwę pliku svg jako argument.")
        sys.exit(1)
        
    # Nazwa pliku SVG do modyfikacji
    file_name = sys.argv[1]
    inkscape_convert_to_stroke(file_name)

