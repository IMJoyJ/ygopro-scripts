--魔王龍 ベエルゼ
-- 效果：
-- 暗属性调整＋调整以外的怪兽1只以上
-- ①：场上的这张卡不会被战斗·效果破坏。
-- ②：这张卡的战斗或者对方的效果让自己受到伤害的场合发动。这张卡的攻击力上升受到的伤害的数值。
function c34408491.initial_effect(c)
	-- 添加同调召唤手续，要求1只暗属性调整和1只以上调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：场上的这张卡不会被战斗·效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
	-- ②：这张卡的战斗或者对方的效果让自己受到伤害的场合发动。这张卡的攻击力上升受到的伤害的数值。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(34408491,0))  --"攻击上升"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_DAMAGE)
	e3:SetCondition(c34408491.atkcon)
	e3:SetOperation(c34408491.atkop)
	c:RegisterEffect(e3)
end
-- 效果发动条件判断：伤害是由对方效果造成且自己为伤害接受方，或自己参与战斗且处于战斗状态
function c34408491.atkcon(e,tp,eg,ep,ev,re,r,rp)
	if ep~=tp then return false end
	if bit.band(r,REASON_EFFECT)~=0 then return rp==1-tp end
	return e:GetHandler():IsRelateToBattle()
end
-- 效果处理：使该怪兽的攻击力上升受到的伤害数值
function c34408491.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 将攻击力提升效果注册给该怪兽
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ev)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
