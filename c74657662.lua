--ヴァイロン・マテリアル
-- 效果：
-- 名字带有「大日」的怪兽才能装备。装备怪兽的攻击力上升600。场上表侧表示存在的这张卡被送去墓地的场合，可以从卡组把1张名字带有「大日」的魔法卡加入手卡。
function c74657662.initial_effect(c)
	-- 名字带有「大日」的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c74657662.target)
	e1:SetOperation(c74657662.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力上升600。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(600)
	c:RegisterEffect(e2)
	-- 名字带有「大日」的怪兽才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c74657662.eqlimit)
	c:RegisterEffect(e3)
	-- 场上表侧表示存在的这张卡被送去墓地的场合，可以从卡组把1张名字带有「大日」的魔法卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(74657662,0))  --"检索"
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c74657662.thcon)
	e4:SetTarget(c74657662.thtg)
	e4:SetOperation(c74657662.thop)
	c:RegisterEffect(e4)
end
-- 装备限制：只能装备给名字带有「大日」的怪兽
function c74657662.eqlimit(e,c)
	return c:IsSetCard(0x30)
end
-- 过滤条件：场上表侧表示的名字带有「大日」的怪兽
function c74657662.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x30)
end
-- 放入连锁：选择场上1只表侧表示的名字带有「大日」的怪兽作为装备对象
function c74657662.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c74657662.filter(chkc) end
	-- 检查场上是否存在可以装备的名字带有「大日」的怪兽
	if chk==0 then return Duel.IsExistingTarget(c74657662.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家发送提示信息：请选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示的名字带有「大日」的怪兽作为效果的对象
	Duel.SelectTarget(tp,c74657662.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：将这张卡装备给目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：将这张卡装备给选择的怪兽
function c74657662.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选择的第一个对象（即要装备的怪兽）
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 执行装备操作，将这张卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 发动条件：这张卡在场上表侧表示存在并被送去墓地
function c74657662.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_FACEUP)
		and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤条件：卡组中名字带有「大日」的魔法卡且能加入手卡
function c74657662.thfilter(c)
	return c:IsSetCard(0x30) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 放入连锁：检查并设置检索「大日」魔法卡的操作信息
function c74657662.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手卡的名字带有「大日」的魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c74657662.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组把1张名字带有「大日」的魔法卡加入手卡
function c74657662.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足条件的名字带有「大日」的魔法卡
	local g=Duel.SelectMatchingCard(tp,c74657662.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
