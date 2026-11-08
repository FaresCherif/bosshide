# Roadmap BossHide

## Vision

Un employé veut passer son après-midi aux toilettes. Il doit traverser l'open space sans se faire repérer par le patron, et franchir des obstacles (codes, clés, questions) que le patron multiplie d'un niveau à l'autre pour l'en empêcher.

- **Version finale** : 10 niveaux de difficulté croissante, avec score et chrono.
- **Échéance** : aucune.
- **Hors périmètre (pour l'instant)** : multijoueur, éditeur de niveaux, histoire à embranchements.

## État actuel

Fait :

- [x] Déplacement gauche/droite, caméra qui suit le joueur
- [x] Zone d'arrivée, message de réussite, restart avec R
- [x] Manager fixe : cycle face/dos, scan en trois tiers, game over si repéré
- [x] Flèche d'anticipation du scan
- [x] Bureaux : état « travail » qui rend le joueur invisible
- [x] Manager patrouilleur avec une vision courte vers l'avant

## Jalons

Chaque ligne correspond à une tâche du cycle de CLAUDE.md. Priorités : **P1** indispensable, **P2** souhaitable, **P3** bonus.

### M1 – Obstacles (les « tâches » du pitch)

| Statut | Prio | Fonctionnalité | Critère de fin | Dépend de |
|---|---|---|---|---|
| [x] | P1 | Porte verrouillée | Une porte bloque le passage tant qu'elle n'est pas ouverte | – |
| [x] | P1 | Clé à ramasser | Le joueur ramasse une clé avec E ; elle ouvre la porte associée | Porte |
| [x] | P1 | Code à lire | Un code de 4 chiffres tiré au hasard, sur un post-it : E l'affiche tant que le joueur reste devant (à retenir de tête) | – |
| [x] | P1 | Digicode | E ouvre un panneau de saisie au clavier (0-9, Retour arrière, Entrée, Échap) ; le bon code ouvre la porte. Le jeu continue pendant la saisie. Un mauvais code fait perdre 100 points et attire le manager qui patrouille (il va au digicode, attend 3 s, puis reprend sa ronde) | Porte, Code |
| [x] | P1 | Collègue et QCM | Un collègue bloque le joueur au passage et pose une question à 3 choix (touches 1-2-3) ; le joueur est protégé pendant la question. Une mauvaise réponse coûte 100 points et fait foncer le manager qui patrouille (2× sa vitesse) | – |
| [x] | P2 | Le joueur est vulnérable pendant une interaction | Le jeu continue pendant la saisie du digicode ; pendant la question du collègue, le joueur est protégé | Digicode, QCM |

### M2 – Boucle de jeu

| Statut | Prio | Fonctionnalité | Critère de fin | Dépend de |
|---|---|---|---|---|
| [x] | P1 | Chrono | Le temps du niveau s'affiche et s'arrête à l'arrivée | – |
| [x] | P1 | Score | 1000 − 10 par seconde, sans descendre sous 0, affiché seulement à l'arrivée ; pas de score au game over | Chrono |
| [x] | P1 | Données de niveau | Un niveau est décrit dans sa propre scène, chargée par un gestionnaire | – |
| [x] | P1 | Enchaînement des niveaux | Une réussite mène au niveau suivant ; un échec relance le même | Données de niveau |
| [ ] | P2 | Sauvegarde | Les niveaux débloqués et les meilleurs scores sont conservés | Score, Enchaînement |

### M3 – Contenu : les 10 niveaux

Progression indicative, à ajuster en jouant :

| Niveaux | Introduit |
|---|---|
| 1–2 | Manager fixe et bureaux (tutoriel) |
| 3 | Clé et porte |
| 4 | Manager patrouilleur |
| 5 | Code à lire et digicode |
| 6 | Collègue et QCM |
| 7–8 | Combinaisons, plusieurs managers |
| 9–10 | Tout à la fois, contraintes de temps serrées |

- [ ] P1 – Niveaux 1 à 10 jouables du début à la fin
- [ ] P2 – Courbe de difficulté validée par des tests manuels

### M4 – Habillage

- [x] P1 – Menu principal et sélection de niveau (déblocage limité à la session en attendant la sauvegarde)
- [ ] P1 – Écrans de fin de niveau (score, chrono, rejouer, suivant)
- [ ] P2 – Graphismes : joueur, managers, décor de bureau
- [ ] P2 – Sons : pas, alerte de détection, porte, réussite
- [ ] P3 – Musique

### M5 – Release

- [ ] P1 – Export et build jouable
- [ ] P2 – Polish : réglages, remappage des touches, pause

## Backlog d'idées

Idées non planifiées, à piocher quand un jalon se libère :

- **Photocopieuse** : maintenir E pendant quelques secondes pour récupérer un document indispensable.
- **Téléphone qui sonne** : il faut décrocher rapidement, sinon le patron se retourne.
- **Mot de passe d'ordinateur** : retrouver un indice dans le niveau pour déverrouiller un poste.
- **Café à apporter** au patron pour le distraire quelques secondes.
- **Collègue bavard** : il bloque le passage tant qu'on ne lui a pas répondu.
- **Cachettes** : plante, armoire, sous un bureau.
- **Caméras de surveillance** avec un balayage fixe.
- **Collègue délateur** qui prévient le patron s'il voit le joueur.
- **Jauge d'envie pressante** qui monte au fil du temps.
- **Saut ou plusieurs étages** (escaliers, ascenseur).

## Questions ouvertes

- **Plateforme cible** : PC seulement, ou aussi le web ?
- **Score** : bonus pour les tâches optionnelles ?
- **Graphismes** : assets faits main ou packs existants ?
