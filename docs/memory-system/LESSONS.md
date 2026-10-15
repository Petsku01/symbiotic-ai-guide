# LESSONS.md — production lessons from a live agent memory system

Kahdeksan oppia jotka syntyy vain kun järjestelmä pyörii 24/7 oikean käyttäjän kanssa.
Jokainen väite on todistettu tuotannossa — ei suunniteltu käytäntö.

## 1. Kaksi politiikkaa samassa komponentissa = aina drift

Kompressio-enginellä meillä oli triggeri (`should_compress_info` → "pakkaa") ja
oma cache-guard (`compress()` → "skipaa jos provider-cache tekee työn ja paine < 0.85").
Ne ristiriitaisivat täsmälleen silloin kun triggeri laukesi (paine 0,505 < 0,85):
host ei nähnyt skipin syytä → `attempts_exhausted`-luokitus → käyttäjä sai
"model may stop responding" -varoituksen vaikka API-kutsut onnistuivat (~50 % kapasiteetista).

**Sääntö:** kun komponentin sisäinen päättäjä sanoo "tee X", sen sisäinen guard ei saa
itsenäisesti kieltää X:tä — tai jos saa, syy on kuljettava ulos näkyvästi.
(Korjasimme configilla: pressure_override 0.85 → 0.49 = skip vain alle trigger-kynnyksen.)

## 2. Väärä fix-varianteista: verify on käyttäytymistä, ei lukemista

Ensiyrityksemme korjata guardia: nostaa cache-share-kynnys 0.8 → 0.98. Config-luku
"toimi" (engine näki 0.98:n). Mutta aamun tapauksessa share oli **0.9993** — se ylittää
*kaikki* kynnykset, eli fix ei olisi estänyt skipiä koskaan. Käyttäytymistesti
(aito compress(): aamu-data + matalapainetapaus) paljasti virheen minuutissa.

**Sääntö:** config-lukeminen läpi ≠ korjaus todennettu. Ajaa aito polku
tuotantodatalla ennen julistusta.

## 3. Offsite-backup ilman restore-testiä = ei varmistusta palautuksesta

Kaksi rekonstruktiovauriota (ollama_utils.py, dream.py) johtui siitä, että backup
ottaneen tiettyjä polkuja pois (workspace excluded → tools-moduulit katosivat).
Meillä oli E2E-SHA-identtinen salattu backup **kahdesta pilvestä** — ja silti
palautusharjoitus paljasti reikää.

**Sääntö:** restore-check = osa backup-ketjua. Testikohde: temp-hakemistoon,
SHA-verifioitava, jokaiselle tuotantoartefaktille (state.db, episoodikanta, tar-kerros).

## 4. Valvonta joka myös kirjoittaa = kilpailutaja

Ensimmäiset operator-yritykset yrittivät auttaa: "korjataan MEMORY.md-rakenne
health-ajossa". Sääntö käänsi: **valvoja ei kirjoita** (luku + raportti + exit-koodi).
Syy: (a) race-ikkuna kirjoituspöytien välillä (flock + CAS-puutokset),
(b) auto-repairi joka onnistuu 99 %:n = yksi 1 % -vaurio joka hävittää muistin.

## 5. "Entry = 1 rivi" säännön monirivitodiste

HOT-muistissa sääntö oli yksi rivi per entry (§-erottimien välissä). Kartoitus
löysi kaksi monirivistä lohkoa (rivit 39–40, 60–62) — kirjoittajat synkronoimatta
saman säännön. Operaattorin §-pair-tarkistus ei nappaa sedä (orpojen parien
lasku = vain viereiset erottiment).

**Sääntö:** kanoninen parseri + rakennetarkistus joka havaitsee poikkeamat —
ei vain erottimien laskemista.

## 6. Kartta ei ole identiteetti — jokaiselle mittarille as_of

Episoodikanta kasvoi 5992 → 5997 riviin **yhden inventointiajon aikana** (4 min).
"Totaalinen kartoitus" ilman aikaleimoja = epätosi tunnissa. Jokaiselle mittarille:
`as_of`: + SQL-kysely + evidence-skriptipolku.

## 7. Punatesti = vaurion simulointi, ei happy-path

Kolmenlaiset vauriot jokaiselle uudelle työkalulle: (a) avain puuttuu,
(b) snapshot tyhjä, (c) kohdehakemisto puuttuu. Punatestit löysivät:
nimilogiikkavirhe (zstd purkautui väärään nimeen → 2 CRIT heti),
combine-logiikan puutteen (ei-ositetut .enc-tiedostot jäävät dekryptaamatta).

## 8. Cross-review: eri mallit, eri reitit, samat todisteet

Kolme audit-lähestymistapaa löysivät eri virheet: Sol (gpt-6.1-sol) = mekaaninen
inventointi + 12 vanhentunutta dokumenttiväitettä; Kuu = live-mittaukset +
skriptipohjainen todenpito; Grok 4.6 (aito eri malliperhe) = adversarial:
laskentasääntöjen puutteet + "kartta ei kanna itseään". Jos kaikki kolme
samasta mallista — yhden blind spotin toisto. **Delegoinnit: pinna malli
(explicit provider/model) ellei eri mallia nimenomaan pyydetty.**