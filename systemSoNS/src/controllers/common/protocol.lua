local protocol = {}


protocol.PACKET_SIZE = 12

protocol.TYPE_MESSAGE = {
    UP = 1,
    DOWN = 0
}

-- message

protocol.BYTE_RECRUIMENT = {
    SENDER_ID = 1,
    TYP_MSG = 2,

    SOSN_RANK = 3,
    CARDINALITY = 4,
    TYPE_ROBOT = 5,

    -- the next id is for know what robot was accept 
    -- and do not generate a errors
    RESPONSE_ID = 6, 
    STATE_RECRUITMENT = 7   -- 1 ACCEPT  2 REJECTED 3 AWAITING
}

---- BOTH ARE TRAMA FOR THE MESSAGE
protocol.BYTE_SENDUP = { 
    ----- HEADER --------  (for the heartbeat)
    SENDER_ID = 1,      -- 1 rto 9 drone    10 to 99 qupa  
    TYP_MSG = 2,
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
    TYP_MSG = 2,
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


protocol.BYTE_SEND_TOPOLOGY = {
    
    SENDER_ID = 1,
    TYP_MSG = 2,

    DESTINITY = 3,
    ID_GRAPH1 = 4,
    ID_GRAPH2 = 5,
    ID_GRAPH3 = 6
}

protocol.BYTE_RESP_REC_TARGET = {
    SENDER_ID = 1,
    TYP_MSG = 2,

    RESPONSE = 3,  -- 1 loaded    
}

protocol.BYTE_SEND_INSTRUCTIONS = {
    SENDER_ID = 1,
    TYP_MSG = 2,

    DESTINITY = 3,
    TAR_POS_X = 4,
    TAR_POS_y = 5,
    TAR_POS_Z = 6,

    TAR_Q_1 = 7,
    TAR_Q_2 = 8,
    TAR_Q_3 = 9,
    TAR_Q_4 = 10
}

protocol.BYTE_SENDDATA = {
    -- UPSTREAM
    SENDER_ID = 1,
    TYP_MSG = 2,

    DESTNINTY = 3,
    CARD_DRONE = 4,
    CARD_BLIMP = 5,
    CARD_QUPA = 6,
    CARD_HIGH = 7,

}

function protocol.build_packet(field, type_message)
    local packet = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    
    packet[protocol.BYTE_SENDUP.SENDER_ID]   = field.sender_id or 0
    packet[protocol.BYTE_SENDUP.TYP_MSG] = field.typ_msg or 0
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



function protocol.recruitment_msg(field)
    local packet = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    packet[protocol.BYTE_RECRUIMENT.SENDER_ID] = field.sender_id or 0
    packet[protocol.BYTE_RECRUIMENT.TYP_MSG] = field.typ_msg or 0
    packet[protocol.BYTE_RECRUIMENT.SOSN_RANK] = field.sosn_rank or 0
    packet[protocol.BYTE_RECRUIMENT.CARDINALITY] = field.cardinality or 0
    packet[protocol.BYTE_RECRUIMENT.TYPE_ROBOT] = field.type_robot or 0
    packet[protocol.BYTE_RECRUIMENT.RESPONSE_ID] = field.response_id or 0
    packet[protocol.BYTE_RECRUIMENT.STATE_RECRUITMENT] = field.state_recruiment or 0
    return packet
end

function protocol.decode_msg(data)
    if type(data) ~= "table" or #data < protocol.PACKET_SIZE then
        return {valid = false, error = "packet too short"}
    end

    local decoded = {
        valid = true,
        sender_id = data[protocol.BYTE_RECRUIMENT.SENDER_ID],
        typ_msg = data[protocol.BYTE_RECRUIMENT.TYP_MSG],
        sosn_rank = data[protocol.BYTE_RECRUIMENT.SOSN_RANK],
        cardinality = data[protocol.BYTE_RECRUIMENT.CARDINALITY],
        type_robot = data[protocol.BYTE_RECRUIMENT.TYPE_ROBOT],
        response_id = data[protocol.BYTE_RECRUIMENT.RESPONSE_ID],
        state_recruiment = data[protocol.BYTE_RECRUIMENT.STATE_RECRUITMENT]
    }

