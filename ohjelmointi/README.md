# VS Code opiskelukäyttöön (Windows)

Yksi PowerShell-skripti, joka laittaa VS Coden järkevään kuntoon pienellä vaivalla:
asentaa puuttuvat ohjelmat ja laajennukset, kirjoittaa perusasetukset ja laittaa
automaattiset päivitykset päälle. Se toimii myös silloin, kun sinulla on jo VS Code
asennettuna: se ei koske siihen, mitä sinulla jo on, ja varmuuskopioi asetukset ennen muutoksia.

Skriptin voi ajaa uudelleen milloin tahansa. Se lisää aina vain puuttuvat asiat.

## Pikaohje

Avaa PowerShell (Windows-näppäin, kirjoita `PowerShell`, Enter) ja aja nämä rivit samassa ikkunassa:

```powershell
cd $env:USERPROFILE\Downloads
$u = "[[https://raw.githubusercontent.com/KAYTTAJA/vscode-setup/main/vscode-setup.ps1](https://github.com/peltomi/seamk/blob/8b792234d8469768c7c62cb9c2f93dd4e6afb8af/ohjelmointi/vscode-setup.ps1)](https://github.com/peltomi/seamk/blob/8b792234d8469768c7c62cb9c2f93dd4e6afb8af/ohjelmointi/vscode-setup.ps1)"
Invoke-WebRequest -UseBasicParsing -Uri $u -OutFile vscode-setup.ps1
notepad vscode-setup.ps1
powershell -ExecutionPolicy Bypass -File .\vscode-setup.ps1
```

1. Ensimmäinen rivi siirtyy Lataukset-kansioon, toinen kertoo mistä skripti haetaan ja kolmas lataa sen.
2. Neljäs avaa sen Muistiossa, jotta voit **lukea sen ennen ajoa** (sulje Muistio, kun olet valmis).
3. Viides ajaa sen. Vastaa kysymyksiin `K` (kyllä) tai `e` (ei). Enter yksinään valitsee oletuksen.

## Moduulit

Skripti kysyy, mitä käytät. Voit valita useamman (esim. `1,3`).

| # | Moduuli | Laajennukset | Asetukset |
|---|---|---|---|
| 1 | **python** | Python, Pylance, Ruff | Ruff muotoilee ja järjestää importit, kun painat Ctrl+S |
| 2 | **automaatio** | YAML, Ansible, Remote-SSH, Remote-WSL | YAML 2 välilyöntiä, välilyönnit näkyviin, playbook-tunnistus |
| 3 | **muistiinpanot** | Markdown All in One, suomen oikoluku | Rivitys päälle, oikoluku fi + en |

Kaikille tulee lisäksi **Error Lens** ja perusasetukset (automaattitallennus, ei minimapia,
ei tervetulosivua, telemetria pois).

> **Ansible ja Windows:** Ansible ei aja natiivisti Windowsilla. Käytä sitä WSL:n (Windows Subsystem
> for Linux) kautta: `wsl --install` PowerShellissä, ja avaa kansio VS Codessa komennolla
> **WSL: Connect to WSL**.

## Valinnat (ei-interaktiivinen ajo)

```powershell
powershell -ExecutionPolicy Bypass -File .\vscode-setup.ps1 -Modules python,muistiinpanot -Yes
```

| Valitsin | Mitä tekee |
|---|---|
| `-Modules a,b` | Valitsee moduulit kysymättä (python, automaatio, muistiinpanot) |
| `-Yes` | Vastaa kysymyksiin oletuksella (ilman `-Modules`: python; asetukset: yhdistä) |
| `-NoApps` | Ei asenna VS Codea, Pythonia tai Gitiä, vain laajennukset ja asetukset |
| `-SettingsMode merge\|replace\|keep` | Yhdistä (oletus), korvaa tai älä muuta (ehdotus talletetaan viereen) |
| `-AutoUpdateTask` | Luo viikoittaisen päivitystehtävän kysymättä |

## Jos sinulla on jo VS Code

