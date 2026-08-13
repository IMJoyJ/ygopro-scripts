--おくびょうかぜ
-- 效果：
-- 直到下次的对方回合的结束阶段，场上的盖放的魔法·陷阱不能破坏。
function c40350910.initial_effect(c)
	-- 直到下次的对方回合的结束阶段，场上的盖放的魔法·陷阱不能破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c40350910.activate)
	c:RegisterEffect(e1)
end
-- 创建一个持续效果并注册：使双方魔法与陷阱区域的里侧表示的魔法·陷阱卡不受效果破坏影响；该效果对里侧卡也适用（EFFECT_FLAG_SET_AVAILABLE），并在经过第2次结束阶段（即下次对方回合的结束阶段）后自动失效。
function c40350910.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 直到下次的对方回合的结束阶段，场上的盖放的魔法·陷阱不能破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTarget(c40350910.infilter)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 将刚创建的抗性效果e1正式登记到场上（持有者为tp），使其开始影响双方魔法与陷阱区域；该效果会在设定的重置阶段/次数到达后自动失效。
	Duel.RegisterEffect(e1,tp)
end
-- 效果适用对象的判定过滤器：仅当卡为里侧表示时返回true，即保护对象限定为场上里侧表示的魔法·陷阱卡。
function c40350910.infilter(e,c)
	return c:IsFacedown()
end
