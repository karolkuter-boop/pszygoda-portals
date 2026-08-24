PSZYGODA PORTALS - INSTANCJA PRISM Z AUTOMATYCZNA AKTUALIZACJA R8

1. Otworz Prism Launcher.
2. Kliknij Dodaj instancje -> Importuj.
3. Wskaz ten plik ZIP.
4. Upewnij sie, ze powstala instancja o nazwie Pszygoda Portals AutoUpdate R8.
5. Uruchom nowa instancje. Nie uruchamiaj starszej instancji Pszygoda Portals.

Przed kazdym startem profil pobiera aktualna wersje paczki z:
https://raw.githubusercontent.com/karolkuter-boop/pszygoda-portals/refs/heads/main/pack.toml

Instancja nie zawiera sciezki Javy nalezacej do komputera autora. Wlasny launcher
aktualizacji znajduje Jave 21 wybrana dla instancji, zarzadzana przez Prism,
zainstalowana razem z Prismem przenosnym albo dostepna przez JAVA_HOME/PATH.
Kazdy kandydat jest sprawdzany i inna wersja Javy nie zostanie uzyta. Pierwsze
uruchomienie pobierze mody i moze potrwac kilka minut. Wymagane jest legalne konto
Minecraft.

Jesli w komunikacie startowym widac cudza stala sciezke profilu Windows albo sama
fraze -jar bez programu Java przed nia, uruchomiona zostala starsza instancja. Ta wersja nazywa sie
AutoUpdate R8 i uruchamia plik packwiz-update.cmd zamiast pustego $INST_JAVA.

Gdy launcher nie znajdzie Javy 21, wybierz ja w ustawieniach instancji Prism albo
ustaw zmienna srodowiskowa PSZYGODA_JAVA na pelna sciezke do bin\java.exe.

Nie dodawaj recznie Bobby, Vista, Voidstack, Simple Voice Chat ani innych wersji
Iris lub Sodium. Xaero's Minimap jest juz w paczce jako mod kliencki. Ten profil ma wersje
przypiete pod Immersive Portals 6.0.6.

Flashback jest czescia paczki, ale gwarantowany tryb produkcyjny dotyczy obecnie
scen bez aktywnych portali. Nagrywanie rozpocznij dopiero po usunieciu wszystkich
portali i nie tworz portali w trakcie nagrania. Sceny wykorzystujace Immersive
Portals nagrywaj osobno, bez uruchomionego nagrywania Flashback, dopoki pelna
macierz zgodnosci portalowej nie przejdzie QA.

Domyslny Photon-Pszygoda 1.4 uzywa chmur Minecrafta Fancy i kwadratowego
waniliowego slonca. W finale Krawedzi niebo robi sie pomaranczowo-zlote, ale
woda pozostaje niebieska. TAA i Motion Blur sa wylaczone dla Immersive Portals.
