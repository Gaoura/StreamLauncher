class Stream
  def initialize(nom, url_stream, url_chat)
    @nom = nom
    @url_stream = url_stream
    @url_chat = url_chat
  end
  attr_accessor :nom, :url_stream, :url_chat
end

Shoes.app title: "StreamLauncher, GUI for livestreamer",
          width: 920,
          height: 400,
          resizable: false do

  background slategray


  stream1 = Stream.new("Zerator", "", "http://www.twitch.tv/zerator/chat?popout=")
  stream2 = Stream.new("Corobizar", "www.twitch.tv/baramout", "http://corobizar.com/stand-alone-chat.php")
  stream3 = Stream.new("machin daiy", "http://games.dailymotion.com/live/x3ixah7", "http://corobizar.com/stand-alone-chat.php")
  stream4 = Stream.new("Mira truc", "http://www.twitch.tv/MilleniumTVLoL", "http://www.twitch.tv/zerator/chat?popout=")
  liste_streams = [stream1, stream2, stream3, stream4]

  nom_stream = ""
  qualite_select = ""
  adresse_stream = ""
  adresse_chat = ""

  # chargement éventuel de la serialization la liste des streams
  if File.exists?("streams.slgl")
    File.open("streams.slgl") do |f|
      liste_streams = Marshal.load(f)
    end
  end

  # on récupère la liste des noms de streams
  liste_noms = liste_streams.collect do |element|
    element.nom
  end
  # tri de la liste sans tenir compte de la casse
  liste_noms.sort! do |a,b|
    a.casecmp(b)
  end

=begin
/////////////////////////////////////////////////////////////////////////////////////////////

            ########  #######  ########      ######  ##        #######  ########
               ##    ##     ## ##     ##    ##    ## ##       ##     ##    ##
               ##    ##     ## ##     ##    ##       ##       ##     ##    ##
               ##    ##     ## ########      ######  ##       ##     ##    ##
               ##    ##     ## ##                 ## ##       ##     ##    ##
               ##    ##     ## ##           ##    ## ##       ##     ##    ##
               ##     #######  ##            ######  ########  #######     ##

/////////////////////////////////////////////////////////////////////////////////////////////
=end

  # bande supérieure
  flow margin: 10 do
    # colonne de gauche
    stack width: 300 do
      para "Liste des streams enregistrés :"
      @liste_streams_enregistres = list_box items: liste_noms, width: 275
    end

    # colonne centrale
    stack width: 300 do
      @b1 = button "Qualités disponibles ?", width: 275, margin_bottom: 3
      @b2 = button "Lancer ce stream", width: 275, margin_bottom: 3
      @b3 = button "Lancer le chat du stream", width: 275
    end

    # colonne de droite cachée par défaut
    @qualite_error = stack width: 300, hidden: true do
      @message_qualite = para ""
      @liste_qualites = list_box
    end
  end


=begin
/////////////////////////////////////////////////////////////////////////////////////////////

    ########      ######         ######## ##     ## ######## ##    ## ########  ######
       ##        ##    ##        ##       ##     ## ##       ###   ##    ##    ##    ##
       ##        ##              ##       ##     ## ##       ####  ##    ##    ##
       ##         ######         ######   ##     ## ######   ## ## ##    ##     ######
       ##              ##        ##        ##   ##  ##       ##  ####    ##          ##
       ##    ### ##    ## ###    ##         ## ##   ##       ##   ###    ##    ##    ##
       ##    ###  ######  ###    ########    ###    ######## ##    ##    ##     ######

