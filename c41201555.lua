--コアキメイル・グラヴィローズ
-- 效果：
-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只植物族怪兽给对方观看。或者都不进行让这张卡破坏。自己的准备阶段时只有1次，可以从自己卡组把1只3星以下的怪兽送去墓地。
function c41201555.initial_effect(c)
	-- 注册卡片效果中涉及的其他卡片代码
	aux.AddCodeList(c,36623431)
	-- 在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只植物族怪兽给对方观看。或者都不进行让这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c41201555.mtcon)
	e1:SetOperation(c41201555.mtop)
	c:RegisterEffect(e1)
	-- 自己的准备阶段时只有1次，可以从自己卡组把1只3星以下的怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41201555,3))  --"送墓"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c41201555.condition)
	e2:SetTarget(c41201555.target)
	e2:SetOperation(c41201555.operation)
	c:RegisterEffect(e2)
end
-- 判断是否为当前回合玩家
function c41201555.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家
	return Duel.GetTurnPlayer()==tp
end
-- 过滤手卡中「核成兽的钢核」的条件
function c41201555.cfilter1(c)
	return c:IsCode(36623431) and c:IsAbleToGraveAsCost()
end
-- 过滤手卡中植物族怪兽的条件
function c41201555.cfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_PLANT) and not c:IsPublic()
end
-- 处理结束阶段效果的主函数
function c41201555.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 显示选择对象的动画效果
	Duel.HintSelection(Group.FromCards(c))
	-- 获取手卡中「核成兽的钢核」的卡片组
	local g1=Duel.GetMatchingGroup(c41201555.cfilter1,tp,LOCATION_HAND,0,nil)
	-- 获取手卡中植物族怪兽的卡片组
	local g2=Duel.GetMatchingGroup(c41201555.cfilter2,tp,LOCATION_HAND,0,nil)
	local select=2
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 选择效果处理方式：送去墓地/给对方观看/破坏
		select=Duel.SelectOption(tp,aux.Stringid(41201555,0),aux.Stringid(41201555,1),aux.Stringid(41201555,2))  --"选择一张「核成兽的钢核」送去墓地/选择一张植物族怪兽给对方观看/破坏「核成孕妇蔷薇」"
	elseif g1:GetCount()>0 then
		-- 选择效果处理方式：送去墓地/破坏
		select=Duel.SelectOption(tp,aux.Stringid(41201555,0),aux.Stringid(41201555,2))  --"选择一张「核成兽的钢核」送去墓地/破坏「核成孕妇蔷薇」"
		if select==1 then select=2 end
	elseif g2:GetCount()>0 then
		-- 选择效果处理方式：给对方观看/破坏
		select=Duel.SelectOption(tp,aux.Stringid(41201555,1),aux.Stringid(41201555,2))+1  --"选择一张植物族怪兽给对方观看/破坏「核成孕妇蔷薇」"
	else
		-- 选择效果处理方式：破坏
		select=Duel.SelectOption(tp,aux.Stringid(41201555,2))  --"破坏「核成孕妇蔷薇」"
		select=2
	end
	if select==0 then
		-- 提示选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g=g1:Select(tp,1,1,nil)
		-- 将选择的卡送去墓地
		Duel.SendtoGrave(g,REASON_COST)
	elseif select==1 then
		-- 提示选择要给对方确认的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local g=g2:Select(tp,1,1,nil)
		-- 确认对方查看选择的卡
		Duel.ConfirmCards(1-tp,g)
		-- 洗切自己的手牌
		Duel.ShuffleHand(tp)
	else
		-- 破坏自身
		Duel.Destroy(c,REASON_COST)
	end
end
-- 判断是否为当前回合玩家
function c41201555.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家
	return Duel.GetTurnPlayer()==tp
end
-- 过滤卡组中3星以下怪兽的条件
function c41201555.tgfilter(c)
	return c:IsLevelBelow(3) and c:IsAbleToGrave()
end
-- 设置效果目标
function c41201555.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c41201555.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 处理准备阶段效果的主函数
function c41201555.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c41201555.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
