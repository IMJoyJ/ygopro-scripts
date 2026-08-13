--ニードル・ガンナー
-- 效果：
-- 这张卡为同调素材的同调怪兽向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
function c17841097.initial_effect(c)
	-- 这张卡为同调素材的同调怪兽向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e1:SetCondition(c17841097.pscon)
	e1:SetOperation(c17841097.psop)
	c:RegisterEffect(e1)
end
-- 判断该卡是否作为同调素材被送去墓地（位于墓地且原因为同调召唤），以确定是否为同调召唤提供素材。
function c17841097.pscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 获取这张卡作为素材同调召唤出的同调怪兽，并赋予其贯穿效果（攻击守备表示怪兽时若攻击力超过守备力则给予差值伤害）。
function c17841097.psop(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetHandler():GetReasonCard()
	-- 向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
end
