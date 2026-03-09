--Ωメガネ
-- 效果：
-- 这张卡只有自己场上的怪兽才能装备。1回合1次，对方手卡随机选择1张确认。这个效果发动的回合，装备怪兽不能攻击。
function c4857085.initial_effect(c)
	-- 这张卡只有自己场上的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c4857085.target)
	e1:SetOperation(c4857085.operation)
	c:RegisterEffect(e1)
	-- 1回合1次，对方手卡随机选择1张确认。
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetValue(c4857085.eqlimit)
	c:RegisterEffect(e2)
	-- 这个效果发动的回合，装备怪兽不能攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(4857085,0))  --"确认手牌"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c4857085.cfcost)
	e3:SetTarget(c4857085.cftg)
	e3:SetOperation(c4857085.cfop)
	c:RegisterEffect(e3)
end
-- 限制装备对象为自己的怪兽
function c4857085.eqlimit(e,c)
	return c:IsControler(e:GetHandlerPlayer())
end
-- 选择装备目标怪兽
function c4857085.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 检查是否有可装备的己方表侧怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择一个己方表侧怪兽作为装备对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息，准备将此卡装备给目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作
function c4857085.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将此卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 支付装备效果的费用
function c4857085.cfcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetEquipTarget():GetAttackAnnouncedCount()==0 end
	-- 装备时使目标怪兽不能攻击
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 确认对方手牌是否为空
function c4857085.cftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方是否有手牌
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
end
-- 执行确认对方手牌并洗切对方手牌的操作
function c4857085.cfop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手牌组
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(tp,1)
	-- 向玩家确认选择的对方手牌
	Duel.ConfirmCards(tp,sg)
	-- 将对方手牌洗切
	Duel.ShuffleHand(1-tp)
end
