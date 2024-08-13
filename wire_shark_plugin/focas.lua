focas_protocol = Proto("Focas", "Focas Protocol")
sync_code = ProtoField.uint32("Focas.Sync", "SYNC", base.DEC_HEX)
version = ProtoField.uint16("Focas.version", "VERSION", base.DEC_HEX)

request_type = ProtoField.uint8("Focas.request", "REQ_TYPE", base.DEC_HEX)
requestCodes = {
    [1] = "Request",
    [2] = "Response"
}
request_value = ProtoField.uint8("Focas.value", "REQ_VALUE", base.DEC_HEX, requestCodes)
total_request_length = ProtoField.uint16("Focas.totallength", "TOTAL_LENGTH", base.DEC_HEX) -- length plus 2
subpacket_count = ProtoField.uint16("Focas.subpacket", "SUB_COUNT", base.DEC_HEX)
request_length = ProtoField.uint16("Focas.reqLength", "REQ_LENGTH", base.DEC_HEX)
controlarea = {
    [1] = "CNC",
    [2] = "PMC"
}
control_type = ProtoField.uint16("Focas.cncpmc","CMC_PMC", base.DEC_HEX, controlarea) 
Func_field_1 = ProtoField.uint16("Focas.funcfield1", "FUNC_F1", base.DEC_HEX)
rCodes ={
    [14] = "Read CNC Param",
    [21] = "Read Macro",
    [22] = "Write Macro",
    [24] = "Read Sys info",
    [26] = "Read Alarm",
    [28] = "Read Program Number Main/Run",
    [29] = "Read Sequence Number",
    [31] = "Rewind Program",
    [32] = "Read Mdi",
    [33] = "Read G Code",
    [35] = "Read alarm Info",
    [36] = "Read actual Feedrate",
    [37] = "Read Actual Spindle speed",
    [38] = "Read Position",
    [48] = "Read Diagnosis",
    [64] = "Read actual SpindleSpeed load",
    [69] = "Get Time/Date",
    [70] = "Set Time/Date",
    [86] = "Servo Load",
    [97] = "Read Signal Name Operator Panel ?",
    [137] = "Axis Names ?",
    [138] = "Spiendle name ?",
    [139] = "axis names absolute ?",
    [141] = "Read Cnc Param (cncRdParam3)",
    [32769] = "Read Pmc"

}
Func_field_2 = ProtoField.uint16("Focas.funcfield2", "FUNC_F2", base.DEC_HEX, rCodes)
fill_field_1= ProtoField.uint32("Focas.fillfield1", "FILL_F1", base.DEC_HEX)
fill_field_2= ProtoField.uint16("Focas.fillfield2", "FILL_F2", base.DEC_HEX)
payload_length= ProtoField.uint16("Focas.payloadlength", "PAYLOAD", base.DEC_HEX)
remaining_bytes = ProtoField.bytes("Focas.remainbytes", "BYTES")

focas_protocol.fields = {
    sync_code,
    version,
    request_type,
    request_value,
    total_request_length,
    subpacket_count,
    request_length,
    control_type,
    Func_field_1,
    Func_field_2,
    fill_field_1,
    fill_field_2,
    payload_length,
    remaining_bytes
    }

function focas_protocol.dissector(buffer, pinfo, tree)
    offset = 0
    length = buffer:len()
    print(length)
    if length == 0 then return end
    

    pinfo.cols.protocol = focas_protocol.name

    local subtree = tree:add(focas_protocol, buffer(), "focas protocol data")
    subtree:add(sync_code, buffer(0,4))
    offset = offset + 4
    subtree:add(version, buffer(offset,2))
    offset = offset + 2
    subtree:add(request_type, buffer(offset,1))
    offset = offset + 1
    subtree:add(request_value, buffer(offset,1))
    offset = offset + 1
    subtree:add(total_request_length, buffer(offset,2))
    offset = offset + 2
    
    if length > offset then
        subtree:add(subpacket_count, buffer(offset,2))
        offset = offset + 2
    end
    if length > offset then
        subtree:add(request_length, buffer(offset,2))
        _req_length = buffer(offset,2):uint()
        offset = offset + 2
    end
    if length > offset then
        subtree:add(control_type, buffer(offset,2))
        offset = offset + 2
    end
    if length > offset then
        subtree:add(Func_field_1, buffer(offset,2))
        offset = offset + 2
        subtree:add(Func_field_2, buffer(offset,2))
        offset = offset + 2
        subtree:add(fill_field_1, buffer(offset,4))
        offset = offset + 4
        subtree:add(fill_field_2, buffer(offset,2))
        offset = offset + 2
        subtree:add(payload_length, buffer(offset,2))
        payload = buffer(offset,2):uint()
        offset = offset + 2
        subtree:add(remaining_bytes, buffer(offset,payload))
    end


end

local tcp_port = DissectorTable.get("tcp.port")
tcp_port:add(8193, focas_protocol)