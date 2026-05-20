--魍魎跋扈
-- 效果：
-- ①：自己·对方的主要阶段才能发动。把1只怪兽通常召唤。
function c75025112.initial_effect(c)
	-- ①：自己·对方的主要阶段才能发动。把1只怪兽通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCondition(c75025112.condition)
	e1:SetTarget(c75025112.target)
	e1:SetOperation(c75025112.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：自己或对方的主要阶段
function c75025112.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 过滤条件：可以进行通常召唤（表侧表示召唤或里侧表示盖放）的怪兽
function c75025112.filter(c)
	return c:IsSummonable(true,nil) or c:IsMSetable(true,nil)
end
-- 效果发动的目标选择与检测
function c75025112.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己手牌或场上是否存在至少1只可以进行通常召唤的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c75025112.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 设置操作信息为：包含通常召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 效果处理：选择1只怪兽进行通常召唤或里侧表示盖放
function c75025112.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 让玩家从手牌或场上选择1只满足通常召唤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c75025112.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		if tc:IsSummonable(true,nil) and (not tc:IsMSetable(true,nil)
			-- 若怪兽既可表侧召唤也可里侧盖放，则让玩家选择以表侧攻击表示还是里侧守备表示上场
			or Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)==POS_FACEUP_ATTACK) then
			-- 忽略每回合的通常召唤次数限制，将该怪兽表侧表示通常召唤
			Duel.Summon(tp,tc,true,nil)
		-- 否则，忽略每回合的通常召唤次数限制，将该怪兽里侧表示盖放
		else Duel.MSet(tp,tc,true,nil) end
	end
end
