--コート・オブ・ジャスティス
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。从手卡把1只天使族怪兽特殊召唤。这个效果在自己场上有1星天使族怪兽存在的场合才能发动和处理。
function c24449083.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文内容：①：自己主要阶段才能发动。从手卡把1只天使族怪兽特殊召唤。这个效果在自己场上有1星天使族怪兽存在的场合才能发动和处理。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24449083,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,24449083)
	e2:SetCondition(c24449083.condition)
	e2:SetTarget(c24449083.target)
	e2:SetOperation(c24449083.operation)
	c:RegisterEffect(e2)
end
-- 规则层面作用：定义用于检查场上是否存在1星天使族怪兽的过滤函数。
function c24449083.cfilter(c)
	return c:IsFaceup() and c:IsLevel(1) and c:IsRace(RACE_FAIRY)
end
-- 规则层面作用：判断自己场上是否存在1星天使族怪兽，作为效果发动条件之一。
function c24449083.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：检查自己场上是否存在1星天使族怪兽。
	return Duel.IsExistingMatchingCard(c24449083.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 规则层面作用：定义用于筛选可特殊召唤的天使族怪兽的过滤函数。
function c24449083.filter(c,e,sp)
	return c:IsRace(RACE_FAIRY) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
-- 规则层面作用：设置效果的发动条件，检查手牌中是否存在满足条件的天使族怪兽并确保场上还有空位。
function c24449083.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查手牌中是否存在满足条件的天使族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c24449083.filter,tp,LOCATION_HAND,0,1,nil,e,tp)
		-- 规则层面作用：检查自己场上是否有足够的怪兽区域。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 规则层面作用：设置连锁处理信息，表明将要特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 规则层面作用：定义效果的处理流程，包括检查场上空位、确认场上存在1星天使族怪兽、选择并特殊召唤手牌中的天使族怪兽。
function c24449083.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：检查自己场上是否还有空位，若无则不执行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 规则层面作用：检查自己场上是否存在1星天使族怪兽，若无则不执行特殊召唤。
	if not Duel.IsExistingMatchingCard(c24449083.cfilter,tp,LOCATION_MZONE,0,1,nil) then return end
	-- 规则层面作用：向玩家提示选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面作用：从手牌中选择满足条件的天使族怪兽。
	local g=Duel.SelectMatchingCard(tp,c24449083.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 规则层面作用：将选中的怪兽特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
