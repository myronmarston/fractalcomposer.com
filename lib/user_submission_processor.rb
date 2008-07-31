class UserSubmissionProcessor    
  @@semaphore = Mutex.new
  @@singleton_thread = nil unless defined? @@singleton_thread
  
  def self.start_processor_if_necessary
    @@semaphore.synchronize do      
      if @@singleton_thread.nil?
        logger.info "processor starting"
        @@singleton_thread = Thread.new {UserSubmissionProcessor.process}          
      else
        logger.info "processor already running"
      end
    end
  end
  
  private
  
  def self.process   
    sleep 1
    #TODO: how to I propagate exceptions to rails' exception-handling mechanism?
    while true
      user_submission = UserSubmission.find(:first, :conditions => {:processing_completed => nil}, :order => 'created_at')
      logger.info "processing user submission: #{user_submission.inspect}"
      break unless user_submission
      user_submission.process  
    end
    
    @@semaphore.synchronize do
      @@singleton_thread = nil
      ActiveRecord::Base.verify_active_connections!
      Thread.exit
    end    
  end
  
  def self.logger
    ActiveRecord::Base.logger
  end
end
