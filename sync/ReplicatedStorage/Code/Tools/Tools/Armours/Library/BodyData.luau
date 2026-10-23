local module = {}

module.BodyParts = {
	"Head",

	"RightFoot",
	"RightLowerLeg",
	"RightUpperLeg",

	"RightHand",
	"RightLowerArm",
	"RightUpperArm",

	"LowerTorso",
	"UpperTorso",

	"LeftFoot",
	"LeftLowerLeg",
	"LeftUpperLeg",

	"LeftHand",
	"LeftLowerArm",
	"LeftUpperArm",
}

module.DestroyOnHealth = {
	["Head"] = 0.05,

	["RightFoot"]= 0.10,
	["RightLowerLeg"]= 0.15,
	["RightUpperLeg"]= 0.20,

	["RightHand"]= 0.25,
	["RightLowerArm"]= 0.3,
	["RightUpperArm"]= 0.35,

	["LowerTorso"]= 0.4,
	["UpperTorso"]= 0.45,

	["LeftFoot"]= 0.5,
	["LeftLowerLeg"]= 0.55,
	["LeftUpperLeg"]= 0.6,

	["LeftHand"]= 0.65,
	["LeftLowerArm"]= 0.7,
	["LeftUpperArm"]= 0.75
}

return module
