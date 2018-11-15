driver_label = "Intesis Box HVAC Controller Gateway"
driver_help= [[
================
Most HVAC installations in the United States are easy as most thermostats utilise a universal standard and as such can be replaced easily by a 3rd party thermostat such as automation-compatible thermostats.

Unfortunately alot of HVAC manufacturers do not utilise this standard and have proprietary closed communications that are specific to that HVAC manufacturer.  This makes it extremely cumbersome for integrators to source a reliable HVAC product and in many countries integrators do not even bother with HVAC integration because it is just too hard.

Luckily Intesis have released their range of IntesisBox wifi gateways.  The IntesisBox allows you to easily integrate HVAC systems into BLGW by retrofitting the IntesisBox gateway into the existing indoor unit.  Intesis offer two gateway types.

Specific IntesisBox’s are developed to communicate with the HVAC manufacturer’s proprietary communications protocol allowing for true real time bidirectional communication with the system. 

Universal IntesisBox’s are developed to offer compatibility with thousands of HVAC models through infra red and offer room temperature feedback via a sensor in the IntesisBox.

This IntesisBox driver for BLGW will work with all models of IntesisBox and will provide full two way control/feedback.


Khimo support notes:
  - Plese don't let empty tables on commands or states

]]

driver_channels={
  TCP(3310,"192.168.77.75","Direct Ethernet Connection", "Direct Ethernet connection for this Intesis Box HVAC Controller Gateway driver"),
}

local t2spActions = {
  ["SET HEAT SP"]= { arguments= { numericArgument("HEAT SP", 22.0, 16.0, 30.0) } },
  ["SET COOL SP"]= { arguments= { numericArgument("COOL SP", 22.0, 18.0, 30.0) } },
  ["SET MODE"]= { arguments= { enumArgument("MODE", {  "Off", "Heat", "Cool", "Auto", "_Dry", "_Fan"  }, "Auto" ) } },
  ["SET FAN AUTO"]= {},
  ["STATE_UPDATE"]= {},
  ["_SET ONOFF"]= { context_help= "turns unit ON or OFF", arguments= { enumArgument("ON / OFF", {  true, false  }, false ) } },
  ["_SET FANSP"]= { context_help= "set fan speed", arguments= { enumArgument("Fan Speed", {  "_Auto", "_High", "_Med", "_low", "_Quiet" }, "_Auto" ) } },
  ["_SET VANEUD"]= { context_help= "set vertical vane position", arguments= { enumArgument("VANEUD", {  1, 2, 3, 4, 5, 6, "_SWING" }, 1 ) } },
  ["_SET VANELR"]= { context_help= "set horizontal vane position", arguments= { enumArgument("VANELR", {  1, 2, 3, 4, 5, "_SWING" }, 1 ) } },
  ["_SET SWING"]= { context_help= "set SWING operation mode", arguments= { enumArgument("SWING", {  "_UD", "_LR", "_UDLR", "Off" }, "Off" ) } }

}

local positiveNumber = "\\([0-9]\\|[1-9][0-9]*\\)"

local theAddress= stringArgumentRegEx( "address", "1", positiveNumber )

local t2spStates = { 
	["VALUE"]= {},
  	["TEMPERATURE"]= { arguments= { temperatureArgument("Temperature", "C", 22.0 ) } },
  	["HEAT SP"]= { arguments= { temperatureArgument("Temperature", "C", 22.0 ) } },
  	["COOL SP"]= { arguments= { temperatureArgument("Temperature", "C", 22.0 ) } },
  	["MODE"]= { arguments= { enumArgument("MODE", {  "Off", "Heat", "Cool", "Auto", "_Dry", "_Fan"  }, "Auto" ) } },
    	["FAN AUTO"]= {},
    	["_ONOFF"]= { arguments= { enumArgument("ON / OFF", {  true, false  }, false ) } },
    	["_FANSP"]= { arguments= { enumArgument("Fan Speed", {  "Auto", "_High", "_Med", "_low", "_Quiet" }, "Auto" ) } },
  	["_VANEUD"]= { arguments= { enumArgument("VANEUD", {  1, 2, 3, 4, 5, 6, "_SWING" }, 1 ) } },
  	["_VANELR"]= { arguments= { enumArgument("VANELR", {  1, 2, 3, 4, 5, "_SWING" }, 1 ) } },
  	["_SWING"]= { arguments= { enumArgument("SWING", {  "_UD", "_LR", "_UDLR", "Off" }, "Off" ) } }
}

resource_types= {
  ["Intesis Thermostat"]= { 
    standardResourceType= "THERMOSTAT_2SP",
    address= theAddress,
    events= t2spActions,
    commands= t2spActions,
    states= t2spStates 
  }
}

[[
* The process is a global function responsible of control the message channel, receive and send states requests to mantain
the connection alive, there you will set the state of your resources.
This function is called on driver init and is called in a loop while the system is loaded

function process()
  Trace('Starting process') --The Trace command let you print process function outputs on the BLI/BLGW log
  -- You need to send some request to your device to know if you can reach it, 
  -- for that I recommend to send a state request which also let you set the initial state of the devices
  channel.write('GET,acNum:function/ CHN,acNum:function,value') -- You will read and write through the channel
  local reader, msg = channel.readUntil('expected message', <timeout>) 
  if reader == CONST.OK and <some condition> then --CONST.OK is equivalent to a 200 http response
    driver.setOnline() -- Will turn green the driver label
    setResourceState('resource.typeId', {address=resource.address}, {['state_name'] = newState}) -- Update resource state
    - There exists to ways to keep the driver alive, use channel.status() in a while loop or let the process function end and starts again
    while (channel.status()) do 
      -- wait for some state coming 
    end
  else
    -- set driver label to red and return error
    driver.setError()
    return CONST.HW_ERROR
  end
  -- Print a message and wait for some time till start the process again
  channel.retry('End of the process', <polling time>)
  return CONST.POLLING
end


* executeCommand runs on parallel to the process and is the responsible to execute the commands that comes from the macros
  
function executeCommand(command, resource, commandArgs)
  if resource.typeId == "some resource type" and command == "some command" then
    channel.write("SET,acNum:function,value / LIMITS:function,range") -- The feedback from the commands is captured on the process function
  else if -- the remaining commands
  end
end
  
The two functions above are mandatories to the driver works, 
respecting these functions you can define how much functions as you need always as local functions
]]
