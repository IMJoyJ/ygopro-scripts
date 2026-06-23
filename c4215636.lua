--霞の谷の祭壇
-- 效果：
-- 风属性怪兽被卡的效果破坏送去自己墓地时，可以从自己的手卡·卡组把1只风属性·3星以下的怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。这个效果1回合只能使用1次。
function c4215636.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 创建一个诱发选发效果，用于在风属性怪兽被破坏送入墓地时发动，特殊召唤风属性3星以下的怪兽，且该效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetDescription(aux.Stringid(4215636,0))  --"特殊召唤"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1)
	e2:SetCondition(c4215636.condition)
	e2:SetTarget(c4215636.target)
	e2:SetOperation(c4215636.operation)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断被破坏送入墓地的怪兽是否为风属性且为己方控制。
function c4215636.cfilter(c,tp)
	return bit.band(c:GetReason(),0x41)==0x41 and c:IsControler(tp) and c:IsAttribute(ATTRIBUTE_WIND)
end
-- 条件函数，判断是否有满足条件的风属性怪兽被破坏送入墓地。
function c4215636.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c4215636.cfilter,1,nil,tp)
end
-- 过滤函数，用于筛选手卡或卡组中风属性且等级为3星以下的可特殊召唤怪兽。
function c4215636.spfilter(c,e,tp)
	return c:IsLevelBelow(3) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标函数，检查是否满足发动条件，包括未处于连锁中、场上存在空位、手卡或卡组存在符合条件的怪兽。
function c4215636.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING)
		-- 目标函数中判断是否满足发动条件，包括场上存在空位、手卡或卡组存在符合条件的怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c4215636.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息，表示该效果将特殊召唤1只怪兽，目标为手卡或卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 效果处理函数，检查场上是否有空位，若存在则提示选择并特殊召唤符合条件的怪兽。
function c4215636.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否还有空位，若无则直接返回。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的风属性3星以下的怪兽。
	local g=Duel.SelectMatchingCard(tp,c4215636.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 尝试特殊召唤所选怪兽，若成功则继续设置效果无效化。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 为特殊召唤的怪兽设置效果无效化（禁止其发动效果）。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 为特殊召唤的怪兽设置效果无效化（禁止其效果在回合结束时重置）。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
	end
	-- 完成特殊召唤流程，结束该次特殊召唤处理。
	Duel.SpecialSummonComplete()
end
