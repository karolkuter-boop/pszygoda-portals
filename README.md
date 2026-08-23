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
- `Photon-Pszygoda-1.3c` jako domyślny shaderpack: Photon 1.3b z prawdziwymi
  chmurami Minecrafta Fancy, kwadratowym waniliowym słońcem oraz profilem bezpiecznym dla portali
- Krawędź `0.11.0` z protokołem snapshotu v2, zapisem portali tworzonych podczas nagrania
  oraz anomalią `pekniecie`
- Pszygoda `1.14.125`, która pomija lifecycle Truman Set na wewnętrznym serwerze powtórki
  Flashbacka i pozwala czysto zamknąć replay bez dostępu do nieistniejącego Overworldu

Immersive Portals 6.0.6 deklaruje twardą niezgodność z każdą wersją Iris inną niż 1.8.0 oraz
Sodium inną niż 0.6.0. Nie uruchamiaj `packwiz update --all` bez ponownego audytu tej trójki.

## Flashback i portale

Immersive Portals przechowuje chunki klienta we własnej mapie, podczas gdy Flashback 0.39.x
nie odtwarza samodzielnie kompletnego stanu IP. Krawędź 0.11.0 zapisuje transakcję snapshotu
`begin/reset/end`, mapę wymiarów, chunki wszystkich światów oraz portale tworzone i usuwane
już po rozpoczęciu nagrania. Przy odtwarzaniu odbudowuje światy i renderery w stałej kolejności,
odrzuca stare generacje oraz weryfikuje liczniki. Most pozostaje opcjonalny: Krawędź uruchamia
się również bez Flashbacka i Immersive Portals.

Macierz QA dla przyszłych nagrań zaliczono na Minecraft 1.21.1 z Flashbackiem 0.39.7 i IP 6.0.6:

- IP bez Sodium i Iris,
- IP z Sodium 0.6.0,
- IP, Sodium i Iris 1.8.0 przy wyłączonym shaderze,
- pełny profil z Photon-Pszygoda,
- ręczny portal o skali 2× w tym samym wymiarze.

W scenariuszu produkcyjnym replay rozpoczął się bez portalu, następnie anomalia utworzyła
dokładnie cztery portale, usunęła je i utworzyła ponownie. Ciągłe odtwarzanie oraz seek przed
spawnem, po spawnie, po usunięciu i po ponownym spawnie zachowały widoczny teren. Snapshoty
raportowały dwa światy i 625 chunków; test skalowany raportował jeden portal po seeku. Log nie
zawierał duplikatów, nieznanych wymiarów ani wyjątków kompatybilności.

Zakres gwarantowanego QA obejmuje portale zwykłe i skalowane w jednym wymiarze. Portale między
wymiarami, animowane i wielokrotnie zagnieżdżone nie są objęte tym wydaniem. Stare replaye
nagrane bez protokołu 0.11.0 nie są naprawiane wstecznie.

Nowa anomalia jest dostępna jako `/krawedz anomalia pekniecie`. Pierwsze wywołanie tworzy
dwustronny klaster czterech portali 3×4, drugie go usuwa, a `/krawedz anomalia stop` sprząta
portal i tickety chunków. Bez Immersive Portals literal `pekniecie` nie jest rejestrowany.

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
portali na klatkę. Iris startuje z `Photon-Pszygoda-1.3c.zip`. W tym wariancie Photon nie
zastępuje nieba własnymi chmurami wolumetrycznymi: Iris wymusza waniliowe `clouds=fancy`,
a geometria chmur przechodzi przez fallback `gbuffers_textured`. To są prawdziwe chmury
Minecrafta Fancy, nie opcja `Blocky Clouds` Photona.

Opcja `VANILLA_SUN` jest domyślnie włączona. Na niebie renderowana jest kwadratowa tekstura
słońca Minecrafta, a realistyczna proceduralna tarcza Photona jest wyłączona. Kolor światła,
cienie i atmosfera Photona pozostają aktywne.

TAA i Motion Blur są domyślnie wyłączone, ponieważ Immersive Portals nie renderuje poprawnie
efektów temporalnych, gdy portal znajduje się w kadrze. Pozostałe ustawienia Photona nadal
można swobodnie dopasowywać. To profil do nagrywek i normalnej gry, nie gwarancja 120 FPS
w scenie z wieloma widocznymi portalami.

Immersive Portals musi znajdować się również na serwerze. Serwer Pszygoda Portals jest
synchronizowany z tym repozytorium; klient i serwer muszą mieć dokładnie tę samą wersję moda.

## Instalacja klienta

Najprościej zaimportować wydany plik `.mrpack`. Dla instancji aktualizowanej przez Packwiz
ustaw powyższy adres `pack.toml` w komendzie pre-launch `packwiz-installer-bootstrap`.

## Walidacja lokalna

```powershell
packwiz refresh
packwiz list
packwiz modrinth export --output Pszygoda-Portals-1.0.0-portals.8.mrpack
```

Po każdej zmianie stosu renderowania trzeba ponownie sprawdzić co najmniej: start klienta,
wejście do świata, widoczne chmury Minecrafta Fancy i waniliowe słońce, zwykły oraz skalowany
portal w tym samym wymiarze, shader włączony i wyłączony, ciągłe odtwarzanie oraz seek przez
utworzenie, usunięcie i ponowne utworzenie portalu.
