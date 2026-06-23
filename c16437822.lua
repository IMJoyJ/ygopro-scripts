--フリント・アタック
-- 效果：
-- 把有「打火石」装备的1只怪兽破坏。发动后这张卡被送去墓地时，这张卡可以回到卡组。
function c16437822.initial_effect(c)
	-- 把有「打火石」装备的1只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c16437822.target)
	e1:SetOperation(c16437822.activate)
	c:RegisterEffect(e1)
	-- 发动后这张卡被送去墓地时，这张卡可以回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16437822,0))  --"返回卡组"
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c16437822.retcon)
	e2:SetTarget(c16437822.rettg)
	e2:SetOperation(c16437822.retop)
	c:RegisterEffect(e2)
	-- 记录卡片离开场上的状态以判断是否满足返回卡组条件
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_LEAVE_FIELD_P)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(c16437822.checkop)
	c:RegisterEffect(e3)
	e2:SetLabelObject(e3)
end
-- 筛选有装备卡且装备的是「打火石」的怪兽
function c16437822.filter(c)
	return c:GetEquipCount()~=0 and c:GetEquipGroup():IsExists(Card.IsCode,1,nil,75560629)
end
-- 选择目标怪兽并设置破坏效果
function c16437822.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c16437822.filter(chkc) end
	-- 判断是否存在符合条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c16437822.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择符合条件的1只怪兽作为破坏对象
	local g=Duel.SelectTarget(tp,c16437822.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏效果
function c16437822.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 检测卡片是否在离开场上时被确认
function c16437822.checkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_LEAVE_CONFIRMED) then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 判断卡片是否满足返回卡组的条件
function c16437822.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetLabel()==1
end
-- 设置返回卡组效果的操作信息
function c16437822.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeck() end
	-- 设置返回卡组效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 执行返回卡组效果
function c16437822.retop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将卡片送回卡组并洗牌
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
