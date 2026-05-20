--曙光の騎士
-- 效果：
-- 场上的这张卡被送去墓地的场合，可以从卡组把1只光属性怪兽送去墓地。此外，这张卡从卡组送去墓地的场合，选择自己墓地1只光属性怪兽在卡组最上面放置。「曙光之骑士」的效果1回合只能使用1次。
function c6351548.initial_effect(c)
	-- 场上的这张卡被送去墓地的场合，可以从卡组把1只光属性怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(6351548,0))  --"送墓"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,6351548)
	e1:SetCondition(c6351548.condition)
	e1:SetTarget(c6351548.target)
	e1:SetOperation(c6351548.operation)
	c:RegisterEffect(e1)
	-- 此外，这张卡从卡组送去墓地的场合，选择自己墓地1只光属性怪兽在卡组最上面放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(6351548,1))  --"返回卡组"
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,6351548)
	e2:SetCondition(c6351548.tdcon)
	e2:SetTarget(c6351548.tdtg)
	e2:SetOperation(c6351548.tdop)
	c:RegisterEffect(e2)
end
-- 检查这张卡被送去墓地前的原本位置是否在场上
function c6351548.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤卡组中可以送去墓地的光属性怪兽
function c6351548.tgfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToGrave()
end
-- 效果1的发动准备，检查卡组中是否存在符合条件的怪兽并设置送去墓地的操作信息
function c6351548.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只可以送去墓地的光属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c6351548.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将卡组中的1张卡送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果1的处理，从卡组选择1只光属性怪兽送去墓地
function c6351548.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1只符合条件的光属性怪兽
	local g=Duel.SelectMatchingCard(tp,c6351548.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽因效果送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 检查这张卡被送去墓地前的原本位置是否在卡组
function c6351548.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_DECK)
end
-- 过滤墓地中可以返回卡组的光属性怪兽
function c6351548.tdfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToDeck()
end
-- 效果2的发动准备，选择自己墓地1只光属性怪兽作为对象，并设置返回卡组的操作信息
function c6351548.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c6351548.tdfilter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地1只符合条件的光属性怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c6351548.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置将对象卡片返回卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果2的处理，将作为对象的墓地怪兽放置在卡组最上面
function c6351548.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽放置在持有者卡组的最上面
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
