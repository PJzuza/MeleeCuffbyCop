    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- MeleeCuffbyCop -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
	-- On WIP. Bare with my coding skill and special thank you to Luffy for repolishing my bullshi* codes :P --
	-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
	_G.mcc = _G.mcc or {}
	mcc._path = ModPath
	mcc.settings_path = SavePath .. "MeleeCuffChance.txt"
	mcc.settings = {mcc_chance_slider_value = 20}
-- 
function mcc:GetCuffedChanceValue()
	return self.settings.mcc_chance_slider_value
end

function mcc:Reset()
	self.settings = {
		mcc_chance_slider_value = 20
	}
end

function mcc:Save()
	local file = io.open(self.settings_path, "w+")
	if file then
		file:write(json.encode(mcc.settings))
		file:close()
	end
end

function mcc:Load()
	self:Reset()
	local file = io.open(self.settings_path, "r")
	if file then
		for k, v in pairs(json.decode(file:read('*all')) or {}) do
				self.settings[k] = v
		end
		--self:GetCuffedChanceValue() -- What this function does here?; ShockWave
		--True... I'm derped xD; NewPJzuza
		file:close()
	end
end

--PostHook to override a function PlayerDamage:damage_melee | Thanks to Luffy on this part :D
if RequiredScript == "lib/units/beings/player/playerdamage" and mcc:GetCuffedChanceValue() ~= 0 then
	local types = { -- Enemy's types | You can add more enemies types if you want.
		["medic"] = true,
		["taser"] = true,
		["spooc"] = true,
		--[[ Excluded All dozer units. You can re-enable by delete this line and the line after tank_mini
		["tank"] = true,
		["tank_hw"] = true,
		["tank_medic"] = true,
		["tank_mini"] = true,
		]]--
		["swat"] = true,
		["city_swat"] = true,
		["cop"] = true,
		["cop_female"] = true,
		["cop_scared"] = true,
		["fbi"] = true,
		["fbi_swat"] = true,
		["fbi_heavy_swat"] = true,
		["heavy_swat"] = true,
		["gensec"] = true,
		["murky"] = true,
		--[[ Excluded All shields as well (since this one shouldn't attack using melee in a first place)
		["phalanx_minion"] = true,
		["phalanx_vip"] = true,
		]]--
		["security"] = true,
		["heavy_zeal_sniper"] = true
	}
	Hooks:PostHook(PlayerDamage, "damage_melee", "MeleeChanceDamageMelee", function(self, attack_data)
		if not self:_chk_can_take_dmg() then
			return
		end
			
		-- preparing somee stuffs
		local getting_cuffed_chance = math.random(0, 100)
		local player_can_counter_strike_cops = managers.player:has_category_upgrade("player", "counter_strike_melee")
		local player_can_counter_strike_clk =  managers.player:has_category_upgrade("player", "counter_strike_spooc")
		local enemies_attacker_types = attack_data.attacker_unit:base()._tweak_table

		-- check if enemy type key exists in the table(in our case equals to true)
		if types[enemies_attacker_types] then
			-- check if the player got tased | if so check if the player is on swan song or not.
			if self._unit:movement():tased() then
				if not self._unit:character_damage().swansong then
					-- check if the player is still alive or not.
					if alive(self._unit) then
						-- check if the player got meleed then a cop can cuff the player instantly.
						if self:_chk_can_take_dmg() then
							-- check the enemy unit| If alive and successfully cuff player then line i03 will be run. Works on normal and heavy swats and some type of cops.
							if attack_data.attacker_unit and attack_data.attacker_unit:alive() then
								attack_data.attacker_unit:sound():say("i03")
								managers.player:set_player_state("arrested")
								return self._current_state
							end
						end
					end
				end
			end
			
			-- run a random number | if true then the player will get cuffed by cops because of getting meleed.
			if getting_cuffed_chance < mcc:GetCuffedChanceValue() then
				-- if the player is on swansong, bleed out or incapacitated state then the player won't get cuffed.
				if self._unit:character_damage().swansong or self._bleed_out or self:incapacitated() then
				
				-- check if the player has counterstrike skill basic or ace then cops can't cuff you (for now...)
				-- Serious bug. You gain auto counter somehow and sometimes :\ (but luckily the cloaker counter is normal so be on guard when facing him.)
				elseif player_can_counter_strike_cops and self._unit:movement():current_state().in_melee then
					if player_can_counter_strike_clk and self._unit:movement():current_state().in_melee then
						self._unit:movement():current_state():discharge_melee()
						return "countered"
					else
						self._unit:movement():current_state():discharge_melee()
						return "countered"
					end 
				-- if others states from above 	
				else
					if attack_data.attacker_unit and alive(attack_data.attacker_unit) then		
						attack_data.attacker_unit:sound():say("i03")
						managers.player:set_player_state("arrested")
						return self._current_state
					end				
				end
			end
		-- if enemies types are not matched in enemies_attacker_types then do nothing
 		else
			-- unless the player has counterstrike skill then it will be used
			-- It still has that serious bug. You gain auto counter somehow and sometimes :\
			if player_can_counter_strike_cops and self._unit:movement():current_state().in_melee then
				if player_can_counter_strike_clk and self._unit:movement():current_state().in_melee then
					self._unit:movement():current_state():discharge_melee()
					return "countered"
				else
					self._unit:movement():current_state():discharge_melee()
					return "countered"
				end 
			end
		end
	end)
end

--Localization in case we have a new language kicks in.
Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_mcc", function( loc )
	if file.DirectoryExists(mcc._path .. "loc/") then
		local custom_language
		for _, mod in pairs(BLT and BLT.Mods:Mods() or {}) do
			if mod:GetName() == "PAYDAY 2 THAI LANGUAGE Mod" and mod:IsEnabled() then
				custom_language = "thai"
				break
			end			
		end
		if custom_language then
			loc:load_localization_file(mcc._path .. "loc/" .. custom_language ..".txt")
		else
			for _, filename in pairs(file.GetFiles(mcc._path .. "loc/")) do
				local str = filename:match('^(.*).txt$')
				if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
					loc:load_localization_file(mcc._path .. "loc/" .. filename)
					break
				end
			end
		end
	end
	loc:load_localization_file(mcc._path .. "loc/english.txt", false)
end)

-- Menu for a Slider and a reset button 
Hooks:Add( "MenuManagerInitialize", "MenuManagerInitialize_mcc", function( menu_manager )

	MenuCallbackHandler.callback_mcc_chance_slider_filters = function (self, item)
		mcc.settings.mcc_chance_slider_value = item:value()
	end 
	
	MenuCallbackHandler.mcc_save = function(this, item)
		mcc:Save()
	end
	
	MenuCallbackHandler.callback_mcc_chance_reset = function(self, item)
		MenuHelper:ResetItemsToDefaultValue(item, {["mcc_chance_slider"] = true}, 20)
	end
	
	mcc:Load()	
	MenuHelper:LoadFromJsonFile(mcc._path .. "menu/options.txt", mcc, mcc.settings)
end )