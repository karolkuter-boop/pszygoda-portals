# Pszygoda Portals — Fabric 1.21.1

Izolowany wariant paczki Pszygoda przygotowany pod Immersive Portals. Zwykła paczka
`pszygoda-pack` pozostaje bez zmian. To osobny kanał Packwiz przeznaczony do nagrywania
Farlands i ręcznie budowanych scen z portalami.

Adres manifestu Packwiz:

`https://raw.githubusercontent.com/karolkuter-boop/pszygoda-portals/main/pack.toml`

## Zablokowany stos renderowania

- Immersive Portals `6.0.6-mc1.21.1`
- Flashback `0.39.7` z mostem snapshotu chunków Immersive Portals
- Iris `1.8.0+mc1.21.1`
- Sodium `0.6.0+mc1.21.1`
- Xaero's Minimap `26.4.2` — minimapa i waypointy, wyłącznie po stronie klienta
- `Photon-Pszygoda-1.4` jako domyślny shaderpack: fork Photona 1.3b z prawdziwymi
  chmurami Minecrafta Fancy, kwadratowym waniliowym słońcem i złotym finałem Krawędzi
- Krawędź `0.18.0` z przezroczystym trybem zwykłych replayów, portalowym protokołem v3,
  render-only Echo, oceanem pod `last_land`, anomaliami reżyserskimi i nową trasą Farlands
- Pszygoda `1.14.125`, która pomija lifecycle Truman Set na wewnętrznym serwerze powtórki
  Flashbacka i pozwala czysto zamknąć replay bez dostępu do nieistniejącego Overworldu

Immersive Portals 6.0.6 deklaruje twardą niezgodność z każdą wersją Iris inną niż 1.8.0 oraz
Sodium inną niż 0.6.0. Nie uruchamiaj `packwiz update --all` bez ponownego audytu tej trójki.

## Flashback i portale

Krawędź 0.12.0 wybiera raz, przy rozpoczęciu nagrania, jeden z dwóch trybów. Gdy nie ma
aktywnego ani globalnego portalu, działa **TRANSPARENT**: nie zapisuje snapshotów mostka,
nie przejmuje czyszczenia encji, nie filtruje natywnych pakietów IP i nie wymusza reloadu
rendererów. Jedynym adapterem jest odczyt prawdziwej mapy chunków IP dla natywnego snapshotu
Flashbacka. Dzięki temu instalacja IP nie powinna zmieniać zwykłego replaya bez portali.

Nagranie rozpoczęte z aktywnym portalem używa eksperymentalnego trybu **MANAGED v3**:
`begin/reset/end`, tokenu generacji, mapy wymiarów, liczników encji per wymiar i listy UUID
nagranych graczy. Rozbieżność chunków, encji, graczy albo aktywnego świata kończy transakcję
jawnym `FAIL`. Stare snapshoty v2 z zerem portali są ignorowane, aby natywny strumień
Flashbacka mógł otworzyć dawne zwykłe replaye best-effort. Most pozostaje opcjonalny:
Krawędź uruchamia się również bez Flashbacka i Immersive Portals.

Integracja odtwarzania Flashback–Immersive Portals ma obecnie status **eksperymentalny**.
Krawędź `0.18.0` i paczka `1.0.0-portals.14` zachowują naprawę crasha lokalnego ReplayServera
`Missing Dimension krawedz:podroz`: serwerowe śledzenie chunków i encji Immersive Portals
nie jest wykonywane ponownie podczas odtwarzania. Nie rozszerza to jeszcze gwarancji na
złożone replaye portalowe:
otwarcie replaya ani poprawne liczniki chunków nie są wystarczającym dowodem zgodności.

Twardy kontrakt dla następnego zatwierdzonego wydania jest następujący:

- nagranie rozpoczęte bez aktywnych portali, w którym podczas całej sesji żaden portal nie jest
  tworzony ani używany, ma korzystać z natywnej ścieżki Flashbacka;
- w takim nagraniu mostek IP nie może uruchamiać własnego snapshotu ani resetować encji;
- teren, nagrana postać, pozostałe encje, odtwarzanie ciągłe i seek muszą działać tak samo jak
  przy nieobecnym Immersive Portals.

