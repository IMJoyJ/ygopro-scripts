--サイレント・ソードマン LV7
-- 效果：
-- 这张卡不能通常召唤。「沉默剑士 LV5」的效果才能特殊召唤。
-- ①：只要这张卡在怪兽区域存在，场上的魔法卡的效果无效化。
function c37267041.initial_effect(c)
	c:EnableReviveLimit()
	-- 「沉默剑士 LV5」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 使这张卡不能通常召唤。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 场上的魔法卡的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e2:SetTarget(c37267041.distg)
	c:RegisterEffect(e2)
	-- 连锁处理开始时无效魔法卡效果。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(c37267041.disop)
	c:RegisterEffect(e3)
end
c37267041.lvup={74388798}
c37267041.lvdn={1995985,74388798}
-- 目标为魔法卡。
function c37267041.distg(e,c)
	return c:IsType(TYPE_SPELL)
end
-- 若连锁为魔法卡效果且发生在魔法区，则无效该效果。
function c37267041.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的触发位置。
	local tl=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if bit.band(tl,LOCATION_SZONE)~=0 and re:IsActiveType(TYPE_SPELL) then
		-- 使该连锁效果无效。
		Duel.NegateEffect(ev)
	end
end
