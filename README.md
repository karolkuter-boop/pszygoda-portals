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
- `Photon-Pszygoda-1.3b` jako domyślny shaderpack: Photon 1.3b z prawdziwymi
  chmurami Minecrafta w trybie Fancy oraz profilem bezpiecznym dla portali
- Krawędź `0.10.3` z wyborem atmosfery według aktualnie renderowanego świata oraz pełnym mostem
  Flashback–Immersive Portals
- Pszygoda `1.14.125`, która pomija lifecycle Truman Set na wewnętrznym serwerze powtórki
  Flashbacka i pozwala czysto zamknąć replay bez dostępu do nieistniejącego Overworldu

Immersive Portals 6.0.6 deklaruje twardą niezgodność z każdą wersją Iris inną niż 1.8.0 oraz
Sodium inną niż 0.6.0. Nie uruchamiaj `packwiz update --all` bez ponownego audytu tej trójki.

## Flashback i portale

Immersive Portals przechowuje chunki klienta we własnej mapie, podczas gdy Flashback 0.39.x
buduje snapshot tylko z bieżącego świata vanilla. Krawędź 0.10.3 zapisuje mapy wymiarów,
wtórne światy i chunki, zwykłe encje, portale oraz portale globalne. Przy odtwarzaniu usuwa
niepełne pakiety preludium ReplayServera i odbudowuje stan IP w bezpiecznej kolejności.
Most jest klientowy i nie zmienia zachowania zwykłego klienta bez obu modów.

Test runtime na serwerze Farlands potwierdził nagranie dwóch światów, 625 zdalnych chunków,
5 portali i 88 zdalnych encji, otwarcie replaya, utworzenie wtórnego Netheru, seek przez zmianę
wymiaru oraz ciągłe odtworzenie przejścia Overworld–Nether. Powtórny test na Pszygodzie 1.14.125
potwierdził również czyste zamknięcie `ReplayServer` bez `TrumanRuntimeBridge.stop`,
`NullPointerException` i `Exception stopping the server`. Log końcowy nie zawiera odrzuconych
wymiarów ani wyjątków klienta przy Iris 1.8.0 i Sodium 0.6.0.

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
portali na klatkę. Iris startuje z `Photon-Pszygoda-1.3b.zip`. W tym wariancie Photon nie
zastępuje nieba własnymi chmurami wolumetrycznymi: Iris wymusza waniliowe `clouds=fancy`,
a geometria chmur przechodzi przez fallback `gbuffers_textured`. To są prawdziwe chmury
Minecrafta Fancy, nie opcja `Blocky Clouds` Photona.

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
packwiz modrinth export --output Pszygoda-Portals-1.0.0.mrpack
```

Po każdej zmianie stosu renderowania trzeba ponownie sprawdzić co najmniej: start klienta,
wejście do świata, widoczne chmury Minecrafta Fancy, portal Overworld–Nether, chmury widziane
przez portal, widok portalu w portalu, shader włączony i wyłączony oraz przejście do obu
wymiarów Krawędzi.
