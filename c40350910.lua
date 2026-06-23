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
-- 将效果注册给全局环境，使场上的盖放的魔法·陷阱不会被效果破坏
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
	-- 把效果作为玩家player的效果注册给全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 判断目标卡片是否为里侧表示
function c40350910.infilter(e,c)
	return c:IsFacedown()
end
