--BF－毒風のシムーン
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：自己场上没有怪兽存在的场合，从手卡把这张卡以外的1只「黑羽」怪兽除外才能发动。从卡组选1张「黑旋风」在自己的魔法与陷阱区域表侧表示放置。那之后，手卡的这张卡不用解放作召唤或送去墓地。这个效果放置的「黑旋风」在结束阶段送去墓地，自己受到1000伤害。这个效果的发动后，直到回合结束时自己不是暗属性怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果：①效果（起动效果，手卡发动）以及不用解放进行召唤的规则效果。
function s.initial_effect(c)
	-- ①：自己场上没有怪兽存在的场合，从手卡把这张卡以外的1只「黑羽」怪兽除外才能发动。从卡组选1张「黑旋风」在自己的魔法与陷阱区域表侧表示放置。那之后，手卡的这张卡不用解放作召唤或送去墓地。这个效果放置的「黑旋风」在结束阶段送去墓地，自己受到1000伤害。这个效果的发动后，直到回合结束时自己不是暗属性怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.sumcon)
	e1:SetCost(s.sumcost)
	e1:SetTarget(s.sumtg)
	e1:SetOperation(s.sumop)
	c:RegisterEffect(e1)
	-- 手卡的这张卡不用解放作召唤
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.ntcon)
	e2:SetValue(SUMMON_TYPE_NORMAL)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
end
-- 检查是否满足不用解放进行召唤的条件。
function s.ntcon(e,c,minc)
	if c==nil then return true end
	-- 检查是否不需要解放怪兽且场上有足够的格子/祭品来进行召唤。
	return minc==0 and Duel.CheckTribute(c,0)
end
-- 检查发动条件：自己场上没有怪兽存在。
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽数量是否为0。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 过滤手卡中除这张卡以外的「黑羽」怪兽，且该怪兽可以作为代价除外。
function s.cfilter(c)
	return c:IsSetCard(0x33) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果发动的代价：从手卡把这张卡以外的1只「黑羽」怪兽除外。
function s.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 步骤0：检查手卡中是否存在除自身以外可除外的「黑羽」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,c) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择手卡中1张满足条件的「黑羽」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,c)
	-- 将选中的怪兽表侧表示除外作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤卡组中的「黑旋风」，且该卡不能是被禁止使用的卡，并且在场上是唯一的。
function s.acfilter(c,tp)
	return c:IsCode(91351370) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 效果发动的靶向/可行性检查：检查魔陷区是否有空位、卡组是否有「黑旋风」，以及手卡的这张卡是否能召唤或送去墓地。
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查自己的魔法与陷阱区域是否有空位。
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0
			-- 或者检查卡组中是否存在可以放置的「黑旋风」，若不满足则返回false。
			or not Duel.IsExistingMatchingCard(s.acfilter,tp,LOCATION_DECK,0,1,nil,tp) then return false end
		return e:GetHandler():IsSummonable(true,e:GetLabelObject()) or e:GetHandler():IsAbleToGrave()
	end
end
-- 效果处理：适用额外卡组特殊召唤限制，从卡组将「黑旋风」表侧表示放置，并注册结束阶段送去墓地的效果，那之后将这张卡召唤或送去墓地。
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这个效果的发动后，直到回合结束时自己不是暗属性怪兽不能从额外卡组特殊召唤。从卡组选1张「黑旋风」在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册限制玩家从额外卡组特殊召唤非暗属性怪兽的效果。
	Duel.RegisterEffect(e1,tp)
	-- 检查魔法与陷阱区域是否有空位，若无则结束处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要放置到场上的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组选择1张「黑旋风」。
	local tc=Duel.SelectMatchingCard(tp,s.acfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	-- 若成功选择，则将该卡在自己的魔法与陷阱区域表侧表示放置。
	if tc and Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)~=0 then
		-- 这个效果放置的「黑旋风」在结束阶段送去墓地，自己受到1000伤害。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetRange(LOCATION_SZONE)
		e1:SetCountLimit(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetOperation(s.tgop)
		tc:RegisterEffect(e1)
		if not c:IsRelateToEffect(e) then return end
		local se=e:GetLabelObject()
		if c:IsSummonable(true,se)
			-- 检查是否选择进行召唤（若不能送去墓地则必须召唤）。
			and (not c:IsAbleToGrave() or Duel.SelectOption(tp,1151,1191)==0) then
			-- 中断当前效果，使之后的操作（召唤）不与放置「黑旋风」同时处理。
			Duel.BreakEffect()
			-- 将手卡的这张卡不用解放进行通常召唤。
			Duel.Summon(tp,c,true,se)
		else
			-- 中断当前效果，使之后的操作（送去墓地）不与放置「黑旋风」同时处理。
			Duel.BreakEffect()
			-- 将手卡的这张卡送去墓地。
			Duel.SendtoGrave(c,REASON_EFFECT)
		end
	end
end
-- 限制只能从额外卡组特殊召唤暗属性怪兽。
function s.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_DARK) and c:IsLocation(LOCATION_EXTRA)
end
-- 结束阶段将「黑旋风」送去墓地并让自己受到1000伤害的具体处理。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动该效果的卡片。
	Duel.Hint(HINT_CARD,0,id)
	local c=e:GetHandler()
	-- 将放置的「黑旋风」送去墓地，若成功送去墓地则执行后续处理。
	if Duel.SendtoGrave(c,REASON_EFFECT)~=0 then
		-- 自己受到1000点伤害。
		Duel.Damage(tp,1000,REASON_EFFECT)
	end
end
