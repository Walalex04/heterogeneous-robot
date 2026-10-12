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


--- Enum layout for commant msg, it does not neccesity payload
--- Define the fixed index mapping for payload 
---@enum Protocol.BYTE_COMMAND_ROBOTS
Protocol.BYTE_COMMAND_ROBOTS = {

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


    TAR_POS_X_1     = 7,

    TAR_POS_X_2     = 8,

    TAR_POS_Y_1     = 9,

    TAR_POS_Y_2     = 10,

    TAR_POS_Z_1     = 11,

    TAR_POS_Z_2     = 12,

    TAR_YAW_1       = 13,

    TAR_YAW_2       = 14

}


--- Enum layout for target send, it will more than 1
--- Define the fixed index mapping for payload 
---@enum Protocol.BYTE_UNLIKE_ROBOTS
Protocol.BYTE_TARGETGRAPH_ROBOTS = {

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



    LEVEL_CHILDS_1   = 7,

    TYPE_CHILD_1    = 8,

    ID_CHILD_1_1      = 9,

    ID_CHILD_2_1  = 10,

    POS_X1_CHILD_1  = 11,

    POS_X2_CHILD_1  = 12,

    POS_Y1_CHILD_1  = 13,
    
    POS_Y2_CHILD_1  = 14,

    POS_Z1_CHILD_1  = 15,

    POS_Z2_CHILD_1  = 16,

    YAW_1_CHILD_1   = 17,

    YAW_2_CHILD_1   = 18, 


    LEVEL_CHILDS_2   = 19,

    TYPE_CHILD_2    = 20,

    ID_CHILD_1_2      = 21,

    ID_CHILD_2_2   = 22,

    POS_X1_CHILD_2  = 23,

    POS_X2_CHILD_2  = 24,

    POS_Y1_CHILD_2  = 25,
    
    POS_Y2_CHILD_2  = 26,

    POS_Z1_CHILD_2  = 27,

    POS_Z2_CHILD_2  = 28,

    YAW_1_CHILD_2   = 29,

    YAW_2_CHILD_2   = 30, 


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



-- Variable that store the prox data that will 
--- send, only for target operation
---@type table
Protocol.msg_targraph = {
    QUANT_MSG = 0,
    INDEX_MSG = 0,
    MSG = {}
}

-- Variable that store the prox data that will 
--- send, only for command operation
---@type table
Protocol.msg_command = {
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


--- Store all msg that was recived associated with unlike
---@type table
Protocol.rec_msg_unlike = {}  -- ID = {Is_complete: true or false, value = {}} (variable strcture)


-- Store all msg that was recived associated with unlike
---@type table
Protocol.rec_msg_unlike_child = {}  -- ID = {Is_complete: true or false, value = {}} (variable strcture)


--- Store all msg that was recived associated with target
---@type table
Protocol.rec_msg_targetGraph = {}


--- Store all msg that was recived associated with commands
---@type table
Protocol.rec_msg_command = {}


--- Variable that store the pointer of message
---@type Integer
Protocol.pointer_Msg = 1;

---Variable that store the message that it is waiting
---@type Table
Protocol.stack_msg = {}  -- [id msg] = [Type of message]
-------------------------------------------------
---             FUNCTIONS
-------------------------------------------------



--- Function that select what type of messages will be
--- sent, there are differentes messages that need to 
--- be sent, and for one tick only one message can be sent
--- for that the function will work as manager 
function Protocol.select_type_msg()
    
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




    if((Protocol.pointer_Msg == Protocol.TypeMsg.TARGET_GRAPH_MSG)
        and (Protocol.msg_targraph.QUANT_MSG ~= 0) ) then
        --log("The target message to be sent")
        msg = Protocol.msg_targraph.MSG[Protocol.msg_targraph.INDEX_MSG + 1] --start with 0

        
        if((Protocol.msg_targraph.INDEX_MSG + 1) 
            < Protocol.msg_targraph.QUANT_MSG) then
            -- we assure that the prox pointer will be the same msg type
            Protocol.pointer_Msg = Protocol.pointer_Msg - 1; 
            Protocol.msg_targraph.INDEX_MSG = Protocol.msg_targraph.INDEX_MSG + 1
        else
            -- when there are not message more to be sent then we restaure         
            Protocol.msg_targraph.INDEX_MSG  = 0
            Protocol.msg_targraph.QUANT_MSG  = 0
            Protocol.msg_targraph.MSG  = {}
            
        end
    else
        --Protocol.pointer_Msg = Protocol.pointer_Msg + 1;
    end   

     if((Protocol.pointer_Msg == Protocol.TypeMsg.COMMAND_MSG)
        and (Protocol.msg_command.QUANT_MSG ~= 0) ) then
        --log("The target message to be sent")
        msg = Protocol.msg_command.MSG[Protocol.msg_command.INDEX_MSG + 1] --start with 0

        
        if((Protocol.msg_command.INDEX_MSG + 1) 
            < Protocol.msg_command.QUANT_MSG) then
            -- we assure that the prox pointer will be the same msg type
            Protocol.pointer_Msg = Protocol.pointer_Msg - 1; 
            Protocol.msg_command.INDEX_MSG = Protocol.msg_command.INDEX_MSG + 1
        else
            -- when there are not message more to be sent then we restaure         
            Protocol.msg_command.INDEX_MSG  = 0
            Protocol.msg_command.QUANT_MSG  = 0
            Protocol.msg_command.MSG  = {}
            
        end
    else
        --Protocol.pointer_Msg = Protocol.pointer_Msg + 1;
    end   

        
    if((Protocol.pointer_Msg == Protocol.TypeMsg.UNLIKE_MSG)
        and (Protocol.msg_unlike.QUANT_MSG > 0) ) then
        --log("sending unlike msg")
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

    if(Protocol.pointer_Msg >= Protocol.NUM_TYPE_MSG+1)
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
    log("the quant is " .. Protocol.msg_unlike.QUANT_MSG)
end



--- Function that make and store unlike msg
--- @param data tabla data recived
function Protocol.decode_unlike_msg(data)
     if type(data) ~= "table" or #data < 64 then
        return {valid = false, error = "packet too short or invalid"}
    end

    local decoded = {
        valid = true,
        header = {
            sender_id     = data[Protocol.BYTE_UNLIKE_ROBOTS.SENDER_ID],
            type_msg      = data[Protocol.BYTE_UNLIKE_ROBOTS.TYP_MSG],
            packet_id     = data[Protocol.BYTE_UNLIKE_ROBOTS.PACKET_ID],
            quant_packets = data[Protocol.BYTE_UNLIKE_ROBOTS.QUANT_PACKETS],
            index_packet  = data[Protocol.BYTE_UNLIKE_ROBOTS.INDEX_PACKET],
            target_id     = data[Protocol.BYTE_UNLIKE_ROBOTS.TARGET_ID],
        }
    }  

    local is_comp = (decoded.header.quant_packets == decoded.header.index_packet)
    Protocol.rec_msg_unlike[decoded.header.sender_id] = {
        is_complete = is_comp,
        msg = decoded
    } 
end

--- Function that make and store unlike msg
--- @param data tabla data recived
function Protocol.decode_unlike_msg_fchild(data)
     if type(data) ~= "table" or #data < 64 then
        return {valid = false, error = "packet too short or invalid"}
    end

    local decoded = {
        valid = true,
        header = {
            sender_id     = data[Protocol.BYTE_UNLIKE_ROBOTS.SENDER_ID],
            type_msg      = data[Protocol.BYTE_UNLIKE_ROBOTS.TYP_MSG],
            packet_id     = data[Protocol.BYTE_UNLIKE_ROBOTS.PACKET_ID],
            quant_packets = data[Protocol.BYTE_UNLIKE_ROBOTS.QUANT_PACKETS],
            index_packet  = data[Protocol.BYTE_UNLIKE_ROBOTS.INDEX_PACKET],
            target_id     = data[Protocol.BYTE_UNLIKE_ROBOTS.TARGET_ID],
        }
    }  

    local is_comp = (decoded.header.quant_packets == decoded.header.index_packet)
    Protocol.rec_msg_unlike_child[decoded.header.sender_id] = {
        is_complete = is_comp,
        msg = decoded
    } 
end




--- Function that make and store response msg
--- @param field Table The elements for construction[see BYTE_UNLIKE_ROBOTS]
function Protocol.build_target_msg(field)
    local packet = {}
    for i = 1, 64 do
        packet[i] = 0
    end

    packet[Protocol.BYTE_TARGETGRAPH_ROBOTS.SENDER_ID]      = field.sender_id or 0
    packet[Protocol.BYTE_TARGETGRAPH_ROBOTS.TYP_MSG]        = field.type_msg or 0
    packet[Protocol.BYTE_TARGETGRAPH_ROBOTS.PACKET_ID]      = field.packet_id or 0
    packet[Protocol.BYTE_TARGETGRAPH_ROBOTS.QUANT_PACKETS]  = field.quant_packets or 0
    packet[Protocol.BYTE_TARGETGRAPH_ROBOTS.INDEX_PACKET]   = field.index_packet or 0
    packet[Protocol.BYTE_TARGETGRAPH_ROBOTS.TARGET_ID]      = field.target_id or 0


    packet[Protocol.BYTE_TARGETGRAPH_ROBOTS.LEVEL_CHILDS_1]   = field.level_child_1 or 0
    packet[Protocol.BYTE_TARGETGRAPH_ROBOTS.TYPE_CHILD_1]     = field.type_child_1 or 0
    packet[Protocol.BYTE_TARGETGRAPH_ROBOTS.ID_CHILD_1_1]     = field.id_child_1_1 or 0
    packet[Protocol.BYTE_TARGETGRAPH_ROBOTS.ID_CHILD_2_1]     = field.id_child_2_1 or 0
    packet[Protocol.BYTE_TARGETGRAPH_ROBOTS.POS_X1_CHILD_1]   = field.pos_x1_child_1 or 0
    packet[Protocol.BYTE_TARGETGRAPH_ROBOTS.POS_X2_CHILD_1]   = field.pos_x2_child_1 or 0
    packet[Protocol.BYTE_TARGETGRAPH_ROBOTS.POS_Y1_CHILD_1]   = field.pos_y1_child_1 or 0
    packet[Protocol.BYTE_TARGETGRAPH_ROBOTS.POS_Y2_CHILD_1]   = field.pos_y2_child_1 or 0
    packet[Protocol.BYTE_TARGETGRAPH_ROBOTS.POS_Z1_CHILD_1]   = field.pos_z1_child_1 or 0
    packet[Protocol.BYTE_TARGETGRAPH_ROBOTS.POS_Z2_CHILD_1]   = field.pos_z2_child_1 or 0
    packet[Protocol.BYTE_TARGETGRAPH_ROBOTS.YAW_1_CHILD_1]    = field.yaw_1_child_1 or 0
    packet[Protocol.BYTE_TARGETGRAPH_ROBOTS.YAW_2_CHILD_1]    = field.yaw_2_child_1 or 0

    -- CHILD 2 (Índices del 19 al 30)
    packet[Protocol.BYTE_TARGETGRAPH_ROBOTS.LEVEL_CHILDS_2]   = field.level_child_2 or 0
    packet[Protocol.BYTE_TARGETGRAPH_ROBOTS.TYPE_CHILD_2]     = field.type_child_2 or 0
    packet[Protocol.BYTE_TARGETGRAPH_ROBOTS.ID_CHILD_1_2]     = field.id_child_1_2 or 0
    packet[Protocol.BYTE_TARGETGRAPH_ROBOTS.ID_CHILD_2_2]    = field.id_child_2_2 or 0 
    packet[Protocol.BYTE_TARGETGRAPH_ROBOTS.POS_X1_CHILD_2]   = field.pos_x1_child_2 or 0
    packet[Protocol.BYTE_TARGETGRAPH_ROBOTS.POS_X2_CHILD_2]   = field.pos_x2_child_2 or 0
    packet[Protocol.BYTE_TARGETGRAPH_ROBOTS.POS_Y1_CHILD_2]   = field.pos_y1_child_2 or 0
    packet[Protocol.BYTE_TARGETGRAPH_ROBOTS.POS_Y2_CHILD_2]   = field.pos_y2_child_2 or 0
    packet[Protocol.BYTE_TARGETGRAPH_ROBOTS.POS_Z1_CHILD_2]   = field.pos_z1_child_2 or 0
    packet[Protocol.BYTE_TARGETGRAPH_ROBOTS.POS_Z2_CHILD_2]   = field.pos_z2_child_2 or 0
    packet[Protocol.BYTE_TARGETGRAPH_ROBOTS.YAW_1_CHILD_2]    = field.yaw_1_child_2 or 0
    packet[Protocol.BYTE_TARGETGRAPH_ROBOTS.YAW_2_CHILD_2]    = field.yaw_2_child_2 or 0

    -- the message must be accumalate
    --log(string.format("we add a new message with id %i, the total quantity is %i and the current index %i and this will send to %i",
    --                 field.packet_id, field.quant_packets, field.index_packet, field.target_id ))
    Protocol.msg_targraph.QUANT_MSG = Protocol.msg_targraph.QUANT_MSG + 1
    Protocol.msg_targraph.MSG[Protocol.msg_targraph.QUANT_MSG] = packet; -- add new message
end

--- func that decode the data and store to the correct variable
--- @param data tabla data recived
function Protocol.decode_target_msg(data)
    if type(data) ~= "table" or #data < 64 then
        return {valid = false, error = "packet too short or invalid"}
    end

    local decoded = {
        valid = true,
        header = {
            sender_id     = data[Protocol.BYTE_TARGETGRAPH_ROBOTS.SENDER_ID],
            type_msg      = data[Protocol.BYTE_TARGETGRAPH_ROBOTS.TYP_MSG],
            packet_id     = data[Protocol.BYTE_TARGETGRAPH_ROBOTS.PACKET_ID],
            quant_packets = data[Protocol.BYTE_TARGETGRAPH_ROBOTS.QUANT_PACKETS],
            index_packet  = data[Protocol.BYTE_TARGETGRAPH_ROBOTS.INDEX_PACKET],
            target_id     = data[Protocol.BYTE_TARGETGRAPH_ROBOTS.TARGET_ID],
        },
        payload = {
            level_child_1 = data[Protocol.BYTE_TARGETGRAPH_ROBOTS.LEVEL_CHILDS_1],
            type_child_1  = data[Protocol.BYTE_TARGETGRAPH_ROBOTS.TYPE_CHILD_1],
            id_child_1_1  = data[Protocol.BYTE_TARGETGRAPH_ROBOTS.ID_CHILD_1_1],
            id_child_2_1  = data[Protocol.BYTE_TARGETGRAPH_ROBOTS.ID_CHILD_2_1],
            pos_x1_child_1 = data[Protocol.BYTE_TARGETGRAPH_ROBOTS.POS_X1_CHILD_1],
            pos_x2_child_1 = data[Protocol.BYTE_TARGETGRAPH_ROBOTS.POS_X2_CHILD_1],
            pos_y1_child_1 = data[Protocol.BYTE_TARGETGRAPH_ROBOTS.POS_Y1_CHILD_1],
            pos_y2_child_1 = data[Protocol.BYTE_TARGETGRAPH_ROBOTS.POS_Y2_CHILD_1],
            pos_z1_child_1 = data[Protocol.BYTE_TARGETGRAPH_ROBOTS.POS_Z1_CHILD_1],
            pos_z2_child_1 = data[Protocol.BYTE_TARGETGRAPH_ROBOTS.POS_Z2_CHILD_1],
            yaw_1_child_1  = data[Protocol.BYTE_TARGETGRAPH_ROBOTS.YAW_1_CHILD_1],
            yaw_2_child_1  = data[Protocol.BYTE_TARGETGRAPH_ROBOTS.YAW_2_CHILD_1],

            level_child_2 = data[Protocol.BYTE_TARGETGRAPH_ROBOTS.LEVEL_CHILDS_2],
            type_child_2  = data[Protocol.BYTE_TARGETGRAPH_ROBOTS.TYPE_CHILD_2],
            id_child_1_2  = data[Protocol.BYTE_TARGETGRAPH_ROBOTS.ID_CHILD_1_2],
            id_child_2_2  = data[Protocol.BYTE_TARGETGRAPH_ROBOTS.ID_CHILD_2_2],
            pos_x1_child_2 = data[Protocol.BYTE_TARGETGRAPH_ROBOTS.POS_X1_CHILD_2],
            pos_x2_child_2 = data[Protocol.BYTE_TARGETGRAPH_ROBOTS.POS_X2_CHILD_2],
            pos_y1_child_2 = data[Protocol.BYTE_TARGETGRAPH_ROBOTS.POS_Y1_CHILD_2],
            pos_y2_child_2 = data[Protocol.BYTE_TARGETGRAPH_ROBOTS.POS_Y2_CHILD_2],
            pos_z1_child_2 = data[Protocol.BYTE_TARGETGRAPH_ROBOTS.POS_Z1_CHILD_2],
            pos_z2_child_2 = data[Protocol.BYTE_TARGETGRAPH_ROBOTS.POS_Z2_CHILD_2],
            yaw_1_child_2  = data[Protocol.BYTE_TARGETGRAPH_ROBOTS.YAW_1_CHILD_2],
            yaw_2_child_2  = data[Protocol.BYTE_TARGETGRAPH_ROBOTS.YAW_2_CHILD_2],
        }
    }

    local is_comp = (decoded.header.quant_packets == decoded.header.index_packet)
    local sender_id = decoded.header.sender_id
    local packet_id = decoded.header.packet_id

    Protocol.rec_msg_targetGraph = Protocol.rec_msg_targetGraph or {}
    Protocol.rec_msg_targetGraph[sender_id] = Protocol.rec_msg_targetGraph[sender_id] or {}
    Protocol.rec_msg_targetGraph[sender_id][packet_id] = Protocol.rec_msg_targetGraph[sender_id][packet_id] or { msg = {} }

    Protocol.rec_msg_targetGraph[sender_id][packet_id].is_complete = is_comp
    table.insert(Protocol.rec_msg_targetGraph[sender_id][packet_id].msg, decoded)
end

--- Function that make and store command msg
--- @param field Table The elements for construction
function Protocol.build_command_msg(field)
    local packet = {}
    for i = 1, 64 do
        packet[i] = 0
    end
    
    packet[Protocol.BYTE_COMMAND_ROBOTS.SENDER_ID]     = field.sender_id or 0
    packet[Protocol.BYTE_COMMAND_ROBOTS.TYP_MSG]       = field.type_msg or 0
    packet[Protocol.BYTE_COMMAND_ROBOTS.PACKET_ID]     = field.packet_id or 0
    packet[Protocol.BYTE_COMMAND_ROBOTS.QUANT_PACKETS] = field.quant_packets or 0
    packet[Protocol.BYTE_COMMAND_ROBOTS.INDEX_PACKET]  = field.index_packet or 0
    packet[Protocol.BYTE_COMMAND_ROBOTS.TARGET_ID]     = field.target_id or 0

    packet[Protocol.BYTE_COMMAND_ROBOTS.TAR_POS_X_1]   = field.tar_pos_x_1 or 0
    packet[Protocol.BYTE_COMMAND_ROBOTS.TAR_POS_X_2]   = field.tar_pos_x_2 or 0
    packet[Protocol.BYTE_COMMAND_ROBOTS.TAR_POS_Y_1]   = field.tar_pos_y_1 or 0
    packet[Protocol.BYTE_COMMAND_ROBOTS.TAR_POS_Y_2]   = field.tar_pos_y_2 or 0
    packet[Protocol.BYTE_COMMAND_ROBOTS.TAR_POS_Z_1]   = field.tar_pos_z_1 or 0
    packet[Protocol.BYTE_COMMAND_ROBOTS.TAR_POS_Z_2]   = field.tar_pos_z_2 or 0
    packet[Protocol.BYTE_COMMAND_ROBOTS.TAR_YAW_1]     = field.tar_yaw_1 or 0
    packet[Protocol.BYTE_COMMAND_ROBOTS.TAR_YAW_2]     = field.tar_yaw_2 or 0


    Protocol.msg_command.QUANT_MSG = Protocol.msg_command.QUANT_MSG + 1
    Protocol.msg_command.MSG[Protocol.msg_command.QUANT_MSG] = packet

    log(string.format("There are %i messages stored", Protocol.msg_command.QUANT_MSG))
    
end

--- Function that decode the data and store to the correct variable
--- @param data table data received
function Protocol.decode_command_msg(data, range, hor_bearing, ver_bearing)
    if type(data) ~= "table" or #data < 64 then
        return {valid = false, error = "packet too short or invalid"}
    end
    
    local x = range * math.abs(math.cos(ver_bearing)) * math.cos(hor_bearing)
    local y = range * math.abs(math.cos(ver_bearing)) * math.sin(hor_bearing)
    local z = range * math.sin(ver_bearing)

    local decoded = {
        valid = true,
        header = {
            sender_id     = data[Protocol.BYTE_COMMAND_ROBOTS.SENDER_ID],
            type_msg      = data[Protocol.BYTE_COMMAND_ROBOTS.TYP_MSG],
            packet_id     = data[Protocol.BYTE_COMMAND_ROBOTS.PACKET_ID],
            quant_packets = data[Protocol.BYTE_COMMAND_ROBOTS.QUANT_PACKETS],
            index_packet  = data[Protocol.BYTE_COMMAND_ROBOTS.INDEX_PACKET],
            target_id     = data[Protocol.BYTE_COMMAND_ROBOTS.TARGET_ID],
        },
        payload = {
            tar_pos_x_1 = data[Protocol.BYTE_COMMAND_ROBOTS.TAR_POS_X_1],
            tar_pos_x_2 = data[Protocol.BYTE_COMMAND_ROBOTS.TAR_POS_X_2],
            tar_pos_y_1 = data[Protocol.BYTE_COMMAND_ROBOTS.TAR_POS_Y_1],
            tar_pos_y_2 = data[Protocol.BYTE_COMMAND_ROBOTS.TAR_POS_Y_2],
            tar_pos_z_1 = data[Protocol.BYTE_COMMAND_ROBOTS.TAR_POS_Z_1],
            tar_pos_z_2 = data[Protocol.BYTE_COMMAND_ROBOTS.TAR_POS_Z_2],
            tar_yaw_1   = data[Protocol.BYTE_COMMAND_ROBOTS.TAR_YAW_1],
            tar_yaw_2   = data[Protocol.BYTE_COMMAND_ROBOTS.TAR_YAW_2],
        }
    }

    local is_comp = (decoded.header.quant_packets == decoded.header.index_packet)

    
    Protocol.rec_msg_command = Protocol.rec_msg_command or {}
    Protocol.rec_msg_command[decoded.header.sender_id] = {
            is_complete = is_comp,
            msg = decoded,
            x_rel = x * 10,
            y_rel = y * 10,
            z_rel = z * 10
        }

end

return Protocol