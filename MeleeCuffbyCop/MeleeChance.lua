if RequiredScript == "lib/units/beings/player/playerdamage" then

	-- create an overided function to a player so it won't fuck** up the whole function 
	local overide_player_damage_melee = PlayerDamage.damage_melee
	local getting_cuffed_melee_chance = 20 -- Change this number from 0(cops won't cuff a player) up to 100(cops always cuff a player)
	function PlayerDamage:damage_melee(attack_data)
		overide_player_damage_melee(self, attack_data)
		if not self:_chk_can_take_dmg() then
			return
		end
			
			-- preparing somee stuffs
			local getting_cuffed_chance = math.random(0,100)
			local player_can_counter_strike_cops = managers.player:has_category_upgrade("player", "counter_strike_melee")
			local player_can_counter_strike_clk =  managers.player:has_category_upgrade("player", "counter_strike_spooc")
			local enemies_attacker_types = attack_data.attacker_unit:base()._tweak_table
		-- check enemies types | You can add more enemies types if you want 
		if 	enemies_attacker_types == "medic" or 
			enemies_attacker_types == "taser" or 
			enemies_attacker_types == "spooc" or 
			--[[ Excluded All dozer units. You can re-enable by delete this line and the line after tank_mini
			enemies_attacker_types == "tank" or 
			enemies_attacker_types == "tank_hw" or 
			enemies_attacker_types == "tank_medic" or 
			enemies_attacker_types == "tank_mini" or
				]]--
			enemies_attacker_types == "city_swat" or 
			enemies_attacker_types == "cop" or 
			enemies_attacker_types == "cop_female" or 
			enemies_attacker_types == "cop_scared" or 
			enemies_attacker_types == "fbi" or 
			enemies_attacker_types == "fbi_swat" or 
			enemies_attacker_types == "fbi_heavy_swat" or 
			enemies_attacker_types == "heavy_swat" or 
			enemies_attacker_types == "gensec" or 
			enemies_attacker_types == "murky" or 
			enemies_attacker_types == "phalanx_minion" or 
			enemies_attacker_types == "phalanx_vip" or 
			enemies_attacker_types == "security" or 
			enemies_attacker_types == "heavy_zeal_sniper" then
			-- check if the player got tased | if so check if the player is on swan song or not.
			if self._unit:movement():tased() then
				if not self._unit:character_damage().swansong then
					-- check if the player is still alive or not.
					if alive(self._unit) then
						-- check if the player got meleed then a cop can cuff the player instantly.
						if self:_chk_can_take_dmg() then
							managers.player:set_player_state("arrested")
							return self._current_state
						end
					end
				end
			end
			
			-- run a random number | if true then the player will get cuffed by cops because of getting meleed.
			if getting_cuffed_chance < getting_cuffed_melee_chance then
				-- if the player is on swansong, beed out or incapacitated state then the player won't get cuffed.
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
					managers.player:set_player_state("arrested")
					end
					return self._current_state
				end
		-- if enemies types are not matched in enemies_attacker_types then do nothing
 		else
			-- unless the player has counterstrike skill then it will be used
			-- It still has that serious bug. You gain auto counter somehow and sometimes :\
			if player_can_counter_strike_cops and self._unit:movement():current_state().in_melee then
				self._unit:movement():current_state():discharge_melee()
				return "countered"
			end 
		end
	end
end

--[[
Thing I still have to do
	* Fixed some serious bugs. (auto counter, no timer if you got cuffed while you got tased at the same time, every enemies can cuff a player for now, auto counter is cheating to me... though I am trying to fix it)
	* Exclude some types of enemies and special enemies like Dozer, Taser, Sniper, Shield may be...
	* Make it works both client side and a host side. (now it works only if you have this mod)
	* I may add an option to enable-disable this mod.
	* I may add a voice line (Voice ID: "i03" that cop says "It's over", "This ends now", "Scumbag") considered it as a tuant.
	* If possible I may chance the lib/units/enemies/cop/logics/coplogicarrest like more than 1 cop can perform an action or when a player got flashed then cops will charge at a player to cuff him/her.
	* Repolish my shitty coding :P 
	* Some other things I guess... gonna try harder with my shitty coding skill...
Note- This is my second mod so as you can see, It's still buggy as fuc* 
	- If anyone wants to help, please do since my coding skill is so fuck** up. Send me a pull request so I can check and push it at my Github.
]]--