/////////////////////////////////////////////////////////////////////////////////////////////
=end

  # à chaque sélection d'un nom de stream
  @liste_streams_enregistres.change do |element|
    # on le retient dans une variable et
    nom_stream = element.text
    # on nettoie la colonne de droite
    @qualite_error.hide
    # et on efface la qualité pour ne pas perdre en cohérence
    qualite_select = ""

    # stockage des informations correspondant au nom du stream sélectionné
    liste_streams.each do |elem|
      if nom_stream == elem.nom
        adresse_stream = elem.url_stream
        adresse_chat = elem.url_chat
        break
      end
    end

    # mise à jour des champs de la boite d'ajout/modification de stream
    @nouv_nom.text = nom_stream
    @nouv_url_stream.text = adresse_stream
    @nouv_url_chat.text = adresse_chat
  end

  # recherche des qualités disponibles pour le stream sélectionné
  @b1.click do
    @message_erreur.replace("")
    @bord.hide
    @liste_qualites.remove

    # si aucun stream n'est sélectionné, on renvoie un message d'erreur
    if nom_stream.empty?
      @message_erreur.replace("Aucun stream sélectionné")
      @bord.show
    # sinon s'il n'y a pas d'adresse pour le stream sélectionné, on renvoie une erreur
    elsif adresse_stream.empty?
      @message_erreur.replace("Aucune adresse enregistré pour #{nom_stream}")
      @bord.show
    # sinon on peut tenter de lancer livestreamer
    else
      # on exécute la commande avec `...` pour rediriger l'affichage dans une variable
      @commande = `livestreamer "#{adresse_stream}"`

      # après cette commande, soit on a un message contenant "error"..
      if @commande.include?("error:")
        # dans ce cas on renvoie un message d'erreur
        @message_erreur.replace(["Impossible de vérifier la qualité, ",
                                  "le stream est hors-ligne ou l'adresse est erronée..."])
        # on affiche la bordure du bandeau d'erreur
        @bord.show
        @liste_qualites.remove
      # soit on a un message contenant les qualités
      else
        # on révèle la colonne de droite
        @qualite_error.show
        # r1 est l'expression regulière pour nettoyer en partie la liste des qualités
        r1 = Regexp.new('(\s\(\w+\)(\, )?)|(\, )')
        # on soustrait la première (et unique) occurrence de "...\nAvailable streams: "
        # ainsi que toutes les occurrences correspondantes à r1 par une espace
        @commande.sub!(/.+\sAvailable streams: /, '').gsub!(r1, ' ')
        # enfin il ne reste que des qualités séparés par une espace, on les split en un array
        @resultat = @commande.split(' ')

        # on affiche la liste déroulante des qualités disponibles
        @message_qualite.replace("Qualités disponibles pour\n#{nom_stream} :")
        # on supprime la précédente liste de qualités
        @liste_qualites.remove

        # la liste des qualités va contenir notre résultat traité
        @qualite_error.append do
          @liste_qualites = list_box items: @resultat, width: 150 do |element|
          # à chaque sélection d'un élément, on le retient dans une variable
            qualite_select = element.text
          end
        end
      end
    end
  end

  # lance le stream sélectionné
  @b2.click do
    @message_erreur.replace("")
    @bord.hide

    # si aucune qualité n'est sélectionné, on lancera par défaut avec la qualité "best"
    if qualite_select.empty?
      qualite_select = "best"
    end

    # si aucun stream n'est sélectionné, on envoie un message d'erreur
    if nom_stream.empty?
      @message_erreur.replace("Aucun stream sélectionné")
      @bord.show
    # sinon s'il n'y a pas d'adresse pour le stream sélectionné, on renvoie une erreur
    elsif adresse_stream.empty?
      @message_erreur.replace("Aucune adresse enregistré pour #{nom_stream}")
      @bord.show
    # sinon on peut lancer le stream
    else
      system("cmd.exe /c start livestreamer #{adresse_stream} #{qualite_select}")
    end
  end

  # lance le chat du stream sélectionné
  @b3.click do
    @message_erreur.replace("")
    @bord.hide

    # si aucun stream n'est sélectionné, on envoie un message d'erreur
    if nom_stream.empty?
      @message_erreur.replace("Aucun stream sélectionné")
      @bord.show
    # sinon si le stream ne possède pas d'adresse de chat, on envoie un message d'erreur
    elsif adresse_chat.empty?
      @message_erreur.replace("Aucun chat enregistré pour #{nom_stream}")
      @bord.show
    # sinon on peut lancer le chat dans le navigateur
    else
      system("start #{adresse_chat}")
    end
  end

=begin
/////////////////////////////////////////////////////////////////////////////////////////////

  ######## ########  ########   #######  ########      ######  ##        #######  ########
  ##       ##     ## ##     ## ##     ## ##     ##    ##    ## ##       ##     ##    ##
  ##       ##     ## ##     ## ##     ## ##     ##    ##       ##       ##     ##    ##
  ######   ########  ########  ##     ## ########      ######  ##       ##     ##    ##
  ##       ##   ##   ##   ##   ##     ## ##   ##            ## ##       ##     ##    ##
  ##       ##    ##  ##    ##  ##     ## ##    ##     ##    ## ##       ##     ##    ##
  ######## ##     ## ##     ##  #######  ##     ##     ######  ########  #######     ##

