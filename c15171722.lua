--エヴォルダー・リオス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「通向进化的吊桥」或「进化的特异点」在自己场上盖放。
-- ②：这张卡是已召唤或者已用炎属性怪兽的效果特殊召唤的场合，自己主要阶段才能发动。从卡组把1只爬虫类族·恐龙族的炎属性怪兽送去墓地。那之后，可以把场上2只怪兽的种族和等级变成和送去墓地的怪兽相同。
local s,id,o=GetID()
-- 创建并注册这张卡的所有效果：①的召唤·特殊召唤时盖放效果（分别注册通常召唤和特殊召唤两个触发效果），②的辅助标记效果（记录用炎属性怪兽的效果特殊召唤）以及②的起动效果（送墓并改变种族等级）。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「通向进化的吊桥」或「进化的特异点」在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 已用炎属性怪兽的效果特殊召唤的场合
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetOperation(s.checkop)
	c:RegisterEffect(e3)
	-- ②：这张卡是已召唤或者已用炎属性怪兽的效果特殊召唤的场合，自己主要阶段才能发动。从卡组把1只爬虫类族·恐龙族的炎属性怪兽送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.tgcon)
	e4:SetTarget(s.tgtg)
	e4:SetOperation(s.tgop)
	c:RegisterEffect(e4)
end
-- 检查卡片是否为「通向进化的吊桥」(93504463) 或「进化的特异点」(74100225)，并且可以盖放到场上。
function s.setfilter(c)
	return c:IsCode(93504463,74100225) and c:IsSSetable()
end
-- ①效果的发动条件：从自己卡组检查是否存在至少1张满足 s.setfilter 的卡。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时（chk==0）确认卡组中存在可盖放对象，否则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 执行①效果：从卡组选择1张符合条件的卡，盖放到自己场上。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要盖放的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 按 s.setfilter 条件从卡组选择1张卡。
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡盖放到自己场上（魔法与陷阱区）。
		Duel.SSet(tp,g)
	end
end
-- 当这张卡被炎属性怪兽的效果特殊召唤成功时，在这张卡上设置标记，表示“已用炎属性怪兽的效果特殊召唤”，供②效果判断。
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if not re then return end
	if re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsAttribute(ATTRIBUTE_FIRE) then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD-RESET_TEMP_REMOVE,0,1)
	end
end
-- ②效果的发动条件：这张卡是通常召唤过的，或者是特殊召唤且带有炎属性特招标记（即符合“已召唤或者已用炎属性怪兽的效果特殊召唤”）。
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_NORMAL) or c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:GetFlagEffect(id)>0
end
-- 从卡组中筛选符合条件的怪兽：炎属性、爬虫类族或恐龙族、且可以送去墓地。
function s.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_REPTILE+RACE_DINOSAUR)
		and c:IsAbleToGrave()
end
-- ②效果的发动判定：检查卡组中是否存在可送去墓地的目标，并设置操作信息（将1张卡从卡组送去墓地）。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时（chk==0）确认卡组中存在符合条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次效果的操作信息为 CATEGORY_TOGRAVE，数量1，从卡组送去墓地，供连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 筛选场上表侧表示、非链接/超量怪兽，且种族或等级与送墓怪兽不完全相同（需要被改变）的怪兽。
function s.filter(c,race,lv)
	return c:IsFaceup() and not c:IsType(TYPE_LINK+TYPE_XYZ) and (not c:IsRace(race) or not c:IsLevel(lv))
end
-- 执行②效果：从卡组选择1只符合条件的炎属性爬虫类/恐龙族怪兽送去墓地；若成功且该墓地怪兽有种族和等级，则从场上选择2只符合条件的怪兽，将其种族和等级变为与墓地怪兽相同（可以选择不发动变更）。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要送去墓地的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1张满足 tgfilter 的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		local tc=g:GetFirst()
		-- 将选择的怪兽送去墓地，并确认送墓成功且该卡仍在墓地。
		if Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) then
			local race,lv=tc:GetRace(),tc:GetLevel()
			if race==0 or lv==0 then return end
			-- 获取当前场上所有满足 s.filter 条件的怪兽组，用于后续选择2只。
			local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,race,lv)
			-- 当可选怪兽数不少于2只且玩家确认要改变时，继续执行变更处理。
			if #g>=2 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否改变2只怪兽的种族和等级？"
				-- 显示“请选择表侧表示的卡”的选择提示。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
				local sg=g:Select(tp,2,2,nil)
				local c=e:GetHandler()
				-- 为选中的怪兽组显示被选择动画，并将它们记录为效果对象。
				Duel.HintSelection(sg)
				-- 中断当前效果处理，使后续对怪兽的种族/等级变更视为独立处理，避免时点被错误占据。
				Duel.BreakEffect()
				-- 遍历选中的2只怪兽，逐只附加种族与等级变更效果。
				for sc in aux.Next(sg) do
					-- 那之后，可以把场上2只怪兽的种族和等级变成和送去墓地的怪兽相同。
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_CHANGE_RACE)
					e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
					e1:SetValue(race)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD)
					sc:RegisterEffect(e1)
					local e2=e1:Clone()
					e2:SetCode(EFFECT_CHANGE_LEVEL)
					e2:SetValue(lv)
					sc:RegisterEffect(e2)
				end
			end
		end
	end
end
