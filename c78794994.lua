--戦線復活の代償
-- 效果：
-- 把自己场上1只通常怪兽送去墓地，选择自己或者对方的墓地1只怪兽才能发动。选择的怪兽在自己场上特殊召唤，把这张卡装备。这张卡从场上离开时，装备怪兽破坏。
function c78794994.initial_effect(c)
	-- 把自己场上1只通常怪兽送去墓地，选择自己或者对方的墓地1只怪兽才能发动。选择的怪兽在自己场上特殊召唤，把这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c78794994.cost)
	e1:SetTarget(c78794994.target)
	e1:SetOperation(c78794994.operation)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时，装备怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c78794994.desop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的通常怪兽，且能作为代价送去墓地，并考虑怪兽区域空格限制
function c78794994.costfilter(c,ft,tp)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsAbleToGraveAsCost() and (ft>0 or c:GetSequence()<5)
end
-- 发动代价：把自己场上1只通常怪兽送去墓地
function c78794994.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自身场上怪兽区域的可用空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 在发动阶段检测是否满足发动代价（场上存在可送去墓地的通常怪兽，且有足够的怪兽区域空格）
	if chk==0 then return ft>-1 and Duel.IsExistingMatchingCard(c78794994.costfilter,tp,LOCATION_MZONE,0,1,nil,ft,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择1只满足条件的通常怪兽
	local g=Duel.SelectMatchingCard(tp,c78794994.costfilter,tp,LOCATION_MZONE,0,1,1,nil,ft,tp)
	-- 将选择的怪兽作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果发动时的对象选择与操作信息注册
function c78794994.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 检测双方墓地是否存在可以特殊召唤的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanBeSpecialSummoned,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,0,tp,false,false) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择双方墓地1只可以特殊召唤的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsCanBeSpecialSummoned,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,0,tp,false,false)
	-- 设置效果处理信息：包含特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置效果处理信息：包含装备这张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备限制：只能装备给这张卡的效果所选择的怪兽
function c78794994.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 效果处理：特殊召唤目标怪兽并装备这张卡，同时添加装备限制
function c78794994.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动的目标对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		-- 将目标怪兽在自己场上表侧表示特殊召唤，若特殊召唤失败则结束处理
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
		-- 将这张卡装备给特殊召唤的怪兽
		Duel.Equip(tp,c,tc)
		-- 把这张卡装备。
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c78794994.eqlimit)
		c:RegisterEffect(e1)
	end
end
-- 这张卡从场上离开时，破坏装备的怪兽
function c78794994.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 因效果破坏装备怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
