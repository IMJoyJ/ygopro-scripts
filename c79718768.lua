--急転直下
-- 效果：
-- 对方把以墓地存在的卡为对象的魔法·陷阱·效果怪兽的效果发动的场合这张卡破坏。这张卡的效果让这张卡被破坏送去墓地时，对方把墓地存在的卡全部加入卡组洗切。
function c79718768.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 对方把以墓地存在的卡为对象的魔法·陷阱·效果怪兽的效果发动的场合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_BECOME_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(c79718768.desop1)
	c:RegisterEffect(e2)
	-- 这张卡破坏
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetOperation(c79718768.desop2)
	c:RegisterEffect(e3)
	e3:SetLabelObject(e2)
	-- 这张卡的效果让这张卡被破坏送去墓地时，对方把墓地存在的卡全部加入卡组洗切。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(79718768,0))  --"返回卡组"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c79718768.retcon)
	e4:SetOperation(c79718768.retop)
	c:RegisterEffect(e4)
end
-- 在卡片成为效果对象时触发，若该效果由对方发动、属于取对象效果且对象包含墓地的卡，则将该效果记录在LabelObject中
function c79718768.desop1(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
		or not eg:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) then
		e:SetLabelObject(nil)
	else e:SetLabelObject(re) end
end
-- 在连锁处理结束时触发，若刚刚处理完毕的效果与之前记录的满足条件的效果一致，则将这张卡破坏
function c79718768.desop2(e,tp,eg,ep,ev,re,r,rp)
	local pe=e:GetLabelObject():GetLabelObject()
	if pe and pe==re then
		-- 因效果将这张卡破坏
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
-- 检查导致这张卡送去墓地的效果是否是这张卡自身的效果
function c79718768.retcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler()==e:GetHandler()
end
-- 获取对方墓地的所有卡片，并将其全部送回卡组洗切
function c79718768.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方墓地的所有卡片
	local g=Duel.GetFieldGroup(tp,0,LOCATION_GRAVE)
	-- 将获取到的卡片全部送回持有者卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
