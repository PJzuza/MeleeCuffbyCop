local superblt = false
for _, mod in pairs(BLT and BLT.Mods:Mods() or {}) do
	if mod:GetName() == "SuperBLT" and mod:IsEnabled() then
		superblt = true
		break
	end			
end
if superblt == false then
	if UpdateThisMod then
		UpdateThisMod:Add({
			mod_id = 'MeleeCuffbyCop',
			data = {
				dl_url = 'https://raw.githubusercontent.com/PJzuza/MeleeCuffbyCop/blob/master/updates/MCbC.zip',
				info_url = 'https://raw.githubusercontent.com/PJzuza/MeleeCuffbyCop/master/mod.txt'
			}
		})
	end

end