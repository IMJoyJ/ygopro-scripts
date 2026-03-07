--煉獄の狂宴
-- 效果：
-- ①：把自己的手卡·场上（表侧表示）1张「炼狱」魔法·陷阱卡送去墓地才能发动。等级合计直到变成8星为止，从卡组把最多3只「狱火机」怪兽无视召唤条件特殊召唤。
function c31548814.initial_effect(c)
	-- 效果原文内容：①：把自己的手卡·场上（表侧表示）1张「炼狱」魔法·陷阱卡送去墓地才能发动。等级合计直到变成8星为止，从卡组把最多3只「狱火机」怪兽无视召唤条件特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c31548814.cost)
	e1:SetTarget(c31548814.target)
	e1:SetOperation(c31548814.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：过滤满足条件的「炼狱」魔法·陷阱卡（表侧表示或在手卡且能作为代价送去墓地）
function c31548814.costfilter(c)
	return c:IsSetCard(0xc5) and c:IsType(TYPE_SPELL+TYPE_TRAP) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and c:IsAbleToGraveAsCost()
end
-- 效果作用：检查是否有满足条件的「炼狱」魔法·陷阱卡并选择一张送去墓地作为发动代价
function c31548814.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检测是否满足发动条件（手卡或场上存在1张符合条件的「炼狱」魔法·陷阱卡）
	if chk==0 then return Duel.IsExistingMatchingCard(c31548814.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 效果作用：提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 效果作用：选择满足条件的1张「炼狱」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c31548814.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,e:GetHandler())
	-- 效果作用：将选中的卡送去墓地作为发动代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果作用：过滤满足条件的「狱火机」怪兽（属于狱火机卡组且能特殊召唤）
function c31548814.spfilter(c,e,tp)
	return c:IsSetCard(0xbb) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果作用：检测是否满足特殊召唤条件（场上可用位置和卡组中是否有满足等级合计为8的怪兽）
function c31548814.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 效果作用：获取玩家场上可用的怪兽区域数量（最多3个）
		local ft=math.min((Duel.GetLocationCount(tp,LOCATION_MZONE)),3)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		-- 效果作用：获取卡组中所有满足条件的「狱火机」怪兽
		local g=Duel.GetMatchingGroup(c31548814.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		return ft>0 and g:CheckWithSumEqual(Card.GetLevel,8,1,ft)
	end
	-- 效果作用：设置连锁操作信息，表示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果作用：根据满足条件的怪兽数量和等级合计选择并特殊召唤怪兽
function c31548814.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取玩家场上可用的怪兽区域数量（最多3个）
	local ft=math.min((Duel.GetLocationCount(tp,LOCATION_MZONE)),3)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 效果作用：获取卡组中所有满足条件的「狱火机」怪兽
	local g=Duel.GetMatchingGroup(c31548814.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if ft<=0 or g:GetCount()==0 then return end
	-- 效果作用：提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:SelectWithSumEqual(tp,Card.GetLevel,8,1,ft)
	-- 效果作用：将选中的怪兽无视召唤条件特殊召唤到场上
	Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)
end
