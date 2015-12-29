class Stream
  def initialize(nom, url_stream, url_chat)
    @nom = nom
    @url_stream = url_stream
    @url_chat = url_chat
  end
  attr_reader :nom, :url_stream, :url_chat
end

Shoes.app title: "StreamLauncher, GUI for livestreamer",
          width: 910,
          height: 700,
          resizable: false do

  stream1 = Stream.new("Zerator", "www.twitch.tv/zerator", "http://www.twitch.tv/zerator/chat?popout=")
  stream2 = Stream.new("Corobizar", "dailymotion.com/video/x162xu2", "http://corobizar.com/stand-alone-chat.php")
  stream3 = Stream.new("machin daiy", "http://games.dailymotion.com/live/x3ixah7", "http://corobizar.com/stand-alone-chat.php")
  stream4 = Stream.new("Mira truc", "http://www.twitch.tv/miramisu", "http://www.twitch.tv/zerator/chat?popout=")
  liste_streams = [stream1, stream2, stream3, stream4]

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
  # tri de la liste
  liste_noms.sort!

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
  flow margin: 5 do
    # colonne de gauche
    stack width: 300 do
      para "Liste des streams enregistrés :"
      @liste = list_box items: liste_noms, width: 275 do |element|
        # à chaque sélection d'un nom de stream, on le retient dans une variable et
        @stream_select = element.text
        # on nettoie la colonne de droite
        @qualite_error.hide
        # et on efface la qualité pour ne pas perdre en cohérence
        qualite_select = ""

        # stockage des informations correspondant au nom du stream sélectionné
        liste_streams.each do |elem|
          if @stream_select == elem.nom
            adresse_stream = elem.url_stream
            adresse_chat = elem.url_chat
            break
          end
        end
      end
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

  # NOTE: si aucun stream n'est sélectionné et qu'on clique sur b1, on obtient une list_box

  # recherche des qualités disponibles pour le stream sélectionné
  @b1.click do
    @message_erreur.replace("")
    @bord.hide
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
      @message_qualite.replace("Qualités disponibles pour\n#{@stream_select} :")
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

  # lance le stream sélectionné
  @b2.click do
    @message_erreur.replace("")
    @bord.hide

    # si aucune qualité n'est sélectionné, on lancera par défaut avec la qualité "best"
    if qualite_select.empty?
      qualite_select = "best"
    end

    # si aucun stream n'est sélectionné, on envoie un message d'erreur
    if adresse_stream.empty?
      @message_erreur.replace("Aucun stream sélectionné")
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
    if adresse_stream.empty?
      @message_erreur.replace("Aucun stream sélectionné")
      @bord.show
    # sinon si le stream ne possède pas d'adresse de chat, on envoie un message d'erreur
    elsif adresse_chat.empty?
      @message_erreur.replace("Aucun chat enregistré pour #{@stream_select}")
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
  flow margin: 5 do
    @bord = border red, strokewidth: 2, hidden: true
    @message_erreur = para "", align: "center"
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
  flow margin: 5 do
    
  end

end
