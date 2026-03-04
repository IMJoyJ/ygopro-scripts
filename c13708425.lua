--フレア・リゾネーター
-- 效果：
-- 这张卡为同调素材的同调怪兽的攻击力上升300。
function c13708425.initial_effect(c)
	-- 这张卡为同调素材的同调怪兽的攻击力上升300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e1:SetCondition(c13708425.atkcon)
	e1:SetOperation(c13708425.atkop)
	c:RegisterEffect(e1)
end
-- 效果作用：判断是否因同调召唤成为素材
function c13708425.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO
end
-- 效果作用：使同调怪兽攻击力上升300
function c13708425.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sync=c:GetReasonCard()
	-- 使同调怪兽攻击力上升300
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(300)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	sync:RegisterEffect(e1,true)
end
