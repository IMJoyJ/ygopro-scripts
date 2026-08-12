--甲虫装機の魔剣 ゼクトキャリバー
-- 效果：
-- 名字带有「甲虫装机」的怪兽才能装备。装备怪兽的攻击力·守备力上升800。场上表侧表示存在的这张卡被送去墓地时，选择自己墓地1只名字带有「甲虫装机」的怪兽加入手卡。
function c16550875.initial_effect(c)
	-- 名字带有「甲虫装机」的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c16550875.target)
	e1:SetOperation(c16550875.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力·守备力上升800。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(800)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- 名字带有「甲虫装机」的怪兽才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c16550875.eqlimit)
	c:RegisterEffect(e3)
	-- 场上表侧表示存在的这张卡被送去墓地时，选择自己墓地1只名字带有「甲虫装机」的怪兽加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(16550875,0))  --"加入手卡"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c16550875.thcon)
	e4:SetTarget(c16550875.thtg)
	e4:SetOperation(c16550875.thop)
	c:RegisterEffect(e4)
end
-- 限制装备对象为名字带有「甲虫装机」的怪兽。
function c16550875.eqlimit(e,c)
	return c:IsSetCard(0x56)
end
-- 筛选场上名字带有「甲虫装机」的表侧表示怪兽。
function c16550875.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x56)
end
-- 选择场上名字带有「甲虫装机」的表侧表示怪兽作为装备对象。
function c16550875.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c16550875.filter(chkc) end
	-- 判断是否存在名字带有「甲虫装机」的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(c16550875.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上名字带有「甲虫装机」的表侧表示怪兽作为装备对象。
	Duel.SelectTarget(tp,c16550875.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置装备效果的处理信息。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作，将装备卡装备给目标怪兽。
function c16550875.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的装备对象。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽。
		Duel.Equip(tp,c,tc)
	end
end
-- 判断装备卡是否从场上以表侧表示被送去墓地。
function c16550875.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_FACEUP)
		and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 筛选玩家墓地名字带有「甲虫装机」的怪兽。
function c16550875.thfilter(c)
	return c:IsSetCard(0x56) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 选择玩家墓地名字带有「甲虫装机」的怪兽加入手卡。
function c16550875.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c16550875.thfilter(chkc) end
	-- 判断是否存在玩家墓地名字带有「甲虫装机」的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c16550875.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择玩家墓地名字带有「甲虫装机」的怪兽作为目标。
	local g=Duel.SelectTarget(tp,c16550875.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置将怪兽加入手牌的处理信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 执行将目标怪兽加入手牌的操作。
function c16550875.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的怪兽。
		Duel.ConfirmCards(1-tp,tc)
	end
end
