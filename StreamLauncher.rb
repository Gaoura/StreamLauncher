class Stream
  def initialize(nom, url, chat_url)
    @nom = nom
    @url = url
    @chat_url = chat_url
  end
  attr_reader :nom, :url, :chat_url
end

Shoes.app title: "StreamLauncher, GUI for livestreamer",
          width: 1000,
          height: 700,
          resizable: true do

  stream1 = Stream.new("Zerator", "www.twitch.tv/zerator", "http://www.twitch.tv/zerator/chat?popout=")
  stream2 = Stream.new("Corobizar", "dailymotion.com/video/x162xu2", "http://corobizar.com/stand-alone-chat.php")
  stream3 = Stream.new("machin daiy", "http://games.dailymotion.com/live/x3ixah7", "http://corobizar.com/stand-alone-chat.php")
  stream4 = Stream.new("Mira truc", "http://www.twitch.tv/miramisu", "http://www.twitch.tv/zerator/chat?popout=")
  liste_streams = [stream1, stream2, stream3, stream4]


  if File.exists?("streams.slgl")
    File.open("streams.slgl") do |f|
      liste_streams = Marshal.load(f)
    end
  end


#  stack do
#    para "Liste des streams enregistrés :"
#    stack width: 200, height: 500, scroll: true do
#      border black, strokewidth: 1
#      @liste_streams.each do |stream|
#        flow do
#          @radio = radio :streams
#          para stream.nom
#        end
#      end
#    end
#  end

  # on récupère la liste des noms de streams
  liste_noms = liste_streams.collect do |element|
    element.nom
  end
  # tri de la liste
  liste_noms.sort!

  # bande supérieure
  @main = flow margin: 5 do
    # colonne de gauche
    stack width: 275 do
      para "Liste des streams enregistrés :"
      @liste = list_box items: liste_noms, width: 250 do |element|
        # à chaque sélection d'un nom de stream, on le retient dans une variable et
        @stream_select = element.text
        # on nettoie la colonne de droite pour ne pas perdre en cohérence
        @qualite_error.hide

        liste_streams.each do |elem|
          if @stream_select == elem.nom
            @adresse = elem.url
            break
          end
        end
      end
    end

    # colonne centrale
    stack width: 275 do
      @b1 = button "Qualités disponibles ?"
      @b2 = button "Lancer ce stream"
      @b3 = button "Lancer le chat du stream"
    end

    # colonne de droite variable
    @qualite_error = stack width: 300 do
      @message_qualite = para ""
      @liste_qualites = list_box width: 150
    end
  end

  @qualite_error.hide

  # recherche des qualités disponibles pour le stream sélectionné
  @b1.click do
    @qualite_error.show
    @commande = `livestreamer #{@adresse}`

    # après cette commande, soit on a un message contenant "error"..
    if @commande.include?("error:")
      @message_qualite.replace("Stream hors-ligne ou adresse erronée...")
      @liste_qualites.remove
    # soit on a un message contenant les qualités
    else
      # r1 est l'expression regulière pour nettoyer en partie la liste des qualités
      r1 = Regexp.new('(\s\(\w+\)(\, )?)|(\, )')
      # on soustrait la première (et unique) occurrence de "...\nAvailable streams: "
      # ainsi que toutes les occurrences correspondantes à r1 par une espace
      @commande.sub!(/.+\sAvailable streams: /, '').gsub!(r1, ' ')
      # enfin il ne reste que des qualités séparés par une espace, on les split en un array
      @resultat = @commande.split(' ')

      # on affiche la liste déroulante des qualités disponibles
      @message_qualite.replace("Qualités disponibles pour ce stream :")

      # on supprime la précédente liste de qualités
      @liste_qualites.remove
      # la liste des qualités va contenir notre résultat traité
      @qualite_error.append do
        @liste_qualites = list_box items: @resultat, width: 150 do |element|
        # à chaque sélection d'un élément, on le retient dans une variable
          @qualite_select = element.text
        end
      end
    end

  end

  @b2.click  do

  end
end
