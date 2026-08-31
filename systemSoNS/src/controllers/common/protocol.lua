local protocol = {}


protocol.PACKET_SIZE = 12

protocol.TYPE_MESSAGE = {
    UP = 1,
    DOWN = 0
}

---- BOTH ARE TRAMA FOR THE MESSAGE
protocol.BYTE_SENDUP = { 
    ----- HEADER --------  (for the heartbeat)
    SENDER_ID = 1,      -- 1 rto 9 drone    10 to 99 qupa  
    SEQ_COUNTER = 2,
    TIMESTAMP = 3,

    ----- TOPOLGY -------- (data of the topology)
    ROOT_ID = 4,
    PARENT_ID = 5,
    TREE_DEPTH = 6, 
    STATE = 7,      --- CONNECTED OR SEARCHING


    ----- TELEMETRY -------- (data sensing)
    ROLE = 8,
    POSITION = 9,
    ORIENTATION = 10,
    OBSTACLES = 11

}
protocol.BYTE_SENDDOWN = { 
    ----- HEADER --------  (for the heartbeat)
    SENDER_ID = 1,
    SEQ_COUNTER = 2,
    TIMESTAMP = 3,

    ----- TOPOLGY -------- (data of the topology)
    ROOT_ID = 4,
    PARENT_ID = 5,
    TREE_DEPTH = 6, 
    STATE = 7,      --- CONNECTED OR SEARCHING


    ----- COMMANDS -------- (data sensing)
    TARGET_POSITION = 8,
    TARGET_ORINTATION = 9,
}


function protocol.build_packet(field, type_message)
    local packet = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    
    packet[protocol.BYTE_SENDUP.SENDER_ID]   = field.sender_id or 0
    packet[protocol.BYTE_SENDUP.SEQ_COUNTER] = field.seq_counter or 0
    packet[protocol.BYTE_SENDUP.TIMESTAMP]   = field.timestamp or 0

    packet[protocol.BYTE_SENDUP.ROOT_ID]     = field.root_id or 0
    packet[protocol.BYTE_SENDUP.PARENT_ID]   = field.parent_id or 0
    packet[protocol.BYTE_SENDUP.TREE_DEPTH]  = field.tree_depth or 0
    packet[protocol.BYTE_SENDUP.STATE]       = field.state or 0

    if type_message == protocol.TYPE_MESSAGE.UP then
        packet[protocol.BYTE_SENDUP.ROLE]        = field.role or 0
        packet[protocol.BYTE_SENDUP.POSITION]    = field.position or 0
        packet[protocol.BYTE_SENDUP.ORIENTATION] = field.orientation or 0
        packet[protocol.BYTE_SENDUP.OBSTACLES]   = field.obstacles or 0

    elseif type_message == protocol.TYPE_MESSAGE.DOWN then
        packet[protocol.BYTE_SENDDOWN.TARGET_POSITION]   = field.target_position or 0
        packet[protocol.BYTE_SENDDOWN.TARGET_ORIENTATION] = field.target_orientation or 0
    end


    return packet
end


return protocol