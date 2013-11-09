# Copyright Nodally Technologies Inc. 2013
# Licensed under the Open Software License version 3.0
# http://opensource.org/licenses/OSL-3.0

class SingleMessageXenode
  include XenoCore::NodeBase
  
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