/////////////////////////////////////////////////////////////////////////////////////////////
=end

  # bandeau pour les messages d'erreur
  flow margin_bottom: 20, margin_top: 20, height: 101 do
    @bord = border red, strokewidth: 2, hidden: true
    @message_erreur = para "", align: "center", margin_bottom: 20, margin_top: 20
  end

=begin
/////////////////////////////////////////////////////////////////////////////////////////////

            ########   #######  ########     ######  ##        #######  ########
            ##     ## ##     ##    ##       ##    ## ##       ##     ##    ##
            ##     ## ##     ##    ##       ##       ##       ##     ##    ##
            ########  ##     ##    ##        ######  ##       ##     ##    ##
            ##     ## ##     ##    ##             ## ##       ##     ##    ##
            ##     ## ##     ##    ##       ##    ## ##       ##     ##    ##
            ########   #######     ##        ######  ########  #######     ##

/////////////////////////////////////////////////////////////////////////////////////////////
=end

  # bande inférieure
  flow margin: 10 do
    stack width: 500 do
      border black, strokewidth: 2, width: 475
      flow margin: 5 do
        @b_ajouter = button "Ajouter", width: 155
        @b_modifier = button "Modifier", width: 155
        @b_supprimer = button "Supprimer", width: 155
      end
      flow margin: 2 do
        para "Nom :"
        @nouv_nom = edit_line width: 340, right: 30
      end
      flow margin: 2 do
        para "URL du stream :"
        @nouv_url_stream = edit_line width: 340, right: 30
      end
      flow margin: 2 do
        para "URL du chat :"
        @nouv_url_chat = edit_line width: 340, right: 30
      end
    end
    stack width: 400, margin: 30 do
      @video = edit_line text: "http://www.", width: 340
      @b4 = button "Lancer ce stream", margin_left: 90
    end
  end

=begin
/////////////////////////////////////////////////////////////////////////////////////////////

    ########       ######         ######## ##     ## ######## ##    ## ########  ######
    ##     ##     ##    ##        ##       ##     ## ##       ###   ##    ##    ##    ##
    ##     ##     ##              ##       ##     ## ##       ####  ##    ##    ##
    ########       ######         ######   ##     ## ######   ## ## ##    ##     ######
    ##     ##           ##        ##        ##   ##  ##       ##  ####    ##          ##
    ##     ## ### ##    ## ###    ##         ## ##   ##       ##   ###    ##    ##    ##
    ########  ###  ######  ###    ########    ###    ######## ##    ##    ##     ######

