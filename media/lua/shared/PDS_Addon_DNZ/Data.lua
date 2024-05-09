-- Mirror of DiceSystem_Data

require("DiceSystem_Data")


PLAYER_DICE_VALUES.SKILLS = {
    "Body", "Wisdom", "Intelligence", "Reflex", "Charisma", "Willpower", "Luck"
}

PLAYER_DICE_VALUES.STATUS_EFFECTS = {
    "Blinded", "Deafened", "Frightened",
    "Grappled", "Incapacitated", "Poisoned",
    "Prone", "Stunned", "Invisible",
    "Bleeding", "Sneaking" }


PLAYER_DICE_VALUES.OCCUPATIONS = {
    "Paesant", "FormerSlave", "Survivalist", "Artificer",
    "Scribe", "TravellingMerchant", "Cowboy", "Tribesman",
    "Warrior", "Squire", "Thief", "Healer", "Diplomat"
}

PLAYER_DICE_VALUES.OCCUPATIONS_BONUS = {
    Paesant = { Strength = 1},
    FormerSlave = { Strength = 2, Willpower = 1},
    Survivalist = { Wisdom = 2, Reflex = 1},
    Artificer = { Intelligence = 3 },
    TravellingMerchant = { Charisma = 2, Willpower = 1 },
    Cowboy = { Reflex = 2, Wisdom = 1},
    Tribesman = { Strength = 1, Reflex = 1, Wisdom = 1 },
    Warrior = { Strength = 2, Reflex = 1},
    Squire = {Strength = 2, Intelligence = 1 },
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