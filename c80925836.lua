--コアキメイル・デビル
-- 效果：
-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只恶魔族怪兽给对方观看。或者都不进行让这张卡破坏。只要这张卡在自己场上表侧表示存在，主要阶段时发动的光属性以及暗属性的效果怪兽的效果无效化。
function c80925836.initial_effect(c)
	-- 注册该卡片记有「核成兽的钢核」（卡号36623431）的卡片信息
	aux.AddCodeList(c,36623431)
	-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只恶魔族怪兽给对方观看。或者都不进行让这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c80925836.mtcon)
	e1:SetOperation(c80925836.mtop)
	c:RegisterEffect(e1)
	-- 只要这张卡在自己场上表侧表示存在，主要阶段时发动的光属性以及暗属性的效果怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetOperation(c80925836.disop)
	c:RegisterEffect(e2)
end
-- 维持代价效果的发动条件函数（仅在自己的结束阶段触发）
function c80925836.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为该卡的控制者
	return Duel.GetTurnPlayer()==tp
end
-- 过滤手牌中可作为代价送去墓地的「核成兽的钢核」的条件函数
function c80925836.cfilter1(c)
	return c:IsCode(36623431) and c:IsAbleToGraveAsCost()
end
-- 过滤手牌中未公开的恶魔族怪兽的条件函数
function c80925836.cfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_FIEND) and not c:IsPublic()
end
-- 维持代价效果的具体处理函数（选择送墓、展示或破坏）
function c80925836.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 选中该卡并显示被选为对象的动画效果，提示玩家正在处理该卡的维持代价
	Duel.HintSelection(Group.FromCards(c))
	-- 获取玩家手牌中满足送墓条件的「核成兽的钢核」卡片组
	local g1=Duel.GetMatchingGroup(c80925836.cfilter1,tp,LOCATION_HAND,0,nil)
	-- 获取玩家手牌中满足展示条件的恶魔族怪兽卡片组
	local g2=Duel.GetMatchingGroup(c80925836.cfilter2,tp,LOCATION_HAND,0,nil)
	local select=2
	-- 提示玩家进行选项选择
	Duel.Hint(HINT_SELECTMSG,tp,0)
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 当手牌中既有「核成兽的钢核」又有恶魔族怪兽时，让玩家在“送墓”、“展示”和“破坏”三个选项中选择
		select=Duel.SelectOption(tp,aux.Stringid(80925836,0),aux.Stringid(80925836,1),aux.Stringid(80925836,2))  --"选择一张「核成兽的钢核」送去墓地/选择一只恶魔族怪物给对方观看/破坏「核成恶魔」"
	elseif g1:GetCount()>0 then
		-- 当手牌中只有「核成兽的钢核」时，让玩家在“送墓”和“破坏”两个选项中选择
		select=Duel.SelectOption(tp,aux.Stringid(80925836,0),aux.Stringid(80925836,2))  --"选择一张「核成兽的钢核」送去墓地/破坏「核成恶魔」"
		if select==1 then select=2 end
	elseif g2:GetCount()>0 then
		-- 当手牌中只有恶魔族怪兽时，让玩家在“展示”和“破坏”两个选项中选择，并对返回值进行偏移处理
		select=Duel.SelectOption(tp,aux.Stringid(80925836,1),aux.Stringid(80925836,2))+1  --"选择一只恶魔族怪物给对方观看/破坏「核成恶魔」"
	else
		-- 当手牌中既没有「核成兽的钢核」也没有恶魔族怪兽时，强制玩家选择“破坏”选项
		select=Duel.SelectOption(tp,aux.Stringid(80925836,2))  --"破坏「核成恶魔」"
		select=2
	end
	if select==0 then
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g=g1:Select(tp,1,1,nil)
		-- 将选中的卡作为维持代价送去墓地
		Duel.SendtoGrave(g,REASON_COST)
	elseif select==1 then
		-- 提示玩家选择要给对方确认的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local g=g2:Select(tp,1,1,nil)
		-- 给对方玩家确认选中的手牌怪兽
		Duel.ConfirmCards(1-tp,g)
		-- 重新洗切玩家的手牌
		Duel.ShuffleHand(tp)
	else
		-- 因未支付维持代价而将这张卡破坏
		Duel.Destroy(c,REASON_COST)
	end
end
-- 无效化光属性及暗属性怪兽效果的具体处理函数
function c80925836.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的游戏阶段
	local ph=Duel.GetCurrentPhase()
	if (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and re:IsActiveType(TYPE_MONSTER)
		and re:GetHandler():IsAttribute(ATTRIBUTE_DARK+ATTRIBUTE_LIGHT) then
		-- 无效化该连锁的效果
		Duel.NegateEffect(ev)
	end
end