/////////////////////////////////////////////////////////////////////////////////////////////
=end

  # ajout d'un stream à la liste
  @b_ajouter.click do
    @message_erreur.replace("")
    @bord.hide

    # on enleve les espaces inutiles en début et fin de chaine
    @nouv_nom.text = @nouv_nom.text.strip
    @nouv_url_stream.text = @nouv_url_stream.text.strip
    @nouv_url_chat.text = @nouv_url_chat.text.strip

    # le nom doit faire 20 caractères au maximum pour éviter qu'il ne dépasse trop à droite
    if @nouv_nom.text.size > 20
      @nouv_nom.text = @nouv_nom.text[0..19]
    end

    # on a besoin ces valeurs car elles vont changer en changeant @liste_streams_enregistres
    nom = @nouv_nom.text
    url_stream = @nouv_url_stream.text
    url_chat = @nouv_url_chat.text

    # si le stream n'a pas de nom, on renvoie un message d'erreur
    if nom.empty?
      @message_erreur.replace("Veuillez indiquer un nom pour le stream")
      @bord.show
    # si le stream n'a ni adresse pour le stream ni pour le chat, on renvoie une erreur
    elsif url_stream.empty? && url_chat.empty?
      @message_erreur.replace(["Veuillez indiquer une adresse ",
                                "pour le stream ou pour le chat"])
      @bord.show
    # sinon on peut tenter de l'ajouter à la liste
    else
      existe_deja = false

      # on vérifie qu'aucun stream ne possède déjà le même nom, sinon on renvoie une erreur
      liste_streams.each do |elem|
        if nom == elem.nom
          @message_erreur.replace("Ce nom de stream est déjà pris")
          @bord.show
          existe_deja = true
          break
        end
      end

      if existe_deja == false
        # on crée un nouveau stream dans la liste
        stream_tmp = Stream.new(nom, url_stream, url_chat)
        liste_streams << stream_tmp

        # on récupère la liste des noms de streams
        liste_noms = liste_streams.collect do |element|
          element.nom
        end
        # tri de la liste sans tenir compte de la casse
        liste_noms.sort! do |a,b|
          a.casecmp(b)
        end

        # on remplace les précédents items de @liste_streams_enregistres par liste_noms
        # note: cette affectation provoque un appel à sa méthode change() mais c'est
        #       nécessaire pour actualiser la liste déroulante
        @liste_streams_enregistres.items = liste_noms

        # on place la liste déroulante sur ce nouvel élément
        @liste_streams_enregistres.choose(nom)

        # TODO: serialization de la liste de streams à ajouter ici
      end
    end
  end

  # modification d'un stream de la liste
  @b_modifier.click do
    @message_erreur.replace("")
    @bord.hide

    # si aucun stream n'est sélectionné, on renvoie un message d'erreur
    if nom_stream.empty?
      @message_erreur.replace("Aucun stream sélectionné pour modification")
      @bord.show
    else
      # on enleve les espaces inutiles en début et fin de chaine
      @nouv_nom.text = @nouv_nom.text.strip
      @nouv_url_stream.text = @nouv_url_stream.text.strip
      @nouv_url_chat.text = @nouv_url_chat.text.strip

      # le nom doit faire 20 caractères au maximum pour éviter qu'il ne dépasse trop à droite
      if @nouv_nom.text.size > 20
        @nouv_nom.text = @nouv_nom.text[0..19]
      end

      # on a besoin ces valeurs car elles vont changer en changeant @liste_streams_enregistres
      nom = @nouv_nom.text
      url_stream = @nouv_url_stream.text
      url_chat = @nouv_url_chat.text

      # si le stream n'a pas de nom, on renvoie un message d'erreur
      if nom.empty?
        @message_erreur.replace("Veuillez indiquer un nom pour le stream")
        @bord.show
      # si le stream n'a ni adresse pour le stream ni pour le chat, on renvoie une erreur
      elsif url_stream.empty? && url_chat.empty?
        @message_erreur.replace(["Veuillez indiquer une adresse ",
                                  "pour le stream ou pour le chat"])
        @bord.show
      # sinon on peut modifier la liste
      else
        # on cherche le stream ayant le même nom que celui sélectionné pour le modifier
        liste_streams.each do |elem|
          if nom_stream == elem.nom
              elem.nom = nom
              elem.url_stream = url_stream
              elem.url_chat = url_chat
            break
          end
        end

        # on récupère la liste des noms de streams
        liste_noms = liste_streams.collect do |element|
          element.nom
        end
        # tri de la liste sans tenir compte de la casse
        liste_noms.sort! do |a,b|
          a.casecmp(b)
        end

        # on remplace les précédents items de @liste_streams_enregistres par liste_noms
        # note: cette affectation provoque un appel à sa méthode change() mais c'est
        #       nécessaire pour actualiser la liste déroulante
        @liste_streams_enregistres.items = liste_noms

        # si le nom change du stream sélectionné, on replace la liste déroulante dessus
        if nom_stream != nom
          @liste_streams_enregistres.choose(nom)
        end

        # TODO: serialization de la liste de streams à ajouter ici
      end
    end
  end

  # suppression d'un stream de la liste
  @b_supprimer.click do
    @message_erreur.replace("")
    @bord.hide

    # si aucun stream n'est sélectionné, on renvoie un message d'erreur
    if nom_stream.empty?
      @message_erreur.replace("Aucun stream sélectionné pour suppression")
      @bord.show
    else
      # on cherche le stream ayant le même nom que celui sélectionné pour le suppresion
      liste_streams.each do |elem|
        if nom_stream == elem.nom
            liste_streams.delete(elem)
          break
        end
      end

      # on récupère la liste des noms de streams
      liste_noms = liste_streams.collect do |element|
        element.nom
      end
      # tri de la liste sans tenir compte de la casse
      liste_noms.sort! do |a,b|
        a.casecmp(b)
      end

      # plus aucun stream n'est sélectionné, plutôt que de mettre le premier de la liste
      # pour éviter un double-clique maladroit sur le bouton Supprimer
      adresse_stream = ""
      adresse_chat = ""

      # on remplace les précédents items de @liste_streams_enregistres par liste_noms
      # note: cette affectation provoque un appel à sa méthode change() mais c'est
      #       nécessaire pour actualiser la liste déroulante
      @liste_streams_enregistres.items = liste_noms

      # je ne sais pas pourquoi, si on remet nom_stream à vide AVANT de modifier les items
      # on ne passe plus ni dans "if nom_stream.empty?" ni dans "else"
      # si on enchaine les suppressions
      nom_stream = ""
    end
  end
end
