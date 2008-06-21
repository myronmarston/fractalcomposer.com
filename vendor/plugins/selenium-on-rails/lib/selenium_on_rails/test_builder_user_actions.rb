# Mirrors the actions specified in user-extensions.js from the selenium-core
module SeleniumOnRails::TestBuilderUserActions
 
 def watch_ajax_requests
   command 'watchAjaxRequests'
 end
 
 def wait_for_ajax_request(timeout)
   command 'waitForAjaxRequest', timeout
 end
 
 def label(label)
   command 'label', label
 end
 
 def goto_if(condition, label)
   command 'gotoIf', condition, label
 end 
 
 def goto(label)
   command 'goto', label
 end
 
 def refresh_and_wait
   command 'refreshAndWait'
 end
 
 private
   
 # Generates the corresponding +_and_wait+ for each action.
 def self.generate_and_wait_actions
   public_instance_methods.each do |method|
     define_method method + '_and_wait' do |*args|
       make_command_waiting do
         send method, *args
       end
     end
   end
 end

 generate_and_wait_actions
 
end