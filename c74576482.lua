--コアキメイル・シーパンサー
-- 效果：
-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只水属性怪兽给对方观看。或者都不进行让这张卡破坏。1回合1次，可以从手卡把1张「核成兽的钢核」送去墓地，选择自己墓地存在的1张魔法卡回到卡组最上面。
function c74576482.initial_effect(c)
	-- 注册该卡关联的卡片密码（「核成兽的钢核」的卡片密码为36623431）
	aux.AddCodeList(c,36623431)
	-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只水属性怪兽给对方观看。或者都不进行让这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c74576482.mtcon)
	e1:SetOperation(c74576482.mtop)
	c:RegisterEffect(e1)
	-- 1回合1次，可以从手卡把1张「核成兽的钢核」送去墓地，选择自己墓地存在的1张魔法卡回到卡组最上面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(74576482,3))  --"返回卡组"
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c74576482.tdcost)
	e2:SetTarget(c74576482.tdtg)
	e2:SetOperation(c74576482.tdop)
	c:RegisterEffect(e2)
end
-- 维持效果发动的条件过滤函数（仅在自己的结束阶段）
function c74576482.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为该卡的控制者
	return Duel.GetTurnPlayer()==tp
end
-- 过滤手卡中可作为Cost送去墓地的「核成兽的钢核」
function c74576482.cfilter1(c)
	return c:IsCode(36623431) and c:IsAbleToGraveAsCost()
end
-- 过滤手卡中未公开的水属性怪兽卡
function c74576482.cfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_WATER) and not c:IsPublic()
end
-- 维持效果的具体处理（选择送墓「核成兽的钢核」、展示水属性怪兽或破坏自身）
function c74576482.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 选中该卡并显示被选为对象的动画效果
	Duel.HintSelection(Group.FromCards(c))
	-- 获取手卡中满足条件的「核成兽的钢核」卡片组
	local g1=Duel.GetMatchingGroup(c74576482.cfilter1,tp,LOCATION_HAND,0,nil)
	-- 获取手卡中满足条件的水属性怪兽卡片组
	local g2=Duel.GetMatchingGroup(c74576482.cfilter2,tp,LOCATION_HAND,0,nil)
	local select=2
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 玩家手卡同时存在「核成兽的钢核」和水属性怪兽时，提供三个选项：送墓钢核、展示水属性怪兽、破坏自身
		select=Duel.SelectOption(tp,aux.Stringid(74576482,0),aux.Stringid(74576482,1),aux.Stringid(74576482,2))  --"选择一张「核成兽的钢核」送去墓地/选择一张水属性怪兽给对方观看/破坏「核成海豹」"
	elseif g1:GetCount()>0 then
		-- 玩家手卡仅有「核成兽的钢核」时，提供两个选项：送墓钢核、破坏自身
		select=Duel.SelectOption(tp,aux.Stringid(74576482,0),aux.Stringid(74576482,2))  --"选择一张「核成兽的钢核」送去墓地/破坏「核成海豹」"
		if select==1 then select=2 end
	elseif g2:GetCount()>0 then
		-- 玩家手卡仅有水属性怪兽时，提供两个选项：展示水属性怪兽、破坏自身，并对选项索引进行偏移处理
		select=Duel.SelectOption(tp,aux.Stringid(74576482,1),aux.Stringid(74576482,2))+1  --"选择一张水属性怪兽给对方观看/破坏「核成海豹」"
	else
		-- 玩家手卡既无「核成兽的钢核」也无水属性怪兽时，强制选择破坏自身
		select=Duel.SelectOption(tp,aux.Stringid(74576482,2))  --"破坏「核成海豹」"
		select=2
	end
	if select==0 then
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g=g1:Select(tp,1,1,nil)
		-- 将选择的卡作为Cost送去墓地
		Duel.SendtoGrave(g,REASON_COST)
	elseif select==1 then
		-- 提示玩家选择要给对方确认的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local g=g2:Select(tp,1,1,nil)
		-- 给对方玩家确认选择的手卡
		Duel.ConfirmCards(1-tp,g)
		-- 重新洗切手卡
		Duel.ShuffleHand(tp)
	else
		-- 将自身作为Cost破坏
		Duel.Destroy(c,REASON_COST)
	end
end
-- 魔法卡回卡组效果的Cost处理函数（从手卡把1张「核成兽的钢核」送去墓地）
function c74576482.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可作为Cost送去墓地的「核成兽的钢核」
	if chk==0 then return Duel.IsExistingMatchingCard(c74576482.cfilter1,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择手卡中1张「核成兽的钢核」
	local g=Duel.SelectMatchingCard(tp,c74576482.cfilter1,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的「核成兽的钢核」作为Cost送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤自己墓地中可以回到卡组的魔法卡
function c74576482.filter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToDeck()
end
-- 魔法卡回卡组效果的目标选择与发动准备函数
function c74576482.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c74576482.filter(chkc) end
	-- 检查自己墓地是否存在可以回到卡组的魔法卡
	if chk==0 then return Duel.IsExistingTarget(c74576482.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地存在的1张魔法卡作为效果对象
	local g=Duel.SelectTarget(tp,c74576482.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息为“将选中的1张卡送回卡组”
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 魔法卡回卡组效果的具体处理函数
function c74576482.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的目标卡片（即选中的墓地魔法卡）
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片送回持有者卡组的最上面
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
