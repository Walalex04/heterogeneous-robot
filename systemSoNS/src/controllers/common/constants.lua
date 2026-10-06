
local constants = {}



constants.TYPE_ROBOT = {
    DRONE = 1,
    BLIMP = 2,
    QUPA = 3
}

constants.STATE_RECRUITMENT = { 
    ACCEPTED = 1,
    REJECTED = 2,
    AWAITING = 3,
    INTILIZING = 4,
}

constants.ROLE = {
    BRAIN = 1,
    NAVIGATOR = 2,
    WORKER = 3
}

constants.STATE_ROBOT = {
    SEARCHING = 1,
    COMP_GRAPH = 2,
    WORKING = 3
}

return constants

