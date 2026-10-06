local Protocol = {}


----------------------------------------------------------
----            ENUMS
----------------------------------------------------------


--- Enum All types of messages
---@enum Robot.StateCarGraph
Protocol.TypeMsg = {
    -- To send petition to recruiment
    RRECRUIMENT_MSG     = 1,
    -- Response of something 
    RESPONSE_MSG        = 2,
    -- Data of child's sensors 
    DATA_MSG            = 3,
    -- Target graph new 
    TARGET_GRAPH_MSG    = 4,
    -- COMMAND DIRECT CHILD
    COMMAND_MSG         = 5,
    -- PETITION FOR UNLIKE CHILD PARENT
    UNLIKE_MSG          = 6
}


--- Enum for state of graph
---@enum Robot.StateCarGraph
Protocol.ResponseMsg = {
    ACCEPT              = 1,
    REJECTED            = 2
}


-------------------------------------------------
---             ENUM/STRUCT MESSAGES
-------------------------------------------------

--- Enum layout for the recruiment message protocol 
--- Define the fixed index mapping for payload 
---@enum Protocol.BYTE_RECRUIMENT
Protocol.BYTE_RECRUIMENT = {

    -- Unique ID of the robot sending the message
    SENDER_ID       = 1,
    -- The type of message
    TYP_MSG         = 2,      
    -- The unique ID for message
    PACKET_ID       = 3,
    -- Total number of packets into which the message was divided
    QUANT_PACKETS   = 4,
    -- The current index of packet (MAX = CANT_PACKETS)
    INDEX_PACKET    = 5,
    -- The target id (if it is broadcast use 0)
    TARGET_ID       = 6,

    -- Robot Rank of sender
    SOSN_RANK       = 7,
    
}

--- Enum layout for response msg
--- Define the fixed index mapping for payload 
---@enum Protocol.BYTE_RESPONSE_MSG
Protocol.BYTE_RESPONSE_MSG = {

    -- Unique ID of the robot sending the message
    SENDER_ID       = 1,
    -- The type of message
    TYP_MSG         = 2,      
    -- The unique ID for message
    PACKET_ID       = 3,
    -- Total number of packets into which the message was divided
    QUANT_PACKETS   = 4,
    -- The current index of packet (MAX = CANT_PACKETS)
    INDEX_PACKET    = 5,
    -- The target id (if it is broadcast use 0)
    TARGET_ID       = 6,

    -- Robot Rank of sender
    RESPONSE       = 7,
    
}

--- Enum layout for unlike msg, it does not neccesity payload
--- Define the fixed index mapping for payload 
---@enum Protocol.BYTE_UNLIKE_ROBOTS
Protocol.BYTE_UNLIKE_ROBOTS = {

    -- Unique ID of the robot sending the message
    SENDER_ID       = 1,
    -- The type of message
    TYP_MSG         = 2,      
    -- The unique ID for message
    PACKET_ID       = 3,
    -- Total number of packets into which the message was divided
    QUANT_PACKETS   = 4,
    -- The current index of packet (MAX = CANT_PACKETS)
    INDEX_PACKET    = 5,
    -- The target id (if it is broadcast use 0)
    TARGET_ID       = 6,
    
}


-----------------------------------------------------
---                 Variables
-----------------------------------------------------

--- The Quantity of messages
---@type Integer
Protocol.NUM_TYPE_MSG = 6

--- Variable that store the prox data that will 
--- send, only for recuiment operation
---@type table
Protocol.msg_recruiment = {
    QUANT_MSG = 0,
    INDEX_MSG = 0,
    MSG = {}
}


-- Variable that store the prox data that will 
--- send, only for response operation
---@type table
Protocol.msg_response = {
    QUANT_MSG = 0,
    INDEX_MSG = 0,
    MSG = {}
}

-- Variable that store the prox data that will 
--- send, only for unlike operation
---@type table
Protocol.msg_unlike = {
    QUANT_MSG = 0,
    INDEX_MSG = 0,
    MSG = {}
}


--- Store all msg that was recived associated with recruiment
---@type table
Protocol.rec_msg_recruiment = {}  -- ID = {Is_complete: true or false, value = {}} (variable strcture)


--- Store all msg that was recived associated with response
---@type table
Protocol.rec_msg_response = {}  -- ID = {Is_complete: true or false, value = {}} (variable strcture)


--- Variable that store the pointer of message
---@type Integer
Protocol.pointer_Msg = 1;

---Variable that store the message that it is waiting
---@type Table
Protocol.stack_msg = {}  -- [id msg] = [Type of message]
-------------------------------------------------
---             FUNCTIONS
-------------------------------------------------


---


