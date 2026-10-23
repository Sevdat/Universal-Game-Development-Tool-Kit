local module = {}

local replicatedStorage = game:GetService("ReplicatedStorage")
local armours = replicatedStorage:WaitForChild("Armours")

module.DefaultArmourName = "Mark1"

module.ArmourConfig = {
	Mark1 = {
		Name = "Mark1",
		Model = armours:WaitForChild("Mark1"),
		FlightForce = 200,
		MaxHealth = 100,
		MaxDamageMultiplier = 150,
		Price = 100,
	},
	["Ballerina Cappuccina"] = {
		Name = "Ballerina Cappuccina",
		Model = armours:WaitForChild("Ballerina Cappuccina"),
		FlightForce = 400,
		MaxHealth = 100,
		MaxDamageMultiplier = 150,
		Price = 100
	},
	["Bananita Dolphinita"] = {
		Name = "Bananita Dolphinita",
		Model = armours:WaitForChild("Bananita Dolphinita"),
		FlightForce = 400,
		MaxHealth = 100,
		MaxDamageMultiplier = 150,
		Price = 100
	},
	["Boneca Ambalabu"] = {
		Name = "Boneca Ambalabu",
		Model = armours:WaitForChild("Boneca Ambalabu"),
		FlightForce = 400,
		MaxHealth = 100,
		MaxDamageMultiplier = 150,
		Price = 100
	},
	["Brr Brr Patapim"] = {
		Name = "Brr Brr Patapim",
		Model = armours:WaitForChild("Brr Brr Patapim"),
		FlightForce = 400,
		MaxHealth = 100,
		MaxDamageMultiplier = 150,
		Price = 100
	},
	["Brri Brri Bicus Dicus Bombicus"] = {
		Name = "Brri Brri Bicus Dicus Bombicus",
		Model = armours:WaitForChild("Brri Brri Bicus Dicus Bombicus"),
		FlightForce = 400,
		MaxHealth = 100,
		MaxDamageMultiplier = 150,
		Price = 100
	},
	["Burbaloni Loliloli"] = {
		Name = "Burbaloni Loliloli",
		Model = armours:WaitForChild("Burbaloni Loliloli"),
		FlightForce = 400,
		MaxHealth = 100,
		MaxDamageMultiplier = 150,
		Price = 100
	},
	["Chef Crabracadabra"] = {
		Name = "Chef Crabracadabra",
		Model = armours:WaitForChild("Chef Crabracadabra"),
		FlightForce = 400,
		MaxHealth = 100,
		MaxDamageMultiplier = 150,
		Price = 100
	},
	["Cocofanto Elefanto"] = {
		Name = "Cocofanto Elefanto",
		Model = armours:WaitForChild("Cocofanto Elefanto"),
		FlightForce = 400,
		MaxHealth = 100,
		MaxDamageMultiplier = 150,
		Price = 100
	},
	["Frigo Camelo"] = {
		Name = "Frigo Camelo",
		Model = armours:WaitForChild("Frigo Camelo"),
		FlightForce = 400,
		MaxHealth = 100,
		MaxDamageMultiplier = 150,
		Price = 100
	},
	["Gangster Footera"] = {
		Name = "Gangster Footera",
		Model = armours:WaitForChild("Gangster Footera"),
		FlightForce = 400,
		MaxHealth = 100,
		MaxDamageMultiplier = 150,
		Price = 100
	},
	["Glorbo Fruttodrillo"] = {
		Name = "Glorbo Fruttodrillo",
		Model = armours:WaitForChild("Glorbo Fruttodrillo"),
		FlightForce = 400,
		MaxHealth = 100,
		MaxDamageMultiplier = 150,
		Price = 100
	},
	["Graipuss Medussi"] = {
		Name = "Graipuss Medussi",
		Model = armours:WaitForChild("Graipuss Medussi"),
		FlightForce = 400,
		MaxHealth = 100,
		MaxDamageMultiplier = 150,
		Price = 100
	},
	["La Vacca Saturno Saturnita"] = {
		Name = "La Vacca Saturno Saturnita",
		Model = armours:WaitForChild("La Vacca Saturno Saturnita"),
		FlightForce = 400,
		MaxHealth = 100,
		MaxDamageMultiplier = 150,
		Price = 100
	},
	["Lirilì Larilà"] = {
		Name = "Lirilì Larilà",
		Model = armours:WaitForChild("Lirilì Larilà"),
		FlightForce = 400,
		MaxHealth = 100,
		MaxDamageMultiplier = 150,
		Price = 100
	},
	["Noobini Pizzanini"] = {
		Name = "Noobini Pizzanini",
		Model = armours:WaitForChild("Noobini Pizzanini"),
		FlightForce = 400,
		MaxHealth = 100,
		MaxDamageMultiplier = 150,
		Price = 100
	},
	["Odin Din Din Dun"] = {
		Name = "Odin Din Din Dun",
		Model = armours:WaitForChild("Odin Din Din Dun"),
		FlightForce = 400,
		MaxHealth = 100,
		MaxDamageMultiplier = 150,
		Price = 100
	},
	["Orangutini Ananassini"] = {
		Name = "Orangutini Ananassini",
		Model = armours:WaitForChild("Orangutini Ananassini"),
		FlightForce = 400,
		MaxHealth = 100,
		MaxDamageMultiplier = 150,
		Price = 100
	},
	["Rhino Toasterino"] = {
		Name = "Rhino Toasterino",
		Model = armours:WaitForChild("Rhino Toasterino"),
		FlightForce = 400,
		MaxHealth = 100,
		MaxDamageMultiplier = 150,
		Price = 100
	},
	["Svinina Bombardino"] = {
		Name = "Svinina Bombardino",
		Model = armours:WaitForChild("Svinina Bombardino"),
		FlightForce = 400,
		MaxHealth = 100,
		MaxDamageMultiplier = 150,
		Price = 100
	},
	["Talpa Di Fero"] = {
		Name = "Talpa Di Fero",
		Model = armours:WaitForChild("Talpa Di Fero"),
		FlightForce = 400,
		MaxHealth = 100,
		MaxDamageMultiplier = 150,
		Price = 100
	},
	["Tim Cheese"] = {
		Name = "Tim Cheese",
		Model = armours:WaitForChild("Tim Cheese"),
		FlightForce = 400,
		MaxHealth = 100,
		MaxDamageMultiplier = 150,
		Price = 100
	},
	["Trippi Troppi"] = {
		Name = "Trippi Troppi",
		Model = armours:WaitForChild("Trippi Troppi"),
		FlightForce = 400,
		MaxHealth = 100,
		MaxDamageMultiplier = 150,
		Price = 100
	},
	["Trulimero Trulicina"] = {
		Name = "Trulimero Trulicina",
		Model = armours:WaitForChild("Trulimero Trulicina"),
		FlightForce = 400,
		MaxHealth = 100,
		MaxDamageMultiplier = 150,
		Price = 100
	},
	["Tung Tung Tung Sahur"] = {
		Name = "Tung Tung Tung Sahur",
		Model = armours:WaitForChild("Tung Tung Tung Sahur"),
		FlightForce = 400,
		MaxHealth = 100,
		MaxDamageMultiplier = 150,
		Price = 100
	}
}

function module.GetArmourConfig(armourName:string)	
	return module.ArmourConfig[armourName]
end

function module.IsDestroyed(bodyPartName,currentHealthRatio)
	local ratio = module.DestroyOnHealth[bodyPartName]
	if ratio and currentHealthRatio <= ratio then
		return true
	end
	return false
end

return module
