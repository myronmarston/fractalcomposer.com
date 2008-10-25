fc_atom_feed(:schema_date => Date.civil(2008, 10, 25), :root_url => 'http://fractalcomposer.com/' ) do |feed|
   feed.title("Fractal Composer Generated Pieces")
   feed.updated(@generated_pieces.size == 0 ? DateTime.now : @generated_pieces.first.created_at)   
   
   feed.author do |author|
      author.name 'Myron Marston'
      author.email 'myron@fractalcomposer.com'
      author.uri 'http://fractalcomposer.com/'
   end
   
   feed.rights '&copy;2008 Myron Marston', :type => 'html'
  
   for @generated_piece in @generated_pieces         
     feed.entry(@generated_piece, :url => url_for(:controller => 'compose', :id => @generated_piece.id, :only_path => false) ) do |entry|
       entry.link :rel => 'license', :type => 'application/rdf+xml', :href => "#{LICENSE_URL}rdf"       
       entry.title(generated_piece_germ_by_ip)             
                         
       entry.author do |author|
         author.name(@generated_piece.user_ip_address)
       end
      
       # if there are any files missing from the file system, skip this piece...
       local_midi_file = get_local_filename(@generated_piece.generated_midi_file)
       local_guido_file = get_local_filename(@generated_piece.generated_guido_file)
       next unless File.exist?(local_midi_file)  && File.file?(local_midi_file) &&
                   File.exist?(local_guido_file) && File.file?(local_guido_file)  
      
       entry_midi_enclosure(entry, @generated_piece.generated_midi_file)
       
       @last_generated_piece = @generated_piece # the partial uses @last_generated_piece
       entry.content(:type => 'html') do |content|
         content.cdata! render(:partial => 'compose/listen_to_part.html.erb', :locals => {:div_id_prefix => dom_id(@generated_piece)})
       end
     end
   end
 end
