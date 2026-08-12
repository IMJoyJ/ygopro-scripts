--機殻の生贄
-- 效果：
-- 「机壳」怪兽才能装备。
-- ①：装备怪兽的攻击力上升300，不会被战斗破坏。
-- ②：「机壳」怪兽上级召唤的场合，装备怪兽可以作为2只的数量解放。
-- ③：这张卡从场上送去墓地的场合才能发动。从卡组把1只「机壳」怪兽加入手卡。
function c17639150.initial_effect(c)
	-- ①：装备怪兽的攻击力上升300，不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c17639150.eqtg)
	e1:SetOperation(c17639150.eqop)
	c:RegisterEffect(e1)
	-- 「机壳」怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c17639150.effcon)
	c:RegisterEffect(e2)
	-- ①：装备怪兽的攻击力上升300，不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(300)
	c:RegisterEffect(e3)
	-- ①：装备怪兽的攻击力上升300，不会被战斗破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	-- ②：「机壳」怪兽上级召唤的场合，装备怪兽可以作为2只的数量解放。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e5:SetValue(c17639150.effcon)
	c:RegisterEffect(e5)
	-- ③：这张卡从场上送去墓地的场合才能发动。从卡组把1只「机壳」怪兽加入手卡。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(17639150,0))  --"卡组检索"
	e6:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_TO_GRAVE)
	e6:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e6:SetCondition(c17639150.thcon)
	e6:SetTarget(c17639150.thtg)
	e6:SetOperation(c17639150.thop)
	c:RegisterEffect(e6)
end
-- 判断目标怪兽是否为「机壳」怪兽
function c17639150.effcon(e,c)
	return c:IsSetCard(0xaa)
end
-- 过滤出场上正面表示的「机壳」怪兽
function c17639150.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xaa)
end
-- 选择场上正面表示的「机壳」怪兽作为装备对象
function c17639150.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c17639150.eqfilter(chkc) end
	-- 检查场上是否存在正面表示的「机壳」怪兽
	if chk==0 then return Duel.IsExistingTarget(c17639150.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上正面表示的「机壳」怪兽作为装备对象
	Duel.SelectTarget(tp,c17639150.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置装备效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备卡的处理函数
function c17639150.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的装备对象
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 判断此卡是否从场上送去墓地
function c17639150.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤出卡组中可加入手牌的「机壳」怪兽
function c17639150.thfilter(c)
	return c:IsSetCard(0xaa) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置检索效果的操作信息
function c17639150.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在「机壳」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c17639150.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索卡组中的「机壳」怪兽并加入手牌
function c17639150.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只「机壳」怪兽
	local g=Duel.SelectMatchingCard(tp,c17639150.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「机壳」怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