Do czasu udokumentowanego PASS osobnej macierzy portalowej **nie uruchamiaj nagrywania
Flashbacka w scenie z aktywnym portalem ani nie twórz portalu w trakcie nagrania**. Replaye
z portalami, w tym zwykłymi i skalowanymi w jednym wymiarze, pozostają eksperymentalne.
Portale między wymiarami, animowane i wielokrotnie zagnieżdżone nie są objęte zakresem.
Portal utworzony w trakcie nagrania transparentnego nie przełącza trybu w połowie pliku;
operator dostaje jedno ostrzeżenie i powinien zatrzymać nagranie. Stary testowy replay portalowy
nie jest naprawiany wstecznie.

Nowa anomalia jest dostępna jako `/krawedz anomalia pekniecie`. Pierwsze wywołanie tworzy
dwustronny klaster czterech portali 3×4, drugie go usuwa, a `/krawedz anomalia stop` sprząta
portal i tickety chunków. Bez Immersive Portals literal `pekniecie` nie jest rejestrowany.

Krawędź 0.14.0 zawiera `/krawedz anomalia tekst`: wiadomości czatu, nicki w TAB-ie i nad
głowami graczy oraz tekst tabliczek rozpadają się wyłącznie w renderze klienta. Faza glitchu
zmienia się co 300 ms, czyli dwa razy szybciej niż w 0.13.0. Oryginalne
wiadomości, profile i NBT tabliczek pozostają nietknięte. `/krawedz anomalia kopiowanie`
przenosi każdą postawioną i zniszczoną pozycję bloku na tę samą lokalną współrzędną wszystkich
wczytanych chunków aktywnego wymiaru oraz chunków wczytanych później. Wyłączenie zatrzymuje
kolejkę i czyści wzorzec; kopie już zapisane w świecie pozostają.

Echo ma własną animację chodu liczoną z przesunięcia pozycji, więc działa również wtedy, gdy
serwerowy `limbAnimator` zapisuje same zera. Stare replaye z takim strumieniem dostają
deterministyczny fallback. Stan `ekwipunek`, `tekst` i `serca` trafia do snapshotów Flashbacka,
a wszystkie trzy efekty korzystają z przewijalnego czasu świata. Serwer replaya nie wykonuje
ponownie żadnej logiki anomalii; `woda`, `chunki`, `encje` i `kopiowanie` odtwarzają zapisane
pakiety i stan świata, a portal `pekniecie` nie jest usuwany jako osierocony przy wczytaniu.

## Zmiany trasy i anomalii w 0.18.0

- Granice wszystkich etapów mają dokładne komendy `...-granica`, a Stripelands i Fringelands
  zajmują poprawne miejsca oraz wartości filmowych współrzędnych.
- Normalny teren przed Farlands i teren bazowy Stripelands korzystają z waniliowej generacji;
  Farlands zaczynają się od dojrzałej geometrii bez drugiego, słabszego generatora na wejściu.
- Farlands mają naturalne potwory, Stripelands sporadyczne krowy, owce i świnie, a Fringelands
  sporadyczne owce. Flatlands otrzymały rzadkie małe jeziora z gliniasto-żwirowym dnem.
- `kopiowanie` pozostaje ograniczone do etapu aktywacji, a każdą anomalię można uruchomić
  globalnie albo dla nicku i selektora Minecrafta.
- `chunki` migoczą pięć razy na sekundę głównie w pierwszych dwóch pierścieniach wokół gracza;
  aktualny chunk gracza nigdy nie znika.
- Różdżka Freeze Entity zamraża wskazaną encję bez kolizji i teleportacji, a kolejne użycie
  bezpiecznie ją odmraża.

## Celowo usunięte z wariantu

- FFTV Shot Designer — nie jest potrzebny do bazowego nagrywania i montażu replayów Flashback.
- Bobby — oznaczony przez Immersive Portals jako poważnie niekompatybilny.
- Simple Voice Chat — niepotrzebny w tym profilu i zgłoszony jako potencjalne źródło ścinania
  dźwięku przy portalach.
- Vista i dostarczany dla niej Moonlight — ich serwerowe mixiny synchronizacji encji kolidują
  bezpośrednio z mixinem Immersive Portals i powodują crash przy pierwszych aktywnych chunkach.
- Voidstack — jego globalny stan atmosfery i własne operacje na framebufferze mogą przeciekać
  między równocześnie renderowanymi światami.
- Complementary Reimagined — jest na oficjalnej liście shaderów sprawiających problemy
  z renderowaniem Immersive Portals.
- VerityUrbex — był demonstracyjnym shaderem projektu i nie jest częścią profilu nagraniowego.

