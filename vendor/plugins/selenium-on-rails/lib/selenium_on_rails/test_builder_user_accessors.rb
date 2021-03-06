# Mirrors the accessors specified in user-extensions.js from the selenium-core
module SeleniumOnRails::TestBuilderUserAccessors
  
  def store_xpath_count xpath, variable_name
    commad 'storeXpathCount', xpath, variable_name
  end
  
  # Return the length of text of a specified element.
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_text_length(locator, variable)</tt>
  # * <tt>assert_not_text_length(locator, length)</tt>
  # * <tt>verify_text_length(locator, length)</tt>
  # * <tt>verify_not_text_length(locator, length)</tt>
  # * <tt>wait_for_text_length(locator, length)</tt>
  # * <tt>wait_for_not_text_length(locator, length)</tt>
  def store_text_length locator, variable_name
    command 'storeTextLength', locator, variable_name
  end
  
  # Checks if value entered more than once in textbox.
  #
  # Related Assertions, automatically generated:
  # * <tt>assert_not_text_length(locator, text)</tt>
  # * <tt>verify_text_length(locator, text)</tt>
  # * <tt>verify_not_text_length(locator, text)</tt>
  # * <tt>wait_for_text_length(locator, text)</tt>
  # * <tt>wait_for_not_text_length(locator, text)</tt>
  def assert_value_repeated locator, text
    command 'assertValueRepeated', locator, text
  end
  
  private
  
  def self.generate_methods
    public_instance_methods.each do |method|
      case method
      when 'store_text_length', 'store_xpath_count'
        each_assertion method do |assertion_method, command_name|
          define_method assertion_method do |arg1, arg2|
            command command_name, arg1, arg2
          end
        end
      when 'assert_value_repeated'
        each_check method do |check_method, command_name|
          define_method check_method do |arg1, arg2|
             command command_name, arg1, arg2
          end
        end              
      else
        raise "Internal error: Don't know how to process user accessor: #{method}"
      end
    end
  end
  
  # Generates all the assertions needed given a +store_method+.
  def self.each_assertion store_method
    before_negation = nil
    after_negation = store_method.split('_')[1..-1] #throw away 'store'
    if after_negation.last == 'present'
      before_negation, after_negation = after_negation, after_negation.pop
    end

    ['assert', 'verify', ['wait','for']].each do |action|
      [nil, 'not'].each do |negation|
        name = [action, before_negation, negation, after_negation].flatten.reject{|a|a.nil?}
        method_name = name.join '_'
        command = name.inject(name.shift.clone) {|n, p| n << p.capitalize}
        yield method_name, command
      end
    end
  end
  
  def self.each_check assert_method
    before_negation = nil
    after_negation = assert_method.split('_')[1..-1] #throw away 'assert'
    if after_negation.last == 'present'
      before_negation, after_negation = after_negation, after_negation.pop
    end
    
    ['assert', 'verify', ['wait', 'for']].each do |action|
      [nil, 'not'].each do |negation|
        unless (action == 'assert' && negation.nil?)
          name = [action, before_negation, negation, after_negation].flatten.reject{|a|a.nil?}
          method_name = name.join '_'
          command = name.inject(name.shift.clone) {|n, p| n << p.capitalize}
          yield method_name, command
        end
      end
    end
  end
  
  generate_methods
  
end