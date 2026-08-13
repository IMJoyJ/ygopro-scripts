--サイレント・ソードマン LV7
-- 效果：
-- 这张卡不能通常召唤。「沉默剑士 LV5」的效果才能特殊召唤。
-- ①：只要这张卡在怪兽区域存在，场上的魔法卡的效果无效化。
function c37267041.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。「沉默剑士 LV5」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件效果的值设为恒为 false（aux.FALSE 始终返回 false），使这张卡不被常规特殊召唤方式允许，只能通过「沉默剑士 LV5」的效果特殊召唤。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，场上的魔法卡的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e2:SetTarget(c37267041.distg)
	c:RegisterEffect(e2)
	-- ①：只要这张卡在怪兽区域存在，场上的魔法卡的效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(c37267041.disop)
	c:RegisterEffect(e3)
end
c37267041.lvup={74388798}
c37267041.lvdn={1995985,74388798}
-- 定义无效对象的筛选函数：仅将魔法卡（TYPE_SPELL）作为无效化对象，从而实现只无效“魔法卡”的效果。
function c37267041.distg(e,c)
	return c:IsType(TYPE_SPELL)
end
-- 连锁处理时的无效化操作：检测到从魔法与陷阱区域发动的魔法卡效果进入连锁时，将其效果无效，维护①的无效化效果。
function c37267041.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的发动位置（CHAININFO_TRIGGERING_LOCATION），用于判断该效果是否来自魔法与陷阱区域。
	local tl=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if bit.band(tl,LOCATION_SZONE)~=0 and re:IsActiveType(TYPE_SPELL) then
		-- 将当前连锁上的魔法卡效果无效，实际执行“场上的魔法卡的效果无效化”。
		Duel.NegateEffect(ev)
	end
end
