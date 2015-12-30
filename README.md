# StreamLauncher

[livestreamer](https://github.com/chrippa/livestreamer) permet de lancer un stream ou une vidéo dans un lecteur vidéo de bureau ([liste des lecteurs compatibles](http://docs.livestreamer.io/players.html)) pour éviter d'avoir à ouvrir votre navigateur ou simplement pour esquiver le bien connu et cancérogène Adobe Flash Player.

StreamLauncher fournit une interface graphique pour une utilisation basique de  ainsi que la possibilité de configurer une liste de streams/vidéos pour les lancer plus rapidement qu'avec la Command Line Interface de livestreamer.

Note: Ce logiciel a seulement été testé sur Windows 7 pour le moment.

# Installation

1. [Installez livestreamer](http://docs.livestreamer.io/install.html)
2. Si ce n'est pas fait, rajoutez-le à votre variable d'environnement **Path** :
  * Sous Windows 7 :
    * **Ordinateur** -> **Propriétés Systèmes** -> **Paramètres systèmes avancés** -> **Variables d'environnements**
    * Sélectionnez **Path**, **Modifier** (dans *Variables utilisateurs* ou dans *Variables systèmes* peu importe)
    * Ajoutez `C:\Program Files (x86)\Livestreamer` (chemin d'installation de livestreamer) à la fin
    * Fini ! vous pouvez quitter en faisant OK.
3. Si vous souhaitez participer au développement de StreamLauncher : [installez Shoes 3.2](http://shoesrb.com/downloads/) (Shoes contient Ruby donc pas la peine de l'installer avant).
4. Si vous souhaitez juste utiliser l'exécutable fourni :
  * il contient tout (le script .rb + l'installateur de Shoes 3.2.25) ;
  * commencez par télécharger le dossier (bouton "Download ZIP") et le dézipper ailleurs que dans votre dossier Temp (si vous voulez conserver votre liste de streams intacte) ;
  * lancez l'exécutable pour ouvrir StreamLauncher, notez que, si vous ne possédez pas Shoes (premier démarrage de l'éxecutable), il va s'installer, cela peut durer plusieurs minutes.
5. C'est bon, StreamLauncher devrait se lancer !

# TODO

- [ ] Ajouter un bouton pour lancer un chat (lancement de navigateur) en bas à droite
- [ ] Essayer de proposer anglais et français
- [ ] Passer tout le code en anglais
- [ ] Essayer d'éclaircir le code, supprimer les redondances si possible
- [ ] Ajouter la compatibilité avec Linux
- [ ] Créer des liens directs pour le téléchargement des seuls fichiers utiles pour un utilisateur final
- [ ] Compléter le guide avec des captures d'écran de l'interface ?
