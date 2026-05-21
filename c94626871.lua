--トリックスター・スイートデビル
-- 效果：
-- 「淘气仙星」怪兽2只
-- ①：只要这张卡在怪兽区域存在，每次这张卡所连接区的怪兽被战斗·效果破坏送去墓地，给与对方200伤害。
-- ②：每次「淘气仙星」怪兽的效果让对方受到伤害发动。对方场上的全部表侧表示怪兽的攻击力直到回合结束时下降这张卡所连接区的怪兽数量×200。
function c94626871.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤条件为「淘气仙星」怪兽2只
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0xfb),2,2)
	-- ①：只要这张卡在怪兽区域存在，每次这张卡所连接区的怪兽被战斗·效果破坏送去墓地，给与对方200伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c94626871.damcon)
	e2:SetOperation(c94626871.damop)
	c:RegisterEffect(e2)
	-- ②：每次「淘气仙星」怪兽的效果让对方受到伤害发动。对方场上的全部表侧表示怪兽的攻击力直到回合结束时下降这张卡所连接区的怪兽数量×200。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_DAMAGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c94626871.atkcon)
	e3:SetOperation(c94626871.atkop)
	c:RegisterEffect(e3)
end
-- 过滤在自身所连接区被战斗·效果破坏并送去墓地的怪兽
function c94626871.cfilter(c,tp,zone)
	local seq=c:GetPreviousSequence()
	if c:IsPreviousControler(1-tp) then seq=seq+16 end
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_MZONE) and bit.extract(zone,seq)~=0
end
-- 检查送去墓地的怪兽中是否存在在自身所连接区被破坏的怪兽
function c94626871.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c94626871.cfilter,1,nil,tp,e:GetHandler():GetLinkedZone())
end
-- 给与对方200点效果伤害的执行操作
function c94626871.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 在决斗中显示该卡片发动的提示动画
	Duel.Hint(HINT_CARD,0,94626871)
	-- 给与对方玩家200点效果伤害
	Duel.Damage(1-tp,200,REASON_EFFECT)
end
-- 检查是否是「淘气仙星」怪兽的效果让对方受到伤害
function c94626871.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and bit.band(r,REASON_BATTLE)==0 and re
		and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0xfb)
end
-- 降低对方场上所有表侧表示怪兽攻击力的执行操作
function c94626871.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetLinkedGroupCount()
	if ct<=0 then return end
	-- 获取对方场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 攻击力直到回合结束时下降这张卡所连接区的怪兽数量×200
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-ct*200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
