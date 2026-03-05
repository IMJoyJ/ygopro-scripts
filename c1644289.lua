--ヴァイロン・セグメント
-- 效果：
-- 名字带有「大日」的怪兽才能装备。装备怪兽不会成为对方的陷阱·效果怪兽的效果的对象。场上表侧表示存在的这张卡被送去墓地的场合，可以从自己卡组把1张名字带有「大日」的魔法卡加入手卡。
function c1644289.initial_effect(c)
	-- 名字带有「大日」的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c1644289.target)
	e1:SetOperation(c1644289.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽不会成为对方的陷阱·效果怪兽的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetValue(c1644289.tglimit)
	c:RegisterEffect(e2)
	-- 场上表侧表示存在的这张卡被送去墓地的场合，可以从自己卡组把1张名字带有「大日」的魔法卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c1644289.eqlimit)
	c:RegisterEffect(e3)
	-- 名字带有「大日」的怪兽才能装备。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(1644289,0))  --"检索"
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c1644289.thcon)
	e4:SetTarget(c1644289.thtg)
	e4:SetOperation(c1644289.thop)
	c:RegisterEffect(e4)
end
-- 限制装备对象为名字带有「大日」的怪兽。
function c1644289.eqlimit(e,c)
	return c:IsSetCard(0x30)
end
-- 装备怪兽不会成为对方的陷阱·效果怪兽的效果的对象。
function c1644289.tglimit(e,re,rp)
	return rp==1-e:GetHandlerPlayer() and re:IsActiveType(TYPE_TRAP+TYPE_MONSTER)
end
-- 筛选场上名字带有「大日」的表侧表示怪兽。
function c1644289.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x30)
end
-- 选择场上名字带有「大日」的表侧表示怪兽作为装备对象。
function c1644289.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c1644289.filter(chkc) end
	-- 检查场上是否存在名字带有「大日」的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(c1644289.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上名字带有「大日」的表侧表示怪兽作为装备对象。
	Duel.SelectTarget(tp,c1644289.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为装备效果。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作。
function c1644289.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的装备对象。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽。
		Duel.Equip(tp,c,tc)
	end
end
-- 场上表侧表示存在的这张卡被送去墓地的场合。
function c1644289.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_FACEUP)
		and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 筛选卡组中名字带有「大日」的魔法卡。
function c1644289.thfilter(c)
	return c:IsSetCard(0x30) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 设置检索效果的处理信息。
function c1644289.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在名字带有「大日」的魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c1644289.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息为将卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果。
function c1644289.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择一张名字带有「大日」的魔法卡。
	local g=Duel.SelectMatchingCard(tp,c1644289.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的魔法卡加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
