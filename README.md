# Pszygoda Portals — Fabric 1.21.1

Izolowany wariant paczki Pszygoda przygotowany pod Immersive Portals. Zwykła paczka
`pszygoda-pack` pozostaje bez zmian. To osobny kanał Packwiz przeznaczony do nagrywania
Farlands i ręcznie budowanych scen z portalami.

Adres manifestu Packwiz:

`https://raw.githubusercontent.com/karolkuter-boop/pszygoda-portals/main/pack.toml`

## Zablokowany stos renderowania

- Immersive Portals `6.0.6-mc1.21.1`
- Iris `1.8.0+mc1.21.1`
- Sodium `0.6.0+mc1.21.1`
- VerityUrbex jako jedyny dostarczany shaderpack
- Krawędź `0.10.1` z wyborem atmosfery według aktualnie renderowanego świata

Immersive Portals 6.0.6 deklaruje twardą niezgodność z każdą wersją Iris inną niż 1.8.0 oraz
Sodium inną niż 0.6.0. Nie uruchamiaj `packwiz update --all` bez ponownego audytu tej trójki.

## Celowo usunięte z wariantu

- Flashback i zależny od niego FFTV Shot Designer — replay nie odtwarza poprawnie bloków
  renderowanych przez portale.
- Bobby — oznaczony przez Immersive Portals jako poważnie niekompatybilny.
- Simple Voice Chat — niepotrzebny w tym profilu i zgłoszony jako potencjalne źródło ścinania
  dźwięku przy portalach.
- Vista i dostarczany dla niej Moonlight — ich serwerowe mixiny synchronizacji encji kolidują
  bezpośrednio z mixinem Immersive Portals i powodują crash przy pierwszych aktywnych chunkach.
- Voidstack — jego globalny stan atmosfery i własne operacje na framebufferze mogą przeciekać
  między równocześnie renderowanymi światami.
- Complementary Reimagined i Photon Voidlands — pierwszy jest na oficjalnej liście
  niekompatybilnych shaderów, a oba używają efektów temporalnych ryzykownych przy wielu kamerach.

Kopie odzyskiwalne plików bez metadanych Packwiz są lokalnie w `_portals-retired/`; katalog jest
ignorowany przez Git i Packwiz, więc nie trafi do eksportu.

## Ustawienia bezpiecznego profilu

`config/immersive_portals.json` ogranicza rekurencję do dwóch warstw i maksymalnie 16 renderów
portali na klatkę. Iris startuje z `VerityUrbex.zip`. To profil do nagrywek i normalnej gry,
nie gwarancja 120 FPS w scenie z wieloma widocznymi portalami.

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
wejście do świata, portal Overworld–Nether, widok portalu w portalu, shader włączony i wyłączony
oraz przejście do obu wymiarów Krawędzi.
