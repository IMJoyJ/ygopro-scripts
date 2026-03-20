--グローウィング・ボウガン
-- 效果：
-- 「黑羽」怪兽才能装备。这个卡名的②③的效果1回合各能使用1次。
-- ①：装备怪兽的攻击力·守备力上升500。
-- ②：装备怪兽战斗破坏对方怪兽的场合才能发动。对方手卡随机选1张丢弃。
-- ③：装备怪兽成为同调素材让这张卡被送去墓地的场合才能发动。墓地的这张卡加入手卡。
function c53860621.initial_effect(c)
	-- ①：装备怪兽的攻击力·守备力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c53860621.target)
	e1:SetOperation(c53860621.operation)
	c:RegisterEffect(e1)
	-- 「黑羽」怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetValue(c53860621.eqlimit)
	c:RegisterEffect(e2)
	-- ①：装备怪兽的攻击力·守备力上升500。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(500)
	c:RegisterEffect(e3)
	-- ①：装备怪兽的攻击力·守备力上升500。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	e4:SetValue(500)
	c:RegisterEffect(e4)
	-- ②：装备怪兽战斗破坏对方怪兽的场合才能发动。对方手卡随机选1张丢弃。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(53860621,0))
	e5:SetCategory(CATEGORY_HANDES)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_BATTLE_DESTROYING)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1,53860621)
	e5:SetCondition(c53860621.descon)
	e5:SetTarget(c53860621.destg)
	e5:SetOperation(c53860621.desop)
	c:RegisterEffect(e5)
	-- ③：装备怪兽成为同调素材让这张卡被送去墓地的场合才能发动。墓地的这张卡加入手卡。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(53860621,1))
	e6:SetCategory(CATEGORY_TOHAND)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCode(EVENT_TO_GRAVE)
	e6:SetCountLimit(1,53860622)
	e6:SetCondition(c53860621.retcon)
	e6:SetTarget(c53860621.rettg)
	e6:SetOperation(c53860621.retop)
	c:RegisterEffect(e6)
end
-- 限制只能装备「黑羽」怪兽
function c53860621.eqlimit(e,c)
	return c:IsSetCard(0x33)
end
-- 判断是否为「黑羽」怪兽且表侧表示
function c53860621.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x33)
end
-- 选择装备对象，要求为「黑羽」怪兽且表侧表示
function c53860621.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c53860621.eqfilter(chkc) end
	-- 判断是否存在符合条件的装备对象
	if chk==0 then return Duel.IsExistingTarget(c53860621.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择装备对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择一个「黑羽」怪兽作为装备对象
	Duel.SelectTarget(tp,c53860621.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，表示将装备卡装备给目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备卡的发动效果处理
function c53860621.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 判断是否为装备怪兽战斗破坏对方怪兽的场合
function c53860621.descon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and eg:IsContains(ec)
end
-- 准备发动效果，判断对方手牌数量是否大于0
function c53860621.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断对方手牌数量是否大于0
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	-- 设置效果处理信息，表示将对方手牌丢弃
	Duel.SetOperationInfo(0,CATEGORY_HANDES,0,0,1-tp,1)
end
-- 发动效果，随机选择对方一张手牌丢弃
function c53860621.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手牌组
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(1-tp,1)
	-- 将选择的对方手牌丢入墓地
	Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)
end
-- 判断是否为装备怪兽成为同调素材被送去墓地的场合
function c53860621.retcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	return c:IsReason(REASON_LOST_TARGET) and ec:IsReason(REASON_SYNCHRO)
end
-- 准备发动效果，判断此卡是否能加入手牌
function c53860621.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置效果处理信息，表示将此卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 发动效果，将此卡加入手牌并确认
function c53860621.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡加入玩家手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 向对方确认此卡加入手牌
		Duel.ConfirmCards(1-tp,c)
	end
end
