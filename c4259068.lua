--魔力倹約術
-- 效果：
-- 发动魔法卡时不需支付基本分。
function c4259068.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 发动魔法卡时不需支付基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_LPCOST_CHANGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(1,0)
	e2:SetValue(c4259068.costchange)
	c:RegisterEffect(e2)
end
-- 作为永续效果，当自己发动魔法卡需要支付基本分时，将所需支付的基本分变为0；但存在例外：卡号为9236985（遗式的写魂镜）和57496978（相互碰撞的灵魂）的卡发动时不适用此效果，仍按原费用支付。
function c4259068.costchange(e,re,rp,val)
	if re and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsType(TYPE_SPELL) and not re:GetHandler():IsCode(9236985,57496978) then
		return 0
	else
		return val
	end
end
