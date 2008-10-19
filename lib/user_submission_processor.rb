class UserSubmissionProcessor    
  include ExceptionNotifiable
  
  SLEEP_TIME = 30 unless defined? SLEEP_TIME
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
    user_submission = nil
    
    while true
      begin      
        user_submission = UserSubmission.find(:first, :conditions => {:processing_completed => nil}, :order => 'created_at')
        
        if user_submission
          logger.info "***** processing user submission: #{user_submission.inspect}"              
          user_submission.process  
        else          
          logger.info "***** no unprocessed user submissions found. Sleeping for #{SLEEP_TIME} seconds" 
          sleep SLEEP_TIME
        end  
      rescue Exception => ex        
        logger.error "***** An exception occurred while processing the user submissions: #{ex.inspect} \n#{ex.backtrace}"             
        ExceptionNotifier.deliver_processor_exception_notification(ex, user_submission)

        @@semaphore.synchronize do
          @@singleton_thread = nil
          ActiveRecord::Base.verify_active_connections!
          Thread.exit
        end  
      end
    end          
  end
  
  def self.logger
    ActiveRecord::Base.logger
  end
end
