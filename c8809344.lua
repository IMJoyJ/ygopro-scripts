--外神ナイアルラ
-- 效果：
-- 4星怪兽×2
-- ①：这张卡超量召唤成功时，把手卡任意数量丢弃才能发动。这张卡的阶级上升丢弃数量的数值。
-- ②：1回合1次，这张卡持有超量素材的场合以自己墓地1只怪兽为对象才能发动。这张卡的超量素材全部取除，把作为对象的怪兽在这张卡下面重叠作为超量素材。这张卡的种族·属性变成和这个效果作为超量素材的怪兽的原本的种族·属性相同。
function c8809344.initial_effect(c)
	-- 设置超量召唤手续：4星怪兽×2
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：这张卡超量召唤成功时，把手卡任意数量丢弃才能发动。这张卡的阶级上升丢弃数量的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(8809344,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c8809344.rkcon)
	e1:SetCost(c8809344.rkcost)
	e1:SetOperation(c8809344.rkop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，这张卡持有超量素材的场合以自己墓地1只怪兽为对象才能发动。这张卡的超量素材全部取除，把作为对象的怪兽在这张卡下面重叠作为超量素材。这张卡的种族·属性变成和这个效果作为超量素材的怪兽的原本的种族·属性相同。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(8809344,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c8809344.condition)
	e2:SetTarget(c8809344.target)
	e2:SetOperation(c8809344.operation)
	c:RegisterEffect(e2)
end
-- 检查发动条件：此卡是否超量召唤成功
function c8809344.rkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 效果1的代价处理：丢弃任意数量的手牌，并记录丢弃的数量
function c8809344.rkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在至少1张可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并丢弃任意数量的手牌作为代价，返回实际丢弃的数量
	local ct=Duel.DiscardHand(tp,Card.IsDiscardable,1,60,REASON_COST+REASON_DISCARD)
	e:SetLabel(ct)
end
-- 效果1的效果处理：使这张卡的阶级上升丢弃手牌数量的数值
function c8809344.rkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的阶级上升丢弃数量的数值。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_RANK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e2:SetValue(e:GetLabel())
		c:RegisterEffect(e2)
	end
end
-- 检查发动条件：此卡是超量怪兽且持有超量素材
function c8809344.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsType(TYPE_XYZ) and e:GetHandler():GetOverlayCount()>0
end
-- 过滤条件：墓地中可以作为超量素材的怪兽卡
function c8809344.matfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanOverlay()
end
-- 效果2的对象选择与效果分类设置
function c8809344.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c8809344.matfilter(chkc) end
	-- 检查自己墓地是否存在至少1只满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c8809344.matfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要作为超量素材的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 选择自己墓地1只怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c8809344.matfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：有1张卡将离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 效果2的效果处理：取除全部素材，将对象怪兽叠放为素材，并改变自身的种族和属性
function c8809344.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsCanOverlay() then
		local og=c:GetOverlayGroup()
		if og:GetCount()==0 then return end
		-- 将这张卡持有的超量素材全部送去墓地
		Duel.SendtoGrave(og,REASON_EFFECT)
		-- 将作为对象的怪兽重叠在这张卡下面作为超量素材
		Duel.Overlay(c,Group.FromCards(tc))
		if c:IsFacedown() then return end
		-- 这张卡的属性变成和这个效果作为超量素材的怪兽的原本的属性相同。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(tc:GetOriginalAttribute())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_RACE)
		e2:SetValue(tc:GetOriginalRace())
		c:RegisterEffect(e2)
	end
end
