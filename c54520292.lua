--コアキメイル・アイス
-- 效果：
-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1张永续魔法卡给对方观看。或者都不进行让这张卡破坏。可以把1张手卡送去墓地让场上存在的1只特殊召唤的怪兽破坏。
function c54520292.initial_effect(c)
	-- 注册该卡关联的卡片密码（核成兽的钢核）
	aux.AddCodeList(c,36623431)
	-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1张永续魔法卡给对方观看。或者都不进行让这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c54520292.mtcon)
	e1:SetOperation(c54520292.mtop)
	c:RegisterEffect(e1)
	-- 可以把1张手卡送去墓地让场上存在的1只特殊召唤的怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(54520292,3))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCost(c54520292.descost)
	e2:SetTarget(c54520292.destg)
	e2:SetOperation(c54520292.desop)
	c:RegisterEffect(e2)
end
-- 维持效果的发动条件：当前回合是自己的回合
function c54520292.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为该卡的控制者
	return Duel.GetTurnPlayer()==tp
end
-- 过滤条件：手牌中的「核成兽的钢核」且能作为Cost送去墓地
function c54520292.cfilter1(c)
	return c:IsCode(36623431) and c:IsAbleToGraveAsCost()
end
-- 过滤条件：手牌中未公开的永续魔法卡
function c54520292.cfilter2(c)
	return c:GetType()==TYPE_SPELL+TYPE_CONTINUOUS and not c:IsPublic()
end
-- 维持效果的具体处理：选择将「核成兽的钢核」送去墓地、展示永续魔法卡或破坏自身
function c54520292.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 选中该卡并显示选中动画，提示玩家该卡正在进行维持效果处理
	Duel.HintSelection(Group.FromCards(c))
	-- 获取手牌中满足送墓条件的「核成兽的钢核」卡片组
	local g1=Duel.GetMatchingGroup(c54520292.cfilter1,tp,LOCATION_HAND,0,nil)
	-- 获取手牌中满足展示条件的永续魔法卡卡片组
	local g2=Duel.GetMatchingGroup(c54520292.cfilter2,tp,LOCATION_HAND,0,nil)
	local select=2
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 玩家手牌中既有「核成兽的钢核」又有永续魔法卡时，提供三个选项：送墓、展示、破坏自身
		select=Duel.SelectOption(tp,aux.Stringid(54520292,0),aux.Stringid(54520292,1),aux.Stringid(54520292,2))  --"选择一张「核成兽的钢核」送去墓地/选择一张永续魔法卡给对方观看/破坏「核成冰人」"
	elseif g1:GetCount()>0 then
		-- 玩家手牌中只有「核成兽的钢核」时，提供两个选项：送墓、破坏自身
		select=Duel.SelectOption(tp,aux.Stringid(54520292,0),aux.Stringid(54520292,2))  --"选择一张「核成兽的钢核」送去墓地/破坏「核成冰人」"
		if select==1 then select=2 end
	elseif g2:GetCount()>0 then
		-- 玩家手牌中只有永续魔法卡时，提供两个选项：展示、破坏自身，并对返回值进行偏移处理
		select=Duel.SelectOption(tp,aux.Stringid(54520292,1),aux.Stringid(54520292,2))+1  --"选择一张永续魔法卡给对方观看/破坏「核成冰人」"
	else
		-- 玩家手牌中两者都没有时，强制选择破坏自身
		select=Duel.SelectOption(tp,aux.Stringid(54520292,2))  --"破坏「核成冰人」"
		select=2
	end
	if select==0 then
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g=g1:Select(tp,1,1,nil)
		-- 将选中的卡作为维持Cost送去墓地
		Duel.SendtoGrave(g,REASON_COST)
	elseif select==1 then
		-- 提示玩家选择要给对方确认的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local g=g2:Select(tp,1,1,nil)
		-- 给对方玩家确认选中的手牌
		Duel.ConfirmCards(1-tp,g)
		-- 洗切自身手牌
		Duel.ShuffleHand(tp)
	else
		-- 因未支付维持Cost而将自身破坏
		Duel.Destroy(c,REASON_COST)
	end
end
-- 破坏效果的Cost：把1张手卡送去墓地
function c54520292.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Cost检测：检查手牌中是否存在至少1张可以作为Cost送去墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要作为Cost送去墓地的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择1张手牌作为Cost送去墓地
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的手牌作为Cost送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤条件：特殊召唤的怪兽
function c54520292.filter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 破坏效果的目标选择与发动检测
function c54520292.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c54520292.filter(chkc) end
	-- 发动检测：检查场上是否存在可以作为效果对象的特殊召唤的怪兽
	if chk==0 then return Duel.IsExistingTarget(c54520292.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1只特殊召唤的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c54520292.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的具体处理
function c54520292.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 破坏该对象怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
