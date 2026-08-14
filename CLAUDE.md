# Tree4All — Contexte du projet

> Ce fichier est chargé automatiquement par Claude Code à l'ouverture d'une session dans ce dossier. Il résume tout ce qu'il faut savoir pour reprendre le travail sans repartir de zéro. Mets-le à jour à chaque évolution notable (nouvelle fonctionnalité, décision, correctif important).

## Le projet en une phrase

Application mobile (Flutter, Android + iOS) qui aide les gens en France et en Belgique à trouver **légalement** où planter des arbres/arbustes/fleurs/légumes, avec un système de rangs inspiré d'arbres légendaires, et une couche annexe de **lieux légendaires** (mégalithes, sites païens, histoire de la sorcellerie) à visiter.

Direction artistique : fantasy médiéval / magie de la nature — mages, grimoire, pousses de vie. Palette violet arcane + vert forêt + or + parchemin. Polices Cinzel (titres) / EB Garamond (corps) / système (UI).

## Comment on travaille ensemble

- L'utilisateur (Mathieu, pseudo GitHub `L0KImb`) **n'a aucune connaissance technique** — expliquer simplement, ne pas présumer de vocabulaire dev.
- Préférence explicite : **"tu fais et tu me montres"** — travailler en autonomie maximale, peu de questions, livrer des résultats concrets (APK, captures, liens) plutôt que des plans.
- Quand un bug est signalé, **toujours vérifier réellement avant de dire que c'est corrigé** (on s'est fait avoir une fois : un fix "logique" livré sans test sur appareil réel s'est révélé insuffisant à vérifier — depuis, tester sur émulateur Android avant de livrer un correctif carte/permissions).
- Ne jamais inventer de données (zones, lieux, légendes, sources) — toujours rechercher et citer une source réelle. Si rien de fiable n'est trouvé, le dire explicitement plutôt que d'improviser.

## État actuel (14 août 2026)

