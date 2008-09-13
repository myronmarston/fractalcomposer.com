# taken from http://groups.google.com/group/jruby-users/browse_thread/thread/e703e3acd2f9bed7/baee5d58f5fb6d58?lnk=gst&q=render_optional_error_file#
PUBLIC_ROOT = if defined?($servlet_context)
   $servlet_context.getRealPath('/')
 else
   RAILS_ROOT + '/public'
 end
 
PUBLIC_ROOT_WITHOUT_TRAILING_SLASH = PUBLIC_ROOT.chomp(File::SEPARATOR).chomp(File::ALT_SEPARATOR)

user_generated_files_path = File.join(PUBLIC_ROOT, 'user_generated_files')
unless File.exist?(user_generated_files_path)
  # make a symlink to the user generated files path... 
  puts "creating symbolic link for #{user_generated_files_path}"  
  `ln -s /fractal_composer_user_generated_files #{user_generated_files_path}`    
  raise 'The user_generated_files symlink was not created as expected.' unless File.exist?(user_generated_files_path)  
end