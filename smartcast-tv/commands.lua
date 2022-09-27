function send_command(cmd, tParams)

print("Send command function: "..cmd)
codeset=-1
code=-1

if(cmd=="BACK") or (cmd=="CANCEL") then
    codeset=8
    code=2
elseif (cmd=="OFF") then
    codeset=11
    code=0
elseif (cmd=="ON") then
    codeset=11
    code=1
elseif (cmd=="MENU") then
    codeset=4
    code=8
elseif (cmd=="UP") then
    codeset=3
    code=8
elseif (cmd=="DOWN") then
    codeset=3
    code=0
elseif (cmd=="LEFT") then
    codeset=3
    code=1
elseif (cmd=="RIGHT") then
    codeset=3
    code=7
elseif (cmd=="INFO") then
    codeset=0
    code=0
elseif (cmd=="CHANNEL_UP") then
    codeset=8
    code=1
elseif (cmd=="CHANNEL_DOWN") then
    codeset=8
    code=0
elseif (cmd=="ENTER") then
    codeset=3
    code=2
elseif (cmd=="GUIDE") then
    codeset=7
    code=1
elseif (cmd=="PULSE_VOL_DOWN") then
    codeset=5
    code=0
elseif (cmd=="PULSE_VOL_UP") then
    codeset=5
    code=1
elseif (cmd=="MUTE_TOGGLE") then
    codeset=5
    code=4
elseif (cmd=="SET_INPUT") then
    input = tostring(tParams["INPUT"])
    if (input=="1000") then
	   input = "HDMI-1"
    elseif (input=="1001") then
	   input = "HDMI-2"
    elseif (input=="1002") then
	   input = "HDMI-3"
    elseif (input=="1004") then
	   input = "TV"
    elseif (input=="1005") then
	   input = "TV"
    else
	   print("Input didn't match: "..input)
    end
    sendInput1(input)
    return
elseif (cmd=="SET_CHANNEL") then
    print("CHANNEL PARAMS: "..dump(tParams))
    channel = tostring(tParams["CHANNEL"])
    input = "TV"
    sendInput1(input)
    return
end

sendCmd(codeset, code)

end