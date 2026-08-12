--バージェストマ・マーレラ
-- 效果：
-- ①：从卡组把1张陷阱卡送去墓地。
-- ②：陷阱卡发动时，连锁那个发动才能把这个效果在墓地发动。这张卡变成通常怪兽（水族·水·2星·攻1200/守0）在怪兽区域特殊召唤（不当作陷阱卡使用）。这个效果特殊召唤的这张卡不受怪兽的效果影响，从场上离开的场合除外。
function c64765016.initial_effect(c)
	-- ①：从卡组把1张陷阱卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c64765016.target)
	e1:SetOperation(c64765016.activate)
	c:RegisterEffect(e1)
	-- ②：陷阱卡发动时，连锁那个发动才能把这个效果在墓地发动。这张卡变成通常怪兽（水族·水·2星·攻1200/守0）在怪兽区域特殊召唤（不当作陷阱卡使用）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(64765016,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(c64765016.spcon)
	e2:SetTarget(c64765016.sptg)
	e2:SetOperation(c64765016.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：卡组中可以送去墓地的陷阱卡
function c64765016.tgfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsAbleToGrave()
end
-- 效果①的发动准备：检查卡组中是否存在可送去墓地的陷阱卡，并设置操作信息
function c64765016.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张可以送去墓地的陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c64765016.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作信息为：将卡组的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理：从卡组选择1张陷阱卡送去墓地
function c64765016.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张满足过滤条件的陷阱卡
	local g=Duel.SelectMatchingCard(tp,c64765016.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 效果②的发动条件：连锁中正有陷阱卡的效果发动
function c64765016.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 效果②的发动准备：检查怪兽区域是否有空位，以及是否能将该卡作为特定属性、种族、攻守的怪兽特殊召唤
function c64765016.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自身怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否能将此卡作为水属性·水族·2星·攻1200/守0的通常怪兽特殊召唤
		and Duel.IsPlayerCanSpecialSummonMonster(tp,64765016,0xd4,TYPES_NORMAL_TRAP_MONSTER,1200,0,2,RACE_AQUA,ATTRIBUTE_WATER) end
	-- 设置当前连锁的操作信息为：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果②的效果处理：将自身作为通常怪兽特殊召唤，并赋予不受怪兽效果影响以及离场除外的效果
function c64765016.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若怪兽区域已无空位，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 检查此卡是否仍与该效果相关，且是否仍能将其作为特定怪兽特殊召唤
	if c:IsRelateToEffect(e) and Duel.IsPlayerCanSpecialSummonMonster(tp,64765016,0xd4,TYPES_NORMAL_TRAP_MONSTER,1200,0,2,RACE_AQUA,ATTRIBUTE_WATER) then
		c:AddMonsterAttribute(TYPE_NORMAL)
		-- 将此卡以表侧表示特殊召唤（作为特殊召唤的多步处理之一）
		Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP)
		-- 这个效果特殊召唤的这张卡不受怪兽的效果影响
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_IMMUNE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetValue(c64765016.efilter)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		-- 从场上离开的场合除外。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e3:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e3,true)
		-- 完成特殊召唤的后续处理
		Duel.SpecialSummonComplete()
	end
end
-- 抗性过滤条件：不受怪兽的效果影响
function c64765016.efilter(e,re)
	return re:IsActiveType(TYPE_MONSTER)
end