--- Function that select what type of messages will be
--- sent, there are differentes messages that need to 
--- be sent, and for one tick only one message can be sent
--- for that the function will work as manager 
function Protocol.select_type_msg()
    --log(Protocol.pointer_Msg )
    local msg = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0} 

    --Select the type of message to be sent  
    if((Protocol.pointer_Msg == Protocol.TypeMsg.RRECRUIMENT_MSG)
        and (Protocol.msg_recruiment.QUANT_MSG ~= 0) ) then

        --log("The recruiment message to be sent")
        msg = Protocol.msg_recruiment.MSG[Protocol.msg_recruiment.INDEX_MSG]
        
        if(Protocol.msg_recruiment.INDEX_MSG 
            < Protocol.msg_recruiment.QUANT_MSG) then
            -- we assure that the prox pointer will be the same msg type
            Protocol.pointer_Msg = Protocol.pointer_Msg - 1; 
            Protocol.msg_recruiment.INDEX_MSG = Protocol.msg_recruiment.INDEX_MSG + 1
            

        end
    else 
        --Protocol.pointer_Msg = Protocol.pointer_Msg + 1;
        -- if there is not a message then to point the next
        --log("there is not message for recruiment to be sent")
    end

    if((Protocol.pointer_Msg == Protocol.TypeMsg.RESPONSE_MSG)
        and (Protocol.msg_response.QUANT_MSG ~= 0) ) then
        --log("The response message to be sent")
        msg = Protocol.msg_response.MSG[Protocol.msg_response.INDEX_MSG + 1] --start with 0

        
        if((Protocol.msg_response.INDEX_MSG + 1) 
            < Protocol.msg_response.QUANT_MSG) then
            -- we assure that the prox pointer will be the same msg type
            Protocol.pointer_Msg = Protocol.pointer_Msg - 1; 
            Protocol.msg_response.INDEX_MSG = Protocol.msg_response.INDEX_MSG + 1
        else
            -- when there are not message more to be sent then we restaure         
            Protocol.msg_response.INDEX_MSG  = 0
            Protocol.msg_response.QUANT_MSG  = 0
            Protocol.msg_response.MSG  = {}
            
            
        end
    else
        --Protocol.pointer_Msg = Protocol.pointer_Msg + 1;
    end

    
    if((Protocol.pointer_Msg == Protocol.TypeMsg.UNLIKE_MSG)
        and (Protocol.msg_unlike.QUANT_MSG ~= 0) ) then
        log("The unlike message to be sent")
        msg = Protocol.msg_unlike.MSG[Protocol.msg_unlike.INDEX_MSG + 1] --start with 0

        
        if((Protocol.msg_unlike.INDEX_MSG + 1) 
            < Protocol.msg_unlike.QUANT_MSG) then
            -- we assure that the prox pointer will be the same msg type
            Protocol.pointer_Msg = Protocol.pointer_Msg - 1; 
            Protocol.msg_unlike.INDEX_MSG = Protocol.msg_unlike.INDEX_MSG + 1
        else
            -- when there are not message more to be sent then we restaure         
            Protocol.msg_unlike.INDEX_MSG  = 0
            Protocol.msg_unlike.QUANT_MSG  = 0
            Protocol.msg_unlike.MSG  = {}
            
        end
    else
        --Protocol.pointer_Msg = Protocol.pointer_Msg + 1;
    end    


    if(Protocol.pointer_Msg >= Protocol.NUM_TYPE_MSG)
         then Protocol.pointer_Msg = 0 end;
    Protocol.pointer_Msg = Protocol.pointer_Msg + 1;

    return msg
end



--- Function that encode the values to send
--- @param field Table The elements for construction[see BYTE_RECRUIMENT]
function Protocol.build_recruitment_packet(field)
    local packet = {}
    for i = 1, 64 do
        packet[i] = 0
    end

    packet[Protocol.BYTE_RECRUIMENT.SENDER_ID]      = field.sender_id or 0
    packet[Protocol.BYTE_RECRUIMENT.TYP_MSG]        = field.type_msg or 0
    packet[Protocol.BYTE_RECRUIMENT.PACKET_ID]      = field.packet_id or 0
    packet[Protocol.BYTE_RECRUIMENT.QUANT_PACKETS]  = field.quant_packets or 0
    packet[Protocol.BYTE_RECRUIMENT.INDEX_PACKET]   = field.index_packet or 0
    packet[Protocol.BYTE_RECRUIMENT.TARGET_ID]      = field.target_id or 0
    packet[Protocol.BYTE_RECRUIMENT.SOSN_RANK]      = field.sosn_rank or 0

    Protocol.msg_recruiment.QUANT_MSG = 1
    Protocol.msg_recruiment.INDEX_MSG = 1
    Protocol.msg_recruiment.MSG[Protocol.msg_recruiment.INDEX_MSG] = packet;
    
end

