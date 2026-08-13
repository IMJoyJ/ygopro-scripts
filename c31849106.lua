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
-- 发动后，为当前回合玩家注册一个持续到结束阶段的领域效果：将符合“原始类型为怪兽且不是作为超量素材、也不是被当作魔法陷阱卡使用”的卡改为除外而不是送去墓地；该效果带有SET_AVAILABLE、IGNORE_RANGE、IGNORE_IMMUNE，即里侧表示的卡也适用、全场所有区域生效且不受效果免疫影响。
function c31849106.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，被送去墓地的怪兽不去墓地而除外。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	-- 设置重定向效果的过滤目标：只有通过aux.DimensionalFissureTarget判断为“原本是怪兽且不是作为超量素材送去墓地、也不是被当作魔法陷阱卡使用的卡”才会被改为除外。
	e1:SetTarget(aux.DimensionalFissureTarget)
	e1:SetTargetRange(LOCATION_DECK,LOCATION_DECK)
	e1:SetValue(LOCATION_REMOVED)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将领域效果e1注册到发动玩家tp的一方，使其作为全场效果生效，并在本回合结束阶段自动重置失效。
	Duel.RegisterEffect(e1,tp)
end
