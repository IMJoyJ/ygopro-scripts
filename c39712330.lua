--決戦の火蓋
-- 效果：
-- 可以把自己墓地1张怪兽卡从游戏中除外，从手卡把1只通常怪兽通常召唤。这个效果在自己回合的主要阶段时才能发动。
function c39712330.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文内容：可以把自己墓地1张怪兽卡从游戏中除外，从手卡把1只通常怪兽通常召唤。这个效果在自己回合的主要阶段时才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39712330,0))  --"通常召唤"
	e2:SetCategory(CATEGORY_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(c39712330.condition)
	e2:SetCost(c39712330.cost)
	e2:SetTarget(c39712330.target)
	e2:SetOperation(c39712330.activate)
	c:RegisterEffect(e2)
end
-- 规则层面操作：判断是否为自己的回合且当前阶段为主要阶段1或主要阶段2
function c39712330.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取当前回合玩家
	local tn=Duel.GetTurnPlayer()
	-- 规则层面操作：获取当前阶段
	local ph=Duel.GetCurrentPhase()
	return tn==tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- 规则层面操作：过滤函数，用于筛选墓地中的怪兽卡
function c39712330.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 规则层面操作：发动时支付费用，从墓地选择1张怪兽卡除外
function c39712330.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检查是否满足支付费用的条件
	if chk==0 then return Duel.IsExistingMatchingCard(c39712330.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 规则层面操作：向玩家提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 规则层面操作：选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c39712330.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 规则层面操作：将选中的卡从游戏中除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 规则层面操作：过滤函数，用于筛选手牌中的通常怪兽
function c39712330.filter(c)
	return c:IsType(TYPE_NORMAL) and (c:IsSummonable(true,nil) or c:IsMSetable(true,nil))
end
-- 规则层面操作：设置效果的发动条件和目标，检查是否有满足条件的怪兽可召唤
function c39712330.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 规则层面操作：统计手牌中满足条件的通常怪兽数量
		local ct1=Duel.GetMatchingGroupCount(c39712330.filter,tp,LOCATION_HAND,0,nil)
		-- 规则层面操作：获取当前玩家已使用的次数标识
		local ct2=Duel.GetFlagEffect(tp,39712330)
		return ct1-ct2>0
	end
	-- 规则层面操作：注册一个标识效果，防止本回合重复使用此效果
	Duel.RegisterFlagEffect(tp,39712330,RESET_CHAIN,0,1)
	-- 规则层面操作：设置连锁操作信息，表示将要进行通常召唤
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 规则层面操作：效果发动时，从手牌选择1只通常怪兽进行通常召唤或Set
function c39712330.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：向玩家提示选择要召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 规则层面操作：选择满足条件的1只通常怪兽
	local g=Duel.SelectMatchingCard(tp,c39712330.filter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		local s1=tc:IsSummonable(true,nil)
		local s2=tc:IsMSetable(true,nil)
		-- 规则层面操作：判断是否选择攻击表示召唤或守备表示Set
		if (s1 and s2 and Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)==POS_FACEUP_ATTACK) or not s2 then
			-- 规则层面操作：将选中的怪兽通常召唤
			Duel.Summon(tp,tc,true,nil)
		else
			-- 规则层面操作：将选中的怪兽盖放
			Duel.MSet(tp,tc,true,nil)
		end
	end
end