--- func that decode the data and store to the correct variable
---@param data tabla data recived
---@param currentSoSNRank Integer the rank of the robot
---@param lastSoSNRoot Integer the last id parent robot
function Protocol.decode_recruitment_packet(data, currentSoSNRank, lastSoSNRoot)
    if type(data) ~= "table" or #data < 64 then
        return {valid = false, error = "packet too short or invalid"}
    end

    local decoded = {
        valid = true,
        header = {
            sender_id     = data[Protocol.BYTE_RECRUIMENT.SENDER_ID],
            type_msg      = data[Protocol.BYTE_RECRUIMENT.TYP_MSG],
            packet_id     = data[Protocol.BYTE_RECRUIMENT.PACKET_ID],
            quant_packets = data[Protocol.BYTE_RECRUIMENT.QUANT_PACKETS],
            index_packet  = data[Protocol.BYTE_RECRUIMENT.INDEX_PACKET],
            target_id     = data[Protocol.BYTE_RECRUIMENT.TARGET_ID],
        },
        payload = {
            sosn_rank     = data[Protocol.BYTE_RECRUIMENT.SOSN_RANK]
        }
    }
    -- add the msg for recruiment only if it is from a better robot (the lower rank)
    if((decoded.payload.sosn_rank < currentSoSNRank) and 
        (decoded.header.sender_id ~= lastSoSNRoot)) then
        local is_comp = (decoded.header.quant_packets == decoded.header.index_packet)
        Protocol.rec_msg_recruiment[decoded.header.sender_id] = {
            is_complete = is_comp,
            msg = decoded
        }
        --log(decoded.payload.sosn_rank)
        --[[
        for i, data in pairs(decoded.payload) do
            --log("entro al for")
            Protocol.rec_msg_recruiment[decoded.header.sender_id][i] = data
        end
        ]]
    end
end

--- Function that make and store response msg
--- @param field Table The elements for construction[see BYTE_RESPONSE_MSG]
function Protocol.build_response_msg(field)
    local packet = {}
    for i = 1, 64 do
        packet[i] = 0
    end

    packet[Protocol.BYTE_RESPONSE_MSG.SENDER_ID]      = field.sender_id or 0
    packet[Protocol.BYTE_RESPONSE_MSG.TYP_MSG]        = field.type_msg or 0
    packet[Protocol.BYTE_RESPONSE_MSG.PACKET_ID]      = field.packet_id or 0
    packet[Protocol.BYTE_RESPONSE_MSG.QUANT_PACKETS]  = field.quant_packets or 0
    packet[Protocol.BYTE_RESPONSE_MSG.INDEX_PACKET]   = field.index_packet or 0
    packet[Protocol.BYTE_RESPONSE_MSG.TARGET_ID]      = field.target_id or 0
    packet[Protocol.BYTE_RESPONSE_MSG.RESPONSE]       = field.response or 0

    -- the message must be accumalate
    Protocol.msg_response.QUANT_MSG = Protocol.msg_response.QUANT_MSG + 1
    Protocol.msg_response.MSG[Protocol.msg_response.QUANT_MSG] = packet; -- add new message

    

end


--- func that decode the data and store to the correct variable
---@param data tabla data recived
function Protocol.decode_response_msg(data)
    if type(data) ~= "table" or #data < 64 then
        return {valid = false, error = "packet too short or invalid"}
    end

    local decoded = {
        valid = true,
        header = {
            sender_id     = data[Protocol.BYTE_RESPONSE_MSG.SENDER_ID],
            type_msg      = data[Protocol.BYTE_RESPONSE_MSG.TYP_MSG],
            packet_id     = data[Protocol.BYTE_RESPONSE_MSG.PACKET_ID],
            quant_packets = data[Protocol.BYTE_RESPONSE_MSG.QUANT_PACKETS],
            index_packet  = data[Protocol.BYTE_RESPONSE_MSG.INDEX_PACKET],
            target_id     = data[Protocol.BYTE_RESPONSE_MSG.TARGET_ID],
        },
        payload = {
            response     = data[Protocol.BYTE_RESPONSE_MSG.RESPONSE]
        }
    }

    local is_comp = (decoded.header.quant_packets == decoded.header.index_packet)
    Protocol.rec_msg_response[decoded.header.sender_id] = {
        is_complete = is_comp,
        msg = decoded
    }


end



--- Function that make and store response msg
--- @param field Table The elements for construction[see BYTE_UNLIKE_ROBOTS]
function Protocol.build_unlike_msg(field)
    local packet = {}
    for i = 1, 64 do
        packet[i] = 0
    end

    packet[Protocol.BYTE_UNLIKE_ROBOTS.SENDER_ID]      = field.sender_id or 0
    packet[Protocol.BYTE_UNLIKE_ROBOTS.TYP_MSG]        = field.type_msg or 0
    packet[Protocol.BYTE_UNLIKE_ROBOTS.PACKET_ID]      = field.packet_id or 0
    packet[Protocol.BYTE_UNLIKE_ROBOTS.QUANT_PACKETS]  = field.quant_packets or 0
    packet[Protocol.BYTE_UNLIKE_ROBOTS.INDEX_PACKET]   = field.index_packet or 0
    packet[Protocol.BYTE_UNLIKE_ROBOTS.TARGET_ID]      = field.target_id or 0

    -- the message must be accumalate
    Protocol.msg_unlike.QUANT_MSG = Protocol.msg_unlike.QUANT_MSG + 1
    Protocol.msg_unlike.MSG[Protocol.msg_unlike.QUANT_MSG] = packet; -- add new message
end


return Protocol