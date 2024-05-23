	//=================================================================================================================
	// Robin : (W) Parkour Shot
	//=================================================================================================================
	"robin_parkour_shot"
	{
		"BaseClass"     					"ability_lua"
		"ScriptFile"    					"abilities/robin/vector_targeting_lua"
		"AbilityTextureName"			"pangolier_swashbuckle"
		"FightRecapLevel"				"1"
		"MaxLevel"						"4"
		
		"AbilityType"					"DOTA_ABILITY_TYPE_BASIC"
		"AbilityBehavior"				"DOTA_ABILITY_BEHAVIOR_POINT | DOTA_ABILITY_BEHAVIOR_VECTOR_TARGETING"
		"AbilityUnitDamageType"			"DAMAGE_TYPE_PHYSICAL"
		"AbilityCastPoint"				"0.0"
		"AbilityCastRange"				"1000"


		// Ability Resource
		//-------------------------------------------------------------------------------------------------------------
		"AbilityCooldown"				"20 16 12 8"
		"AbilityManaCost"				"80 90 100 110"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"				"FIELD_INTEGER"
				"dash_range"			"1000"
			}
			"02"
			{
				"var_type"				"FIELD_INTEGER"
				"range"					"900"
			}
			"05"
			{
				"var_type"				"FIELD_INTEGER"
				"damage"				"24 42 60 78"
			}
		}
	}