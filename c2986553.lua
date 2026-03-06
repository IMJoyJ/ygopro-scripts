--夜薔薇の騎士
-- 效果：
-- ①：这张卡召唤成功时才能发动。从手卡把1只4星以下的植物族怪兽特殊召唤。
-- ②：只要这张卡在怪兽区域存在，对方不能选择植物族怪兽作为攻击对象。
function c2986553.initial_effect(c)
	-- 效果原文内容：只要这张卡在怪兽区域存在，对方不能选择植物族怪兽作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetValue(c2986553.atlimit)
	c:RegisterEffect(e1)
	-- 效果原文内容：这张卡召唤成功时才能发动。从手卡把1只4星以下的植物族怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2986553,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c2986553.sumtg)
	e2:SetOperation(c2986553.sumop)
	c:RegisterEffect(e2)
end
-- 规则层面作用：限制对方不能选择表侧表示的植物族怪兽作为攻击对象。
function c2986553.atlimit(e,c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT)
end
-- 规则层面作用：过滤满足条件的卡片，即4星以下的植物族怪兽且能被特殊召唤。
function c2986553.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_PLANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面作用：判断是否满足特殊召唤的条件，包括手牌中有符合条件的怪兽且场上存在空位。
function c2986553.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查玩家场上是否有足够的怪兽区域用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面作用：检查玩家手牌中是否存在至少一张满足条件的怪兽。
		and Duel.IsExistingMatchingCard(c2986553.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 规则层面作用：设置连锁操作信息，表明将要处理特殊召唤的效果。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 规则层面作用：执行特殊召唤操作，选择并特殊召唤符合条件的怪兽。
function c2986553.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：判断玩家场上是否有足够的怪兽区域用于特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 规则层面作用：向玩家发送提示信息，提示其选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面作用：从玩家手牌中选择满足条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c2986553.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 规则层面作用：将选中的怪兽以正面表示的形式特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
