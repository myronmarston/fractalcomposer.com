class UserSubmissionProcessor    
  @@semaphore = Mutex.new
  @@singleton_thread = nil unless defined? @@singleton_thread
  
  def self.start_processor_if_necessary
    @@semaphore.synchronize do      
      if @@singleton_thread.nil?
        @@singleton_thread = Thread.new {UserSubmissionProcessor.process}          
      end
    end
  end
  
  private
  
  def self.process   
    sleep 1
    #TODO: how to I propigate exceptions to rails' exception-handling mechanism?
    while true
      user_submission = UserSubmission.find(:first, :conditions => {:processing_completed => nil}, :order => 'created_at')
      break unless user_submission
      user_submission.process  
    end
    
    @@semaphore.synchronize do
      @@singleton_thread = nil
      Thread.exit
    end    
  end
end
