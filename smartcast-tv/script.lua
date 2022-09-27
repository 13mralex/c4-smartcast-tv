require "commands"
JSON = (require "json")
token = ""
pin = ""
auth_token = Properties["Authorization Token"]

function OnDriverInit()

    print("Driver init...")
    --id = C4:GetDeviceID()
    --auth_token = C4:GetVariable(id, idVariable)
end

function connect_tv(action, pin)

    local data = ""

    putData='{"DEVICE_ID":"254","DEVICE_NAME":"C4 TRIAL 1"}'
    
    baseurl = "https://"..Properties["Device IP"]..":7345"
    
    if (action == "start") then
	   url = baseurl.."/pairing/start"
	   print("Calling URL: "..url)
	   print(C4:urlPut(url, putData, {["Content-Type"]="application/Json"}))
	   function ReceivedAsync(ticketId, strData)
		   print(ticketId .. ": " .. strData)
		   data = strData
		   local table = JSON:decode(data)
		   print("JSON Table: "..dump(table))
		   token = table["ITEM"]["PAIRING_REQ_TOKEN"]
		   print("Pairing Token: "..token)
	   end
    end
    
    if (action == "stop") then
	   url = baseurl.."/pairing/cancel"
	   print("Calling URL: "..url)
	   print(C4:urlPut(url, putData, {["Content-Type"]="application/Json"}))
	   function ReceivedAsync(ticketId, strData)
		   print(ticketId .. ": " .. strData)
		   data = strData
		   local table = JSON:decode(data)
		   print("JSON Table: "..dump(table))
	   end
    end
    
    if (action == "pair") then
	   putData='{"DEVICE_ID": "254","CHALLENGE_TYPE": 1,"RESPONSE_VALUE": "'..pin..'","PAIRING_REQ_TOKEN": '..token.."}"
	   print(putData)
	   url = baseurl.."/pairing/pair"
	   print("Calling URL: "..url)
	   print(C4:urlPut(url, putData, {["Content-Type"]="application/Json"}))
	   function ReceivedAsync(ticketId, strData)
		   print(ticketId .. ": " .. strData)
		   data = strData
		   local table = JSON:decode(data)
		   print("JSON Table: "..dump(table))
		   auth_token = table["ITEM"]["AUTH_TOKEN"]
		   C4:UpdateProperty("Authorization Token", auth_token)
	   end
    end
    
    --get pair code

    --putData='{"DEVICE_ID": "254","CHALLENGE_TYPE": 1,"RESPONSE_VALUE": "1526","PAIRING_REQ_TOKEN": 887923}'
    
    --url = baseurl.."/pairing/pair"

    --print(C4:urlPut("https://10.0.1.95:7345/pairing/pair", putData, {["Content-Type"]="application/Json"}))
    --function ReceivedAsync(ticketId, strData)
	--    print(ticketId .. ": " .. strData)
    --end


end

function sendCmd(codeset, code)

    --send command
    putData='{"KEYLIST": [{"CODESET": '..codeset..',"CODE": '..code..',"ACTION":"KEYPRESS"}]}'

    baseurl = "https://"..Properties["Device IP"]..":7345"
    
    headers = {}
    headers["Content-Type"] = "application/Json"
    headers["AUTH"] = auth_token

    url = baseurl.."/key_command/"
    print("Codeset: "..codeset.." Code: "..code)
    print("Calling URL: "..url)
    print("Data: "..putData)
    print(C4:urlPut(url, putData, headers))
    
    function ReceivedAsync(ticketId, strData)
		   print(ticketId .. ": " .. strData)
		   data = strData
		   local table = JSON:decode(data)
		   print("JSON Table: "..dump(table))
    end

end

function sendInput1(input)
    
    baseurl = "https://"..Properties["Device IP"]..":7345"
    hashval = ""
    headers = {}
    headers["Content-Type"] = "application/Json"
    headers["AUTH"] = auth_token

    url = baseurl.."/menu_native/dynamic/tv_settings/devices/current_input"
    
    C4:urlGet(url, headers)
    
    function ReceivedAsync(ticketId, strData)
		   --print(ticketId .. ": " .. strData)
		   data = strData
		   local table = JSON:decode(data)
		   --print("JSON Table: "..dump(table))
		   --print("Hash value before: "..tostring(table["ITEMS"][1]["HASHVAL"]))
		   hashval = tostring(table["ITEMS"][1]["HASHVAL"])
		   --print("Hash value after: "..hashval)
		   sendInput2(input,hashval)
    end

end

function sendInput2(input,hash)

    putData = '{"REQUEST": "MODIFY","VALUE": "'..input..'","HASHVAL":'..hash..'}' 
    
    baseurl = "https://"..Properties["Device IP"]..":7345"
    
    headers = {}
    headers["Content-Type"] = "application/Json"
    headers["AUTH"] = auth_token

    url = baseurl.."/menu_native/dynamic/tv_settings/devices/current_input"
    print("---------")
    print("Input: "..input)
    print("Calling URL: "..url)
    print("Data: "..putData)
    print(C4:urlPut(url, putData, headers))
    
    function ReceivedAsync(ticketId, strData)
		   --print(ticketId .. ": " .. strData)
		   print("---------")
    end
end

function OnNetworkBindingChanged(idBinding, bIsBound)

print("Network Binding changed...")

    if (bIsBound == "True") then
	   ipAddr = C4:GetBindingAddress(idBinding)
	   print("New IP Address: "..ipAddr)
    end

end

function OnPropertyChanged(sProperty)
    print("OnPropertyChanged(" .. sProperty .. ") changed to: " .. Properties[sProperty])
    if (sProperty == "Pairing Code") then
	   pin = Properties[sProperty]
	   print("PIN Submitted: "..pin)
	   connect_tv("pair",pin)
    end
end

function ReceivedFromProxy(idBinding, strCommand, tParams)
    print("Received from proxy........")
    print("ID: "..idBinding)
    print("Command: "..strCommand)
    print("Parameters: "..dump(tParams))
    --print("Proxy command: "..strCommand)
    --for k,v in pairs(tParams) do
	--   print(k .. ": " .. v)
    --end
    print("End......")
    send_command(strCommand, tParams)
end

function ExecuteCommand(strCommand, tParams)
print("Execute Command: "..strCommand)
print("Parameters: "..dump(tParams))
 if (strCommand == "LUA_ACTION") then
   if tParams ~= nil then
     for cmd,cmdv in pairs(tParams) do 
       --print (cmd,cmdv)
       if cmd == "ACTION" then
         if cmdv == "pair" then
		  connect_tv("start")
	    elseif cmdv == "stop_pair" then
		  connect_tv("stop")
         else
           print("From ExecuteCommand Function - Undefined Action")
           print("Key: " .. cmd .. "  Value: " .. cmdv)
         end
       else
         print("From ExecuteCommand Function - Undefined Command")
         print("Key: " .. cmd .. "  Value: " .. cmdv)
       end
     end
   end
 end

end

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end