- ✅ App Flutter réelle et fonctionnelle dans `app/` — build APK Android release OK, testée sur émulateur.
- ✅ 3324 zones réelles chargées depuis de vraies API/open data (voir détail plus bas).
- ✅ 28 lieux légendaires réels et documentés (mégalithes, sorcellerie, folklore, sites païens).
- ✅ Système de rangs/XP, grimoire de plantation, catalogue de 18 espèces avec sources de graines.
- ✅ Outil de zonage en direct (Géoportail de l'Urbanisme + API nature IGN) — fonctionne partout en France.
- ✅ Dépôt GitHub public : **https://github.com/L0KImb/tree4all**
- ✅ Routine cloud de veille mensuelle active (1er de chaque mois, écrit un rapport dans `veille/` — jamais de modif auto des données).
- ❌ Pas de build iOS (besoin d'un Mac ou d'un CI cloud type Codemagic).
- ❌ Pas de comptes développeur Apple/Google (à faire par l'utilisateur lui-même, hors de portée de l'assistant : comptes + paiement).
- ❌ Barre de recherche visuelle mais pas encore branchée à un géocodeur.
- ❌ Pas de backend — les données sont figées au moment du build (voir "Prochaines étapes").

## Structure du dépôt

```
TREE4ALL/
├── CLAUDE.md              ← ce fichier
├── prototype-web/         ← prototype HTML/JS de validation de la DA (avant l'app réelle, gardé comme référence de design, plus maintenu activement)
├── veille/                ← rapports mensuels de la routine cloud (créé par la routine, pas par nous)
└── app/                   ← LA vraie application Flutter
    ├── assets/data/       ← zones.json, especes.json, rangs.json, sources-graines.json, lieux-legendaires.json
    ├── assets/fonts/      ← Cinzel-Bold, CinzelDecorative-Bold, EBGaramond-Regular/Italic (embarquées en local, PAS de google_fonts)
    └── lib/
        ├── models/        ← Zone, Species, Rank, Plantation, SeedSource, LegendaryPlace
        ├── state/         ← Catalog (charge les JSON une fois), PlayerState (XP/rangs/visites, persisté via SharedPreferences)
        ├── services/       ← GpuService (zonage PLU + parcs nationaux/Natura2000/ZNIEFF en direct, API IGN gratuite sans clé)
        ├── screens/       ← MapScreen (écran unique, tout se passe ici + des bottom sheets)
        ├── sheets/        ← ZoneSheet, GrimoireSheet, AddPlantationSheet, LevelUpSheet, LegendaryPlaceSheet
        ├── theme/         ← AppTheme (couleurs, typographie)
        └── widgets/       ← RankBadge, SpeciesCard
```

## Couverture des données (zones.json, 3324 entrées)

| Source | Territoire | Zones | Type |
|---|---|---|---|
| opendata.paris.fr (permis de végétaliser) | Paris | 1680 | permis |
| data.ampmetropole.fr (espaces publics) | Marseille + 92 communes AMP | 1307 | naturelle |
| ONF geo-onf.opendata.arcgis.com | Bouches-du-Rhône (forêts) | 122 | naturelle |
| data.seineouest.fr (Jardiner ma ville) | GPSO (Boulogne-Billancourt, Issy, Meudon...) | 89 | permis |
| opendata.brussels.be (potagers collectifs) | Bruxelles | 30 | association |
| geoservices.wallonie.be (CONSNAT) | Province de Liège | 27 | naturelle |
| odwb.be (SGIB) | Liège + communes limitrophes | 26 | naturelle |
| opendata.liege.be (espaces verts) | Liège | 25 | naturelle |
| geoservices.wallonie.be (Natura 2000) | Province de Liège | 16 | naturelle |
| data.gouv.fr (Parc national des Calanques) | Marseille/Cassis | 2 | naturelle |

**Aucune donnée ouverte de permis citoyens trouvée** pour Marseille-ville, Bruxelles-ville, Liège-ville malgré recherche dédiée (dispositifs existants mais en formulaire papier). Compensé par le zonage naturel réel + l'outil de vérification en direct (fonctionne nationalement en France via `apicarto.ign.fr`).

`lieux-legendaires.json` (28 entrées, catégories `megalithe`/`sorcellerie`/`folklore`/`paien`) : liste curée à la main à partir de recherches sourcées (Wikipédia, Base Mérimée, travaux universitaires UMons) — pas d'API unifiée pour ce contenu, donc pas de pipeline de mise à jour automatique dessus (contrairement à `zones.json`).

## Historique des décisions clés

1. **Prototype web d'abord** (HTML/CSS/JS, Leaflet) pour valider vite la DA fantasy médiéval avant d'investir dans du code Flutter. Gardé dans `prototype-web/` comme référence.
2. **Flutter choisi** pour un seul code Android/iOS, gratuit, bon pour un design animé soigné.
3. **Pas de backend pour l'instant** — toutes les données sont embarquées en assets JSON au moment du build. Simple, gratuit, marche hors-ligne. Limite : une donnée qui change côté ville n'est visible qu'au prochain build.
4. **GitHub public choisi** (pas privé) pour éviter d'avoir à gérer une authentification pour la routine cloud de veille — aucune donnée sensible dans le repo de toute façon.
5. **google_fonts retiré** au profit de polices embarquées en local (`assets/fonts/`) — google_fonts téléchargeait au runtime et échouait silencieusement sans connexion, ce qui a contribué à une confusion lors du bug de la carte.
6. **Zonage GPU/nature comme complément honnête** là où aucune donnée de zone n'existe (ex. Marseille intra-muros, Liège-ville) plutôt que d'inventer des zones fictives.

## Bug important résolu (leçon à retenir)

Le tout premier APK livré avait une carte qui ne s'affichait pas sur un vrai téléphone. Cause : **`AndroidManifest.xml` n'avait aucune permission réseau déclarée** (`android.permission.INTERNET` manquante) — Android bloque silencieusement tous les sockets sans elle. `flutter analyze` et `flutter build` ne détectent PAS ce genre de problème (c'est un problème runtime, pas de compilation). **Depuis : toujours tester sur émulateur Android réel avant de livrer un correctif touchant au réseau/permissions/manifeste**, pas seulement `flutter analyze`/`flutter build`.

## Infrastructure de dev (sur cette machine Windows)

- **Flutter SDK** : `C:\Users\33617\flutter` (ajouté au PATH utilisateur)
- **Android SDK** : `C:\Users\33617\Android\sdk` (`ANDROID_HOME`/`ANDROID_SDK_ROOT` définis)
- **JDK** : `C:\Program Files\Microsoft\jdk-17.0.20.8-hotspot` — **il faut `JAVA_HOME` pointé dessus** pour toute commande Gradle/sdkmanager/avdmanager (le Java système par défaut est trop ancien, v1.8).
- Un AVD de test (`tree4all_test`, Android 15/x86_64) a été créé pour la vérification sur émulateur ; peut être relancé avec `emulator -avd tree4all_test -no-window -gpu swiftshader_indirect` (headless, pas d'affichage GUI dans cet environnement).
- Build : `flutter build apk --release` depuis `app/` (avec `JAVA_HOME` + PATH Flutter/platform-tools exportés).

### Pièges Windows/Git Bash rencontrés
- Les chemins style `/c/Users/...` (Git Bash) plantent quand ils sont passés à `node`/des outils Windows natifs — utiliser `C:/Users/...` dans ces cas.
- `adb shell screencap /sdcard/...` échoue si MSYS réécrit le chemin POSIX — préfixer avec `MSYS_NO_PATHCONV=1`.
- Un alias `python`/`python3` sur cette machine ouvre un stub Windows Store qui pollue stdout — éviter, utiliser `node` pour les scripts ad hoc.

## Prochaines étapes possibles (non priorisées, à discuter avec l'utilisateur)

- Géocodage réel pour la barre de recherche.
- Petit backend/fonction serverless pour rafraîchir `zones.json` sans republier l'app.
- Étendre la couverture (Rennes, Avignon déjà identifiés dans la recherche initiale mais pas encore intégrés).
- Signalement citoyen de nouvelles zones (avec modération) — idée v2.
- Build iOS + comptes développeur + publication stores — décision et action de l'utilisateur.

## Liens

- Dépôt : https://github.com/L0KImb/tree4all
- Routine de veille mensuelle : https://claude.ai/code/routines/trig_01Q2NQQgxz5X66SjYUgU8Bei
