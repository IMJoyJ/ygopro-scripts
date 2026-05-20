--EXP
-- 效果：
-- ①：这个回合，自己在通常的灵摆召唤外加上只有1次，自己主要阶段可以从额外卡组把怪兽灵摆召唤。
function c58308221.initial_effect(c)
	-- ①：这个回合，自己在通常的灵摆召唤外加上只有1次，自己主要阶段可以从额外卡组把怪兽灵摆召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c58308221.target)
	e1:SetOperation(c58308221.activate)
	c:RegisterEffect(e1)
end
-- 卡片发动的靶向与条件检查函数。
function c58308221.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家本回合是否尚未发动过此卡（通过检查全局标识数量是否为0）。
	if chk==0 then return Duel.GetFlagEffect(tp,58308221)==0 end
end
-- 卡片发动成功后的效果处理，为玩家注册额外灵摆召唤的效果并添加回合结束重置的已发动标识。
function c58308221.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 自己在通常的灵摆召唤外加上只有1次，自己主要阶段可以从额外卡组把怪兽灵摆召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(58308221,0))  --"使用「额外灵摆」的效果灵摆召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_PENDULUM_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetCountLimit(1,58308221)
	e1:SetValue(c58308221.pendvalue)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将额外灵摆召唤的效果注册给发动该卡效果的玩家。
	Duel.RegisterEffect(e1,tp)
	-- 为玩家注册一个在回合结束时重置的全局标识，用于限制同名卡一回合只能发动一次。
	Duel.RegisterFlagEffect(tp,58308221,RESET_PHASE+PHASE_END,0,1)
end
-- 过滤函数，限制该额外灵摆召唤的怪兽必须是存在于额外卡组的怪兽。
function c58308221.pendvalue(e,c)
	return c:IsLocation(LOCATION_EXTRA)
end
