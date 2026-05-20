--盗人の煙玉
-- 效果：
-- 装备在怪兽上的这张卡被其他卡的效果破坏时，看对方手卡并选择1张丢弃。
function c63789924.initial_effect(c)
	-- （作为装备魔法卡的发动）
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c63789924.target)
	e1:SetOperation(c63789924.operation)
	c:RegisterEffect(e1)
	-- （装备限制）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 装备在怪兽上的这张卡被其他卡的效果破坏时，看对方手卡并选择1张丢弃。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(63789924,0))  --"手牌丢弃"
	e3:SetCategory(CATEGORY_HANDES)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c63789924.discon)
	e3:SetTarget(c63789924.distg)
	e3:SetOperation(c63789924.disop)
	c:RegisterEffect(e3)
end
-- 装备魔法卡发动时的对象选择与效果处理准备
function c63789924.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在可以装备的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示怪兽作为装备对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁信息，表示该效果包含装备操作，对象为这张卡自身
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动成功后的装备效果处理
function c63789924.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备对象怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 检查此卡是否在装备状态下被其他卡的效果破坏
function c63789924.discon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,0x41)==0x41 and e:GetHandler():GetEquipTarget()~=nil
end
-- 丢弃手牌效果的发动准备，设置对象玩家和连锁信息
function c63789924.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为发动效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁信息，表示该效果包含丢弃对方1张手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,1)
end
-- 丢弃手牌效果的具体处理：确认对方手牌并选择1张丢弃
function c63789924.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理的玩家（即发动效果的玩家）
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取对方玩家的所有手牌
	local g=Duel.GetFieldGroup(p,0,LOCATION_HAND)
	if g:GetCount()>0 then
		-- 让发动效果的玩家确认对方的所有手牌
		Duel.ConfirmCards(p,g)
		-- 提示玩家选择要丢弃的手牌
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		local sg=g:Select(p,1,1,nil)
		-- 将选择的卡因效果丢弃送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
		-- 将对方剩余的手牌洗切
		Duel.ShuffleHand(1-p)
	end
end
