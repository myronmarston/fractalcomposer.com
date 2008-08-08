# taken from http://groups.google.com/group/jruby-users/browse_thread/thread/e703e3acd2f9bed7/baee5d58f5fb6d58?lnk=gst&q=render_optional_error_file#
PUBLIC_ROOT = if defined?($servlet_context)
   $servlet_context.getRealPath('/')
 else
   RAILS_ROOT + '/public'
 end
 
PUBLIC_ROOT_WITHOUT_TRAILING_SLASH = PUBLIC_ROOT.chomp(File::SEPARATOR).chomp(File::ALT_SEPARATOR)