    return decoded
end

function protocol.send_topology_msg(field)
    local packet = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    packet[protocol.BYTE_SEND_TOPOLOGY.SENDER_ID] = field.sender_id or 0
    packet[protocol.BYTE_SEND_TOPOLOGY.TYP_MSG] = field.typ_msg or 0
    packet[protocol.BYTE_SEND_TOPOLOGY.DESTINITY] = field.destinity or 0
    packet[protocol.BYTE_SEND_TOPOLOGY.ID_GRAPH1] = field.id_graph1 or 0
    packet[protocol.BYTE_SEND_TOPOLOGY.ID_GRAPH2] = field.id_graph2 or 0
    packet[protocol.BYTE_SEND_TOPOLOGY.ID_GRAPH3] = field.id_graph3 or 0
    return packet
end

function protocol.resp_rec_target_msg(field)
    local packet = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    packet[protocol.BYTE_RESP_REC_TARGET.SENDER_ID] = field.sender_id or 0
    packet[protocol.BYTE_RESP_REC_TARGET.TYP_MSG] = field.typ_msg or 0
    packet[protocol.BYTE_RESP_REC_TARGET.RESPONSE] = field.response or 0
    return packet
end


function protocol.decode_send_topology_msg(data)
    if type(data) ~= "table" or #data < protocol.PACKET_SIZE then
        return {valid = false, error = "packet too short"}
    end

    local decoded = {
        valid = true,
        sender_id = data[protocol.BYTE_SEND_TOPOLOGY.SENDER_ID],
        typ_msg = data[protocol.BYTE_SEND_TOPOLOGY.TYP_MSG],
        destinity = data[protocol.BYTE_SEND_TOPOLOGY.DESTINITY],
        id_graph1 = data[protocol.BYTE_SEND_TOPOLOGY.ID_GRAPH1],
        id_graph2 = data[protocol.BYTE_SEND_TOPOLOGY.ID_GRAPH2],
        id_graph3 = data[protocol.BYTE_SEND_TOPOLOGY.ID_GRAPH3]
    }

    return decoded
end

function protocol.decode_resp_rec_target_msg(data)
    if type(data) ~= "table" or #data < protocol.PACKET_SIZE then
        return {valid = false, error = "packet too short"}
    end

    local decoded = {
        valid = true,
        sender_id = data[protocol.BYTE_RESP_REC_TARGET.SENDER_ID],
        typ_msg = data[protocol.BYTE_RESP_REC_TARGET.TYP_MSG],
        response = data[protocol.BYTE_RESP_REC_TARGET.RESPONSE]
    }

    return decoded
end


function protocol.send_instructions_msg(field)
    --local packet = table.create(64, 0)
    local packet = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    packet[protocol.BYTE_SEND_INSTRUCTIONS.SENDER_ID] = field.sender_id or 0
    packet[protocol.BYTE_SEND_INSTRUCTIONS.TYP_MSG] = field.typ_msg or 0
    packet[protocol.BYTE_SEND_INSTRUCTIONS.DESTINITY] = field.destinity or 0
    
    packet[protocol.BYTE_SEND_INSTRUCTIONS.TAR_POS_X] = field.tar_pos_x or 0
    packet[protocol.BYTE_SEND_INSTRUCTIONS.TAR_POS_y] = field.tar_pos_y or 0
    packet[protocol.BYTE_SEND_INSTRUCTIONS.TAR_POS_Z] = field.tar_pos_z or 0

    packet[protocol.BYTE_SEND_INSTRUCTIONS.TAR_Q_1] = field.tar_q_1 or 0
    packet[protocol.BYTE_SEND_INSTRUCTIONS.TAR_Q_2] = field.tar_q_2 or 0
    packet[protocol.BYTE_SEND_INSTRUCTIONS.TAR_Q_3] = field.tar_q_3 or 0
    packet[protocol.BYTE_SEND_INSTRUCTIONS.TAR_Q_4] = field.tar_q_4 or 0
    return packet
end


function protocol.decode_send_instructions_msg(data)
    if type(data) ~= "table" or #data < protocol.PACKET_SIZE then
        return {valid = false, error = "packet too short"}
    end

    local decoded = {
        valid = true,
        sender_id = data[protocol.BYTE_SEND_INSTRUCTIONS.SENDER_ID],
        typ_msg = data[protocol.BYTE_SEND_INSTRUCTIONS.TYP_MSG],
        destinity = data[protocol.BYTE_SEND_INSTRUCTIONS.DESTINITY],
        
        tar_pos_x = data[protocol.BYTE_SEND_INSTRUCTIONS.TAR_POS_X],
        tar_pos_y = data[protocol.BYTE_SEND_INSTRUCTIONS.TAR_POS_y],
        tar_pos_z = data[protocol.BYTE_SEND_INSTRUCTIONS.TAR_POS_Z],

        tar_q_1 = data[protocol.BYTE_SEND_INSTRUCTIONS.TAR_Q_1],
        tar_q_2 = data[protocol.BYTE_SEND_INSTRUCTIONS.TAR_Q_2],
        tar_q_3 = data[protocol.BYTE_SEND_INSTRUCTIONS.TAR_Q_3],
        tar_q_4 = data[protocol.BYTE_SEND_INSTRUCTIONS.TAR_Q_4]
    }

    return decoded
end



return protocol