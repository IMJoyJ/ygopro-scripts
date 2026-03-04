--コアキメイル・ドラゴ
-- 效果：
-- 这张卡的控制者在每次自己结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只龙族怪兽给对方观看。或者都不进行让这张卡破坏。
-- ①：只要这张卡在怪兽区域存在，双方不能把光·暗属性怪兽特殊召唤。
function c12435193.initial_effect(c)
	-- 为卡片注册「核成兽的钢核」的卡片代码，用于后续效果判断
	aux.AddCodeList(c,36623431)
	-- 这张卡的控制者在每次自己结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只龙族怪兽给对方观看。或者都不进行让这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c12435193.mtcon)
	e1:SetOperation(c12435193.mtop)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，双方不能把光·暗属性怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetTarget(c12435193.disspsum)
	c:RegisterEffect(e2)
end
-- 判断是否为当前回合玩家触发效果
function c12435193.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果持有者
	return Duel.GetTurnPlayer()==tp
end
-- 过滤手卡中可作为代价送去墓地的「核成兽的钢核」
function c12435193.cfilter1(c)
	return c:IsCode(36623431) and c:IsAbleToGraveAsCost()
end
-- 过滤手卡中可作为代价给对方确认的龙族怪兽
function c12435193.cfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_DRAGON) and not c:IsPublic()
end
-- 执行结束阶段效果处理逻辑
function c12435193.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 显示选择对象的动画效果
	Duel.HintSelection(Group.FromCards(c))
	-- 获取满足条件的「核成兽的钢核」卡片组
	local g1=Duel.GetMatchingGroup(c12435193.cfilter1,tp,LOCATION_HAND,0,nil)
	-- 获取满足条件的龙族怪兽卡片组
	local g2=Duel.GetMatchingGroup(c12435193.cfilter2,tp,LOCATION_HAND,0,nil)
	local select=2
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 当同时存在「核成兽的钢核」和龙族怪兽时，选择将其中一张送去墓地或给对方确认一只龙族怪兽
		select=Duel.SelectOption(tp,aux.Stringid(12435193,0),aux.Stringid(12435193,1),aux.Stringid(12435193,2))  --"选择一张「核成兽的钢核」送去墓地"
	elseif g1:GetCount()>0 then
		-- 当只有「核成兽的钢核」时，选择将一张送去墓地或破坏此卡
		select=Duel.SelectOption(tp,aux.Stringid(12435193,0),aux.Stringid(12435193,2))  --"选择一张「核成兽的钢核」送去墓地"
		if select==1 then select=2 end
	elseif g2:GetCount()>0 then
		-- 当只有龙族怪兽时，选择给对方确认一只龙族怪兽或破坏此卡
		select=Duel.SelectOption(tp,aux.Stringid(12435193,1),aux.Stringid(12435193,2))+1  --"选择一只龙族怪物给对方观看"
	else
		-- 当既无「核成兽的钢核」也无龙族怪兽时，只能选择破坏此卡
		select=Duel.SelectOption(tp,aux.Stringid(12435193,2))  --"破坏「核成龙」"
		select=2
	end
	if select==0 then
		-- 提示选择将卡片送去墓地
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=g1:Select(tp,1,1,nil)
		-- 将选择的卡片送去墓地
		Duel.SendtoGrave(g,REASON_COST)
	elseif select==1 then
		-- 提示选择给对方确认的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local g=g2:Select(tp,1,1,nil)
		-- 向对方玩家确认选择的卡片
		Duel.ConfirmCards(1-tp,g)
		-- 洗切自己的手牌
		Duel.ShuffleHand(tp)
	else
		-- 破坏此卡
		Duel.Destroy(c,REASON_COST)
	end
end
-- 判断目标怪兽是否为光·暗属性
function c12435193.disspsum(e,c)
	return c:IsAttribute(ATTRIBUTE_DARK+ATTRIBUTE_LIGHT)
end
