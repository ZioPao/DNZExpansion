DICE_SYSTEM_ADDON_DNZ_MOD_STRING = "PDS_ADDON_DNZ"

require("DiceSystem_Data")
table.insert(DICE_SYSTEM_MOD_ADDONS, {
    name = "DNZ Expansion",
    version = "1.0"
})

PLAYER_DICE_VALUES.SKILLS = {
    "Body", "Wisdom", "Intelligence", "Reflex", "Charisma", "Willpower", "Luck"
}


PLAYER_DICE_VALUES.OCCUPATIONS = {
    "Paesant", "FormerSlave", "Survivalist", "Artificer",
    "Scribe", "TravellingMerchant", "Cowboy", "Tribesman",
    "Warrior", "Squire", "Thief", "Healer", "Diplomat"
}

PLAYER_DICE_VALUES.OCCUPATIONS_BONUS = {
    Paesant = { Strength = 1 },
    FormerSlave = { Strength = 2, Willpower = 1 },
    Survivalist = { Wisdom = 2, Reflex = 1 },
    Artificer = { Intelligence = 2, Wisdom = 1 },
    Scribe = { Intelligence = 3 },
    TravellingMerchant = { Charisma = 2, Willpower = 1 },
    Cowboy = { Reflex = 2, Wisdom = 1 },
    Tribesman = { Strength = 1, Reflex = 1, Wisdom = 1 },
    Warrior = { Strength = 2, Reflex = 1 },
    Squire = { Strength = 2, Intelligence = 1 },
    Thief = { Reflex = 2, Luck = 1 },
    Healer = { Wisdom = 3 },
    Diplomat = { Charisma = 3 }
}


-- For each core skill, we need to list a couple of sub skills
PLAYER_DICE_VALUES.SUB_SKILLS = {
    Body = {
        "Strength", "Athletics", "Melee"
    },
    Wisdom = {
        "Insight", "Perception", "FirstAid"
    },
    Intelligence = {
        "Religion", "History", "Tech"
    },
    Reflex = {
        "Accuracy", "Evasion", "Acrobatics", "Stealth", "Initiative", "SleightOfHand"
    },
    Charisma = {
        "Persuasion", "Intimidate", "Deception"
    },
    Willpower = {
        "Psychic"
    },
    Luck = {}
}

PLAYER_DICE_VALUES.STATUS_EFFECTS = {
    "Blinded", "Deafened", "Frightened",
    "Grappled", "Incapacitated", "Poisoned",
    "Prone", "Stunned", "Invisible",
    "Bleeding", "Sneaking"
}



PLAYER_DICE_VALUES.DEFAULT_HEALTH = 5
PLAYER_DICE_VALUES.DEFAULT_MOVEMENT = 5
PLAYER_DICE_VALUES.DEFAULT_MORALE = 1
PLAYER_DICE_VALUES.MAX_ALLOCATED_POINTS = 0     -- Level 0
PLAYER_DICE_VALUES.MAX_LEVELS = 50
PLAYER_DICE_VALUES.MAX_PER_SKILL_ALLOCATED_POINTS = 10

---@alias diceDataType_DNZ {isInitialized : boolean, isLevelingUp : boolean, occupation : string, statusEffects : statusEffectsType, currentHealth : number, maxHealth : number, healthBonus : number, armorBonus : number, currentMovement : number, maxMovement : number, movementBonus : number, currentMorale : number, maxMorale : number, moraleBonus : number, allocatedPoints : number, level : number, skills : skillsTabType, skillsBonus : skillsBonusTabType, subSkills : table, subSkillsBonus : {}}


---@type diceDataType_DNZ
PLAYER_DICE_VALUES.DEFAULT_MOD_TABLE = {
    isInitialized = false,
    isLevelingUp = false,
    occupation = "",
    statusEffects = {},

    currentHealth = PLAYER_DICE_VALUES.DEFAULT_HEALTH,
    maxHealth = PLAYER_DICE_VALUES.DEFAULT_HEALTH,
    healthBonus = 0,



    armorBonus = 0,

    currentMovement = PLAYER_DICE_VALUES.DEFAULT_MOVEMENT,
    maxMovement = PLAYER_DICE_VALUES.DEFAULT_MOVEMENT,
    movementBonus = 0,

    currentMorale = PLAYER_DICE_VALUES.DEFAULT_MORALE,
    maxMorale = PLAYER_DICE_VALUES.DEFAULT_MORALE,
    moraleBonus = 0,

    allocatedPoints = 0,
    level = 0,      -- Level 0    

    skills = {},
    skillsBonus = {},

    subSkills = {}, -- table with skill as id
    subSkillsBonus = {}


    -- We want to keep track of the status of the skills before assigning them...????????
}

COLORS_DICE_TABLES = {
    -- Normal colors for status effects
    STATUS_EFFECTS     = {
        Blinded = { r = 0.627, g = 0.043, b = 0.796 },
        Deafened = { r = 0.478, g = 0.737, b = 0.627 },
        Frightened = { r = 0.843, g = 0.376, b = 0.627 },
        Grappled = { r = 0.843, g = 0.627, b = 0.376 },
        Incapacitated = { r = 1, g = 1, b = 1 },
        Poisoned = { r = 0.498, g = 0.804, b = 0.376 },
        Prone = { r = 0.376, g = 0.627, b = 1 },
        Stunned = { r = 0.369, g = 0.369, b = 0.863 },
        Invisible = { r = 1, g = 0.627, b = 0.376 },
        Bleeding = { r = 1, g = 0.376, b = 0.376 },
        Sneaking = { r = 0.478, g = 0.627, b = 0.763 },
    },

    -- Used for color blind users
    STATUS_EFFECTS_ALT = {
        Blinded = { r = 0.5, g = 0.2, b = 0.7 },
        Deafened = { r = 0.4, g = 0.7, b = 0.6 },
        Frightened = { r = 0.7, g = 0.3, b = 0.6 },
        Grappled = { r = 0.7, g = 0.5, b = 0.3 },
        Incapacitated = { r = 1, g = 1, b = 1 },
        Poisoned = { r = 0.4, g = 0.6, b = 1 },
        Prone = { r = 0.57, g = 0.15, b = 0.56 },
        Stunned = { r = 0.369, g = 0.369, b = 0.863 },
        Invisible = { r = 1, g = 0.7, b = 0.4 },
        Bleeding = { r = 1, g = 0.4, b = 0.4 },
        Sneaking = { r = 0.4, g = 0.6, b = 0.7 },
    }
}
