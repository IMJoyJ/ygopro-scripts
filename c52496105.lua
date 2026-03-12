--剣闘獣の闘器マニカ
-- 效果：
-- 名字带有「剑斗兽」的怪兽才能装备。只要有这张卡装备，装备怪兽不会被战斗破坏（伤害计算适用）。装备怪兽从自己场上回到卡组让这张卡被送去墓地时，这张卡回到手卡。
function c52496105.initial_effect(c)
	-- 装备效果，可以将名字带有「剑斗兽」的怪兽装备到自己场上
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c52496105.target)
	e1:SetOperation(c52496105.operation)
	c:RegisterEffect(e1)
	-- 只要这张卡装备，装备怪兽不会被战斗破坏（伤害计算适用）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 名字带有「剑斗兽」的怪兽才能装备
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c52496105.eqlimit)
	c:RegisterEffect(e3)
	-- 装备怪兽从自己场上回到卡组让这张卡被送去墓地时，这张卡回到手卡
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetDescription(aux.Stringid(52496105,0))  --"返回手牌"
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c52496105.retcon)
	e4:SetTarget(c52496105.rettg)
	e4:SetOperation(c52496105.retop)
	c:RegisterEffect(e4)
end
-- 判断装备对象是否为名字带有「剑斗兽」的怪兽
function c52496105.eqlimit(e,c)
	return c:IsSetCard(0x1019)
end
-- 筛选场上名字带有「剑斗兽」的表侧表示怪兽
function c52496105.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1019)
end
-- 选择目标怪兽进行装备
function c52496105.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c52496105.filter(chkc) end
	-- 判断是否存在名字带有「剑斗兽」的表侧表示怪兽作为装备对象
	if chk==0 then return Duel.IsExistingTarget(c52496105.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择名字带有「剑斗兽」的表侧表示怪兽作为装备对象
	Duel.SelectTarget(tp,c52496105.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置装备效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作，将装备卡装备给目标怪兽
function c52496105.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的装备对象
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 判断是否因失去装备对象而送去墓地且装备怪兽在卡组或额外卡组
function c52496105.retcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	return c:IsReason(REASON_LOST_TARGET) and ec:IsLocation(LOCATION_DECK+LOCATION_EXTRA)
end
-- 设置返回手牌效果的处理信息
function c52496105.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置返回手牌效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 执行返回手牌效果，将装备卡送回手牌
function c52496105.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将装备卡以效果原因送回手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 向对方确认装备卡
		Duel.ConfirmCards(1-tp,c)
	end
end
