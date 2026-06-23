--グレイモヤ不発弾
-- 效果：
-- 选择场上表侧攻击表示存在的2只怪兽发动。选择的怪兽从场上离开时，这张卡破坏。这张卡破坏时，选择的怪兽破坏。
function c42167046.initial_effect(c)
	-- 选择场上表侧攻击表示存在的2只怪兽发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c42167046.target)
	e1:SetOperation(c42167046.operation)
	c:RegisterEffect(e1)
	-- 选择的怪兽从场上离开时，这张卡破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c42167046.descon1)
	e2:SetOperation(c42167046.desop1)
	c:RegisterEffect(e2)
	-- 这张卡破坏时，选择的怪兽破坏
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c42167046.descon2)
	e3:SetOperation(c42167046.desop2)
	c:RegisterEffect(e3)
end
-- 选择场上表侧攻击表示存在的2只怪兽发动
function c42167046.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsPosition(POS_FACEUP_ATTACK) end
	-- 检查场上是否存在2只表侧攻击表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsPosition,tp,LOCATION_MZONE,LOCATION_MZONE,2,nil,POS_FACEUP_ATTACK) end
	-- 提示玩家选择表侧攻击表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUPATTACK)  --"请选择表侧攻击表示的怪兽"
	-- 选择2只表侧攻击表示的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsPosition,tp,LOCATION_MZONE,LOCATION_MZONE,2,2,nil,POS_FACEUP_ATTACK)
end
-- 将选择的怪兽设置为这张卡的效果对象
function c42167046.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁中被选择的怪兽组并过滤出与效果相关的怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local tc=g:GetFirst()
	while tc do
		c:SetCardTarget(tc)
		tc=g:GetNext()
	end
end
-- 判断这张卡是否因破坏而离场
function c42167046.descon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- 将与这张卡绑定的怪兽中仍在场上的怪兽破坏
function c42167046.desop1(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetCardTarget():Filter(Card.IsLocation,nil,LOCATION_MZONE)
	-- 将怪兽组破坏
	Duel.Destroy(g,REASON_EFFECT)
end
-- 判断被破坏的怪兽是否为之前选择的怪兽之一
function c42167046.descon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetCardTargetCount()==0 then return false end
	local g=c:GetCardTarget()
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	return eg:IsContains(tc1) or (tc2 and eg:IsContains(tc2))
end
-- 将这张卡破坏
function c42167046.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 将这张卡破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
