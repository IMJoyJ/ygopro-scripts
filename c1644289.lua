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
	-- 名字带有「大日」的怪兽才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c1644289.eqlimit)
	c:RegisterEffect(e3)
	-- 场上表侧表示存在的这张卡被送去墓地的场合，可以从自己卡组把1张名字带有「大日」的魔法卡加入手卡。
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
-- 判断装备对象是否满足装备限制：只有名字带有「大日」的怪兽才能装备此卡。
function c1644289.eqlimit(e,c)
	return c:IsSetCard(0x30)
end
-- 判定抗性条件：当效果来自对方玩家，且该效果的类型为陷阱卡或怪兽卡的效果时，装备怪兽不能成为那些效果的对象。
function c1644289.tglimit(e,re,rp)
	return rp==1-e:GetHandlerPlayer() and re:IsActiveType(TYPE_TRAP+TYPE_MONSTER)
end
-- 筛选可作为装备对象的怪兽：必须为场上表侧表示且名字带有「大日」的怪兽。
function c1644289.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x30)
end
-- 发动时的目标选择处理：从场上选择1只表侧表示的名字带有「大日」的怪兽作为装备对象，并设置将此卡装备给该怪兽的操作信息。
function c1644289.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c1644289.filter(chkc) end
	-- 检查发动时是否存在至少1只满足条件的表侧表示名字带有「大日」的怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c1644289.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向操作玩家发送“请选择要装备的卡”的提示，用于引导选择装备对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让操作玩家选择1只符合条件（表侧表示且名字带有「大日」）的场上怪兽，并将其锁定为本次效果的对象。
	Duel.SelectTarget(tp,c1644289.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本次效果将把这卡装备给对象怪兽，操作对象为这张装备卡本身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理时，确认这张卡和目标怪兽仍与效果相关且目标怪兽表侧表示，若是则将该卡装备给目标怪兽。
function c1644289.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备魔法卡装备给目标怪兽。
		Duel.Equip(tp,c,tc)
	end
end
-- 检索效果的发动条件：这张卡必须是场上表侧表示时被送去墓地，满足此情况才能发动检索效果。
function c1644289.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_FACEUP)
		and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 检索目标卡的过滤条件：卡名带有「大日」、是魔法卡，并且能够加入手卡。
function c1644289.thfilter(c)
	return c:IsSetCard(0x30) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 检索效果的目标设置：发动时确认卡组中存在符合条件的「大日」魔法卡，并设置加入手卡的操作信息。
function c1644289.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张名字带有「大日」的魔法卡且能够加入手卡，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c1644289.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：效果处理时准备从卡组把1张名字带有「大日」的魔法卡加入手卡，目标位置为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：玩家从卡组选择1张名字带有「大日」的魔法卡加入手卡，并向对方展示。
function c1644289.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件（名字带有「大日」、魔法卡、可加入手卡）的卡。
	local g=Duel.SelectMatchingCard(tp,c1644289.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「大日」魔法卡加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡片展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
