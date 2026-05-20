--コアキメイル・ベルグザーク
-- 效果：
-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只战士族怪兽给对方观看。或者都不进行让这张卡破坏。这张卡战斗破坏对方怪兽的场合，只有1次可以继续攻击。
function c80367387.initial_effect(c)
	-- 注册该卡片记有「核成兽的钢核」卡名信息的事实
	aux.AddCodeList(c,36623431)
	-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只战士族怪兽给对方观看。或者都不进行让这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c80367387.mtcon)
	e1:SetOperation(c80367387.mtop)
	c:RegisterEffect(e1)
	-- 这张卡战斗破坏对方怪兽的场合，只有1次可以继续攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(80367387,3))  --"继续攻击"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(c80367387.atcon)
	e2:SetOperation(c80367387.atop)
	c:RegisterEffect(e2)
end
-- 维持效果（结束阶段阶段性处理）的触发条件函数
function c80367387.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为该卡的控制者
	return Duel.GetTurnPlayer()==tp
end
-- 过滤手牌中可作为代价送去墓地的「核成兽的钢核」的条件函数
function c80367387.cfilter1(c)
	return c:IsCode(36623431) and c:IsAbleToGraveAsCost()
end
-- 过滤手牌中未公开的战士族怪兽的条件函数
function c80367387.cfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_WARRIOR) and not c:IsPublic()
end
-- 维持效果（结束阶段阶段性处理）的具体操作函数
function c80367387.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 选中该卡片并显示被选为对象的动画效果，提示玩家该卡正在进行维持效果的处理
	Duel.HintSelection(Group.FromCards(c))
	-- 获取手牌中满足条件的「核成兽的钢核」卡片组
	local g1=Duel.GetMatchingGroup(c80367387.cfilter1,tp,LOCATION_HAND,0,nil)
	-- 获取手牌中满足条件的战士族怪兽卡片组
	local g2=Duel.GetMatchingGroup(c80367387.cfilter2,tp,LOCATION_HAND,0,nil)
	local select=2
	-- 提示玩家选择维持效果的处理方式
	Duel.Hint(HINT_SELECTMSG,tp,0)
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 当手牌中既有「核成兽的钢核」又有战士族怪兽时，让玩家在“送去墓地”、“展示怪兽”和“破坏此卡”三个选项中做出选择
		select=Duel.SelectOption(tp,aux.Stringid(80367387,0),aux.Stringid(80367387,1),aux.Stringid(80367387,2))  --"选择一张「核成兽的钢核」送去墓地/选择一只战士族怪物给对方观看/破坏「核成双刀手」"
	elseif g1:GetCount()>0 then
		-- 当手牌中只有「核成兽的钢核」时，让玩家在“送去墓地”和“破坏此卡”两个选项中做出选择
		select=Duel.SelectOption(tp,aux.Stringid(80367387,0),aux.Stringid(80367387,2))  --"选择一张「核成兽的钢核」送去墓地/破坏「核成双刀手」"
		if select==1 then select=2 end
	elseif g2:GetCount()>0 then
		-- 当手牌中只有战士族怪兽时，让玩家在“展示怪兽”和“破坏此卡”两个选项中做出选择，并对返回值进行偏移处理
		select=Duel.SelectOption(tp,aux.Stringid(80367387,1),aux.Stringid(80367387,2))+1  --"选择一只战士族怪物给对方观看/破坏「核成双刀手」"
	else
		-- 当手牌中既没有「核成兽的钢核」也没有战士族怪兽时，强制玩家选择“破坏此卡”
		select=Duel.SelectOption(tp,aux.Stringid(80367387,2))  --"破坏「核成双刀手」"
		select=2
	end
	if select==0 then
		-- 提示玩家选择要送去墓地的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g=g1:Select(tp,1,1,nil)
		-- 将选中的卡片作为维持代价送去墓地
		Duel.SendtoGrave(g,REASON_COST)
	elseif select==1 then
		-- 提示玩家选择要给对方确认的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local g=g2:Select(tp,1,1,nil)
		-- 将选中的怪兽给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
		-- 重新洗切手牌
		Duel.ShuffleHand(tp)
	else
		-- 因未支付维持代价而将这张卡破坏
		Duel.Destroy(c,REASON_COST)
	end
end
-- 战斗破坏怪兽后可以继续攻击的效果触发条件函数
function c80367387.atcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查此卡是否战斗破坏了对方怪兽，且当前是否可以进行连击
	return aux.bdocon(e,tp,eg,ep,ev,re,r,rp) and e:GetHandler():IsChainAttackable()
end
-- 战斗破坏怪兽后可以继续攻击的效果具体操作函数
function c80367387.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 使该怪兽可以再进行1次攻击
	Duel.ChainAttack()
end
