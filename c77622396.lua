--あまのじゃくの呪い
-- 效果：
-- 直到发动回合的结束阶段时，攻击力·守备力的上升·下降的效果变成相反。
function c77622396.initial_effect(c)
	-- 直到发动回合的结束阶段时，攻击力·守备力的上升·下降的效果变成相反。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c77622396.activate)
	c:RegisterEffect(e1)
end
-- 卡片发动时的效果处理，在全局环境注册使攻守增减效果反转的效果。
function c77622396.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 直到发动回合的结束阶段时，攻击力·守备力的上升·下降的效果变成相反。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_REVERSE_UPDATE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 将该效果注册给玩家，使其作为全局场上效果生效。
	Duel.RegisterEffect(e1,tp)
end
