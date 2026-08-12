--異次元グランド
-- 效果：
-- ①：这个回合，被送去墓地的怪兽不去墓地而除外。
function c31849106.initial_effect(c)
	-- ①：这个回合，被送去墓地的怪兽不去墓地而除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c31849106.activate)
	c:RegisterEffect(e1)
end
-- 将效果应用于场上，使符合条件的怪兽在送去墓地时改为除外。
function c31849106.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 将效果应用于场上，使符合条件的怪兽在送去墓地时改为除外。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	-- 设置效果的目标为符合“次元的裂痕”除外条件的怪兽。
	e1:SetTarget(aux.DimensionalFissureTarget)
	e1:SetTargetRange(LOCATION_DECK,LOCATION_DECK)
	e1:SetValue(LOCATION_REMOVED)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该效果注册到玩家的场上，使其生效至结束阶段。
	Duel.RegisterEffect(e1,tp)
end
