--閃光の双剣－トライス
-- 效果：
-- 从手卡送去墓地1张卡，这张卡才能进行装备。装备这张卡的怪兽攻击力下降500点。装备这张卡的怪兽在同1个战斗阶段中可以进行2次攻击。
function c21900719.initial_effect(c)
	-- 从手卡送去墓地1张卡，这张卡才能进行装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetCost(c21900719.cost)
	e1:SetTarget(c21900719.target)
	e1:SetOperation(c21900719.operation)
	c:RegisterEffect(e1)
	-- 装备这张卡的怪兽攻击力下降500点。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(-500)
	c:RegisterEffect(e2)
	-- 装备这张卡的怪兽在同1个战斗阶段中可以进行2次攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_EXTRA_ATTACK)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 装备这张卡的怪兽。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
-- 发动时支付代价：从手卡丢弃1张卡作为发动这张装备魔法的代价。
function c21900719.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在至少1张可以作为代价送去墓地的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 让玩家从手牌选择1张卡，以代价形式丢弃到墓地。
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
-- 选择场上1只表侧表示怪兽作为装备对象，并设置装备处理信息。
function c21900719.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在至少1只表侧表示怪兽可以作为装备对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家弹出“请选择要装备的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示怪兽，并将其登记为这张卡装备的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁的操作信息，标明这张卡将进行装备且目标为这张卡自身。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡和对象仍与效果关联且对象表侧表示，则将这张卡装备给那只怪兽。
function c21900719.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时需要装备的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张装备卡装备到选择的对象怪兽上。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
