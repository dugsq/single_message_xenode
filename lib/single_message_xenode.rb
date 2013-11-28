# Copyright Nodally Technologies Inc. 2013
# Licensed under the Open Software License version 3.0
# http://opensource.org/licenses/OSL-3.0

# Version 0.1.0
#
# Single Message Xenode sends pre-defined message context, data, and command to all of its downstream children. 
# It is ideal for testing your Xenodes.
#
# Configuration File Options:###
#   loop_delay: defines number of seconds the Xenode waits before running the Xenode process. Expects a float. 
#   enabled: determines if this Xenode process is allowed to run. Expects true/false.
#   debug: enables extra debug messages in the log file. Expects true/false.
#   max_msgs: defines the maximum number of messages to send. Defaults to 1 if not specified. Expects an integer.
#   interval: defines the interval for sending each message. Expects an float.
#   msg_data: defines the message text to send. Expects a string.
#   msg_context: defines the message context to send, and a hash can be pre-defined. Expects strings.
#   msg_command: defines the message command to send. Expects a string.
#
# Example Configuration File:
#   enabled: true
#   loop_delay: 10
#   debug: false
#   max_msgs: 3
#   interval: 2.0
#   msg_data: "hello world"
#   msg_context: 
#     myhash:
#       key1: value1
#       key2: value2
#   msg_command: "mycommand"
#
# Example Input: Single Message Xenode does not expect nor handle any input data.
#
# Example Output:
#   msg.data: "String contains the pre-defined message to be sent to the children Xenodes."
#

class SingleMessageXenode
  include XenoCore::XenodeBase
  
  # This xenode uses the startup to send
  # a single message to it's children.
  # The msg_data in the config will be sent in the message data.
  def startup()
    mctx = "#{self.class}.#{__method__} [#{@xenode_id}]"
    
    # time variable for process loop
    # better resolution if the @loop_delay is small and the 
    # interval size is bigger than loop delay
    @last_message = Time.now.to_f
    
    do_debug("#{mctx} - config: #{@config.inspect}", true)
    
    # make sure max_msgs defaults to 1 if not in config
    @max_msgs = @config[:max_msgs]
    @max_msgs ||= 1
    
    # initialize message counter
    @count = 0
    
    # init @done flag
    @done = false

  end
  
  # create a new message and populate it from the config
  def new_message()
    mctx = "#{self.class}.#{__method__} [#{@xenode_id}]"
    # a new message
    msg = XenoCore::Message.new
    # the data for the message from config
    msg.data    = @config[:msg_data]
    msg.context = @config[:msg_context]
    msg.command = @config[:msg_command]
    msg.from_id = @xenode_id
    
    msg
  end
  
  # this gets called by the infrastructure every @loop_delay seconds
  def process()
    mctx = "#{self.class}.#{__method__} [#{@xenode_id}]"
    
    # don't do anything if wwe have reached the max count
    unless @count >= @config[:max_msgs]
      
      # get the current time
      time_now = Time.now.to_f
      
      if (time_now - @last_message) > @config[:interval].to_f
      
        @last_message = time_now
          
        # increment the message counter
        @count += 1
          
        # static message from config
        msg = new_message()
        
        # this only gets logged if debug in config is true
        do_debug("#{mctx} - sent message. #{msg.to_hash}")
        
        # write to all of the Xenodes that are the children
        # of this xenode.
        write_to_children(msg)
      end
        
    else
      # max messages reached
      unless @done
        # this gets logged once regardless if debug is true or false in the config
        # as it has the force flag set to true
        do_debug("#{mctx} - max messages reached. #{@config[:max_msgs]}", true)
        # set the done flag to true so this doesn't happen any more
        @done = true
      end
    end

  end
  
  # this gets called by the infrastructure when the Xenode is shutdown
  def shutdown()
    mctx = "#{self.class}.#{__method__} [#{@xenode_id}]"
    do_debug("#{mctx} - Xenode has exited.", true)
  end
  
end
