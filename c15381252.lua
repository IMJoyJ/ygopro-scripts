--狂戦士の魂
-- 效果：
-- 「狂战士之魂」在1回合只能发动1张。
-- ①：自己场上的怪兽直接攻击给与对方1500以下的伤害时，把手卡全部丢弃才能发动。自己卡组最上面的卡翻开，那是怪兽的场合，那只怪兽送去墓地，给与对方500伤害。那之后，直到怪兽以外被翻开为止让这个效果重复（最多7次）。翻开的卡是怪兽以外的场合，那张卡回到卡组最上面。
function c15381252.initial_effect(c)
	-- 创建效果，设置为发动时效果，触发事件为战斗伤害，限制每回合只能发动1次，条件为对方造成的战斗伤害不超过1500点且攻击怪兽未被阻挡
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCountLimit(1,15381252+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c15381252.condition)
	e1:SetCost(c15381252.cost)
	e1:SetTarget(c15381252.target)
	e1:SetOperation(c15381252.activate)
	c:RegisterEffect(e1)
end
-- 效果条件判断函数，判断是否满足发动条件
function c15381252.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 满足发动条件：对方造成的战斗伤害不超过1500点，攻击怪兽未被阻挡
	return ep~=tp and eg:GetFirst():GetControler()==tp and ev<=1500 and Duel.GetAttackTarget()==nil
end
-- 效果代价函数，判断是否可以支付代价并执行丢弃手牌操作
function c15381252.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取玩家手牌组
		local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
		g:RemoveCard(e:GetHandler())
		return g:GetCount()>0 and g:FilterCount(Card.IsDiscardable,nil)==g:GetCount()
	end
	-- 获取玩家手牌组
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	-- 将手牌全部丢弃至墓地作为发动代价
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 效果目标函数，判断是否可以翻开卡组最上方的卡
function c15381252.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家是否可以翻开卡组最上方的卡
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
-- 效果发动函数，执行翻开卡组最上方卡并根据卡的类型进行后续处理
function c15381252.activate(e,tp,eg,ep,ev,re,r,rp)
	local count=8
	-- 循环条件：次数未用完、玩家可以翻开卡组最上方的卡、对方生命值大于0
	while count>0 and Duel.IsPlayerCanDiscardDeck(tp,1) and Duel.GetLP(1-tp)>0 do
		-- 中断当前效果处理，使后续效果视为不同时处理
		if count<8 then Duel.BreakEffect() end
		-- 确认玩家卡组最上方的1张卡
		Duel.ConfirmDecktop(tp,1)
		-- 获取玩家卡组最上方的1张卡
		local g=Duel.GetDecktopGroup(tp,1)
		local tc=g:GetFirst()
		if tc:IsType(TYPE_MONSTER) then
			-- 禁用洗牌检查，防止翻开卡后自动洗牌
			Duel.DisableShuffleCheck()
			-- 将翻开的卡送去墓地
			Duel.SendtoGrave(tc,REASON_EFFECT+REASON_REVEAL)
			if tc:IsLocation(LOCATION_GRAVE) then
				-- 对对方造成500点伤害
				Duel.Damage(1-tp,500,REASON_EFFECT)
				count=count-1
			else count=0 end
		else
			count=0
		end
	end
end
