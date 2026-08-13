--魔王龍 ベエルゼ
-- 效果：
-- 暗属性调整＋调整以外的怪兽1只以上
-- ①：场上的这张卡不会被战斗·效果破坏。
-- ②：这张卡的战斗或者对方的效果让自己受到伤害的场合发动。这张卡的攻击力上升受到的伤害的数值。
function c34408491.initial_effect(c)
	-- 为这张卡添加同调召唤手续：可用暗属性调整1只 + 调整以外的怪兽1只以上进行同调召唤。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 对应①效果原文：‘场上的这张卡不会被战斗·效果破坏。’中的‘不会被战斗破坏’部分。
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
	-- 对应②效果原文：‘这张卡的战斗或者对方的效果让自己受到伤害的场合发动。这张卡的攻击力上升受到的伤害的数值。’
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(34408491,0))  --"攻击上升"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_DAMAGE)
	e3:SetCondition(c34408491.atkcon)
	e3:SetOperation(c34408491.atkop)
	c:RegisterEffect(e3)
end
-- ②效果的发动条件判定：自己受到伤害时才能发动；若伤害由效果造成，则必须是由对方发动的效果造成的伤害；若为战斗伤害，则要求这张卡与此战斗相关。
function c34408491.atkcon(e,tp,eg,ep,ev,re,r,rp)
	if ep~=tp then return false end
	if bit.band(r,REASON_EFFECT)~=0 then return rp==1-tp end
	return e:GetHandler():IsRelateToBattle()
end
-- ②效果处理：若这张卡仍表侧表示且与该效果关联，则为它生成一个使攻击力上升所受伤害数值（ev）的永续效果，并在卡片离场、无效等标准时机重置该效果。
function c34408491.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 对应②效果原文中的‘这张卡的攻击力上升受到的伤害的数值。’
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ev)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
