if RequiredScript == "lib/units/beings/player/playerdamage" then

	-- create an overided function to a player so it won't fuck** up the whole function 
	local overideplayerdamagemelee = PlayerDamage.damage_melee
	local getting_cuffed_melee_chance = 20 -- Change this number from 0(cops won't cuff a player) up to 100(cops always cuff a player)
	function PlayerDamage:damage_melee(attack_data)
		overideplayerdamagemelee(self, attack_data)
		if not self:_chk_can_take_dmg() then
			return
		end
			
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

		local getting_cuffed_chance = math.random(0,100)
			-- run a random number | if true then the player will get cuffed by cops because of getting meleed.
			if getting_cuffed_chance < getting_cuffed_melee_chance then
				-- if the player is on swansong, beed out or incapacitated state then the player won't get cuffed.
				if self._unit:character_damage().swansong or self._bleed_out or self:incapacitated() then
				
				else
					managers.player:set_player_state("arrested")
					return self._current_state
				end
			end

	end
end

--[[
Thing I still have to do
	* Fixed some serious bugs. (no timer if you got cuffed while you got tased at the same time, every enemies can cuff a player for now)
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