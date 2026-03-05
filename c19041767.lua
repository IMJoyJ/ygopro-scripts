--デュアル・サモナー
-- 效果：
-- 对方的结束阶段时只有1次支付500基本分才能发动。把手卡或者自己场上表侧表示存在的1只二重怪兽通常召唤。此外，这张卡1回合只有1次不会被战斗破坏。
function c19041767.initial_effect(c)
	-- 效果原文内容：此外，这张卡1回合只有1次不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetCountLimit(1)
	e1:SetValue(c19041767.valcon)
	c:RegisterEffect(e1)
	-- 效果原文内容：对方的结束阶段时只有1次支付500基本分才能发动。把手卡或者自己场上表侧表示存在的1只二重怪兽通常召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19041767,0))  --"通常召唤"
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetCondition(c19041767.condition)
	e2:SetCost(c19041767.cost)
	e2:SetTarget(c19041767.target)
	e2:SetOperation(c19041767.operation)
	c:RegisterEffect(e2)
end
-- 规则层面作用：使该卡在战斗破坏时不会被破坏。
function c19041767.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 规则层面作用：过滤出满足条件的二重怪兽（可以通常召唤或盖放）。
function c19041767.filter(c)
	return c:IsType(TYPE_DUAL) and (c:IsSummonable(true,nil) or c:IsMSetable(true,nil))
end
-- 规则层面作用：判断是否为对方的结束阶段。
function c19041767.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：判断是否为对方回合。
	return tp~=Duel.GetTurnPlayer()
end
-- 规则层面作用：支付500基本分的费用。
function c19041767.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查是否能支付500基本分。
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 规则层面作用：支付500基本分。
	Duel.PayLPCost(tp,500)
end
-- 规则层面作用：设置连锁操作信息，确定要处理的召唤目标。
function c19041767.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查手牌或场上是否存在满足条件的二重怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c19041767.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 规则层面作用：设置操作信息，表示将要进行通常召唤。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 规则层面作用：选择并处理召唤目标，根据条件决定是通常召唤还是盖放。
function c19041767.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：提示玩家选择要召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 规则层面作用：选择满足条件的二重怪兽。
	local g=Duel.SelectMatchingCard(tp,c19041767.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		local s1=tc:IsSummonable(true,nil)
		local s2=tc:IsMSetable(true,nil)
		-- 规则层面作用：根据召唤和盖放的可能性决定召唤方式。
		if (s1 and s2 and Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)==POS_FACEUP_ATTACK) or not s2 then
			-- 规则层面作用：执行通常召唤。
			Duel.Summon(tp,tc,true,nil)
		else
			-- 规则层面作用：执行盖放。
			Duel.MSet(tp,tc,true,nil)
		end
	end
end
