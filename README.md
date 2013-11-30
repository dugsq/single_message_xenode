Single Message Xenode
=====================

Note: you will need the Xenograte Community Toolkit (XCT) to run this Xenode. Refer to the XCT repo [https://github.com/Nodally/xenograte-xct](https://github.com/Nodally/xenograte-xct) for more information.

**Single Message Xenode** sends a pre-defined message with its context, data, and/or command to all of its children Xenode. It is ideal for testing your Xenodes.

###Configuration File Options:###
* loop_delay: defines number of seconds the Xenode waits before running the Xenode process. Expects a float. 
* enabled: determines if this Xenode process is allowed to run. Expects true/false.
* debug: enables extra debug messages in the log file. Expects true/false.
* max_msgs: defines the maximum number of messages to send. Defaults to 1 if not specified. Expects an integer.
* interval: defines the interval for sending each message. Expects an float.
* msg_data: defines the message text to send. Expects a string.
* msg_context: defines the message context to send, and a hash can be pre-defined. Expects strings.
  - myhash:
    + key1: value1
    + key2: value2
* msg_command: defines the message command to send. Expects a string.

###Example Configuration File:###
* enabled: true
* loop_delay: 10
* debug: false
* max_msgs: 3
* interval: 2.0
* msg_data: "hello world"
* msg_context: 
  - myhash:
    + key1: value1
    + key2: value2
* msg_command: "mycommand"

###Example Input:###
* Single Message Xenode does not expect nor handle any input data.

###Example Output:###
* msg.data: "String contains the pre-defined message to be sent to the children Xenodes."