Kopie odzyskiwalne plików bez metadanych Packwiz są lokalnie w `_portals-retired/`; katalog jest
ignorowany przez Git i Packwiz, więc nie trafi do eksportu.

## Ustawienia bezpiecznego profilu

`config/immersive_portals.json` ogranicza rekurencję do dwóch warstw i maksymalnie 16 renderów
portali na klatkę. Iris startuje z `Photon-Pszygoda-1.4.zip`. W tym wariancie Photon nie
zastępuje nieba własnymi chmurami wolumetrycznymi: Iris wymusza waniliowe `clouds=fancy`,
a geometria chmur przechodzi przez osobny `gbuffers_clouds`. Pass usuwa podwójne cieniowanie
ścian (mnożniki kierunkowe Minecrafta nie są ponownie mnożone o kierunkowe światło Photona),
więc na bryłach nie powstają skokowe plamy jasności. Po wycięciu waniliowego kształtu ich
powierzchnie są zapisywane jako nieprzezroczyste, dlatego słońce i księżyc pozostają za
chmurami zamiast przebijać przez nie. To nadal prawdziwe chmury Minecrafta Fancy, nie opcja
`Blocky Clouds` Photona.

Opcje `VANILLA_SUN` i `VANILLA_MOON` są domyślnie włączone. Na niebie renderowane są
kwadratowe tekstury słońca oraz faz księżyca Minecrafta, a realistyczne proceduralne tarcze
Photona są wyłączone. Kolor światła, cienie i atmosfera Photona pozostają aktywne.

Tylko w `krawedz:podroz` współrzędna kamery od X=121800 do X=122200 płynnie miesza atmosferę
w pomarańczowo-złoty gradient finału. Pozycja pochodzi z dokładnych uniformów Iris, więc efekt
śledzi również freecam Flashbacka i nie zawija się co 30 000 bloków. Woda `last_land` i
`the_edge` pozostaje niebieska; złoty wygląd tafli pochodzi z nieba i odbić. Inne wymiary oraz
wcześniejsze etapy zachowują zwykły profil Photona.

TAA i Motion Blur są domyślnie wyłączone, ponieważ Immersive Portals nie renderuje poprawnie
efektów temporalnych, gdy portal znajduje się w kadrze. Pozostałe ustawienia Photona nadal
można swobodnie dopasowywać. To profil do nagrywek i normalnej gry, nie gwarancja 120 FPS
w scenie z wieloma widocznymi portalami.

Krawędź 0.12.0 generuje ciągły ocean pod całym overworldowym `last_land` i łączy go bez szwu
z `the_edge`. Już zapisane chunky zachowują starą pustkę do czasu kontrolowanej regeneracji;
stare replaye również nie dostają oceanu wstecznie. Migracja serwera wymaga zatrzymania,
pełnego backupu i osobnej zgody — sam update paczki nie usuwa żadnych chunków.

Immersive Portals musi znajdować się również na serwerze. Serwer Pszygoda Portals jest
synchronizowany z tym repozytorium; klient i serwer muszą mieć dokładnie tę samą wersję moda.

## Instalacja klienta

Najprościej zaimportować wydany plik `.mrpack`. Dla instancji aktualizowanej przez Packwiz
zaimportuj `Pszygoda-Portals-AutoUpdate-1.0.0-portals.14-r9.zip`. R9 nie polega na zawodnym,
pustym `$INST_JAVA`: uruchamia lokalny resolver, sprawdza Javę 21 wybraną przez Prism lub jego
zarządzany runtime, a dopiero potem odpala `packwiz-installer-bootstrap` z powyższym adresem.
Nie kopiuj komendy pre-launch ze starszych instancji R1–R3.

## Walidacja lokalna

```powershell
packwiz refresh
packwiz list
packwiz modrinth export --output Pszygoda-Portals-1.0.0-portals.14.mrpack
```

Po każdej zmianie stosu renderowania trzeba najpierw zaliczyć regresję bez portali: start
klienta, wejście do świata, nagranie własnej postaci, odtwarzanie ciągłe oraz wielokrotny seek
z shaderem wyłączonym i z Photonem. W logu takiego replaya mostek IP nie może się aktywować.
Zwykły i skalowany portal, tworzenie, usunięcie, ponowny spawn oraz widok przez portal stanowią
osobną macierz eksperymentalną i nie rozszerzają gwarancji bez jawnego PASS QA.