- **Ohjelmat:** jo asennettua VS Codea, Pythonia (3.9 tai uudempi) ja Gitiä ei asenneta uudelleen.
- **Laajennukset:** vain puuttuvat asennetaan. Mitään ei poisteta.
- **Asetukset:** jos `settings.json` on jo olemassa, **tehdään aina varmuuskopio**
  (`settings.json.bak-päivämäärä` samaan kansioon). Sitten valitset:
  1. **Yhdistä (suositus):** lisätään vain puuttuvat asetukset. Sinun omat arvosi säilyvät, ja skripti
     kertoo, mitkä niistä poikkesivat ehdotuksesta. Yhdistäminen poistaa kommentit tiedostosta
     (ne ovat varmuuskopiossa).
  2. **Korvaa kokonaan:** vanhat asetukset korvataan uusilla.
  3. **Älä muuta:** ehdotus talletetaan tiedostoon `settings.suositus.json`, ja voit poimia siitä itse.
- Jos `settings.json` ei ole luettavissa automaattisesti (rikkinäinen JSON), tiedostoa ei muuteta.
  Ehdotus talletetaan viereen.

Asetuskansio on `%APPDATA%\Code\User`.

## Automaattiset päivitykset

- **VS Code ja laajennukset** päivittävät itsensä. Skripti laittaa asetukset varmuuden vuoksi päälle:
  `update.mode: default`, `extensions.autoUpdate: true`, `extensions.autoCheckUpdates: true`.
- **Valinnainen viikkotehtävä** päivittää lisäksi VS Coden, Gitin ja Pythonin (`winget upgrade`)
  maanantaisin klo 10.17, tai heti kun kone on seuraavan kerran päällä. Python päivittyy vain
  saman version sisällä (esim. 3.13.x), joten vanhat `.venv`-ympäristöt eivät hajoa.
  - Loki: `%LOCALAPPDATA%\vscode-setup\update.log`
  - Tehtävän poisto: `Unregister-ScheduledTask -TaskName "VSCode-opiskelu-paivitys" -Confirm:$false`

## Mitä skripti EI tee

- Ei poista mitään laajennuksia tai ohjelmia.
- Ei muuta muuta kuin: VS Coden asetukset, laajennukset, PowerShell-skriptien suoritusoikeus
  (vain jos kysyt ja vastaat kyllä, vain sinun käyttäjällesi) ja halutessasi päivitystehtävä.
- Ei laita Windowsin Python-pikakuvakkeita pois päältä. Tee se käsin:
  Asetukset > Sovellukset > Lisäasetukset > Sovellusten suoritusaliakset > laita pois `python.exe` ja `python3.exe`.

## Turvallisuus

Älä aja skriptejä, joita et ole lukenut. Tämä skripti on tavallista tekstiä, ja sen voi lukea Muistiossa
ennen ajoa (pikaohjeen kolmas rivi). Tarkista aina, että osoite on se, jonka sait ryhmältäsi.
Lue myös: `-ExecutionPolicy Bypass` ohittaa PowerShellin rajoituksen vain tälle yhdelle ajolle.

Loki ajoista: `%LOCALAPPDATA%\vscode-setup\setup.log`.

## Ongelmatilanteet

| Ongelma | Ratkaisu |
|---|---|
| `winget` puuttuu | Päivitä *App Installer* Microsoft Storesta, tai aja skripti valitsimella `-NoApps` ja asenna ohjelmat käsin |
| `code` ei löydy | Sulje PowerShell, avaa uusi ja aja skripti uudelleen |
| `running scripts is disabled` skriptiä ajettaessa | Käytä pikaohjeen komentoa tarkalleen (`-ExecutionPolicy Bypass`) |
| Koulun tai työnantajan kone estää asennuksen | Kysy IT-tuelta, tai käytä VS Coden ZIP-versiota (code.visualstudio.com) ja aja skripti `-NoApps`-valitsimella |
| Asetukset eivät muuttuneet | Katso `%APPDATA%\Code\User\settings.suositus.json` ja kopioi tarvittavat rivit käsin |

Versio: 2.0
